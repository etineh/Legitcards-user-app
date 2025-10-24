import 'package:flutter/cupertino.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../data/models/notification_model.dart';
import '../../data/repository/app_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  final List<NotificationM> _notifications = [];
  List<NotificationM> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchNotifications(String userid, String token,
      {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      // _notifications.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getNotifications(
        userid,
        token,
        page: _currentPage,
      );

      if (response.allNote.isEmpty) {
        _hasMore = false;
      } else {
        _notifications.clear(); // remove if auto is active
        _notifications.addAll(response.allNote);
        _currentPage++;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDeviceToken(
      Map<String, dynamic> payload, String token) async {
    final res = await getResponse(_repository.savePushToken(payload, token));
    if (res.status == "success") {
      // print("I have save token");
    }
  }

  // Future<void> saveNotificationToBackend(
  //     Map<String, dynamic> payload, String token) async {
  //   final res = await getResponse(
  //       _repository.saveNotificationToBackend(payload, token));
  //   if (res.status == "success") {
  //     print("General log: I have save the notification");
  //   }
  // }

  // reusable function
  Future<T> getResponse<T>(Future<T> repoCall, {bool shouldLoad = true}) async {
    if (shouldLoad) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      return await repoCall;
    } catch (e) {
      rethrow;
    } finally {
      if (shouldLoad) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
  }
}
