class AnswerSource {
  final double? score;
  final String type;
  final String fileName;
  final String machineName;

  const AnswerSource({
    this.score,
    required this.type,
    required this.fileName,
    required this.machineName,
  });

  factory AnswerSource.fromJson(Map<String, dynamic> json) {
    return AnswerSource(
      score: (json['score'] as num?)?.toDouble(),
      type: json['type']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      machineName: json['machineName']?.toString() ?? '',
    );
  }
}