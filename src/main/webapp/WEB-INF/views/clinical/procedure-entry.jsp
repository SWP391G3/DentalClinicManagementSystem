<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activeMenu" value="dentist_queue" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Hiện Thủ Thuật Tại Ghế — ${patient.fullName} | DCMS Dr.Smile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.2">
    <style>
        .chairside-header {
            background: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid rgba(0, 51, 102, 0.08);
            box-shadow: 0 4px 16px rgba(0, 51, 102, 0.04);
            padding: 20px 24px;
            margin-bottom: 24px;
        }

        .meta-strip {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-top: 14px;
            padding-top: 14px;
            border-top: 1px solid #f1f5f9;
        }

        .meta-strip-label {
            font-size: 11.5px;
            color: var(--text-secondary);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 2px;
        }

        .meta-strip-val {
            font-size: 14px;
            color: var(--drsmile-navy);
            font-weight: 700;
        }

        .chairside-card {
            background: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid rgba(0, 51, 102, 0.08);
            box-shadow: 0 4px 16px rgba(0, 51, 102, 0.04);
            padding: 22px;
            margin-bottom: 24px;
        }

        .plan-import-strip {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            padding: 16px 20px;
            margin-bottom: 24px;
        }

        .tooth-tag {
            background: #f1f5f9;
            color: #1e293b;
            font-weight: 700;
            font-family: 'Inter', monospace;
            padding: 2px 7px;
            border-radius: 5px;
            font-size: 11.5px;
            border: 1px solid #cbd5e1;
            white-space: nowrap !important;
        }

        .material-chip {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 3px 8px;
            font-size: 11px;
            color: #475569;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            margin: 2px 4px 2px 0;
        }

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
            max-width: 600px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            animation: modalPop 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes modalPop {
            0% { transform: scale(0.95); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>

<div class="app-shell">
    <jsp:include page="../layout/sidebar.jsp" />

    <div class="app-main">
        <jsp:include page="../layout/header.jsp" />

        <main class="page-content">
            <!-- Breadcrumb Navigation -->
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
                <a href="${pageContext.request.contextPath}/dentist/queue" style="color: var(--drsmile-blue); text-decoration: none; font-size: 13.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="19" y1="12" x2="5" y2="12"></line>
                        <polyline points="12 19 5 12 12 5"></polyline>
                    </svg>
                    Quay lại hàng đợi ghế khám
                </a>

                <div style="display: flex; gap: 10px; align-items: center;">
                    <a href="${pageContext.request.contextPath}/prescription/form?visitId=${visit.visitId}" class="btn btn-outline" style="font-weight: 700; color: var(--drsmile-navy); border-color: var(--drsmile-navy); text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="16" y1="13" x2="8" y2="13"></line>
                            <line x1="16" y1="17" x2="8" y2="17"></line>
                        </svg>
                        Kê Đơn Thuốc (UC27)
                    </a>
                    <button type="button" class="btn btn-drsmile" onclick="openRecordModal()" style="font-weight: 700;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;">
                            <line x1="12" y1="5" x2="12" y2="19"></line>
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
                        Thực Hiện Thủ Thuật Mới (UC24)
                    </button>
                </div>
            </div>

            <!-- Feedback banners -->
            <c:if test="${not empty param.msg}">
                <div class="alert-banner alert-banner-success" style="margin-bottom: 20px; padding: 12px 16px;">
                    <span class="alert-banner-icon">✓</span>
                    <div>
                        <c:choose>
                            <c:when test="${param.msg eq 'procedure_recorded'}">Đã ghi nhận thủ thuật thực hiện tại ghế thành công! Bản ghi đã sẵn sàng để lập hóa đơn viện phí.</c:when>
                            <c:when test="${param.msg eq 'procedure_completed'}">Đã cập nhật trạng thái hoàn thành thủ thuật.</c:when>
                            <c:when test="${param.msg eq 'material_added'}">Đã ghi nhận vật tư y tế tiêu hao thành công (UC26).</c:when>
                            <c:when test="${param.msg eq 'material_deleted'}">Đã xóa vật tư tiêu hao khỏi danh mục thủ thuật.</c:when>
                            <c:otherwise>Thao tác thành công.</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="alert-banner alert-banner-danger" style="margin-bottom: 20px; padding: 12px 16px;">
                    <span class="alert-banner-icon">!</span>
                    <div>${param.error}</div>
                </div>
            </c:if>

            <!-- Chairside Header: Visit & Patient Context -->
            <div class="chairside-header">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                            <span style="font-family: 'Inter', monospace; font-weight: 800; color: var(--drsmile-blue); background: #f0f7fd; padding: 2px 8px; border-radius: 6px; font-size: 13px;">
                                Buổi Khám #BK-${visit.visitId}
                            </span>
                            <span class="status-pill status-pill-success" style="font-size: 12px;">
                                ${visit.status}
                            </span>
                            <span style="background: #e0f2fe; color: #0369a1; font-weight: 700; padding: 2px 8px; border-radius: 6px; font-size: 12px;">
                                ${visit.operatory != null ? visit.operatory : 'Ghế 1 - P.101'}
                            </span>
                        </div>
                        <h2 style="font-size: 21px; font-weight: 800; color: var(--drsmile-navy); margin: 0;">
                            Bệnh Nhân: ${patient.fullName}
                        </h2>
                    </div>

                    <div style="text-align: right;">
                        <div style="font-size: 12px; color: var(--text-secondary);">Bác Sĩ Phụ Trách Ghế</div>
                        <div style="font-size: 15px; font-weight: 800; color: var(--drsmile-navy);">
                            ${dentist.fullName}
                        </div>
                        <div style="font-size: 12px; color: var(--drsmile-blue); font-weight: 600;">
                            ${dentist.specialization}
                        </div>
                    </div>
                </div>

                <div class="meta-strip">
                    <div>
                        <div class="meta-strip-label">Số Điện Thoại</div>
                        <div class="meta-strip-val">${patient.phone}</div>
                    </div>
                    <div>
                        <div class="meta-strip-label">Giới Tính / Ngày Sinh</div>
                        <div class="meta-strip-val">${patient.gender} &bull; ${patient.dob}</div>
                    </div>
                    <div>
                        <div class="meta-strip-label">Loại Buổi Khám</div>
                        <div class="meta-strip-val">${visit.visitType}</div>
                    </div>
                    <div>
                        <div class="meta-strip-label">Lý Do / Triệu Chứng</div>
                        <div class="meta-strip-val" style="font-size: 13px; font-weight: 600;">
                            ${visit.notes != null ? visit.notes : 'Khám & Điều trị tại ghế'}
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pre-Treatment Vitals & Clinical Clearance Banner (From Dental Assistant) -->
            <div style="background: #ffffff; border: 1px solid var(--border); border-left: 4px solid ${empty assessment ? '#f59e0b' : (assessment.medicalClearance ? '#10b981' : '#ef4444')}; border-radius: var(--radius-lg); padding: 16px 20px; margin-bottom: 24px; box-shadow: var(--shadow-sm);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; flex-wrap: wrap; gap: 8px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="${empty assessment ? '#d97706' : (assessment.medicalClearance ? '#16a34a' : '#dc2626')}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
                        </svg>
                        <span style="font-weight: 700; font-size: 14px; color: var(--drsmile-navy);">
                            Dấu Hiệu Sinh Tồn & An Toàn Tiền Thủ Thuật (Y Tá Nha Khoa Tiếp Nhận)
                        </span>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${not empty assessment}">
                                <span class="status-pill ${assessment.medicalClearance ? 'status-pill-success' : 'status-pill-danger'}" style="font-size: 11.5px;">
                                    ${assessment.medicalClearance ? '✓ Đủ điều kiện can thiệp thủ thuật' : '⚠ Tạm hoãn can thiệp'}
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-pill status-pill-warning" style="font-size: 11.5px;">
                                    Chưa ghi nhận sinh hiệu
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not empty assessment}">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; font-size: 13px; color: var(--text-secondary); background: #f8fafc; padding: 12px 16px; border-radius: 8px;">
                            <div>Huyết áp: <strong style="color: var(--text-primary);">${empty assessment.bloodPressure ? '--' : assessment.bloodPressure} mmHg</strong></div>
                            <div>Mạch: <strong style="color: var(--text-primary);">${empty assessment.pulseRate ? '--' : assessment.pulseRate} bpm</strong></div>
                            <c:if test="${not empty assessment.bloodSugar}">
                                <div>Đường huyết: <strong style="color: var(--text-primary);">${assessment.bloodSugar} mmol/L</strong></div>
                            </c:if>
                            <div>Nguy cơ chảy máu: <strong style="color: ${assessment.bleedingRisk eq 'High' ? '#dc2626' : 'var(--text-primary)'};">${assessment.bleedingRisk}</strong></div>
                            <c:if test="${not empty assessment.notes}">
                                <div style="grid-column: 1 / -1; margin-top: 4px; font-style: italic; color: #475569;">
                                    Ghi chú y tá: "${assessment.notes}"
                                </div>
                            </c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="font-size: 13px; color: var(--text-muted);">
                            Chưa có dữ liệu sinh tồn từ y tá nha khoa. Bác sĩ cần lưu ý kiểm tra thể trạng bệnh nhân trước khi thực hiện các thủ thuật can thiệp tại ghế.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Import From Accepted Treatment Plan Items (Iron Rule 2) -->
            <c:if test="${not empty pendingPlanItems}">
                <div class="plan-import-strip">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                <polyline points="14 2 14 8 20 8"></polyline>
                                <line x1="16" y1="13" x2="8" y2="13"></line>
                                <line x1="16" y1="17" x2="8" y2="17"></line>
                                <polyline points="10 9 9 9 8 9"></polyline>
                            </svg>
                            <span style="font-weight: 800; color: #166534; font-size: 14px; text-transform: uppercase;">
                                Các Thủ Thuật Đã Được Bệnh Nhân Duyệt Trong Kế Hoạch (Sẵn Sàng Thực Hiện)
                            </span>
                        </div>
                        <span style="font-size: 12px; color: #15803d; font-weight: 600;">
                            ${pendingPlanItems.size()} hạng mục chờ thực hiện
                        </span>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 12px;">
                        <c:forEach var="item" items="${pendingPlanItems}">
                            <div style="background: #ffffff; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                        <span style="font-size: 11px; font-weight: 700; color: #0369a1; background: #e0f2fe; padding: 1px 6px; border-radius: 4px;">
                                            Buổi ${item.priorityOrder}
                                        </span>
                                        <c:if test="${not empty item.toothNumber and item.toothNumber > 0}">
                                            <span class="tooth-tag">Răng #${item.toothNumber}</span>
                                        </c:if>
                                    </div>
                                    <div style="font-weight: 700; font-size: 13px; color: var(--drsmile-navy);">
                                        ${item.serviceName}
                                    </div>
                                    <div style="font-size: 12px; color: #15803d; font-weight: 700; margin-top: 2px;">
                                        ${item.formattedUnitPrice} &bull; SL: ${item.quantity}
                                    </div>
                                </div>
                                <button type="button" class="btn btn-secondary" style="margin-top: 10px; font-size: 12px; font-weight: 700; color: #166534; border-color: #86efac; background: #f0fdf4;"
                                        onclick="prefillFromPlanItem('${item.itemId}', '${item.serviceId}', '${item.toothNumber != null ? item.toothNumber : ''}', '${item.surface}', '${item.quantity}', '${item.unitPrice}')">
                                    Thực Hiện Tại Ghế
                                </button>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <!-- Table of Procedures Performed in this visit (UC24, UC25, UC26) -->
            <div class="chairside-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h3 style="font-size: 17px; font-weight: 800; color: var(--drsmile-navy); margin: 0;">
                            Nhật Ký Thủ Thuật Đã Thực Hiện Tại Ghế Trong Buổi Khám Này (UC24)
                        </h3>
                        <div style="font-size: 12.5px; color: var(--text-secondary); margin-top: 2px;">
                            Căn cứ duy nhất để Thu Ngân lập hóa đơn viện phí (Iron Rule 3). Tổng cộng: <strong>${procedures.size()}</strong> thủ thuật.
                        </div>
                    </div>

                    <button type="button" class="btn btn-secondary" onclick="openRecordModal()" style="font-size: 13px; font-weight: 700;">
                        + Thêm Thủ Thuật
                    </button>
                </div>

                <c:choose>
                    <c:when test="${empty procedures}">
                        <div style="text-align: center; padding: 40px 20px; background: #f8fafc; border-radius: 12px; border: 1px dashed #cbd5e1;">
                            <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 15px; margin-bottom: 4px;">
                                Chưa có thủ thuật nào được ghi nhận tại ghế trong buổi khám này
                            </div>
                            <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;">
                                Nhấn nút bên dưới để chọn thủ thuật đã làm thực tế hoặc chọn từ danh sách kế hoạch điều trị đã duyệt ở trên.
                            </p>
                            <button type="button" class="btn btn-drsmile" onclick="openRecordModal()">
                                + Ghi Nhận Thủ Thuật Đầu Tiên
                            </button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x: auto;">
                            <table class="dcms-table" style="width: 100%;">
                                <thead>
                                    <tr>
                                        <th style="width: 7%;">Mã TT</th>
                                        <th style="width: 25%;">Thủ Thuật Nha Khoa</th>
                                        <th style="width: 15%;">Vị Trí Răng (FDI)</th>
                                        <th style="width: 6%; text-align: center;">SL</th>
                                        <th style="width: 12%; text-align: right;">Đơn Giá</th>
                                        <th style="width: 12%; text-align: right;">Thành Tiền</th>
                                        <th style="width: 11%; text-align: center;">Trạng Thái</th>
                                        <th style="width: 12%; text-align: center;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="proc" items="${procedures}">
                                        <tr>
                                            <td style="font-family: 'Inter', monospace; font-weight: 700; color: var(--drsmile-blue);">
                                                #TT-${proc.procedureId}
                                            </td>
                                            <td>
                                                <div style="font-weight: 700; color: var(--drsmile-navy); font-size: 13.5px;">
                                                    ${proc.serviceName}
                                                </div>
                                                <div style="font-size: 11px; color: var(--text-secondary); font-family: 'Inter', monospace;">
                                                    ${proc.serviceCode} &bull; ${proc.serviceUnit} &bull; BS: ${proc.dentistName}
                                                </div>
                                                <c:if test="${not empty proc.clinicalNotes}">
                                                    <div style="font-size: 11.5px; color: #475569; font-style: italic; margin-top: 2px;">
                                                        Ghi chú: ${proc.clinicalNotes}
                                                    </div>
                                                </c:if>

                                                <!-- Materials Used Tags -->
                                                <div style="margin-top: 6px;">
                                                    <c:forEach var="mat" items="${proc.materials}">
                                                        <span class="material-chip">
                                                            <span>&bull;</span>
                                                            <strong>${mat.materialName}</strong>: ${mat.quantity} ${mat.unit}
                                                        </span>
                                                    </c:forEach>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty proc.toothNumber and proc.toothNumber > 0}">
                                                        <span class="tooth-tag">Răng #${proc.toothNumber}</span>
                                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 2px;">
                                                            Mặt: ${proc.surface}
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size: 12px; color: var(--text-secondary); font-style: italic;">
                                                            Toàn hàm / Chung
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center; font-weight: 700;">
                                                ${proc.quantity}
                                            </td>
                                            <td style="text-align: right; font-size: 13px; color: var(--text-secondary);">
                                                ${proc.formattedPrice}
                                            </td>
                                            <td style="text-align: right; font-weight: 800; color: var(--drsmile-navy); font-size: 13.5px;">
                                                ${proc.formattedSubTotal}
                                            </td>
                                            <td style="text-align: center;">
                                                <span class="status-pill ${proc.statusBadgeClass}" style="font-size: 11px; padding: 2px 8px;">
                                                    ${proc.statusDisplayName}
                                                </span>
                                            </td>
                                            <td style="text-align: center;">
                                                <div style="display: flex; gap: 6px; justify-content: center;">
                                                    <button type="button" class="btn btn-secondary" style="font-size: 11.5px; padding: 3px 8px;"
                                                            onclick="openMaterialModal('${proc.procedureId}', '${proc.serviceName}')"
                                                            title="Ghi nhận vật tư tiêu hao (UC26)">
                                                        + Vật Tư
                                                    </button>
                                                    <c:if test="${proc.status eq 'InProgress'}">
                                                        <form action="${pageContext.request.contextPath}/clinical/procedure/complete" method="POST" style="margin: 0;">
                                                            <input type="hidden" name="procedureId" value="${proc.procedureId}">
                                                            <input type="hidden" name="visitId" value="${visit.visitId}">
                                                            <button type="submit" class="btn btn-drsmile" style="font-size: 11.5px; padding: 3px 8px;" title="Xác nhận hoàn tất thủ thuật">
                                                                Hoàn Tất
                                                            </button>
                                                        </form>
                                                    </c:if>
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
        </main>
    </div>
