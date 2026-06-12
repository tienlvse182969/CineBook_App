import 'package:ve_xem_phim/models/snack.dart';

const List<SnackCategory> snackCategories = [
  SnackCategory(name: 'Bắp rang', items: [
    SnackItem(
      id: 'popcorn_butter_s',
      name: 'Bắp rang bơ cỡ nhỏ',
      description: 'Bơ thơm, giòn rụm · phù hợp 1 người',
      price: 45000,
    ),
    SnackItem(
      id: 'popcorn_butter_l',
      name: 'Bắp rang bơ cỡ lớn',
      description: 'Bơ thơm, giòn rụm · phù hợp 2 người',
      price: 65000,
    ),
    SnackItem(
      id: 'popcorn_cheese_s',
      name: 'Bắp phô mai cỡ nhỏ',
      description: 'Phô mai béo, mặn vừa · phù hợp 1 người',
      price: 50000,
    ),
    SnackItem(
      id: 'popcorn_cheese_l',
      name: 'Bắp phô mai cỡ lớn',
      description: 'Phô mai béo, mặn vừa · phù hợp 2 người',
      price: 70000,
    ),
  ]),

  SnackCategory(name: 'Combo tiết kiệm', items: [
    SnackItem(
      id: 'combo_1',
      name: 'Combo 1',
      description: 'Bắp rang bơ nhỏ + 1 Pepsi (M)',
      price: 75000,
    ),
    SnackItem(
      id: 'combo_2',
      name: 'Combo 2',
      description: 'Bắp rang bơ lớn + 2 Pepsi (M)',
      price: 110000,
    ),
    SnackItem(
      id: 'combo_3',
      name: 'Combo 3',
      description: '2 Bắp phô mai nhỏ + 2 Pepsi (L)',
      price: 135000,
    ),
  ]),

  SnackCategory(name: 'Nước uống', items: [
    SnackItem(
      id: 'pepsi_m',
      name: 'Pepsi cỡ vừa (M)',
      description: 'Nước ngọt có gas · 450ml',
      price: 30000,
    ),
    SnackItem(
      id: 'pepsi_l',
      name: 'Pepsi cỡ lớn (L)',
      description: 'Nước ngọt có gas · 600ml',
      price: 40000,
    ),
    SnackItem(
      id: '7up_m',
      name: '7UP cỡ vừa (M)',
      description: 'Nước chanh có gas · 450ml',
      price: 30000,
    ),
    SnackItem(
      id: 'water',
      name: 'Nước suối',
      description: 'Nước khoáng đóng chai · 500ml',
      price: 20000,
    ),
  ]),

  SnackCategory(name: 'Đồ ăn vặt', items: [
    SnackItem(
      id: 'hotdog',
      name: 'Hotdog',
      description: 'Xúc xích nướng kèm tương ớt',
      price: 50000,
    ),
    SnackItem(
      id: 'fried_chicken',
      name: 'Gà rán (2 miếng)',
      description: 'Giòn tan, thơm ngon',
      price: 65000,
    ),
    SnackItem(
      id: 'fries',
      name: 'Khoai tây chiên',
      description: 'Vừa chiên, giòn rụm · size M',
      price: 45000,
    ),
    SnackItem(
      id: 'nachos',
      name: 'Nachos phô mai',
      description: 'Bánh ngô giòn kèm sốt phô mai',
      price: 55000,
    ),
  ]),
];
