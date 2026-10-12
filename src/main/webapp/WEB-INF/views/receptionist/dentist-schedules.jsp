<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="schedules" scope="request" />
<c:set var="u" value="${sessionScope.currentUser}" />
<c:set var="userRole" value="${not empty u.roleName ? u.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
<c:set var="canManageSchedules" value="${userRole eq 'Admin' or userRole eq 'Receptionist'}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Trực Bác Sĩ (Dentist Work Schedule) — Dr.Smile DCMS Dental Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.1">
    <style>
        .preset-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
            margin-top: 6px;
        }
        .preset-btn {
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            padding: 8px 10px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #334155;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s;
        }
        .preset-btn:hover {
            background: #e0f2fe;
            border-color: #0284c7;
            color: #0369a1;
        }
        .preset-btn.active-preset {
            background: #e0f2fe;
            border-color: #0284c7;
            color: #0369a1;
            box-shadow: 0 0 0 2px rgba(2, 132, 199, 0.2);
        }
        .search-input-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }
        .search-input-wrap svg {
            position: absolute;
            left: 10px;
            pointer-events: none;
            color: #94a3b8;
        }
        .search-input-wrap input {
            padding-left: 32px !important;
        }
        .toolbar-group {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        @media (max-width: 900px) {
            .toolbar-group {
                width: 100%;
                justify-content: flex-start;
            }
            .search-input-wrap input {
                width: 100% !important;
            }
        }
    </style>
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
                <a href="${pageContext.request.contextPath}/reception/calendar">Lịch Hẹn Khám</a>
                <span class="breadcrumb-separator">/</span>
                <span>Lịch Trực Bác Sĩ (Dentist Work Schedule)</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>Quản Lý Lịch Trực & Phân Ca Bác Sĩ</h1>
                    <p>Thiết lập ca trực cố định hàng tuần theo quy chuẩn điều phối nhân sự, tự động nhận hẹn và chống trùng lịch (UC37)</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/reception/calendar" class="btn btn-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Lịch Dạng Calendar
                    </a>
                    <c:if test="${canManageSchedules}">
                        <button type="button" class="btn btn-primary" onclick="openAddScheduleModal()">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                            + Thêm Ca Trực Bác Sĩ
                        </button>
                    </c:if>
                </div>
            </div>

            <!-- Success Notification -->
            <c:if test="${param.success eq 'created'}">
                <div class="alert-banner alert-banner-success">
                    <span class="alert-banner-icon">✓</span>
                    <div><strong>Thành công:</strong> Đã tạo mới ca trực cho Bác sĩ thành công! Lịch hẹn sẽ tự động áp dụng khung giờ này.</div>
                </div>
            </c:if>
            <c:if test="${param.success eq 'deleted'}">
                <div class="alert-banner alert-banner-info">
                    <span class="alert-banner-icon">✓</span>
                    <div><strong>Đã xóa:</strong> Đã gỡ bỏ ca trực khỏi hệ thống.</div>
                </div>
            </c:if>
            <c:if test="${param.success eq 'toggled'}">
                <div class="alert-banner alert-banner-info">
                    <span class="alert-banner-icon">✓</span>
                    <div><strong>Cập nhật:</strong> Đã thay đổi trạng thái khả dụng của ca trực.</div>
                </div>
            </c:if>

            <!-- Error Notification -->
            <c:if test="${not empty param.error}">
                <div class="alert-banner alert-banner-danger">
                    <span class="alert-banner-icon">!</span>
                    <div><strong>Lỗi thực hiện:</strong> ${param.error}</div>
                </div>
            </c:if>

            <!-- Stats Overview Row -->
            <div class="kpi-grid" style="margin-bottom: 24px;">
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${totalShifts}</h3>
                        <span>Tổng số ca trực trong tuần</span>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${activeShifts}</h3>
                        <span>Đang nhận hẹn khám (Active)</span>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-amber">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="10" y1="15" x2="10" y2="9"></line><line x1="14" y1="15" x2="14" y2="9"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${inactiveShifts}</h3>
                        <span>Tạm ngưng nhận hẹn (Pause)</span>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-purple">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="16" y1="11" x2="22" y2="11"></line></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${dentists.size()}</h3>
                        <span>Bác sĩ chuyên khoa tại cơ sở</span>
                    </div>
                </div>
            </div>

            <!-- FULL-WIDTH SCHEDULE CARD -->
            <div class="card" style="margin: 0;">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                    <div>
                        <div class="card-title">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#007acc" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                <line x1="8" y1="2" x2="8" y2="6"></line>
                                <line x1="3" y1="10" x2="21" y2="10"></line>
                            </svg>
                            <span>Danh Sách Ca Trực Bác Sĩ Hàng Tuần</span>
                        </div>
                        <p style="font-size: 12px; color: var(--text-muted); margin: 3px 0 0 0;">
                            Tổng cộng <strong>${scheduleList.size()}</strong> ca làm việc đã thiết lập &bull; Click các tab thứ bên dưới để lọc nhanh
                        </p>
                    </div>

                    <!-- Toolbar: Doctor Filter + Add Schedule Button -->
                    <div class="toolbar-group">
                        <!-- Filter by Dentist -->
                        <form action="${pageContext.request.contextPath}/reception/schedules" method="GET" style="display: flex; align-items: center; gap: 8px; margin: 0;">
                            <label style="font-size: 12.5px; font-weight: 600; color: var(--text-muted); margin: 0; white-space: nowrap;">Bác sĩ:</label>
                            <select name="dentistId" class="form-control" style="width: 190px; padding: 7px 12px; font-size: 12.5px; border-radius: 8px;" onchange="this.form.submit()">
                                <option value="">-- Tất cả Bác sĩ --</option>
                                <c:forEach var="d" items="${dentists}">
                                    <option value="${d.dentistId}" ${selectedDentistId == d.dentistId ? 'selected' : ''}>
                                        ${d.fullName}
                                    </option>
                                </c:forEach>
                            </select>
                        </form>

                        <c:set var="u" value="${sessionScope.currentUser}" />
                        <c:set var="userRole" value="${not empty u.roleName ? u.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
                        <c:set var="canManageSchedules" value="${userRole eq 'Admin' or userRole eq 'Receptionist'}" />

                        <!-- Add Schedule Trigger Button -->
                        <c:if test="${canManageSchedules}">
                            <button type="button" class="btn btn-primary btn-sm" onclick="openAddScheduleModal()" style="display: inline-flex; align-items: center; gap: 4px; padding: 7px 14px; font-size: 12.5px;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                + Thêm Ca
                            </button>
                        </c:if>
                    </div>
                </div>

                <!-- DAY-OF-WEEK QUICK FILTER CHIPS -->
                <div class="filter-chips-bar" id="dayFilterBar">
                    <span class="filter-chip active" data-day="all" onclick="selectDayFilter('all')">
                        Tất cả ngày <span class="filter-chip-count" id="count-all">${scheduleList.size()}</span>
                    </span>
                    <span class="filter-chip" data-day="1" onclick="selectDayFilter('1')">
                        Thứ Hai <span class="filter-chip-count" id="count-1">0</span>
                    </span>
                    <span class="filter-chip" data-day="2" onclick="selectDayFilter('2')">
                        Thứ Ba <span class="filter-chip-count" id="count-2">0</span>
                    </span>
                    <span class="filter-chip" data-day="3" onclick="selectDayFilter('3')">
                        Thứ Tư <span class="filter-chip-count" id="count-3">0</span>
                    </span>
                    <span class="filter-chip" data-day="4" onclick="selectDayFilter('4')">
                        Thứ Năm <span class="filter-chip-count" id="count-4">0</span>
                    </span>
                    <span class="filter-chip" data-day="5" onclick="selectDayFilter('5')">
                        Thứ Sáu <span class="filter-chip-count" id="count-5">0</span>
                    </span>
                    <span class="filter-chip" data-day="6" onclick="selectDayFilter('6')">
                        Thứ Bảy <span class="filter-chip-count" id="count-6">0</span>
                    </span>
                    <span class="filter-chip" data-day="7" onclick="selectDayFilter('7')">
                        Chủ Nhật <span class="filter-chip-count" id="count-7">0</span>
                    </span>
                </div>

                <!-- ROSTER TABLE -->
                <div class="table-responsive">
                    <table class="table-custom" id="scheduleTable">
                        <thead>
                            <tr>
                                <th style="width: 80px; text-align: center;">Mã Ca</th>
                                <th style="min-width: 280px;">Bác Sĩ Điều Trị</th>
                                <th style="width: 140px; text-align: center;">Thứ Trực</th>
                                <th style="width: 200px;">Khung Giờ Ca Làm Việc</th>
                                <th style="width: 170px; text-align: center;">Trạng Thái</th>
                                <th style="text-align: right; width: 180px;" data-no-sort="true">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="scheduleTableBody">
                            <c:choose>
                                <c:when test="${empty scheduleList}">
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 60px 20px; color: var(--text-muted);">
                                            <div style="font-size: 15px; font-weight: 700; color: var(--drsmile-navy); margin-bottom: 6px;">Chưa có ca trực nào được thiết lập</div>
                                            <div style="font-size: 13px; margin-bottom: 16px;">Bấm nút "+ Thêm Ca Trực Bác Sĩ" để bắt đầu thiết lập lịch làm việc cố định hàng tuần.</div>
                                            <button type="button" class="btn btn-primary btn-sm" onclick="openAddScheduleModal()">
                                                + Thêm Ca Trực Đầu Tiên
                                            </button>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="s" items="${scheduleList}">
                                        <tr class="schedule-row" data-day="${s.dayOfWeek}" data-dentist="${s.dentistId}" data-name="${s.dentistName.toLowerCase()} ${s.specialization.toLowerCase()}">
                                            <td style="text-align: center;">
                                                <span class="badge-code">#${s.scheduleId}</span>
                                            </td>
                                            <td>
                                                <div class="doctor-cell">
                                                    <div class="doctor-avatar-sm">
                                                        ${s.dentistName.substring(s.dentistName.lastIndexOf(' ') + 1, s.dentistName.lastIndexOf(' ') + 2)}
                                                    </div>
                                                    <div class="doctor-cell-info">
                                                        <div class="doctor-cell-name">${s.dentistName}</div>
                                                        <div class="doctor-cell-sub">
                                                            <span>${s.specialization}</span> &bull; <span class="badge-room">${s.roomNumber != null ? s.roomNumber : 'Ghế khám'}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td style="text-align: center;">
                                                <span class="day-badge day-${s.dayOfWeek}">
                                                    ${s.dayOfWeekName}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="time-badge">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <circle cx="12" cy="12" r="10"></circle>
                                                        <polyline points="12 6 12 12 16 14"></polyline>
                                                    </svg>
                                                    <span>${s.shiftTimeFormatted}</span>
                                                </div>
                                            </td>
                                            <td style="text-align: center;">
                                                <c:choose>
                                                    <c:when test="${s.available}">
                                                        <span class="status-pill status-pill-success">
                                                            <span class="status-dot"></span>
                                                            Đang nhận hẹn
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-pill status-pill-muted">
                                                            <span class="status-dot"></span>
                                                            Tạm ngưng
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right;">
                                                <c:choose>
                                                    <c:when test="${canManageSchedules}">
                                                        <div style="display: inline-flex; gap: 8px; align-items: center; justify-content: flex-end; white-space: nowrap;">
                                                            <!-- Toggle Availability Form -->
                                                            <form action="${pageContext.request.contextPath}/reception/schedules/toggle" method="POST" style="margin: 0; display: inline;">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}" />
                                                                <input type="hidden" name="available" value="${!s.available}" />
                                                                <input type="hidden" name="returnDentistId" value="${selectedDentistId}" />
                                                                <button type="submit" class="btn-action-outline" title="${s.available ? 'Tạm ngưng nhận hẹn' : 'Kích hoạt ca trực'}">
                                                                    ${s.available ? 'Tạm ngưng' : 'Kích hoạt'}
                                                                </button>
                                                            </form>

                                                            <!-- Delete Schedule Form -->
                                                            <form action="${pageContext.request.contextPath}/reception/schedules/delete" method="POST" style="margin: 0; display: inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa ca trực #${s.scheduleId} của ${s.dentistName} vào ${s.dayOfWeekName}?');">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}" />
                                                                <input type="hidden" name="returnDentistId" value="${selectedDentistId}" />
                                                                <button type="submit" class="btn-action-danger" title="Xóa ca trực">
                                                                    Xóa
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size: 11.5px; color: var(--text-muted); font-weight: 600;">Xem ca</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                            <tr id="noResultsRow" style="display: none;">
                                <td colspan="6" style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
                                    <div style="font-size: 14px; font-weight: 600; color: var(--drsmile-navy); margin-bottom: 4px;">Không tìm thấy ca trực phù hợp</div>
                                    <div style="font-size: 12.5px;">Thử chọn ngày khác hoặc xóa từ khóa tìm kiếm.</div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- MODAL DIALOG: THÊM CA TRỰC BÁC SĨ -->
