import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';
import '../models/order_model.dart';

const String kAppLogo =
    'https://lh3.googleusercontent.com/aida/AEtjO1VjwMTAQZ_e36hJQkPgfxwynSSiIOwKyAKHZ2lC8XSVCJInAtWu_WN20Wv7XsM53Z8y3JWyYLdKhzWD1Pct85FE6V5F2Ufd0SN1vhP7TwhH384wkbbkXeJQrh6ggzaeS3k5M2RXVUjCtn5H_c8EzrQRvtUcWOZXVO2Snkt8JqYX9JfwWUzn6Ttp269WS6D9qvKM5DJJrSyQyXO57WfIn-3YupzTsziKMwoZ8Fi4xSVWraBSjyJ_fLPpkLvr';

const String kUserAvatar =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAFnxO2uVjcbzsl6MBu2fAR-IdntAwSFmN8jsWOHQ7ntHLMhP5Gi-t7Z47caoxD6Z8Pz3-KdTgVvaGEAvy2mrmnq_HsFKvUncDzMQRXm4nG6f5iVAU8-W5UpwyrdUoF9h0dqOXIuovbEoe4cdCOfyRGelgq7gInq6O7HrlkY7o3s8FXOzKkLoBT5aXt3DFRdooZchcwyfZhRNTOVltc5xjXMLAod2gQnZFsUPpecG6HL0sOSmS5uNHkKg';

UserModel getInitialUser() => UserModel(
      id: 'usr-01',
      name: 'Đặng Thảo Vy',
      email: 'KDuy8383@gmail.com',
      phone: '0983 838 311',
      avatar: kUserAvatar,
      furniCoins: 150,
      savedAddress: 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
      role: 'customer',
    );

List<ProductModel> getMockProducts() => [
      ProductModel(
        id: 'nordic-desk',
        name: 'Nordic Oak Desk',
        subtitle: 'Gỗ sồi Bắc Âu tự nhiên',
        material: 'Gỗ sồi trắng nhập khẩu & phụ kiện mạ kẽm',
        price: 2450000,
        originalPrice: 2890000,
        rating: 4.9,
        reviewCount: 128,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
        badge: '3D Ready',
        category: 'desk',
        assemblyTimeMinutes: 25,
        description:
            'Bàn làm việc Scandinavian thanh lịch với đường bo góc mềm mại, kết cấu mộng âm dương không cần keo dán độc hại. Tích hợp ống luồn dây cáp ẩn tinh tế.',
        is3dReady: true,
        modelCode: 'MODEL ND-2024',
      ),
      ProductModel(
        id: 'poang-chair',
        name: 'Poäng Scandi Chair',
        subtitle: 'Ghế thư giãn uốn nhiệt',
        material: 'Gỗ bạch dương ép nhiệt & đệm vải Linen tự nhiên',
        price: 1850000,
        originalPrice: 2190000,
        rating: 4.8,
        reviewCount: 94,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsscLVhDaUME-1f0Yl6xVCCvVl3H3neu32KunxIM9sOcjfedNxSwC3BW6PUAlIF_d-RpeDHGNEdngit8tjpzthNqJATNP-EnL7Kr7dqwrx_qHl9dR88XkTv0Y5rR9NCjEsixLwtHRrM2DdJkFfTTIafZJkFHvuKANZK1IFzUcwoem8FCg9XHX_SUx8Bq3-eGEiRCEdzWjl4lwDJaSsJmRERzQ5wCd-vI_DtjtmAHL2wPuGZvO2sgVyJA',
        badge: '15 Phút',
        category: 'chair',
        assemblyTimeMinutes: 15,
        description:
            'Ghế thư giãn công thái học độ cong chuẩn sinh học cột sống. Khung gỗ đàn hồi tự nhiên tạo nhịp bập bênh êm ái thư thái sau ngày làm việc.',
        is3dReady: true,
        modelCode: 'MODEL PC-108',
      ),
      ProductModel(
        id: 'billy-shelf',
        name: 'Billy Minimalist',
        subtitle: 'Khớp nối nhanh không keo',
        material: 'Gỗ tần bì cao cấp phủ sáp ong thực vật',
        price: 1290000,
        originalPrice: 1550000,
        rating: 4.7,
        reviewCount: 62,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDWpA7VhMU6VnI_bBKWwu5V1WeWwovi-qNhc-AKDBXyAwkXE4tOAubqdqzxdRfdXcYK7m2jr2w466OXeeCfANedB1Y6ZIT9wI53yQA2DnsWqiE2ERsSUWQ14_leIqR2VJKXNE119P71PuL_u4VdKAfHmzIibAEEOcf3rwWjMLoLyrUwHULfQzTdweHrZHfeHaEAOE_uC2GQmTpmeyuS21aoGoC_aCOlCdwl9cbqzHtYLciRcIbrSWgmmg',
        badge: '4 Tầng',
        category: 'shelf',
        assemblyTimeMinutes: 20,
        description:
            'Kệ sách thông minh thanh mảnh 4 tầng có thể ghép nối mô-đun mở rộng ngang dọc theo diện tích căn hộ hiện đại.',
        is3dReady: true,
        modelCode: 'MODEL BM-402',
      ),
      ProductModel(
        id: 'hemnes-table',
        name: 'Hemnes Wood Table',
        subtitle: 'Tủ cạnh giường gỗ tự nhiên',
        material: 'Gỗ thông nguyên khối & núm đồng thau chải xước',
        price: 890000,
        originalPrice: 1050000,
        rating: 4.9,
        reviewCount: 81,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuANt1NPXLHJXVcWkGYboWUbS3J_EdmfyGAJWyau9RxdqA9eNiS8e0GCO_DGH61JlRsvf2K14ofLzxDgXubexb6rAhlDNBcz43bElgsXRAVfEHT0PD20ePrMNIhjzrhtOqRT4TQZIMy-93rO0n5vDx9HgenNcMXKg8JOyB_MjWHqYxMBqDNcAGS2hMnq7O2nmxqp-iR6Jr_d_afa2gDtODRPaiQulQL98aN-QQgcbehQOCyoi4StvfQiqg',
        badge: 'Dễ ráp',
        category: 'desk',
        assemblyTimeMinutes: 10,
        description:
            'Bàn tab đầu giường nhỏ gọn trang nhã với một ngăn kéo chống ồn và kệ để sách tạp chí thư giãn.',
        is3dReady: true,
        modelCode: 'MODEL HW-12',
      ),
      ProductModel(
        id: 'part-cam-set',
        name: 'Bộ ốc khóa chốt cam M6x35',
        subtitle: 'Phụ kiện linh kiện thay thế',
        material: 'Thép mạ kẽm chống rỉ',
        price: 25000,
        rating: 5.0,
        reviewCount: 310,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
        badge: 'Túi 10 cái',
        category: 'parts',
        assemblyTimeMinutes: 2,
        description: 'Túi 10 bộ ốc liên kết chốt cam và nở nhựa chuẩn nội thất lắp ráp tháo rời thông minh.',
        is3dReady: false,
        modelCode: 'PART-CAM-10',
      ),
    ];

