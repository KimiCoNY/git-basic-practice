-- Bước 1: Sử dụng cơ sở dữ liệu QuanLySinhVien
USE QuanLySinhVien;

-- Bước 2: Hiển thị số lượng sinh viên ở từng nơi
SELECT Address, COUNT(StudentId) AS 'Số lượng học viên'
FROM Student
GROUP BY Address;

-- Bước 3: Tính điểm trung bình các môn học của mỗi học viên
SELECT S.StudentId, S.StudentName, AVG(M.Mark) AS 'Điểm trung bình'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName;

-- Bước 4: Hiển thị những học viên có điểm trung bình các môn học lớn hơn 15
SELECT S.StudentId, S.StudentName, AVG(M.Mark) AS 'Điểm trung bình'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(M.Mark) > 15;

-- Bước 5: Hiển thị thông tin các học viên có điểm trung bình lớn nhất
-- Dùng HAVING kết hợp toán tử >= ALL trên tập hợp điểm trung bình của tất cả học viên
SELECT S.StudentId, S.StudentName, AVG(M.Mark) AS 'Điểm trung bình'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(M.Mark) >= ALL (
    SELECT AVG(Mark) 
    FROM Mark 
    GROUP BY StudentId
);
