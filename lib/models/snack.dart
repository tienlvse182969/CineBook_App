class SnackItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String type;
  final String status;

  const SnackItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.type = 'FOOD',
    this.status = 'AVAILABLE',
  });

  factory SnackItem.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'FOOD';
    return SnackItem(
      id: (json['snack_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: _descriptionFor(type),
      price: _priceToInt(json['price']),
      type: type,
      status: json['status']?.toString() ?? 'AVAILABLE',
    );
  }

  static int _priceToInt(dynamic value) {
    if (value is num) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  static String _descriptionFor(String type) {
    switch (type) {
      case 'POPCORN':
        return 'Bắp rang thơm giòn';
      case 'DRINK':
        return 'Nước uống dùng kèm khi xem phim';
      case 'COMBO':
        return 'Combo tiết kiệm';
      default:
        return 'Đồ ăn nhẹ';
    }
  }
}

class SnackCategory {
  final String name;
  final List<SnackItem> items;

  const SnackCategory({required this.name, required this.items});
}
