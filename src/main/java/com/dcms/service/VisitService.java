package com.dcms.service;

import com.dcms.dao.AppointmentDAO;
import com.dcms.dao.VisitDAO;
import com.dcms.model.Appointment;
import com.dcms.model.Visit;

import java.time.LocalDateTime;
import java.util.List;

/**
 * VisitService implements core domain rules for Patient encounters and Clinic Reception.
 * ENFORCES NON-NEGOTIABLE RULE 1:
 * - Appointment != Visit
 * - An Appointment cannot become a Visit without explicit Check-in.
 * - Walk-in patients create a Visit directly without an Appointment.
 */
public class VisitService {

    private final VisitDAO visitDAO;
    private final AppointmentDAO appointmentDAO;

    public VisitService() {
        this.visitDAO = new VisitDAO();
        this.appointmentDAO = new AppointmentDAO();
    }

    public VisitService(VisitDAO visitDAO, AppointmentDAO appointmentDAO) {
        this.visitDAO = visitDAO;
        this.appointmentDAO = appointmentDAO;
    }

    /**
     * Checks in a scheduled patient when they physically arrive at the clinic.
     * Transitions Appointment status to 'Arrived' and spawns a new Visit in 'Waiting' status.
     * @param appointmentId valid appointment ID
     * @return created Visit entity
     */
    public Visit checkInPatient(int appointmentId) {
        Appointment appt = appointmentDAO.findById(appointmentId);
        if (appt == null) {
            throw new IllegalArgumentException("Không tìm thấy lịch hẹn với mã: " + appointmentId);
        }

        if (Appointment.STATUS_ARRIVED.equalsIgnoreCase(appt.getStatus())) {
            throw new IllegalStateException("Lịch hẹn này đã được tiếp đón (Check-in) trước đó!");
        }

        if (!appt.canBeCheckedIn()) {
            throw new IllegalStateException(
                    "Không thể check-in lịch hẹn đang ở trạng thái: " + appt.getStatus() +
                    " (Chỉ cho phép tiếp đón lịch hẹn Pending hoặc Confirmed)"
            );
        }

        // A retry (or two receptionists clicking at the same time) must never
        // create two encounters for one appointment. Keep this check before
        // changing the appointment state so a duplicate request is harmless.
        Visit existingVisit = visitDAO.findByAppointmentId(appointmentId);
        if (existingVisit != null) {
            throw new IllegalStateException("Lịch hẹn này đã có lượt khám #" + existingVisit.getVisitId());
        }

        // Instantiate the Visit before entering the atomic persistence path.
        Visit visit = new Visit();
        visit.setPatientId(appt.getPatientId());
        visit.setPrimaryDentistId(appt.getDentistId());
        visit.setAppointmentId(appt.getAppointmentId()); // Linked
        visit.setCheckInTime(LocalDateTime.now());
        visit.setStatus(Visit.STATUS_WAITING);
        visit.setVisitType(Visit.TYPE_SCHEDULED);
        visit.setNotes(appt.getReason() != null ? "Lịch hẹn: " + appt.getReason() : "Tiếp đón theo lịch hẹn");

        // Production VisitDAO uses one SQL transaction for both writes. A 0
        // return keeps compatibility with older adapters/mocks and falls back
        // to the original two-DAO flow below.
        int atomicVisitId = visitDAO.checkInAndCreateVisit(appointmentId, visit);
        if (atomicVisitId > 0) {
            visit.setVisitId(atomicVisitId);
            return visit;
        }
        if (atomicVisitId < 0) {
            throw new RuntimeException("Không thể cập nhật trạng thái lịch hẹn và khởi tạo lượt khám");
        }

        // Legacy fallback: compensate if Visit creation fails after the first
        // write. This branch is used only by older adapters.
        boolean updated = appointmentDAO.updateStatus(appointmentId, Appointment.STATUS_ARRIVED);
        if (!updated) {
            throw new RuntimeException("Không thể cập nhật trạng thái lịch hẹn sang Arrived");
        }

        int visitId = visitDAO.create(visit);
        if (visitId <= 0) {
            // The two DAO calls use separate connections in the legacy data
            // layer. Compensate the first write when the second one fails so
            // reception does not leave an Arrived appointment without a Visit.
            appointmentDAO.updateStatus(appointmentId, appt.getStatus());
            throw new RuntimeException("Lỗi hệ thống: Không thể khởi tạo lượt khám thực tế (Visit)");
        }
        visit.setVisitId(visitId);
        return visit;
    }

