/// Structured draft produced from a speech transcript.
///
/// Null fields mean "leave form default / unchanged". [transcript] is kept
/// in memory for the capture-sheet preview only and is **not** written to the
/// expense note or any store.
class VoiceExpenseDraft {
  final int? amountMinor;
  final String? currencyCode;
  final int? tagId;
  final int? paymentMethodId;
  final String transcript;

  const VoiceExpenseDraft({
    this.amountMinor,
    this.currencyCode,
    this.tagId,
    this.paymentMethodId,
    required this.transcript,
  });

  bool get hasAmount => amountMinor != null && amountMinor! > 0;
}
