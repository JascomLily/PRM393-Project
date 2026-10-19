# 🛋️ FURNI3D MOBILE - PRM393 FLUTTER PROJECT

Ứng dụng thương mại điện tử bán nội thất thông minh tích hợp hướng dẫn lắp ráp 3D Unity, đối soát thanh toán VNPAY Sandbox, tích lũy điểm thưởng Xu (FurniCoins) và GPS tracking tài xế giao hàng.

Dự án được xây dựng chuẩn theo yêu cầu môn học **PRM393 (Mobile Programming)**.

---

## 🏗️ Cấu trúc thư mục (Architecture: MVC / N-Layer with Provider)

```
PRM393-Project/
├── lib/
│   ├── data/
│   │   └── mock_data.dart              # Dữ liệu mẫu sản phẩm, voucher, tài khoản demo
│   ├── models/
│   │   ├── user_model.dart             # Model người dùng, vai trò customer/admin, ví xu
│   │   ├── product_model.dart          # Model sản phẩm, phân loại, thông số 3D
│   │   ├── cart_item_model.dart        # Model món trong giỏ hàng
│   │   ├── order_model.dart            # Model đơn hàng, timeline giao hàng, driver tracking
│   │   └── voucher_model.dart          # Model mã ưu đãi giảm giá
│   ├── providers/
│   │   ├── auth_provider.dart          # Quản lý Đăng nhập, Đăng ký, Google login, session SharedPreferences
│   │   ├── cart_provider.dart          # Quản lý giỏ hàng, tính phí ship, trừ điểm Xu FurniCoins, áp voucher
│   │   └── order_provider.dart         # Quản lý đơn hàng, lưu mã GD VNPAY, cập nhật trạng thái
│   ├── screens/
│   │   ├── main_navigation_screen.dart # Thanh điều hướng BottomNavigationBar (5 Tabs)
│   │   ├── auth/
│   │   │   ├── login_screen.dart         # Đăng nhập Email/Pass, 1-Click Demo Fill, Google Login
│   │   │   ├── register_screen.dart      # Đăng ký thành viên (+100 Xu thưởng)
│   │   │   └── forgot_password_screen.dart # Quên mật khẩu & OTP test 123456
│   │   ├── profile/
│   │   │   └── profile_screen.dart       # Xem/sửa thông tin, số dư ví Xu, đổi vai trò, đăng xuất
│   │   ├── explore/
│   │   │   ├── explore_screen.dart       # Duyệt sản phẩm theo danh mục, tìm kiếm, banner 3D
│   │   │   └── product_detail_screen.dart # Chi tiết sản phẩm, chọn loại gỗ, thêm giỏ, Mua ngay
│   │   ├── cart/
│   │   │   └── cart_screen.dart          # Quản lý giỏ hàng, áp mã giảm giá, tick dùng Xu thưởng
│   │   ├── checkout/
│   │   │   ├── checkout_screen.dart      # Điền thông tin người nhận, chọn phương thức thanh toán
│   │   │   ├── vnpay_qr_screen.dart      # Cổng VNPAY QR Sandbox, mã QR động, đếm ngược 15:00
│   │   │   ├── vnpay_atm_screen.dart     # Thẻ ATM nội địa NCB Sandbox (có nút điền nhanh thẻ test) & OTP
│   │   │   └── order_success_screen.dart # Chúc mừng đặt hàng, nhận +30 Xu, xem hóa đơn
│   │   ├── orders/
│   │   │   ├── orders_screen.dart        # Danh sách đơn hàng, lọc trạng thái, đánh giá camera (+50 Xu)
│   │   │   ├── vnpay_invoice_dialog.dart # Hóa đơn điện tử VNPAY (in / lưu PDF)
│   │   │   └── driver_tracking_dialog.dart # GPS tracking tài xế trên bản đồ giả lập
│   │   ├── model3d/
│   │   │   └── model3d_screen.dart       # Giả lập hướng dẫn bóc tách linh kiện 3D Unity xoay 360°
│   │   ├── parts/
│   │   │   └── parts_screen.dart         # Báo cáo thiếu linh kiện & mua lẻ linh kiện thay thế
│   │   └── admin/
│   │       └── admin_screen.dart         # Quản lý doanh thu, duyệt đơn hàng, bật tắt voucher
│   └── main.dart                         # Khởi chạy MultiProvider & cấu hình ThemeData
├── docs/                                 # Tài liệu đặc tả môn học PRM393
└── stitch_prototype/                     # Prototype giao diện UI tham khảo
```

---

## 🚀 Hướng dẫn chạy ứng dụng

### 1. Cài đặt thư viện dependencies
```bash
flutter pub get
```

### 2. Chạy ứng dụng

- **Chạy trên trình duyệt Web (Chrome):**
```bash
flutter run -d chrome
```

- **Chạy trên thiết bị Android (Máy ảo hoặc thiết bị thật kết nối USB):**
```bash
flutter run
```

- **Chạy trên thiết bị Windows Desktop:**
```bash
flutter run -d windows
```

---

## 🔑 Tài khoản Demo (Hỗ trợ 1-Click Fill trên màn hình Đăng nhập)

- 👤 **Khách hàng**: `customer@furni3d.vn` / Mật khẩu: `123456`
- 👑 **Quản trị viên (Admin)**: `admin@furni3d.vn` / Mật khẩu: `admin123`
- 🌐 **Đăng nhập Google**: Bấm nút *"Đăng nhập với Google"* để xác thực và trải nghiệm tức thì.

---

## 💳 Thông tin Thẻ Test VNPAY Sandbox

- **Ngân hàng**: NCB - Ngân hàng Quốc Dân
- **Số thẻ ATM**: `9704 1985 2619 1432` *(có nút Điền nhanh trên màn hình thanh toán)*
- **Tên chủ thẻ**: `NGUYEN VAN A`
- **Ngày phát hành**: `07/15`
- **Mã OTP xác thực**: `123456`
