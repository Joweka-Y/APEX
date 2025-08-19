import 'dart:convert';

class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final double price;
  final String description;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String location;
  final String condition;
  final int mileage;
  final String fuelType;
  final String transmission;
  final String color;
  final List<String> features;
  final DateTime createdAt;
  final bool isSold;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.location,
    required this.condition,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.color,
    required this.features,
    required this.createdAt,
    this.isSold = false,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    // Parse features field properly
    List<String> features;
    if (json['features'] == null ||
        json['features'].toString().trim().isEmpty) {
      features = [];
    } else if (json['features'] is String) {
      final featuresStr = json['features'].toString().trim();
      if (featuresStr.isEmpty) {
        features = [];
      } else {
        try {
          // Try to parse as JSON string first
          final decoded = jsonDecode(featuresStr);
          if (decoded is List) {
            features = decoded.cast<String>();
          } else {
            // Fallback to comma-separated string
            features = featuresStr
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (e) {
          // If JSON parsing fails, use comma-separated string
          features = featuresStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } else if (json['features'] is List) {
      features = List<String>.from(json['features']);
    } else {
      features = [];
    }

    return Car(
      id: json['id']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      price: json['price'] is num
          ? json['price'].toDouble()
          : double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      condition: json['condition']?.toString() ?? '',
      mileage: json['mileage'] is int
          ? json['mileage']
          : int.tryParse(json['mileage']?.toString() ?? '0') ?? 0,
      fuelType: json['fuelType']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      features: features,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSold: json['isSold'] == 1 || json['isSold'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'location': location,
      'condition': condition,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'color': color,
      'features': features.isNotEmpty ? jsonEncode(features) : '[]',
      'createdAt': createdAt.toIso8601String(),
      'isSold': isSold ? 1 : 0, // Convert boolean to integer
    };
  }

  Car copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    double? price,
    String? description,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? location,
    String? condition,
    int? mileage,
    String? fuelType,
    String? transmission,
    String? color,
    List<String>? features,
    DateTime? createdAt,
    bool? isSold,
  }) {
    return Car(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      color: color ?? this.color,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      isSold: isSold ?? this.isSold,
    );
  }
}
