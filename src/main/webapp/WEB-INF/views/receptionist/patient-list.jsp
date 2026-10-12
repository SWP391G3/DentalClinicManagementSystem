<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="patients" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Bệnh Nhân — Dr.Smile DCMS Dental Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.0">
</head>
<body>

<div class="app-shell">
    <jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

    <div class="app-main">
        <jsp:include page="/WEB-INF/views/layout/header.jsp" />

        <main class="page-content">
            <c:set var="u" value="${sessionScope.currentUser}" />
            <c:set var="userRole" value="${not empty u.roleName ? u.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
            <c:set var="canCreatePatient" value="${userRole eq 'Admin' or userRole eq 'Receptionist'}" />

            <div class="page-header-row">
                <div class="page-title">
                    <h1>Hồ Sơ Bệnh Nhân</h1>
                    <p>Tra cứu tiền sử bệnh lý, dị ứng thuốc và quản lý thông tin liên hệ bệnh nhân</p>
                </div>
                <c:if test="${canCreatePatient}">
                    <div>
                        <a href="${pageContext.request.contextPath}/reception/patients/create" class="btn btn-primary">
                            + Đăng Ký Bệnh Nhân Mới
                        </a>
                    </div>
                </c:if>
            </div>

            <!-- Search Card -->
            <div class="card" style="margin-bottom: 20px;">
                <form action="${pageContext.request.contextPath}/reception/patients" method="GET" style="display:flex; gap:12px; padding:16px 20px;">
                    <input type="text" 
                           name="keyword" 
                           class="form-control" 
                           style="flex:1;" 
                           value="${keyword}" 
                           placeholder="Nhập số điện thoại, số CCCD hoặc họ tên bệnh nhân để tìm kiếm nhanh..." />
                    <button type="submit" class="btn btn-primary">
                        Tìm Kiếm
                    </button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/reception/patients" class="btn btn-secondary">
                            Xóa Tìm Kiếm
                        </a>
                    </c:if>
                </form>
            </div>

            <!-- Patients Table -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        Danh Sách Bệnh Nhân
                        <c:if test="${not empty keyword}">
                            <span style="font-size:13px; font-weight:normal; color:var(--text-muted); margin-left:8px;">
                                (Kết quả tìm kiếm cho: "<strong>${keyword}</strong>")
                            </span>
                        </c:if>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table-custom" data-datatable="true" data-page-size="10">
                        <thead>
                            <tr>
                                <th>Mã BN</th>
                                <th>Họ & Tên</th>
                                <th>Số Điện Thoại</th>
                                <th>Giới Tính / Ngày Sinh</th>
                                <th>Cảnh Báo Bệnh Lý & Dị Ứng</th>
                                <th>Địa Chỉ</th>
                                <th style="text-align: right;" data-no-sort="true">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty patientList}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <h4>Không tìm thấy bệnh nhân nào</h4>
                                                <p>Thử tìm kiếm với số điện thoại khác hoặc thêm mới hồ sơ bệnh nhân.</p>
                                                <div style="margin-top:16px;">
                                                    <a href="${pageContext.request.contextPath}/reception/patients/create" class="btn btn-primary btn-sm">
                                                        + Đăng ký hồ sơ mới
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="p" items="${patientList}">
                                        <tr>
                                            <td>
                                                <strong style="color:var(--text-muted); font-size:13px;">#${p.patientId}</strong>
                                            </td>
                                            <td>
                                                <div class="patient-cell">
                                                    <div class="patient-avatar-sm">
                                                        ${p.fullName.substring(0, 1).toUpperCase()}
                                                    </div>
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${p.patientId}" 
                                                           style="font-weight:700; color:var(--drsmile-navy); text-decoration:none;" 
                                                           title="Nhấp để xem hồ sơ bệnh án 360°">
                                                            ${p.fullName}
                                                        </a>
                                                        <c:if test="${not empty p.citizenId}">
                                                            <div style="font-size:11px; color:var(--text-muted);">CCCD: ${p.citizenId}</div>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span style="font-family:monospace; font-weight:600; background:#f1f5f9; padding:4px 8px; border-radius:6px;">
                                                    ${p.phone}
                                                </span>
                                            </td>
                                            <td>
                                                <div style="font-weight:600;">${p.gender}</div>
                                                <c:if test="${not empty p.dob}">
                                                    <div style="font-size:11.5px; color:var(--text-muted);">${p.dob}</div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty p.medicalAlerts or not empty p.allergies}">
                                                        <c:if test="${not empty p.medicalAlerts}">
                                                            <div class="alert-tag">Bệnh nền: ${p.medicalAlerts}</div>
                                                        </c:if>
                                                        <c:if test="${not empty p.allergies}">
                                                            <div class="alert-tag" style="background:#fff1f2; color:#be123c;">Dị ứng: ${p.allergies}</div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:var(--text-muted); font-size:12.5px;">Bình thường</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div style="max-width:200px; font-size:12.5px; color:var(--text-secondary);">
                                                    ${not empty p.address ? p.address : 'Chưa cập nhật'}
                                                </div>
                                            </td>
                                            <td style="text-align: right;">
                                                <div style="display:inline-flex; gap:6px;">
                                                    <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${p.patientId}" 
                                                       class="btn btn-secondary btn-sm" 
                                                       style="color:var(--drsmile-navy); font-weight:700; border-color:#cbd5e1;" 
                                                       title="Xem chi tiết bệnh án 360°">
                                                        Bệnh Án
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/reception/patients/edit?id=${p.patientId}" class="btn btn-secondary btn-sm">
                                                        Sửa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/reception/appointments/create?patientId=${p.patientId}" class="btn btn-primary btn-sm" title="Đặt lịch hẹn ngay cho bệnh nhân này">
                                                        Đặt Lịch
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div style="display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-top:1px solid var(--border-light); font-size:13px; color:var(--text-muted);">
                        <div>Hiển thị trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng số: ${totalRecords} bệnh nhân)</div>
                        <div style="display:flex; gap:4px;">
                            <c:forEach begin="1" end="${totalPages}" var="pageIndex">
                                <a href="${pageContext.request.contextPath}/reception/patients?page=${pageIndex}&keyword=${keyword}" 
                                   class="btn btn-sm ${pageIndex == currentPage ? 'btn-primary' : 'btn-secondary'}">
                                    ${pageIndex}
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</div>

<!-- DCMS Universal Data Table Standard Engine -->
<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=2.1" charset="UTF-8"></script>

</body>
</html>
