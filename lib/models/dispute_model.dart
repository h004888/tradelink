class Dispute {
  final String id;
  final String transactionId;
  final String raisedBy;
  final String reason;
  final String description;
  final bool priority;
  final String status; // 'open' | 'resolved' | 'closed'
  final String? resolution;
  final String? decision; // 'refund' | 'release' | 'reject'
  final List<String> attachments;
  final String? chatLogSnapshot;
  final DateTime createdAt;

  const Dispute({
    required this.id,
    required this.transactionId,
    required this.raisedBy,
    required this.reason,
    required this.description,
    required this.priority,
    required this.status,
    this.resolution,
    this.decision,
    this.attachments = const [],
    this.chatLogSnapshot,
    required this.createdAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> j) {
    return Dispute(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      transactionId: (j['transactionId'] is Map ? j['transactionId']['_id'] : j['transactionId'])?.toString() ?? '',
      raisedBy: (j['raisedBy'] is Map ? j['raisedBy']['_id'] : j['raisedBy'])?.toString() ?? '',
      reason: j['reason']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      priority: j['priority'] == true,
      status: j['status']?.toString() ?? 'open',
      resolution: j['resolution'] as String?,
      decision: j['decision'] as String?,
      attachments: ((j['attachments'] as List?) ?? []).map((e) => e.toString()).toList(),
      chatLogSnapshot: j['chatLogSnapshot'] as String?,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
