package com.dcms.controller;

import com.dcms.dao.DentistDAO;
import com.dcms.dao.DentalServiceDAO;
import com.dcms.dao.PatientDAO;
import com.dcms.model.DentalService;
import com.dcms.model.Dentist;
import com.dcms.model.Patient;
import com.dcms.model.TreatmentPlan;
import com.dcms.model.User;
import com.dcms.service.TreatmentPlanService;

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
import java.util.List;

/**
 * Controller handling Treatment Plans, Procedure Mapping & Cost Estimation (UC19, UC20, UC21, UC23).
 */
@WebServlet(name = "TreatmentPlanServlet", urlPatterns = {
        "/treatment/plans",
        "/treatment/plans/detail",
        "/treatment/plans/create",
        "/treatment/plans/item/add",
        "/treatment/plans/item/delete",
        "/treatment/plans/estimate/discount",
        "/treatment/plans/submit",
        "/treatment/plans/print-estimate"
})
public class TreatmentPlanServlet extends HttpServlet {

    private final TreatmentPlanService planService;
    private final PatientDAO patientDAO;
    private final DentistDAO dentistDAO;
    private final DentalServiceDAO serviceDAO;

    public TreatmentPlanServlet() {
        this.planService = new TreatmentPlanService();
        this.patientDAO = new PatientDAO();
        this.dentistDAO = new DentistDAO();
        this.serviceDAO = new DentalServiceDAO();
    }

    public TreatmentPlanServlet(TreatmentPlanService planService, PatientDAO patientDAO,
                                DentistDAO dentistDAO, DentalServiceDAO serviceDAO) {
        this.planService = planService;
        this.patientDAO = patientDAO;
        this.dentistDAO = dentistDAO;
        this.serviceDAO = serviceDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/treatment/plans/create" -> showCreateForm(request, response);
            case "/treatment/plans/detail" -> showPlanDetail(request, response);
            case "/treatment/plans/print-estimate" -> showPrintEstimate(request, response);
            default -> showPlanList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        switch (path) {
            case "/treatment/plans/create" -> handleCreatePlan(request, response);
            case "/treatment/plans/item/add" -> handleAddItem(request, response);
            case "/treatment/plans/item/delete" -> handleDeleteItem(request, response);
            case "/treatment/plans/estimate/discount" -> handleUpdateDiscount(request, response);
            case "/treatment/plans/submit" -> handleSubmitPlan(request, response);
            default -> response.sendRedirect(request.getContextPath() + "/treatment/plans");
        }
    }

    private void showPlanList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String patientIdParam = request.getParameter("patientId");
        List<TreatmentPlan> plans;

        if (patientIdParam != null && !patientIdParam.trim().isEmpty()) {
            try {
                int patientId = Integer.parseInt(patientIdParam.trim());
                plans = planService.getPlansByPatient(patientId);
                request.setAttribute("selectedPatientId", patientId);
            } catch (NumberFormatException e) {
                plans = planService.getAllPlans();
            }
        } else {
            plans = planService.getAllPlans();
        }

