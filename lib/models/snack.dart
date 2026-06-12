class SnackItem {
  final String id;
  final String name;
  final String description;
  final int price;

  const SnackItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}

class SnackCategory {
  final String name;
  final List<SnackItem> items;

  const SnackCategory({required this.name, required this.items});
}