<c:if test="${canManageSchedules}">
<div id="addScheduleModal" class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="modalScheduleTitle" hidden>
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title" id="modalScheduleTitle">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#007acc" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
                <span>Khai Báo Ca Trực Bác Sĩ Mới</span>
            </div>
            <button type="button" class="modal-close-btn" onclick="closeAddScheduleModal()" aria-label="Đóng">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/reception/schedules/create" method="POST">
            <div style="display: flex; flex-direction: column; gap: 16px;">
                <!-- Doctor Selection -->
                <div class="form-group">
                    <label for="formDentistId" class="form-label required">Bác Sĩ Phụ Trách</label>
                    <select id="formDentistId" name="dentistId" class="form-control" required>
                        <option value="">-- Chọn bác sĩ trực --</option>
                        <c:forEach var="d" items="${dentists}">
                            <option value="${d.dentistId}" ${selectedDentistId == d.dentistId ? 'selected' : ''}>
                                ${d.fullName} (${d.specialization})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Day Of Week -->
                <div class="form-group">
                    <label for="formDayOfWeek" class="form-label required">Thứ Trong Tuần</label>
                    <select id="formDayOfWeek" name="dayOfWeek" class="form-control" required>
                        <option value="1">Thứ Hai</option>
                        <option value="2">Thứ Ba</option>
                        <option value="3">Thứ Tư</option>
                        <option value="4">Thứ Năm</option>
                        <option value="5">Thứ Sáu</option>
                        <option value="6">Thứ Bảy</option>
                        <option value="7">Chủ Nhật</option>
                    </select>
                </div>

                <!-- Quick Preset Shifts -->
                <div class="form-group">
                    <label class="form-label" style="display: flex; justify-content: space-between; align-items: center;">
                        <span>Khung Giờ Mẫu Nhanh</span>
                        <span style="font-size: 11.5px; font-weight: 500; color: #0284c7;">Click để điền giờ tự động</span>
                    </label>
                    <div class="preset-buttons">
                        <button type="button" class="preset-btn" onclick="applyPreset('08:00', '12:00', this)">
                            Sáng (08:00 - 12:00)
                        </button>
                        <button type="button" class="preset-btn" onclick="applyPreset('13:00', '17:30', this)">
                            Chiều (13:00 - 17:30)
                        </button>
                        <button type="button" class="preset-btn" onclick="applyPreset('13:00', '18:30', this)">
                            Tối (13:00 - 18:30)
                        </button>
                        <button type="button" class="preset-btn" onclick="applyPreset('08:00', '18:30', this)">
                            Cả ngày (08:00 - 18:30)
                        </button>
                    </div>
                </div>

                <!-- Start and End Time Inputs -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                    <div class="form-group">
                        <label for="shiftStart" class="form-label required">Giờ Bắt Đầu</label>
                        <input type="time" id="shiftStart" name="shiftStart" class="form-control" value="08:00" required />
                    </div>
                    <div class="form-group">
                        <label for="shiftEnd" class="form-label required">Giờ Kết Thúc</label>
                        <input type="time" id="shiftEnd" name="shiftEnd" class="form-control" value="17:00" required />
                    </div>
                </div>

                <!-- Is Available Checkbox -->
                <div style="padding: 12px 14px; background: #f8fafc; border: 1px solid var(--border-light); border-radius: 8px;">
                    <label style="display: flex; align-items: center; gap: 10px; font-weight: 600; cursor: pointer; margin: 0; font-size: 13px; color: var(--drsmile-navy);">
                        <input type="checkbox" name="isAvailable" value="true" checked style="width: 18px; height: 18px; accent-color: var(--drsmile-navy);" />
                        <span>Kích hoạt ca trực ngay (Sẵn sàng nhận hẹn khám)</span>
                    </label>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeAddScheduleModal()">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" style="padding: 9px 22px;">
                    Lưu Ca Trực Bác Sĩ
                </button>
            </div>
        </form>
    </div>
