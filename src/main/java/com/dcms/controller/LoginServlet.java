package com.dcms.controller;

import com.dcms.model.User;
import com.dcms.service.AuthService;
import com.dcms.service.exception.AuthenticationException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * LoginServlet handles user authentication and role-based redirect.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            redirectToDashboard(request, response, currentUser);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            User user = authService.authenticate(username, password);
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);

            redirectToDashboard(request, response, user);
        } catch (AuthenticationException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("enteredUsername", username);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String ctx = request.getContextPath();
        String role = user.getRoleName() != null ? user.getRoleName().trim() : "";

        switch (role) {
            case "Admin":
                response.sendRedirect(ctx + "/admin/dashboard");
                break;
            case "Receptionist":
                response.sendRedirect(ctx + "/reception/appointments");
                break;
            case "Dentist":
                response.sendRedirect(ctx + "/dentist/queue");
                break;
            case "DentalAssistant":
                response.sendRedirect(ctx + "/assistant/dashboard");
                break;
            case "Patient":
                response.sendRedirect(ctx + "/patient/appointments");
                break;
            case "Cashier":
                response.sendRedirect(ctx + "/cashier/billing");
                break;
            default:
                response.sendRedirect(ctx + "/index.jsp");
                break;
        }
    }
}
