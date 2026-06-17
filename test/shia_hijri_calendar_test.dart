import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';
import 'package:test/test.dart';

/// The exact `#home-date` block served by sistani.org root, captured
/// 2026-06-17. Used to lock the parser against the real markup.
const _sampleHomePage = '''
<!DOCTYPE html><html><body>
<div id="home-date">
<span style="margin-left:9px;">الأربعاء ١ - المحرم الحرام - ١٤٤٨هـ </span>||
<span style="margin-right:9px;"></span> (النجف الأشرف)
&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp;
Wed, 17 Jun 2026
</div>
<script>var lastHomeUpdate=(new Date).getTime(), uts=1781696659;</script>
</body></html>
''';

/// A source that returns a fixed snapshot, for testing the calendar logic
/// without any network.
class _FakeSource implements HijriDateSource {
  _FakeSource(this.snapshot);
  ShiaHijriSnapshot snapshot;
  int fetchCount = 0;

  @override
  Future<ShiaHijriSnapshot> fetch() async {
    fetchCount++;
    return snapshot;
  }

  @override
  void close() {}
}

class _FailingSource implements HijriDateSource {
  @override
  Future<ShiaHijriSnapshot> fetch() async =>
      throw ShiaHijriSourceException('offline');
  @override
  void close() {}
}

