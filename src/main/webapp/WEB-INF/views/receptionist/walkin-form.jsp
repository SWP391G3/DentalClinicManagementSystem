<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="walkin" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiếp Nhận Khách Vãng Lai (Walk-in) — Dr.Smile DCMS Dental Care</title>
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
                <a href="${pageContext.request.contextPath}/reception/checkin">Tiếp Đón & Check-in</a>
                <span class="breadcrumb-separator">/</span>
                <span>Tiếp Nhận Khách Vãng Lai</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>Tiếp Nhận Khách Vãng Lai (Walk-in)</h1>
                    <p>Khách đến trực tiếp phòng khám không hẹn trước &bull; Sinh trực tiếp Lượt khám (Visit) theo Nguyên tắc Thép số 1</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/reception/checkin" class="btn btn-secondary">
                        <span>←</span> Quay Lại Quầy Tiếp Đón
                    </a>
                </div>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="alert-banner alert-banner-danger">
                    <span class="alert-banner-icon">!</span>
                    <div><strong>Lỗi tiếp nhận:</strong> ${errorMessage}</div>
                </div>
            </c:if>

            <!-- Form Card -->
            <div class="form-card">
                <div class="form-card-header">
                    <h2>Thông Tin Lượt Khám Vãng Lai</h2>
                    <p>Vui lòng tìm kiếm hồ sơ bệnh nhân có sẵn hoặc tạo mới trước khi tiếp nhận vào ghế khám</p>
                </div>

                <form action="${pageContext.request.contextPath}/reception/walkin" method="POST">
                    <div class="form-card-body">
                        <!-- Hidden Patient ID -->
                        <input type="hidden" id="patientId" name="patientId" value="${selectedPatient != null ? selectedPatient.patientId : ''}" required />

                        <!-- Form Grid -->
                        <div class="form-grid">
                            <!-- Patient Search -->
                            <div class="form-group form-group-full search-autocomplete-box">
                                <label for="patientSearch" class="form-label required">Tìm Kiếm Bệnh Nhân</label>
                                <div style="display:flex; gap:10px;">
                                    <input type="text" 
                                           id="patientSearch" 
                                           class="form-control" 
                                           placeholder="Gõ số điện thoại hoặc họ tên bệnh nhân..." 
                                           autocomplete="off"
                                           value="${selectedPatient != null ? selectedPatient.fullName : ''}" />
                                    <a href="${pageContext.request.contextPath}/reception/patients/create" class="btn btn-secondary" style="flex-shrink:0;">
                                        + Tạo Hồ Sơ Mới
                                    </a>
                                </div>
                                <div id="searchResults" class="search-results-floating"></div>

                                <div id="selectedPatientBadge" class="selected-patient-chip" style="${selectedPatient != null ? '' : 'display:none;'}">
                                    <span>Đã chọn: <strong id="selectedPatientName">${selectedPatient.fullName}</strong> — SĐT: <strong id="selectedPatientPhone">${selectedPatient.phone}</strong></span>
                                </div>
                            </div>

                            <!-- Doctor Selection -->
                            <div class="form-group">
                                <label for="dentistId" class="form-label required">Bác Sĩ Tiếp Nhận</label>
                                <select id="dentistId" name="dentistId" class="form-control" required>
                                    <option value="">-- Chọn bác sĩ trực ca tại phòng khám --</option>
                                    <c:forEach var="d" items="${dentists}">
                                        <option value="${d.dentistId}">
                                            ${d.fullName} — ${d.specialization} (${d.roomNumber != null ? d.roomNumber : 'Ghế khám'})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Visit Type -->
                            <div class="form-group">
                                <label for="visitType" class="form-label required">Loại Tiếp Nhận</label>
                                <select id="visitType" name="visitType" class="form-control">
                                    <option value="WalkIn" selected>Khách vãng lai (Không hẹn trước)</option>
                                    <option value="Emergency">Cấp cứu nha khoa (Ưu tiên khám ngay)</option>
                                </select>
                            </div>

                            <!-- Symptoms / Notes -->
                            <div class="form-group form-group-full">
                                <label for="notes" class="form-label">Lý Do Khám & Triệu Chứng Ban Đầu</label>
                                <textarea id="notes" 
                                          name="notes" 
                                          class="form-control" 
                                          rows="3" 
                                          placeholder="Mô tả triệu chứng đau răng, sưng nướu, vị trí răng cần kiểm tra hoặc nhu cầu của khách hàng..."></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="form-card-footer">
                        <a href="${pageContext.request.contextPath}/reception/checkin" class="btn btn-secondary">
                            Hủy Bỏ
                        </a>
                        <button type="submit" class="btn btn-primary">
                            Xác Nhận Tiếp Nhận Vào Hàng Đợi
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<script>
    var searchInput = document.getElementById('patientSearch');
    var resultsBox = document.getElementById('searchResults');
    var patientIdInput = document.getElementById('patientId');
    var badgeBox = document.getElementById('selectedPatientBadge');
    var badgeName = document.getElementById('selectedPatientName');
    var badgePhone = document.getElementById('selectedPatientPhone');

    var debounceTimer;
    searchInput.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        var q = this.value.trim();
        if (q.length < 2) {
            resultsBox.style.display = 'none';
            return;
        }

        debounceTimer = setTimeout(function() {
            fetch('${pageContext.request.contextPath}/reception/patients/search-ajax?term=' + encodeURIComponent(q))
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    resultsBox.innerHTML = '';
                    if (!data || data.length === 0) {
                        resultsBox.innerHTML = '<div class="search-result-row" style="color:var(--text-muted); cursor:default;">Không tìm thấy bệnh nhân. <a href="${pageContext.request.contextPath}/reception/patients/create" style="color:var(--primary); font-weight:700; margin-left:6px;">Tạo mới hồ sơ</a></div>';
                    } else {
                        data.forEach(function(p) {
                            var item = document.createElement('div');
                            item.className = 'search-result-row';
                            item.innerHTML = '<div><strong>' + p.fullName + '</strong> <span style="color:var(--text-muted); font-size:12px;">(' + (p.gender || '') + ')</span></div>' +
                                             '<div style="color:var(--primary); font-family:monospace; font-weight:600;">' + p.phone + '</div>';
                            item.addEventListener('click', function() {
                                patientIdInput.value = p.patientId;
                                searchInput.value = p.fullName;
                                badgeName.innerText = p.fullName;
                                badgePhone.innerText = p.phone;
                                badgeBox.style.display = 'inline-flex';
                                resultsBox.style.display = 'none';
                            });
                            resultsBox.appendChild(item);
                        });
                    }
                    resultsBox.style.display = 'block';
                })
                .catch(function(err) {
                    console.error('Error fetching search results:', err);
                });
        }, 250);
    });

    document.addEventListener('click', function(e) {
        if (!searchInput.contains(e.target) && !resultsBox.contains(e.target)) {
            resultsBox.style.display = 'none';
        }
    });

    var walkinForm = document.querySelector('form[action$="/reception/walkin"]');
    if (walkinForm) {
        walkinForm.addEventListener('submit', function(e) {
            if (!patientIdInput.value || patientIdInput.value.trim() === '') {
                e.preventDefault();
                alert('Vui lòng tìm kiếm và nhấp chọn bệnh nhân từ danh sách gợi ý trước khi tiếp nhận.');
                searchInput.focus();
                return false;
            }
            var docSelect = document.getElementById('dentistId');
            if (!docSelect || !docSelect.value) {
                e.preventDefault();
                alert('Vui lòng chọn bác sĩ phụ trách ca khám cho bệnh nhân.');
                if (docSelect) docSelect.focus();
                return false;
            }
        });
    }
</script>

</body>
</html>
