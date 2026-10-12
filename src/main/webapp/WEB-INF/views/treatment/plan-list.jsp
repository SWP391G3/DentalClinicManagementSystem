<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activeMenu" value="treatment_plans" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kế Hoạch Điều Trị Nha Khoa — DCMS Dr.Smile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=4.0">
    <style>
        .page-hero-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: 0 4px 18px rgba(0, 51, 102, 0.05);
            padding: 24px 30px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            flex-wrap: wrap;
            position: relative;
            overflow: hidden;
        }

        .page-hero-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(180deg, var(--drsmile-navy) 0%, #00a8cc 100%);
        }

        .category-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11.5px;
            font-weight: 700;
            color: #0284c7;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
            padding: 3px 10px;
            border-radius: 9999px;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .patient-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .patient-avatar-mini {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--drsmile-navy) 0%, #00a8cc 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
            flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(0, 51, 102, 0.15);
        }

        .plan-code-badge {
            font-family: 'Inter', monospace;
            font-weight: 800;
            color: #0052cc;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12.5px;
            white-space: nowrap !important;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-action-view {
            background: #f0f7fd;
            color: var(--drsmile-blue);
            border: 1px solid #bae6fd;
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 12.5px;
            font-weight: 700;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all var(--transition-fast);
            white-space: nowrap !important;
        }

        .btn-action-view:hover {
            background: var(--drsmile-blue);
            color: #ffffff;
            border-color: var(--drsmile-blue);
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 82, 204, 0.25);
        }

        /* Interactive KPI Cards */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        @media (max-width: 1024px) {
            .kpi-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        .kpi-card-interactive {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            padding: 20px 22px;
            box-shadow: 0 2px 8px rgba(0, 51, 102, 0.04);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            cursor: pointer;
            user-select: none;
        }

        .kpi-card-interactive:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px -6px rgba(0, 51, 102, 0.12);
            border-color: #cbd5e1;
        }

        .kpi-card-interactive.active-filter {
            border-color: #0052cc !important;
            box-shadow: 0 0 0 2px rgba(0, 82, 204, 0.25) !important;
            background: #f8fbff;
        }

        .kpi-border-navy { border-left: 4px solid #0052cc !important; }
        .kpi-border-amber { border-left: 4px solid #f59e0b !important; }
        .kpi-border-green { border-left: 4px solid #10b981 !important; }
        .kpi-border-cyan { border-left: 4px solid #00a8cc !important; }

        .kpi-icon-box-modern {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .kpi-icon-navy-modern { background: #eff6ff; color: #1d4ed8; }
        .kpi-icon-amber-modern { background: #fffbeb; color: #d97706; }
        .kpi-icon-green-modern { background: #ecfdf5; color: #059669; }
        .kpi-icon-cyan-modern { background: #e0f2fe; color: #0284c7; }

        .kpi-meta-modern h3 {
            font-size: 28px;
            font-weight: 800;
            color: var(--drsmile-navy);
            line-height: 1.1;
            margin: 0 0 4px 0;
            font-variant-numeric: tabular-nums;
        }

        .kpi-meta-modern .kpi-label {
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            margin-bottom: 2px;
        }

        .kpi-meta-modern .kpi-subtext {
            font-size: 11.5px;
            color: #94a3b8;
            font-weight: 500;
        }

        /* Filter Tabs */
        .filter-tabs-row {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 18px;
            flex-wrap: wrap;
        }

        .filter-tab-pill {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            color: #475569;
            padding: 6px 16px;
            border-radius: 9999px;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .filter-tab-pill:hover {
            background: #f8fafc;
            color: var(--drsmile-navy);
            border-color: #94a3b8;
        }

        .filter-tab-pill.active {
            background: var(--drsmile-navy);
            color: #ffffff;
            border-color: var(--drsmile-navy);
            box-shadow: 0 2px 8px rgba(0, 51, 102, 0.2);
        }

        .filter-tab-pill .tab-count {
            background: rgba(0, 0, 0, 0.08);
            padding: 1px 7px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 700;
        }

        .filter-tab-pill.active .tab-count {
            background: rgba(255, 255, 255, 0.25);
            color: #ffffff;
        }
    </style>
</head>
<body class="theme-drsmile">

<div class="app-shell">
    <jsp:include page="../layout/sidebar.jsp" />

    <div class="app-main">
        <jsp:include page="../layout/header.jsp" />

        <main class="page-content">
            <!-- Hero Header Card -->
            <div class="page-hero-card">
                <div>
                    <div class="category-chip">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        <span>Khu Khám Lâm Sàng &bull; Nha Khoa Dr.Smile</span>
                    </div>
                    <h1 style="font-size: 26px; font-weight: 800; color: var(--drsmile-navy); margin: 0 0 6px 0; letter-spacing: -0.4px;">
                        Kế Hoạch Điều Trị & Dự Toán Viện Phí
                    </h1>
                    <p style="font-size: 13.5px; color: var(--text-secondary); margin: 0;">
                        Lập phác đồ điều trị đa buổi, chỉ định răng theo chuẩn FDI và quản lý dự toán chi phí minh bạch
                    </p>
                </div>

                <c:set var="u" value="${sessionScope.currentUser}" />
                <c:set var="userRole" value="${not empty u.roleName ? u.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
                <c:set var="isClinician" value="${userRole eq 'Admin' or userRole eq 'Dentist'}" />

                <c:if test="${isClinician}">
                    <div>
                        <a href="${pageContext.request.contextPath}/treatment/plans/create" class="btn btn-primary" style="padding: 12px 24px; font-size: 13.5px; font-weight: 700; display: inline-flex; align-items: center; gap: 8px; border-radius: 10px; box-shadow: 0 4px 14px rgba(0, 51, 102, 0.25);">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            <span>Lập Kế Hoạch Điều Trị Mới</span>
                        </a>
                    </div>
                </c:if>
            </div>

            <!-- KPI Cards Summary (Interactive) -->
            <c:set var="totalCount" value="${plans.size()}" />
            <c:set var="inProgressCount" value="0" />
            <c:set var="proposedCount" value="0" />
            <c:set var="acceptedCount" value="0" />
            <c:forEach var="p" items="${plans}">
                <c:if test="${p.status eq 'InProgress'}"><c:set var="inProgressCount" value="${inProgressCount + 1}" /></c:if>
                <c:if test="${p.status eq 'Proposed'}"><c:set var="proposedCount" value="${proposedCount + 1}" /></c:if>
                <c:if test="${p.status eq 'Accepted'}"><c:set var="acceptedCount" value="${acceptedCount + 1}" /></c:if>
            </c:forEach>

            <div class="kpi-grid">
                <div class="kpi-card-interactive kpi-border-navy active-filter" data-status="all" onclick="filterByStatus('all', this)" title="Nhấp để hiển thị toàn bộ phác đồ">
                    <div class="kpi-meta-modern">
                        <h3>${totalCount}</h3>
                        <div class="kpi-label">Tổng kế hoạch đã lập</div>
                        <div class="kpi-subtext">Toàn hệ thống phòng khám</div>
                    </div>
                    <div class="kpi-icon-box-modern kpi-icon-navy-modern">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1"/></svg>
                    </div>
                </div>

                <div class="kpi-card-interactive kpi-border-amber" data-status="Chờ bệnh nhân duyệt" onclick="filterByStatus('Chờ bệnh nhân duyệt', this)" title="Nhấp để lọc danh sách chờ duyệt">
                    <div class="kpi-meta-modern">
                        <h3 style="color: #b45309;">${proposedCount}</h3>
                        <div class="kpi-label">Chờ bệnh nhân duyệt</div>
                        <div class="kpi-subtext">Cần tư vấn chốt lộ trình</div>
                    </div>
                    <div class="kpi-icon-box-modern kpi-icon-amber-modern">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                </div>

                <div class="kpi-card-interactive kpi-border-green" data-status="Đã đồng ý điều trị" onclick="filterByStatus('Đã đồng ý điều trị', this)" title="Nhấp để lọc danh sách đã đồng ý">
                    <div class="kpi-meta-modern">
                        <h3 style="color: #059669;">${acceptedCount}</h3>
                        <div class="kpi-label">Đã đồng ý điều trị</div>
                        <div class="kpi-subtext">Sẵn sàng lên ghế điều trị</div>
                    </div>
                    <div class="kpi-icon-box-modern kpi-icon-green-modern">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                </div>

                <div class="kpi-card-interactive kpi-border-cyan" data-status="Đang điều trị" onclick="filterByStatus('Đang điều trị', this)" title="Nhấp để lọc danh sách đang thực hiện">
                    <div class="kpi-meta-modern">
                        <h3 style="color: #0284c7;">${inProgressCount}</h3>
                        <div class="kpi-label">Đang điều trị tại ghế</div>
                        <div class="kpi-subtext">Thủ thuật đang triển khai</div>
                    </div>
                    <div class="kpi-icon-box-modern kpi-icon-cyan-modern">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                    </div>
                </div>
            </div>

            <!-- Quick Filter Tabs Row -->
            <div class="filter-tabs-row">
                <button type="button" class="filter-tab-pill active" onclick="filterByStatus('all', this)">
                    <span>Tất Cả Phác Đồ</span>
                    <span class="tab-count">${totalCount}</span>
                </button>
                <button type="button" class="filter-tab-pill" onclick="filterByStatus('Chờ bệnh nhân duyệt', this)">
                    <span>Chờ Bệnh Nhân Duyệt</span>
                    <span class="tab-count">${proposedCount}</span>
                </button>
                <button type="button" class="filter-tab-pill" onclick="filterByStatus('Đã đồng ý điều trị', this)">
                    <span>Đã Đồng Ý Điều Trị</span>
                    <span class="tab-count">${acceptedCount}</span>
                </button>
                <button type="button" class="filter-tab-pill" onclick="filterByStatus('Đang điều trị', this)">
                    <span>Đang Điều Trị Tại Ghế</span>
                    <span class="tab-count">${inProgressCount}</span>
                </button>
            </div>

            <!-- Treatment Plans Data Table Card -->
            <div class="card" style="box-shadow: 0 4px 20px rgba(0, 51, 102, 0.05); border-radius: 16px; overflow: hidden; border: 1px solid var(--border);">
                <div class="card-header" style="padding: 18px 24px; background: #ffffff; border-bottom: 1px solid var(--border-light); display: flex; align-items: center; justify-content: space-between;">
                    <div class="card-title" style="font-size: 16px; font-weight: 800; color: var(--drsmile-navy); display: flex; align-items: center; gap: 8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                        <span>Danh Sách Phác Đồ Lâm Sàng Toàn Viện</span>
                    </div>
                    <span class="badge-pill badge-primary" style="font-size: 12px; padding: 4px 12px;">
                        ${plans.size()} Phác đồ
                    </span>
                </div>

                <div class="card-body" style="padding: 0;">
                    <div class="table-responsive" style="margin: 0; padding: 0; border: none; box-shadow: none; border-radius: 0;">
                        <table id="treatmentPlansTable" class="table-custom" data-datatable="true" data-page-size="10" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th style="width: 11%;">Mã Kế Hoạch</th>
                                    <th style="width: 20%;">Bệnh Nhân</th>
                                    <th style="width: 17%;">Bác Sĩ Phụ Trách</th>
                                    <th style="width: 22%;">Nội Dung / Chẩn Đoán</th>
                                    <th style="width: 13%;">Tổng Dự Toán</th>
                                    <th style="width: 11%;">Trạng Thái</th>
                                    <th style="width: 6%; text-align: center;" data-no-sort="true">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="plan" items="${plans}">
                                    <tr>
                                        <td>
                                            <span class="plan-code-badge">
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                                #KH-${plan.planId}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="patient-cell">
                                                <div class="patient-avatar-mini">
                                                    ${plan.patientName.substring(0, 1).toUpperCase()}
                                                </div>
                                                <div>
                                                    <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${plan.patientId}" 
                                                       target="_blank" 
                                                       style="font-weight: 700; color: var(--drsmile-navy); font-size: 14px; text-decoration: none;"
                                                       title="Nhấp để xem Bệnh Án 360°">
                                                        ${plan.patientName}
                                                    </a>
                                                    <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px; display: flex; align-items: center; gap: 4px;">
                                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                                                        <span>${plan.patientPhone}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--text-primary); font-size: 13.5px;">
                                                ${plan.dentistName}
                                            </div>
                                            <div style="font-size: 12px; color: #0284c7; font-weight: 600; margin-top: 2px;">
                                                ${plan.dentistSpecialization}
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 13.5px; margin-bottom: 2px;">
                                                ${plan.title}
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-secondary); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;" title="${plan.diagnosis}">
                                                ${plan.diagnosis}
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 800; color: var(--drsmile-navy); font-size: 14.5px;">
                                                ${plan.formattedFinalEstimate}
                                            </div>
                                            <c:if test="${plan.totalDiscount > 0}">
                                                <div style="margin-top: 3px;">
                                                    <span style="font-size: 11px; color: #15803d; background: #dcfce7; padding: 2px 7px; border-radius: 4px; font-weight: 600; display: inline-flex; align-items: center; gap: 3px;">
                                                        - ${plan.formattedTotalDiscount}
                                                    </span>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <span class="status-pill ${plan.statusBadgeClass}">
                                                <span class="status-dot"></span>
                                                ${plan.statusDisplayName}
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <a href="${pageContext.request.contextPath}/treatment/plans/detail?id=${plan.planId}" class="btn-action-view" title="Xem chi tiết phác đồ & Báo giá">
                                                <span>Chi Tiết</span>
                                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=2.5"></script>
<script>
    function filterByStatus(statusName, el) {
        // Update active tab buttons
        document.querySelectorAll('.filter-tab-pill').forEach(function(pill) {
            pill.classList.remove('active');
        });
        
        // Update active KPI cards
        document.querySelectorAll('.kpi-card-interactive').forEach(function(card) {
            card.classList.remove('active-filter');
        });

        if (el) {
            if (el.classList.contains('filter-tab-pill')) {
                el.classList.add('active');
                const matchedCard = document.querySelector('.kpi-card-interactive[data-status="' + statusName + '"]');
                if (matchedCard) matchedCard.classList.add('active-filter');
            } else if (el.classList.contains('kpi-card-interactive')) {
                el.classList.add('active-filter');
                document.querySelectorAll('.filter-tab-pill').forEach(function(pill) {
                    const text = pill.innerText || pill.textContent;
                    if (statusName === 'all' && text.indexOf('Tất Cả') !== -1) pill.classList.add('active');
                    else if (statusName !== 'all' && text.indexOf(statusName) !== -1) pill.classList.add('active');
                });
            }
        }

        // Apply filter to datatable
        const searchInput = document.querySelector('.dt-search-input');
        if (searchInput) {
            searchInput.value = statusName === 'all' ? '' : statusName;
            searchInput.dispatchEvent(new Event('input', { bubbles: true }));
        }
    }
</script>
</body>
</html>

