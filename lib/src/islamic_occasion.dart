import 'hijri_date.dart';

/// Category of a religious occasion, useful for theming (e.g. mourning = black,
/// eid = green).
enum OccasionType {
  /// A feast — Eid al-Fitr, Eid al-Adha, Eid al-Ghadir.
  eid,

  /// Birth (mawlid) of the Prophet, an Imam, or a holy figure.
  birth,

  /// Martyrdom or passing of a holy figure.
  martyrdom,

  /// A day of mourning that is not itself a martyrdom (e.g. Tasua, Arbaeen).
  mourning,

  /// Other religious significance (Mab'ath, Arafah, Laylat al-Qadr ...).
  religious,
}

/// A Shia religious occasion pinned to a fixed Hijri month and day.
class IslamicOccasion {
  const IslamicOccasion({
    required this.month,
    required this.day,
    required this.arabicName,
    required this.englishName,
    required this.type,
    this.isHoliday = false,
  });

  /// 1-based Hijri month (1..12).
  final int month;

  /// Day of the Hijri month (1..30).
  final int day;

  /// Arabic name, e.g. `عاشوراء - استشهاد الإمام الحسين (ع)`.
  final String arabicName;

  /// English name, e.g. `Ashura — Martyrdom of Imam Husayn`.
  final String englishName;

  final OccasionType type;

  /// Whether this is commonly an official/public holiday in Shia regions.
  final bool isHoliday;

  /// True when this occasion falls on [date].
  bool matches(HijriDate date) => date.monthNumber == month && date.day == day;

  @override
  String toString() => '$englishName ($day/$month)';
}
