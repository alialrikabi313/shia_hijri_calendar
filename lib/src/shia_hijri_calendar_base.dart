import 'anchor_store.dart';
import 'hijri_conversion.dart';
import 'hijri_date.dart';
import 'hijri_date_source.dart';
import 'islamic_occasion.dart';
import 'month_start.dart';
import 'official_anchors.dart';
import 'shia_hijri_snapshot.dart';
import 'shia_occasions.dart';
import 'sistani_source.dart';
import 'tabular_islamic.dart';

/// High-level entry point for the official Shia (Sistani office) Hijri date.
///
/// Strategy — "scrape only at the month edges, count locally in between":
/// a Hijri month is always 29 or 30 days, so once we know the official start of
/// a month, every day inside it is exact arithmetic with **no network**. Fresh
/// fetches happen only when a month boundary is in play (or on [refresh] /
/// `forceRefresh`). Verified month starts are seeded from [officialMonthStarts]
/// and learned from every successful fetch.
///
/// ```dart
/// final calendar = ShiaHijriCalendar();
/// final today = await calendar.today();
/// print(today.formatArabic()); // ١ المحرم ١٤٤٨هـ
///
/// // Bidirectional conversion (exact where verified, else tabular estimate):
/// final c = calendar.gregorianToHijri(DateTime(2026, 6, 20));
/// print('${c.hijri.formatEnglish()} — ${c.isVerified ? "verified" : "estimate"}');
/// ```
class ShiaHijriCalendar {
  ShiaHijriCalendar({
    HijriDateSource? source,
    AnchorStore? store,
    DateTime Function()? clock,
    Iterable<MonthStart>? seed,
    List<IslamicOccasion>? occasions,
  }) : _source = source ?? SistaniHijriSource(),
       _store = store ?? MemoryAnchorStore(),
       _clock = clock ?? DateTime.now,
       _table = MonthStartTable(seed ?? officialMonthStarts()),
       _occasions = occasions ?? shiaOccasions();

  final HijriDateSource _source;
  final AnchorStore _store;
  final DateTime Function() _clock;
  final MonthStartTable _table;
  final List<IslamicOccasion> _occasions;

  ShiaHijriSnapshot? _cached;
  bool _loaded = false;

  /// The last snapshot held in memory (does not read persistent storage).
  ShiaHijriSnapshot? get lastSnapshot => _cached;

  /// All verified Hijri month starts currently known (seed + learned).
  List<MonthStart> get knownMonthStarts => _table.all;

  /// Loads the persisted snapshot (if any) into memory and the conversion
  /// table. Safe to call repeatedly; only the first call touches the store.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final stored = await _store.read();
    if (stored != null) _ingest(stored);
  }

  /// Returns today's official Shia Hijri date.
  ///
  /// Answers from verified data when the day is unambiguous; otherwise fetches
  /// a fresh value from sistani.org. Set [forceRefresh] to always fetch.
  ///
  /// If the network is unavailable but cached/seed data can resolve the day
  /// (exactly, or a best-effort near a month end), that is returned instead of
  /// throwing. With nothing to fall back on, the source error propagates.
  Future<HijriDate> today({bool forceRefresh = false}) async {
    await load();
    final todayDate = _dateOnly(_clock());

    if (!forceRefresh) {
      final exact = _table.gregorianToHijri(todayDate);
      if (exact != null) return exact;
    }

    try {
      final snapshot = await _source.fetch();
      _ingest(snapshot);
      await _store.write(snapshot);
      return _table.gregorianToHijri(todayDate) ?? snapshot.hijri;
    } on ShiaHijriSourceException {
      final exact = _table.gregorianToHijri(todayDate);
      if (exact != null) return exact;
      final approx = _bestEffortLocal(_cached, todayDate);
      if (approx != null) return approx;
      rethrow;
    }
  }

  /// Forces a fetch from the source and persists the result.
  Future<ShiaHijriSnapshot> refresh() async {
    final snapshot = await _source.fetch();
    _ingest(snapshot);
    await _store.write(snapshot);
    return snapshot;
  }

  /// Converts a Gregorian [date] to Shia Hijri.
  ///
  /// Returns a [HijriConversion] flagged [ConversionSource.verified] when a
  /// known month boundary covers the date, or [ConversionSource.estimated]
  /// (tabular approximation, possibly off by a day) otherwise. Synchronous: it
  /// uses whatever data is already loaded — call [load]/[today]/[refresh] to
  /// enrich it first.
  HijriConversion gregorianToHijri(DateTime date) {
    final target = _dateOnly(date);
    final exact = _table.gregorianToHijri(target);
    if (exact != null) {
      return HijriConversion(exact, ConversionSource.verified);
    }
    return HijriConversion(
      TabularIslamicCalendar.fromGregorian(target),
      ConversionSource.estimated,
    );
  }

  /// Converts a Shia Hijri [hijri] date to Gregorian, verified where possible.
  GregorianConversion hijriToGregorian(HijriDate hijri) {
    final exact = _table.hijriToGregorian(hijri);
    if (exact != null) {
      return GregorianConversion(exact, ConversionSource.verified);
    }
    return GregorianConversion(
      TabularIslamicCalendar.toGregorian(hijri),
      ConversionSource.estimated,
    );
  }

  /// All known religious occasions (the default Shia set, or the custom list
  /// passed to the constructor).
  List<IslamicOccasion> get occasions => List.unmodifiable(_occasions);

  /// Religious occasions that fall on [date] (usually zero or one).
  List<IslamicOccasion> occasionsOn(HijriDate date) =>
      _occasions.where((o) => o.matches(date)).toList(growable: false);

  /// All occasions in a Hijri [month] (1..12), sorted by day.
  List<IslamicOccasion> occasionsInMonth(int month) =>
      (_occasions.where((o) => o.month == month).toList()
            ..sort((a, b) => a.day.compareTo(b.day)))
          .toList(growable: false);

  /// Whether [date] is commonly an official holiday.
  bool isHoliday(HijriDate date) => occasionsOn(date).any((o) => o.isHoliday);

  /// Convenience: today's date together with its occasions.
  Future<List<IslamicOccasion>> occasionsToday({
    bool forceRefresh = false,
  }) async => occasionsOn(await today(forceRefresh: forceRefresh));

  /// Records a snapshot in memory and folds its implied month start into the
  /// conversion table.
  void _ingest(ShiaHijriSnapshot snapshot) {
    _cached = snapshot;
    _table.add(MonthStart.fromSnapshot(snapshot));
  }

  /// Offline fallback for [today]: optimistic local arithmetic that tolerates
  /// day 30 (may be off by one until the next successful fetch).
  HijriDate? _bestEffortLocal(ShiaHijriSnapshot? snapshot, DateTime date) {
    if (snapshot == null) return null;
    final diff = date.difference(_dateOnly(snapshot.gregorianDate)).inDays;
    final day = snapshot.hijri.day + diff;
    if (day >= 1 && day <= 30) return snapshot.hijri.copyWith(day: day);
    return null;
  }

  /// Releases the HTTP client owned by the default source.
  void close() => _source.close();
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
