class SnackItem {
  final int id;
  final String name;
  final int price;
  final String type;
  final String status;

  const SnackItem({
    required this.id,
    required this.name,
    required this.price,
    this.type = 'FOOD',
    this.status = 'AVAILABLE',
  });

  factory SnackItem.fromJson(Map<String, dynamic> json) {
    return SnackItem(
      id: (json['snack_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: _priceToInt(json['price']),
      type: json['type']?.toString() ?? 'FOOD',
      status: json['status']?.toString() ?? 'AVAILABLE',
    );
  }

  static int _priceToInt(dynamic value) {
    if (value is num) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }
}

class SnackCategory {
  final String name;
  final List<SnackItem> items;

  const SnackCategory({required this.name, required this.items});
}
