import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('FlutterSecureKeyStorage Unit Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late FlutterSecureKeyStorage storage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storage = FlutterSecureKeyStorage(storage: mockStorage);
    });

    test('read delegates to FlutterSecureStorage', () async {
      when(
        () => mockStorage.read(key: 'test_key'),
      ).thenAnswer((_) async => 'stored_value');

      final result = await storage.read(key: 'test_key');

      expect(result, equals('stored_value'));
      verify(() => mockStorage.read(key: 'test_key')).called(1);
    });

    test('write delegates to FlutterSecureStorage', () async {
      when(
        () => mockStorage.write(key: 'test_key', value: 'val'),
      ).thenAnswer((_) async {});

      await storage.write(key: 'test_key', value: 'val');

      verify(() => mockStorage.write(key: 'test_key', value: 'val')).called(1);
    });

    test('delete delegates to FlutterSecureStorage', () async {
      when(() => mockStorage.delete(key: 'test_key')).thenAnswer((_) async {});

      await storage.delete(key: 'test_key');

      verify(() => mockStorage.delete(key: 'test_key')).called(1);
    });

    test('containsKey delegates to FlutterSecureStorage', () async {
      when(
        () => mockStorage.containsKey(key: 'test_key'),
      ).thenAnswer((_) async => true);

      final result = await storage.containsKey(key: 'test_key');

      expect(result, isTrue);
      verify(() => mockStorage.containsKey(key: 'test_key')).called(1);
    });

    test('deleteAll delegates to FlutterSecureStorage', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await storage.deleteAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('default constructor instantiates without error', () {
      final defaultStorage = FlutterSecureKeyStorage();
      expect(defaultStorage, isA<ISecureKeyStorage>());
    });
  });
}
