package com.dcms.controller;

import com.dcms.dao.DentistDAO;
import com.dcms.dao.PatientDAO;
import com.dcms.model.Appointment;
import com.dcms.model.Dentist;
import com.dcms.model.Patient;
import com.dcms.model.User;
import com.dcms.model.Visit;
import com.dcms.service.AppointmentService;
import com.dcms.service.VisitService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * CheckInServlet handles patient reception, walk-in registration, and dentist waiting queues.
 */
@WebServlet(name = "CheckInServlet", urlPatterns = {
        "/reception/checkin",
        "/reception/walkin",
        "/dentist/queue",
        "/dentist/start-exam"
})
public class CheckInServlet extends HttpServlet {

    private VisitService visitService;
    private AppointmentService appointmentService;
    private DentistDAO dentistDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.visitService = new VisitService();
        this.appointmentService = new AppointmentService();
        this.dentistDAO = new DentistDAO();
        this.patientDAO = new PatientDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/reception/walkin".equals(servletPath)) {
            showWalkInForm(request, response);
            return;
        }

        if ("/dentist/queue".equals(servletPath)) {
            showDentistQueue(request, response);
            return;
        }

        // Default: Reception Check-in Hub
        showReceptionCheckIn(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();

        if ("/reception/walkin".equals(servletPath)) {
            handleCreateWalkIn(request, response);
            return;
        }

        if ("/dentist/start-exam".equals(servletPath)) {
            handleStartExam(request, response);
            return;
        }

        // Default: POST /reception/checkin (Scheduled check-in)
        handleScheduledCheckIn(request, response);
    }

    private void showReceptionCheckIn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate today = LocalDate.now();

        // 1. Appointments scheduled for today
        List<Appointment> todayAppointments = appointmentService.getAppointmentsForDate(today, null);

        // 2. Currently waiting patient queue
        List<Visit> waitingQueue = visitService.getTodayWaitingQueue(null);

        request.setAttribute("todayAppointments", todayAppointments);
        request.setAttribute("waitingQueue", waitingQueue);
        request.setAttribute("todayDate", today);

        request.getRequestDispatcher("/WEB-INF/views/receptionist/checkin.jsp").forward(request, response);
    }

    private void showWalkInForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Dentist> dentists = dentistDAO.listAllDentists();
        request.setAttribute("dentists", dentists);

        String patientIdParam = request.getParameter("patientId");
        if (patientIdParam != null && !patientIdParam.trim().isEmpty()) {
            try {
                int patientId = Integer.parseInt(patientIdParam.trim());
                Patient patient = patientDAO.findById(patientId);
                request.setAttribute("selectedPatient", patient);
            } catch (NumberFormatException ignored) {}
        }

        request.getRequestDispatcher("/WEB-INF/views/receptionist/walkin-form.jsp").forward(request, response);
    }

    private void showDentistQueue(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        Integer dentistId = null;
        if (currentUser != null && "Dentist".equalsIgnoreCase(currentUser.getRoleName())) {
            dentistId = currentUser.getUserId();
        }

        List<Visit> queue = visitService.getTodayWaitingQueue(dentistId);
        request.setAttribute("waitingQueue", queue);
        request.setAttribute("dentistId", dentistId);

        request.getRequestDispatcher("/WEB-INF/views/dentist/queue.jsp").forward(request, response);
    }

    private void handleScheduledCheckIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String apptIdParam = request.getParameter("appointmentId");
        try {
            int appointmentId = Integer.parseInt(apptIdParam);
            Visit visit = visitService.checkInPatient(appointmentId);
            response.sendRedirect(request.getContextPath() + "/reception/checkin?success=checkedin&visitId=" + visit.getVisitId());
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/reception/checkin?error="
                    + java.net.URLEncoder.encode(ex.getMessage() != null ? ex.getMessage() : "Không thể check-in", "UTF-8"));
        }
    }

    private void handleCreateWalkIn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String patientIdStr = request.getParameter("patientId");
            String dentistIdStr = request.getParameter("dentistId");

            if (patientIdStr == null || patientIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng tìm kiếm và chọn bệnh nhân từ danh sách gợi ý trước khi tiếp nhận.");
            }
            if (dentistIdStr == null || dentistIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn bác sĩ phụ trách tiếp nhận ca khám.");
            }

            int patientId = Integer.parseInt(patientIdStr.trim());
            int dentistId = Integer.parseInt(dentistIdStr.trim());
            String visitType = request.getParameter("visitType");
            String notes = request.getParameter("notes");

            Visit visit = visitService.createWalkInVisit(patientId, dentistId, visitType, notes);
            response.sendRedirect(request.getContextPath() + "/reception/checkin?success=walkin&visitId=" + visit.getVisitId());
        } catch (NumberFormatException ex) {
            request.setAttribute("errorMessage", "Mã bệnh nhân hoặc mã bác sĩ không đúng định dạng số.");
            showWalkInForm(request, response);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            showWalkInForm(request, response);
        }
    }

    private void handleStartExam(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String visitIdParam = request.getParameter("visitId");
        String operatory = request.getParameter("operatory");
        try {
            int visitId = Integer.parseInt(visitIdParam);
            Visit visit = visitService.getVisitById(visitId);
            if (visit == null) {
                throw new IllegalArgumentException("Không tìm thấy lượt khám");
            }
            HttpSession session = request.getSession(false);
            User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
            if (currentUser != null && "Dentist".equalsIgnoreCase(currentUser.getRoleName())
                    && currentUser.getUserId() != visit.getPrimaryDentistId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Lượt khám không được phân công cho bác sĩ này");
                return;
            }
            visitService.startExamination(visitId, operatory);
            response.sendRedirect(request.getContextPath() + "/clinical/examination?visitId=" + visitId + "&success=started");
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }
}
