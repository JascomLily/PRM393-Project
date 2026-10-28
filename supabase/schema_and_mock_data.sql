-- ============================================================================
-- SOFA SO GOOD - MOBILE APPLICATION
-- SUPABASE POSTGRESQL SCHEMA & SEED DATA
-- Chạy script này trong Supabase Dashboard -> SQL Editor -> Run
-- Script này an toàn và có thể chạy lại nhiều lần (Idempotent) mà không bị lỗi.
-- ============================================================================

-- BẬT EXTENSION UUID (Nếu chưa có)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. BẢNG HỒ SƠ NGƯỜI DÙNG (PROFILES)
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    avatar TEXT,
    furni_coins INTEGER DEFAULT 0,
    saved_address TEXT,
    role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Đảm bảo cột is_active tồn tại nếu bảng đã được tạo trước đó
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 2. BẢNG SẢN PHẨM (PRODUCTS)
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    subtitle TEXT,
    material TEXT,
    price BIGINT NOT NULL,
    original_price BIGINT,
    rating NUMERIC(2,1) DEFAULT 5.0,
    review_count INTEGER DEFAULT 0,
    image TEXT NOT NULL,
    badge TEXT,
    category TEXT NOT NULL CHECK (category IN ('desk', 'chair', 'shelf', 'lamp', 'parts')),
    assembly_time_minutes INTEGER DEFAULT 15,
    description TEXT,
    is_3d_ready BOOLEAN DEFAULT true,
    model_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. BẢNG MÃ GIẢM GIÁ (VOUCHERS)
CREATE TABLE IF NOT EXISTS public.vouchers (
    code TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value BIGINT NOT NULL,
    min_spend BIGINT NOT NULL DEFAULT 0,
    max_discount BIGINT DEFAULT 500000,
    expiry_date TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. BẢNG ĐƠN HÀNG (ORDERS)
CREATE TABLE IF NOT EXISTS public.orders (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    user_id TEXT REFERENCES public.profiles(id) ON DELETE SET NULL,
    date TEXT NOT NULL,
    estimated_delivery TEXT,
    total_amount BIGINT NOT NULL,
    payment_method TEXT NOT NULL, -- 'VNPAY_QR', 'VNPAY_ATM', 'COD'
    payment_status TEXT NOT NULL, -- 'PAID', 'PENDING'
    transaction_id TEXT,
    status TEXT NOT NULL DEFAULT 'shipping', -- 'pending', 'processing', 'shipping', 'completed', 'cancelled'
    receiver_name TEXT NOT NULL,
    receiver_phone TEXT NOT NULL,
    shipping_address TEXT NOT NULL,
    order_note TEXT,
    review_stars INTEGER,
    review_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. BẢNG CHI TIẾT ĐƠN HÀNG (ORDER_ITEMS)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id TEXT REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id TEXT,
    name TEXT NOT NULL,
    price BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    image TEXT NOT NULL,
    variant TEXT
);

-- 6. BẢNG BÁO THIẾU LINH KIỆN (MISSING_REPORTS)
CREATE TABLE IF NOT EXISTS public.missing_reports (
    id TEXT PRIMARY KEY,
    order_code TEXT NOT NULL,
    product_name TEXT NOT NULL,
    part_name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    note TEXT NOT NULL,
    photo_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'DELIVERING', 'COMPLETED')),
    admin_note TEXT,
    created_at TEXT NOT NULL
);

-- 7. BẢNG YÊU CẦU ĐỔI TRẢ & HOÀN TIỀN (RETURN_REQUESTS)
CREATE TABLE IF NOT EXISTS public.return_requests (
    id TEXT PRIMARY KEY,
    order_code TEXT NOT NULL,
    reason TEXT NOT NULL CHECK (reason IN ('DEFECTIVE', 'TRANSIT_DAMAGE', 'MISMATCH_3D', 'OTHER')),
    note TEXT NOT NULL,
    photo_url TEXT NOT NULL,
    return_method TEXT NOT NULL CHECK (return_method IN ('REFUND', 'EXCHANGE')),
    refund_amount BIGINT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'REFUNDED')),
    admin_response TEXT,
    created_at TEXT NOT NULL
);

-- ============================================================================
-- CẤU HÌNH ROW LEVEL SECURITY (RLS)
-- Xóa policy cũ trước nếu đã tồn tại để tránh lỗi 42710 (policy already exists)
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vouchers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missing_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.return_requests ENABLE ROW LEVEL SECURITY;

-- 1. Drop existing policies if any
DROP POLICY IF EXISTS "Public Read Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Public All Profiles" ON public.profiles;

