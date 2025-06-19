// lib/models/challenge.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
  });

  /// Create a Challenge from a Firestore document snapshot
  factory Challenge.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Challenge(
      id: doc.id,
      title: data?['title'] as String? ?? '',
      description: data?['description'] as String? ?? '',
    );
  }

  /// Convert a Challenge into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}