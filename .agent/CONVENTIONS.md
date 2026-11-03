# CODE CONVENTIONS & STYLE GUIDE (QUY CHUẨN MÃ NGUỒN)

Tài liệu này định nghĩa các chuẩn mực code để đảm bảo toàn bộ codebase đồng nhất, sạch sẽ và dễ bảo trì.

---

## 1. Định dạng Phản hồi API (Standard API Response)
Tất cả các API endpoint phải trả về cấu trúc JSON đồng nhất:

```json
{
  "success": true,
  "data": { ... },
  "message": "Mô tả ngắn gọn về kết quả",
  "error": null
}
```

Khi có lỗi:
```json
{
  "success": false,
  "data": null,
  "message": "Không thể xử lý yêu cầu",
  "error": {
    "code": "INVALID_CROP_ID",
    "details": "Mã cây trồng không tồn tại trong cơ sở dữ liệu"
  }
}
```

---

## 2. Quy tắc Xử lý Ngoại lệ (Error Handling)
* **KHÔNG BAO GIỜ nuốt lỗi**: Tuyệt đối cấm viết `try: ... except: pass`. Mọi lỗi đều phải được log lại hoặc ném ra exception rõ ràng.
* **Tự tạo Custom Exceptions**: Tạo các class kế thừa từ Exception cơ bản (ví dụ: `class ModelInferenceError(Exception): pass`) để tầng Controller dễ bắt và phân loại HTTP status code.

---

## 3. Quy chuẩn Đặt tên (Naming Conventions)
* **Python**:
  * Biến, hàm, module: `snake_case` (ví dụ: `calculate_market_trend()`, `user_id`).
  * Class, Schema: `PascalCase` (ví dụ: `MarketAnalyzerService`, `CropRecommendationRequest`).
  * Hằng số: `UPPER_SNAKE_CASE` (ví dụ: `DEFAULT_OLLAMA_TIMEOUT = 60.0`).
* **REST API**:
  * Đặt tên endpoint dùng danh từ số nhiều: `/api/v1/crops`, `/api/v1/markets`.
  * Dùng đúng động từ HTTP: `GET` (lấy dữ liệu), `POST` (tạo mới/tính toán AI), `PUT`/`PATCH` (sửa), `DELETE` (xóa).

---

## 4. Type Annotations (Ép kiểu tĩnh)
* 100% các hàm mới bắt buộc phải có Type Hints cho tất cả các tham số đầu vào và giá trị trả về:
  ```python
  async def recommend_crops(
      farm_id: int, 
      budget: float, 
      top_k: int = 3
  ) -> list[CropRecommendation]:
      ...
  ```
