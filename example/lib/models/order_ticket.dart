class OrderTicket {
  const OrderTicket({
    required this.id,
    required this.drink,
    required this.quantity,
    required this.note,
    required this.member,
    required this.rush,
    required this.ready,
    required this.createdAt,
  });

  final int id;
  final String drink;
  final int quantity;
  final String note;
  final bool member;
  final bool rush;
  final bool ready;
  final DateTime createdAt;

  OrderTicket copyWith({
    int? id,
    String? drink,
    int? quantity,
    String? note,
    bool? member,
    bool? rush,
    bool? ready,
    DateTime? createdAt,
  }) {
    return OrderTicket(
      id: id ?? this.id,
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      member: member ?? this.member,
      rush: rush ?? this.rush,
      ready: ready ?? this.ready,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get shortLabel => '$quantity x $drink';
}
