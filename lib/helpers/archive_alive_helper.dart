import 'package:http/http.dart' as http;
import 'dart:async';

Future<String> isHttpConnectionGood({
  required Function(bool) onPageOffline,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final url = Uri.parse('https://www.archive.org');

  try {
    final response = await http.get(url).timeout(timeout);
    print("isHttpConnectionGood response.statusCode: ${response.statusCode}");
    if (response.statusCode >= 200 && response.statusCode < 404) {
      if (_isTemporarilyOffline(response.body)) {
        onPageOffline(true);
        return 'Temporarily Offline';
      }
      onPageOffline(false);
      return 'Connection Successful';
    } else {
      return 'HTTP Request Failed (${response.statusCode})';
    }
  } on TimeoutException catch (_) {
    onPageOffline(true);

    return 'Connection Timeout';
  } catch (e) {
    onPageOffline(true);

    return 'HTTP Request Error: $e';
  }
}

bool _isTemporarilyOffline(String body) {
  return body.toLowerCase().contains('temporarily offline') ||
      body.toLowerCase().contains('service unavailable') ||
      body.toLowerCase().contains('server error') ||
      body.toLowerCase().contains('503 service unavailable');
}

Future<String> checkConnectionWithRetries({
  required Function(bool) onPageOffline,
  required int retryCount,
  Duration delayBetweenRetries = const Duration(seconds: 1),
}) async {
  for (int i = 0; i < retryCount; i++) {
    final result = await isHttpConnectionGood(onPageOffline: onPageOffline);
    print("checkConnectionWithRetries result: $result");
    if (result == 'Connection Successful' ||
        result == 'Temporarily Offline' ||
        result == '403 Forbidden') {
      return result;
    }
    await Future.delayed(delayBetweenRetries);
  }
  return 'Connection Failed After Multiple Attempts';
}
