class ProductReviewItem {
  final String id;
  final String orderCode;
  final String author;
  final int stars;
  final String comment;
  final List<String> media;
  final DateTime createdAt;
  bool isDeleted;
  DateTime? deletedAt;
  String? deletedBy;
  String get userName => author;
  int get rating => stars;
  List<String> get mediaUrls => media;

  ProductReviewItem({
    required this.id,
    required this.orderCode,
    required this.author,
    required this.stars,
    required this.comment,
    this.media = const [],
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderCode': orderCode,
        'author': author,
        'stars': stars,
        'comment': comment,
        'media': media,
        'createdAt': createdAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'deletedBy': deletedBy,
      };

  factory ProductReviewItem.fromJson(Map<String, dynamic> json) => ProductReviewItem(
        id: json['id'] ?? '',
        orderCode: json['orderCode'] ?? '',
        author: json['author'] ?? 'Khách hàng SOFA SO GOOD',
        stars: json['stars'] ?? 5,
        comment: json['comment'] ?? '',
        media: (json['media'] as List?)?.cast<String>() ?? [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        isDeleted: json['isDeleted'] ?? false,
        deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt']) : null,
        deletedBy: json['deletedBy'],
      );
}

class ProductModel {
  final String id;
  final String name;
  final String subtitle;
  final String material;
  final int price;
  final int? originalPrice;
  double rating;
  int reviewCount;
  final String image;
  final String? badge;
  final String category; // 'desk', 'chair', 'shelf', 'lamp', 'parts'
  final int assemblyTimeMinutes;
  final String description;
  final bool is3dReady;
  final String modelCode;
  int stockQuantity;
  final List<String> tags;
  final List<String> colors;
  final List<ProductReviewItem> reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.material,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.image,
    this.badge,
    required this.category,
    required this.assemblyTimeMinutes,
    required this.description,
    this.is3dReady = true,
    required this.modelCode,
    this.stockQuantity = 15,
    List<String>? tags,
    List<String>? colors,
    List<ProductReviewItem>? reviews,
  })  : tags = tags ?? ['Bắc Âu', 'Gỗ tự nhiên'],
        colors = colors ?? ['Gỗ sồi tự nhiên', 'Gỗ óc chó', 'Trắng Bắc Âu'],
        reviews = reviews ?? [];

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isAvailable => stockQuantity > 0;

  // Active reviews that are not soft-deleted
  List<ProductReviewItem> get activeReviews =>
      reviews.where((r) => !r.isDeleted).toList();

  double get calculatedRating {
    final active = activeReviews;
    if (active.isEmpty) return rating;
    final total = active.fold<int>(0, (sum, r) => sum + r.stars);
    return double.parse((total / active.length).toStringAsFixed(1));
  }

  int get calculatedReviewCount {
    final active = activeReviews;
    return active.isEmpty ? reviewCount : active.length;
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? material,
    int? price,
    int? originalPrice,
    double? rating,
    int? reviewCount,
    String? image,
    String? badge,
    String? category,
    int? assemblyTimeMinutes,
    String? description,
    bool? is3dReady,
    String? modelCode,
    int? stockQuantity,
    List<String>? tags,
    List<String>? colors,
    List<ProductReviewItem>? reviews,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      material: material ?? this.material,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      image: image ?? this.image,
      badge: badge ?? this.badge,
      category: category ?? this.category,
      assemblyTimeMinutes: assemblyTimeMinutes ?? this.assemblyTimeMinutes,
      description: description ?? this.description,
      is3dReady: is3dReady ?? this.is3dReady,
      modelCode: modelCode ?? this.modelCode,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      tags: tags ?? List.from(this.tags),
      colors: colors ?? List.from(this.colors),
      reviews: reviews ?? List.from(this.reviews),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'material': material,
        'price': price,
        'originalPrice': originalPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'image': image,
        'badge': badge,
        'category': category,
        'assemblyTimeMinutes': assemblyTimeMinutes,
        'description': description,
        'is3dReady': is3dReady,
        'modelCode': modelCode,
        'stockQuantity': stockQuantity,
        'tags': tags,
        'colors': colors,
        'reviews': reviews.map((r) => r.toJson()).toList(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        subtitle: json['subtitle'] ?? '',
        material: json['material'] ?? '',
        price: json['price'] ?? 0,
        originalPrice: json['originalPrice'],
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: json['reviewCount'] ?? 0,
        image: json['image'] ?? '',
        badge: json['badge'],
        category: json['category'] ?? 'desk',
        assemblyTimeMinutes: json['assemblyTimeMinutes'] ?? 15,
        description: json['description'] ?? '',
        is3dReady: json['is3dReady'] ?? true,
        modelCode: json['modelCode'] ?? '',
        stockQuantity: json['stockQuantity'] ?? 15,
        tags: (json['tags'] as List?)?.cast<String>() ?? ['Bắc Âu', 'Gỗ tự nhiên'],
        colors: (json['colors'] as List?)?.cast<String>() ?? ['Gỗ sồi tự nhiên', 'Gỗ óc chó'],
        reviews: (json['reviews'] as List?)
                ?.map((r) => ProductReviewItem.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
