class UserModel {
  final String email;
  final String name;
  final String jwtToken;
  final String message;
  final bool success;

  UserModel({
    required this.email,
    required this.name,
    required this.jwtToken,
    required this.message,
    required this.success,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String,
      jwtToken: json['jwtToken'] as String,
      message: json['message'] as String,
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'jwtToken': jwtToken,
    'message': message,
    'success': success,
  };
}