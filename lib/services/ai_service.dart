import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? suggestedAction;
  final String? suggestedProductOrPart;

  AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedAction,
    this.suggestedProductOrPart,
  });
}

class AiService {
  // Cau hinh Local LLM (Ollama / LM Studio) hoac Gemini
  static String localLlmUrl = 'http://10.0.2.2:11434'; // 10.0.2.2 cho Android Emulator, doi thanh IP LAN khi chay tren dien thoai that
  static String modelName = 'qwen2.5:3b';
  static String? geminiApiKey;

  static void configureLocalLlm({required String url, String? model}) {
    localLlmUrl = url.trim();
    if (model != null && model.isNotEmpty) {
      modelName = model.trim();
    }
  }

  // Gui tin nhan toi AI va nhan phan hoi
  static Future<AiChatMessage> sendMessage(String userPrompt) async {
    final lower = userPrompt.toLowerCase();

    // 1. Thu goi Local LLM (Ollama) neu duoc cau hinh
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final uri = Uri.parse('$localLlmUrl/api/generate');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final systemPrompt = '''
Ban la FurniAI - Chuyen gia tu van noi that thong minh va ho tro ky thuat cua he thong Furni3D (Sofa So Good).
Cac san pham 3D Furni3D:
1. Poang Scandi Chair (Ghe uon nhiet Scandinavia, model CHAIR-01)
2. Eames Lounge Chair (Ghe boc da cong thai hoc, model CHAIR-18)
3. Strandmon Wing Chair (Ghe tua lung cao co dien, model CHAIR-34)
4. Pax Wardrobe Closet (Tu quan ao 2 canh, model CLOSET-01)
5. Koppang Dresser Drawer (Tu ngan keo 3 tang go soi, model DRAWER-30)
6. Nordic Oak Desk (Ban lam viec go soi nhap khau, model TABLE-08)
7. Hemnes Wood Table (Tu dau giuong ngan keo, model TABLE-09)
8. Noguchi Coffee Table (Ban tra dang la mat kinh, model TABLE-26)

Cac phu kien linh kien thay the san co:
- Oc cam lien ket 15mm & chot go phi 8
- Ban le giam chan canh tu inox 304
- Mieng dem cao su boc chan ban/ghe chong tray
- Tay nam dong thau chai xuoc Nordic

Hay tra loi ngan gon, than thien, chu dao bang tieng Viet. Neu khach bao thieu linh kien lap rap, hay xac dinh ten linh kien va khuyen khach tao phieu cap bu mien phi.
''';

      final body = jsonEncode({
        'model': modelName,
        'prompt': '$systemPrompt\nNguoi dung: $userPrompt\nFurniAI:',
        'stream': false,
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final resBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(resBody) as Map<String, dynamic>;
        final aiText = data['response'] as String?;
        if (aiText != null && aiText.trim().isNotEmpty) {
          return _parseResponseWithAction(aiText.trim(), lower);
        }
      }
    } catch (e) {
      debugPrint('[AiService] Local LLM not available or offline: $e. Falling back to Furni3D Knowledge Engine.');
    }

    // 2. Fallback sang Bo quy tac Chuyen gia Furni3D (dam bao luon hoat dong 100% khong bao gio loi)
    return _generateExpertFallbackResponse(userPrompt, lower);
  }

  static AiChatMessage _parseResponseWithAction(String aiText, String lowerPrompt) {
    String? action;
    String? target;

    if (lowerPrompt.contains('thiếu') || lowerPrompt.contains('báo thiếu') || lowerPrompt.contains('hỏng') || lowerPrompt.contains('phụ kiện') || lowerPrompt.contains('ốc')) {
      action = 'REPORT_MISSING';
      if (lowerPrompt.contains('bàn')) target = 'Nordic Oak Desk';
      else if (lowerPrompt.contains('ghế')) target = 'Poäng Scandi Chair';
      else if (lowerPrompt.contains('tủ')) target = 'Pax Wardrobe Closet';
    }

    return AiChatMessage(
      text: aiText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedAction: action,
      suggestedProductOrPart: target,
    );
  }

