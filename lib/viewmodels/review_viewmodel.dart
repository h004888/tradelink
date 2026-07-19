import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();
  final String transactionId;
  final String targetId;

  ReviewViewModel({required this.transactionId, required this.targetId});

  UiState<void> _state = const Idle();
  UiState<void> get state => _state;
  int _rating = 0;
  int get rating => _rating;
  int _communication = 0, _punctuality = 0, _quality = 0;
  int get communication => _communication;
  int get punctuality => _punctuality;
  int get quality => _quality;
  String _comment = '';
  String get comment => _comment;

  final Set<String> _selectedTags = {};
  Set<String> get selectedTags => Set.unmodifiable(_selectedTags);

  void setRating(int v) { _rating = v; notifyListeners(); }
  void setCommunication(int v) { _communication = v; notifyListeners(); }
  void setPunctuality(int v) { _punctuality = v; notifyListeners(); }
  void setQuality(int v) { _quality = v; notifyListeners(); }
  void setComment(String v) { _comment = v; }

  void toggleTag(String tag) {
    if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
    notifyListeners();
  }

  String? validate() {
    if (_rating == 0) return 'Vui lòng chọn đánh giá tổng';
    if (_communication == 0) return 'Vui lòng đánh giá giao tiếp';
    if (_punctuality == 0) return 'Vui lòng đánh giá đúng hẹn';
    if (_quality == 0) return 'Vui lòng đánh giá chất lượng';
    return null;
  }

  Future<bool> submit() async {
    final v = validate();
    if (v != null) {
      _state = Error(message: v, retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();

    final tagsPrefix = _selectedTags.isNotEmpty ? _selectedTags.map((t) => '#$t').join(' ') : '';
    final fullComment = [tagsPrefix, _comment].where((s) => s.isNotEmpty).join('\n');

    final res = await _repository.submitReview(
      transactionId: transactionId,
      targetId: targetId,
      rating: _rating,
      communication: _communication,
      punctuality: _punctuality,
      quality: _quality,
      comment: fullComment.isNotEmpty ? fullComment : null,
    );
    switch (res) {
      case ResultSuccess<bool>():
        _state = const Success(null);
        notifyListeners();
        return true;
      case FailureResult<bool>(:final failure):
        _state = Error(message: failure.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