DROP POLICY IF EXISTS "Public Read Products" ON public.products;
DROP POLICY IF EXISTS "Public All Products" ON public.products;

DROP POLICY IF EXISTS "Public Read Vouchers" ON public.vouchers;
DROP POLICY IF EXISTS "Public All Vouchers" ON public.vouchers;

DROP POLICY IF EXISTS "Public Read Orders" ON public.orders;
DROP POLICY IF EXISTS "Public All Orders" ON public.orders;

DROP POLICY IF EXISTS "Public Read Order Items" ON public.order_items;
DROP POLICY IF EXISTS "Public All Order Items" ON public.order_items;

DROP POLICY IF EXISTS "Public Read Missing Reports" ON public.missing_reports;
DROP POLICY IF EXISTS "Public All Missing Reports" ON public.missing_reports;

DROP POLICY IF EXISTS "Public Read Return Requests" ON public.return_requests;
DROP POLICY IF EXISTS "Public All Return Requests" ON public.return_requests;

-- 2. Tạo policy đầy đủ quyền (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY "Public All Profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Products" ON public.products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Vouchers" ON public.vouchers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Orders" ON public.orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Order Items" ON public.order_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Missing Reports" ON public.missing_reports FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public All Return Requests" ON public.return_requests FOR ALL USING (true) WITH CHECK (true);

-- ============================================================================
-- DỮ LIỆU MẪU (SEED DATA)
-- ============================================================================

-- Làm sạch dữ liệu cũ khi nạp lại
DELETE FROM public.order_items;
DELETE FROM public.orders;
DELETE FROM public.missing_reports;
DELETE FROM public.return_requests;
DELETE FROM public.vouchers;
DELETE FROM public.products;
DELETE FROM public.profiles;

-- 1. Insert Profiles
INSERT INTO public.profiles (id, name, email, phone, avatar, furni_coins, saved_address, role, is_active) VALUES
('usr-01', 'Đặng Thảo Vy', 'customer@furni3d.vn', '0983 838 311', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 150, 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh', 'customer', true),
('usr-02', 'Quản Trị Viên Sofa so good', 'admin@furni3d.vn', '1900 8383', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 9999, 'Trụ sở Sofa so good, Tầng 32 Landmark 81, TP. Hồ Chí Minh', 'admin', true);

-- 2. Insert Products
INSERT INTO public.products (id, name, subtitle, material, price, original_price, rating, review_count, image, badge, category, assembly_time_minutes, description, is_3d_ready, model_code) VALUES
('nordic-desk', 'Nordic Oak Desk', 'Gỗ sồi Bắc Âu tự nhiên', 'Gỗ sồi trắng nhập khẩu & phụ kiện mạ kẽm', 2450000, 2890000, 4.9, 128, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', '3D Ready', 'desk', 25, 'Bàn làm việc Scandinavian thanh lịch với đường bo góc mềm mại, kết cấu mộng âm dương không cần keo dán độc hại. Tích hợp ống luồn dây cáp ẩn tinh tế.', true, 'MODEL ND-2024'),
('poang-chair', 'Poäng Scandi Chair', 'Ghế thư giãn uốn nhiệt', 'Gỗ bạch dương ép nhiệt & đệm vải Linen tự nhiên', 1850000, 2190000, 4.8, 94, 'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80', '15 Phút', 'chair', 15, 'Ghế thư giãn công thái học độ cong chuẩn sinh học cột sống. Khung gỗ đàn hồi tự nhiên tạo nhịp bập bênh êm ái thư thái sau ngày làm việc.', true, 'MODEL PC-108'),
('kallax-shelf', 'Kallax Modular Shelf 4x2', 'Kệ tủ mô-đun đa năng', 'Gỗ công nghiệp lõi xanh chống ẩm E0 phủ Melamine vân sồi', 1650000, 1950000, 4.7, 83, 'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?auto=format&fit=crop&w=800&q=80', 'Đa năng', 'shelf', 30, 'Hệ thống kệ 8 ô chứa đồ mô-đun tùy biến cao. Có thể xoay dọc làm kệ sách hoặc đặt ngang làm vách ngăn phòng khách hiện đại.', true, 'MODEL KS-402'),
('stranne-light', 'Stranne Nordic Desk Lamp', 'Đèn bàn kim loại tối giản', 'Thép sơn tĩnh điện mờ & đế gỗ thông', 520000, 650000, 4.9, 41, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'Ánh sáng 3000K', 'lamp', 5, 'Đèn bàn phong cách Hygge ánh sáng vàng ấm chống lóa mắt, cổ xoay đa hướng 360 độ.', false, 'MODEL SL-301'),
('part-bolt-m6', 'Bộ 10 Bu-lông M6 Mạ Kẽm', 'Linh kiện thay thế chính hãng', 'Thép mạ kẽm cường độ cao chống rỉ sét', 45000, 60000, 5.0, 15, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'Gửi nhanh', 'parts', 1, 'Bộ bu-lông ren M6 tiêu chuẩn vừa khít cho toàn bộ các sản phẩm bàn ghế Sofa so good.', false, 'PART-M6-10'),
('part-wood-dowel', 'Túi 20 Chốt Gỗ Mộng Beech', 'Chốt mộng định vị', 'Gỗ dẻ gai ép vân gân chống trượt', 30000, 40000, 4.9, 29, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'Chính xác', 'parts', 1, 'Chốt gỗ mộng định vị liên kết các tấm gỗ không cần bắt vít xuyên bề mặt.', false, 'PART-DOW-20');

-- 3. Insert Vouchers
INSERT INTO public.vouchers (code, title, discount_type, discount_value, min_spend, max_discount, expiry_date, is_active) VALUES
('FURNI10', 'Giảm 10% đơn từ 1.000.000₫', 'percentage', 10, 1000000, 300000, '31/12/2026', true),
('SCANDI200', 'Giảm trực tiếp 200.000₫ cho bàn ghế', 'fixed', 200000, 2000000, 200000, '31/12/2026', true),
('FREESHIP', 'Miễn phí giao hàng nội thành', 'fixed', 50000, 500000, 50000, '31/12/2026', true),
('WELCOME50', 'Ưu đãi thành viên mới -50k', 'fixed', 50000, 300000, 50000, '30/11/2026', true);

-- 4. Insert Orders
INSERT INTO public.orders (id, code, user_id, date, estimated_delivery, total_amount, payment_method, payment_status, transaction_id, status, receiver_name, receiver_phone, shipping_address, order_note) VALUES
('ord-01', 'F3D-882194', 'usr-01', '26/10/2026 09:15', 'Hôm nay, 16:30 - 18:30', 2250000, 'VNPAY_ATM', 'PAID', 'VNP202610260915882194', 'shipping', 'Đặng Thảo Vy', '0983 838 311', 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh', 'Giao giờ hành chính, gọi trước 15 phút'),
('ord-02', 'F3D-771032', 'usr-01', '20/10/2026 14:00', 'Đã giao thành công', 1850000, 'COD', 'PAID', 'COD20261020771032', 'completed', 'Đặng Thảo Vy', '0983 838 311', 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh', 'Để ở quầy lễ tân tầng G');

-- 5. Insert Order Items
INSERT INTO public.order_items (order_id, product_id, name, price, quantity, image, variant) VALUES
('ord-01', 'nordic-desk', 'Nordic Oak Desk', 2450000, 1, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'Gỗ sồi tự nhiên 120x60cm'),
('ord-02', 'poang-chair', 'Poäng Scandi Chair', 1850000, 1, 'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80', 'Đệm vải Linen màu cát');

-- 6. Insert Missing Reports
INSERT INTO public.missing_reports (id, order_code, product_name, part_name, quantity, note, photo_url, status, admin_note, created_at) VALUES
('RPT-901', 'F3D-882194', 'Nordic Oak Desk', 'Chốt mộng gỗ D8x40 (Bộ C)', 4, 'Mở hộp chỉ thấy 6 chốt mộng, theo sách hướng dẫn 3D cần 10 chốt.', 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'DELIVERING', 'Đã chuyển bưu tá Viettel Post mã VT99281, dự kiến giao trong ngày mai.', '25/10/2026 14:20'),
('RPT-902', 'F3D-771032', 'Poäng Scandi Chair', 'Ốc lục giác M6x35mm', 2, 'Rơi mất trong lúc khui túi nilon phụ kiện.', 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'COMPLETED', 'Khách đã xác nhận nhận đủ phụ kiện thay thế.', '22/10/2026 08:30');

-- 7. Insert Return Requests
INSERT INTO public.return_requests (id, order_code, reason, note, photo_url, return_method, refund_amount, status, admin_response, created_at) VALUES
('RET-5512', 'F3D-882194', 'TRANSIT_DAMAGE', 'Góc cạnh mặt bàn bị móp do va đập trong quá trình vận chuyển.', 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80', 'EXCHANGE', 2450000, 'APPROVED', 'Đã duyệt đổi mặt bàn mới 100%, tài xế sẽ qua thu hồi mặt cũ và giao mặt mới trong ngày mai.', '25/10/2026 10:30');
