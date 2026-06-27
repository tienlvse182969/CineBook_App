import 'package:flutter/material.dart';

// ── Mock user ────────────────────────────────────────────────────

const mockUserName    = 'Lê Văn Tiến';
const mockUserEmail   = 'tien4849@gmail.com';
const mockUserPoints  = 1250;
const mockTierPoints  = 2000;
const mockCurrentTier = 'Thành viên Bạc';
const mockNextTier    = 'Thành viên Vàng';
const mockMemberSince = 'Tháng 01, 2025';

// ── Mock ticket model ────────────────────────────────────────────

class MockSnack {
  final String name;
  final int qty;
  final int unitPrice;
  const MockSnack({required this.name, required this.qty, required this.unitPrice});
}

class MockTicket {
  final String movieTitle;
  final String date;
  final String time;
  final String hall;
  final List<String> seats;
  final int total;
  final bool upcoming;
  final Color color;
  final List<MockSnack> snacks;

  const MockTicket({
    required this.movieTitle,
    required this.date,
    required this.time,
    required this.hall,
    required this.seats,
    required this.total,
    required this.upcoming,
    required this.color,
    this.snacks = const [],
  });
}

// ── Mock ticket data ─────────────────────────────────────────────

const mockTickets = <MockTicket>[
  MockTicket(
    movieTitle: 'Mission: Impossible 8',
    date: '12/06/2026',
    time: '09:00',
    hall: 'Phòng 1 · 2D',
    seats: ['D7', 'D8'],
    total: 220000,
    upcoming: true,
    color: Color(0xFF1565C0),
    snacks: [
      MockSnack(name: 'Bắp rang bơ vừa', qty: 1, unitPrice: 45000),
      MockSnack(name: 'Pepsi lon', qty: 2, unitPrice: 25000),
    ],
  ),
  MockTicket(
    movieTitle: 'Inside Out 3',
    date: '25/05/2026',
    time: '14:30',
    hall: 'Phòng 3 · 3D',
    seats: ['E4', 'E5', 'E6'],
    total: 450000,
    upcoming: false,
    color: Color(0xFF2E7D32),
    snacks: [
      MockSnack(name: 'Combo Đôi (bắp + 2 nước)', qty: 1, unitPrice: 90000),
    ],
  ),
  MockTicket(
    movieTitle: 'Avengers: Doomsday',
    date: '10/05/2026',
    time: '20:15',
    hall: 'Phòng 5 · IMAX 3D',
    seats: ['F3'],
    total: 120000,
    upcoming: false,
    color: Color(0xFF6A1B9A),
  ),
];
