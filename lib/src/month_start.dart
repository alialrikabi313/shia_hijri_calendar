import 'hijri_date.dart';
import 'shia_hijri_snapshot.dart';

/// The verified first civil day of a given Hijri month, as published by the
/// Sistani office.
class MonthStart implements Comparable<MonthStart> {
  MonthStart({
    required this.year,
    required this.month,
    required DateTime gregorian,
  }) : gregorian = DateTime(gregorian.year, gregorian.month, gregorian.day);

  /// Hijri year of this month.
  final int year;

  /// 1-based Hijri month number (1..12).
  final int month;

  /// Civil date of day 1 of this Hijri month (date-only).
  final DateTime gregorian;

  /// Derives the month start implied by a verified [snapshot]: the Gregorian
  /// date minus `(day - 1)` days.
  factory MonthStart.fromSnapshot(ShiaHijriSnapshot s) => MonthStart(
    year: s.hijri.year,
    month: s.hijri.monthNumber,
    gregorian: s.gregorianDate.subtract(Duration(days: s.hijri.day - 1)),
  );

  int get _key => year * 12 + (month - 1);

  @override
  int compareTo(MonthStart other) => _key.compareTo(other._key);

  @override
  bool operator ==(Object other) =>
      other is MonthStart && other.year == year && other.month == month;

  @override
  int get hashCode => _key;

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'gregorian': gregorian.toIso8601String(),
  };

  factory MonthStart.fromJson(Map<String, dynamic> json) => MonthStart(
    year: (json['year'] as num).toInt(),
    month: (json['month'] as num).toInt(),
    gregorian: DateTime.parse(json['gregorian'] as String),
  );

  @override
  String toString() =>
      'MonthStart($year-${month.toString().padLeft(2, '0')} @ '
      '${gregorian.toIso8601String().split('T').first})';
}

/// A growing, sorted set of verified [MonthStart]s used for **exact**
/// conversion. Anything it cannot cover is left to the tabular fallback.
class MonthStartTable {
  MonthStartTable([Iterable<MonthStart> initial = const []]) {
    for (final m in initial) {
      add(m);
    }
  }

  // Keyed by year*12+month for de-duplication, kept sorted on read.
  final Map<int, MonthStart> _byMonth = {};

  /// All known month starts, sorted ascending.
  List<MonthStart> get all {
    final list = _byMonth.values.toList()..sort();
    return List.unmodifiable(list);
  }

  bool get isEmpty => _byMonth.isEmpty;

  /// Adds (or replaces) a verified month start.
  void add(MonthStart start) =>
      _byMonth[start.year * 12 + (start.month - 1)] = start;

  MonthStart? _get(int year, int month) => _byMonth[year * 12 + (month - 1)];

  MonthStart? _next(MonthStart m) {
    final nextYear = m.month == 12 ? m.year + 1 : m.year;
    final nextMonth = m.month == 12 ? 1 : m.month + 1;
    return _get(nextYear, nextMonth);
  }

  /// Exact Hijri date for [date] if a verified month covers it, else `null`.
  ///
  /// Certainty rule: a Hijri month is always ≥ 29 days, so days 1..29 of the
  /// latest known month start are always safe. Day 30 needs the next month's
  /// start to confirm the month had 30 days.
  HijriDate? gregorianToHijri(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    MonthStart? best;
    for (final m in all) {
      if (!m.gregorian.isAfter(target)) {
        best = m;
      } else {
        break;
      }
    }
    if (best == null) return null;
    final day = target.difference(best.gregorian).inDays + 1;
    if (day < 1) return null;
    if (day <= 29) return HijriDate(best.year, best.month, day);
    final next = _next(best);
    if (next == null) return null; // day 30 unconfirmed
    if (target.isBefore(next.gregorian)) {
      return HijriDate(best.year, best.month, day); // confirmed 30-day month
    }
    return null; // falls into the next (or a later) month we don't bound here
  }

  /// Exact Gregorian date for [hijri] if its month start is known, else `null`.
  DateTime? hijriToGregorian(HijriDate hijri) {
    final start = _get(hijri.year, hijri.monthNumber);
    if (start == null) return null;
    return start.gregorian.add(Duration(days: hijri.day - 1));
  }

  List<Map<String, dynamic>> toJson() =>
      all.map((m) => m.toJson()).toList(growable: false);

  factory MonthStartTable.fromJson(List<dynamic> json) => MonthStartTable(
    json.map((e) => MonthStart.fromJson((e as Map).cast<String, dynamic>())),
  );
}
