import 'hijri_date.dart';

/// A verified anchor linking a civil (Gregorian) day to the official Shia
/// Hijri date announced by the Sistani office, plus the metadata needed to
/// reason about freshness.
///
/// One snapshot is enough to compute any day that falls safely inside the same
/// Hijri month locally (no network), because Hijri months are always 29 or 30
/// days. A fresh fetch is only needed once a month boundary is in play.
class ShiaHijriSnapshot {
  ShiaHijriSnapshot({
    required this.hijri,
    required this.gregorianDate,
    required this.fetchedAt,
    this.serverTime,
  });

  /// The official Hijri date for [gregorianDate].
  final HijriDate hijri;

  /// The civil date (date-only, no time) that [hijri] corresponds to.
  final DateTime gregorianDate;

  /// When this snapshot was retrieved from the source.
  final DateTime fetchedAt;

  /// Server clock reported by sistani.org (`uts`), when available.
  final DateTime? serverTime;

  Map<String, dynamic> toJson() => {
    'hijri': hijri.toJson(),
    'gregorianDate': _dateOnly(gregorianDate).toIso8601String(),
    'fetchedAt': fetchedAt.toIso8601String(),
    'serverTime': serverTime?.toIso8601String(),
  };

  factory ShiaHijriSnapshot.fromJson(Map<String, dynamic> json) =>
      ShiaHijriSnapshot(
        hijri: HijriDate.fromJson(
          (json['hijri'] as Map).cast<String, dynamic>(),
        ),
        gregorianDate: DateTime.parse(json['gregorianDate'] as String),
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        serverTime: json['serverTime'] == null
            ? null
            : DateTime.parse(json['serverTime'] as String),
      );

  @override
  String toString() =>
      'ShiaHijriSnapshot(${hijri.formatEnglish()} == '
      '${_dateOnly(gregorianDate).toIso8601String().split('T').first})';
}

/// Strips the time component, keeping a local date-only `DateTime`.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
