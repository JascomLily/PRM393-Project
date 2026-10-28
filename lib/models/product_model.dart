class ProductModel {
  final String id;
  final String name;
  final String subtitle;
  final String material;
  final int price;
  final int? originalPrice;
  final double rating;
  final int reviewCount;
  final String image;
  final String? badge;
  final String category; // 'desk', 'chair', 'shelf', 'lamp', 'parts'
  final int assemblyTimeMinutes;
  final String description;
  final bool is3dReady;
  final String modelCode;

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
  });

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
      );
}