  static AiChatMessage _generateExpertFallbackResponse(String originalPrompt, String lower) {
    // Kiem tra chu de: Bao thieu linh kien / ho tro lap rap
    if (lower.contains('thiếu') || lower.contains('mất') || lower.contains('ốc') || lower.contains('bản lề') || lower.contains('chốt') || lower.contains('gãy') || lower.contains('phụ kiện')) {
      String identifiedPart = 'Ốc cam liên kết 15mm & Chốt gỗ phi 8';
      String productName = 'Nordic Oak Desk';

      if (lower.contains('bản lề') || lower.contains('cánh tủ') || lower.contains('tủ quần áo')) {
        identifiedPart = 'Bản lề giảm chấn cánh tủ inox 304';
        productName = 'Pax Wardrobe Closet';
      } else if (lower.contains('chân') || lower.contains('đệm') || lower.contains('trầy')) {
        identifiedPart = 'Miếng đệm cao su bọc chân bàn ghế';
        productName = 'Poäng Scandi Chair';
      } else if (lower.contains('tay nắm') || lower.contains('ngăn kéo')) {
        identifiedPart = 'Tay nắm đồng thau chải xước Nordic';
        productName = 'Koppang Dresser Drawer';
      }

      final reply = '''
FurniAI đã nhận diện trường hợp của bạn!
• Bộ phận chẩn đoán: $identifiedPart
• Dành cho sản phẩm: $productName

Theo chính sách bảo hành hậu mãi của Furni3D, toàn bộ linh kiện bị thiếu hoặc cong vênh khi bóc hộp sẽ được CẤP BÙ MIỄN PHÍ 100% và chuyển phát nhanh Viettel Post trong 48h.

Bạn có thể ấn nút "Tạo phiếu cấp bù ngay" bên dưới để hệ thống tự động điền sẵn thông tin!''';

      return AiChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedAction: 'REPORT_MISSING',
        suggestedProductOrPart: productName,
      );
    }

    // Kiem tra chu de: Goi y phoi san pham (Cross-sell / Decor)
    if (lower.contains('phòng khách') || lower.contains('sofa') || lower.contains('ghế') || lower.contains('bàn trà')) {
      return AiChatMessage(
        text: '''
Gợi ý phối không gian Phòng khách phong cách Bắc Âu (Scandinavian):
1. Ghế bành chủ đạo: Poäng Scandi Chair (Ghế gỗ uốn nhiệt công thái học)
2. Bàn trà trung tâm: Noguchi Coffee Table (Mặt kính cường lực dáng lá)
3. Tủ lưu trữ: Koppang Dresser Drawer (Tủ 3 tầng gỗ sồi vân tự nhiên)

Sự kết hợp này mang lại ánh sáng ấm cúng, tối ưu diện tích và đồng bộ 100% mã màu gỗ sồi tự nhiên!''',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedAction: 'VIEW_PRODUCT',
        suggestedProductOrPart: 'Poäng Scandi Chair',
      );
    }

    if (lower.contains('phòng làm việc') || lower.contains('bàn làm việc') || lower.contains('học')) {
      return AiChatMessage(
        text: '''
Gợi ý góc làm việc tập trung Minimalism:
1. Bàn làm việc: Nordic Oak Desk (Kích thước 1m4 chuẩn chỉ, gỗ sồi nhập khẩu)
2. Ghế ngồi: Eames Lounge Chair (Nâng đỡ cột sống, đệm da êm ái khi ngồi lâu)
3. Kệ đầu bàn: Hemnes Wood Table (Để tài liệu và ổ cắm gọn gàng)

Các sản phẩm đều có mô hình 3D AR để bạn ướm thử trực tiếp vào phòng trước khi quyết định!''',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedAction: 'VIEW_PRODUCT',
        suggestedProductOrPart: 'Nordic Oak Desk',
      );
    }

    // Mac dinh
    return AiChatMessage(
      text: '''
Xin chào! Tôi là Trợ lý FurniAI. Tôi có thể hỗ trợ bạn:
• Gợi ý phối đồ nội thất theo phong cách (Scandi, Japandi, Modern)
• Hướng dẫn ráp đồ và mở bản vẽ 3D tương tác
• Chẩn đoán và hỗ trợ tạo phiếu cấp bù linh kiện thiếu miễn phí

Bạn cần FurniAI tư vấn về căn phòng hay sản phẩm nào?''',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
