import 'package:ve_xem_phim/models/showtime.dart';

// ── Weekday schedule (Monday – Thursday) ────────────────────────
//
// 6 slots. Density: morning light → lunch medium → afternoon medium
//          → after-work medium-heavy → prime-time heavy → late medium.

const List<ShowtimeData> weekdayShowtimes = [
  // 09:30 · ~17 % booked (15 / 90)
  ShowtimeData(time: '09:30', bookedSeats: [
    'A3', 'A8',
    'B5', 'B9',
    'C2', 'C7',
    'D4', 'D10',
    'E6',
    'F3',
    'G8',
    'H1', 'H7',
    'I4', 'I9',
  ]),

  // 12:00 · ~26 % booked (23 / 90)
  ShowtimeData(time: '12:00', bookedSeats: [
    'A2', 'A6', 'A10',
    'B3', 'B7',
    'C1', 'C5', 'C9',
    'D2', 'D6', 'D10',
    'E3', 'E8',
    'F2', 'F7',
    'G4', 'G9',
    'H3', 'H7',
    'I1', 'I5', 'I9',
    'A4',
  ]),

  // 14:30 · ~23 % booked (21 / 90)
  ShowtimeData(time: '14:30', bookedSeats: [
    'A1', 'A5', 'A9',
    'B2', 'B6', 'B10',
    'C3', 'C7',
    'D1', 'D4', 'D8',
    'E2', 'E7',
    'F4', 'F9',
    'G3', 'G7',
    'H1', 'H6', 'H10',
    'I3',
  ]),

  // 17:00 · ~40 % booked (36 / 90)
  ShowtimeData(time: '17:00', bookedSeats: [
    'A1', 'A3', 'A5', 'A7', 'A9',
    'B2', 'B4', 'B6', 'B8',
    'C1', 'C3', 'C5', 'C7', 'C9',
    'D2', 'D4', 'D6', 'D8', 'D10',
    'E1', 'E4', 'E7', 'E10',
    'F2', 'F5', 'F8',
    'G3', 'G6', 'G9',
    'H1', 'H4', 'H7', 'H10',
    'I2', 'I5', 'I9',
  ]),

  // 19:30 · ~54 % booked (49 / 90)  ← prime time
  ShowtimeData(time: '19:30', bookedSeats: [
    'A1', 'A2', 'A4', 'A5', 'A7', 'A8', 'A10',
    'B1', 'B3', 'B4', 'B6', 'B7', 'B9',
    'C1', 'C2', 'C4', 'C5', 'C7', 'C8',
    'D1', 'D3', 'D4', 'D6', 'D8', 'D9',
    'E1', 'E3', 'E5', 'E7', 'E9',
    'F1', 'F3', 'F5', 'F8', 'F10',
    'G2', 'G4', 'G6', 'G8',
    'H1', 'H3', 'H5', 'H7', 'H9',
    'I2', 'I4', 'I6', 'I8',
  ]),

  // 22:00 · ~30 % booked (27 / 90)
  ShowtimeData(time: '22:00', bookedSeats: [
    'A2', 'A6', 'A9',
    'B1', 'B4', 'B8',
    'C3', 'C7', 'C10',
    'D2', 'D5', 'D9',
    'E4', 'E8',
    'F2', 'F6',
    'G3', 'G7', 'G10',
    'H1', 'H5', 'H9',
    'I3', 'I6', 'I10',
    'A4', 'B6',
  ]),
];

// ── Weekend schedule (Friday – Sunday) ──────────────────────────
//
// 7 slots. Busier overall; 20:15 nearly full.

