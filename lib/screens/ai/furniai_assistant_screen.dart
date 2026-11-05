import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_image_view.dart';
import '../explore/product_detail_screen.dart';
import '../parts/report_missing_dialog.dart';

class FurniAiAssistantScreen extends StatefulWidget {
  final String? initialPrompt;

  const FurniAiAssistantScreen({super.key, this.initialPrompt});

  @override
  State<FurniAiAssistantScreen> createState() => _FurniAiAssistantScreenState();
}

class _FurniAiAssistantScreenState extends State<FurniAiAssistantScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<AiChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Gợi ý phối phòng khách Bắc Âu',
    'Góc làm việc Minimalism',
    'Tôi lắp bàn nhưng thiếu ốc cam 15mm',
    'Tủ quần áo bị thiếu bản lề inox',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message from FurniAI
    _messages.add(
      AiChatMessage(
        text: 'Xin chào! Tôi là Trợ lý FurniAI của Sofa So Good.\nTôi có thể giúp bạn gợi ý phối đồ nội thất hoặc hỗ trợ chẩn đoán và cấp bù linh kiện bị thiếu khi lắp ráp.\n\nBạn cần hỗ trợ gì hôm nay?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(
        AiChatMessage(text: query, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await AiService.sendMessage(query);

    if (!mounted) return;
    setState(() {
      _messages.add(response);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _showSettingsDialog() {
    final urlCtrl = TextEditingController(text: AiService.localLlmUrl);
    final modelCtrl = TextEditingController(text: AiService.modelName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cấu hình Local LLM tại nhà',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có thể kết nối app trực tiếp với Ollama chạy trên máy tính cá nhân:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL Server (Ollama / LocalAI)',
                hintText: 'http://192.168.1.X:11434',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên Model LLM',
                hintText: 'qwen2.5:3b, llama3.2...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* Ghi chú: Nếu server tắt hoặc không kết nối được, FurniAI sẽ tự động kích hoạt bộ máy chuyên gia nội bộ để phản hồi ngay lập tức.',
              style: TextStyle(fontSize: 10, color: Colors.orange, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              AiService.configureLocalLlm(
                url: urlCtrl.text,
                model: modelCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu cấu hình Local LLM thành công!')),
              );
            },
            child: const Text('Lưu cấu hình'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: AppTheme.woodDark, size: 22),
            SizedBox(width: 8),
            Text(
              'Trợ lý FurniAI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.woodDark,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cấu hình Local LLM',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FurniAI đang phân tích kiến thức nội thất...',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Quick Prompts Horizontal List
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final prompt = _quickPrompts[idx];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => _handleSendMessage(prompt),
                );
              },
            ),
          ),

          // Bottom Input Bar with Safe Area for Android navigation buttons
          SafeArea(
            top: false,
            bottom: true,
            minimum: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Hỏi FurniAI về phối đồ, thiếu linh kiện...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _handleSendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, size: 18, color: Colors.white),
                      onPressed: () => _handleSendMessage(_textCtrl.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ProductModel> _getRelevantProducts(
    AiChatMessage msg,
    List<ProductModel> allProducts,
  ) {
    if (msg.isUser) return [];

    final result = <ProductModel>[];
    final addedIds = <String>{};

    void tryAdd(ProductModel p) {
      if (!addedIds.contains(p.id)) {
        addedIds.add(p.id);
        result.add(p);
      }
    }

    final lowerText = msg.text.toLowerCase();
    final lowerTarget = msg.suggestedProductOrPart?.toLowerCase() ?? '';

    // 1. Direct match with suggestedProductOrPart
    if (lowerTarget.isNotEmpty) {
      for (final p in allProducts) {
        if (p.name.toLowerCase().contains(lowerTarget) ||
            lowerTarget.contains(p.name.toLowerCase()) ||
            p.id.toLowerCase() == lowerTarget) {
          tryAdd(p);
        }
      }
    }

    // 2. Scan text for known product names or model codes
    for (final p in allProducts) {
      final nameLower = p.name.toLowerCase();
      if (lowerText.contains(nameLower)) {
        tryAdd(p);
        continue;
      }

      // Check specific keywords for products
      if (p.id == 'Bed35' &&
          (lowerText.contains('hemnes king bed') ||
              lowerText.contains('bed frame 35') ||
              lowerText.contains('bed35'))) {
        tryAdd(p);
      } else if (p.id == 'Closet23' &&
          (lowerText.contains('pax modern closet') ||
              lowerText.contains('closet 23') ||
              lowerText.contains('pax wardrobe') ||
              lowerText.contains('pax modern'))) {
        tryAdd(p);
      } else if (p.id == 'Drawer31' &&
          (lowerText.contains('koppang walnut') ||
              lowerText.contains('drawer 31') ||
              lowerText.contains('koppang'))) {
        tryAdd(p);
      } else if (p.id == 'Sofa36' &&
          (lowerText.contains('kivik') || lowerText.contains('sofa 36'))) {
        tryAdd(p);
      } else if (p.id == 'Sofa49' &&
          (lowerText.contains('landskrona') || lowerText.contains('sofa 49'))) {
        tryAdd(p);
      } else if (p.id == 'Table48' &&
          (lowerText.contains('marble luxury') ||
              lowerText.contains('table 48') ||
              lowerText.contains('cẩm thạch'))) {
        tryAdd(p);
      } else if (p.id == 'Chair01' &&
          (lowerText.contains('poäng') ||
              lowerText.contains('poang') ||
              lowerText.contains('scandi chair'))) {
        tryAdd(p);
      } else if (p.id == 'Table08' &&
          (lowerText.contains('nordic oak') ||
              lowerText.contains('table 08') ||
              lowerText.contains('bàn làm việc'))) {
        tryAdd(p);
      } else if (p.id == 'Table26' &&
          (lowerText.contains('lövbacken') || lowerText.contains('lovbacken'))) {
        tryAdd(p);
      } else if (p.id == 'Chair34' && (lowerText.contains('frosta'))) {
        tryAdd(p);
      } else if (p.id == 'Chair18' && (lowerText.contains('strandmon'))) {
        tryAdd(p);
      } else if (p.id == 'Closet01' && (lowerText.contains('hemnes 2-door'))) {
        tryAdd(p);
      } else if (p.id == 'Drawer30' && (lowerText.contains('malm 3-drawer'))) {
        tryAdd(p);
      } else if (p.id == 'Bed26' && (lowerText.contains('malm bed frame'))) {
        tryAdd(p);
      }
    }

    return result;
  }

  Widget _buildProductNavigateCard(ProductModel product) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ProductImageView(
                  imageUrl: product.image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF161B28),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currencyFormatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF805528),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF805528),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiChatMessage msg) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final relevantProducts = _getRelevantProducts(msg, productProvider.products);

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.woodDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: msg.isUser ? Colors.white : AppTheme.textPrimary,
              ),
            ),

            // Nut Tao phieu cap bu neu co yeu cau linh kien
            if (msg.suggestedAction == 'REPORT_MISSING') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF805528),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.build_circle, size: 16),
                  label: const Text(
                    'Tạo phiếu cấp bù ngay (Điền sẵn)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReportMissingDialog(
                        initialProduct: msg.suggestedProductOrPart,
                      ),
                    );
                  },
                ),
              ),
            ],

            // Cac the san pham goi y co the bam vao de navigate toi ProductDetailScreen
            if (relevantProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFEB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 13,
                      color: Color(0xFF805528),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Bấm xem ngay sản phẩm gợi ý:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF805528),
                      ),
                    ),
                  ],
                ),
              ),
              ...relevantProducts.map((p) => _buildProductNavigateCard(p)),
            ],
          ],
        ),
      ),
    );
  }
}
