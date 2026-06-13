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

class MockTicket {
  final String movieTitle;
  final String date;
  final String time;
  final List<String> seats;
  final int total;
  final bool upcoming;
  final Color color;

  const MockTicket({
    required this.movieTitle,
    required this.date,
    required this.time,
    required this.seats,
    required this.total,
    required this.upcoming,
    required this.color,
  });
}

// ── Mock ticket data ─────────────────────────────────────────────

const mockTickets = <MockTicket>[
  MockTicket(
    movieTitle: 'Mission: Impossible 8',
    date: '12/06/2026',
    time: '09:00',
    seats: ['D7', 'D8'],
    total: 150000,
    upcoming: true,
    color: Color(0xFF1565C0),
  ),
  MockTicket(
    movieTitle: 'Inside Out 3',
    date: '25/05/2026',
    time: '14:30',
    seats: ['E4', 'E5', 'E6'],
    total: 360000,
    upcoming: false,
    color: Color(0xFF2E7D32),
  ),
  MockTicket(
    movieTitle: 'Avengers: Doomsday',
    date: '10/05/2026',
    time: '20:15',
    seats: ['F3'],
    total: 120000,
    upcoming: false,
    color: Color(0xFF6A1B9A),
  ),
];
