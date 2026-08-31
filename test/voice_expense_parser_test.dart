import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/voice_expense/model/voice_expense_parser.dart';
import 'package:valtero/features/voice_expense/model/voice_match_candidate.dart';

void main() {
  group('parseVoiceTranscript amount', () {
    test('parses integer amount', () {
      final draft = parseVoiceTranscript('кофе 350 рублей');
      expect(draft.amountMinor, 35000);
      expect(draft.currencyCode, 'RUB');
      expect(draft.transcript, 'кофе 350 рублей');
    });

    test('parses decimal with comma', () {
      final draft = parseVoiceTranscript('12,50 euro');
      expect(draft.amountMinor, 1250);
      expect(draft.currencyCode, 'EUR');
    });

    test('parses decimal with dot', () {
      final draft = parseVoiceTranscript('spent 19.99 dollars');
      expect(draft.amountMinor, 1999);
      expect(draft.currencyCode, 'USD');
    });

    test('parses spaced thousands', () {
      final draft = parseVoiceTranscript('1 200 руб');
      expect(draft.amountMinor, 120000);
      expect(draft.currencyCode, 'RUB');
    });

    test('returns null amount when no digits', () {
      final draft = parseVoiceTranscript('кофе картой');
      expect(draft.amountMinor, isNull);
      expect(draft.transcript, 'кофе картой');
    });
  });

  group('parseVoiceTranscript currency', () {
    test('detects currency symbol', () {
      final draft = parseVoiceTranscript('\$45 groceries');
      expect(draft.amountMinor, 4500);
      expect(draft.currencyCode, 'USD');
    });

    test('leaves currency null when unknown', () {
      final draft = parseVoiceTranscript('купил за 100');
      expect(draft.amountMinor, 10000);
      expect(draft.currencyCode, isNull);
    });
  });

  group('parseVoiceTranscript matches', () {
    const tags = [
      VoiceMatchCandidate(id: 1, label: 'Groceries'),
      VoiceMatchCandidate(id: 2, label: 'Transport'),
      VoiceMatchCandidate(id: 3, label: 'Кофе'),
    ];
    const payments = [
      VoiceMatchCandidate(id: 10, label: 'Card'),
      VoiceMatchCandidate(id: 11, label: 'Cash'),
      VoiceMatchCandidate(id: 12, label: 'Карта'),
    ];

    test('matches tag and payment by word', () {
      final draft = parseVoiceTranscript(
        'groceries 40 dollars card',
        tags: tags,
        paymentMethods: payments,
      );
      expect(draft.tagId, 1);
      expect(draft.paymentMethodId, 10);
      expect(draft.currencyCode, 'USD');
      expect(draft.amountMinor, 4000);
    });

    test('matches cyrillic labels', () {
      final draft = parseVoiceTranscript(
        'кофе 350 карта',
        tags: tags,
        paymentMethods: payments,
      );
      expect(draft.tagId, 3);
      expect(draft.paymentMethodId, 12);
      expect(draft.amountMinor, 35000);
    });

    test('ignores short accidental substrings', () {
      final draft = parseVoiceTranscript(
        'car wash 20',
        tags: tags,
        paymentMethods: payments,
      );
      // "card" must not match inside "car"
      expect(draft.paymentMethodId, isNull);
      expect(draft.tagId, isNull);
    });

    test('keeps transcript in memory without implying note storage', () {
      final draft = parseVoiceTranscript(
        'something unrecognized',
        tags: tags,
        paymentMethods: payments,
      );
      expect(draft.transcript, 'something unrecognized');
      expect(draft.tagId, isNull);
      expect(draft.paymentMethodId, isNull);
      expect(draft.amountMinor, isNull);
    });
  });
}
