package com.dcms.controller;

import com.dcms.model.PreTreatmentAssessment;
import com.dcms.model.User;
import com.dcms.model.Visit;
import com.dcms.service.ClinicalService;
import com.dcms.service.VisitService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Dental Assistant (Y tá nha khoa) workbench and pre-treatment vitals intake.
 */
@WebServlet(name = "AssistantDashboardServlet", urlPatterns = {"/assistant/dashboard", "/assistant/vitals/save"})
public class AssistantDashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AssistantDashboardServlet.class.getName());

    private final VisitService visitService;
    private final ClinicalService clinicalService;

    public AssistantDashboardServlet() {
        this.visitService = new VisitService();
        this.clinicalService = new ClinicalService();
    }

    public AssistantDashboardServlet(VisitService visitService, ClinicalService clinicalService) {
        this.visitService = visitService;
        this.clinicalService = clinicalService;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        List<Visit> todayVisits = visitService.getTodayVisits();
        List<Integer> visitIds = new ArrayList<>();
        int waitingCount = 0;
        int inProgressCount = 0;

        for (Visit v : todayVisits) {
            visitIds.add(v.getVisitId());
            if (Visit.STATUS_WAITING.equalsIgnoreCase(v.getStatus())) {
                waitingCount++;
            } else if (Visit.STATUS_IN_PROGRESS.equalsIgnoreCase(v.getStatus())) {
                inProgressCount++;
            }
        }

        Map<Integer, PreTreatmentAssessment> assessmentMap = clinicalService.getAssessmentsForVisits(visitIds);
        int vitalsRecordedCount = assessmentMap.size();

        request.setAttribute("todayVisits", todayVisits);
        request.setAttribute("assessmentMap", assessmentMap);
        request.setAttribute("totalVisits", todayVisits.size());
        request.setAttribute("waitingCount", waitingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("vitalsRecordedCount", vitalsRecordedCount);
        request.setAttribute("activeMenu", "assistant_dashboard");

        // Forward flash messages if present
        if (session != null && session.getAttribute("toastSuccess") != null) {
            request.setAttribute("toastSuccess", session.getAttribute("toastSuccess"));
            session.removeAttribute("toastSuccess");
        }
        if (session != null && session.getAttribute("toastError") != null) {
            request.setAttribute("toastError", session.getAttribute("toastError"));
            session.removeAttribute("toastError");
        }

        request.getRequestDispatcher("/WEB-INF/views/assistant/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String visitIdStr = request.getParameter("visitId");
        String patientIdStr = request.getParameter("patientId");
        String bloodPressure = request.getParameter("bloodPressure");
        String pulseStr = request.getParameter("pulseRate");
        String bloodSugarStr = request.getParameter("bloodSugar");
        String bleedingRisk = request.getParameter("bleedingRisk");
        String anxietyLevel = request.getParameter("anxietyLevel");
        boolean medicalClearance = "true".equalsIgnoreCase(request.getParameter("medicalClearance"));
        String notes = request.getParameter("notes");

        try {
            int visitId = Integer.parseInt(visitIdStr != null ? visitIdStr.trim() : "0");
            int patientId = Integer.parseInt(patientIdStr != null ? patientIdStr.trim() : "0");

            if (visitId <= 0 || patientId <= 0) {
                if (session != null) {
                    session.setAttribute("toastError", "Thông tin lượt khám hoặc bệnh nhân không hợp lệ.");
                }
                response.sendRedirect(request.getContextPath() + "/assistant/dashboard");
                return;
            }

            Integer pulse = null;
            if (pulseStr != null && !pulseStr.trim().isEmpty()) {
                try {
                    pulse = Integer.parseInt(pulseStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            BigDecimal bloodSugar = null;
            if (bloodSugarStr != null && !bloodSugarStr.trim().isEmpty()) {
                try {
                    bloodSugar = new BigDecimal(bloodSugarStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            PreTreatmentAssessment assessment = new PreTreatmentAssessment();
            assessment.setVisitId(visitId);
            assessment.setPatientId(patientId);
            assessment.setBloodPressure(bloodPressure != null ? bloodPressure.trim() : "");
            assessment.setPulseRate(pulse);
            assessment.setBloodSugar(bloodSugar);
            assessment.setBleedingRisk(bleedingRisk != null ? bleedingRisk.trim() : "Bình thường");
            assessment.setAnxietyLevel(anxietyLevel != null ? anxietyLevel.trim() : "Thấp");
            assessment.setMedicalClearance(medicalClearance);
            assessment.setNotes(notes != null ? notes.trim() : "");
            if (currentUser != null) {
                assessment.setAssessedBy(currentUser.getUserId());
            }

            clinicalService.recordPreTreatmentAssessment(assessment);

            if (session != null) {
                session.setAttribute("toastSuccess", "Đã lưu chỉ số sinh hiệu và đánh giá an toàn cho lượt khám #" + visitId + " thành công!");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lưu chỉ số sinh hiệu", ex);
            if (session != null) {
                session.setAttribute("toastError", "Lỗi xử lý dữ liệu: " + ex.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/assistant/dashboard");
    }
}
