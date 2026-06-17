/// Official Shia (Sistani office) Hijri calendar for Dart & Flutter.
///
/// Fetches the authoritative Hijri date from sistani.org (which follows actual
/// moon sighting — رؤية الهلال — and can differ by a day from Umm al-Qura),
/// caches it, and computes the day-of-month locally between fetches.
library;

export 'src/anchor_store.dart';
export 'src/arabic_digits.dart';
export 'src/hijri_conversion.dart';
export 'src/hijri_date.dart';
export 'src/hijri_date_source.dart';
export 'src/hijri_month.dart';
export 'src/month_start.dart';
export 'src/official_anchors.dart';
export 'src/shia_hijri_calendar_base.dart';
export 'src/shia_hijri_snapshot.dart';
export 'src/sistani_source.dart';
export 'src/tabular_islamic.dart';
