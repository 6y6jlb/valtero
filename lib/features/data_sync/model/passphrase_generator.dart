import 'dart:math';

import 'package:valtero/features/data_sync/model/passphrase_wordlist.dart';

/// Builds a readable passphrase: four wordlist words + numeric suffix.
///
/// Example shape: `orange-river-lamp-stone-42`.
String generatePassphrase([Random? random]) {
  final rng = random ?? Random.secure();
  final words = List<String>.generate(
    4,
    (_) => kPassphraseWordlist[rng.nextInt(kPassphraseWordlist.length)],
  );
  final suffix = rng.nextInt(100);
  return '${words.join('-')}-$suffix';
}
