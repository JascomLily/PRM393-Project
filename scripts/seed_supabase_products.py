"""
Script đồng bộ và nạp dữ liệu 8 sản phẩm chuẩn tương ứng với 8 mô hình 3D Unity vào Supabase Table 'products'.
Chạy script:
    python scripts/seed_supabase_products.py
"""

import json
import urllib.request
import urllib.error

SUPABASE_URL = "https://vriluovamsnuthscwuqe.supabase.co"
SUPABASE_ANON_KEY = "sb_publishable_iut1BYb5c3C4o8qD6IDDJA_KcTLeroR"

PRODUCTS = [
    {
        "id": "Chair01",
        "name": "Poäng Scandi Chair",
        "subtitle": "Ghế thư giãn uốn nhiệt",
        "material": "Gỗ bạch dương ép nhiệt & đệm vải tự nhiên",
        "price": 1850000,
        "original_price": 2190000,
        "rating": 4.9,
        "review_count": 128,
        "image": "https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80",
        "badge": "3D Ready",
        "category": "chair",
        "assembly_time_minutes": 15,
        "description": "Ghế thư giãn công thái học độ cong chuẩn sinh học cột sống. Khung gỗ đàn hồi tự nhiên tạo nhịp bập bênh êm ái thư thái.",
        "is_3d_ready": True,
        "model_code": "CHAIR-01",
    },
    {
        "id": "Chair18",
        "name": "Strandmon Lounge Armchair",
        "subtitle": "Ghế bành tựa cao Scandinavian",
        "material": "Khung gỗ sồi nguyên khối & vải nỉ dệt thô cao cấp",
        "price": 2850000,
        "original_price": 3200000,
        "rating": 4.8,
        "review_count": 95,
        "image": "https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?auto=format&fit=crop&w=800&q=80",
        "badge": "Bán chạy",
        "category": "chair",
        "assembly_time_minutes": 20,
        "description": "Ghế bành phong cách Bắc Âu cổ điển với tựa lưng cao nâng đỡ vai gáy hoàn hảo, đệm mút mật độ cao êm ái bền bỉ.",
        "is_3d_ready": True,
        "model_code": "CHAIR-18",
    },
    {
        "id": "Chair34",
        "name": "Frosta Nordic Stool",
        "subtitle": "Ghế đẩu tròn xếp chồng",
        "material": "Gỗ tần bì cao cấp phủ sáp ong thực vật",
        "price": 490000,
        "original_price": 650000,
        "rating": 4.7,
        "review_count": 114,
        "image": "https://images.unsplash.com/photo-1503602642458-232111445657?auto=format&fit=crop&w=800&q=80",
        "badge": "Dễ ráp",
        "category": "chair",
        "assembly_time_minutes": 5,
        "description": "Ghế đẩu 4 chân tròn dáng tối giản, lắp ráp nhanh chóng bằng chốt âm dương và có thể xếp chồng gọn gàng tiết kiệm diện tích.",
        "is_3d_ready": True,
        "model_code": "CHAIR-34",
    },
    {
        "id": "Closet01",
        "name": "Hemnes 2-Door Wardrobe",
        "subtitle": "Tủ quần áo 2 cánh đứng",
        "material": "Gỗ thông tự nhiên nguyên khối & phụ kiện đồng thau",
        "price": 4850000,
        "original_price": 5600000,
        "rating": 4.9,
        "review_count": 86,
        "image": "https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=800&q=80",
        "badge": "Cao cấp",
        "category": "shelf",
        "assembly_time_minutes": 45,
        "description": "Tủ quần áo 2 cánh phong cách Bắc Âu thanh lịch, tích hợp ngăn treo đồ thông thoáng và tầng để đồ gấp tiện lợi.",
        "is_3d_ready": True,
        "model_code": "CLOSET-01",
    },
    {
        "id": "Drawer30",
        "name": "Malm 3-Drawer Chest",
        "subtitle": "Tủ ngăn kéo lưu trữ đa năng",
        "material": "Gỗ công nghiệp MDF phủ Melamine chống ẩm cao cấp",
        "price": 1950000,
        "original_price": 2350000,
        "rating": 4.8,
        "review_count": 142,
        "image": "https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?auto=format&fit=crop&w=800&q=80",
        "badge": "Đa năng",
        "category": "shelf",
        "assembly_time_minutes": 30,
        "description": "Tủ 3 tầng ngăn kéo ray trượt giảm chấn êm ái, mặt hộc vát tay nắm tinh tế không gờ nổi, an toàn cho trẻ nhỏ.",
        "is_3d_ready": True,
        "model_code": "DRAWER-30",
    },
    {
        "id": "Table08",
        "name": "Nordic Oak Desk",
        "subtitle": "Bàn làm việc Scandinavian",
        "material": "Gỗ sồi trắng nhập khẩu & phụ kiện mạ kẽm",
        "price": 2450000,
        "original_price": 2890000,
        "rating": 4.9,
        "review_count": 156,
        "image": "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80",
        "badge": "3D Ready",
        "category": "desk",
        "assembly_time_minutes": 25,
        "description": "Bàn làm việc Scandinavian thanh lịch với đường bo góc mềm mại, kết cấu mộng âm dương chắc chắn và ống luồn dây cáp ẩn.",
        "is_3d_ready": True,
        "model_code": "TABLE-08",
    },
    {
        "id": "Table09",
        "name": "Ingatorp Dining Table",
        "subtitle": "Bàn ăn mở rộng gia đình",
        "material": "Gỗ cao su tuyển chọn sơn phủ mờ chống nước",
        "price": 3250000,
        "original_price": 3800000,
        "rating": 4.8,
        "review_count": 78,
        "image": "https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?auto=format&fit=crop&w=800&q=80",
        "badge": "Gia đình",
        "category": "desk",
        "assembly_time_minutes": 35,
        "description": "Bàn ăn thông minh thiết kế 4-6 chỗ ngồi, chân tiện dáng tân cổ điển trang nhã, mặt bàn chống trầy và kháng nhiệt.",
        "is_3d_ready": True,
        "model_code": "TABLE-09",
    },
    {
        "id": "Table26",
        "name": "Lövbacken Coffee Table",
        "subtitle": "Bàn trà sofa dáng lá",
        "material": "Gỗ dán phủ veneer óc chó & đầu chân bọc kim loại đồng",
        "price": 1150000,
        "original_price": 1400000,
        "rating": 4.9,
        "review_count": 110,
        "image": "https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&w=800&q=80",
        "badge": "Nổi bật",
        "category": "desk",
        "assembly_time_minutes": 10,
        "description": "Bàn trà phòng khách dáng chiếc lá Bắc Âu độc bản với 3 chân nghiêng thanh thoát bọc chân vàng đồng sang trọng.",
        "is_3d_ready": True,
        "model_code": "TABLE-26",
    },
]


def seed_products():
    url = f"{SUPABASE_URL}/rest/v1/products"
    data = json.dumps(PRODUCTS).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req) as resp:
            print(f"Thanh cong! Ma HTTP: {resp.status}")
            print(f"Da dong bo thanh cong {len(PRODUCTS)} san pham vao Supabase!")
    except urllib.error.HTTPError as e:
        print(f"Loi HTTP {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"Loi: {e}")


if __name__ == "__main__":
    seed_products()
