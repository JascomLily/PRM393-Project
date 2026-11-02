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
        id: 'Chair01',
        name: 'Poäng Scandi Chair',
        subtitle: 'Ghế thư giãn uốn nhiệt',
        material: 'Gỗ bạch dương ép nhiệt & đệm vải tự nhiên',
        price: 1850000,
        originalPrice: 2190000,
        rating: 4.9,
        reviewCount: 128,
        image:
            'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80',
        badge: '3D Ready',
        category: 'chair',
        assemblyTimeMinutes: 15,
        description:
            'Ghế thư giãn công thái học độ cong chuẩn sinh học cột sống. Khung gỗ đàn hồi tự nhiên tạo nhịp bập bênh êm ái thư thái.',
        is3dReady: true,
        modelCode: 'CHAIR-01',
      ),
      ProductModel(
        id: 'Chair18',
        name: 'Strandmon Lounge Armchair',
        subtitle: 'Ghế bành tựa cao Scandinavian',
        material: 'Khung gỗ sồi nguyên khối & vải nỉ dệt thô cao cấp',
        price: 2850000,
        originalPrice: 3200000,
        rating: 4.8,
        reviewCount: 95,
        image:
            'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?auto=format&fit=crop&w=800&q=80',
        badge: 'Bán chạy',
        category: 'chair',
        assemblyTimeMinutes: 20,
        description:
            'Ghế bành phong cách Bắc Âu cổ điển với tựa lưng cao nâng đỡ vai gáy hoàn hảo, đệm mút mật độ cao êm ái bền bỉ.',
        is3dReady: true,
        modelCode: 'CHAIR-18',
      ),
      ProductModel(
        id: 'Chair34',
        name: 'Frosta Nordic Stool',
        subtitle: 'Ghế đẩu tròn xếp chồng',
        material: 'Gỗ tần bì cao cấp phủ sáp ong thực vật',
        price: 490000,
        originalPrice: 650000,
        rating: 4.7,
        reviewCount: 114,
        image:
            'https://images.unsplash.com/photo-1503602642458-232111445657?auto=format&fit=crop&w=800&q=80',
        badge: 'Dễ ráp',
        category: 'chair',
        assemblyTimeMinutes: 5,
        description:
            'Ghế đẩu 4 chân tròn dáng tối giản, lắp ráp nhanh chóng bằng chốt âm dương và có thể xếp chồng gọn gàng tiết kiệm diện tích.',
        is3dReady: true,
        modelCode: 'CHAIR-34',
      ),
      ProductModel(
        id: 'Closet01',
        name: 'Hemnes 2-Door Wardrobe',
        subtitle: 'Tủ quần áo 2 cánh đứng',
        material: 'Gỗ thông tự nhiên nguyên khối & phụ kiện đồng thau',
        price: 4850000,
        originalPrice: 5600000,
        rating: 4.9,
        reviewCount: 86,
        image:
            'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=800&q=80',
        badge: 'Cao cấp',
        category: 'shelf',
        assemblyTimeMinutes: 45,
        description:
            'Tủ quần áo 2 cánh phong cách Bắc Âu thanh lịch, tích hợp ngăn treo đồ thông thoáng và tầng để đồ gấp tiện lợi.',
        is3dReady: true,
        modelCode: 'CLOSET-01',
      ),
      ProductModel(
        id: 'Drawer30',
        name: 'Malm 3-Drawer Chest',
        subtitle: 'Tủ ngăn kéo lưu trữ đa năng',
        material: 'Gỗ công nghiệp MDF phủ Melamine chống ẩm cao cấp',
        price: 1950000,
        originalPrice: 2350000,
        rating: 4.8,
        reviewCount: 142,
        image:
            'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?auto=format&fit=crop&w=800&q=80',
        badge: 'Đa năng',
        category: 'shelf',
        assemblyTimeMinutes: 30,
        description:
            'Tủ 3 tầng ngăn kéo ray trượt giảm chấn êm ái, mặt hộc vát tay nắm tinh tế không gờ nổi, an toàn cho trẻ nhỏ.',
        is3dReady: true,
        modelCode: 'DRAWER-30',
      ),
      ProductModel(
        id: 'Table08',
        name: 'Nordic Oak Desk',
        subtitle: 'Bàn làm việc Scandinavian',
        material: 'Gỗ sồi trắng nhập khẩu & phụ kiện mạ kẽm',
        price: 2450000,
        originalPrice: 2890000,
        rating: 4.9,
        reviewCount: 156,
        image:
            'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
        badge: '3D Ready',
        category: 'desk',
        assemblyTimeMinutes: 25,
        description:
            'Bàn làm việc Scandinavian thanh lịch với đường bo góc mềm mại, kết cấu mộng âm dương chắc chắn và ống luồn dây cáp ẩn.',
        is3dReady: true,
        modelCode: 'TABLE-08',
      ),
      ProductModel(
        id: 'Table09',
        name: 'Ingatorp Dining Table',
        subtitle: 'Bàn ăn mở rộng gia đình',
        material: 'Gỗ cao su tuyển chọn sơn phủ mờ chống nước',
        price: 3250000,
        originalPrice: 3800000,
        rating: 4.8,
        reviewCount: 78,
        image:
            'https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?auto=format&fit=crop&w=800&q=80',
        badge: 'Gia đình',
        category: 'desk',
        assemblyTimeMinutes: 35,
        description:
            'Bàn ăn thông minh thiết kế 4-6 chỗ ngồi, chân tiện dáng tân cổ điển trang nhã, mặt bàn chống trầy và kháng nhiệt.',
        is3dReady: true,
        modelCode: 'TABLE-09',
      ),
      ProductModel(
        id: 'Table26',
        name: 'Lövbacken Coffee Table',
        subtitle: 'Bàn trà sofa dáng lá',
        material: 'Gỗ dán phủ veneer óc chó & đầu chân bọc kim loại đồng',
        price: 1150000,
        originalPrice: 1400000,
        rating: 4.9,
        reviewCount: 110,
        image:
            'https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&w=800&q=80',
        badge: 'Nổi bật',
        category: 'desk',
        assemblyTimeMinutes: 10,
        description:
            'Bàn trà phòng khách dáng chiếc lá Bắc Âu độc bản với 3 chân nghiêng thanh thoát bọc chân vàng đồng sang trọng.',
        is3dReady: true,
        modelCode: 'TABLE-26',
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
            productId: 'Table08',
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
