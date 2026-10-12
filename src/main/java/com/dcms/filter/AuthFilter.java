package com.dcms.filter;

import com.dcms.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthFilter controls access to protected functional modules based on Role (RBAC).
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/admin/*",
        "/reception/*",
        "/dentist/*",
        "/patient/*",
        "/clinical/*",
        "/prescription/*",
        "/cashier/*"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.substring(contextPath.length());

        // 1. Not logged in -> Redirect to login page
        if (currentUser == null) {
            httpResponse.sendRedirect(contextPath + "/login?redirect=" + path);
            return;
        }

        // 2. Role-based authorization check
        String role = currentUser.getRoleName() != null ? currentUser.getRoleName().trim() : "";
        boolean isAuthorized = false;

        if (role.equalsIgnoreCase("Admin")) {
            // Admin has superuser privileges
            isAuthorized = true;
        } else if (path.startsWith("/reception/")) {
            isAuthorized = role.equalsIgnoreCase("Receptionist")
                    || (path.startsWith("/reception/calendar") && role.equalsIgnoreCase("Dentist"))
                    || (path.startsWith("/reception/schedules") && role.equalsIgnoreCase("Dentist"))
                    || (path.startsWith("/reception/patients") && (role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("DentalAssistant") || role.equalsIgnoreCase("Cashier")))
                    // Dental assistants can receive a patient at the chair,
                    // but still cannot create, cancel or manage appointments.
                    || (path.startsWith("/reception/checkin") && role.equalsIgnoreCase("DentalAssistant"));
        } else if (path.startsWith("/assistant/")) {
            isAuthorized = role.equalsIgnoreCase("DentalAssistant") || role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("Admin");
        } else if (path.startsWith("/dentist/")) {
            isAuthorized = role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("DentalAssistant");
        } else if (path.startsWith("/patient/")) {
            // Patients can only access their own self-service portal (Admin can inspect).
            isAuthorized = role.equalsIgnoreCase("Patient") || role.equalsIgnoreCase("Admin");
        } else if (path.startsWith("/clinical/")) {
            isAuthorized = role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("DentalAssistant");
        } else if (path.startsWith("/cashier/")) {
            isAuthorized = role.equalsIgnoreCase("Cashier") || role.equalsIgnoreCase("Admin");
        } else if (path.startsWith("/treatment/")) {
            isAuthorized = role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("Receptionist")
                    || role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("DentalAssistant");
        } else if (path.startsWith("/prescription/")) {
            isAuthorized = role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("DentalAssistant")
                    || role.equalsIgnoreCase("Receptionist") || role.equalsIgnoreCase("Admin");
        } else if (path.startsWith("/admin/")) {
            isAuthorized = role.equalsIgnoreCase("Admin")
                    || (path.startsWith("/admin/services") && (role.equalsIgnoreCase("Dentist") || role.equalsIgnoreCase("Receptionist") || role.equalsIgnoreCase("DentalAssistant") || role.equalsIgnoreCase("Cashier") || role.equalsIgnoreCase("Patient")));
        }

        if (!isAuthorized) {
            httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
            httpRequest.setAttribute("requiredPath", path);
            httpRequest.setAttribute("userRole", role);
            httpRequest.getRequestDispatcher("/WEB-INF/views/common/access-denied.jsp").forward(request, response);
            return;
        }

        // Authorized -> Continue chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