        List<Patient> patients = patientDAO.findAll();
        request.setAttribute("plans", plans);
        request.setAttribute("patients", patients);
        request.getRequestDispatcher("/WEB-INF/views/treatment/plan-list.jsp").forward(request, response);
    }

    private void showPlanDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/treatment/plans");
            return;
        }

        try {
            int planId = Integer.parseInt(idParam.trim());
            TreatmentPlan plan = planService.getPlanDetails(planId);
            if (plan == null) {
                response.sendRedirect(request.getContextPath() + "/treatment/plans?error=" +
                        URLEncoder.encode("Không tìm thấy kế hoạch điều trị #" + planId, StandardCharsets.UTF_8));
                return;
            }

            Patient patient = patientDAO.findById(plan.getPatientId());
            List<DentalService> activeServices = serviceDAO.findAll(true);
            request.setAttribute("plan", plan);
            request.setAttribute("patient", patient);
            request.setAttribute("activeServices", activeServices);
            request.getRequestDispatcher("/WEB-INF/views/treatment/plan-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/treatment/plans");
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String patientIdParam = request.getParameter("patientId");
        int preSelectedPatientId = 0;
        if (patientIdParam != null && !patientIdParam.trim().isEmpty()) {
            try {
                preSelectedPatientId = Integer.parseInt(patientIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        List<Patient> patients = patientDAO.findAll();
        List<Dentist> dentists = dentistDAO.findAll();

        request.setAttribute("patients", patients);
        request.setAttribute("dentists", dentists);
        request.setAttribute("preSelectedPatientId", preSelectedPatientId);
        request.setAttribute("currentUser", currentUser);
        request.getRequestDispatcher("/WEB-INF/views/treatment/plan-form.jsp").forward(request, response);
    }

    private void showPrintEstimate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/treatment/plans");
            return;
        }

        try {
            int planId = Integer.parseInt(idParam.trim());
            TreatmentPlan plan = planService.getPlanDetails(planId);
            if (plan == null) {
                response.sendRedirect(request.getContextPath() + "/treatment/plans");
                return;
            }

            request.setAttribute("plan", plan);
            request.getRequestDispatcher("/WEB-INF/views/treatment/estimate-print.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/treatment/plans");
        }
    }

    private void handleCreatePlan(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int patientId = Integer.parseInt(request.getParameter("patientId"));
            int dentistId = Integer.parseInt(request.getParameter("dentistId"));
            String title = request.getParameter("title");
            String diagnosis = request.getParameter("diagnosis");
            String notes = request.getParameter("notes");

            TreatmentPlan created = planService.createTreatmentPlan(patientId, dentistId, title, diagnosis, notes);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + created.getPlanId() + "&msg=created");
        } catch (Exception ex) {
            String error = URLEncoder.encode("Lỗi tạo kế hoạch: " + ex.getMessage(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/create?error=" + error);
        }
    }

    private void handleAddItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int planId = 0;
        try {
            planId = Integer.parseInt(request.getParameter("planId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));

            String toothParam = request.getParameter("toothNumber");
            Integer toothNumber = null;
            if (toothParam != null && !toothParam.trim().isEmpty()) {
                toothNumber = Integer.parseInt(toothParam.trim());
            }

            String surface = request.getParameter("surface");
            int quantity = 1;
            String quantityParam = request.getParameter("quantity");
            if (quantityParam != null && !quantityParam.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityParam.trim());
            }

            BigDecimal unitPrice = null;
            String priceParam = request.getParameter("unitPrice");
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                unitPrice = new BigDecimal(priceParam.trim());
            }

            int priorityOrder = 1;
            String priorityParam = request.getParameter("priorityOrder");
            if (priorityParam != null && !priorityParam.trim().isEmpty()) {
                priorityOrder = Integer.parseInt(priorityParam.trim());
            }

            String notes = request.getParameter("itemNotes");

            planService.addPlanItem(planId, serviceId, toothNumber, surface, quantity, unitPrice, priorityOrder, notes);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&msg=item_added");
        } catch (Exception ex) {
            String error = URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&error=" + error);
        }
    }

    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int planId = 0;
        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            planId = Integer.parseInt(request.getParameter("planId"));

            planService.removePlanItem(itemId, planId);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&msg=item_deleted");
        } catch (Exception ex) {
            String error = URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&error=" + error);
        }
    }

    private void handleUpdateDiscount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int planId = 0;
        try {
            planId = Integer.parseInt(request.getParameter("planId"));
            String discountStr = request.getParameter("totalDiscount");
            BigDecimal discount = BigDecimal.ZERO;
            if (discountStr != null && !discountStr.trim().isEmpty()) {
                discount = new BigDecimal(discountStr.trim());
            }

            planService.updateEstimateDiscount(planId, discount);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&msg=discount_updated");
        } catch (Exception ex) {
            String error = URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&error=" + error);
        }
    }

    private void handleSubmitPlan(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int planId = 0;
        try {
            planId = Integer.parseInt(request.getParameter("planId"));
            planService.submitPlanForReview(planId);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&msg=submitted");
        } catch (Exception ex) {
            String error = URLEncoder.encode(ex.getMessage(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/treatment/plans/detail?id=" + planId + "&error=" + error);
        }
    }
}
