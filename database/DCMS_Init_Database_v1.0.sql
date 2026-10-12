-- =========================================================================
-- DENTAL CLINIC MANAGEMENT SYSTEM (DCMS)
-- DATABASE INITIALIZATION SCRIPT - ITERATION 1 (BASELINE v1.0)
-- Target RDBMS: Microsoft SQL Server 2019+
-- Business Baseline: DCMS_Business_Baseline_Standardized.md (BF-01)
-- =========================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DCMS_DB')
BEGIN
    CREATE DATABASE DCMS_DB COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END
GO

USE DCMS_DB;
GO

-- 1. DROP EXISTING TABLES IN REVERSE ORDER (FOR CLEAN RE-INSTALL)
-- Drop Iteration 2 dependants first so the baseline can be re-run safely.
IF OBJECT_ID('dbo.DentalAttachments', 'U') IS NOT NULL DROP TABLE dbo.DentalAttachments;
IF OBJECT_ID('dbo.ClinicalExaminations', 'U') IS NOT NULL DROP TABLE dbo.ClinicalExaminations;
IF OBJECT_ID('dbo.ToothFindings', 'U') IS NOT NULL DROP TABLE dbo.ToothFindings;
IF OBJECT_ID('dbo.PreTreatmentAssessments', 'U') IS NOT NULL DROP TABLE dbo.PreTreatmentAssessments;
IF OBJECT_ID('dbo.Visits', 'U') IS NOT NULL DROP TABLE dbo.Visits;
IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL DROP TABLE dbo.Appointments;
IF OBJECT_ID('dbo.DentistSchedules', 'U') IS NOT NULL DROP TABLE dbo.DentistSchedules;
IF OBJECT_ID('dbo.Dentists', 'U') IS NOT NULL DROP TABLE dbo.Dentists;
IF OBJECT_ID('dbo.Patients', 'U') IS NOT NULL DROP TABLE dbo.Patients;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- 2. TABLE: Roles
CREATE TABLE dbo.Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
GO

-- 3. TABLE: Users (Staff, Dentists, Receptionists, Cashiers, Admins, Patients)
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NOT NULL,
    RoleId INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);
GO

-- 4. TABLE: Dentists (Extended profile for clinical providers)
CREATE TABLE dbo.Dentists (
    DentistId INT PRIMARY KEY,
    LicenseNumber NVARCHAR(50) NOT NULL UNIQUE,
    Specialization NVARCHAR(100) NOT NULL DEFAULT N'Nha khoa tổng quát',
    RoomNumber NVARCHAR(20) NULL,
    CONSTRAINT FK_Dentists_Users FOREIGN KEY (DentistId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE
);
GO

-- 5. TABLE: DentistSchedules (Working hours to check availability & prevent double-booking)
CREATE TABLE dbo.DentistSchedules (
    ScheduleId INT IDENTITY(1,1) PRIMARY KEY,
    DentistId INT NOT NULL,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7), -- 1=Monday, 7=Sunday
    ShiftStart TIME NOT NULL,
    ShiftEnd TIME NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_DentistSchedules_Dentists FOREIGN KEY (DentistId) REFERENCES dbo.Dentists(DentistId)
);
GO

-- 6. TABLE: Patients
CREATE TABLE dbo.Patients (
    PatientId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Dob DATE NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN (N'Nam', N'Nữ', N'Khác')),
    Phone NVARCHAR(20) NOT NULL,
    CitizenId NVARCHAR(20) NULL,
    Address NVARCHAR(255) NULL,
    MedicalAlerts NVARCHAR(MAX) NULL,   -- Ví dụ: Tim mạch, tiểu đường, máu khó đông
    Allergies NVARCHAR(MAX) NULL,       -- Dị ứng thuốc tê, kháng sinh
    EmergencyContact NVARCHAR(150) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL
);
GO

CREATE NONCLUSTERED INDEX IX_Patients_CitizenId ON dbo.Patients(CitizenId);
-- Prevent duplicate identity records while still allowing patients without a
-- citizen ID. Phone is the public booking lookup key and must be unique too.
CREATE UNIQUE NONCLUSTERED INDEX UX_Patients_Phone ON dbo.Patients(Phone);
CREATE UNIQUE NONCLUSTERED INDEX UX_Patients_CitizenId ON dbo.Patients(CitizenId)
    WHERE CitizenId IS NOT NULL;
GO

-- 7. TABLE: Appointments (Scheduled intent to visit - BF-01)
-- MANDATORY RULE: Appointment != Visit
CREATE TABLE dbo.Appointments (
    AppointmentId INT IDENTITY(1,1) PRIMARY KEY,
    PatientId INT NOT NULL,
    DentistId INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Reason NVARCHAR(255) NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'Confirmed', 'Arrived', 'Completed', 'Cancelled', 'NoShow')),
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (PatientId) REFERENCES dbo.Patients(PatientId),
    CONSTRAINT FK_Appointments_Dentists FOREIGN KEY (DentistId) REFERENCES dbo.Dentists(DentistId)
);
GO

CREATE NONCLUSTERED INDEX IX_Appointments_Date_Dentist ON dbo.Appointments(AppointmentDate, DentistId);
GO

