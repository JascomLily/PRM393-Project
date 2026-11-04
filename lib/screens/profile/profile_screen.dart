import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final addrCtrl = TextEditingController(text: user.savedAddress);
    String currentAvatar = user.avatar;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Chỉnh sửa hồ sơ cá nhân',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar Picker from Gallery / Camera
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.wood, width: 2.5),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: ClipOval(
                            child: isUploading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.wood,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : _buildAvatarImage(currentAvatar),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final source = await showModalBottomSheet<ImageSource>(
                                context: context,
                                backgroundColor: AppTheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.photo_library_outlined,
                                            color: AppTheme.primary),
                                        title: const Text('Chọn ảnh từ thư viện'),
                                        onTap: () =>
                                            Navigator.pop(ctx, ImageSource.gallery),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt_outlined,
                                            color: AppTheme.primary),
                                        title: const Text('Chụp ảnh mới'),
                                        onTap: () =>
                                            Navigator.pop(ctx, ImageSource.camera),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (source == null) return;

                              final picked = await picker.pickImage(
                                source: source,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 85,
                              );

                              if (picked != null) {
                                setDialogState(() => isUploading = true);
                                try {
                                  final bytes = await picked.readAsBytes();
                                  String? uploadedUrl;
                                  if (SupabaseService.isConfigured) {
                                    uploadedUrl = await SupabaseService.uploadAvatar(
                                      bytes: bytes,
                                      fileName: picked.name,
                                    );
                                  }

                                  final finalAvatar = uploadedUrl ??
                                      'data:image/jpeg;base64,${base64Encode(bytes)}';

                                  setDialogState(() {
                                    currentAvatar = finalAvatar;
                                    isUploading = false;
                                  });
                                } catch (_) {
                                  setDialogState(() => isUploading = false);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nhấn vào biểu tượng máy ảnh để tải ảnh từ máy',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addrCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ mặc định',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newEmail = emailCtrl.text.trim();
                final newPhone = phoneCtrl.text.trim();
                final newAddress = addrCtrl.text.trim();

                if (newName.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng không để trống họ tên và email.'),
                    ),
                  );
                  return;
                }

                auth.updateFullProfile(
                  name: newName,
                  email: newEmail,
                  phone: newPhone,
                  address: newAddress,
                  avatar: currentAvatar,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.primary,
                    content: Text('Đã cập nhật thông tin cá nhân và ảnh đại diện thành công!'),
                  ),
                );
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog(
    BuildContext context,
    AuthProvider auth, {
    AddressModel? existing,
  }) {
    final labelCtrl = TextEditingController(text: existing?.label ?? 'Nhà riêng');
    final nameCtrl = TextEditingController(
      text: existing?.receiverName ?? auth.currentUser?.name ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: existing?.receiverPhone ?? auth.currentUser?.phone ?? '',
    );
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    bool isDefault = existing?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            existing == null ? 'Thêm địa chỉ giao hàng' : 'Chỉnh sửa địa chỉ',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick tag selector
                Row(
                  children: ['Nhà riêng', 'Văn phòng', 'Khác'].map((tag) {
                    final selected = labelCtrl.text == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() => labelCtrl.text = tag);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên người nhận',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addrCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ chi tiết (Số nhà, đường, phường, quận...)',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Đặt làm địa chỉ mặc định',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  value: isDefault,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setModalState(() => isDefault = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final addrText = addrCtrl.text.trim();
                if (addrText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập địa chỉ chi tiết')),
                  );
                  return;
                }

                if (existing != null) {
                  auth.updateAddress(
                    existing.copyWith(
                      label: labelCtrl.text.trim(),
                      receiverName: nameCtrl.text.trim(),
                      receiverPhone: phoneCtrl.text.trim(),
                      address: addrText,
                      isDefault: isDefault,
                    ),
                  );
                } else {
                  auth.addAddress(
                    AddressModel(
                      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                      label: labelCtrl.text.trim(),
                      receiverName: nameCtrl.text.trim(),
                      receiverPhone: phoneCtrl.text.trim(),
                      address: addrText,
                      isDefault: isDefault,
                    ),
                  );
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primary,
                    content: Text(
                      existing == null
                          ? 'Đã thêm địa chỉ giao hàng thành công!'
                          : 'Đã cập nhật địa chỉ giao hàng!',
                    ),
                  ),
                );
              },
              child: Text(existing == null ? 'Thêm mới' : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Xác nhận xóa tài khoản',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản của mình? Toàn bộ điểm tích lũy FurniCoins và thông tin cá nhân sẽ bị hủy bỏ hoàn toàn và không thể khôi phục.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.deleteMyAccount();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.error,
                    content: Text('Tài khoản của bạn đã được xóa vĩnh viễn khỏi hệ thống.'),
                  ),
                );
              }
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String url) {
    if (url.startsWith('data:image')) {
      final base64Str = url.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: AppTheme.wood),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: AppTheme.wood),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Tài Khoản Cá Nhân')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined, size: 72, color: AppTheme.wood),
                const SizedBox(height: 16),
                const Text(
                  'Bạn chưa đăng nhập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để theo dõi đơn hàng, tích lũy FurniCoins và xem mô hình 3D thực tế.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Đăng nhập ngay'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isAdmin = user.isAdmin;
    final addresses = user.addresses;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tài Khoản Cá Nhân'),
        actions: [
          IconButton(
            tooltip: 'Chỉnh sửa thông tin',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfileDialog(context, auth),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.wood, width: 2),
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(user.avatar),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAdmin ? AppTheme.primaryMint : AppTheme.woodLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAdmin ? 'QUẢN TRỊ VIÊN' : 'THÀNH VIÊN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? AppTheme.primary : AppTheme.woodDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        Text(user.phone, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Phan hien thi theo vai tro: Admin vs Khach hang
            if (isAdmin) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4A2A18)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUYỀN HỆ THỐNG',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Quản Trị Viên (Admin)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Quản lý danh mục 3D, đơn hàng, mã giảm giá và theo dõi đánh giá của khách hàng.',
                            style: TextStyle(fontSize: 11, color: Color(0xFFDCD2C6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF805528),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.dashboard_outlined, size: 16),
                  label: const Text('Mở Bảng điều khiển Quản trị viên', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                ),
              ),
            ] else ...[
              // FurniCoins Points Card cho khach hang
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.woodLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.wood.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.monetization_on, color: AppTheme.woodDark, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VÍ ĐIỂM THƯỞNG SOFA SO GOOD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppTheme.woodDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${user.furniCoins} Xu',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '1 Xu = 1.000₫ • Dùng trực tiếp khi thanh toán đơn hàng',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // SỔ ĐỊA CHỈ NHẬN HÀNG (ADDRESS BOOK) - Chi hien thi cho khach hang
            if (!isAdmin) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sổ địa chỉ nhận hàng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddressDialog(context, auth),
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.primary),
                  label: const Text(
                    'Thêm địa chỉ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...addresses.map((addr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: addr.isDefault ? AppTheme.primary : AppTheme.border,
                    width: addr.isDefault ? 1.5 : 1,
                  ),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: addr.isDefault
                                ? AppTheme.primary
                                : AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            addr.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: addr.isDefault ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.woodLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.woodDark,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showAddressDialog(context, auth, existing: addr),
                        ),
                        const SizedBox(width: 12),
                        // Delete button (if more than 1 address)
                        if (addresses.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Xác nhận xóa địa chỉ'),
                                  content: Text('Bạn có chắc chắn muốn xóa "${addr.address}"?'),
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
                                        auth.deleteAddress(addr.id);
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
                    const SizedBox(height: 8),
                    Text(
                      '${addr.receiverName} • ${addr.receiverPhone}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr.address,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    if (!addr.isDefault) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => auth.setDefaultAddress(addr.id),
                        child: const Text(
                          'Thiết lập làm mặc định',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            ],

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Đăng xuất tài khoản'),
                onPressed: () => auth.logout(),
              ),
            ),

            const SizedBox(height: 12),

            // Delete Account Button
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                icon: const Icon(Icons.delete_forever_outlined, size: 16),
                label: const Text(
                  'Xóa tài khoản của tôi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _showDeleteAccountDialog(context, auth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
