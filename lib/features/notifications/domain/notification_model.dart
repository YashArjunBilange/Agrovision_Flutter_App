class FarmAlertModel {
  final int id;
  final String titleEn;
  final String titleMr;
  final String messageEn;
  final String messageMr;
  final String type; // 'weather', 'advisory', 'task', 'warning'
  final String severity; // 'high', 'medium', 'low'
  final String? actionRoute;
  final bool isRead;
  final DateTime createdAt;

  const FarmAlertModel({
    required this.id,
    required this.titleEn,
    required this.titleMr,
    required this.messageEn,
    required this.messageMr,
    required this.type,
    required this.severity,
    this.actionRoute,
    this.isRead = false,
    required this.createdAt,
  });

  factory FarmAlertModel.fromJson(Map<String, dynamic> json) {
    return FarmAlertModel(
      id: json['id'] as int,
      titleEn: json['title_en'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      messageEn: json['message_en'] as String? ?? '',
      messageMr: json['message_mr'] as String? ?? '',
      type: json['type'] as String? ?? 'advisory',
      severity: json['severity'] as String? ?? 'low',
      actionRoute: json['action_route'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AlertListModel {
  final List<FarmAlertModel> alerts;
  final int unreadCount;

  const AlertListModel({
    required this.alerts,
    required this.unreadCount,
  });

  factory AlertListModel.fromJson(Map<String, dynamic> json) {
    return AlertListModel(
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => FarmAlertModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
