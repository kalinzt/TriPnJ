import 'dart:async';

/// Debouncer - 연속된 이벤트에서 마지막 호출만 실행
///
/// 사용자가 필터를 연속으로 변경할 때 마지막 요청만 실행하여 불필요한 API 호출 방지
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  /// 디바운스된 함수 실행
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// 취소
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 리소스 해제
  void dispose() {
    cancel();
  }
}
