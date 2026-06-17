# shia_hijri_calendar

Official **Shia (Sistani office) Hijri date** for Dart & Flutter.

The Shia Hijri calendar follows **actual moon sighting** (رؤية الهلال) as
announced by the office of Grand Ayatollah al-Sistani, which can differ by a
day from the calculated Umm al-Qura calendar. This package reads the
authoritative date directly from [sistani.org](https://www.sistani.org/),
caches it, and counts locally between month boundaries — so it only touches the
network at the **start and end of a Hijri month**.

> التقويم الهجري عند الشيعة يعتمد على **رؤية الهلال** كما يعلنها مكتب السيد
> السيستاني، وقد يختلف يوماً عن تقويم أم القرى. هذه الحزمة تجيب التاريخ الرسمي
> من موقع السيستاني، تخزّنه محلياً، وتحسب الأيام بنفسها بين الشهور — فلا تتصل
> بالإنترنت إلا عند **أول وآخر الشهر**.

## Features

- ✅ Today's official Shia Hijri date (`today()`).
- ✅ Bidirectional conversion `gregorianToHijri()` / `hijriToGregorian()`,
  flagged **verified** (known boundary) or **estimated** (tabular fallback).
- ✅ Offline between month edges (verified boundaries + local arithmetic).
- ✅ Arabic / English / ISO formatting.
- ✅ Pluggable cache (`MemoryAnchorStore`, or your own via `StringAnchorStore`).
- ✅ Pluggable source (`HijriDateSource`) for testing or other offices.
- ✅ Pure Dart — works on mobile, desktop, server, and CLI.

## Install

```yaml
dependencies:
  shia_hijri_calendar: ^0.2.0
```

## Usage

```dart
import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';

Future<void> main() async {
  final calendar = ShiaHijriCalendar();

  final today = await calendar.today();
  print(today.formatArabic());  // ١ المحرم ١٤٤٨هـ
  print(today.formatEnglish()); // 1 Muharram 1448 AH
  print(today.toIso());         // 1448-01-01

  calendar.close();
}
```

### Converting dates

```dart
final calendar = ShiaHijriCalendar();
await calendar.today(); // optional: enrich verified data first

final c = calendar.gregorianToHijri(DateTime(2026, 6, 20));
print('${c.hijri.formatEnglish()} (${c.isVerified ? 'verified' : 'estimate'})');

final g = calendar.hijriToGregorian(HijriDate(1448, 1, 10));
print(g); // 2026-06-26 (verified)
```

Verified results come from official month boundaries — seeded via
`officialMonthStarts()` and learned from each successful fetch. Add confirmed
boundaries to `officialMonthStarts()` to widen exact coverage; everything else
uses the tabular (`TabularIslamicCalendar`) approximation.

### How fetching works

`today()` returns the cached value and advances the day locally as long as the
answer is unambiguous (days 1–29 of the known month). When a month boundary is
in play, it fetches a fresh value from sistani.org and updates the cache. Use
`refresh()` to force a fetch, or `today(forceRefresh: true)`.

If the network is unavailable but a cached anchor exists, a best-effort value
is returned (possibly off by one near a month end) instead of throwing.

### Persisting the cache (Flutter)

By default the cache lives in memory. To survive restarts, back it with
`shared_preferences`:

```dart
class PrefsAnchorStore extends StringAnchorStore {
  PrefsAnchorStore(this.prefs);
  final SharedPreferences prefs;

  @override
  Future<String?> readString() async => prefs.getString('shia_hijri');

  @override
  Future<void> writeString(String value) async =>
      prefs.setString('shia_hijri', value);
}

final calendar = ShiaHijriCalendar(store: PrefsAnchorStore(prefs));
```

> **Flutter Web note:** browsers block direct cross-origin requests (CORS) to
> sistani.org. On the web, route the fetch through your own proxy/backend and
> feed the HTML to `SistaniHijriSource().parse(html)`, or implement a custom
> `HijriDateSource`.

## Data source & accuracy

The date is parsed from the server-rendered `#home-date` block on the
sistani.org home page. Results match exactly what the office publishes. This
package is an unofficial client and is not affiliated with the office of
al-Sistani.

## Roadmap

- Persist the full learned month-start table (not just the latest anchor).
- Ship more verified boundaries from the yearly «مواقيت الأهلّة».
- Optional companion Flutter package with ready-made widgets.

## License

MIT — see [LICENSE](LICENSE).
