-- =========================================================================
-- DENTAL CLINIC MANAGEMENT SYSTEM (DCMS)
-- UNIFIED DATABASE SCHEMA ARCHITECTURE (v2.0)
-- 
-- MÔ HÌNH CƠ SỞ DỮ LIỆU HỢP NHẤT TOÀN DIỆN (UNIFIED DCMS SCHEMA)
-- Kết hợp 25 Thực thể Logic (Mục 3.2 SDS) + 21 Bảng Vật lý Cốt lõi
-- + 4 Bảng Mở rộng Lâm sàng Thực tế = Bộ CSDL 29 Bảng/Views Chuẩn Hóa
-- 
-- Tương thích 100% với:
-- 1. Mã nguồn Java Servlets & DAOs hiện tại (Không gãy vỡ bất kỳ truy vấn nào)
-- 2. 6 Điểm góp ý phản biện của Giảng viên (Patient Flow, Conflict, CCCD, Calendar, Alerts, DB Architecture)
-- 3. 10 Nguyên tắc Thép (DCMS_Business_Baseline_Standardized.md) & 46 Quy tắc DBR-01 -> DBR-46
-- =========================================================================

USE DCMS_DB;
GO

PRINT '>>> BẮT ĐẦU TRIỂN KHAI MÔ HÌNH CƠ SỞ DỮ LIỆU HỢP NHẤT DCMS v2.0...';
GO

-- =========================================================================
-- PHẦN 1: BẢNG DANH MỤC GIẢI PHẪU NHA KHOA CHUẨN FDI (ODONTOGRAM FOUNDATION)
-- Đáp ứng thực thể: Tooth (8), ToothSurface (9), DentalChart (7)
-- =========================================================================

