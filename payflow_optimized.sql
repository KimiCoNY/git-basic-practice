-- ========================================================
-- HỆ THỐNG VÍ ĐIỆN TỬ PAYFLOW - DATABASE PERFORMANCE TUNING
-- ========================================================
USE payflow_db;

-- 1. Tạo Composite Index (B-Tree Index) tối ưu cho mệnh đề WHERE
-- Thứ tự: transaction_type (so khớp chính xác '=' -> ref) đứng trước,
-- created_at (lọc khoảng thời gian range -> range) đứng sau.
CREATE INDEX idx_type_date ON Transactions(transaction_type, created_at);

-- 2. Kiểm tra kế hoạch thực thi (Execution Plan) sau khi tối ưu
-- Chuyển điều kiện Non-SARGable (YEAR, MONTH) thành SARGable Range Filter
EXPLAIN 
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at < '2026-07-01 00:00:00';

-- 3. Câu lệnh truy vấn chính thức đưa vào Production
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at < '2026-07-01 00:00:00';
