-- Sử dụng cơ sở dữ liệu QuanLySinhVien
USE QuanLySinhVien;

-- 1. Hiển thị danh sách tất cả các học viên
SELECT * 
FROM Student;

-- 2. Hiển thị danh sách các học viên đang theo học (Status = true hoặc 1)
SELECT * 
FROM Student 
WHERE Status = true;

-- 3. Hiển thị danh sách các môn học có thời gian học (Credit) nhỏ hơn 10
SELECT * 
FROM Subject 
WHERE Credit < 10;

-- 4. Hiển thị danh sách học viên lớp A1 (kết hợp JOIN giữa Student và Class)
SELECT S.StudentId, S.StudentName, C.ClassName
FROM Student S 
JOIN Class C ON S.ClassId = C.ClassID
WHERE C.ClassName = 'A1';

-- 5. Hiển thị điểm môn CF của các học viên (kết hợp JOIN giữa Student, Mark và Subject)
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId 
JOIN Subject Sub ON M.SubId = Sub.SubId
WHERE Sub.SubName = 'CF';