-- 8. TABLE: Visits (Actual clinical encounter at the clinic - BF-01)
-- MANDATORY RULE: Walk-ins create Visit directly without AppointmentId.
CREATE TABLE dbo.Visits (
    VisitId INT IDENTITY(1,1) PRIMARY KEY,
    PatientId INT NOT NULL,
    PrimaryDentistId INT NOT NULL,
    AppointmentId INT NULL, -- NULL if walk-in or emergency
    CheckInTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CheckOutTime DATETIME2 NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Waiting' 
        CHECK (Status IN ('Waiting', 'InProgress', 'Completed', 'Cancelled')),
    VisitType NVARCHAR(30) NOT NULL DEFAULT 'Scheduled' 
        CHECK (VisitType IN ('Scheduled', 'WalkIn', 'Emergency')),
    Notes NVARCHAR(MAX) NULL,
    Operatory NVARCHAR(50) NULL DEFAULT N'Ghế 1 - P.101',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Visits_Patients FOREIGN KEY (PatientId) REFERENCES dbo.Patients(PatientId),
    CONSTRAINT FK_Visits_Dentists FOREIGN KEY (PrimaryDentistId) REFERENCES dbo.Dentists(DentistId),
    CONSTRAINT FK_Visits_Appointments FOREIGN KEY (AppointmentId) REFERENCES dbo.Appointments(AppointmentId)
);
GO

CREATE NONCLUSTERED INDEX IX_Visits_Patient_Time ON dbo.Visits(PatientId, CheckInTime);
GO

-- =========================================================================
-- SEED MASTER DATA FOR ITERATION 1
-- =========================================================================

-- Insert Roles
INSERT INTO dbo.Roles (RoleName, Description) VALUES
(N'Admin', N'Quản trị viên toàn hệ thống'),
(N'Receptionist', N'Nhân viên lễ tân, tiếp đón, đặt lịch'),
(N'Dentist', N'Bác sĩ nha khoa điều trị'),
(N'DentalAssistant', N'Y tá nha khoa'),
(N'Cashier', N'Thu ngân viện phí'),
(N'Patient', N'Bệnh nhân đặt và quản lý lịch khám cá nhân');
GO

-- Insert Default Users (Password: 123456 -> BCrypt hashed)
-- BCrypt hash for "123456" is '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK'
INSERT INTO dbo.Users (Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive) VALUES
('admin', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'Quản trị viên', 'admin@dcms.vn', '0901000001', 1, 1),
('letan01', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'Nguyễn Thị Thu (Lễ tân)', 'letan@dcms.vn', '0901000002', 2, 1),
('bacsi_hung', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'BS. Trần Mạnh Hùng', 'hungtm@dcms.vn', '0901000003', 3, 1),
('bacsi_lan', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'BS. Lê Mai Lan', 'lanlm@dcms.vn', '0901000004', 3, 1),
('thungan01', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'Phạm Thu Ngân', 'thungan@dcms.vn', '0901000005', 5, 1),
('trothu01', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'Lê Thị Mai (Y tá nha khoa)', 'mailt@dcms.vn', '0901000006', 4, 1),
('benhnhan01', '$2a$10$WetW.pp9un3bEg0egrnwR.aYd3dtTm91gs0TAxeHj7pstRZASkhrK', N'Hoàng Văn Nam', 'namhv@gmail.com', '0988111222', 6, 1);
GO

-- Insert Dentist Details
INSERT INTO dbo.Dentists (DentistId, LicenseNumber, Specialization, RoomNumber) VALUES
(3, 'CCHN-001234/BYT', N'Nha khoa tổng quát & Cấy ghép Implant', 'P.101'),
(4, 'CCHN-005678/BYT', N'Chỉnh nha & Thẩm mỹ nụ cười', 'P.102');
GO

-- Insert Dentist Schedules (Thứ 2 đến Chủ Nhật, 08:00 - 18:30)
INSERT INTO dbo.DentistSchedules (DentistId, DayOfWeek, ShiftStart, ShiftEnd, IsAvailable) VALUES
(3, 1, '08:00', '18:30', 1),
(3, 2, '08:00', '18:30', 1),
(3, 3, '08:00', '18:30', 1),
(3, 4, '08:00', '18:30', 1),
(3, 5, '08:00', '18:30', 1),
(3, 6, '08:00', '18:30', 1),
(3, 7, '08:00', '18:30', 1),
(4, 1, '08:00', '18:30', 1),
(4, 2, '08:00', '18:30', 1),
(4, 3, '08:00', '18:30', 1),
(4, 4, '08:00', '18:30', 1),
(4, 5, '08:00', '18:30', 1),
(4, 6, '08:00', '18:30', 1),
(4, 7, '08:00', '18:30', 1);
GO

-- Insert Sample Patients
INSERT INTO dbo.Patients (FullName, Dob, Gender, Phone, CitizenId, Address, MedicalAlerts, Allergies) VALUES
(N'Hoàng Văn Nam', '1992-05-14', N'Nam', '0988111222', '001092001122', N'Cầu Giấy, Hà Nội', N'Tiền sử cao huyết áp', N'Dị ứng Penicillin'),
(N'Đỗ Thu Trang', '1998-11-20', N'Nữ', '0977333444', '001098003344', N'Nam Từ Liêm, Hà Nội', NULL, NULL);
GO

PRINT N'DCMS Database Initialized Successfully for Iteration 1!';
GO
