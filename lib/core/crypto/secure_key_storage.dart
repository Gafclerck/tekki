import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrat abstrait pour le stockage sécurisé des clés cryptographiques privées (Keystore/Keychain).
abstract interface class ISecureKeyStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<bool> containsKey({required String key});
  Future<void> deleteAll();
}

/// Implémentation basée sur [FlutterSecureStorage] avec chiffrement matériel Android
/// et options de SharedPreferences chiffrées.
class FlutterSecureKeyStorage implements ISecureKeyStorage {
  FlutterSecureKeyStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
