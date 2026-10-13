<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="${isEdit ? 'patients' : 'patient_create'}" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Chỉnh Sửa' : 'Thêm Mới'} Hồ Sơ Bệnh Nhân — Dr.Smile DCMS Dental Care</title>
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
                <a href="${pageContext.request.contextPath}/reception/patients">Hồ Sơ Bệnh Nhân</a>
                <span class="breadcrumb-separator">/</span>
                <span>${isEdit ? 'Chỉnh Sửa Hồ Sơ' : 'Thêm Mới Bệnh Nhân'}</span>
            </div>

            <!-- Page Header Row -->
            <div class="page-header-row">
                <div class="page-title">
                    <h1>${isEdit ? 'Chỉnh Sửa Hồ Sơ Bệnh Nhân' : 'Tạo Hồ Sơ Bệnh Nhân Mới'}</h1>
                    <p>Nhập thông tin hành chính, tiền sử dị ứng và bệnh lý theo chuẩn quy định BF-01</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/reception/patients" class="btn btn-secondary">
                        <span>←</span> Quay Lại Danh Sách
                    </a>
                </div>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="alert-banner alert-banner-danger">
                    <span class="alert-banner-icon">!</span>
                    <div><strong>Lỗi xử lý:</strong> ${errorMessage}</div>
                </div>
            </c:if>

            <!-- Form Card -->
            <div class="form-card">
                <div class="form-card-header">
                    <h2>${isEdit ? 'Cập Nhật Thông Tin Bệnh Nhân' : 'Thông Tin Hành Chính & Y Tế'}</h2>
                    <p>Đảm bảo số điện thoại chính xác để nhận diện hồ sơ bệnh nhân khi đặt lịch hoặc thanh toán</p>
                </div>

                <form action="${pageContext.request.contextPath}/reception/patients${isEdit ? '/edit' : '/create'}" method="POST">
                    <div class="form-card-body">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="patientId" value="${patient.patientId}" />
                        </c:if>

                        <div class="form-grid">
                            <!-- Full Name -->
                            <div class="form-group">
                                <label for="fullName" class="form-label required">Họ & Tên Bệnh Nhân</label>
                                <input type="text" 
                                       id="fullName" 
                                       name="fullName" 
                                       class="form-control" 
                                       value="${patient.fullName}" 
                                       placeholder="Ví dụ: Nguyễn Văn An" 
                                       required 
                                       autofocus />
                            </div>

                            <!-- Phone -->
                            <div class="form-group">
                                <label for="phone" class="form-label required">Số Điện Thoại (10 chữ số)</label>
                                <input type="text" 
                                       id="phone" 
                                       name="phone" 
                                       class="form-control" 
                                       value="${patient.phone}" 
                                       placeholder="Ví dụ: 0988123456" 
                                       required />
                            </div>

                            <!-- Gender -->
                            <div class="form-group">
                                <label for="gender" class="form-label required">Giới Tính</label>
                                <select id="gender" name="gender" class="form-control" required>
                                    <option value="Nam" ${patient.gender eq 'Nam' ? 'selected' : ''}>Nam</option>
                                    <option value="Nữ" ${patient.gender eq 'Nữ' ? 'selected' : ''}>Nữ</option>
                                    <option value="Khác" ${patient.gender eq 'Khác' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>

                            <!-- DOB -->
                            <div class="form-group">
                                <label for="dob" class="form-label">
                                    Ngày Sinh <span style="font-size:11.5px; color:var(--text-muted); font-weight:normal;">(Tối thiểu 12 tháng tuổi)</span>
                                </label>
                                <input type="date" 
                                       id="dob" 
                                       name="dob" 
                                       class="form-control" 
                                       value="${patient.dob}" />
                            </div>

                            <!-- Citizen ID (Optional) -->
                            <div class="form-group">
                                <label for="citizenId" class="form-label">
                                    Số CCCD / Hộ Chiếu <span style="font-size:11.5px; color:var(--text-muted); font-weight:normal;">(Tùy chọn bổ sung &bull; Không bắt buộc)</span>
                                </label>
                                <input type="text" 
                                       id="citizenId" 
                                       name="citizenId" 
                                       class="form-control" 
                                       value="${patient.citizenId}" 
                                       placeholder="Ví dụ: 001099xxxxxx (Không bắt buộc)" />
                            </div>

                            <!-- Emergency Contact -->
                            <div class="form-group">
                                <label for="emergencyContact" class="form-label">Người Thân / Liên Hệ Khẩn Cấp</label>
                                <input type="text" 
                                       id="emergencyContact" 
                                       name="emergencyContact" 
                                       class="form-control" 
                                       value="${patient.emergencyContact}" 
                                       placeholder="Tên và SĐT người thân" />
                            </div>

                            <!-- Address -->
                            <div class="form-group form-group-full">
                                <label for="address" class="form-label">Địa Chỉ Thường Trú</label>
                                <input type="text" 
                                       id="address" 
                                       name="address" 
                                       class="form-control" 
                                       value="${patient.address}" 
                                       placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành..." />
                            </div>

                            <!-- Medical Alerts (Health History) -->
                            <div class="form-group">
                                <label for="medicalAlerts" class="form-label" style="color: var(--danger);">
                                    Tiền Sử Bệnh Lý Nền (Nếu có)
                                </label>
                                <textarea id="medicalAlerts" 
                                          name="medicalAlerts" 
                                          class="form-control" 
                                          rows="2" 
                                          style="border-color: #fca5a5; background: #fffafb;" 
                                          placeholder="Ví dụ: Cao huyết áp, tiểu đường, máu khó đông, tim mạch...">${patient.medicalAlerts}</textarea>
                            </div>

                            <!-- Allergies -->
                            <div class="form-group">
                                <label for="allergies" class="form-label" style="color: var(--warning);">
                                    Tiền Sử Dị Ứng Thuốc (Nếu có)
                                </label>
                                <textarea id="allergies" 
                                          name="allergies" 
                                          class="form-control" 
                                          rows="2" 
                                          style="border-color: #fde68a; background: #fffdf5;" 
                                          placeholder="Ví dụ: Dị ứng thuốc tê Lidocaine, Penicillin, Aspirin...">${patient.allergies}</textarea>
                            </div>
                        </div>
                    </div>

                    <div class="form-card-footer">
                        <a href="${pageContext.request.contextPath}/reception/patients" class="btn btn-secondary">
                            Hủy Bỏ
                        </a>
                        <button type="submit" class="btn btn-primary">
                            Lưu Hồ Sơ Bệnh Nhân
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var dobInput = document.getElementById('dob');
        if (dobInput) {
            var maxDate = new Date();
            maxDate.setFullYear(maxDate.getFullYear() - 1);
            var yyyy = maxDate.getFullYear();
            var mm = String(maxDate.getMonth() + 1).padStart(2, '0');
            var dd = String(maxDate.getDate()).padStart(2, '0');
            var maxDateStr = yyyy + '-' + mm + '-' + dd;
            dobInput.max = maxDateStr;

            var form = dobInput.closest('form');
            if (form) {
                form.addEventListener('submit', function(e) {
                    if (dobInput.value && dobInput.value > maxDateStr) {
                        e.preventDefault();
                        alert('Tuổi bệnh nhân tối thiểu phải từ 12 tháng tuổi trở lên (ngày sinh tối đa là ' + maxDateStr + '). Vui lòng kiểm tra lại!');
                        dobInput.focus();
                        return false;
                    }
                });
            }
        }
    });
</script>

</body>
</html>
