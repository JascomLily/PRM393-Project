import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';
import '../models/order_model.dart';

const String kAppLogo =
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=200&q=80';

const String kUserAvatar =
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

UserModel getInitialUser() => UserModel(
      id: 'usr-01',
      name: 'Đặng Thảo Vy',
      email: 'customer@furni3d.vn',
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
            'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
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
            'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80',
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
            'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?auto=format&fit=crop&w=800&q=80',
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
            'https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&w=800&q=80',
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
            'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
        badge: 'Túi 10 cái',
        category: 'parts',
        assemblyTimeMinutes: 2,
        description:
            'Chốt cam mạ kẽm chống trượt ren, liên kết mộng gỗ siêu chắc chắn không cần keo dính độc hại.',
        is3dReady: false,
        modelCode: 'PART-CAM-01',
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
                'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
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
