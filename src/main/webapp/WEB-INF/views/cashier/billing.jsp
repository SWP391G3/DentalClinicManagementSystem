<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activeMenu" value="cashier_billing" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bàn Thu Ngân &amp; Viện Phí — DCMS Dental Care Dr.Smile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.0">
    <style>
        .cashier-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .kpi-row-cashier {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .kpi-card-cashier {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: var(--shadow-sm);
        }

        .kpi-icon-cashier {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .kpi-val-cashier {
            font-size: 20px;
            font-weight: 800;
            color: var(--drsmile-navy);
            line-height: 1.2;
        }

        .kpi-label-cashier {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            margin-top: 4px;
        }

        .filter-tabs-cashier {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
        }

        .tab-btn-cashier {
            background: none;
            border: none;
            padding: 8px 16px;
            font-size: 13.5px;
            font-weight: 600;
            color: var(--text-secondary);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all var(--transition-normal);
        }

        .tab-btn-cashier:hover {
            background: #f1f5f9;
            color: var(--drsmile-navy);
        }

        .tab-btn-cashier.active {
            background: rgba(0, 51, 102, 0.08);
            color: var(--drsmile-navy);
            font-weight: 700;
        }

        .btn-pay-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: #0284c7;
            color: #ffffff;
            font-size: 12.5px;
            font-weight: 600;
            border-radius: var(--radius-sm);
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all var(--transition-normal);
        }

        .btn-pay-action:hover {
            background: #0369a1;
            transform: translateY(-1px);
        }

        .btn-receipt-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: #ffffff;
            color: var(--drsmile-navy);
            font-size: 12.5px;
            font-weight: 600;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            cursor: pointer;
            text-decoration: none;
            transition: all var(--transition-normal);
        }

        .btn-receipt-action:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
        }

        /* Modal Dialog Styling */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-card {
            background: #ffffff;
            border-radius: var(--radius-xl);
            width: 100%;
            max-width: 520px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border: 1px solid var(--border);
            overflow: hidden;
            animation: modalFadeIn 0.2s ease-out;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.96); }
            to { opacity: 1; transform: scale(1); }
        }

        .modal-header {
            padding: 18px 24px;
            background: #f8fafc;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--drsmile-navy);
            margin: 0;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 20px;
            color: var(--text-muted);
            cursor: pointer;
            padding: 4px;
            line-height: 1;
        }

        .modal-body {
            padding: 24px;
        }

        .modal-footer {
            padding: 16px 24px;
            background: #f8fafc;
            border-top: 1px solid var(--border);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .summary-box {
            background: #f0f7fd;
            border: 1px solid #bae6fd;
            border-radius: var(--radius-md);
            padding: 14px 16px;
            margin-bottom: 20px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            margin-bottom: 6px;
        }

        .summary-row:last-child {
            margin-bottom: 0;
            padding-top: 6px;
            border-top: 1px dashed #7dd3fc;
            font-weight: 700;
        }

        .quick-amt-btn {
            padding: 5px 10px;
            font-size: 11.5px;
            font-weight: 600;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.15s;
        }

        .quick-amt-btn:hover {
            background: #e2e8f0;
            border-color: #94a3b8;
        }
    </style>
</head>
<body>

<div class="app-shell">
    <jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

    <div class="app-main">
        <header class="app-topbar">
            <div class="topbar-title">Bàn Thu Ngân &amp; Quầy Viện Phí</div>
            <div class="topbar-actions">
                <span style="font-size: 13px; color: var(--text-muted);">
                    Thu ngân: <strong><c:out value="${sessionScope.currentUser.fullName}" /></strong>
                </span>
            </div>
        </header>

        <main class="app-content">
            <div class="breadcrumb" style="margin-bottom: 12px;">
                <a href="${pageContext.request.contextPath}/">Trang Chủ</a>
                <span class="breadcrumb-separator">/</span>
                <span>Quầy Thu Ngân</span>
                <span class="breadcrumb-separator">/</span>
                <span>Bàn Thu Ngân &amp; Viện Phí</span>
            </div>

            <!-- Toast / Notifications -->
            <c:if test="${param.success eq 'payment_recorded'}">
                <div class="alert-banner alert-banner-success" style="margin-bottom: 20px; padding: 12px 16px;">
                    <span class="alert-banner-icon">✓</span>
                    <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                        <div>
                            <strong>Thanh toán thành công:</strong> Đã ghi nhận phiếu thu viện phí cho hóa đơn <strong>#${param.invoiceId}</strong>.
                        </div>
                        <c:if test="${not empty param.invoiceId}">
                            <a href="${pageContext.request.contextPath}/cashier/receipt?id=${param.invoiceId}" target="_blank" class="btn btn-secondary" style="padding: 4px 12px; font-size: 12px;">
                                In Biên Lai Ngay
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="alert-banner alert-banner-danger" style="margin-bottom: 20px; padding: 12px 16px;">
                    <span class="alert-banner-icon">!</span>
                    <div><c:out value="${param.error}" /></div>
                </div>
            </c:if>

            <div class="cashier-header">
                <div>
                    <h1 style="font-size: 22px; font-weight: 800; color: var(--drsmile-navy); margin: 0;">
                        Quầy Thu Ngân &amp; Viện Phí Phòng Khám
                    </h1>
                    <p style="font-size: 13px; color: var(--text-secondary); margin: 4px 0 0 0;">
                        Tiếp nhận thanh toán sau khi hoàn tất thủ thuật tại ghế (Iron Rule 3). Quản lý thu tiền nhiều lần và công nợ (Iron Rule 8).
                    </p>
                </div>
            </div>

            <!-- KPI Row (Current Shift Summary) -->
            <div class="kpi-row-cashier">
                <div class="kpi-card-cashier">
                    <div class="kpi-icon-cashier" style="background: rgba(16, 185, 129, 0.1); color: #059669;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                    </div>
                    <div>
                        <div class="kpi-val-cashier">${shiftSummary.formattedRevenueToday}</div>
                        <div class="kpi-label-cashier">Thực thu trong ca</div>
                    </div>
                </div>

                <div class="kpi-card-cashier">
                    <div class="kpi-icon-cashier" style="background: rgba(2, 132, 199, 0.1); color: #0284c7;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <div>
                        <div class="kpi-val-cashier">${shiftSummary.totalPaidInvoices}</div>
                        <div class="kpi-label-cashier">Phiếu thu hoàn tất</div>
                    </div>
                </div>

                <div class="kpi-card-cashier">
                    <div class="kpi-icon-cashier" style="background: rgba(245, 158, 11, 0.1); color: #d97706;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                    <div>
                        <div class="kpi-val-cashier">${shiftSummary.totalWaitingInvoices}</div>
                        <div class="kpi-label-cashier">Lượt chờ thu tiền</div>
                    </div>
                </div>

                <div class="kpi-card-cashier">
                    <div class="kpi-icon-cashier" style="background: rgba(239, 68, 68, 0.1); color: #dc2626;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1"/></svg>
                    </div>
                    <div>
                        <div class="kpi-val-cashier">${shiftSummary.formattedPendingBalance}</div>
                        <div class="kpi-label-cashier">Viện phí còn nợ</div>
                    </div>
                </div>
            </div>

            <!-- Invoices Table Card -->
            <div class="card" style="margin-bottom: 24px;">
                <div class="card-header" style="flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h3 class="card-title" style="margin: 0; font-size: 16px; color: var(--drsmile-navy);">
                            Danh Sách Hóa Đơn &amp; Lượt Thu Tiền Viện Phí
                        </h3>
                        <p style="font-size: 12.5px; color: var(--text-muted); margin: 2px 0 0 0;">
                            Hóa đơn được lập tự động từ thủ thuật đã thực tế thực hiện xong tại ghế khám.
                        </p>
                    </div>
                </div>

                <!-- Filter Tabs -->
                <div style="padding: 12px 20px 0 20px;">
                    <div class="filter-tabs-cashier">
                        <button type="button" class="tab-btn-cashier active" onclick="filterByStatus('all', this)">
                            Tất Cả Hóa Đơn
                        </button>
                        <button type="button" class="tab-btn-cashier" onclick="filterByStatus('Unpaid', this)">
                            Chưa Thanh Toán
                        </button>
                        <button type="button" class="tab-btn-cashier" onclick="filterByStatus('PartiallyPaid', this)">
                            Thu Một Phần / Trả Góp
                        </button>
                        <button type="button" class="tab-btn-cashier" onclick="filterByStatus('Paid', this)">
                            Đã Thanh Toán Đủ
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="data-table" id="cashierBillingTable" data-datatable="true" data-page-size="10">
                        <thead>
                            <tr>
                                <th style="width: 120px; text-align: center;">Mã Hóa Đơn</th>
                                <th style="width: 220px;">Bệnh Nhân</th>
                                <th style="width: 180px;">Bác Sĩ &amp; Ghế</th>
                                <th style="width: 140px; text-align: right;">Tổng Viện Phí</th>
                                <th style="width: 130px; text-align: right;">Đã Thu</th>
                                <th style="width: 140px; text-align: right;">Còn Lại</th>
                                <th style="width: 140px; text-align: center;">Trạng Thái</th>
                                <th style="width: 160px; text-align: center;" data-no-sort="true">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="inv" items="${invoices}">
                                <tr data-status="${inv.status}">
                                    <td style="text-align: center;">
                                        <span class="badge-code">${inv.invoiceCode}</span>
                                        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">
                                            #LK-${inv.visitId}
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 700; color: var(--drsmile-navy);">
                                            <c:out value="${inv.patientName}" />
                                        </div>
                                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                            SĐT: <c:out value="${inv.patientPhone}" />
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;">
                                            <c:out value="${inv.dentistName}" />
                                        </div>
                                        <div style="font-size: 12px; color: var(--text-muted);">
                                            <c:out value="${inv.operatory}" />
                                        </div>
                                    </td>
                                    <td style="text-align: right; font-weight: 700; color: var(--drsmile-navy);">
                                        ${inv.formattedFinalAmount}
                                        <c:if test="${inv.discountAmount gt 0}">
                                            <div style="font-size: 11px; color: #059669; font-weight: 500;">
                                                (Đã giảm ${inv.formattedDiscountAmount})
                                            </div>
                                        </c:if>
                                    </td>
                                    <td style="text-align: right; font-weight: 600; color: #059669;">
                                        ${inv.formattedPaidAmount}
                                    </td>
                                    <td style="text-align: right; font-weight: 700; color: ${inv.balanceAmount gt 0 ? '#dc2626' : '#059669'};">
                                        ${inv.formattedBalanceAmount}
                                    </td>
                                    <td style="text-align: center;">
                                        <span class="status-pill ${inv.statusBadgeClass}">
                                            <span class="status-dot"></span>
                                            ${inv.statusDisplayName}
                                        </span>
                                    </td>
                                    <td style="text-align: center;">
                                        <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                            <c:if test="${inv.status ne 'Paid' and inv.status ne 'Cancelled'}">
                                                <button type="button" 
                                                        class="btn-pay-action" 
                                                        onclick="openPaymentModal(${inv.invoiceId}, '${inv.invoiceCode}', '${inv.patientName}', '${inv.formattedFinalAmount}', ${inv.balanceAmount}, '${inv.formattedBalanceAmount}')">
                                                    Thu Tiền
                                                </button>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/cashier/receipt?id=${inv.invoiceId}" 
                                               target="_blank" 
                                               class="btn-receipt-action" 
                                               title="Xem và in biên lai thu tiền">
                                                Biên Lai
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Modal Thu Tiền Viện Phí Nhanh -->
<div class="modal-overlay" id="paymentModal">
    <div class="modal-card">
        <div class="modal-header">
            <h3 class="modal-title">Lập Phiếu Thu Viện Phí</h3>
            <button type="button" class="modal-close" onclick="closePaymentModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/cashier/payment" method="POST" id="paymentForm">
            <input type="hidden" name="invoiceId" id="modalInvoiceId">
            <div class="modal-body">
                <div class="summary-box">
                    <div class="summary-row">
                        <span style="color: var(--text-muted);">Mã Hóa Đơn:</span>
                        <strong id="modalInvoiceCode">#HD-...</strong>
                    </div>
                    <div class="summary-row">
                        <span style="color: var(--text-muted);">Bệnh Nhân:</span>
                        <strong id="modalPatientName">...</strong>
                    </div>
                    <div class="summary-row">
                        <span style="color: var(--text-muted);">Tổng Tiền Sau Giảm:</span>
                        <span id="modalFinalAmount">0 đ</span>
                    </div>
                    <div class="summary-row">
                        <span style="color: #dc2626;">Còn Phải Thu:</span>
                        <span id="modalBalanceAmount" style="color: #dc2626; font-size: 15px;">0 đ</span>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label required">Số Tiền Thu Lần Này (VNĐ)</label>
                    <div style="display: flex; gap: 8px; margin-bottom: 8px;">
                        <input type="number" 
                               id="modalAmountInput" 
                               name="amount" 
                               class="form-control" 
                               placeholder="Nhập số tiền thu" 
                               required 
                               min="1000" 
                               step="1000"
                               oninput="calculateChange()" />
                        <button type="button" class="quick-amt-btn" onclick="fillQuickPercent(1)">100%</button>
                        <button type="button" class="quick-amt-btn" onclick="fillQuickPercent(0.5)">50%</button>
                        <button type="button" class="quick-amt-btn" onclick="fillQuickPercent(0.3)">30%</button>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label required">Phương Thức Thanh Toán</label>
                    <select name="paymentMethod" id="modalPaymentMethod" class="form-control" onchange="toggleCashFields()">
                        <option value="Cash">Tiền mặt tại quầy</option>
                        <option value="BankTransfer">Chuyển khoản QR ngân hàng</option>
                        <option value="Card">Quẹt thẻ ngân hàng POS</option>
                    </select>
                </div>

                <!-- Tiền khách đưa & tiền thối (Chỉ hiện khi chọn tiền mặt) -->
                <div id="cashChangeSection" style="background: #f8fafc; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 12px; margin-bottom: 16px;">
                    <div class="form-group" style="margin-bottom: 8px;">
                        <label class="form-label" style="font-size: 12.5px;">Tiền Khách Đưa (VNĐ)</label>
                        <input type="number" 
                               id="modalTenderedInput" 
                               class="form-control" 
                               placeholder="VD: 500000" 
                               step="1000"
                               oninput="calculateChange()" />
                    </div>
                    <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; color: var(--drsmile-navy); padding-top: 4px;">
                        <span>Tiền Thừa Trả Lại:</span>
                        <span id="modalChangeDisplay" style="color: #059669;">0 đ</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Ghi Chú Thu Ngân (Không bắt buộc)</label>
                    <input type="text" name="notes" class="form-control" placeholder="Mã tham chiếu ngân hàng, số hóa đơn VAT..." />
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closePaymentModal()">Hủy Bỏ</button>
                <button type="submit" class="btn btn-drsmile" style="padding: 10px 20px;">
                    Xác Nhận Thu Tiền
                </button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dcms-datatable.js?v=2.1"></script>
<script>
    let rawBalance = 0;

    function openPaymentModal(invoiceId, code, patientName, finalAmt, balance, formattedBalance) {
        document.getElementById('modalInvoiceId').value = invoiceId;
        document.getElementById('modalInvoiceCode').innerText = '#' + code;
        document.getElementById('modalPatientName').innerText = patientName;
        document.getElementById('modalFinalAmount').innerText = finalAmt;
        document.getElementById('modalBalanceAmount').innerText = formattedBalance;
        
        rawBalance = balance;
        document.getElementById('modalAmountInput').value = balance;
        document.getElementById('modalAmountInput').max = balance;
        document.getElementById('modalTenderedInput').value = balance;
        
        calculateChange();
        document.getElementById('paymentModal').classList.add('active');
    }

    function closePaymentModal() {
        document.getElementById('paymentModal').classList.remove('active');
    }

    function fillQuickPercent(rate) {
        const amt = Math.round(rawBalance * rate);
        document.getElementById('modalAmountInput').value = amt;
        document.getElementById('modalTenderedInput').value = amt;
        calculateChange();
    }

    function toggleCashFields() {
        const method = document.getElementById('modalPaymentMethod').value;
        const section = document.getElementById('cashChangeSection');
        section.style.display = (method === 'Cash') ? 'block' : 'none';
    }

    function calculateChange() {
        const toPay = parseFloat(document.getElementById('modalAmountInput').value) || 0;
        const tendered = parseFloat(document.getElementById('modalTenderedInput').value) || 0;
        const change = tendered - toPay;
        
        const changeDisplay = document.getElementById('modalChangeDisplay');
        if (change >= 0) {
            changeDisplay.innerText = new Intl.NumberFormat('vi-VN').format(change) + ' đ';
            changeDisplay.style.color = '#059669';
        } else {
            changeDisplay.innerText = 'Chưa đủ tiền khách đưa';
            changeDisplay.style.color = '#dc2626';
        }
    }

    function filterByStatus(status, btn) {
        document.querySelectorAll('.tab-btn-cashier').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const rows = document.querySelectorAll('#cashierBillingTable tbody tr');
        rows.forEach(row => {
            if (status === 'all' || row.getAttribute('data-status') === status) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    // Close on overlay click
    document.getElementById('paymentModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closePaymentModal();
        }
    });
</script>

</body>
</html>
