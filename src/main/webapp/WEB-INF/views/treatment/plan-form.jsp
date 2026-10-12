<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeMenu" value="treatment_plans" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lập Kế Hoạch Điều Trị Mới — DCMS Dr.Smile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.2">
    <style>
        .form-card-container {
            max-width: 860px;
            margin: 0 auto;
            background: #ffffff;
            border-radius: var(--radius-xl);
            border: 1px solid rgba(0, 51, 102, 0.08);
            padding: 36px 40px;
            box-shadow: 0 10px 30px rgba(0, 51, 102, 0.05);
        }

        .form-grid-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .guide-box {
            background: #f0f7fd;
            border-left: 4px solid var(--drsmile-blue);
            padding: 14px 18px;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            margin-bottom: 24px;
            font-size: 13.5px;
            color: #0c4a6e;
            line-height: 1.5;
        }

        @media (max-width: 768px) {
            .form-grid-2col {
                grid-template-columns: 1fr;
            }
            .form-card-container {
                padding: 24px 20px;
            }
        }
    </style>
</head>
<body>

<div class="app-shell">
    <jsp:include page="../layout/sidebar.jsp" />

    <div class="app-main">
        <jsp:include page="../layout/header.jsp" />

        <main class="page-content">
            <div style="margin-bottom: 20px;">
                <a href="${pageContext.request.contextPath}/treatment/plans" style="color: var(--drsmile-blue); text-decoration: none; font-size: 13.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px;">
                    <span>←</span> Quay lại danh sách phác đồ điều trị
                </a>
            </div>

            <div class="form-card-container">
                <div style="margin-bottom: 24px; border-bottom: 1px solid #e2e8f0; padding-bottom: 18px;">
                    <div style="font-size: 13px; color: var(--drsmile-cyan); font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">
                        Bước 1: Khởi Tạo Hồ Sơ Kế Hoạch
                    </div>
                    <h1 style="font-size: 22px; font-weight: 800; color: var(--drsmile-navy); margin: 0;">
                        Lập Kế Hoạch Điều Trị Nha Khoa Mới (UC19)
                    </h1>
                    <p style="font-size: 13px; color: var(--text-secondary); margin: 4px 0 0 0;">
                        Khởi tạo thông tin chẩn đoán phác đồ ban đầu. Sau khi tạo thành công, bác sĩ có thể thêm chi tiết từng thủ thuật theo chuẩn FDI và phân chia buổi điều trị.
                    </p>
                </div>

                <div class="guide-box">
                    <strong>Quy trình chuẩn y khoa Dr.Smile:</strong> Kế hoạch điều trị hỗ trợ kéo dài qua nhiều buổi khám (`Multi-visit`). Dự toán viện phí chỉ được tạm tính và không xuất hóa đơn thu tiền cho đến khi thủ thuật thực tế được thực hiện tại ghế.
                </div>

                <c:if test="${not empty param.error}">
                    <div class="alert-banner alert-banner-danger" style="margin-bottom: 20px; padding: 12px 16px;">
                        <span class="alert-banner-icon">!</span>
                        <div>${param.error}</div>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/treatment/plans/create" method="POST">
                    <div class="form-grid-2col">
                        <div class="form-group">
                            <label for="patientId" class="form-label required">Bệnh Nhân Điều Trị</label>
                            <select id="patientId" name="patientId" class="form-control" required>
                                <option value="">-- Chọn bệnh nhân từ danh bạ --</option>
                                <c:forEach var="p" items="${patients}">
                                    <option value="${p.patientId}" ${p.patientId == preSelectedPatientId ? 'selected' : ''}>
                                        #BN-${p.patientId}: ${p.fullName} (SĐT: ${p.phone})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="dentistId" class="form-label required">Bác Sĩ Phụ Trách Kế Hoạch</label>
                            <select id="dentistId" name="dentistId" class="form-control" required>
                                <option value="">-- Chọn bác sĩ điều trị chính --</option>
                                <c:forEach var="d" items="${dentists}">
                                    <option value="${d.dentistId}">
                                        ${d.fullName} — ${d.specialization} (${d.roomNumber})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label for="title" class="form-label required">Tên Kế Hoạch / Mục Tiêu Điều Trị</label>
                        <input type="text" id="title" name="title" class="form-control" 
                               placeholder="Ví dụ: Phục hình răng sứ thẩm mỹ 6 răng cửa hàm trên, Điều trị tủy R46 và trám răng..." 
                               required />
                    </div>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label for="diagnosis" class="form-label">Chẩn Đoán Lâm Sàng & Phim X-Quang</label>
                        <textarea id="diagnosis" name="diagnosis" class="form-control" rows="3" 
                                  placeholder="Ghi nhận tình trạng bệnh lý: Sâu ngà sâu R46, viêm tủy không hồi phục, mất răng R36..."></textarea>
                    </div>

                    <div class="form-group" style="margin-bottom: 28px;">
                        <label for="notes" class="form-label">Ghi Chú Phác Đồ & Lộ Trình Dự Kiến</label>
                        <textarea id="notes" name="notes" class="form-control" rows="2" 
                                  placeholder="Dự kiến điều trị trong 3 buổi hẹn: Buổi 1 điều trị tủy, Buổi 2 lấy dấu cùi răng, Buổi 3 gắn răng hoàn tất..."></textarea>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid #e2e8f0; padding-top: 20px;">
                        <a href="${pageContext.request.contextPath}/treatment/plans" class="btn btn-secondary">
                            Hủy Bỏ
                        </a>
                        <button type="submit" class="btn btn-drsmile" style="padding: 12px 24px; font-size: 14.5px;">
                            <span>Lưu Kế Hoạch & Tiếp Tục Thêm Thủ Thuật →</span>
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

</body>
</html>
