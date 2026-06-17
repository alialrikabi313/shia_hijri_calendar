import 'hijri_date.dart';

/// Arithmetic ("tabular"/Kuwaiti) Islamic calendar conversion.
///
/// This is a deterministic, offline approximation: it assumes a fixed 30-year
/// leap cycle rather than real moon sighting, so it can be off by a day or two
/// from the official Sistani date. It is used only as a **fallback** for dates
/// that no verified anchor covers. Round-trips
/// (`toGregorian(fromGregorian(x)) == x`) are exact.
abstract final class TabularIslamicCalendar {
  // Julian Day Number of the civil Islamic epoch (Fri 16 Jul 622 CE).
  static const int _islamicEpoch = 1948440;

  /// Julian Day Number for a proleptic-Gregorian date (all-integer formula).
  static int gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Inverse of [gregorianToJdn]; returns a date-only [DateTime].
  static DateTime jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }

  static int _hijriToJdn(int year, int month, int day) =>
      (11 * year + 3) ~/ 30 +
      354 * year +
      30 * month -
      (month - 1) ~/ 2 +
      day +
      _islamicEpoch -
      385;

  /// Converts a Gregorian [date] to an estimated [HijriDate].
  static HijriDate fromGregorian(DateTime date) {
    final jd = gregorianToJdn(date.year, date.month, date.day);
    var l = jd - _islamicEpoch + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j =
        ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l =
        l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }

  /// Converts a [HijriDate] to an estimated date-only Gregorian [DateTime].
  static DateTime toGregorian(HijriDate hijri) =>
      jdnToGregorian(_hijriToJdn(hijri.year, hijri.monthNumber, hijri.day));
}
