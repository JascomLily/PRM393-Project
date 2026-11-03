# RULES & BEHAVIORAL CONTRACT (ĐẠO LUẬT HÀNH VI CỦA AGENT)

Tài liệu này định nghĩa các giới hạn và tiêu chuẩn hành vi của Agent khi thao tác trên codebase.

---

### 1. Nguyên tắc Bảo toàn Mã nguồn (Code Preservation)
* **Không "xóa đi làm lại từ đầu"**: Trừ khi người dùng yêu cầu rõ ràng, tuyệt đối không được viết lại toàn bộ một file lớn nếu chỉ cần sửa một vài hàm.
* **Bảo tồn Comment & Docstrings**: Giữ nguyên toàn bộ ghi chú và tài liệu sẵn có không liên quan đến phạm vi sửa đổi.
* **Tính tương thích ngược**: Đảm bảo các thay đổi không làm gãy (break) các module hoặc API endpoints đang hoạt động khác.

---

### 2. Nguyên tắc "Thực tế hơn Ảo tưởng" (No Assumptions)
* **Không bịa đặt thư viện**: Chỉ sử dụng các thư viện đã được khai báo trong dependencies (hoặc các thư viện chuẩn của ngôn ngữ). Nếu cần cài thư viện mới, phải giải thích lý do tại sao các thư viện hiện có không giải quyết được.
* **Xác thực đường dẫn & môi trường**: Luôn kiểm tra sự tồn tại của file, biến môi trường (`.env`), cổng mạng trước khi đưa ra kết luận.

---

### 3. Vòng lặp Kiểm chứng (Verification First)
* Một tính năng chỉ được xem là "Xong" (Definition of Done) khi:
  1. Mã nguồn không có lỗi cú pháp hoặc lỗi kiểu dữ liệu nghiêm trọng.
  2. Đã xử lý các trường hợp biên (Edge cases: rỗng, null, timeout, đầu vào sai format).
  3. Có ít nhất một kịch bản kiểm thử (test case) hoặc lệnh curl/cli để người dùng nghiệm thu ngay.
