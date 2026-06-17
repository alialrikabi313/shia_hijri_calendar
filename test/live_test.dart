@Tags(['live'])
library;

import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';
import 'package:test/test.dart';

/// Hits the real sistani.org site to confirm the scraper still works.
///
/// Excluded from normal CI (`dart test -x live`); the scheduled
/// `monitor.yml` workflow runs it weekly and opens an issue if it breaks.
void main() {
  test(
    'sistani.org still returns a parseable date',
    () async {
      final calendar = ShiaHijriCalendar();
      try {
        final today = await calendar.today(forceRefresh: true);
        expect(today.year, greaterThan(1440));
        expect(today.monthNumber, inInclusiveRange(1, 12));
        expect(today.day, inInclusiveRange(1, 30));

        final snapshot = calendar.lastSnapshot;
        expect(snapshot, isNotNull);
        expect(snapshot!.gregorianDate.year, greaterThanOrEqualTo(2026));
      } finally {
        calendar.close();
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
