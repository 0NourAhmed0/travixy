class SearchQuery {
  final String queryText;
  //filters is typed as Map<String, dynamic> since filters can vary
  final Map<String, dynamic> filters;
  final int resultsCount;
  final DateTime timestamp;

  SearchQuery({
    required this.queryText,
    required this.filters,
    required this.resultsCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'queryText': queryText,
      'filters': filters,
      'resultsCount': resultsCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      queryText: json['queryText'] ?? '',
      filters: json['filters'] ?? {},
      resultsCount: json['resultsCount'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}