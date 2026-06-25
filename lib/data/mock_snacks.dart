import 'package:ve_xem_phim/models/snack.dart';

const List<SnackCategory> snackCategories = [
  SnackCategory(name: 'Bắp rang', items: [
    SnackItem(
      id: 1,
      name: 'Bắp rang bơ cỡ nhỏ',
      description: 'Bơ thơm, giòn rụm · phù hợp 1 người',
      price: 45000,
    ),
    SnackItem(
      id: 2,
      name: 'Bắp rang bơ cỡ lớn',
      description: 'Bơ thơm, giòn rụm · phù hợp 2 người',
      price: 65000,
    ),
    SnackItem(
      id: 3,
      name: 'Bắp phô mai cỡ nhỏ',
      description: 'Phô mai béo, mặn vừa · phù hợp 1 người',
      price: 50000,
    ),
    SnackItem(
      id: 4,
      name: 'Bắp phô mai cỡ lớn',
      description: 'Phô mai béo, mặn vừa · phù hợp 2 người',
      price: 70000,
    ),
  ]),

  SnackCategory(name: 'Combo tiết kiệm', items: [
    SnackItem(
      id: 5,
      name: 'Combo 1',
      description: 'Bắp rang bơ nhỏ + 1 Pepsi (M)',
      price: 75000,
    ),
    SnackItem(
      id: 6,
      name: 'Combo 2',
      description: 'Bắp rang bơ lớn + 2 Pepsi (M)',
      price: 110000,
    ),
    SnackItem(
      id: 13,
      name: 'Combo 3',
      description: '2 Bắp phô mai nhỏ + 2 Pepsi (L)',
      price: 135000,
    ),
  ]),

  SnackCategory(name: 'Nước uống', items: [
    SnackItem(
      id: 7,
      name: 'Pepsi cỡ vừa (M)',
      description: 'Nước ngọt có gas · 450ml',
      price: 30000,
    ),
    SnackItem(
      id: 8,
      name: 'Pepsi cỡ lớn (L)',
      description: 'Nước ngọt có gas · 600ml',
      price: 40000,
    ),
    SnackItem(
      id: 9,
      name: '7UP cỡ vừa (M)',
      description: 'Nước chanh có gas · 450ml',
      price: 30000,
    ),
    SnackItem(
      id: 10,
      name: 'Nước suối',
      description: 'Nước khoáng đóng chai · 500ml',
      price: 20000,
    ),
  ]),

  SnackCategory(name: 'Đồ ăn vặt', items: [
    SnackItem(
      id: 11,
      name: 'Hotdog',
      description: 'Xúc xích nướng kèm tương ớt',
      price: 50000,
    ),
    SnackItem(
      id: 14,
      name: 'Gà rán (2 miếng)',
      description: 'Giòn tan, thơm ngon',
      price: 65000,
    ),
    SnackItem(
      id: 12,
      name: 'Khoai tây chiên',
      description: 'Vừa chiên, giòn rụm · size M',
      price: 45000,
    ),
    SnackItem(
      id: 15,
      name: 'Nachos phô mai',
      description: 'Bánh ngô giòn kèm sốt phô mai',
      price: 55000,
    ),
  ]),
];
