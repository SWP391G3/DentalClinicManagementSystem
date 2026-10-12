package com.dcms.controller;

import com.dcms.dao.DentistDAO;
import com.dcms.model.Dentist;
import com.dcms.model.DentistSchedule;
import com.dcms.service.DentistScheduleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalTime;
import java.util.List;

/**
 * DentistScheduleServlet manages dentist working shifts and calendar schedules (UC37).
 */
@WebServlet(name = "DentistScheduleServlet", urlPatterns = {
        "/reception/schedules",
        "/reception/schedules/create",
        "/reception/schedules/delete",
        "/reception/schedules/toggle"
})
public class DentistScheduleServlet extends HttpServlet {

    private final DentistScheduleService scheduleService;
    private final DentistDAO dentistDAO;

    public DentistScheduleServlet() {
        this.scheduleService = new DentistScheduleService();
        this.dentistDAO = new DentistDAO();
    }

    public DentistScheduleServlet(DentistScheduleService scheduleService, DentistDAO dentistDAO) {
        this.scheduleService = scheduleService;
        this.dentistDAO = dentistDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dentistParam = request.getParameter("dentistId");
        Integer dentistId = null;
        if (dentistParam != null && !dentistParam.trim().isEmpty()) {
            try {
                dentistId = Integer.parseInt(dentistParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<DentistSchedule> list = scheduleService.listAllSchedules(dentistId);
        List<Dentist> dentists = dentistDAO.listAllDentists();

        long activeCount = list.stream().filter(DentistSchedule::isAvailable).count();

        request.setAttribute("scheduleList", list);
        request.setAttribute("dentists", dentists);
        request.setAttribute("selectedDentistId", dentistId);
        request.setAttribute("totalShifts", list.size());
        request.setAttribute("activeShifts", activeCount);
        request.setAttribute("inactiveShifts", list.size() - activeCount);

        request.getRequestDispatcher("/WEB-INF/views/receptionist/dentist-schedules.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();

        if ("/reception/schedules/delete".equals(servletPath)) {
            handleDelete(request, response);
            return;
        }

        if ("/reception/schedules/toggle".equals(servletPath)) {
            handleToggle(request, response);
            return;
        }

        handleCreate(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String dentistIdStr = request.getParameter("dentistId");
        String returnDentist = (dentistIdStr != null && !dentistIdStr.trim().isEmpty()) ? dentistIdStr.trim() : "";

        try {
            if (dentistIdStr == null || dentistIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn bác sĩ phụ trách ca trực");
            }
            String dayOfWeekStr = request.getParameter("dayOfWeek");
            if (dayOfWeekStr == null || dayOfWeekStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn thứ trong tuần");
            }

            int dentistId = Integer.parseInt(dentistIdStr.trim());
            int dayOfWeek = Integer.parseInt(dayOfWeekStr.trim());

            String startStr = request.getParameter("shiftStart");
            String endStr = request.getParameter("shiftEnd");

            if (startStr == null || startStr.trim().isEmpty() || endStr == null || endStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập đầy đủ giờ bắt đầu và giờ kết thúc ca trực");
            }

            LocalTime start = LocalTime.parse(startStr.trim());
            LocalTime end = LocalTime.parse(endStr.trim());

            boolean isAvailable = request.getParameter("isAvailable") != null;

            DentistSchedule schedule = new DentistSchedule();
            schedule.setDentistId(dentistId);
            schedule.setDayOfWeek(dayOfWeek);
            schedule.setShiftStart(start);
            schedule.setShiftEnd(end);
            schedule.setAvailable(isAvailable);

            scheduleService.addSchedule(schedule);

            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&success=created");
        } catch (Exception ex) {
            String errorMsg = URLEncoder.encode(
                    ex.getMessage() != null ? ex.getMessage() : "Lỗi khi thêm ca trực",
                    StandardCharsets.UTF_8
            );
            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&error=" + errorMsg);
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String returnDentist = request.getParameter("returnDentistId");
        if (returnDentist == null) returnDentist = "";

        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            scheduleService.deleteSchedule(scheduleId);
            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&success=deleted");
        } catch (Exception ex) {
            String errorMsg = URLEncoder.encode(
                    ex.getMessage() != null ? ex.getMessage() : "Không thể xóa ca trực",
                    StandardCharsets.UTF_8
            );
            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&error=" + errorMsg);
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String returnDentist = request.getParameter("returnDentistId");
        if (returnDentist == null) returnDentist = "";

        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            boolean available = Boolean.parseBoolean(request.getParameter("available"));
            scheduleService.toggleAvailability(scheduleId, available);
            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&success=toggled");
        } catch (Exception ex) {
            String errorMsg = URLEncoder.encode(
                    ex.getMessage() != null ? ex.getMessage() : "Không thể cập nhật trạng thái",
                    StandardCharsets.UTF_8
            );
            response.sendRedirect(request.getContextPath() + "/reception/schedules?dentistId="
                    + returnDentist + "&error=" + errorMsg);
        }
    }
}
