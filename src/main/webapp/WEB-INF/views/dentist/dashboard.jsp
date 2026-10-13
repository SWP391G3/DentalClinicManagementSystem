<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="dentist_dashboard" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bàn Làm Việc Bác Sĩ Nha Khoa — Dr.Smile DCMS Dental Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=4.0">
</head>
<body>

<div class="app-shell">
    <!-- Reusable Sidebar -->
    <jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

    <div class="app-main">
        <!-- Reusable Header -->
        <jsp:include page="/WEB-INF/views/layout/header.jsp" />

        <main class="page-content">
            <!-- Breadcrumbs -->
            <div class="breadcrumb-trail">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span class="breadcrumb-separator">/</span>
                <span>Khu Khám Lâm Sàng</span>
                <span class="breadcrumb-separator">/</span>
                <span>Bàn Làm Việc Bác Sĩ (Dentist Workbench)</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>Bàn Làm Việc Bác Sĩ Nha Khoa</h1>
                    <p>Bác sĩ: <strong>${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : sessionScope.fullName}</strong> &bull; Quản lý ghế khám, hàng đợi bệnh nhân và bệnh án điều trị</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/dentist/queue" class="btn btn-secondary">
                        Xem Hàng Đợi Ghế Khám
                    </a>
                </div>
            </div>

            <!-- Toast / Success Messages -->
            <c:if test="${param.success eq 'visit_completed'}">
                <div class="alert-banner alert-banner-success">
                    <span class="alert-banner-icon" style="font-weight:700;">✓</span>
                    <div>
                        <strong>Hoàn tất ca khám:</strong> Đã lưu trữ thành công kết quả khám và đóng lượt khám của bệnh nhân.
                    </div>
                </div>
            </c:if>

            <!-- Dentist KPIs Grid -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${totalApptsCount}</h3>
                        <span>Lịch hẹn của tôi hôm nay</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-amber">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${waitingVisits != null ? waitingVisits.size() : 0}</h3>
                        <span>Bệnh nhân đang chờ</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-purple">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.8 2.3A.3.3 0 1 0 5 2H4a2 2 0 0 0-2 2v5a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6V4a2 2 0 0 0-2-2h-1a.2.2 0 1 0 .3.3"></path><path d="M8 15v1a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6v-4"></path><circle cx="20" cy="10" r="2"></circle></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${inProgressCount}</h3>
                        <span>Ca đang khám tại ghế</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${completedCount}</h3>
                        <span>Đã hoàn thành hôm nay</span>
                    </div>
                </div>
            </div>

            <!-- Active / In-Progress Visits Alert -->
            <c:forEach var="v" items="${doctorVisits}">
                <c:if test="${v.status eq 'InProgress'}">
                    <div style="background: linear-gradient(135deg, #f0f7fd 0%, #e0f2fe 100%); border: 2px solid var(--drsmile-navy); border-radius: 12px; padding: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; box-shadow: var(--shadow-md);">
                        <div style="display: flex; align-items: center; gap: 16px;">
                            <div style="width: 50px; height: 50px; border-radius: 50%; background: var(--drsmile-navy); color: white; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 800;">
                                LIVE
                            </div>
                            <div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <h3 style="margin: 0; font-size: 18px; color: #1e3a8a;">Ca khám đang mở tại ghế: <strong>${empty v.operatory ? 'Ghế khám chính' : v.operatory}</strong></h3>
                                    <span class="badge-pill badge-Arrived">● Đang khám</span>
                                </div>
                                <div style="color: #1e40af; font-size: 14px; margin-top: 4px;">
                                    Bệnh nhân: <strong>${v.patientName}</strong> &bull; SĐT: <code>${v.patientPhone}</code> &bull; Giờ tiếp đón: ${v.checkInTime.toLocalTime().toString().substring(0, 5)}
                                </div>
                            </div>
                        </div>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${v.patientId}" target="_blank" class="btn btn-outline" style="padding: 12px 18px; font-size: 14px; font-weight: 600;" title="Xem Bệnh Án Toàn Diện">
                                Bệnh Án 360°
                            </a>
                            <a href="${pageContext.request.contextPath}/clinical/examination?visitId=${v.visitId}" class="btn btn-primary" style="padding: 12px 24px; font-size: 14px; font-weight: 600;">
                                Mở Hồ Sơ & Sơ Đồ Răng &rarr;
                            </a>
                        </div>
                    </div>
                </c:if>
            </c:forEach>

            <div style="display: grid; grid-template-columns: 1.2fr 1fr; gap: 24px;">
                <!-- Left: Waiting Patients Queue with Operatory Selection -->
                <div class="card">
                    <div class="card-header">
                        <div class="card-title">
                            <span>Bệnh Nhân Chờ Khám Tại Ghế</span>
                        </div>
                        <span class="badge-pill badge-Pending">
                            ${empty waitingVisits ? 0 : waitingVisits.size()} Bệnh nhân
                        </span>
                    </div>
                    <div class="card-body" style="padding: 20px;">
                        <c:choose>
                            <c:when test="${empty waitingVisits}">
                                <div class="empty-state" style="padding: 30px;">
                                    <h4>Không có bệnh nhân nào đang chờ</h4>
                                    <p>Khi quầy lễ tân check-in tiếp đón, bệnh nhân sẽ xuất hiện ngay tại đây.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="display: flex; flex-direction: column; gap: 16px;">
                                    <c:forEach var="v" items="${waitingVisits}" varStatus="loop">
                                        <form action="${pageContext.request.contextPath}/dentist/start-exam" method="POST" style="margin: 0;">
                                            <input type="hidden" name="visitId" value="${v.visitId}" />
                                            <div style="background: white; border: 1px solid var(--border); border-radius: 10px; padding: 16px; display: flex; justify-content: space-between; align-items: center; transition: all 0.2s ease;">
                                                <div>
                                                    <div style="display: flex; align-items: center; gap: 8px;">
                                                        <span style="font-weight: 700; color: var(--text-primary); font-size: 15px;">#${loop.index + 1} &bull; ${v.patientName}</span>
                                                        <span class="badge-pill ${v.visitType eq 'Emergency' ? 'badge-Cancelled' : (v.visitType eq 'Scheduled' ? 'badge-Confirmed' : 'badge-Pending')}">
                                                            ${v.visitType eq 'Emergency' ? 'Cấp cứu' : (v.visitType eq 'Scheduled' ? 'Có hẹn' : 'Vãng lai')}
                                                        </span>
                                                    </div>
                                                    <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">
                                                        ${v.patientPhone} &bull; Check-in: <strong>${v.checkInTime.toLocalTime().toString().substring(0, 5)}</strong>
                                                    </div>
                                                    <c:if test="${not empty v.medicalAlerts || not empty v.allergies}">
                                                        <div style="margin-top: 6px; display: flex; gap: 6px; flex-wrap: wrap;">
                                                            <c:if test="${not empty v.medicalAlerts}">
                                                                <span class="alert-tag">Cảnh báo: ${v.medicalAlerts}</span>
                                                            </c:if>
                                                            <c:if test="${not empty v.allergies}">
                                                                <span class="alert-tag" style="background:#fef3c7; color:#b45309;">Dị ứng: ${v.allergies}</span>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </div>

                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${v.patientId}" target="_blank" class="btn btn-outline" style="padding: 7px 12px; font-size: 12px; white-space: nowrap;" title="Xem Bệnh Án 360°">
                                                        Bệnh Án
                                                    </a>
                                                    <select name="operatory" class="form-control" style="width: 140px; padding: 8px 10px; font-size: 13px;">
                                                        <option value="Ghế 1 - P.101">Ghế 1 - P.101</option>
                                                        <option value="Ghế 2 - P.102">Ghế 2 - P.102</option>
                                                        <option value="Ghế 3 - P.103">Ghế 3 - P.103</option>
                                                        <option value="Ghế VIP - P.201">Ghế VIP - P.201</option>
                                                    </select>
                                                    <button type="submit" class="btn btn-success" style="padding: 8px 16px; font-size: 13px; white-space: nowrap;">
                                                        Mời Khám
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Right: Doctor Today Worklist (Appointments & Completed Visits) -->
                <div class="card">
                    <div class="card-header" style="flex-wrap: wrap; gap: 8px;">
                        <div class="card-title">
                            <span>Danh Sách Ca Khám Phân Công Hôm Nay</span>
                        </div>
                        <span class="badge-pill badge-Confirmed">
                            ${empty todayAppointments ? 0 : todayAppointments.size()} Cuộc hẹn
                        </span>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <div class="table-responsive">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width: 130px;">Khung Giờ</th>
                                        <th>Bệnh Nhân</th>
                                        <th>Lý Do / Dịch Vụ</th>
                                        <th style="text-align: center; width: 110px;">Trạng Thái</th>
                                        <th style="text-align: center; width: 90px;">Hồ Sơ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty todayAppointments}">
                                            <tr>
                                                <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 36px;">
                                                    Không có lịch hẹn nào được phân công hôm nay.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="a" items="${todayAppointments}">
                                                <tr>
                                                    <td>
                                                        <div class="time-badge">
                                                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                <circle cx="12" cy="12" r="10"></circle>
                                                                <polyline points="12 6 12 12 16 14"></polyline>
                                                            </svg>
                                                            <span>${a.startTime.toString().substring(0, 5)} – ${a.endTime.toString().substring(0, 5)}</span>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="patient-cell">
                                                            <div class="patient-avatar-sm">
                                                                ${a.patientName.substring(0, 1).toUpperCase()}
                                                            </div>
                                                            <div>
                                                                <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 13.5px;">${a.patientName}</div>
                                                                <div style="margin-top: 2px;">
                                                                    <span class="badge-code" style="font-size: 11px;">${a.patientPhone}</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span style="font-weight: 500;">${empty a.reason ? 'Khám nha tổng quát' : a.reason}</span>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <span class="badge-pill badge-${a.status}">● ${a.status}</span>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${a.patientId}" target="_blank" class="btn btn-outline" style="padding: 4px 8px; font-size: 11px; white-space: nowrap;">
                                                            Bệnh Án
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

</body>
</html>
