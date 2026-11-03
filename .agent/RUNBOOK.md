# RUNBOOK & VERIFICATION CHECKS (CẨM NANG VẬN HÀNH & KIỂM THỬ)

Tài liệu này chứa các câu lệnh tiêu chuẩn để thiết lập, chạy kiểm thử và đảm bảo chất lượng trước khi nộp code.

---

## 1. Thiết lập Môi trường (Environment Setup)
```bash
# Tạo và kích hoạt môi trường ảo Python
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

# Cài đặt dependencies
pip install -r requirements.txt
```

---

## 2. Kiểm tra Chất lượng Code (Linter & Type Check)
Agent hoặc lập trình viên phải chạy các lệnh này trước khi commit:

```bash
# 1. Kiểm tra lỗi cú pháp và chuẩn code (Ruff / Flake8)
ruff check .

# 2. Tự động format code theo chuẩn
ruff format .

# 3. Kiểm tra kiểu dữ liệu tĩnh (Type Checking)
mypy app/
```

---

## 3. Chạy Kiểm thử Tự động (Testing)
```bash
# Chạy toàn bộ Unit Tests & Integration Tests
pytest -v

# Chạy test kèm đo độ phủ code (Coverage)
pytest --cov=app tests/
```

---

## 4. Chạy Ứng dụng & Kiểm tra Healthcheck
```bash
# Khởi chạy FastAPI Backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Kiểm tra xem API Server đã sống chưa
curl http://localhost:8000/health
```
