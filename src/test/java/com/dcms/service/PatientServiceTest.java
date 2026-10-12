package com.dcms.service;

import com.dcms.dao.PatientDAO;
import com.dcms.model.Patient;
import com.dcms.service.exception.DuplicatePhoneException;
import com.dcms.service.exception.PatientValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class PatientServiceTest {

    @Mock
    private PatientDAO patientDAO;

    private PatientService patientService;

    @BeforeEach
    public void setUp() {
        patientService = new PatientService(patientDAO);
    }

    @Test
    @DisplayName("TC_PAT_01: Create Patient Success with valid data")
    public void testCreatePatientSuccess() {
        Patient p = new Patient();
        p.setFullName("Nguyễn Văn A");
        p.setPhone("0988123456");
        p.setGender("Nam");
        p.setDob(LocalDate.of(1995, 5, 20));

        when(patientDAO.findByPhone("0988123456")).thenReturn(null);
        when(patientDAO.create(p)).thenReturn(101);

        Patient created = patientService.createPatient(p);

        assertNotNull(created);
        assertEquals(101, created.getPatientId());
        assertEquals("Nguyễn Văn A", created.getFullName());
        verify(patientDAO).create(p);
    }

    @Test
    @DisplayName("TC_PAT_02: Create Patient Fails when Phone already registered")
    public void testCreatePatientDuplicatePhone() {
        Patient p = new Patient();
        p.setFullName("Nguyễn Văn B");
        p.setPhone("0988123456");
        p.setGender("Nam");

        Patient existing = new Patient();
        existing.setPatientId(50);
        existing.setFullName("Người Đã Có");
        existing.setPhone("0988123456");

        when(patientDAO.findByPhone("0988123456")).thenReturn(existing);

        assertThrows(DuplicatePhoneException.class, () -> {
            patientService.createPatient(p);
        }, "Should throw DuplicatePhoneException when phone exists");

        verify(patientDAO, never()).create(any());
    }

    @Test
    @DisplayName("TC_PAT_03: Validation Error on invalid Vietnamese phone number")
    public void testCreatePatientInvalidPhone() {
        Patient p = new Patient();
        p.setFullName("Trần Thị C");
        p.setGender("Nữ");
        p.setPhone("123456"); // Invalid phone

        assertThrows(PatientValidationException.class, () -> {
            patientService.createPatient(p);
        });

        p.setPhone("0123456789"); // 01 is not a valid modern 10-digit mobile prefix
        assertThrows(PatientValidationException.class, () -> {
            patientService.createPatient(p);
        });
    }

    @Test
    @DisplayName("TC_PAT_04: Validation Error on blank FullName")
    public void testCreatePatientBlankName() {
        Patient p = new Patient();
        p.setFullName("   ");
        p.setPhone("0988123456");
        p.setGender("Nam");

        assertThrows(PatientValidationException.class, () -> {
            patientService.createPatient(p);
        });
    }

    @Test
    @DisplayName("TC_PAT_05: Validation Error on invalid Gender")
    public void testCreatePatientInvalidGender() {
        Patient p = new Patient();
        p.setFullName("Lê Văn D");
        p.setPhone("0988123456");
        p.setGender("Unknown");

        assertThrows(PatientValidationException.class, () -> {
            patientService.createPatient(p);
        });
    }

    @Test
    @DisplayName("TC_PAT_06: Search patients by keyword")
    public void testSearchPatients() {
        Patient p = new Patient(1, "Hoàng Văn Nam", LocalDate.of(1992, 5, 14), "Nam", "0988111222", "001092001122", "Hà Nội");
        when(patientDAO.search("0988", 0, 10)).thenReturn(Collections.singletonList(p));
        List<Patient> results = patientService.searchPatients("0988", 1, 10);
        assertEquals(1, results.size());
        assertEquals("Hoàng Văn Nam", results.get(0).getFullName());
    }

    @Test
    @DisplayName("TC_PAT_07: Validation Error when Patient age is under 12 months")
    public void testCreatePatientDobUnderOneYearFails() {
        Patient p = new Patient();
        p.setFullName("Bé Sơ Sinh");
        p.setPhone("0988123456");
        p.setGender("Nam");
        // Born 3 months ago (< 12 months)
        p.setDob(LocalDate.now().minusMonths(3));

        PatientValidationException ex = assertThrows(PatientValidationException.class, () -> {
            patientService.createPatient(p);
        });
        assertTrue(ex.getMessage().contains("12 tháng tuổi"));
    }
}