const List<ShowtimeData> weekendShowtimes = [
  // 09:00 · ~16 % booked (14 / 90)
  ShowtimeData(time: '09:00', bookedSeats: [
    'A4', 'A9',
    'B2', 'B7',
    'C5', 'C10',
    'D3',
    'E4', 'E9',
    'F6',
    'G2',
    'H5', 'H9',
    'I3',
  ]),

  // 11:15 · ~29 % booked (26 / 90)
  ShowtimeData(time: '11:15', bookedSeats: [
    'A1', 'A5', 'A9',
    'B3', 'B7', 'B10',
    'C2', 'C6', 'C10',
    'D1', 'D4', 'D8',
    'E2', 'E6', 'E9',
    'F3', 'F7',
    'G1', 'G5', 'G9',
    'H2', 'H6', 'H10',
    'I4', 'I8',
    'A3',
  ]),

  // 13:30 · ~38 % booked (34 / 90)
  ShowtimeData(time: '13:30', bookedSeats: [
    'A1', 'A3', 'A5', 'A7',
    'B2', 'B4', 'B6', 'B8', 'B10',
    'C1', 'C3', 'C5', 'C7', 'C9',
    'D2', 'D4', 'D6', 'D8',
    'E1', 'E3', 'E6', 'E9',
    'F2', 'F5', 'F8',
    'G3', 'G6', 'G9',
    'H1', 'H4', 'H8',
    'I2', 'I6', 'I9',
  ]),

  // 15:45 · ~40 % booked (36 / 90)
  ShowtimeData(time: '15:45', bookedSeats: [
    'A2', 'A4', 'A6', 'A8', 'A10',
    'B1', 'B3', 'B5', 'B7', 'B9',
    'C2', 'C4', 'C6', 'C8',
    'D1', 'D3', 'D5', 'D7', 'D9',
    'E2', 'E5', 'E8',
    'F1', 'F4', 'F7', 'F10',
    'G2', 'G5', 'G8',
    'H3', 'H6', 'H9',
    'I1', 'I5', 'I8',
  ]),

  // 18:00 · ~56 % booked (50 / 90)
  ShowtimeData(time: '18:00', bookedSeats: [
    'A1', 'A2', 'A4', 'A5', 'A7', 'A8',
    'B1', 'B2', 'B4', 'B5', 'B7', 'B8', 'B10',
    'C1', 'C2', 'C4', 'C5', 'C7', 'C8', 'C10',
    'D1', 'D3', 'D5', 'D7', 'D9',
    'E1', 'E2', 'E4', 'E6', 'E8', 'E10',
    'F1', 'F3', 'F5', 'F7', 'F9',
    'G2', 'G4', 'G6', 'G8', 'G10',
    'H1', 'H3', 'H5', 'H7',
    'I1', 'I3', 'I5', 'I7', 'I9',
  ]),

  // 20:15 · ~68 % booked (61 / 90)  ← nearly full
  ShowtimeData(time: '20:15', bookedSeats: [
    'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8',
    'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9',
    'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9',
    'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8',
    'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8',
    'F1', 'F2', 'F4', 'F5', 'F7', 'F8',
    'G1', 'G3', 'G5', 'G7', 'G9',
    'H1', 'H3', 'H5', 'H7', 'H9',
    'I1', 'I3', 'I5',
  ]),

  // 22:30 · ~32 % booked (29 / 90)
  ShowtimeData(time: '22:30', bookedSeats: [
    'A3', 'A5', 'A7',
    'B2', 'B5', 'B7', 'B9',
    'C1', 'C4', 'C6', 'C8',
    'D3', 'D5', 'D7', 'D10',
    'E2', 'E6', 'E9',
    'F3', 'F8',
    'G1', 'G5', 'G9',
    'H2', 'H6', 'H10',
    'I3', 'I7', 'I10',
  ]),
];

// ── Helper ───────────────────────────────────────────────────────

/// Returns the showtime schedule for the given date.
/// Fri–Sun → weekend schedule; Mon–Thu → weekday schedule.
List<ShowtimeData> showtimesFor(DateTime date) {
  return date.weekday >= DateTime.friday ? weekendShowtimes : weekdayShowtimes;
}
