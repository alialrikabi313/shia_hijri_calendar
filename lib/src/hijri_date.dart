import 'arabic_digits.dart';
import 'hijri_month.dart';

/// An immutable day on the Islamic (Hijri) lunar calendar as observed by the
/// office of Grand Ayatollah al-Sistani.
///
/// A [HijriDate] is a pure value: it carries no Gregorian mapping by itself.
/// The mapping to a civil date comes from a verified anchor fetched from
/// sistani.org (see `ShiaHijriCalendar`).
class HijriDate implements Comparable<HijriDate> {
  /// Creates a Hijri date from a 1-based month [month] (1..12).
  HijriDate(this.year, int month, this.day)
    : month = HijriMonth.fromNumber(month) {
    _validate();
  }

  /// Creates a Hijri date from a [HijriMonth] value.
  HijriDate.of(this.year, this.month, this.day) {
    _validate();
  }

  /// The Hijri year, e.g. `1448`.
  final int year;

  /// The month of the year.
  final HijriMonth month;

  /// Day of the month, `1..30`.
  final int day;

  /// 1-based month number (1..12).
  int get monthNumber => month.number;

  void _validate() {
    if (day < 1 || day > 30) {
      throw RangeError.range(day, 1, 30, 'day', 'Hijri day of month');
    }
    if (year < 1) {
      throw RangeError.range(year, 1, null, 'year', 'Hijri year');
    }
  }

  /// Returns a copy with the given fields replaced.
  HijriDate copyWith({int? year, HijriMonth? month, int? day}) =>
      HijriDate.of(year ?? this.year, month ?? this.month, day ?? this.day);

  /// Formats in English, e.g. `1 Muharram 1448 AH`.
  String formatEnglish() => '$day ${month.englishName} $year AH';

  /// Formats in Arabic with Arabic-Indic digits, e.g. `١ المحرم ١٤٤٨هـ`.
  String formatArabic() =>
      '${asciiToArabicDigits(day)} ${month.arabicName} '
      '${asciiToArabicDigits(year)}هـ';

  /// ISO-like sortable form `YYYY-MM-DD`, e.g. `1448-01-01`.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${monthNumber.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(HijriDate other) {
    final byYear = year.compareTo(other.year);
    if (byYear != 0) return byYear;
    final byMonth = monthNumber.compareTo(other.monthNumber);
    if (byMonth != 0) return byMonth;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'HijriDate(${toIso()})';

  /// JSON round-tripping, used by anchor stores.
  Map<String, dynamic> toJson() => {
    'year': year,
    'month': monthNumber,
    'day': day,
  };

  /// Restores a [HijriDate] from [toJson] output.
  factory HijriDate.fromJson(Map<String, dynamic> json) => HijriDate(
    (json['year'] as num).toInt(),
    (json['month'] as num).toInt(),
    (json['day'] as num).toInt(),
  );
}