</div>

<!-- Modal: Ghi Nhận Thủ Thuật Thực Hiện Tại Ghế (UC24) -->
<div id="recordModal" class="modal-overlay">
    <div class="modal-dialog-custom">
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 18px 24px; border-bottom: 1px solid #e2e8f0;">
            <div style="display: flex; align-items: center; gap: 8px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--drsmile-blue)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polyline points="12 6 12 12 14 14"></polyline>
                </svg>
                <h3 style="font-size: 17px; font-weight: 800; color: var(--drsmile-navy); margin: 0;">
                    Thực Hiện Thủ Thuật Tại Ghế (UC24)
                </h3>
            </div>
            <button type="button" onclick="closeRecordModal()" style="background: none; border: none; font-size: 22px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/clinical/procedure/record" method="POST" style="padding: 24px;">
            <input type="hidden" name="visitId" value="${visit.visitId}">
            <input type="hidden" id="planItemId" name="planItemId" value="">

            <div class="form-group" style="margin-bottom: 16px;">
                <label for="serviceId" class="form-label required">Thủ Thuật / Dịch Vụ Nha Khoa</label>
                <select id="serviceId" name="serviceId" class="form-control" required onchange="handleProcServiceChange(this)">
                    <option value="">-- Chọn dịch vụ từ biểu phí Dr.Smile --</option>
                    <c:forEach var="svc" items="${activeServices}">
                        <option value="${svc.serviceId}" data-price="${svc.price}" data-unit="${svc.unit}">
                            [${svc.serviceCode}] ${svc.serviceName} — ${svc.formattedPrice} / ${svc.unit}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                <div class="form-group">
                    <label for="toothNumber" class="form-label">Răng Can Thiệp (FDI 11–48)</label>
                    <select id="toothNumber" name="toothNumber" class="form-control">
                        <option value="">-- Toàn hàm / Không áp dụng --</option>
                        <optgroup label="Hàm Trên - Bên Phải (Cung 1: 11 - 18)">
                            <option value="18">Răng 18 (Răng khôn trên phải)</option>
                            <option value="17">Răng 17 (Răng hàm lớn 2)</option>
                            <option value="16">Răng 16 (Răng hàm lớn 1)</option>
                            <option value="15">Răng 15 (Răng hàm nhỏ 2)</option>
                            <option value="14">Răng 14 (Răng hàm nhỏ 1)</option>
                            <option value="13">Răng 13 (Răng nanh trên phải)</option>
                            <option value="12">Răng 12 (Răng cửa bên)</option>
                            <option value="11">Răng 11 (Răng cửa giữa trên phải)</option>
                        </optgroup>
                        <optgroup label="Hàm Trên - Bên Trái (Cung 2: 21 - 28)">
                            <option value="21">Răng 21 (Răng cửa giữa trên trái)</option>
                            <option value="22">Răng 22 (Răng cửa bên)</option>
                            <option value="23">Răng 23 (Răng nanh trên trái)</option>
                            <option value="24">Răng 24 (Răng hàm nhỏ 1)</option>
                            <option value="25">Răng 25 (Răng hàm nhỏ 2)</option>
                            <option value="26">Răng 26 (Răng hàm lớn 1)</option>
                            <option value="27">Răng 27 (Răng hàm lớn 2)</option>
                            <option value="28">Răng 28 (Răng khôn trên trái)</option>
                        </optgroup>
                        <optgroup label="Hàm Dưới - Bên Trái (Cung 3: 31 - 38)">
                            <option value="31">Răng 31 (Răng cửa giữa dưới trái)</option>
                            <option value="32">Răng 32 (Răng cửa bên)</option>
                            <option value="33">Răng 33 (Răng nanh dưới trái)</option>
                            <option value="34">Răng 34 (Răng hàm nhỏ 1)</option>
                            <option value="35">Răng 35 (Răng hàm nhỏ 2)</option>
                            <option value="36">Răng 36 (Răng hàm lớn 1)</option>
                            <option value="37">Răng 37 (Răng hàm lớn 2)</option>
                            <option value="38">Răng 38 (Răng khôn dưới trái)</option>
                        </optgroup>
                        <optgroup label="Hàm Dưới - Bên Phải (Cung 4: 41 - 48)">
                            <option value="41">Răng 41 (Răng cửa giữa dưới phải)</option>
                            <option value="42">Răng 42 (Răng cửa bên)</option>
                            <option value="43">Răng 43 (Răng nanh dưới phải)</option>
                            <option value="44">Răng 44 (Răng hàm nhỏ 1)</option>
                            <option value="45">Răng 45 (Răng hàm nhỏ 2)</option>
                            <option value="46">Răng 46 (Răng hàm lớn 1)</option>
                            <option value="47">Răng 47 (Răng hàm lớn 2)</option>
                            <option value="48">Răng 48 (Răng khôn dưới phải)</option>
                        </optgroup>
                    </select>
                </div>

                <div class="form-group">
                    <label for="surface" class="form-label">Mặt Răng Lâm Sàng</label>
                    <select id="surface" name="surface" class="form-control">
                        <option value="WholeTooth">Toàn thân răng (WholeTooth)</option>
                        <option value="Occlusal">Mặt nhai (Occlusal - O)</option>
                        <option value="Mesial">Mặt gần (Mesial - M)</option>
                        <option value="Distal">Mặt xa (Distal - D)</option>
                        <option value="Buccal">Mặt ngoài / Má (Buccal - B)</option>
                        <option value="Lingual">Mặt trong / Lưỡi (Lingual - L)</option>
                    </select>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                <div class="form-group">
                    <label for="quantity" class="form-label required">Số Lượng</label>
                    <input type="number" id="quantity" name="quantity" class="form-control" value="1" min="1" max="32" required />
                </div>
                <div class="form-group">
                    <label for="actualPrice" class="form-label required">Đơn Giá Thực Tế (VNĐ)</label>
                    <input type="number" id="actualPrice" name="actualPrice" class="form-control" min="0" step="1000" required />
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 20px;">
                <label for="clinicalNotes" class="form-label">Ghi Chú Tiến Trình Lâm Sàng (UC18)</label>
                <textarea id="clinicalNotes" name="clinicalNotes" class="form-control" rows="2"
                          placeholder="Mô tả kỹ thuật can thiệp, phản ứng bệnh nhân hoặc dặn dò sau thủ thuật..."></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeRecordModal()">Đóng</button>
                <button type="submit" class="btn btn-drsmile" style="font-weight: 700;">
                    Lưu &amp; Hoàn Tất Thủ Thuật
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Ghi Nhận Vật Tư Tiêu Hao (UC26) -->
<div id="materialModal" class="modal-overlay">
    <div class="modal-dialog-custom" style="max-width: 480px;">
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 18px 20px; border-bottom: 1px solid #e2e8f0;">
            <h3 style="font-size: 16px; font-weight: 800; color: var(--drsmile-navy); margin: 0;" id="matModalTitle">
                Ghi Nhận Vật Tư Tiêu Hao (UC26)
            </h3>
            <button type="button" onclick="closeMaterialModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #94a3b8;">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/clinical/material/add" method="POST" style="padding: 20px;">
            <input type="hidden" name="visitId" value="${visit.visitId}">
            <input type="hidden" id="matProcedureId" name="procedureId" value="">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label required">Chọn Nhanh Vật Tư Tiêu Hao</label>
                <div style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 8px;">
                    <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 2px 7px;" onclick="setMaterialPreset('Thuốc tê Lidocaine 2%', 'Ống')">Lidocaine 2%</button>
                    <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 2px 7px;" onclick="setMaterialPreset('Chỉ khâu Vicryl 4.0', 'Tép')">Chỉ Vicryl 4.0</button>
                    <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 2px 7px;" onclick="setMaterialPreset('Composite 3M Filtek Z250', 'Tuýp')">Composite 3M</button>
                    <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 2px 7px;" onclick="setMaterialPreset('NaOCl 3% bơm rửa tủy', 'Ống')">Bơm rửa NaOCl</button>
                </div>
                <input type="text" id="materialName" name="materialName" class="form-control" required placeholder="Nhập tên vật tư, thuốc tê, chỉ phẫu thuật..." />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                <div class="form-group">
                    <label for="matQty" class="form-label required">Số Lượng</label>
                    <input type="number" id="matQty" name="quantity" class="form-control" value="1" min="1" required />
                </div>
                <div class="form-group">
                    <label for="matUnit" class="form-label">Đơn Vị Tính</label>
                    <select id="matUnit" name="unit" class="form-control">
                        <option value="Ống">Ống</option>
                        <option value="Tép">Tép</option>
                        <option value="Tuýp">Tuýp</option>
                        <option value="Cái">Cái</option>
                        <option value="Gói">Gói</option>
                        <option value="Hộp">Hộp</option>
                    </select>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 18px;">
                <label for="matNotes" class="form-label">Ghi Chú Sử Dụng</label>
                <input type="text" id="matNotes" name="notes" class="form-control" placeholder="Ghi chú chi tiết nếu có..." />
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn btn-secondary" onclick="closeMaterialModal()">Hủy</button>
                <button type="submit" class="btn btn-drsmile">Lưu Vật Tư</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openRecordModal() {
        document.getElementById('planItemId').value = '';
        document.getElementById('recordModal').classList.add('show');
    }
    function closeRecordModal() {
        document.getElementById('recordModal').classList.remove('show');
    }

    function openMaterialModal(procId, procName) {
        document.getElementById('matProcedureId').value = procId;
        document.getElementById('matModalTitle').innerText = 'Ghi Nhận Vật Tư — ' + procName;
        document.getElementById('materialModal').classList.add('show');
    }
    function closeMaterialModal() {
        document.getElementById('materialModal').classList.remove('show');
    }

    function setMaterialPreset(name, unit) {
        document.getElementById('materialName').value = name;
        document.getElementById('matUnit').value = unit;
    }

    function handleProcServiceChange(selectEl) {
        const selectedOpt = selectEl.options[selectEl.selectedIndex];
        const price = selectedOpt.getAttribute('data-price');
        if (price) {
            document.getElementById('actualPrice').value = price;
        }
    }

    function prefillFromPlanItem(itemId, serviceId, toothNumber, surface, quantity, price) {
        document.getElementById('planItemId').value = itemId;
        document.getElementById('serviceId').value = serviceId;
        if (toothNumber) {
            document.getElementById('toothNumber').value = toothNumber;
        }
        if (surface) {
            document.getElementById('surface').value = surface;
        }
        document.getElementById('quantity').value = quantity;
        document.getElementById('actualPrice').value = price;
        document.getElementById('recordModal').classList.add('show');
    }

    // Close on Escape key
    window.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeRecordModal();
            closeMaterialModal();
        }
    });
</script>

</body>
</html>
