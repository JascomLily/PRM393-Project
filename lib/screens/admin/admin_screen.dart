import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/missing_report_provider.dart';
import '../../models/product_model.dart';
import '../../models/voucher_model.dart';
import '../../models/missing_report_model.dart';
import '../../widgets/product_image_view.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _picker = ImagePicker();

  // 8 Official Unity 3D Models available in the project
  static const List<Map<String, String>> official3DModels = [
    {'code': 'CHAIR-01', 'name': 'Poäng Scandi Chair (Ghế uốn nhiệt)'},
    {'code': 'CHAIR-18', 'name': 'Eames Lounge Chair (Ghế bọc da)'},
    {'code': 'CHAIR-34', 'name': 'Strandmon Wing Chair (Ghế tựa lưng cao)'},
    {'code': 'CLOSET-01', 'name': 'Pax Wardrobe Closet (Tủ quần áo 2 cánh)'},
    {'code': 'DRAWER-30', 'name': 'Koppang Dresser Drawer (Tủ ngăn kéo 3 tầng)'},
    {'code': 'TABLE-08', 'name': 'Nordic Oak Desk (Bàn làm việc sồi)'},
    {'code': 'TABLE-09', 'name': 'Hemnes Wood Table (Tủ đầu giường)'},
    {'code': 'TABLE-26', 'name': 'Noguchi Coffee Table (Bàn trà dáng lá)'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // PRODUCT MANAGEMENT DIALOGS (ADD & EDIT)
  // ==========================================================================
  void _showProductDialog({ProductModel? productToEdit}) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final isEditing = productToEdit != null;

    final nameCtrl = TextEditingController(text: productToEdit?.name ?? '');
    final subtitleCtrl = TextEditingController(text: productToEdit?.subtitle ?? '');
    final priceCtrl = TextEditingController(
        text: productToEdit != null ? productToEdit.price.toString() : '');
    final materialCtrl = TextEditingController(
        text: productToEdit?.material ?? 'Gỗ sồi Bắc Âu tự nhiên');
    final descCtrl = TextEditingController(
        text: productToEdit?.description ?? 'Thiết kế thông minh, lắp ráp mộng âm dương tiện lợi.');
    final assemblyCtrl = TextEditingController(
        text: productToEdit != null ? productToEdit.assemblyTimeMinutes.toString() : '15');
    final imageCtrl = TextEditingController(text: productToEdit?.image ?? '');

    String selectedCategory = productToEdit?.category ?? 'desk';
    String selectedModelCode = productToEdit?.modelCode ?? 'TABLE-08';
    String? localImagePreview;
    Uint8List? pickedImageBytes;
    String? pickedFileName;
    bool isUploadingImage = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final picked = await _picker.pickImage(
                source: source,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              );
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                setModalState(() {
                  pickedImageBytes = bytes;
                  pickedFileName = picked.name;
                  localImagePreview = picked.path;
                  imageCtrl.text = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                });
              }
            } catch (e) {
              debugPrint('Error picking image: $e');
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.65,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview & Upload Buttons
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _buildProductPreview(
                                localPreview: localImagePreview,
                                pickedBytes: pickedImageBytes,
                                urlText: imageCtrl.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  foregroundColor: AppTheme.primary,
                                ),
                                icon: const Icon(Icons.photo_library, size: 16),
                                label: const Text('Thư viện', style: TextStyle(fontSize: 11)),
                                onPressed: () => pickImage(ImageSource.gallery),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  foregroundColor: AppTheme.primary,
                                ),
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('Chụp ảnh', style: TextStyle(fontSize: 11)),
                                onPressed: () => pickImage(ImageSource.camera),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hoặc dán URL hình ảnh',
                        hintText: 'https://images.unsplash.com/...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => setModalState(() {}),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm nội thất *',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: subtitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phụ đề / Kiểu dáng *',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Giá bán (₫) *',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: assemblyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Thời gian ráp (phút)',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category dropdown
                    const Text('Danh mục nội thất:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'desk', child: Text('Bàn làm việc (Desk)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'chair', child: Text('Ghế thư giãn (Chair)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'shelf', child: Text('Kệ & Tủ quần áo (Closet/Shelf)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'lamp', child: Text('Tủ ngăn kéo (Drawer)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'parts', child: Text('Linh kiện phụ kiện (Parts)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Unity 3D Model Code selector
                    const Text('Mã 3D Model Unity tương ứng:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedModelCode,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: official3DModels.map((m) {
                        return DropdownMenuItem(
                          value: m['code'],
                          child: Text(
                            '${m['code']} • ${m['name']}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedModelCode = val);
                      },
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: materialCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Chất liệu gỗ / vật liệu',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả chi tiết',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: isUploadingImage
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng điền tên và giá bán hợp lệ')),
                          );
                          return;
                        }

                        setModalState(() => isUploadingImage = true);

                        // If user picked a local image, upload to Supabase Storage
                        String finalImageUrl = imageCtrl.text.trim();
                        if (pickedImageBytes != null) {
                          final uploadedUrl = await SupabaseService.uploadProductImage(
                            bytes: pickedImageBytes!,
                            fileName: pickedFileName ?? 'product.jpg',
                          );
                          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                            finalImageUrl = uploadedUrl;
                          }
                        }

                        if (finalImageUrl.isEmpty) {
                          finalImageUrl =
                              'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80';
                        }

                        final productId = isEditing
                            ? productToEdit.id
                            : 'prod-${DateTime.now().millisecondsSinceEpoch}';

                        final updatedProduct = ProductModel(
                          id: productId,
                          name: name,
                          subtitle: subtitleCtrl.text.trim().isEmpty
                              ? 'Nội thất Bắc Âu'
                              : subtitleCtrl.text.trim(),
                          price: price,
                          material: materialCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          category: selectedCategory,
                          modelCode: selectedModelCode,
                          assemblyTimeMinutes:
                              int.tryParse(assemblyCtrl.text.trim()) ?? 15,
                          image: finalImageUrl,
                          rating: productToEdit?.rating ?? 5.0,
                          reviewCount: productToEdit?.reviewCount ?? 1,
                          is3dReady: true,
                          badge: productToEdit?.badge ?? 'Mới',
                        );

                        if (isEditing) {
                          productProvider.updateProduct(updatedProduct);
                        } else {
                          productProvider.addProduct(updatedProduct);
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.primary,
                            content: Text(
                              isEditing
                                  ? 'Đã cập nhật sản phẩm "${updatedProduct.name}"!'
                                  : 'Đã thêm sản phẩm "${updatedProduct.name}" thành công!',
                            ),
                          ),
                        );
                      },
                child: isUploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Lưu thay đổi' : 'Thêm sản phẩm'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductPreview({
    String? localPreview,
    Uint8List? pickedBytes,
    required String urlText,
  }) {
    if (pickedBytes != null) {
      return Image.memory(pickedBytes, fit: BoxFit.cover);
    }
    if (localPreview != null && !kIsWeb) {
      return Image.file(File(localPreview), fit: BoxFit.cover);
    }
    if (urlText.startsWith('data:image')) {
      try {
        final b64 = urlText.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover);
      } catch (_) {}
    }
    if (urlText.startsWith('http')) {
      return Image.network(
        urlText,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    return const Center(
      child: Icon(Icons.chair_outlined, size: 40, color: AppTheme.wood),
    );
  }

  // ==========================================================================
  // VOUCHER MANAGEMENT DIALOG
  // ==========================================================================
  void _showAddVoucherDialog(BuildContext context, CartProvider cartProvider) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minSpendCtrl = TextEditingController(text: '500000');
    final expiryCtrl = TextEditingController(text: '31/12/2026');
    String discountType = 'fixed';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'Tạo mã khuyến mãi mới',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã Voucher (VD: TET2026)',
                    prefixIcon: Icon(Icons.qr_code, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả ưu đãi (VD: Giảm ngay 100.000₫)',
                    prefixIcon: Icon(Icons.title, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Giảm tiền (₫)', style: TextStyle(fontSize: 11)),
                      selected: discountType == 'fixed',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: discountType == 'fixed' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => discountType = 'fixed');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Giảm theo %', style: TextStyle(fontSize: 11)),
                      selected: discountType == 'percentage',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: discountType == 'percentage' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => discountType = 'percentage');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: discountType == 'fixed'
                        ? 'Số tiền giảm (VD: 100000)'
                        : 'Phần trăm giảm (VD: 15)',
                    prefixIcon: const Icon(Icons.discount_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: minSpendCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Đơn tối thiểu áp dụng (₫)',
                    prefixIcon: Icon(Icons.shopping_bag_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expiryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hạn dùng (dd/MM/yyyy)',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final code = codeCtrl.text.trim().toUpperCase();
                final title = titleCtrl.text.trim();
                final val = int.tryParse(valueCtrl.text.trim()) ?? 0;
                final minSpend = int.tryParse(minSpendCtrl.text.trim()) ?? 0;

                if (code.isEmpty || title.isEmpty || val <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ mã, mô tả và giá trị')),
                  );
                  return;
                }

                final newVoucher = VoucherModel(
                  code: code,
                  title: title,
                  discountType: discountType,
                  discountValue: val,
                  minSpend: minSpend,
                  expiryDate: expiryCtrl.text.trim(),
                  isActive: true,
                );

                cartProvider.addVoucher(newVoucher);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primary,
                    content: Text('Đã tạo thành công voucher $code!'),
                  ),
                );
              },
              child: const Text('Tạo mã'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<MissingReportProvider>(context);
    final pendingCount = reportProv.reports.where((r) => r.status == 'PENDING').length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản trị hệ thống Furni3D'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            const Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Đơn hàng & Tiền'),
            const Tab(icon: Icon(Icons.chair_outlined, size: 18), text: 'Sản phẩm & 3D'),
            const Tab(icon: Icon(Icons.confirmation_number_outlined, size: 18), text: 'Mã Voucher'),
            Tab(
              icon: const Icon(Icons.handyman_outlined, size: 18),
              text: pendingCount > 0 ? 'Phiếu linh kiện ($pendingCount mới)' : 'Phiếu linh kiện',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ORDERS & REVENUE
          _buildOrdersTab(),

          // TAB 2: PRODUCTS CRUD & 3D MODELS
          _buildProductsTab(),

          // TAB 3: VOUCHERS
          _buildVouchersTab(),

          // TAB 4: PHIẾU LINH KIỆN
          _buildMissingReportsTab(),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: ORDERS & REVENUE
  // ==========================================================================
  Widget _buildOrdersTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProvider = Provider.of<OrderProvider>(context);
    final totalRevenue = orderProvider.orders.fold<int>(
      0,
      (sum, order) => sum + (order.paymentStatus == 'PAID' ? order.totalAmount : 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1810), Color(0xFF5A341E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG DOANH THU ĐÃ ĐỐI SOÁT VNPAY',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.woodLight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(totalRevenue),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statTag('Đơn hàng: ${orderProvider.orders.length}'),
                    const SizedBox(width: 8),
                    _statTag(
                      'Đang giao: ${orderProvider.orders.where((o) => o.status == 'shipping').length}',
                    ),
                    const SizedBox(width: 8),
                    _statTag('Tỉ lệ giao: 98%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Quản lý trạng thái đơn hàng',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),

          ...orderProvider.orders.map((order) {
            final isShipping = order.status == 'shipping';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.code} • ${order.receiverName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(order.totalAmount),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isShipping ? AppTheme.woodLight : const Color(0xFFF7EFE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isShipping ? 'Đang giao hàng' : 'Đã giao thành công',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isShipping ? AppTheme.woodDark : AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isShipping ? AppTheme.primary : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () {
                      final nextStatus = isShipping ? 'completed' : 'shipping';
                      orderProvider.updateOrderStatus(order.id, nextStatus);
                    },
                    child: Text(
                      isShipping ? 'Xác nhận\nĐã Giao' : 'Chuyển\nĐang Giao',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: PRODUCTS CRUD & 3D MODELS
  // ==========================================================================
  Widget _buildProductsTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kho sản phẩm & Model 3D',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Tổng cộng: ${products.length} sản phẩm',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm sản phẩm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _showProductDialog(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Products
          ...products.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildProductPreview(urlText: p.image),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          p.subtitle,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(p.price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 3D Model badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EFE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '3D: ${p.modelCode}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.woodDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Edit & Delete
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                        tooltip: 'Chỉnh sửa sản phẩm',
                        onPressed: () => _showProductDialog(productToEdit: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                        tooltip: 'Xóa sản phẩm',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Xác nhận xóa sản phẩm'),
                              content: Text('Bạn có chắc chắn muốn xóa "${p.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(c);
                                    productProvider.deleteProduct(p.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.primary,
                                        content: Text('Đã xóa sản phẩm ${p.name}!'),
                                      ),
                                    );
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 3: VOUCHERS
  // ==========================================================================
  Widget _buildVouchersTab() {
    final cartProvider = Provider.of<CartProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý mã Voucher khuyến mãi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              TextButton.icon(
                onPressed: () => _showAddVoucherDialog(context, cartProvider),
                icon: const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                label: const Text(
                  'Tạo mã mới',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...cartProvider.vouchers.map((v) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.woodLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.confirmation_num_outlined, size: 20, color: AppTheme.woodDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              v.code,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: v.isActive ? const Color(0xFFF7EFE7) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                v.isActive ? 'Đang bật' : 'Đã tắt',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: v.isActive ? AppTheme.primary : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.title,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: v.isActive,
                    activeColor: AppTheme.primary,
                    onChanged: (val) {
                      cartProvider.toggleVoucher(v.code);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Xác nhận xóa voucher'),
                          content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn mã "${v.code}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(c);
                                cartProvider.deleteVoucher(v.code);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.primary,
                                    content: Text('Đã xóa mã voucher ${v.code}!'),
                                  ),
                                );
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==========================================================================
  // TAB 4: PHIẾU HỖ TRỢ & BẢO HÀNH LINH KIỆN
  // ==========================================================================
  Widget _buildMissingReportsTab() {
    final reportProv = Provider.of<MissingReportProvider>(context);
    final reports = reportProv.reports;
    final pendingCount = reports.where((r) => r.status == 'PENDING').length;
    final approvedCount = reports.where((r) => r.status == 'APPROVED').length;
    final deliveringCount = reports.where((r) => r.status == 'DELIVERING').length;
    final completedCount = reports.where((r) => r.status == 'COMPLETED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1810), Color(0xFF4A2B18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BẢO HÀNH & GỬI BÙ LINH KIỆN TẬN NHÀ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.woodLight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${reports.length} Yêu cầu',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _statTag('Chờ xử lý: $pendingCount'),
                    _statTag('Đã duyệt: $approvedCount'),
                    _statTag('Đang giao: $deliveringCount'),
                    _statTag('Hoàn thành: $completedCount'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Danh sách phiếu hỗ trợ khách hàng',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),

          if (reports.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('Chưa có yêu cầu hỗ trợ linh kiện nào.', style: TextStyle(color: AppTheme.textSecondary)),
            )
          else
            ...reports.map((report) {
              Color statusBg;
              Color statusColor;
              String statusText;

              switch (report.status) {
                case 'APPROVED':
                  statusBg = AppTheme.successBg;
                  statusColor = AppTheme.success;
                  statusText = 'Đã duyệt gửi bù';
                  break;
                case 'DELIVERING':
                  statusBg = AppTheme.infoBg;
                  statusColor = AppTheme.info;
                  statusText = 'Đang giao Viettel Post';
                  break;
                case 'COMPLETED':
                  statusBg = AppTheme.successBg;
                  statusColor = AppTheme.success;
                  statusText = 'Đã nhận đủ phụ kiện';
                  break;
                case 'REJECTED':
                  statusBg = AppTheme.errorBg;
                  statusColor = AppTheme.error;
                  statusText = 'Từ chối hỗ trợ';
                  break;
                default:
                  statusBg = AppTheme.warningBg;
                  statusColor = AppTheme.warning;
                  statusText = 'Đang chờ xử lý';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImageView(
                          imageUrl: report.photoUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
                          placeholderIconSize: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${report.id} • ${report.orderCode}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${report.productName} • ${report.partName} (x${report.quantity})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              ),
                              if (report.note.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Khách báo: ${report.note}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (report.adminNote != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'CSKH: ${report.adminNote}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontStyle: FontStyle.italic),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                'Ngày tạo: ${report.createdAt}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (report.status == 'PENDING') ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Duyệt bù', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              reportProv.updateReportStatus(
                                report.id,
                                'APPROVED',
                                adminNote: 'Admin đã duyệt xuất kho gửi bù phụ kiện chính hãng.',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã duyệt phiếu ${report.id}!')),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(color: AppTheme.error),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.close, size: 14),
                            label: const Text('Từ chối', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              reportProv.updateReportStatus(
                                report.id,
                                'REJECTED',
                                adminNote: 'Từ chối: Sản phẩm không thuộc diện bảo hành linh kiện.',
                              );
                            },
                          ),
                        ],
                        if (report.status == 'APPROVED') ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.info,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.local_shipping_outlined, size: 14),
                            label: const Text('Gửi Viettel Post', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              final trackingCode = 'VT${1000000 + DateTime.now().millisecondsSinceEpoch % 8999999}';
                              reportProv.updateReportStatus(
                                report.id,
                                'DELIVERING',
                                adminNote: 'Đã gửi bưu phẩm Viettel Post mã $trackingCode (Miễn phí 100%)',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã cập nhật mã bưu phẩm $trackingCode!')),
                              );
                            },
                          ),
                        ],
                        if (report.status == 'DELIVERING') ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.done_all, size: 14),
                            label: const Text('Xác nhận đã giao', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              reportProv.updateReportStatus(
                                report.id,
                                'COMPLETED',
                                adminNote: 'Khách hàng đã nhận đủ linh kiện nguyên seal.',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: AppTheme.primary, content: Text('Phiếu ${report.id} đã hoàn tất!')),
                              );
                            },
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                          tooltip: 'Xóa phiếu',
                          onPressed: () {
                            reportProv.deleteReport(report.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã xóa phiếu ${report.id}.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
