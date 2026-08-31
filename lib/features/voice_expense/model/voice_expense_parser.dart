import 'package:valtero/features/voice_expense/model/voice_expense_draft.dart';
import 'package:valtero/features/voice_expense/model/voice_match_candidate.dart';
import 'package:valtero/shared/utils/money.dart';

/// Optional currency tokens → ISO 4217. Kept small and language-agnostic
/// (symbols + common ISO / short forms). Unknown → leave null for form default.
const Map<String, String> kVoiceCurrencyTokens = {
  '₽': 'RUB',
  'руб': 'RUB',
  'рубл': 'RUB',
  'rub': 'RUB',
  'ruble': 'RUB',
  'rubles': 'RUB',
  '\$': 'USD',
  'usd': 'USD',
  'dollar': 'USD',
  'dollars': 'USD',
  '€': 'EUR',
  'eur': 'EUR',
  'euro': 'EUR',
  'euros': 'EUR',
  '£': 'GBP',
  'gbp': 'GBP',
  'pound': 'GBP',
  'pounds': 'GBP',
  '¥': 'JPY',
  'jpy': 'JPY',
  'yen': 'JPY',
  'cny': 'CNY',
  'yuan': 'CNY',
  'rsd': 'RSD',
  'дин': 'RSD',
  'din': 'RSD',
  'rs': 'INR',
  'inr': 'INR',
  'try': 'TRY',
  'tl': 'TRY',
  'chf': 'CHF',
  'pln': 'PLN',
  'zł': 'PLN',
  'czk': 'CZK',
  'uah': 'UAH',
  'грн': 'UAH',
  'kzt': 'KZT',
  'тенге': 'KZT',
};

final _amountPattern = RegExp(
  r'(?<!\d)(\d{1,3}(?:[ \u00a0]\d{3})+|\d+)([.,]\d{1,2})?(?!\d)',
);

/// Pure transcript → [VoiceExpenseDraft] (no I/O, no Flutter).
VoiceExpenseDraft parseVoiceTranscript(
  String transcript, {
  List<VoiceMatchCandidate> tags = const [],
  List<VoiceMatchCandidate> paymentMethods = const [],
}) {
  final trimmed = transcript.trim();
  final lower = trimmed.toLowerCase();

  final amountMinor = _parseFirstAmount(trimmed);
  final currencyCode = _parseCurrency(lower);
  final tagId = _bestMatchId(lower, tags);
  final paymentMethodId = _bestMatchId(lower, paymentMethods);

  return VoiceExpenseDraft(
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    tagId: tagId,
    paymentMethodId: paymentMethodId,
    transcript: trimmed,
  );
}

int? _parseFirstAmount(String text) {
  final match = _amountPattern.firstMatch(text);
  if (match == null) return null;
  final whole = (match.group(1) ?? '').replaceAll(RegExp(r'[ \u00a0]'), '');
  final fraction = match.group(2);
  final raw = fraction == null ? whole : '$whole$fraction';
  final minor = Money.parseMajorToMinor(raw);
  return minor > 0 ? minor : null;
}

String? _parseCurrency(String lower) {
  // Prefer longer tokens first so "rubles" wins over "rub".
  final entries = kVoiceCurrencyTokens.entries.toList()
    ..sort((a, b) => b.key.length.compareTo(a.key.length));

  for (final e in entries) {
    final token = e.key.toLowerCase();
    if (token.length == 1) {
      if (lower.contains(token)) return e.value;
      continue;
    }
    // Whole word or inflection prefix (рубл → рублей / rubles).
    final pattern = RegExp(
      r'(^|[^\p{L}\p{N}])' +
          RegExp.escape(token) +
          r'[\p{L}\p{N}]*([^\p{L}\p{N}]|$)',
      unicode: true,
    );
    if (pattern.hasMatch(lower)) return e.value;
  }
  return null;
}

int? _bestMatchId(String lowerTranscript, List<VoiceMatchCandidate> candidates) {
  VoiceMatchCandidate? best;
  var bestScore = 0;
  for (final c in candidates) {
    final label = c.label.trim().toLowerCase();
    if (label.isEmpty) continue;
    final score = _matchScore(lowerTranscript, label);
    if (score > bestScore) {
      bestScore = score;
      best = c;
    }
  }
  // Require at least a full-word / full-label hit.
  if (best == null || bestScore < 2) return null;
  return best.id;
}

/// Higher is better. 0 = no match, 1 = weak substring, 2+ = word/label hit.
int _matchScore(String lowerTranscript, String lowerLabel) {
  if (lowerTranscript == lowerLabel) return 100;
  if (lowerLabel.length < 2) return 0;

  final wordPattern = RegExp(
    r'(^|[^\p{L}\p{N}])' + RegExp.escape(lowerLabel) + r'([^\p{L}\p{N}]|$)',
    unicode: true,
  );
  if (wordPattern.hasMatch(lowerTranscript)) {
    return 10 + lowerLabel.length;
  }

  // Multi-word label: require all significant words present.
  final parts = lowerLabel
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((p) => p.length >= 3)
      .toList();
  if (parts.length >= 2 && parts.every(lowerTranscript.contains)) {
    return 5 + parts.fold<int>(0, (s, p) => s + p.length);
  }

  if (lowerLabel.length >= 4 && lowerTranscript.contains(lowerLabel)) {
    return 3;
  }
  return 0;
}
