-- =======================================================
-- HỆ THỐNG QUẢN LÝ PHÒNG KHÁM HEALTHSYNC (OPTIMIZED SCHEMA)
-- =======================================================

DROP DATABASE IF EXISTS healthsync_db;
CREATE DATABASE healthsync_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE healthsync_db;

-- 1. Bảng Bệnh nhân
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 2. Bảng Bác sĩ
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- 3. Bảng Lịch hẹn (Đã tái cấu trúc chuẩn hóa)
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') 
           NOT NULL DEFAULT 'PENDING',
    deposit_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 4. Bảng Đơn thuốc (Thực thể mới bổ sung cho trạng thái COMPLETED)
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với lịch hẹn
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescriptions_appointment FOREIGN KEY (appointment_id) 
        REFERENCES Appointments(appointment_id) ON DELETE RESTRICT
);

-- =======================================================
-- BẢO VỆ TOÀN VẸN NGHIỆP VỤ BẰNG DATABASE TRIGGER
-- Ngăn chặn kê đơn thuốc khi lịch hẹn chưa COMPLETED
-- =======================================================
DELIMITER $$
CREATE TRIGGER trg_check_appointment_completed_before_prescription
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status FROM Appointments WHERE appointment_id = NEW.appointment_id;
    
    IF v_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Không thể kê đơn thuốc cho lịch hẹn chưa hoàn tất khám (COMPLETED).';
    END IF;
END$$
DELIMITER ;

-- =======================================================
-- DỮ LIỆU BAN ĐẦU (SEED DATA)
-- =======================================================
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn An', '0901112222'),
('Trần Thị Bình', '0903334444');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Lê Hoàng Nam', 'Khoa Nội'),
('BS. Phạm Mai Lan', 'Khoa Tai Mũi Họng');

-- =======================================================
-- MÔ PHỎNG CÁC KỊCH BẢN NGHIỆP VỤ THỰC TẾ (DML)
-- =======================================================

-- KỊCH BẢN 1: Luồng thành công (PENDING -> CHECKED_IN -> COMPLETED -> Kê đơn)
-- Bước 1.1: Đặt lịch và đặt cọc 500.000 VNĐ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-09-25 09:00:00', 'PENDING', 500000.00);

-- Bước 1.2: Bệnh nhân đến phòng khám
UPDATE Appointments 
SET status = 'CHECKED_IN' 
WHERE appointment_id = 1;

-- Bước 1.3: Bác sĩ khám xong
UPDATE Appointments 
SET status = 'COMPLETED' 
WHERE appointment_id = 1;

-- Bước 1.4: Kê đơn thuốc kèm lịch hẹn đã COMPLETED
INSERT INTO Prescriptions (appointment_id, medication_details, issued_date)
VALUES (1, 'Paracetamol 500mg (2 vỉ), Amoxicillin 500mg (1 hộp). Uống sau ăn.', NOW());


-- KỊCH BẢN 2: Bệnh nhân hủy lịch sau khi CONFIRMED (Phạt tiền cọc)
-- Bước 2.1: Đặt lịch và đã duyệt cọc 300.000 VNĐ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-09-26 14:00:00', 'CONFIRMED', 300000.00);

-- Bước 2.2: Bệnh nhân báo hủy, hệ thống phạt 150.000 VNĐ trừ vào cọc
UPDATE Appointments 
SET status = 'CANCELLED',
    cancel_reason = 'Bận việc đột xuất',
    penalty_fee = 150000.00
WHERE appointment_id = 2;

-- =======================================================
-- TRUY VẤN KIỂM TRA ĐỐI SOÁT
-- =======================================================

-- 1. Xem toàn bộ trạng thái lịch hẹn và dòng tiền cọc / phạt
SELECT 
    a.appointment_id,
    p.full_name AS ten_benh_nhan,
    d.full_name AS ten_bac_si,
    a.status,
    a.deposit_amount AS tien_coc,
    a.penalty_fee AS tien_phat,
    a.cancel_reason AS ly_do_huy
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- 2. Truy vấn danh sách bệnh nhân đã khám xong kèm đơn thuốc chi tiết
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';
