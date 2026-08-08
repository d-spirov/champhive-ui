import 'package:flutter_test/flutter_test.dart';
import 'package:team_hive/shared/services/csrf_interceptor.dart';

void main() {
  test('CsrfInterceptor treats write methods as mutating', () {
    expect(CsrfInterceptor.isMutating('POST'), isTrue);
    expect(CsrfInterceptor.isMutating('put'), isTrue);
    expect(CsrfInterceptor.isMutating('PATCH'), isTrue);
    expect(CsrfInterceptor.isMutating('DELETE'), isTrue);
    expect(CsrfInterceptor.isMutating('GET'), isFalse);
    expect(CsrfInterceptor.isMutating('HEAD'), isFalse);
  });
}
