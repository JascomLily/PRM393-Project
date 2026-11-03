# PROJECT STATUS & DEV REPORT (MẪU BÁO CÁO TIẾN ĐỘ & KỸ THUẬT)

> *File này dùng để tự động tổng hợp tiến độ, các vấn đề kỹ thuật đã giải quyết để đưa vào Slide báo cáo hoặc Luận văn / Đồ án tốt nghiệp.*

---

## 📌 1. Tổng quan Dự án (Project Overview)
* **Tên Dự án**: AI Merchant / Hệ thống phân tích thị trường nông nghiệp
* **Giai đoạn Hiện tại**: Sprint X / Triển khai tích hợp RAG & LLM
* **Mục tiêu chính**: Kết nối Ollama Qwen 2.5:3B với cơ sở dữ liệu thị trường và vector DB.

---

## 🚀 2. Các Tính năng Đã Hoàn thành (Completed Deliverables)
* [x] **Backend Infrastructure**: Dựng API Gateway với FastAPI, tích hợp AsyncSession với PostgreSQL.
* [x] **Data Analytics Module**: Xây dựng thuật toán phân tích xu hướng giá nông sản và tính toán ROI bằng Pandas.
* [x] **RAG Pipeline**: Nhúng dữ liệu kỹ thuật nông nghiệp vào ChromaDB sử dụng mô hình embedding nội bộ.
* [x] **AI Persona Engine**: Thiết lập System Prompt cho Thương nhân AI trên mô hình `Qwen 2.5:3B`.

---

## 🛠️ 3. Nhật ký Kỹ thuật & Sự cố đã Khắc phục (Engineering Post-Mortem)
*Ghi lại các thử thách kỹ thuật quan trọng (rất được Hội đồng chấm đồ án đánh giá cao về tư duy giải quyết vấn đề):*

1. **Vấn đề**: Giảm độ trễ suy luận AI trên phần cứng cục bộ.
   * **Giải pháp**: Lựa chọn mô hình `Qwen 2.5:3B` với lượng tử hóa 4-bit, tận dụng 12GB VRAM của card đồ họa, đưa độ trễ từ 4.2s xuống còn < 0.6s.
2. **Vấn đề**: Đồng bộ hóa dữ liệu thời gian thực giữa Database và Prompt LLM.
   * **Giải pháp**: Xây dựng kiến trúc phân tầng: Pandas xử lý số liệu định lượng trước, sau đó tiêm vào ngữ cảnh (Context Injection) cho LLM xử lý ngôn ngữ tự nhiên.

---

## 📋 4. Kế hoạch Tiếp theo (Next Steps / Roadmap)
* [ ] Hoàn thiện kết nối API từ Client (Unity C# WebRequest / Web UI).
* [ ] Kiểm thử tải (Stress test) khả năng phục vụ đồng thời của mô hình AI nội bộ.
* [ ] Chuẩn bị kịch bản Demo và số liệu đo lường độ chính xác của gợi ý nông sản.
