class BatchModelClass {
  final String id;
  final String name;
  final String quantity;
  final double price;
  final String manufactureDate;
  final String expiryDate;
  final String note;

  BatchModelClass({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.manufactureDate,
    required this.expiryDate,
    required this.note,
  });

  // 1. Convert Batch object into a Map structure for SQFlite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'manufactureDate': manufactureDate,
      'expiryDate': expiryDate,
      'note': note,
    };
  }

  // 2. Reconstruct a Batch object out of a database Map row fetch request
  factory BatchModelClass.fromMap(Map<String, dynamic> map) {
    return BatchModelClass(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      quantity: map['quantity']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      manufactureDate: map['manufactureDate']?.toString() ?? '',
      expiryDate: map['expiryDate']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
    );
  }
}