// File: lib/models/address_model.dart

// Model cho Tỉnh/Thành phố
class Province {
  final int code;
  final String name;

  Province({required this.code, required this.name});

  // Factory để parse JSON từ API
  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'] as int,
      name: json['name'] as String,
    );
  }
}

// Model cho Quận/Huyện
class District {
  final int code;
  final String name;

  District({required this.code, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'] as int,
      name: json['name'] as String,
    );
  }
}

// Model cho Phường/Xã
class Ward {
  final int code;
  final String name;

  Ward({required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'] as int,
      name: json['name'] as String,
    );
  }
}