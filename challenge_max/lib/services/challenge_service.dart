// lib/services/challenge_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams the list of challenges for the current ISO week
  Stream<List<Challenge>> streamWeeklyChallenges() {
    final now = DateTime.now();
    final weekKey = _weekKey(now);
    return _db
      .collection('weeks')
      .doc(weekKey)
      .collection('challenges')
      .orderBy('order')              // ← add this line
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => Challenge.fromDoc(doc))
        .toList(),
      );
  }

  /// Create or update a challenge for the current week
  Future<void> updateChallenge(Challenge challenge) {
    final now = DateTime.now();
    final weekKey = _weekKey(now);
    return _db
        .collection('weeks')
        .doc(weekKey)
        .collection('challenges')
        .doc(challenge.id)
        .set(challenge.toMap(), SetOptions(merge: true));
  }

  /// Helper to compute ISO week key as "YYYY-Www"
  String _weekKey(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final diff = date.difference(jan4).inDays;
    final weekNumber = 1 + ((diff + jan4.weekday - 1) ~/ 7);
    final w = weekNumber.toString().padLeft(2, '0');
    return '${date.year}-W$w';
  }
}
