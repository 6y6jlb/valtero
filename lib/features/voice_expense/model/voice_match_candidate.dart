/// Label already localized for the UI language — used for fuzzy matching
/// against the speech transcript without BuildContext in the parser.
class VoiceMatchCandidate {
  final int id;
  final String label;

  const VoiceMatchCandidate({required this.id, required this.label});
}
