<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="queue" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hàng Đợi Khám Bệnh Nhân — Dr.Smile DCMS Dental Care</title>
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
                <span>Hàng Đợi Ghế Khám</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>Hàng Đợi Khám Bệnh Nhân Tại Ghế</h1>
                    <p>Bác sĩ phụ trách: <strong>${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : sessionScope.fullName}</strong> &bull; Danh sách bệnh nhân đã Check-in tại quầy tiếp đón</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/dentist/queue" class="btn btn-secondary">
                        Làm Mới Hàng Đợi
                    </a>
                </div>
            </div>

            <!-- Toast / Success Messages -->
            <c:if test="${param.success eq 'started'}">
                <div class="alert-banner alert-banner-success">
                    <span class="alert-banner-icon">✓</span>
                    <div>
                        <strong>Đã bắt đầu khám:</strong> Lượt khám đã được kích hoạt thành công, chuyển sang trạng thái <strong>InProgress</strong> để ghi chép chẩn đoán và chỉ định thủ thuật.
                    </div>
                </div>
            </c:if>

            <!-- KPI Summary Cards -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${empty waitingQueue ? 0 : waitingQueue.size()}</h3>
                        <span>Bệnh nhân chờ tại ghế</span>
                    </div>
                </div>

                <c:set var="alertCount" value="0" />
                <c:set var="emergencyCount" value="0" />
                <c:forEach var="v" items="${waitingQueue}">
                    <c:if test="${not empty v.medicalAlerts || not empty v.allergies}">
                        <c:set var="alertCount" value="${alertCount + 1}" />
                    </c:if>
                    <c:if test="${v.visitType eq 'Emergency'}">
                        <c:set var="emergencyCount" value="${emergencyCount + 1}" />
                    </c:if>
                </c:forEach>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-amber">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${alertCount}</h3>
                        <span>Ca có cảnh báo bệnh lý / dị ứng</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-red">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${emergencyCount}</h3>
                        <span>Ca cấp cứu ưu tiên</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3 style="font-size: 20px;">Sẵn Sàng</h3>
                        <span>Trạng thái ghế nha khoa</span>
                    </div>
                </div>
            </div>

            <!-- Queue Patient Cards -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <span>Danh Sách Chờ Khám Theo Thứ Tự Đến</span>
                    </div>
                    <span class="badge-pill badge-Arrived">
                        ● ${empty waitingQueue ? 0 : waitingQueue.size()} người trong hàng
                    </span>
                </div>

                <div class="card-body" style="padding: 24px;">
                    <c:choose>
                        <c:when test="${empty waitingQueue}">
                            <div class="empty-state">
                                <h4>Hiện tại không có bệnh nhân nào trong hàng đợi của bạn</h4>
                                <p>Khi quầy lễ tân Check-in bệnh nhân hoặc tiếp nhận vãng lai, bệnh nhân sẽ lập tức xuất hiện tại đây.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="queue-card-list">
                                <c:forEach var="v" items="${waitingQueue}" varStatus="loop">
                                    <div class="queue-card">
                                        <div class="queue-card-left">
                                            <div class="queue-order-badge ${v.visitType eq 'Emergency' ? 'priority' : ''}">
                                                #${loop.index + 1}
                                            </div>

                                            <div>
                                                <div class="queue-patient-title">
                                                    <h3>${v.patientName}</h3>
                                                    <c:choose>
                                                        <c:when test="${v.visitType eq 'Scheduled'}">
                                                            <span class="badge-pill badge-Confirmed">Có hẹn</span>
                                                        </c:when>
                                                        <c:when test="${v.visitType eq 'Emergency'}">
                                                            <span class="badge-pill badge-Cancelled">Cấp cứu ưu tiên</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-pill badge-Pending">Vãng lai</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <div class="queue-patient-meta">
                                                    <span class="queue-meta-item">
                                                        <span>SĐT:</span>
                                                        <code>${v.patientPhone}</code>
                                                    </span>
                                                    <span class="queue-meta-item">
                                                        <span>Check-in: <strong>${v.checkInTime.toLocalTime().toString().substring(0, 5)}</strong></span>
                                                    </span>
                                                    <span class="queue-meta-item">
                                                        <span style="color:var(--text-muted);">Mã lượt: #${v.visitId}</span>
                                                    </span>
                                                </div>

                                                <c:if test="${not empty v.notes}">
                                                    <div class="queue-patient-notes">
                                                        <strong>Lý do / Triệu chứng:</strong> ${v.notes}
                                                    </div>
                                                </c:if>

                                                <div class="queue-alert-container">
                                                    <c:if test="${not empty v.medicalAlerts}">
                                                        <span class="alert-tag">Bệnh nền: ${v.medicalAlerts}</span>
                                                    </c:if>
                                                    <c:if test="${not empty v.allergies}">
                                                        <span class="alert-tag" style="background:#fef3c7; color:#b45309; border-color:#fde68a;">
                                                            Dị ứng: ${v.allergies}
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>

                                        <div style="flex-shrink: 0; margin-left: 20px;">
                                            <form action="${pageContext.request.contextPath}/dentist/start-exam" method="POST" style="display: flex; flex-direction: column; gap: 8px; margin: 0;">
                                                <input type="hidden" name="visitId" value="${v.visitId}" />
                                                <select name="operatory" class="form-control" style="padding: 6px 10px; font-size: 12px;">
                                                    <option value="Ghế 1 - P.101">Ghế 1 - P.101</option>
                                                    <option value="Ghế 2 - P.102">Ghế 2 - P.102</option>
                                                    <option value="Ghế 3 - P.103">Ghế 3 - P.103</option>
                                                    <option value="Ghế VIP - P.201">Ghế VIP - P.201</option>
                                                </select>
                                                <button type="submit" class="btn btn-success" style="padding: 10px 18px; font-size: 13px; font-weight: 600;">
                                                    Mời Khám Ngay
                                                </button>
                                                <a href="${pageContext.request.contextPath}/clinical/procedures?visitId=${v.visitId}" class="btn btn-secondary" style="padding: 6px 12px; font-size: 12px; font-weight: 600; text-align: center; text-decoration: none;">
                                                    Thủ Thuật Tại Ghế
                                                </a>
                                                <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${v.patientId}" class="btn btn-secondary" style="padding: 6px 12px; font-size: 12px; font-weight: 600; text-align: center; text-decoration: none; color: var(--drsmile-navy); border-color: #cbd5e1;" target="_blank" title="Mở hồ sơ bệnh án 360° của bệnh nhân">
                                                    Xem Bệnh Án 360°
                                                </a>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</div>

</body>
</html>
