import 'package:flutter/foundation.dart';

class StockAuditLog {
  final String id;
  final String productId;
  final String? color;
  final int changeAmount;
  final int remainingStock;
  final String reason;
  final DateTime timestamp;

  StockAuditLog({
    required this.id,
    required this.productId,
    this.color,
    required this.changeAmount,
    required this.remainingStock,
    required this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'color': color,
        'changeAmount': changeAmount,
        'remainingStock': remainingStock,
        'reason': reason,
        'timestamp': timestamp.toIso8601String(),
      };
}

class InventoryService extends ChangeNotifier {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  // In-memory stock map: productId -> stockQuantity
  final Map<String, int> _stockMap = {};
  
  // Per-color stock map: 'productId_color' -> stockQuantity
  final Map<String, int> _colorStockMap = {};

  final List<StockAuditLog> _auditLogs = [];
  final Set<String> _revertedOrders = {};

  List<StockAuditLog> get auditLogs => List.unmodifiable(_auditLogs);

  // Initialize stock for product
  void initStock(String productId, int initialStock, {List<String>? colors}) {
    if (!_stockMap.containsKey(productId)) {
      _stockMap[productId] = initialStock;
      if (colors != null && colors.isNotEmpty) {
        final perColor = (initialStock / colors.length).ceil();
        for (final c in colors) {
          _colorStockMap['${productId}_$c'] = perColor;
        }
      }
    }
  }

  // Get current stock
  int getStock(String productId, {String? color}) {
    if (color != null && color.isNotEmpty) {
      final key = '${productId}_$color';
      if (_colorStockMap.containsKey(key)) {
        return _colorStockMap[key]!;
      }
    }
    return _stockMap[productId] ?? 10; // Default stock if not set
  }

  // Status check: quantity > 0 is "Còn hàng", == 0 is "Hết hàng"
  bool isAvailable(String productId, {String? color, int requestedQty = 1}) {
    final available = getStock(productId, color: color);
    return available >= requestedQty && available > 0;
  }

  // Atomic check & deduct (anti-oversell, no negative quantity)
  // Returns true if successfully deducted, false if insufficient stock
  bool deductStock({
    required String productId,
    required int quantity,
    String? color,
    required String reason,
  }) {
    final current = getStock(productId, color: color);
    if (current < quantity || quantity <= 0) {
      return false; // Insufficient stock or invalid quantity
    }

    final newStock = current - quantity;
    _stockMap[productId] = newStock;
    if (color != null && color.isNotEmpty) {
      final key = '${productId}_$color';
      _colorStockMap[key] = (_colorStockMap[key] ?? current) - quantity;
    }

    _auditLogs.insert(
      0,
      StockAuditLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        color: color,
        changeAmount: -quantity,
        remainingStock: newStock,
        reason: reason,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  // Batch deduct by order
  bool deductOrderStock({
    required String orderCode,
    required List<Map<String, dynamic>> items,
  }) {
    for (final it in items) {
      final pid = it['productId'] as String;
      final qty = (it['quantity'] as num).toInt();
      final color = it['color'] as String?;
      if (!isAvailable(pid, color: color, requestedQty: qty)) {
        return false;
      }
    }
    for (final it in items) {
      final pid = it['productId'] as String;
      final qty = (it['quantity'] as num).toInt();
      final color = it['color'] as String?;
      deductStock(
        productId: pid,
        quantity: qty,
        color: color,
        reason: 'Đặt hàng đơn #$orderCode',
      );
    }
    return true;
  }

  // Batch revert by order (with double-reversion protection)
  bool revertOrderStock({
    required String orderCode,
    required List<Map<String, dynamic>> items,
    required String reason,
  }) {
    if (_revertedOrders.contains(orderCode)) {
      return false; // Single reversion guarantee (Mục 1 & 3)
    }
    _revertedOrders.add(orderCode);
    for (final it in items) {
      final pid = it['productId'] as String;
      final qty = (it['quantity'] as num).toInt();
      final color = it['color'] as String?;
      revertStock(
        productId: pid,
        quantity: qty,
        color: color,
        reason: '$reason (Đơn #$orderCode)',
      );
    }
    return true;
  }

  // Revert stock (e.g. order cancelled or rejected)
  void revertStock({
    required String productId,
    required int quantity,
    String? color,
    required String reason,
  }) {
    if (quantity <= 0) return;

    final current = getStock(productId, color: color);
    final newStock = current + quantity;
    _stockMap[productId] = newStock;
    if (color != null && color.isNotEmpty) {
      final key = '${productId}_$color';
      _colorStockMap[key] = (_colorStockMap[key] ?? current) + quantity;
    }

    _auditLogs.insert(
      0,
      StockAuditLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        color: color,
        changeAmount: quantity,
        remainingStock: newStock,
        reason: reason,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  // Admin manually updates stock quantity
  void updateStock({
    required String productId,
    required int newQuantity,
    String? color,
    required String reason,
  }) {
    final safeQty = newQuantity < 0 ? 0 : newQuantity;
    final current = getStock(productId, color: color);
    final diff = safeQty - current;

    _stockMap[productId] = safeQty;
    if (color != null && color.isNotEmpty) {
      final key = '${productId}_$color';
      _colorStockMap[key] = safeQty;
    }

    _auditLogs.insert(
      0,
      StockAuditLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        color: color,
        changeAmount: diff,
        remainingStock: safeQty,
        reason: reason,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }
}
