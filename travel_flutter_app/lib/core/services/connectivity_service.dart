import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

/// 네트워크 연결 상태 관리 서비스
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();

  bool _isOnline = true;

  /// 온라인 상태 스트림
  Stream<bool> get onlineStream => _onlineController.stream;

  /// 현재 온라인 상태
  bool get isOnline => _isOnline;

  /// 연결 상태 모니터링 시작
  Future<void> initialize() async {
    // 초기 연결 상태 확인
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // 연결 상태 변경 감지
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        Logger.error('연결 상태 감지 오류', error, null, 'ConnectivityService');
      },
    );

    Logger.info(
      '연결 상태 모니터링 시작: ${_isOnline ? "온라인" : "오프라인"}',
      'ConnectivityService',
    );
  }

  /// 연결 상태 업데이트
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;

    // ConnectivityResult.none이 아니면 온라인
    _isOnline = result != ConnectivityResult.none;

    // 상태 변경 시 로깅 및 이벤트 발생
    if (wasOnline != _isOnline) {
      Logger.info(
        '연결 상태 변경: ${_isOnline ? "온라인" : "오프라인"}',
        'ConnectivityService',
      );
      _onlineController.add(_isOnline);
    }
  }

  /// 리소스 해제
  void dispose() {
    _connectivitySubscription?.cancel();
    _onlineController.close();
  }
}
