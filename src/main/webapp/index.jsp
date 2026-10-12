<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.dcms.dao.DentistDAO" %>
<%@ page import="com.dcms.model.Dentist" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%
    // Safe initialization for direct welcome-file access
    if (request.getAttribute("dentistList") == null) {
        List<Dentist> dentistList = null;
        try {
            dentistList = new DentistDAO().listAllDentists();
        } catch (Exception ignored) {}
        request.setAttribute("dentistList", dentistList);
    }
    if (request.getAttribute("todayStr") == null) {
        request.setAttribute("todayStr", LocalDate.now().toString());
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DCMS Dental Care — Dr.Smile Inspired | Nơi khởi nguồn cho nụ cười rạng rỡ</title>
    <meta name="description" content="DCMS Dental Care — Dr.Smile Inspired, chuyên gia răng sứ thẩm mỹ, niềng răng, implant và điều trị nha khoa kỹ thuật cao tại Hà Nội.">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/images/dcms-dental-mark.svg">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=4.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/public-portal.css?v=4.0">
</head>
<body>

    <!-- 1. Topbar liên hệ -->
    <jsp:include page="/WEB-INF/views/public/components/topbar.jsp" />

    <!-- 2. Header & Quick Actions -->
    <jsp:include page="/WEB-INF/views/public/components/header.jsp" />

    <!-- 3. Mega Tab Navigation -->
    <jsp:include page="/WEB-INF/views/public/components/navbar.jsp" />

    <!-- 4. Main Tab Panes Content -->
    <main class="dr-main-content">
        <jsp:include page="/WEB-INF/views/public/components/pane-home.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-services.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-about.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-doctors.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-pricing.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-news.jsp" />
        <jsp:include page="/WEB-INF/views/public/components/pane-booking.jsp" />
    </main>

    <!-- 5. Footer -->
    <jsp:include page="/WEB-INF/views/public/components/footer.jsp" />

    <!-- 6. Confirmation Modal -->
    <jsp:include page="/WEB-INF/views/public/components/booking-modal.jsp" />

    <!-- 7. Client-side Controller Script -->
    <script>window.DCMS_CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
    <script src="${pageContext.request.contextPath}/assets/js/public-portal.js" charset="UTF-8"></script>
</body>
</html>
