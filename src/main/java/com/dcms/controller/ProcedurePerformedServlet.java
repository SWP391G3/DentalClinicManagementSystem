package com.dcms.controller;

import com.dcms.dao.DentalServiceDAO;
import com.dcms.dao.DentistDAO;
import com.dcms.dao.PatientDAO;
import com.dcms.dao.PreTreatmentAssessmentDAO;
import com.dcms.dao.TreatmentPlanDAO;
import com.dcms.dao.VisitDAO;
import com.dcms.model.DentalService;
import com.dcms.model.Dentist;
import com.dcms.model.Patient;
import com.dcms.model.PreTreatmentAssessment;
import com.dcms.model.ProcedurePerformed;
import com.dcms.model.TreatmentPlan;
import com.dcms.model.TreatmentPlanItem;
import com.dcms.model.User;
import com.dcms.model.Visit;
import com.dcms.service.ClinicalProcedureService;
import com.dcms.service.exception.BusinessRuleViolationException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller managing Chairside Procedures Performed & Material Tracking (UC24, UC25, UC26).
 * Managed by Wolf (Clinical Treatment & Chairside Procedures).
 */
@WebServlet(name = "ProcedurePerformedServlet", urlPatterns = {
        "/clinical/procedures",
        "/clinical/procedure/record",
        "/clinical/procedure/complete",
        "/clinical/material/add",
        "/clinical/material/delete"
})
public class ProcedurePerformedServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProcedurePerformedServlet.class.getName());

    private final ClinicalProcedureService clinicalProcedureService;
    private final VisitDAO visitDAO;
    private final PatientDAO patientDAO;
    private final DentistDAO dentistDAO;
    private final DentalServiceDAO serviceDAO;
    private final TreatmentPlanDAO planDAO;
    private final PreTreatmentAssessmentDAO assessmentDAO;

    public ProcedurePerformedServlet() {
        this.clinicalProcedureService = new ClinicalProcedureService();
        this.visitDAO = new VisitDAO();
        this.patientDAO = new PatientDAO();
        this.dentistDAO = new DentistDAO();
        this.serviceDAO = new DentalServiceDAO();
        this.planDAO = new TreatmentPlanDAO();
        this.assessmentDAO = new PreTreatmentAssessmentDAO();
    }

    public ProcedurePerformedServlet(ClinicalProcedureService clinicalProcedureService, VisitDAO visitDAO,
                                    PatientDAO patientDAO, DentistDAO dentistDAO,
                                    DentalServiceDAO serviceDAO, TreatmentPlanDAO planDAO,
                                    PreTreatmentAssessmentDAO assessmentDAO) {
        this.clinicalProcedureService = clinicalProcedureService;
        this.visitDAO = visitDAO;
        this.patientDAO = patientDAO;
        this.dentistDAO = dentistDAO;
        this.serviceDAO = serviceDAO;
        this.planDAO = planDAO;
        this.assessmentDAO = assessmentDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/clinical/procedures".equalsIgnoreCase(path)) {
            showProcedureDesk(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/dentist/queue");
    }

    private void showProcedureDesk(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String visitIdParam = request.getParameter("visitId");
        if (visitIdParam == null || visitIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue?error=" +
                    URLEncoder.encode("Thiếu mã lượt khám bệnh.", StandardCharsets.UTF_8));
            return;
        }

        try {
            int visitId = Integer.parseInt(visitIdParam.trim());
            Visit visit = visitDAO.getVisitById(visitId);
            if (visit == null) {
                response.sendRedirect(request.getContextPath() + "/dentist/queue?error=" +
                        URLEncoder.encode("Buổi khám #" + visitId + " không tồn tại.", StandardCharsets.UTF_8));
                return;
            }

            Patient patient = patientDAO.findById(visit.getPatientId());
            Dentist dentist = dentistDAO.findById(visit.getPrimaryDentistId());
            PreTreatmentAssessment assessment = assessmentDAO.findByVisitId(visitId);
            List<ProcedurePerformed> procedures = clinicalProcedureService.getProceduresByVisit(visitId);
            List<DentalService> activeServices = serviceDAO.findAllActive();

            // Find accepted treatment plans for this patient to import items
            List<TreatmentPlan> plans = planDAO.findByPatientId(visit.getPatientId());
            List<TreatmentPlanItem> pendingPlanItems = new ArrayList<>();
            for (TreatmentPlan p : plans) {
                if ("Accepted".equalsIgnoreCase(p.getStatus()) || "PartiallyAccepted".equalsIgnoreCase(p.getStatus()) || "InProgress".equalsIgnoreCase(p.getStatus())) {
                    List<TreatmentPlanItem> items = planDAO.findItemsByPlanId(p.getPlanId());
                    for (TreatmentPlanItem it : items) {
                        if (!"Completed".equalsIgnoreCase(it.getStatus()) && !"Cancelled".equalsIgnoreCase(it.getStatus())) {
                            pendingPlanItems.add(it);
                        }
                    }
                }
            }

            request.setAttribute("visit", visit);
            request.setAttribute("patient", patient);
            request.setAttribute("dentist", dentist);
            request.setAttribute("assessment", assessment);
            request.setAttribute("procedures", procedures);
            request.setAttribute("activeServices", activeServices);
            request.setAttribute("pendingPlanItems", pendingPlanItems);
            request.setAttribute("activeMenu", "dentist_queue");

            request.getRequestDispatcher("/WEB-INF/views/clinical/procedure-entry.jsp").forward(request, response);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue?error=" +
                    URLEncoder.encode("Mã lượt khám không hợp lệ.", StandardCharsets.UTF_8));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        switch (path) {
            case "/clinical/procedure/record" -> handleRecordProcedure(request, response);
            case "/clinical/procedure/complete" -> handleCompleteProcedure(request, response);
            case "/clinical/material/add" -> handleAddMaterial(request, response);
            case "/clinical/material/delete" -> handleDeleteMaterial(request, response);
            default -> response.sendRedirect(request.getContextPath() + "/dentist/queue");
        }
    }

    private void handleRecordProcedure(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String visitIdParam = request.getParameter("visitId");
        String serviceIdParam = request.getParameter("serviceId");
        String planItemIdParam = request.getParameter("planItemId");
        String toothNumberParam = request.getParameter("toothNumber");
        String surface = request.getParameter("surface");
        String quantityParam = request.getParameter("quantity");
        String actualPriceParam = request.getParameter("actualPrice");
        String clinicalNotes = request.getParameter("clinicalNotes");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int dentistId = (currentUser != null && currentUser.getUserId() > 0) ? currentUser.getUserId() : 3;

        if (visitIdParam == null || serviceIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue?error=ThieuThongTinThuThuat");
            return;
        }

        try {
            int visitId = Integer.parseInt(visitIdParam.trim());
            int serviceId = Integer.parseInt(serviceIdParam.trim());

            Integer planItemId = (planItemIdParam != null && !planItemIdParam.trim().isEmpty()) ?
                    Integer.parseInt(planItemIdParam.trim()) : null;

            Integer toothNumber = (toothNumberParam != null && !toothNumberParam.trim().isEmpty()) ?
                    Integer.parseInt(toothNumberParam.trim()) : null;

            int quantity = (quantityParam != null && !quantityParam.trim().isEmpty()) ?
                    Integer.parseInt(quantityParam.trim()) : 1;

            BigDecimal actualPrice = null;
            if (actualPriceParam != null && !actualPriceParam.trim().isEmpty()) {
                actualPrice = new BigDecimal(actualPriceParam.trim().replace(".", "").replace(",", ""));
            }

            clinicalProcedureService.recordProcedure(visitId, dentistId, null, planItemId, serviceId,
                    toothNumber, surface, quantity, actualPrice, clinicalNotes);

            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitId + "&msg=procedure_recorded");
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode("Dữ liệu nhập số không hợp lệ.", StandardCharsets.UTF_8));
        } catch (BusinessRuleViolationException | IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8));
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error recording procedure", ex);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode("Lỗi hệ thống khi ghi nhận thủ thuật.", StandardCharsets.UTF_8));
        }
    }

    private void handleCompleteProcedure(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String procIdParam = request.getParameter("procedureId");
        String visitIdParam = request.getParameter("visitId");
        String notes = request.getParameter("clinicalNotes");

        if (procIdParam == null || visitIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue");
            return;
        }

        try {
            int procId = Integer.parseInt(procIdParam.trim());
            clinicalProcedureService.completeProcedure(procId, notes);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam + "&msg=procedure_completed");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error completing procedure", ex);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void handleAddMaterial(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String procIdParam = request.getParameter("procedureId");
        String visitIdParam = request.getParameter("visitId");
        String materialName = request.getParameter("materialName");
        String quantityParam = request.getParameter("quantity");
        String unit = request.getParameter("unit");
        String notes = request.getParameter("notes");

        if (procIdParam == null || visitIdParam == null || materialName == null) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue");
            return;
        }

        try {
            int procId = Integer.parseInt(procIdParam.trim());
            int quantity = (quantityParam != null && !quantityParam.trim().isEmpty()) ?
                    Integer.parseInt(quantityParam.trim()) : 1;

            clinicalProcedureService.recordMaterialUsage(procId, materialName, quantity, unit, notes);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam + "&msg=material_added");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error adding material usage", ex);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void handleDeleteMaterial(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String usageIdParam = request.getParameter("usageId");
        String visitIdParam = request.getParameter("visitId");

        if (usageIdParam == null || visitIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/dentist/queue");
            return;
        }

        try {
            int usageId = Integer.parseInt(usageIdParam.trim());
            clinicalProcedureService.removeMaterialUsage(usageId);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam + "&msg=material_deleted");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error deleting material usage", ex);
            response.sendRedirect(request.getContextPath() + "/clinical/procedures?visitId=" + visitIdParam +
                    "&error=" + URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8));
        }
    }
}