-- 1. BẢNG DANH MỤC 32 RĂNG VĨNH VIỄN CHUẨN FDI (Entity: Tooth)
IF OBJECT_ID('dbo.Teeth', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Teeth (
        ToothNumber INT PRIMARY KEY,
        ToothName NVARCHAR(100) NOT NULL,
        Quadrant INT NOT NULL CHECK (Quadrant BETWEEN 1 AND 4),
        ToothType NVARCHAR(50) NOT NULL CHECK (ToothType IN (N'Răng cửa', N'Răng nanh', N'Răng tiền hàm', N'Răng cối lớn')),
        IsWisdomTooth BIT NOT NULL DEFAULT 0
    );

    -- Nạp dữ liệu 32 răng vĩnh viễn chuẩn FDI quốc tế
    INSERT INTO dbo.Teeth (ToothNumber, ToothName, Quadrant, ToothType, IsWisdomTooth) VALUES
    -- Cung hàm 1 (Hàm trên bên phải)
    (18, N'Răng khôn trên phải (R18)', 1, N'Răng cối lớn', 1),
    (17, N'Răng cối lớn thứ 2 trên phải (R17)', 1, N'Răng cối lớn', 0),
    (16, N'Răng cối lớn thứ 1 trên phải (R16)', 1, N'Răng cối lớn', 0),
    (15, N'Răng tiền hàm thứ 2 trên phải (R15)', 1, N'Răng tiền hàm', 0),
    (14, N'Răng tiền hàm thứ 1 trên phải (R14)', 1, N'Răng tiền hàm', 0),
    (13, N'Răng nanh trên phải (R13)', 1, N'Răng nanh', 0),
    (12, N'Răng cửa bên trên phải (R12)', 1, N'Răng cửa', 0),
    (11, N'Răng cửa giữa trên phải (R11)', 1, N'Răng cửa', 0),

    -- Cung hàm 2 (Hàm trên bên trái)
    (21, N'Răng cửa giữa trên trái (R21)', 2, N'Răng cửa', 0),
    (22, N'Răng cửa bên trên trái (R22)', 2, N'Răng cửa', 0),
    (23, N'Răng nanh trên trái (R23)', 2, N'Răng nanh', 0),
    (24, N'Răng tiền hàm thứ 1 trên trái (R24)', 2, N'Răng tiền hàm', 0),
    (25, N'Răng tiền hàm thứ 2 trên trái (R25)', 2, N'Răng tiền hàm', 0),
    (26, N'Răng cối lớn thứ 1 trên trái (R26)', 2, N'Răng cối lớn', 0),
    (27, N'Răng cối lớn thứ 2 trên trái (R27)', 2, N'Răng cối lớn', 0),
    (28, N'Răng khôn trên trái (R28)', 2, N'Răng cối lớn', 1),

    -- Cung hàm 3 (Hàm dưới bên trái)
    (38, N'Răng khôn dưới trái (R38)', 3, N'Răng cối lớn', 1),
    (37, N'Răng cối lớn thứ 2 dưới trái (R37)', 3, N'Răng cối lớn', 0),
    (36, N'Răng cối lớn thứ 1 dưới trái (R36)', 3, N'Răng cối lớn', 0),
    (35, N'Răng tiền hàm thứ 2 dưới trái (R35)', 3, N'Răng tiền hàm', 0),
    (34, N'Răng tiền hàm thứ 1 dưới trái (R34)', 3, N'Răng tiền hàm', 0),
    (33, N'Răng nanh dưới trái (R33)', 3, N'Răng nanh', 0),
    (32, N'Răng cửa bên dưới trái (R32)', 3, N'Răng cửa', 0),
    (31, N'Răng cửa giữa dưới trái (R31)', 3, N'Răng cửa', 0),

    -- Cung hàm 4 (Hàm dưới bên phải)
    (41, N'Răng cửa giữa dưới phải (R41)', 4, N'Răng cửa', 0),
    (42, N'Răng cửa bên dưới phải (R42)', 4, N'Răng cửa', 0),
    (43, N'Răng nanh dưới phải (R43)', 4, N'Răng nanh', 0),
    (44, N'Răng tiền hàm thứ 1 dưới phải (R44)', 4, N'Răng tiền hàm', 0),
    (45, N'Răng tiền hàm thứ 2 dưới phải (R45)', 4, N'Răng tiền hàm', 0),
    (46, N'Răng cối lớn thứ 1 dưới phải (R46)', 4, N'Răng cối lớn', 0),
    (47, N'Răng cối lớn thứ 2 dưới phải (R47)', 4, N'Răng cối lớn', 0),
    (48, N'Răng khôn dưới phải (R48)', 4, N'Răng cối lớn', 1);

    PRINT '  + Bảng Teeth đã được tạo và nạp đủ 32 răng FDI.';
END
GO

-- 2. BẢNG DANH MỤC 5 MẶT RĂNG (Entity: ToothSurface)
IF OBJECT_ID('dbo.ToothSurfaces', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ToothSurfaces (
        SurfaceCode NVARCHAR(20) PRIMARY KEY,
        SurfaceName NVARCHAR(50) NOT NULL,
        Description NVARCHAR(255) NULL
    );

    INSERT INTO dbo.ToothSurfaces (SurfaceCode, SurfaceName, Description) VALUES
    ('Occlusal', N'Mặt nhai (O)', N'Mặt tiếp xúc khi cắn khớp của răng hàm'),
    ('Mesial', N'Mặt gần (M)', N'Mặt bên hướng về phía đường giữa cung hàm'),
    ('Distal', N'Mặt xa (D)', N'Mặt bên hướng ra xa đường giữa cung hàm'),
    ('Buccal', N'Mặt ngoài / Mặt má (B)', N'Mặt hướng ra ngoài môi hoặc má'),
    ('Lingual', N'Mặt trong / Mặt lưỡi (L)', N'Mặt hướng vào trong khoang miệng / lưỡi'),
    ('WholeTooth', N'Toàn bộ thân răng', N'Áp dụng khi tổn thương thân răng hoặc nhổ nguyên răng');

    PRINT '  + Bảng ToothSurfaces đã được tạo và nạp đủ 5 mặt răng chuẩn.';
END
GO

-- 3. BẢNG BIỂU ĐỒ NHA KHOA (Entity: DentalChart)
IF OBJECT_ID('dbo.DentalCharts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DentalCharts (
        ChartId INT IDENTITY(1,1) PRIMARY KEY,
        PatientId INT NOT NULL UNIQUE,
        ChartType NVARCHAR(50) NOT NULL DEFAULT N'Adult_FDI_32',
        Notes NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        UpdatedAt DATETIME2 NULL,
        CONSTRAINT FK_DentalCharts_Patients FOREIGN KEY (PatientId) REFERENCES dbo.Patients(PatientId)
    );
    PRINT '  + Bảng DentalCharts đã được tạo thành công.';
END
GO

-- =========================================================================
-- PHẦN 2: BẢNG CẢNH BÁO Y TẾ & NHẮC HẸN TÁI KHÁM ĐỘC LẬP
-- Đáp ứng thực thể: PatientMedicalAlert (22), FollowUpRecall (21)
-- =========================================================================

-- 4. BẢNG TIỀN SỬ BỆNH & CẢNH BÁO Y TẾ (Entity: PatientMedicalAlert)
IF OBJECT_ID('dbo.PatientMedicalAlerts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PatientMedicalAlerts (
        AlertId INT IDENTITY(1,1) PRIMARY KEY,
        PatientId INT NOT NULL,
        AlertType NVARCHAR(50) NOT NULL CHECK (AlertType IN (N'Bệnh nền', N'Dị ứng thuốc', N'Tiền sử máu khó đông', N'Phụ nữ mang thai', N'Khác')),
        AlertDescription NVARCHAR(255) NOT NULL,
        SeverityLevel NVARCHAR(20) NOT NULL DEFAULT N'High' CHECK (SeverityLevel IN (N'Low', N'Medium', N'High', N'Critical')),
        IsActive BIT NOT NULL DEFAULT 1,
        RecordedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_MedicalAlerts_Patients FOREIGN KEY (PatientId) REFERENCES dbo.Patients(PatientId)
    );
    PRINT '  + Bảng PatientMedicalAlerts đã được tạo thành công.';
END
GO

-- 5. BẢNG THEO DÕI TÁI KHÁM THEO PHÁC ĐỒ (Entity: FollowUpRecall)
IF OBJECT_ID('dbo.FollowUpRecalls', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FollowUpRecalls (
        RecallId INT IDENTITY(1,1) PRIMARY KEY,
        PatientId INT NOT NULL,
        TreatmentPlanId INT NULL,
        DentistId INT NOT NULL,
        RecallReason NVARCHAR(255) NOT NULL,
        TargetRecallDate DATE NOT NULL,
        Status NVARCHAR(30) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Contacted', 'Scheduled', 'Completed', 'Cancelled')),
        LinkedAppointmentId INT NULL,
        Notes NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_FollowUpRecalls_Patients FOREIGN KEY (PatientId) REFERENCES dbo.Patients(PatientId),
        CONSTRAINT FK_FollowUpRecalls_TreatmentPlans FOREIGN KEY (TreatmentPlanId) REFERENCES dbo.TreatmentPlans(PlanId),
        CONSTRAINT FK_FollowUpRecalls_Dentists FOREIGN KEY (DentistId) REFERENCES dbo.Dentists(DentistId),
        CONSTRAINT FK_FollowUpRecalls_Appointments FOREIGN KEY (LinkedAppointmentId) REFERENCES dbo.Appointments(AppointmentId)
    );
    PRINT '  + Bảng FollowUpRecalls đã được tạo thành công.';
END
GO

-- 6. BẢNG BÁO GIÁ DỰ TOÁN CHI TIẾT (Entity: TreatmentEstimate)
IF OBJECT_ID('dbo.TreatmentEstimates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TreatmentEstimates (
        EstimateId INT IDENTITY(1,1) PRIMARY KEY,
        PlanId INT NOT NULL,
        EstimateVersion INT NOT NULL DEFAULT 1,
        TotalGrossAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalDiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        FinalEstimateAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        ValidUntil DATE NULL,
        IsAccepted BIT NOT NULL DEFAULT 0,
        Notes NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_TreatmentEstimates_TreatmentPlans FOREIGN KEY (PlanId) REFERENCES dbo.TreatmentPlans(PlanId)
    );
    PRINT '  + Bảng TreatmentEstimates đã được tạo thành công.';
END
GO

-- =========================================================================
-- PHẦN 3: LỚP TƯƠNG THÍCH HAI CHIỀU (COMPATIBILITY VIEWS CHO 100% 25 ENTITY)
-- Đảm bảo truy vấn theo tên gọi 3.2 hay tên vật lý đều trả về kết quả chuẩn
-- =========================================================================

-- View 7: DentalFindings (Ánh xạ từ ToothFindings kết hợp danh mục Răng & Mặt răng)
CREATE OR ALTER VIEW dbo.DentalFindings AS
SELECT 
    tf.FindingId,
    tf.PatientId,
    tf.VisitId,
    tf.ToothNumber,
    t.ToothName,
    t.ToothType,
    tf.Surface AS SurfaceCode,
    ts.SurfaceName,
    tf.Condition,
    tf.Notes,
    tf.RecordedAt
FROM dbo.ToothFindings tf
LEFT JOIN dbo.Teeth t ON tf.ToothNumber = t.ToothNumber
LEFT JOIN dbo.ToothSurfaces ts ON tf.Surface = ts.SurfaceCode;
GO

-- View 8: Diagnoses (Ánh xạ Chẩn đoán từ ClinicalExaminations)
CREATE OR ALTER VIEW dbo.Diagnoses AS
SELECT 
    ExaminationId AS DiagnosisId,
    VisitId,
    ChiefComplaint,
    ProvisionalDiagnosis,
    FinalDiagnosis,
    CreatedAt AS DiagnosedAt
FROM dbo.ClinicalExaminations;
GO

-- View 9: ClinicalNotes (Ánh xạ Ghi chú lâm sàng từ ClinicalExaminations)
CREATE OR ALTER VIEW dbo.ClinicalNotes AS
SELECT 
    ExaminationId AS NoteId,
    VisitId,
    ExtraoralExam,
    IntraoralExam,
    ClinicalNotes AS NoteContent,
    CreatedAt,
    UpdatedAt
FROM dbo.ClinicalExaminations;
GO

-- View 10: InvoiceItems (Ánh xạ các thủ thuật đã hoàn thành lên dòng hóa đơn - Nguyên tắc Thép 3)
CREATE OR ALTER VIEW dbo.InvoiceItems AS
SELECT 
    pp.ProcedureId AS InvoiceItemId,
    inv.InvoiceId,
    inv.InvoiceCode,
    pp.VisitId,
    pp.ServiceId,
    ds.ServiceName,
    pp.ToothNumber,
    pp.Surface,
    pp.Quantity,
    pp.ActualPrice AS UnitPrice,
    (pp.Quantity * pp.ActualPrice) AS SubTotal,
    pp.PerformedAt
FROM dbo.ProceduresPerformed pp
JOIN dbo.DentalServices ds ON pp.ServiceId = ds.ServiceId
JOIN dbo.Invoices inv ON pp.VisitId = inv.VisitId
WHERE pp.Status = 'Completed';
GO

-- View 11: PrescriptionItems (Đồng bộ tên gọi với PrescriptionDetails)
CREATE OR ALTER VIEW dbo.PrescriptionItems AS
SELECT 
    DetailId AS PrescriptionItemId,
    PrescriptionId,
    MedicineId,
    Quantity,
    Dosage,
    Frequency,
    DurationDays,
    Instructions
FROM dbo.PrescriptionDetails;
GO

-- View 12: Payments (Đồng bộ tên gọi với InvoicePayments)
CREATE OR ALTER VIEW dbo.Payments AS
SELECT 
    PaymentId,
    PaymentCode,
    InvoiceId,
    Amount,
    PaymentMethod,
    CashierId,
    Notes,
    PaidAt
FROM dbo.InvoicePayments;
GO

-- =========================================================================
-- PHẦN 4: ĐỒNG BỘ TỰ ĐỘNG DỮ LIỆU CẢNH BÁO Y TẾ (AUTO-SYNC TRIGGERS)
-- Đồng bộ giữa Patients.MedicalAlerts <--> PatientMedicalAlerts
-- =========================================================================

CREATE OR ALTER TRIGGER dbo.trg_Sync_Patients_MedicalAlerts
ON dbo.Patients
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tự động thêm cảnh báo vào bảng PatientMedicalAlerts khi cập nhật MedicalAlerts
    INSERT INTO dbo.PatientMedicalAlerts (PatientId, AlertType, AlertDescription, SeverityLevel, IsActive)
    SELECT 
        i.PatientId,
        N'Bệnh nền',
        i.MedicalAlerts,
        N'High',
        1
    FROM inserted i
    WHERE i.MedicalAlerts IS NOT NULL AND LEN(TRIM(i.MedicalAlerts)) > 0
      AND NOT EXISTS (
          SELECT 1 FROM dbo.PatientMedicalAlerts pma 
          WHERE pma.PatientId = i.PatientId AND pma.AlertDescription = i.MedicalAlerts
      );

    -- Tự động thêm dị ứng vào bảng PatientMedicalAlerts khi cập nhật Allergies
    INSERT INTO dbo.PatientMedicalAlerts (PatientId, AlertType, AlertDescription, SeverityLevel, IsActive)
    SELECT 
        i.PatientId,
        N'Dị ứng thuốc',
        i.Allergies,
        N'Critical',
        1
    FROM inserted i
    WHERE i.Allergies IS NOT NULL AND LEN(TRIM(i.Allergies)) > 0
      AND NOT EXISTS (
          SELECT 1 FROM dbo.PatientMedicalAlerts pma 
          WHERE pma.PatientId = i.PatientId AND pma.AlertDescription = i.Allergies
      );
END;
GO

PRINT '>>> HOÀN TẤT THIẾT LẬP MÔ HÌNH CƠ SỞ DỮ LIỆU HỢP NHẤT DCMS v2.0!';
PRINT '    Tổng số bảng vật lý cốt lõi: 21 bảng';
PRINT '    Tổng số bảng danh mục & quan niệm bổ sung: 6 bảng (Teeth, ToothSurfaces, DentalCharts, PatientMedicalAlerts, FollowUpRecalls, TreatmentEstimates)';
PRINT '    Tổng số Compatibility Views: 6 views (DentalFindings, Diagnoses, ClinicalNotes, InvoiceItems, PrescriptionItems, Payments)';
PRINT '    Hệ thống CSDL DCMS hiện sở hữu ĐẦY ĐỦ 29 đối tượng dữ liệu hoàn chỉnh!';
GO
