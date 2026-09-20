# BÁO CÁO PHÂN TÍCH ĐỐI CHIẾU (GAP ANALYSIS REPORT)
**Hệ thống:** Phòng khám đa khoa HealthSync  
**Vai trò:** System Analyst & Database Administrator  

Qua đối chiếu giữa UML Activity Diagram do BA xây dựng và mã nguồn CSDL cũ (Legacy SQL), chúng tôi ghi nhận 4 điểm vênh nghiêm trọng khiến hệ thống thất bại khi đưa vào thử nghiệm:

1. **Sai lệch mô hình trạng thái vòng đời (Anti-pattern Boolean):** Cột `is_active BOOLEAN` chỉ biểu diễn được trạng thái nhị phân (Đúng/Sai). Nó hoàn toàn bất khả thi khi biểu diễn quy trình 5 bước nghiệp vụ bắt buộc: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`.
2. **Thất thoát dữ liệu tài chính (Missing Financial Fields):** Hệ thống yêu cầu thu tiền cọc khi đặt và phạt tiền cọc khi hủy sau khi đã xác nhận. Tuy nhiên bảng `Appointments` không hề có các trường `deposit_amount` và `penalty_fee`, khiến nghiệp vụ phạt cọc và đối soát dòng tiền của kế toán không thể ghi nhận.
3. **Thiếu thông tin kiểm toán khi hủy (Missing Audit Trail):** Khi lịch bị hủy, nghiệp vụ yêu cầu ghi nhận lý do nhưng schema cũ thiếu cột `cancel_reason`.
4. **Vắng mặt hoàn toàn thực thể Đơn thuốc (Missing Prescription Entity):** Nghiệp vụ yêu cầu bác sĩ kê đơn khi lịch hẹn chuyển sang `COMPLETED`, nhưng schema không có bảng `Prescriptions`. Điều này vi phạm nghiêm trọng tính toàn vẹn chức năng khám chữa bệnh.