    /**
     * Registers a Walk-in or Emergency patient without prior appointment.
     * NON-NEGOTIABLE RULE: AppointmentId MUST be null.
     */
    public Visit createWalkInVisit(int patientId, int dentistId, String visitType, String notes) {
        if (patientId <= 0) {
            throw new IllegalArgumentException("Vui lòng chọn bệnh nhân");
        }
        if (dentistId <= 0) {
            throw new IllegalArgumentException("Vui lòng chọn bác sĩ phụ trách");
        }

        String type = (visitType != null && !visitType.trim().isEmpty()) ? visitType.trim() : Visit.TYPE_WALK_IN;

        Visit visit = new Visit();
        visit.setPatientId(patientId);
        visit.setPrimaryDentistId(dentistId);
        visit.setAppointmentId(null); // MANDATORY: NULL for walk-ins
        visit.setCheckInTime(LocalDateTime.now());
        visit.setStatus(Visit.STATUS_WAITING);
        visit.setVisitType(type);
        visit.setNotes(notes != null ? notes.trim() : "Khách vãng lai");

        int visitId = visitDAO.create(visit);
        if (visitId <= 0) {
            throw new RuntimeException("Lỗi hệ thống: Không thể khởi tạo lượt khám vãng lai");
        }
        visit.setVisitId(visitId);
        return visit;
    }

    public List<Visit> getTodayWaitingQueue(Integer dentistId) {
        return visitDAO.getWaitingQueue(dentistId);
    }

    public boolean startExamination(int visitId) {
        return startExamination(visitId, null);
    }

    public boolean startExamination(int visitId, String operatory) {
        Visit v = visitDAO.findById(visitId);
        if (v == null) {
            throw new IllegalArgumentException("Không tìm thấy lượt khám với mã: " + visitId);
        }
        if (!Visit.STATUS_WAITING.equalsIgnoreCase(v.getStatus()) && !Visit.STATUS_IN_PROGRESS.equalsIgnoreCase(v.getStatus())) {
            throw new IllegalStateException("Lượt khám không ở trạng thái hợp lệ để bắt đầu khám");
        }
        if (operatory != null && !operatory.trim().isEmpty()) {
            visitDAO.updateOperatory(visitId, operatory.trim());
        }
        return visitDAO.updateStatus(visitId, Visit.STATUS_IN_PROGRESS);
    }

    public boolean assignOperatory(int visitId, String operatory) {
        if (visitId <= 0) {
            throw new IllegalArgumentException("Mã lượt khám không hợp lệ");
        }
        return visitDAO.updateOperatory(visitId, operatory);
    }

    public boolean completeVisit(int visitId) {
        Visit v = visitDAO.findById(visitId);
        if (v == null) {
            throw new IllegalArgumentException("Không tìm thấy lượt khám với mã: " + visitId);
        }
        if (!Visit.STATUS_IN_PROGRESS.equalsIgnoreCase(v.getStatus())) {
            throw new IllegalStateException("Chỉ có thể hoàn tất lượt khám đang ở trạng thái InProgress");
        }
        boolean visitCompleted = visitDAO.updateStatus(visitId, Visit.STATUS_COMPLETED);
        if (!visitCompleted) {
            throw new IllegalStateException("Không thể hoàn tất lượt khám");
        }
        if (v.getAppointmentId() != null) {
            boolean updatedAppointment = appointmentDAO.updateStatus(v.getAppointmentId(), Appointment.STATUS_COMPLETED);
            if (!updatedAppointment) {
                visitDAO.updateStatus(visitId, Visit.STATUS_IN_PROGRESS);
                throw new IllegalStateException("Không thể cập nhật trạng thái lịch hẹn liên kết");
            }
        }
        return true;
    }

    public Visit getVisitById(int visitId) {
        return visitDAO.findById(visitId);
    }

    public List<Visit> getTodayVisits() {
        return visitDAO.findTodayVisits();
    }
}
