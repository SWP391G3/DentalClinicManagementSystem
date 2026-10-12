<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập — DCMS Dental Care | Cổng nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.0">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: 
                radial-gradient(ellipse at 10% 20%, rgba(0, 51, 102, 0.06) 0%, transparent 50%),
                radial-gradient(ellipse at 90% 80%, rgba(0, 168, 204, 0.06) 0%, transparent 50%),
                radial-gradient(ellipse at 50% 50%, rgba(0, 82, 204, 0.03) 0%, transparent 60%),
                var(--bg-app);
            padding: 24px;
        }

        .login-wrapper {
            width: 100%;
            max-width: 450px;
        }

        .login-card {
            background: #ffffff;
            border-radius: var(--radius-xl);
            border: 1px solid rgba(0, 51, 102, 0.08);
            box-shadow: 0 20px 50px -12px rgba(0, 51, 102, 0.15), 0 0 0 1px rgba(0, 51, 102, 0.03);
            padding: 40px;
            position: relative;
            overflow: hidden;
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--drsmile-gradient);
        }

        .login-brand {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-logo-wrap {
            width: 68px;
            height: 68px;
            background: var(--drsmile-gradient);
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin-bottom: 16px;
            color: #ffffff;
            position: relative;
            box-shadow: 0 8px 24px rgba(0, 51, 102, 0.25);
        }

        .login-logo-wrap::after {
            content: '';
            position: absolute;
            inset: -3px;
            border-radius: 18px;
            background: linear-gradient(135deg, rgba(0, 168, 204, 0.3) 0%, transparent 60%);
            z-index: -1;
        }

        .login-brand h1 {
            font-size: 23px;
            font-weight: 800;
            color: var(--drsmile-navy);
            letter-spacing: -0.5px;
            margin-bottom: 4px;
        }

        .login-brand .brand-subtitle {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        .login-brand .brand-subtitle strong {
            color: var(--drsmile-blue);
        }

        .back-home-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--drsmile-blue);
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 14px;
            transition: all var(--transition-fast);
            padding: 4px 0;
        }
        .back-home-link:hover {
            color: var(--drsmile-navy);
            transform: translateX(-2px);
        }

        .login-divider {
            height: 1px;
            background: linear-gradient(90deg, transparent 0%, var(--border) 50%, transparent 100%);
            margin: 24px 0;
        }

        .demo-roles {
            margin-top: 0;
        }

        .demo-roles-title {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            margin-bottom: 10px;
            text-align: center;
        }

        .demo-chips-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
        }

        .demo-chip {
            padding: 8px 3px;
            background: linear-gradient(135deg, #f8fafc 0%, #f0f7fd 100%);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            text-align: center;
            cursor: pointer;
            transition: all var(--transition-normal);
        }

        .demo-chip:hover {
            background: linear-gradient(135deg, #e0f2fe 0%, #dbeafe 100%);
            border-color: #93c5fd;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 82, 204, 0.1);
        }

        .demo-chip-role {
            font-size: 11px;
            font-weight: 700;
            color: var(--drsmile-navy);
            display: block;
            margin-bottom: 2px;
            white-space: nowrap;
        }

        .demo-chip-user {
            font-size: 10px;
            font-family: 'Inter', monospace;
            font-weight: 600;
            color: var(--drsmile-cyan);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: block;
        }

        .login-footer-text {
            text-align: center;
            margin-top: 24px;
            font-size: 12px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        .form-input-icon {
            position: relative;
        }
        .form-input-icon .icon-left {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
            color: var(--text-muted);
            pointer-events: none;
        }
        .form-input-icon .form-control {
            padding-left: 40px;
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div style="margin-bottom: 12px;">
        <a href="${pageContext.request.contextPath}/" class="back-home-link">
            <span>←</span> Quay lại trang chủ DCMS Dental Care
        </a>
    </div>

    <div class="login-card">
        <div class="login-brand">
            <div class="login-logo-wrap">
                <img src="${pageContext.request.contextPath}/assets/images/dcms-dental-mark.svg" alt="DCMS Dental Care" />
            </div>
            <h1>DCMS Dental Care</h1>
            <p class="brand-subtitle">Cổng tác nghiệp nội bộ <strong>DCMS</strong> &bull; Bác sĩ &amp; cán bộ phòng khám</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert-banner alert-banner-danger" style="margin-bottom: 20px; padding: 10px 14px; font-size: 13px;">
                <span class="alert-banner-icon" style="font-weight:700;">!</span>
                <div>${errorMessage}</div>
            </div>
        </c:if>

        <c:if test="${param.loggedOut eq 'true'}">
            <div class="alert-banner alert-banner-success" style="margin-bottom: 20px; padding: 10px 14px; font-size: 13px;">
                <span class="alert-banner-icon" style="font-weight:700;">✓</span>
                <div>Bạn đã đăng xuất an toàn khỏi hệ thống DCMS Dental Care.</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="POST">
            <div class="form-group" style="margin-bottom: 16px;">
                <label for="username" class="form-label required">Tài Khoản</label>
                <div class="form-input-icon">
                    <svg class="icon-left" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); opacity:0.5;"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                    <input type="text" 
                           id="username" 
                           name="username" 
                           class="form-control" 
                           value="${enteredUsername}" 
                           placeholder="Nhập tên đăng nhập" 
                           required 
                           autofocus />
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 24px;">
                <label for="password" class="form-label required">Mật Khẩu</label>
                <div class="form-input-icon">
                    <svg class="icon-left" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); opacity:0.5;"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           class="form-control" 
                           placeholder="Nhập mật khẩu" 
                           required />
                </div>
            </div>

            <button type="submit" class="btn btn-drsmile" style="width: 100%; padding: 13px; font-size: 14.5px;">
                Đăng Nhập Vào Hệ Thống
            </button>
        </form>

        <div class="login-divider"></div>

        <div class="demo-roles">
            <div class="demo-roles-title">Tài khoản demo thử nghiệm (Mật khẩu: 123456)</div>
            <div class="demo-chips-grid">
                <div class="demo-chip" onclick="fillAccount('letan01', '123456')" title="Nhấn để điền tài khoản Lễ tân">
                    <span class="demo-chip-role">Lễ Tân</span>
                    <span class="demo-chip-user">letan01</span>
                </div>
                <div class="demo-chip" onclick="fillAccount('bacsi_hung', '123456')" title="Nhấn để điền tài khoản Nha sĩ">
                    <span class="demo-chip-role">Nha Sĩ</span>
                    <span class="demo-chip-user">bacsi_hung</span>
                </div>
                <div class="demo-chip" onclick="fillAccount('trothu01', '123456')" title="Nhấn để điền tài khoản Y tá nha khoa">
                    <span class="demo-chip-role">Y Tá Nha Khoa</span>
                    <span class="demo-chip-user">trothu01</span>
                </div>
                <div class="demo-chip" onclick="fillAccount('thungan01', '123456')" title="Nhấn để điền tài khoản Thu ngân">
                    <span class="demo-chip-role">Thu Ngân</span>
                    <span class="demo-chip-user">thungan01</span>
                </div>
                <div class="demo-chip" onclick="fillAccount('benhnhan01', '123456')" title="Nhấn để điền tài khoản Bệnh nhân">
                    <span class="demo-chip-role">Bệnh Nhân</span>
                    <span class="demo-chip-user">benhnhan01</span>
                </div>
                <div class="demo-chip" onclick="fillAccount('admin', '123456')" title="Nhấn để điền tài khoản Quản trị">
                    <span class="demo-chip-role">Quản Trị</span>
                    <span class="demo-chip-user">admin</span>
                </div>
            </div>
        </div>
    </div>

    <div class="login-footer-text">
        DCMS Dental Care — Dental Clinic Management System<br/>
        Nhóm G3_SE2064 &bull; SWP391
    </div>
</div>

<script>
    function fillAccount(u, p) {
        document.getElementById('username').value = u;
        document.getElementById('password').value = p;
        document.getElementById('username').style.borderColor = '#00a8cc';
        document.getElementById('password').style.borderColor = '#00a8cc';
        setTimeout(() => {
            document.getElementById('username').style.borderColor = '';
            document.getElementById('password').style.borderColor = '';
        }, 800);
    }
</script>

</body>
</html>
