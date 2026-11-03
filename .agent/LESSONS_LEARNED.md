# LESSONS LEARNED & ANTI-PATTERNS (SỔ ĐEN LỖI & KINH NGHIỆM)

> **HƯỚNG DẪN DÀNH CHO AGENT:**
> Mỗi khi gặp lỗi, điều tra và sửa xong một vấn đề hóc búa (đặc biệt là lỗi phiên bản, lỗi cấu hình phần cứng hoặc API ngầm), 
> HÃY THÊM MỘT MỤC VÀO ĐÂY THEO ĐÚNG ĐỊNH DẠNG CHUẨN 3 PHẦN:
> 1. Triệu chứng (Symptom)
> 2. Nguyên nhân gốc rễ (Root Cause)
> 3. Quy tắc bắt buộc để phòng ngừa (Enforced Rule)

---

### [MẪU 1] Lỗi Khởi tạo ChromaDB Client (Persistent Storage)
* **Triệu chứng**: Chạy code bị lỗi `ValueError: Could not connect to tenant default_tenant` hoặc database mất sạch dữ liệu sau khi restart service.
* **Nguyên nhân gốc**: ChromaDB từ bản 0.4.x trở đi đã thay đổi API, không còn dùng `chromadb.Client()` thông thường cho lưu trữ vật lý.
* **Quy tắc bắt buộc**: BẮT BUỘC dùng `chromadb.PersistentClient(path="./data/chroma")`. Tuyệt đối không dùng `chromadb.Client()`.

---

### [MẪU 2] Lỗi Ollama Local Timeout khi chạy model nặng
* **Triệu chứng**: Client báo lỗi `HTTP 504 Gateway Timeout` hoặc `httpx.ReadTimeout` khi gọi Ollama sinh văn bản dài.
* **Nguyên nhân gốc**: Mặc định timeout của HTTP client thường chỉ là 5 - 10 giây, trong khi prompt dài cần 15 - 30 giây để hoàn thành tính toán.
* **Quy tắc bắt buộc**: Luôn set `timeout=httpx.Timeout(60.0, connect=10.0)` khi khởi tạo HTTP client gọi tới `http://localhost:11434`.

---

### [MẪU 3] Lỗi Phần cứng AMD / DirectML vs CUDA
* **Triệu chứng**: Chạy PyTorch / Torchvision bị văng lỗi `AssertionError: Torch not compiled with CUDA enabled` trên máy chạy GPU AMD (RX 6700 XT).
* **Nguyên nhân gốc**: Code copy trên mạng mặc định gọi `device = "cuda"` chỉ dành cho NVIDIA.
* **Quy tắc bắt buộc**: 
  - Với suy luận LLM: Ưu tiên dùng Ollama (tự tối ưu qua Vulkan/ROCm).
  - Với PyTorch: Bắt buộc dùng `device = "directml"` (qua package `torch-directml`) hoặc fallback về `"cpu"`. Cấm hardcode `"cuda"`.

---

---

### [MẪU 4] Docker Networking giữa Frontend và Backend Container
* **Triệu chứng**: Frontend Next.js trong Docker gọi API Backend qua `http://localhost:5012` bị lỗi `Connection Refused` hoặc màn hình báo "Dịch vụ đang tạm thời không khả dụng".
* **Nguyên nhân gốc**: Bên trong Docker container, `localhost` chỉ trỏ tới chính container đó chứ không trỏ ra máy Host.
* **Quy tắc bắt buộc**: Khi chạy multi-container trên Windows/Docker Desktop mà không dùng mạng nội bộ chung, biến `API_BASE_URL` của Frontend bắt buộc phải dùng `http://host.docker.internal:<port>`.

---

### [MẪU 5] Thông số đóng gói thực tế (Packaging Specifications) khi tính phí GHN
* **Triệu chứng**: Khách hàng bấm "Báo phí giao hàng" hoặc "Đặt hàng" bị chặn với lỗi 503: "Thông số đóng gói thực tế của sản phẩm chưa đủ hoặc chưa được Admin xác nhận; chưa thể báo phí hay tạo đơn."
* **Nguyên nhân gốc**: `ShippingQuoteService` và `CommerceService` bắt buộc mọi sản phẩm phải có `PackagingSpecsConfirmed = true` cùng các kích thước `ShippingWeightGrams`, `PackageLengthCm`, `PackageWidthCm`, `PackageHeightCm` hợp lệ trước khi cho phép GHN tính cước. Dữ liệu seed mặc định ban đầu bị thiếu các trường này.
* **Quy tắc bắt buộc**: Mọi sản phẩm khi tạo mới hoặc trong Seeder phải điền đầy đủ kích thước và kích hoạt `PackagingSpecsConfirmed = true`.

---

### [MẪU 6] Lỗi Cổng thanh toán VNPAY "Không tìm thấy website" (Merchant Website Not Found)
* **Triệu chứng**: Khi khách hàng bấm "Mở trực tiếp Cổng VNPAY Web Browser" hoặc gửi request tới `https://sandbox.vnpayment.vn/paymentv2/vpcpay.html`, trình duyệt hiển thị màn hình VNPAY với cảnh báo đỏ: `Thông báo: Không tìm thấy website (Mã tra cứu: ...)`.
* **Nguyên nhân gốc**:
  1. `vnp_TmnCode` (Terminal ID) dùng tài khoản test mẫu cũ đã bị VNPAY xóa/hủy kích hoạt tên miền website liên kết trên máy chủ sandbox của họ.
  2. Chuỗi bí mật `vnp_HashSecret` bị thiếu ký tự (cắt ngắn xuống 24 ký tự thay vì 32 bytes SHA512 tiêu chuẩn) khiến chữ ký không khớp.
  3. Cổng Sandbox của VNPAY yêu cầu mỗi `vnp_TmnCode` phải được liên kết với một Website Domain hợp lệ và Return URL trong trang quản trị Merchant Sandbox (`https://sandbox.vnpayment.vn/merchantv2/`).
* **Quy tắc bắt buộc**:
  1. Đăng ký tài khoản Sandbox cá nhân chính thức tại `https://sandbox.vnpayment.vn/devreg/` để nhận `vnp_TmnCode` và `vnp_HashSecret` riêng (hoạt động 100%).
  2. Bắt buộc kích hoạt/cập nhật Website URL trong Merchant Portal (`https://furni3d.vn` hoặc domain dự án).
  3. Trong ứng dụng, luôn cung cấp cơ chế đa kênh chuyên nghiệp: Cổng VietQR Napas 247 chuyển khoản ngân hàng thật (quét bằng mọi app Mobile Banking Vietcombank/MB/BIDV/Techcombank) và bộ thẻ test VNPAY Sandbox chính thức kèm nút sao chép 1-chạm để demo không bao giờ bị gián đoạn.