void main() {
  group('Arabic digits', () {
    test('arabic to ascii', () {
      expect(arabicToAsciiDigits('١٤٤٨'), '1448');
      expect(arabicToAsciiDigits('۱۴۴۸'), '1448'); // persian forms
    });
    test('ascii to arabic', () {
      expect(asciiToArabicDigits(1448), '١٤٤٨');
    });
  });

  group('HijriMonth.fromArabicText', () {
    test('matches decorated office names', () {
      expect(HijriMonth.fromArabicText('المحرم الحرام'), HijriMonth.muharram);
      expect(HijriMonth.fromArabicText('ربيع الأول'), HijriMonth.rabiAlAwwal);
      expect(HijriMonth.fromArabicText('ربيع الآخر'), HijriMonth.rabiAlThani);
      expect(HijriMonth.fromArabicText('جمادى الأولى'), HijriMonth.jumadaAlUla);
      expect(
        HijriMonth.fromArabicText('جمادى الآخرة'),
        HijriMonth.jumadaAlAkhira,
      );
      expect(
        HijriMonth.fromArabicText('شهر رمضان المبارك'),
        HijriMonth.ramadan,
      );
      expect(HijriMonth.fromArabicText('ذي القعدة'), HijriMonth.dhuAlQadah);
      expect(HijriMonth.fromArabicText('ذو الحجة'), HijriMonth.dhuAlHijjah);
    });
    test('returns null for nonsense', () {
      expect(HijriMonth.fromArabicText('لا يوجد'), isNull);
    });
  });

  group('HijriDate', () {
    test('validates ranges', () {
      expect(() => HijriDate(1448, 1, 31), throwsRangeError);
      expect(() => HijriDate(1448, 13, 1), throwsRangeError);
    });
    test('formats', () {
      final d = HijriDate(1448, 1, 1);
      expect(d.formatEnglish(), '1 Muharram 1448 AH');
      expect(d.formatArabic(), '١ المحرم ١٤٤٨هـ');
      expect(d.toIso(), '1448-01-01');
    });
    test('json round trip', () {
      final d = HijriDate(1448, 9, 15);
      expect(HijriDate.fromJson(d.toJson()), d);
    });
  });

  group('SistaniHijriSource.parse', () {
    final source = SistaniHijriSource(clock: () => DateTime(2026, 6, 17, 12));
    final snapshot = source.parse(_sampleHomePage);

    test('reads the official Hijri date', () {
      expect(snapshot.hijri, HijriDate(1448, 1, 1));
    });
    test('reads the Gregorian anchor', () {
      expect(snapshot.gregorianDate, DateTime(2026, 6, 17));
    });
    test('reads the server time from uts', () {
      expect(
        snapshot.serverTime,
        DateTime.fromMillisecondsSinceEpoch(1781696659 * 1000, isUtc: true),
      );
    });
    test('throws when block is missing', () {
      expect(
        () => source.parse('<html></html>'),
        throwsA(isA<ShiaHijriSourceException>()),
      );
    });
  });

  group('ShiaHijriCalendar', () {
    ShiaHijriSnapshot anchor(int day, DateTime gregorian) => ShiaHijriSnapshot(
      hijri: HijriDate(1448, 1, day),
      gregorianDate: gregorian,
      fetchedAt: gregorian,
    );

    test('computes locally within the same month without fetching', () async {
      final source = _FakeSource(anchor(1, DateTime(2026, 6, 17)));
      final cal = ShiaHijriCalendar(
        source: source,
        clock: () => DateTime(2026, 6, 25, 9), // 8 days later
      );
      await cal.refresh(); // seed the cache (1 fetch)
      final today = await cal.today();
      expect(today, HijriDate(1448, 1, 9)); // 1 + 8 days
      expect(source.fetchCount, 1); // no extra fetch
    });

    test('fetches again when a month boundary is in play', () async {
      // Anchor is day 28; "today" is 3 days later -> day 31 (impossible),
      // so the calendar must fetch fresh data.
      final source = _FakeSource(anchor(28, DateTime(2026, 7, 14)));
      final cal = ShiaHijriCalendar(
        source: source,
        clock: () => DateTime(2026, 7, 17), // 3 days later -> day 31
      );
      final today = await cal.today();
      // Fresh snapshot still says day 28 (fake source is fixed), diff 3 -> the
      // confident path can't resolve, so it returns the anchor's own date.
      expect(today, HijriDate(1448, 1, 28));
      expect(source.fetchCount, 1);
    });

    test('falls back to cache when the source is offline', () async {
      // Anchor day 28; today is 2 days later -> day 30, which is uncertain so
      // the calendar tries to fetch. The source is offline, so it must fall
      // back to the optimistic local value rather than throw.
      final store = MemoryAnchorStore();
      await store.write(anchor(28, DateTime(2026, 6, 21)));
      final cal = ShiaHijriCalendar(
        source: _FailingSource(),
        store: store,
        clock: () => DateTime(2026, 6, 23), // 2 days later -> day 30
      );
      final today = await cal.today();
      expect(today, HijriDate(1448, 1, 30));
    });

    test('rethrows when offline and the date is outside known data', () async {
      // 2030 is far past the seeded month, so nothing can resolve it offline.
      final cal = ShiaHijriCalendar(
        source: _FailingSource(),
        clock: () => DateTime(2030, 1, 1),
      );
      expect(cal.today(), throwsA(isA<ShiaHijriSourceException>()));
    });

    test('answers offline from the seeded official anchor', () async {
      // No store, source offline, but the bundled 1 Muharram 1448 seed covers
      // 20 Jun 2026 -> verified without any network.
      final cal = ShiaHijriCalendar(
        source: _FailingSource(),
        clock: () => DateTime(2026, 6, 20),
      );
      expect(await cal.today(), HijriDate(1448, 1, 4));
    });
  });

  group('TabularIslamicCalendar', () {
    test('round-trips Gregorian -> Hijri -> Gregorian exactly', () {
      for (final date in [
        DateTime(2024, 1, 1),
        DateTime(2026, 6, 17),
        DateTime(2030, 12, 31),
        DateTime(2000, 2, 29),
      ]) {
        final hijri = TabularIslamicCalendar.fromGregorian(date);
        expect(TabularIslamicCalendar.toGregorian(hijri), date);
      }
    });

    test('is close to the official 1 Muharram 1448', () {
      final h = TabularIslamicCalendar.fromGregorian(DateTime(2026, 6, 17));
      expect(h.year, 1448);
      expect(h.monthNumber, 1);
      expect(h.day, lessThanOrEqualTo(3)); // within a couple of days
    });
  });

  group('conversion', () {
    final cal = ShiaHijriCalendar(clock: () => DateTime(2026, 6, 17));

    test('gregorian -> hijri is verified inside a seeded month', () {
      final c = cal.gregorianToHijri(DateTime(2026, 6, 20));
      expect(c.hijri, HijriDate(1448, 1, 4));
      expect(c.isVerified, isTrue);
    });

    test('gregorian -> hijri falls back to an estimate when unknown', () {
      final c = cal.gregorianToHijri(DateTime(2035, 1, 1));
      expect(c.source, ConversionSource.estimated);
    });

    test('hijri -> gregorian is verified for a seeded month', () {
      final c = cal.hijriToGregorian(HijriDate(1448, 1, 4));
      expect(c.gregorian, DateTime(2026, 6, 20));
      expect(c.isVerified, isTrue);
    });

    test('hijri -> gregorian estimates an unknown month', () {
      final c = cal.hijriToGregorian(HijriDate(1500, 6, 1));
      expect(c.source, ConversionSource.estimated);
    });
  });
}
