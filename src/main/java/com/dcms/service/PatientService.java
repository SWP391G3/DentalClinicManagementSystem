package com.dcms.service;

import com.dcms.dao.PatientDAO;
import com.dcms.model.Patient;
import com.dcms.service.exception.DuplicatePhoneException;
import com.dcms.service.exception.PatientValidationException;

import java.util.List;
import java.util.regex.Pattern;

/**
 * PatientService implements business logic and domain validation for patients.
 */
public class PatientService {

    private static final Pattern VN_PHONE_PATTERN = Pattern.compile("^0[35789]\\d{8}$");

    private final PatientDAO patientDAO;

    public PatientService() {
        this.patientDAO = new PatientDAO();
    }

    public PatientService(PatientDAO patientDAO) {
        this.patientDAO = patientDAO;
    }

    /**
     * Create a new patient record with business validations.
     * @param patient patient info
     * @return saved patient with ID
     */
    public Patient createPatient(Patient patient) {
        validatePatient(patient);

        // Check duplicate phone
        Patient existing = patientDAO.findByPhone(patient.getPhone().trim());
        if (existing != null) {
            throw new DuplicatePhoneException("Số điện thoại [" + patient.getPhone() + "] đã tồn tại trong hệ thống (Bệnh nhân: " + existing.getFullName() + ")");
        }

        int generatedId = patientDAO.create(patient);
        if (generatedId <= 0) {
            throw new RuntimeException("Lỗi hệ thống: Không thể lưu hồ sơ bệnh nhân vào cơ sở dữ liệu");
        }
        patient.setPatientId(generatedId);
        return patient;
    }

    /**
     * Update an existing patient record.
     */
    public boolean updatePatient(Patient patient) {
        if (patient.getPatientId() <= 0) {
            throw new PatientValidationException("ID bệnh nhân không hợp lệ");
        }
        validatePatient(patient);

        Patient existing = patientDAO.findByPhone(patient.getPhone().trim());
        if (existing != null && existing.getPatientId() != patient.getPatientId()) {
            throw new DuplicatePhoneException("Số điện thoại [" + patient.getPhone() + "] đã được dùng bởi bệnh nhân khác");
        }

        return patientDAO.update(patient);
    }

    public Patient getPatientById(int patientId) {
        return patientDAO.findById(patientId);
    }

    public Patient getPatientByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null;
        }
        return patientDAO.findByPhone(phone.trim());
    }

    public List<Patient> searchPatients(String keyword, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;
        return patientDAO.search(keyword, offset, pageSize);
    }

    public int countPatients(String keyword) {
        return patientDAO.countSearch(keyword);
    }

    private void validatePatient(Patient patient) {
        if (patient == null) {
            throw new PatientValidationException("Dữ liệu bệnh nhân không được để trống");
        }

        if (patient.getFullName() == null || patient.getFullName().trim().isEmpty()) {
            throw new PatientValidationException("Họ và tên bệnh nhân là bắt buộc");
        }

        if (patient.getPhone() == null || patient.getPhone().trim().isEmpty()) {
            throw new PatientValidationException("Số điện thoại là bắt buộc");
        }

        String phone = patient.getPhone().trim();
        if (!VN_PHONE_PATTERN.matcher(phone).matches()) {
            throw new PatientValidationException("Số điện thoại không đúng định dạng Việt Nam (10 chữ số, bắt đầu bằng 03, 05, 07, 08, 09)");
        }

        String gender = patient.getGender();
        if (gender == null || (!gender.equals("Nam") && !gender.equals("Nữ") && !gender.equals("Khác"))) {
            throw new PatientValidationException("Giới tính phải là 'Nam', 'Nữ' hoặc 'Khác'");
        }

        if (patient.getDob() != null) {
            java.time.LocalDate minAgeDate = java.time.LocalDate.now().minusYears(1);
            if (patient.getDob().isAfter(minAgeDate)) {
                throw new PatientValidationException("Tuổi bệnh nhân tối thiểu phải từ 12 tháng tuổi trở lên (ngày sinh tối đa là " + minAgeDate + ")");
            }
        }
    }
}
