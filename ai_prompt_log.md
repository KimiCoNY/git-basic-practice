# AI PROMPT LOG

### Session 1: Lựa chọn kiểu dữ liệu cho trạng thái và tài chính
* **Prompt:** "Khi thiết kế các cột tiền tệ như `deposit_amount` và `penalty_fee` trong MySQL, tôi nên dùng kiểu `FLOAT`, `DOUBLE` hay `DECIMAL`? Tại sao kiểu số thực dấu phẩy động lại nguy hiểm trong kế toán?"
* **Takeaway:** Không dùng `FLOAT/DOUBLE` vì gặp lỗi sai số làm tròn nhị phân (IEEE 754 precision error). Luôn dùng `DECIMAL(M, D)` để đảm bảo độ chính xác tuyệt đối từng xu khi đối soát tài chính.

### Session 2: Giải pháp theo dõi vòng đời đơn hàng/lịch hẹn
* **Prompt:** "Tại sao việc dùng cột cờ `is_active BOOLEAN` lại là Anti-pattern đối với quy trình quản lý lịch hẹn khám bệnh có nhiều giai đoạn chuyển tiếp?"
* **Takeaway:** Cột cờ Boolean làm mất ngữ cảnh quy trình (không phân biệt được giữa lịch bị hủy, lịch chưa khám và lịch đã khám xong). Thay vào đó cần dùng `ENUM` định nghĩa rõ ràng State Machine (`PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED`, `CANCELLED`).

### Session 3: Ràng buộc tính toàn vẹn mức ứng dụng và CSDL
* **Prompt:** "Làm thế nào để chặn hoàn toàn hành vi INSERT đơn thuốc vào bảng `Prescriptions` nếu lịch hẹn chưa đạt trạng thái `COMPLETED` ở tầng CSDL MySQL?"
* **Takeaway:** Ràng buộc khóa ngoại chỉ kiểm tra sự tồn tại của `appointment_id`, không kiểm tra giá trị cột `status`. Cần triển khai `BEFORE INSERT TRIGGER` kết hợp `SIGNAL SQLSTATE '45000'` để chặn vi phạm logic từ gốc.


# NHẬT KÝ HỎI ĐÁP HIỆU NĂNG DATABASE (AI PROMPT LOG)

* **Vai trò:** Database Performance Engineer & Database Tuning Assistant (AI)
* **Chủ đề:** Tối ưu hóa truy vấn SARGable, cấu trúc B-Tree Index và phân tích luồng EXPLAIN.

---

### Phiên 1: Khái niệm SARGable và cơ chế vô hiệu hóa Index của hàm
* **Prompt:**
  "Thuật ngữ SARGable (Search Argument Able) trong SQL nghĩa là gì? Tại sao khi viết WHERE YEAR(created_at) = 2026, MySQL lại từ chối sử dụng B-Tree Index trên cột created_at và buộc phải chuyển sang Full Table Scan?"
* **Phản hồi của AI:**
  * SARGable chỉ các điều kiện tìm kiếm mà Database Engine có thể tận dụng cấu trúc chỉ mục để duyệt cây (Index Seek) thay vì quét toàn bộ dữ liệu.
  * Cây B-Tree lưu trữ các giá trị nguyên bản của `created_at` theo thứ tự sắp xếp. Khi áp dụng hàm `YEAR(created_at)`, giá trị đầu ra chưa được tính toán trước nằm trong cây Index. Engine không thể biết giá trị năm nằm ở nhánh nào nếu không lặp qua từng dòng và tính toán hàm đó, biến truy vấn thành Non-SARGable và kích hoạt Full Table Scan.

---

### Phiên 2: Thứ tự sắp xếp cột trong Composite Index
* **Prompt:**
  "Khi tạo Composite Index cho bảng Transactions phục vụ điều kiện `WHERE transaction_type = 'DEPOSIT' AND created_at >= '2026-06-01' AND created_at < '2026-07-01'`, thứ tự (transaction_type, created_at) hay (created_at, transaction_type) sẽ tối ưu hơn theo nguyên lý Leftmost Prefix?"
* **Phản hồi của AI:**
  * Thứ tự tối ưu bắt buộc phải là `(transaction_type, created_at)`.
  * Trong cơ chế B-Tree, việc lọc khoảng (Range Filter) như `>=` hoặc `<` trên một cột sẽ khiến các cột đứng phía sau nó không thể tận dụng được cấu trúc chỉ mục để tìm kiếm nhị phân nữa.
  * Đặt cột so khớp chính xác (`transaction_type = 'DEPOSIT'`) lên đầu giúp thu hẹp phạm vi về một phân nhánh duy nhất (ref lookup), sau đó cột `created_at` tiếp tục thực hiện quét khoảng (range scan) trên phân nhánh đó một cách mượt mà.

---

### Phiên 3: Ý nghĩa các chỉ số trong EXPLAIN và kỹ thuật Profiling
* **Prompt:**
  "Trong kết quả EXPLAIN của MySQL, giá trị của cột `type` biểu thị mức độ hiệu năng như thế nào từ tệ nhất đến tốt nhất? Khác biệt cốt lõi giữa 'Using index' và 'Using index condition' ở cột Extra là gì?"
* **Phản hồi của AI:**
  * Xếp hạng thứ tự hiệu năng của `type`: `ALL` (tệ nhất) < `index` < `range` < `ref` < `eq_ref` < `const` / `system` (tốt nhất).
  * `Using index` (Covering Index): Toàn bộ dữ liệu truy vấn cần thiết đều nằm trọn trong cấu trúc Index, MySQL lấy kết quả trực tiếp từ RAM mà không cần đọc bảng gốc (Clustered Index / Table Data).
  * `Using index condition` (Index Condition Pushdown - ICP): MySQL Engine đẩy điều kiện lọc xuống tầng lưu trữ (Storage Engine) để loại bỏ bớt các dòng không hợp lệ ngay tại tầng Index trước khi quay lại lấy toàn bộ dòng trong bảng, giúp tiết kiệm Disk I/O đáng kể.
