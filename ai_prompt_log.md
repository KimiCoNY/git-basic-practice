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
