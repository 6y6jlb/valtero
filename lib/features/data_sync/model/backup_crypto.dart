import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Argon2id → AES-256-GCM for encrypted backup payloads.
class BackupCrypto {
  BackupCrypto({
    Argon2id? kdf,
    AesGcm? cipher,
  })  : _kdf = kdf ??
            Argon2id(
              parallelism: 2,
              memory: 19456,
              iterations: 2,
              hashLength: 32,
            ),
        _cipher = cipher ?? AesGcm.with256bits();

  final Argon2id _kdf;
  final AesGcm _cipher;

  static const int saltLength = 16;

  Future<EncryptedBackupBytes> encryptBytes({
    required List<int> clearBytes,
    required String passphrase,
  }) async {
    final salt = _randomBytes(saltLength);
    final secretKey = await _deriveKey(passphrase, salt);
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(
      clearBytes,
      secretKey: secretKey,
      nonce: nonce,
    );
    // Store cipherText || mac; nonce is kept separately in the outer file.
    final ciphertext = Uint8List.fromList([
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
    return EncryptedBackupBytes(
      salt: Uint8List.fromList(salt),
      nonce: Uint8List.fromList(nonce),
      ciphertext: ciphertext,
    );
  }

  Future<Uint8List> decryptBytes({
    required List<int> salt,
    required List<int> nonce,
    required List<int> ciphertext,
    required String passphrase,
  }) async {
    final macLength = _cipher.macAlgorithm.macLength;
    if (ciphertext.length <= macLength) {
      throw const BackupCryptoException('ciphertext_too_short');
    }
    final cipherText = ciphertext.sublist(0, ciphertext.length - macLength);
    final macBytes = ciphertext.sublist(ciphertext.length - macLength);
    final secretKey = await _deriveKey(passphrase, salt);
    try {
      final clear = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
        secretKey: secretKey,
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const BackupWrongPassphraseException();
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    return _kdf.deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  List<int> _randomBytes(int length) {
    final bytes = Uint8List(length);
    final rng = Random.secure();
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }
}

class EncryptedBackupBytes {
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List ciphertext;

  const EncryptedBackupBytes({
    required this.salt,
    required this.nonce,
    required this.ciphertext,
  });
}

class BackupCryptoException implements Exception {
  final String code;
  const BackupCryptoException(this.code);

  @override
  String toString() => 'BackupCryptoException($code)';
}

class BackupWrongPassphraseException implements Exception {
  const BackupWrongPassphraseException();

  @override
  String toString() => 'BackupWrongPassphraseException';
}

String encodeBase64(List<int> bytes) => base64Encode(bytes);

Uint8List decodeBase64(String value) => base64Decode(value);
