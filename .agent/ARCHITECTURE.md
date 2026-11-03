# ARCHITECTURE & SYSTEM DESIGN (BẢN ĐỒ KIẾN TRÚC HỆ THỐNG)

> *Điền thông tin dự án cụ thể vào đây để Agent không bao giờ "đi lạc" kiến trúc.*

---

## 1. Tech Stack Cốt lõi
* **Language & Runtime**: Python 3.11+ / Node.js 20+ / C# .NET / v.v.
* **Backend Framework**: FastAPI / Express / NestJS
* **Database & Storage**: PostgreSQL (Relational) / ChromaDB (Vector DB) / Redis (Cache)
* **AI Engine / LLM**: Ollama Local (Qwen 2.5:3B / 7B) / OpenAI API
* **Client / UI**: React / Vue / Streamlit / Unity C#

---

## 2. Phân tầng Trách nhiệm (Architectural Layers)
Tuân thủ nghiêm ngặt mô hình phân tầng sau, cấm gọi tắt vượt cấp:

```
[ Client / UI ] ──(HTTP/JSON)──> [ API Controllers / Routes ]
                                          │
                                          ▼
                                 [ Service Layer ] (Business Logic & AI Prompting)
                                          │
                        ┌─────────────────┴─────────────────┐
                        ▼                                   ▼
              [ Database Repositories ]           [ External Clients / AI APIs ]
              (SQLAlchemy / ChromaDB)             (Ollama / HTTPX / Microservices)
```

1. **API Layer (`/routes` hoặc `/controllers`)**:
   * Chỉ nhận request, validate schema (Pydantic / DTO), ủy quyền cho Service và trả về HTTP Response.
   * **CẤM**: Không viết logic tính toán phức tạp hoặc truy vấn DB trực tiếp tại đây.
2. **Service Layer (`/services`)**:
   * Nơi chứa trái tim của ứng dụng: thuật toán tính toán (Pandas), logic thương nhân AI, ghép context RAG, gọi LLM.
3. **Repository Layer (`/repositories` hoặc `/crud`)**:
   * Nơi duy nhất được phép tương tác với Database qua ORM hoặc query.

---

## 3. Danh sách Thư viện: Khuyên dùng vs. BỊ CẤM

| Loại tác vụ | Thư viện KHUYÊN DÙNG | Thư viện BỊ CẤM / NÉ TRÁNH | Lý do kỹ thuật |
| :--- | :--- | :--- | :--- |
| **HTTP Client** | `httpx` (async) | `requests` (blocking sync) | `requests` làm nghẽn Event Loop của FastAPI |
| **Database ORM** | `SQLAlchemy 2.0` (AsyncSession) | Raw SQL string ghép thủ công | Nguy cơ SQL Injection & không async |
| **Data Schema** | `Pydantic v2` (`.model_dump()`) | `pydantic.BaseModel` v1 (`.dict()`) | Tránh cảnh báo deprecated và tối ưu tốc độ |
| **Data Science** | `pandas`, `numpy` | Vòng lặp `for` lồng nhau qua mảng lớn | Kém hiệu năng hơn vectorized operations |
