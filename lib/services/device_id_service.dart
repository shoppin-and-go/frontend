import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const _keyDeviceId = 'device_id';
  static String? _deviceId;

  static String get deviceId {
    // 아직 디바이스 ID가 설정되지 않았다면 임시 ID 반환
    return _deviceId ?? 'test-device-id';
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_keyDeviceId);

    if (_deviceId == null) {
      _deviceId = const Uuid().v4(); // 완전히 유니크한 ID 생성
      await prefs.setString(_keyDeviceId, _deviceId!);
    }
  }
}
