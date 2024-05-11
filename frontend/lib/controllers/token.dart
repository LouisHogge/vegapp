import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A class that handles storing, retrieving, and deleting authentication tokens.
class Token {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Stores the provided token securely.
  ///
  /// Returns `true` if the token starts with the token header "eyJhbGciOiJIUzI1NiJ9" and is successfully stored,
  /// otherwise returns `false`.
  Future<bool> storeToken(String token) async {
    if (token.startsWith("eyJhbGciOiJIUzI1NiJ9")) {
      await _storage.write(key: 'auth_token', value: token);
      return true;
    } else {
      return false;
    }
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the token as a [String], or `null` if no token is stored.
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Deletes the stored authentication token.
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