List<VoucherModel> getMockVouchers() => [
      VoucherModel(
        code: 'JAPANDI2025',
        title: 'Giảm 10% đơn từ 1.000.000₫',
        discountType: 'percentage',
        discountValue: 10,
        minSpend: 1000000,
      ),
      VoucherModel(
        code: 'FREESHIP',
        title: 'Miễn phí vận chuyển 45.000₫',
        discountType: 'fixed',
        discountValue: 45000,
        minSpend: 500000,
      ),
      VoucherModel(
        code: 'GIAM50K',
        title: 'Giảm ngay 50.000₫ cho đơn đầu tiên',
        discountType: 'fixed',
        discountValue: 50000,
        minSpend: 300000,
      ),
    ];

List<OrderModel> getMockOrders() => [
      OrderModel(
        id: 'ord-101',
        code: '#F3D-88219',
        date: '19/10/2026',
        totalAmount: 2450000,
        paymentMethod: 'VNPAY_QR',
        paymentStatus: 'PAID',
        transactionId: 'VNP-20261019-94821',
        status: 'shipping',
        receiverName: 'Đặng Thảo Vy',
        receiverPhone: '0983 838 311',
        shippingAddress: 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
        items: [
          OrderItemModel(
            productId: 'nordic-desk',
            name: 'Nordic Oak Desk',
            price: 2450000,
            quantity: 1,
            image:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
            variant: 'Gỗ sồi Bắc Âu tự nhiên',
          ),
        ],
        driver: DriverModel(
          name: 'Trần Văn Hoàng',
          licensePlate: '51D-918.42',
          phone: '0908 776 554',
          distanceKm: 2.8,
          avatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=160&q=80',
        ),
        timeline: [
          TimelineStepModel(
            id: 1,
            title: 'Đã xác nhận thanh toán VNPAY',
            time: '11:30',
            description: 'Khớp lệnh cổng thanh toán VNPAY thành công.',
            status: 'completed',
          ),
          TimelineStepModel(
            id: 2,
            title: 'Đã xuất kho & kiểm đếm phụ kiện',
            time: '11:45',
            description: 'Kho Trung tâm chuẩn bị quét mã vạch và bọc xốp chống sốc.',
            status: 'current',
          ),
          TimelineStepModel(
            id: 3,
            title: 'Nội thất Express đang vận chuyển',
            time: 'Dự kiến 15:45',
            description: 'Tài xế nhận hàng và di chuyển tới điểm giao.',
            status: 'upcoming',
          ),
          TimelineStepModel(
            id: 4,
            title: 'Giao hàng & quét QR nghiệm thu',
            time: 'Dự kiến 16:30',
            description: 'Bàn giao và hướng dẫn quét QR mở model 3D.',
            status: 'upcoming',
          ),
        ],
      ),
    ];