</div>
</c:if>

<!-- DCMS Universal Data Table Standard Engine -->
<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=2.1" charset="UTF-8"></script>

<script>
    let activeDayFilter = 'all';

    function openAddScheduleModal() {
        const modal = document.getElementById('addScheduleModal');
        if (modal) {
            modal.removeAttribute('hidden');
            document.body.style.overflow = 'hidden';
            setTimeout(() => {
                const select = document.getElementById('formDentistId');
                if (select) select.focus();
            }, 100);
        }
    }

    function closeAddScheduleModal() {
        const modal = document.getElementById('addScheduleModal');
        if (modal) {
            modal.setAttribute('hidden', '');
            document.body.style.overflow = '';
        }
    }

    // Close on clicking backdrop
    const modalBackdropEl = document.getElementById('addScheduleModal');
    if (modalBackdropEl) {
        modalBackdropEl.addEventListener('click', function(e) {
            if (e.target === this) {
                closeAddScheduleModal();
            }
        });
    }

    // Close on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAddScheduleModal();
        }
    });

    function applyPreset(start, end, btn) {
        document.getElementById('shiftStart').value = start;
        document.getElementById('shiftEnd').value = end;

        // Visual feedback
        document.querySelectorAll('.preset-btn').forEach(b => b.classList.remove('active-preset'));
        if (btn) btn.classList.add('active-preset');
    }

    function selectDayFilter(day) {
        activeDayFilter = day;
        document.querySelectorAll('.filter-chip').forEach(chip => {
            if (chip.getAttribute('data-day') === day) {
                chip.classList.add('active');
            } else {
                chip.classList.remove('active');
            }
        });
        if (scheduleDt) {
            scheduleDt.setCustomFilter(row => {
                const rowDay = row.getAttribute('data-day');
                return activeDayFilter === 'all' || rowDay === activeDayFilter;
            });
        }
    }

    let scheduleDt = null;

    // Calculate day counts dynamically on load and initialize DcmsDataTable
    document.addEventListener('DOMContentLoaded', function() {
        const rows = document.querySelectorAll('.schedule-row');
        const dayCounts = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0 };

        rows.forEach(row => {
            const day = row.getAttribute('data-day');
            if (day && dayCounts[day] !== undefined) {
                dayCounts[day]++;
            }
        });

        for (let d = 1; d <= 7; d++) {
            const badge = document.getElementById('count-' + d);
            if (badge) {
                badge.textContent = dayCounts[d];
            }
        }

        // Initialize Universal DCMS Data Table Standard
        scheduleDt = new DcmsDataTable('#scheduleTable', {
            pageSize: 10,
            searchPlaceholder: 'Tìm nhanh tên bác sĩ, chuyên khoa, phòng khám...',
            customFilterFn: function(row) {
                const rowDay = row.getAttribute('data-day');
                return activeDayFilter === 'all' || rowDay === activeDayFilter;
            }
        });
    });
</script>

</body>
</html>
