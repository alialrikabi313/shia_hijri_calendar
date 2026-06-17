import 'month_start.dart';

/// Verified Hijri month starts published by the Sistani office, used to seed
/// the conversion table so exact answers are available out of the box.
///
/// Each entry is the civil date of **day 1** of that Hijri month, confirmed
/// from sistani.org / official announcements. Add more entries here as the
/// office announces them (or let the package learn them at runtime by calling
/// [ShiaHijriCalendar.today] / [ShiaHijriCalendar.refresh]).
List<MonthStart> officialMonthStarts() => [
  // 1 Muharram 1448 — confirmed Wed 17 Jun 2026 (Sistani sighting).
  MonthStart(year: 1448, month: 1, gregorian: DateTime(2026, 6, 17)),
];
