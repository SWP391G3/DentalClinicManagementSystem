<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="checkin" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiếp Đón & Check-in Bệnh Nhân — Dr.Smile DCMS Dental Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.0">
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
                <span>Tiếp Đón & Check-in</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>Trung Tâm Tiếp Đón & Check-in</h1>
                    <p>Ngày làm việc: <strong>${todayDate}</strong> &bull; Biến Lịch hẹn thành Lượt khám thực tế (Visit) tại ghế</p>
                </div>
                <div style="display:flex; gap:10px;">
                    <a href="${pageContext.request.contextPath}/reception/appointments" class="btn btn-secondary">
                        Danh Sách Lịch Hẹn
                    </a>
                    <a href="${pageContext.request.contextPath}/reception/walkin" class="btn btn-primary">
                        + Tiếp Nhận Khách Vãng Lai
                    </a>
                </div>
            </div>

            <!-- Toast / Success Messages -->
            <c:if test="${param.success eq 'checkedin'}">
                <div class="alert-banner alert-banner-success">
                    <span class="alert-banner-icon">✓</span>
                    <div>
                        <strong>Check-in thành công:</strong> Bệnh nhân đã được tiếp nhận và đưa vào hàng đợi chờ khám (Lượt khám <strong>#${param.visitId}</strong>).
                    </div>
                </div>
            </c:if>
            <c:if test="${param.success eq 'walkin'}">
                <div class="alert-banner alert-banner-success">
                    <span class="alert-banner-icon">✓</span>
                    <div>
                        <strong>Tiếp nhận vãng lai thành công:</strong> Đã tạo lượt khám mới không cần lịch hẹn trước (Lượt khám <strong>#${param.visitId}</strong>).
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert-banner" style="background:#fef2f2;color:#b91c1c;border-color:#fecaca;">
                    <span class="alert-banner-icon">!</span>
                    <div><strong>Không thể check-in:</strong> ${param.error}</div>
                </div>
            </c:if>

            <!-- KPI Summary Cards: Real-Time Patient Flow -->
            <div class="kpi-grid">
                <div class="kpi-card" style="cursor: pointer;" onclick="filterVisitTable('Waiting')">
                    <div class="kpi-icon-box kpi-icon-amber">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${waitingCount != null ? waitingCount : (empty waitingQueue ? 0 : waitingQueue.size())}</h3>
                        <span>1. Chờ vào ghế khám</span>
                    </div>
                </div>

                <div class="kpi-card" style="cursor: pointer;" onclick="filterVisitTable('InProgress')">
                    <div class="kpi-icon-box kpi-icon-blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 18v3M20 18v3M4 11h16M6 11V6a3 3 0 0 1 6 0v5M18 11V8a2 2 0 0 0-2-2"/></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${inProgressCount != null ? inProgressCount : 0}</h3>
                        <span>2. Đang khám tại ghế</span>
                    </div>
                </div>

                <div class="kpi-card" style="cursor: pointer;" onclick="filterVisitTable('Completed')">
                    <div class="kpi-icon-box kpi-icon-green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${completedCount != null ? completedCount : 0}</h3>
                        <span>3. Đã khám xong (Chờ viện phí)</span>
                    </div>
                </div>

                <c:set var="pendingApptCount" value="0" />
                <c:forEach var="a" items="${todayAppointments}">
                    <c:if test="${a.status ne 'Arrived' && a.status ne 'Completed' && a.status ne 'Cancelled'}">
                        <c:set var="pendingApptCount" value="${pendingApptCount + 1}" />
                    </c:if>
                </c:forEach>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-purple">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${pendingApptCount}</h3>
                        <span>Lịch hẹn chờ check-in hôm nay</span>
                    </div>
                </div>
            </div>

            <!-- SECTION 1: TODAY'S ENTIRE ENCOUNTER LIFECYCLE (LIVE PATIENT FLOW) -->
            <div class="card">
                <div class="card-header" style="flex-wrap: wrap; gap: 12px;">
                    <div>
                        <div class="card-title">
                            <span>Luồng Bệnh Nhân Tiếp Đón Trong Ngày (Live Patient Flow)</span>
                        </div>
                        <p style="margin: 4px 0 0 0; font-size: 12.5px; color: var(--text-muted);">
                            Theo dõi tức thì 3 trạng thái: <strong>Chờ khám</strong> &rarr; <strong>Đang tại ghế</strong> &rarr; <strong>Đã hoàn thành</strong>
                        </p>
                    </div>

                    <!-- Flow Filter Buttons -->
                    <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                        <button type="button" class="btn btn-sm btn-outline active-filter-btn" id="btnFilterAll" onclick="filterVisitTable('ALL')">
                            Tất Cả (${empty allTodayVisits ? 0 : allTodayVisits.size()})
                        </button>
                        <button type="button" class="btn btn-sm btn-outline" id="btnFilterWaiting" onclick="filterVisitTable('Waiting')">
                            Chờ Vào Ghế (${waitingCount != null ? waitingCount : 0})
                        </button>
                        <button type="button" class="btn btn-sm btn-outline" id="btnFilterInProgress" onclick="filterVisitTable('InProgress')">
                            Đang Tại Ghế (${inProgressCount != null ? inProgressCount : 0})
                        </button>
                        <button type="button" class="btn btn-sm btn-outline" id="btnFilterCompleted" onclick="filterVisitTable('Completed')">
                            Đã Khám Xong (${completedCount != null ? completedCount : 0})
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table-custom" id="tablePatientFlow" data-datatable="true" data-page-size="10">
                        <thead>
                            <tr>
                                <th style="width: 60px;">STT</th>
                                <th>Thời Điểm Đến</th>
                                <th>Bệnh Nhân</th>
                                <th>Số Điện Thoại</th>
                                <th>Bác Sĩ Điều Trị</th>
                                <th>Vị Trí Ghế / Phòng</th>
                                <th>Cảnh Báo Y Tế & Dị Ứng</th>
                                <th>Trạng Thái Tiến Trình</th>
                                <th style="text-align: center;">Hồ Sơ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty allTodayVisits}">
                                    <tr>
                                        <td colspan="9">
                                            <div class="empty-state">
                                                <h4>Chưa có lượt tiếp đón nào trong ngày hôm nay</h4>
                                                <p>Khi bệnh nhân đến check-in hoặc tiếp nhận vãng lai, toàn bộ luồng khám sẽ hiển thị tại đây.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="v" items="${allTodayVisits}" varStatus="status">
                                        <tr class="flow-row" data-status="${v.status}">
                                            <td>
                                                <div class="queue-order-badge ${v.visitType eq 'Emergency' ? 'priority' : ''}" style="width:34px; height:34px; font-size:13px;">
                                                    #${status.index + 1}
                                                </div>
                                            </td>
                                            <td>
                                                <strong style="color:var(--primary); font-family:monospace; font-size:13.5px;">
                                                    ${v.checkInTime.toLocalTime().toString().substring(0, 5)}
                                                </strong>
                                            </td>
                                            <td>
                                                <div class="patient-cell">
                                                    <div class="patient-avatar-sm">
                                                        ${v.patientName.substring(0, 1).toUpperCase()}
                                                    </div>
                                                    <div>
                                                        <strong>${v.patientName}</strong>
                                                        <div style="font-size: 11.5px; color: var(--text-muted);">
                                                            Mã lượt khám: #${v.visitId} &bull; 
                                                            <c:choose>
                                                                <c:when test="${v.visitType eq 'Scheduled'}"><span style="color:#0284c7; font-weight:600;">Có hẹn</span></c:when>
                                                                <c:when test="${v.visitType eq 'Emergency'}"><span style="color:#dc2626; font-weight:700;">Cấp cứu</span></c:when>
                                                                <c:otherwise><span style="color:#64748b;">Vãng lai</span></c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <code style="background:#f1f5f9; padding:3px 6px; border-radius:4px; font-weight:600;">
                                                    ${v.patientPhone}
                                                </code>
                                            </td>
                                            <td>
                                                <span style="font-weight: 600; color: var(--text-primary);">
                                                    ${v.dentistName}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty v.operatory}">
                                                        <span style="font-weight:700; color:#0369a1; background:#e0f2fe; padding:3px 8px; border-radius:6px; font-size:12px;">
                                                            ${v.operatory}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:var(--text-muted); font-size:12px;">Chờ phân ghế</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${not empty v.medicalAlerts}">
                                                    <span class="alert-tag">Bệnh nền: ${v.medicalAlerts}</span>
                                                </c:if>
                                                <c:if test="${not empty v.allergies}">
                                                    <span class="alert-tag" style="background:#fef3c7; color:#b45309; border-color:#fde68a;">
                                                        Dị ứng: ${v.allergies}
                                                    </span>
                                                </c:if>
                                                <c:if test="${empty v.medicalAlerts && empty v.allergies}">
                                                    <span style="color: var(--text-muted); font-size: 12px;">Bình thường</span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${v.status eq 'Waiting'}">
                                                        <span class="badge-pill badge-Pending" style="font-weight:700;">
                                                            ● Chờ vào ghế
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${v.status eq 'InProgress'}">
                                                        <span class="badge-pill badge-Arrived" style="font-weight:700; background:#e0f2fe; color:#0284c7; border:1px solid #bae6fd;">
                                                            ● Đang khám tại ghế
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${v.status eq 'Completed'}">
                                                        <span class="badge-pill badge-Confirmed" style="font-weight:700;">
                                                            ✓ Đã khám xong
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-pill badge-Cancelled">${v.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${v.patientId}" target="_blank" class="btn btn-outline" style="padding: 4px 8px; font-size: 11.5px; white-space: nowrap;">
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

            <!-- SECTION 2: TODAY'S SCHEDULED APPOINTMENTS READY FOR CHECK-IN -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <span>Lịch Hẹn Trong Ngày Đang Chờ Bệnh Nhân Đến Quầy</span>
                    </div>
                    <span style="font-size: 12.5px; color: var(--text-muted);">
                        Bấm <strong>Tiếp Đón / Check-in</strong> ngay khi bệnh nhân có mặt tại phòng khám
                    </span>
                </div>

                <div class="table-responsive">
                    <table class="table-custom" data-datatable="true" data-page-size="10">
                        <thead>
                            <tr>
                                <th>Khung Giờ</th>
                                <th>Bệnh Nhân</th>
                                <th>Số Điện Thoại</th>
                                <th>Bác Sĩ Phụ Trách</th>
                                <th>Lý Do Khám</th>
                                <th>Trạng Thái Lịch</th>
                                <th style="text-align: right;" data-no-sort="true">Thao Tác Tiếp Đón</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty todayAppointments}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <h4>Không có lịch hẹn nào trong ngày hôm nay</h4>
                                                <p>Các lịch hẹn đã đặt cho ngày ${todayDate} sẽ được hiển thị ở bảng này.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="a" items="${todayAppointments}">
                                        <tr>
                                            <td>
                                                <strong style="color: var(--primary); font-family: monospace; font-size: 13.5px;">
                                                    ${a.startTime} - ${a.endTime}
                                                </strong>
                                            </td>
                                            <td>
                                                <div class="patient-cell">
                                                    <div class="patient-avatar-sm">
                                                        ${a.patientName.substring(0, 1).toUpperCase()}
                                                    </div>
                                                    <div>
                                                        <strong>${a.patientName}</strong>
                                                        <div style="font-size: 11.5px; color: var(--text-muted);">
                                                            Mã BN: #${a.patientId}
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <code style="background:#f1f5f9; padding:3px 6px; border-radius:4px; font-weight:600;">
                                                    ${a.patientPhone}
                                                </code>
                                            </td>
                                            <td>
                                                <span style="font-weight: 600;">${a.dentistName}</span>
                                            </td>
                                            <td>
                                                <span style="color: var(--text-secondary);">
                                                    ${not empty a.reason ? a.reason : 'Khám tổng quát nha khoa'}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${a.status eq 'Arrived'}">
                                                        <span class="badge-pill badge-Arrived">Đã Check-in</span>
                                                    </c:when>
                                                    <c:when test="${a.status eq 'Confirmed'}">
                                                        <span class="badge-pill badge-Confirmed">Đã xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${a.status eq 'Completed'}">
                                                        <span class="badge-pill badge-Completed">Hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${a.status eq 'Cancelled'}">
                                                        <span class="badge-pill badge-Cancelled">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-pill badge-Pending">${a.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right;">
                                                <c:if test="${a.canBeCheckedIn()}">
                                                    <form action="${pageContext.request.contextPath}/reception/checkin" method="POST" style="display:inline-block; margin:0;">
                                                        <input type="hidden" name="appointmentId" value="${a.appointmentId}" />
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            Tiếp Đón / Check-in
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${a.status eq 'Arrived'}">
                                                    <span style="color: var(--success); font-size: 12.5px; font-weight: 600;">
                                                        Đang ở ghế khám
                                                    </span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- DCMS Universal Data Table Standard Engine -->
<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=2.1" charset="UTF-8"></script>
<script>
function filterVisitTable(status) {
    const buttons = ['btnFilterAll', 'btnFilterWaiting', 'btnFilterInProgress', 'btnFilterCompleted'];
    buttons.forEach(id => {
        const b = document.getElementById(id);
        if (b) {
            b.classList.remove('btn-primary');
            b.classList.add('btn-outline');
        }
    });

    const activeId = 'btnFilter' + status;
    const activeBtn = document.getElementById(activeId);
    if (activeBtn) {
        activeBtn.classList.remove('btn-outline');
        activeBtn.classList.add('btn-primary');
    }

    const tableEl = document.getElementById('tablePatientFlow');
    if (tableEl && tableEl._dcmsDataTable) {
        tableEl._dcmsDataTable.setCustomFilter(row => {
            if (status === 'ALL') return true;
            return row.getAttribute('data-status') === status;
        });
    } else {
        const rows = document.querySelectorAll('#tablePatientFlow tbody tr.flow-row');
        rows.forEach(r => {
            const rowStatus = r.getAttribute('data-status');
            r.style.display = (status === 'ALL' || rowStatus === status) ? '' : 'none';
        });
    }
}
</script>
</body>
</html>
