Bản Phân Tích Kế Hoạch Thực Thi (EXPLAIN Analysis)

Trước khi tối ưu (Legacy):

type: ALL (Full Table Scan)

possible_keys / key: NULL

rows: ~5,000,000 dòng

Nguyên nhân: Mệnh đề WHERE YEAR(created_at) = 2026 AND MONTH(created_at) = 6 là truy vấn Non-SARGable. Việc bọc hàm quanh cột buộc MySQL phải quét toàn bộ bảng và tính toán hàm trên từng dòng, chiếm dụng 100% CPU và gây khóa tài nguyên.

Sau khi tối ưu (Refactored):

type: ref hoặc range

key: idx_type_date

rows: Giảm xuống chỉ còn ước tính vài nghìn dòng phát sinh trong tháng 6.

Extra: Using index condition

Cơ chế: Khởi tạo Composite Index (transaction_type, created_at) kết hợp chuyển đổi sang điều kiện khoảng created_at >= '2026-06-01' AND created_at < '2026-07-01' giúp biến truy vấn thành SARGable. Database Engine tận dụng cấu trúc B-Tree để nhảy thẳng đến vị trí dữ liệu (Index Seek) và quét trong phạm vi thu hẹp, giải phóng CPU tức thì.
