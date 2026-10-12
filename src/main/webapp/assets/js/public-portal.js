/**
 * DCMS DENTAL CARE — PUBLIC PORTAL CLIENT LOGIC
 * Handles Mega Tab navigation, sub-tab toggles, booking prefill, and AJAX submissions.
 */

// Chuyển đổi Tab chính (Home, Services, About, Doctors, Pricing, News, Booking)
function switchTab(tabId) {
    const tabs = ['home', 'services', 'about', 'doctors', 'pricing', 'news', 'booking'];
    tabs.forEach(t => {
        const pane = document.getElementById('pane-' + t);
        const navBtn = document.getElementById('tabNav-' + t);
        if (pane) pane.classList.remove('active');
        if (navBtn) navBtn.classList.remove('active');
    });

    const activePane = document.getElementById('pane-' + tabId);
    const activeNav = document.getElementById('tabNav-' + tabId);
    if (activePane) activePane.classList.add('active');
    if (activeNav) activeNav.classList.add('active');

    window.location.hash = tabId;
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Chuyển đổi Sub-tab trong Dịch vụ (Ceramic, Braces, Implant, General)
function switchSubTab(subId) {
    const subTabs = ['ceramic', 'braces', 'implant', 'general'];
    subTabs.forEach(s => {
        const pane = document.getElementById('subPane-' + s);
        const btn = document.getElementById('subNav-' + s);
        if (pane) pane.classList.remove('active');
        if (btn) btn.classList.remove('active');
    });

    const activeSubPane = document.getElementById('subPane-' + subId);
    const activeSubBtn = document.getElementById('subNav-' + subId);
    if (activeSubPane) activeSubPane.classList.add('active');
    if (activeSubBtn) activeSubBtn.classList.add('active');
}

// Tự động điền dịch vụ hoặc bác sĩ rồi chuyển sang Tab Booking
function prefillBooking(reasonName, dentistId) {
    switchTab('booking');
    if (reasonName) {
        const reasonInput = document.getElementById('bookingReasonInput');
        if (reasonInput) reasonInput.value = reasonName;
    }
    if (dentistId) {
        const dentistSelect = document.getElementById('bookingDentistSelect');
        if (dentistSelect) dentistSelect.value = dentistId;
    }
}

// Xử lý gửi AJAX Đặt lịch khám trực tuyến
function handleTabBooking(e) {
    e.preventDefault();
    const form = document.getElementById('onlineBookingForm');
    const submitBtn = document.getElementById('btnSubmitTabBooking');
    const msgEl = document.getElementById('tabBookingMsg');

    const originalBtnHtml = submitBtn.innerHTML;
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<span>Đang xử lý đặt lịch...</span>';
    msgEl.innerText = '';

    const formData = new FormData(form);
    const params = new URLSearchParams();
    for (const [key, value] of formData.entries()) {
        params.append(key, value);
    }

    const contextPath = window.DCMS_CONTEXT_PATH || '';
    const bookingEndpoint = (contextPath ? contextPath : '') + '/booking';

    fetch(bookingEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnHtml;

        if (data.success) {
            document.getElementById('modalCode').innerText = '#APT-' + (data.appointmentId || 'SUCCESS');
            document.getElementById('modalName').innerText = form.fullName.value;
            document.getElementById('modalTime').innerText = form.appointmentDate.value + ' lúc ' + form.timeSlot.value;
            document.getElementById('modalReason').innerText = form.reason.value;

            document.getElementById('successModal').style.display = 'flex';
            form.reset();
        } else {
            msgEl.style.color = '#dc2626';
            msgEl.innerText = data.message || 'Lỗi khi đặt lịch. Vui lòng thử lại!';
        }
    })
    .catch(err => {
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnHtml;
        msgEl.style.color = '#dc2626';
        msgEl.innerText = 'Lỗi kết nối máy chủ. Vui lòng gọi Hotline 096 669 2286 để được hỗ trợ.';
    });
}

function closeModal() {
    const modal = document.getElementById('successModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Khởi tạo tab từ URL hash nếu có (ví dụ #services, #doctors)
function initHashNavigation() {
    const hash = window.location.hash.replace('#', '');
    if (hash && ['home', 'services', 'about', 'doctors', 'pricing', 'news', 'booking'].includes(hash)) {
        switchTab(hash);
    }
}

window.addEventListener('DOMContentLoaded', initHashNavigation);
window.addEventListener('hashchange', initHashNavigation);
