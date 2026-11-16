class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = "",
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "isOnline": isOnline,
      "lastSeen": lastSeen.microsecondsSinceEpoch,
      "createdAt": createdAt.microsecondsSinceEpoch,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: _parseDateTime(map['lastSeen']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMicrosecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
