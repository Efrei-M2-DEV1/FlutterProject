import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/auth/data/auth_service.dart';

void main() {
  late AuthService service;

  setUp(() {
    service = AuthService();
  });

  test('login succeeds with valid credentials', () async {
    final result = await service.login('admin@todolist.com', '123456');
    expect(result.success, isTrue);
    expect(service.isLoggedIn, isTrue);
    expect(service.currentUserEmail, 'admin@todolist.com');
  });

  test('login fails with invalid credentials', () async {
    final result = await service.login('wrong@example.com', 'bad');
    expect(result.success, isFalse);
    expect(service.isLoggedIn, isFalse);
  });

  test('logout resets state', () async {
    await service.login('admin@todolist.com', '123456');
    await service.logout();
    expect(service.isLoggedIn, isFalse);
    expect(service.currentUserEmail, isNull);
  });
}
