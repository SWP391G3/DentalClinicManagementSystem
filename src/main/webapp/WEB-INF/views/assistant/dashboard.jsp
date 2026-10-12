<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bàn Làm Việc Y Tá Nha Khoa — DCMS Dr.Smile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <style>
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .kpi-card {
            background: #ffffff;
            border-radius: var(--radius-lg);
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        .kpi-icon-box {
            width: 48px;
            height: 48px;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .kpi-icon-blue { background: #e0f2fe; color: #0284c7; }
        .kpi-icon-amber { background: #fef3c7; color: #d97706; }
        .kpi-icon-green { background: #dcfce7; color: #16a34a; }
        .kpi-icon-purple { background: #ede9fe; color: #7c3aed; }

        .kpi-meta h3 {
            margin: 0;
            font-size: 26px;
            font-weight: 800;
            color: var(--drsmile-navy);
            line-height: 1.1;
        }
        .kpi-meta span {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 4px;
            display: inline-block;
        }

        .vitals-badge-ok {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 600;
            display: inline-flex;
            flex-direction: column;
            gap: 2px;
            line-height: 1.3;
        }
        .vitals-badge-pending {
            background: #fff7ed;
            color: #c2410c;
            border: 1px solid #ffedd5;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 600;
            display: inline-block;
        }

        /* Modal styling */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 1050;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .modal-overlay.show {
            display: flex;
        }
        .modal-dialog-custom {
            background: #ffffff;
            border-radius: var(--radius-xl);
            width: 100%;
            max-width: 620px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            animation: modalPop 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes modalPop {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        .modal-header-custom {
            background: linear-gradient(135deg, var(--drsmile-navy) 0%, #0c4a6e 100%);
            color: white;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .modal-body-custom {
            padding: 24px;
            max-height: 80vh;
            overflow-y: auto;
        }
        .modal-footer-custom {
            padding: 16px 24px;
            background: #f8fafc;
            border-top: 1px solid var(--border);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
    </style>
</head>
<body class="theme-drsmile">

<div class="app-shell">
    <jsp:include page="../layout/sidebar.jsp" />

    <div class="app-main">
        <jsp:include page="../layout/header.jsp" />

        <main class="page-content">
            <!-- Header Banner -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h1 style="font-size: 24px; font-weight: 800; color: var(--drsmile-navy); margin: 0 0 6px 0;">
                        Bàn Làm Việc Y Tá Nha Khoa
                    </h1>
                    <p style="margin: 0; color: var(--text-muted); font-size: 14px;">
                        Tiếp nhận bệnh nhân, đo chỉ số sinh tồn và chuẩn bị sẵn sàng trước can thiệp điều trị tại ghế
                    </p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <span class="badge-pill badge-Confirmed" style="font-size: 13px; padding: 8px 14px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align: middle; margin-right: 4px;">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="16" y1="2" x2="16" y2="6"></line>
                            <line x1="8" y1="2" x2="8" y2="6"></line>
                            <line x1="3" y1="10" x2="21" y2="10"></line>
                        </svg>
                        Hôm nay: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy" />
                    </span>
                </div>
            </div>

            <!-- Toast Messages -->
            <c:if test="${not empty toastSuccess}">
                <div class="alert-banner alert-banner-success" style="margin-bottom: 20px; padding: 12px 18px; border-radius: 8px; display: flex; align-items: center; gap: 10px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>${toastSuccess}</span>
                </div>
            </c:if>
            <c:if test="${not empty toastError}">
                <div class="alert-banner alert-banner-danger" style="margin-bottom: 20px; padding: 12px 18px; border-radius: 8px; display: flex; align-items: center; gap: 10px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>${toastError}</span>
                </div>
            </c:if>

            <!-- KPI Cards -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${totalVisits}</h3>
                        <span>Tổng ca tiếp đón hôm nay</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-amber">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${waitingCount}</h3>
                        <span>Bệnh nhân đang chờ</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${vitalsRecordedCount}</h3>
                        <span>Đã có sinh hiệu tiền thủ thuật</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon-box kpi-icon-purple">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    </div>
                    <div class="kpi-meta">
                        <h3>${inProgressCount}</h3>
                        <span>Ca đang khám tại ghế</span>
                    </div>
                </div>
            </div>

            <!-- Patient Table Card -->
            <div class="card">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="card-title">
                        <span>Danh Sách Lượt Khám & Đo Sinh Hiệu Tại Ghế</span>
                    </div>
                    <span class="badge-pill badge-Pending">
                        ${empty todayVisits ? 0 : todayVisits.size()} Lượt khám
                    </span>
                </div>

                <div class="card-body" style="padding: 0;">
                    <c:choose>
                        <c:when test="${empty todayVisits}">
                            <div class="empty-state" style="padding: 48px; text-align: center;">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5" style="margin-bottom: 12px;"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
                                <h4 style="margin: 0 0 6px 0; color: var(--drsmile-navy);">Hôm nay chưa có lượt tiếp đón nào</h4>
                                <p style="color: var(--text-muted); margin: 0; font-size: 13.5px;">Khi lễ tân tiếp đón hoặc check-in bệnh nhân, danh sách sẽ hiển thị tại đây.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table-custom" data-datatable="true" data-page-size="10">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px; text-align: center;">STT</th>
                                            <th style="width: 100px;">Mã Buổi Khám</th>
                                            <th style="width: 90px;">Tiếp Đón</th>
                                            <th>Bệnh Nhân</th>
                                            <th>Bác Sĩ & Ghế Khám</th>
                                            <th style="text-align: center; width: 110px;">Trạng Thái</th>
                                            <th style="width: 220px;">Chỉ Số Sinh Hiệu (Tiền Thủ Thuật)</th>
                                            <th style="text-align: center; width: 180px;" data-no-sort="true">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="v" items="${todayVisits}" varStatus="loop">
                                            <c:set var="ass" value="${assessmentMap[v.visitId]}" />
                                            <tr>
                                                <td style="text-align: center; font-weight: 600; color: var(--text-muted);">${loop.index + 1}</td>
                                                <td>
                                                    <span class="badge-code">#BK-${v.visitId}</span>
                                                </td>
                                                <td>
                                                    <span style="font-weight: 600; font-size: 13px; color: var(--text-primary);">
                                                        ${v.checkInTime.toLocalTime().toString().substring(0, 5)}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 14px;">
                                                        ${v.patientName}
                                                    </div>
                                                    <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                        SĐT: <code>${v.patientPhone}</code>
                                                    </div>
                                                    <c:if test="${not empty v.medicalAlerts or not empty v.allergies}">
                                                        <div style="margin-top: 4px; display: flex; gap: 4px; flex-wrap: wrap;">
                                                            <c:if test="${not empty v.medicalAlerts}">
                                                                <span class="alert-tag" style="font-size: 10.5px;">Cảnh báo: ${v.medicalAlerts}</span>
                                                            </c:if>
                                                            <c:if test="${not empty v.allergies}">
                                                                <span class="alert-tag" style="background:#fef3c7; color:#b45309; font-size: 10.5px;">Dị ứng: ${v.allergies}</span>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <div style="font-weight: 600; color: var(--drsmile-navy); font-size: 13.5px;">
                                                        ${empty v.dentistName ? 'Chưa chỉ định' : v.dentistName}
                                                    </div>
                                                    <div style="font-size: 12px; color: var(--primary); margin-top: 2px;">
                                                        ${empty v.operatory ? 'Ghế 1 - P.101' : v.operatory}
                                                    </div>
                                                </td>
                                                <td style="text-align: center;">
                                                    <span class="badge-pill badge-${v.status}">● ${v.status}</span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty ass}">
                                                            <div class="vitals-badge-ok">
                                                                <div>HA: <strong>${empty ass.bloodPressure ? '--' : ass.bloodPressure}</strong> &bull; Mạch: <strong>${empty ass.pulseRate ? '--' : ass.pulseRate} bpm</strong></div>
                                                                <c:if test="${not empty ass.bloodSugar}">
                                                                    <div>Đường huyết: <strong>${ass.bloodSugar} mmol/L</strong></div>
                                                                </c:if>
                                                                <div style="font-size: 11px; color: ${ass.bleedingRisk eq 'High' ? '#b91c1c' : '#15803d'};">
                                                                    Chảy máu: ${ass.bleedingRisk} &bull; ${ass.medicalClearance ? '✓ Đủ điều kiện' : '✕ Tạm hoãn'}
                                                                </div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="vitals-badge-pending">
                                                                Chưa đo sinh hiệu
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <div style="display: flex; gap: 6px; justify-content: center; align-items: center; flex-wrap: wrap;">
                                                        <button type="button" class="btn ${empty ass ? 'btn-primary' : 'btn-outline'}" 
                                                                style="padding: 6px 10px; font-size: 12px; font-weight: 600; white-space: nowrap;"
                                                                onclick="openVitalsModal('${v.visitId}', '${v.patientId}', '${v.patientName}', '${v.patientPhone}', '${not empty ass ? ass.bloodPressure : ''}', '${not empty ass ? ass.pulseRate : ''}', '${not empty ass ? ass.bloodSugar : ''}', '${not empty ass ? ass.bleedingRisk : 'Bình thường'}', '${not empty ass ? ass.anxietyLevel : 'Thấp'}', '${not empty ass ? ass.medicalClearance : 'true'}', '${not empty ass ? ass.notes : ''}')">
                                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align: middle; margin-right: 3px;"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                                            ${empty ass ? 'Đo Sinh Hiệu' : 'Cập Nhật'}
                                                        </button>

                                                        <a href="${pageContext.request.contextPath}/reception/patients/detail?id=${v.patientId}" target="_blank" class="btn btn-outline" style="padding: 6px 10px; font-size: 12px; white-space: nowrap;" title="Xem Bệnh Án 360°">
                                                            Bệnh Án
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- MODAL: GHI NHẬN CHỈ SỐ SINH HIỆU TIỀN THỦ THUẬT -->
<div id="vitalsModal" class="modal-overlay" onclick="handleBackdropClick(event)">
    <div class="modal-dialog-custom">
        <div class="modal-header-custom">
            <div style="display: flex; align-items: center; gap: 10px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                <h3 style="margin: 0; font-size: 17px; font-weight: 700;">Đo Dấu Hiệu Sinh Tồn Tiền Thủ Thuật</h3>
            </div>
            <button type="button" onclick="closeVitalsModal()" style="background: none; border: none; color: white; font-size: 22px; cursor: pointer; line-height: 1;">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/assistant/vitals/save" method="POST">
            <input type="hidden" id="modalVisitId" name="visitId" value="" />
            <input type="hidden" id="modalPatientId" name="patientId" value="" />

            <div class="modal-body-custom">
                <!-- Patient Context Banner -->
                <div style="background: #f0f7fd; border: 1px solid #bae6fd; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px;">
                    <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 15px;" id="modalPatientName">
                        Bệnh nhân: 
                    </div>
                    <div style="font-size: 12.5px; color: #0284c7; margin-top: 2px;" id="modalPatientMeta">
                        Lượt khám: 
                    </div>
                </div>

                <!-- Vitals Inputs Grid -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div class="form-group">
                        <label class="form-label" style="font-weight: 600;">Huyết Áp (mmHg) *</label>
                        <input type="text" id="modalBloodPressure" name="bloodPressure" placeholder="VD: 120/80" class="form-control" required />
                        <span style="font-size: 11px; color: var(--text-muted); margin-top: 4px; display: block;">Ngưỡng an toàn: &lt; 140/90 mmHg</span>
                    </div>

                    <div class="form-group">
                        <label class="form-label" style="font-weight: 600;">Mạch / Nhịp Tim (bpm)</label>
                        <input type="number" id="modalPulseRate" name="pulseRate" placeholder="VD: 75" class="form-control" min="40" max="200" />
                        <span style="font-size: 11px; color: var(--text-muted); margin-top: 4px; display: block;">Bình thường: 60 - 100 lần/phút</span>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <div class="form-group">
                        <label class="form-label" style="font-weight: 600;">Đường Huyết (mmol/L)</label>
                        <input type="text" id="modalBloodSugar" name="bloodSugar" placeholder="VD: 5.6" class="form-control" />
                        <span style="font-size: 11px; color: var(--text-muted); margin-top: 4px; display: block;">Đặc biệt lưu ý trước nhổ răng</span>
                    </div>

                    <div class="form-group">
                        <label class="form-label" style="font-weight: 600;">Nguy Cơ Chảy Máu</label>
                        <select id="modalBleedingRisk" name="bleedingRisk" class="form-control">
                            <option value="Bình thường">Bình thường (Low Risk)</option>
                            <option value="Thấp">Thấp</option>
                            <option value="Trung bình">Trung bình (Theo dõi)</option>
                            <option value="Cao">Cao (Thận trọng can thiệp)</option>
                        </select>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 600;">Mức Độ Lo Lắng / Căng Thẳng</label>
                    <select id="modalAnxietyLevel" name="anxietyLevel" class="form-control">
                        <option value="Thấp">Thấp (Tâm lý ổn định, hợp tác)</option>
                        <option value="Vừa">Vừa (Hơi lo âu, cần trấn an)</option>
                        <option value="Rất sợ">Rất sợ (Sợ đau, cần tiền mê / gây tê nhẹ nhàng)</option>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 600;">Ghi Chú Lâm Sàng & Tiền Sử Dùng Thuốc</label>
                    <textarea id="modalNotes" name="notes" rows="2" class="form-control" placeholder="Ghi nhận thuốc chống đông, dị ứng, thuốc gây tê hoặc lưu ý y tá dặn dò..."></textarea>
                </div>

                <div style="background: #f8fafc; border: 1px solid var(--border); border-radius: 8px; padding: 12px 16px; display: flex; align-items: center; gap: 10px;">
                    <input type="checkbox" id="modalMedicalClearance" name="medicalClearance" value="true" checked style="width: 18px; height: 18px; cursor: pointer;" />
                    <label for="modalMedicalClearance" style="font-weight: 600; font-size: 13.5px; color: var(--text-primary); cursor: pointer; margin: 0;">
                        Xác nhận đủ điều kiện an toàn sinh hiệu để bác sĩ thực hiện can thiệp thủ thuật tại ghế
                    </label>
                </div>
            </div>

            <div class="modal-footer-custom">
                <button type="button" class="btn btn-outline" onclick="closeVitalsModal()">Đóng</button>
                <button type="submit" class="btn btn-primary" style="padding: 9px 20px;">Lưu Chỉ Số Sinh Hiệu</button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=1.0"></script>
<script>
    function openVitalsModal(visitId, patientId, patientName, patientPhone, bp, pulse, sugar, bleeding, anxiety, clearance, notes) {
        document.getElementById('modalVisitId').value = visitId;
        document.getElementById('modalPatientId').value = patientId;
        document.getElementById('modalPatientName').textContent = 'Bệnh nhân: ' + patientName;
        document.getElementById('modalPatientMeta').textContent = 'Mã lượt: #BK-' + visitId + ' • SĐT: ' + (patientPhone || 'Chưa cập nhật');
        document.getElementById('modalBloodPressure').value = bp || '';
        document.getElementById('modalPulseRate').value = pulse || '';
        document.getElementById('modalBloodSugar').value = sugar || '';
        if (bleeding) document.getElementById('modalBleedingRisk').value = bleeding;
        if (anxiety) document.getElementById('modalAnxietyLevel').value = anxiety;
        document.getElementById('modalMedicalClearance').checked = (clearance === 'true' || clearance === true);
        document.getElementById('modalNotes').value = notes || '';

        document.getElementById('vitalsModal').classList.add('show');
    }

    function closeVitalsModal() {
        document.getElementById('vitalsModal').classList.remove('show');
    }

    function handleBackdropClick(e) {
        if (e.target.id === 'vitalsModal') {
            closeVitalsModal();
        }
    }
</script>

</body>
</html>
