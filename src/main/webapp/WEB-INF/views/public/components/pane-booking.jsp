<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!-- TAB 7: ĐẶT LỊCH KHÁM & LIÊN HỆ (BOOKING PANE) -->
<div class="dr-tab-pane" id="pane-booking">
    <div class="booking-page-layout">
        <!-- Form Đặt Lịch Online -->
        <div class="booking-form-box">
            <div style="border-bottom:1px solid #f1f5f9; padding-bottom:14px; margin-bottom:20px;">
                <span style="font-size:12.5px; font-weight:800; color:var(--dr-cyan); text-transform:uppercase;">Đặt Hẹn Trực Tuyến</span>
                <h2 style="font-size:22px; font-weight:800; color:var(--dr-navy); margin:4px 0 0 0;">Đăng Ký Khám & Tư Vấn Miễn Phí</h2>
            </div>

            <c:if test="${not empty param.bookingError}">
                <div style="background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-size:13.5px; display:flex; align-items:center; gap:8px;">
                    <span style="font-weight:bold; font-size:16px;">!</span>
                    <div><strong>Không thể đặt lịch:</strong> ${param.bookingError}</div>
                </div>
            </c:if>

            <form id="onlineBookingForm" onsubmit="handleTabBooking(event)">
                <div class="booking-grid-2" style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px;">
                    <div class="booking-input-group">
                        <label style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Họ và tên bệnh nhân *</label>
                        <input type="text" name="fullName" class="form-control" placeholder="Nguyễn Văn A" required style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid #cbd5e1;">
                    </div>
                    <div class="booking-input-group">
                        <label style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Số điện thoại *</label>
                        <input type="tel" name="phone" class="form-control" placeholder="09xxxxxxxx" pattern="0[35789][0-9]{8}" minlength="10" maxlength="10" required style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid #cbd5e1;">
                    </div>
                </div>

                <div class="booking-grid-2" style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px;">
                    <div class="booking-input-group">
                        <label style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Ngày hẹn khám *</label>
                        <input type="date" name="appointmentDate" class="form-control" value="${todayStr}" min="${todayStr}" required style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid #cbd5e1;">
                    </div>
                    <div class="booking-input-group">
                        <label for="bookingTimeSlot" style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Ca khám mong muốn *</label>
                        <small style="display:block; color:#64748b; font-size:11.5px; margin-bottom:4px;">Mỗi ca kéo dài 30 phút · 08:30 – 18:30</small>
                        <select id="bookingTimeSlot" name="timeSlot" class="form-control" required style="width:100%;">
                            <optgroup label="Buổi sáng">
                                <option value="08:00-08:30">08:00 – 08:30</option>
                                <option value="08:30-09:00">08:30 – 09:00</option>
                                <option value="09:00-09:30">09:00 – 09:30</option>
                                <option value="09:30-10:00">09:30 – 10:00</option>
                                <option value="10:00-10:30" selected>10:00 – 10:30</option>
                                <option value="10:30-11:00">10:30 – 11:00</option>
                                <option value="11:00-11:30">11:00 – 11:30</option>
                                <option value="11:30-12:00">11:30 – 12:00</option>
                            </optgroup>
                            <optgroup label="Buổi chiều">
                                <option value="12:00-12:30">12:00 – 12:30</option>
                                <option value="12:30-13:00">12:30 – 13:00</option>
                                <option value="13:00-13:30">13:00 – 13:30</option>
                                <option value="13:30-14:00">13:30 – 14:00</option>
                                <option value="14:00-14:30">14:00 – 14:30</option>
                                <option value="14:30-15:00">14:30 – 15:00</option>
                                <option value="15:00-15:30">15:00 – 15:30</option>
                                <option value="15:30-16:00">15:30 – 16:00</option>
                                <option value="16:00-16:30">16:00 – 16:30</option>
                                <option value="16:30-17:00">16:30 – 17:00</option>
                                <option value="17:00-17:30">17:00 – 17:30</option>
                                <option value="17:30-18:00">17:30 – 18:00</option>
                                <option value="18:00-18:30">18:00 – 18:30</option>
                            </optgroup>
                        </select>
                    </div>
                </div>

                <div class="booking-grid-2" style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px;">
                    <div class="booking-input-group">
                        <label style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Bác sĩ phụ trách</label>
                        <select name="dentistId" id="bookingDentistSelect" class="form-control" style="width:100%;">
                            <option value="">-- Bác sĩ phù hợp nhất --</option>
                            <c:forEach var="d" items="${dentistList}">
                                <option value="${d.dentistId}">${d.fullName} (${empty d.specialization ? 'Nha khoa tổng quát' : d.specialization})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="booking-input-group">
                        <label style="font-size:12.5px; font-weight:700; color:#334155; margin-bottom:4px; display:block;">Dịch vụ yêu cầu</label>
                        <input type="text" name="reason" id="bookingReasonInput" class="form-control" placeholder="Khám tổng quát, răng sứ, niềng răng..." value="Khám tổng quát & Tư vấn" style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid #cbd5e1;">
                    </div>
                </div>

                <button type="submit" id="btnSubmitTabBooking" class="btn-hero-primary" style="width:100%; padding:14px; justify-content:center; font-size:15px; margin-top:8px;">
                    Xác Nhận Đăng Ký Lịch Khám
                </button>
                <div id="tabBookingMsg" style="text-align:center; margin-top:10px; font-size:13px;"></div>
            </form>
        </div>

        <!-- Thông Tin Liên Hệ & Cơ Sở -->
        <div class="booking-info-box">
            <h3 style="font-size:18px; font-weight:800; color:var(--dr-navy); margin:0 0 16px 0;">Hệ Thống Cơ Sở Nha Khoa Dr.Smile</h3>
            
            <div style="margin-bottom:18px; padding-bottom:14px; border-bottom:1px solid #f1f5f9;">
                <strong style="color:var(--dr-navy); font-size:14.5px;">Cơ sở chính (Núi Trúc):</strong>
                <p style="font-size:13px; color:#475569; margin:4px 0;">Số 41, phố Núi Trúc, phường Giảng Võ, quận Ba Đình, Hà Nội</p>
                <span style="font-size:12.5px; color:#0284c7; font-weight:600;">Hotline: 096 669 2286</span>
            </div>

            <div style="margin-bottom:18px; padding-bottom:14px; border-bottom:1px solid #f1f5f9;">
                <strong style="color:var(--dr-navy); font-size:14.5px;">Cơ sở 2 (Phố Huế):</strong>
                <p style="font-size:13px; color:#475569; margin:4px 0;">Số 124 Phố Huế, quận Hai Bà Trưng, Hà Nội</p>
                <span style="font-size:12.5px; color:#0284c7; font-weight:600;">Hotline: 08 6542 8768</span>
            </div>

            <div>
                <strong style="color:var(--dr-navy); font-size:14.5px;">Giờ Mở Cửa Phục Vụ:</strong>
                <p style="font-size:13px; color:#475569; margin:4px 0;">Từ 08:30 đến 18:30 (Thứ 2 đến Chủ Nhật, kể cả ngày lễ)</p>
                <p style="font-size:12.5px; color:#64748b; margin:0;">Email liên hệ: drsmile.vn@gmail.com &bull; MST: 0109138207</p>
            </div>
        </div>
    </div>
</div>
