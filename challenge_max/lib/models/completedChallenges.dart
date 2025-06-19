import 'package:flutter/foundation.dart';

class CompletedChallenges extends ChangeNotifier {
  final Set<String> _done = {};

  /// Mark a challenge done and notify.
  void markDone(String id) {
    if (_done.add(id)) {
      notifyListeners();
    }
  }

  /// True only if this exact id is done.
  bool isDone(String id) => _done.contains(id);

  /// True if all 25 are done.
  bool get isFullBoard => _done.length >= 25;

  /// Winning lines (rows, cols, diags) by challenge ID.
  List<List<String>> get _winningLines {
    // rows
    final rows = List.generate(5, (r) => List.generate(
      5, (c) => 'challenge_${r*5 + c + 1}'
    ));
    // cols
    final cols = List.generate(5, (c) => List.generate(
      5, (r) => 'challenge_${r*5 + c + 1}'
    ));
    // diags
    final diag1 = List.generate(5, (i) => 'challenge_${i*6 + 1}');
    final diag2 = List.generate(5, (i) => 'challenge_${(i+1)*4 + 1}');
    return [...rows, ...cols, diag1, diag2];
  }

  /// True if any winning line is fully done.
  bool get hasBingo {
    return _winningLines.any((line) =>
      line.every((id) => _done.contains(id))
    );
  }
}
