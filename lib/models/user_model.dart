import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Helper method to parse DateTime from various possible formats
  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value == null) return null;
      
      // If it's already a DateTime, return it
      if (value is DateTime) return value;
      
      // If it's a Timestamp, convert to DateTime
      if (value is Timestamp) return value.toDate();
      
      // If it's an int (microseconds since epoch), convert to DateTime
      if (value is int) return DateTime.fromMicrosecondsSinceEpoch(value);
      
      // If it's a String, try to parse it
      if (value is String) return DateTime.parse(value);
      
      // If it's a double, treat as milliseconds since epoch
      if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      
      return null;
    } catch (e) {
      print('UserModel: Error parsing DateTime from value: $value, error: $e');
      return null;
    }
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
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}