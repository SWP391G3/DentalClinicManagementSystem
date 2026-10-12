package com.dcms.controller;

import com.dcms.model.PreTreatmentAssessment;
import com.dcms.model.Visit;
import com.dcms.service.ClinicalService;
import com.dcms.service.VisitService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
public class AssistantDashboardServletTest {

    @Mock
    private VisitService visitService;

    @Mock
    private ClinicalService clinicalService;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private RequestDispatcher requestDispatcher;

    private AssistantDashboardServlet servlet;

    @BeforeEach
    public void setUp() {
        servlet = new AssistantDashboardServlet(visitService, clinicalService);
        when(request.getContextPath()).thenReturn("/dcms");
        when(request.getSession(false)).thenReturn(session);
        when(request.getRequestDispatcher(anyString())).thenReturn(requestDispatcher);
    }

    @Test
    @DisplayName("TC_ASSISTANT_01: doGet renders assistant dashboard with today visits and assessments")
    public void testDoGetRendersDashboard() throws Exception {
        Visit v = new Visit();
        v.setVisitId(10);
        v.setPatientId(5);
        v.setStatus(Visit.STATUS_WAITING);
        v.setCheckInTime(LocalDateTime.now());

        when(visitService.getTodayVisits()).thenReturn(Collections.singletonList(v));

        Map<Integer, PreTreatmentAssessment> map = new HashMap<>();
        PreTreatmentAssessment ass = new PreTreatmentAssessment();
        ass.setVisitId(10);
        ass.setPatientId(5);
        ass.setBloodPressure("120/80");
        map.put(10, ass);

        when(clinicalService.getAssessmentsForVisits(any())).thenReturn(map);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("todayVisits"), any());
        verify(request).setAttribute(eq("assessmentMap"), eq(map));
        verify(request).setAttribute(eq("totalVisits"), eq(1));
        verify(request).setAttribute(eq("waitingCount"), eq(1));
        verify(request).getRequestDispatcher("/WEB-INF/views/assistant/dashboard.jsp");
        verify(requestDispatcher).forward(request, response);
    }

    @Test
    @DisplayName("TC_ASSISTANT_02: doPost records vitals and redirects to dashboard")
    public void testDoPostSavesVitals() throws Exception {
        when(request.getParameter("visitId")).thenReturn("15");
        when(request.getParameter("patientId")).thenReturn("8");
        when(request.getParameter("bloodPressure")).thenReturn("125/82");
        when(request.getParameter("pulseRate")).thenReturn("76");
        when(request.getParameter("bloodSugar")).thenReturn("5.5");
        when(request.getParameter("bleedingRisk")).thenReturn("Bình thường");
        when(request.getParameter("medicalClearance")).thenReturn("true");
        when(request.getParameter("notes")).thenReturn("Sức khỏe tốt");

        servlet.doPost(request, response);

        verify(clinicalService).recordPreTreatmentAssessment(any(PreTreatmentAssessment.class));
        verify(session).setAttribute(eq("toastSuccess"), anyString());
        verify(response).sendRedirect("/dcms/assistant/dashboard");
    }

    @Test
    @DisplayName("TC_ASSISTANT_03: doPost invalid ids redirects with error toast")
    public void testDoPostInvalidIds() throws Exception {
        when(request.getParameter("visitId")).thenReturn("0");
        when(request.getParameter("patientId")).thenReturn("-1");

        servlet.doPost(request, response);

        verify(clinicalService, never()).recordPreTreatmentAssessment(any());
        verify(session).setAttribute(eq("toastError"), anyString());
        verify(response).sendRedirect("/dcms/assistant/dashboard");
    }
}
