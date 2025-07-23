class Place {
  final String id;
  final String name;
  final String photoRef;
  final double rating;
  final String address;
  final String type;
  final String phone;
  final List reviews;
  final List openingHours;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.name,
    required this.photoRef,
    required this.rating,
    required this.address,
    required this.type,
    required this.phone,
    required this.reviews,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'placeId': id,
    'title': name,
    'imageUrls': [photoRef],
    'address': address,
    'searchString': type,
    'phone': phone,
    'reviews': reviews,
    'openingHours': openingHours,
    'location': {'lat': latitude, 'lng': longitude},
  };

  factory Place.fromMap(Map<String, dynamic> map) {
    // Xử lý ảnh bị null hoặc là List, hoặc String
    String getPhotoRef(dynamic imageUrls) {
      if (imageUrls == null) return 'https://via.placeholder.com/150';
      if (imageUrls is List && imageUrls.isNotEmpty) return imageUrls[0];
      if (imageUrls is String) return imageUrls;
      return 'https://via.placeholder.com/150';
    }

    // Xử lý rating (nếu có)
    double parseRating(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Place(
      id: map['placeId'] ?? '',
      name: map['title'] ?? '',
      photoRef: getPhotoRef(map['imageUrls']),
      rating: parseRating(map['rating']),
      address: map['address'] ?? '',
      type: map['searchString'] ?? '',
      phone: map['phone'] ?? '',
      reviews: map['reviews'] ?? [],
      openingHours: map['openingHours'] ?? [],
      latitude: map['location']?['lat']?.toDouble() ?? 0.0,
      longitude: map['location']?['lng']?.toDouble() ?? 0.0,
    );
  }
}
