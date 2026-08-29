/// Outcome of an integration connection probe. Messages must be safe for UI
/// (never include raw credentials or full HTTP bodies).
class IntegrationTestResult {
  final bool success;
  final String messageKey;

  const IntegrationTestResult({
    required this.success,
    required this.messageKey,
  });

  factory IntegrationTestResult.ok([String messageKey = 'connectionOk']) {
    return IntegrationTestResult(success: true, messageKey: messageKey);
  }

  factory IntegrationTestResult.fail([String messageKey = 'connectionFailed']) {
    return IntegrationTestResult(success: false, messageKey: messageKey);
  }
}
