# shia_hijri_calendar

[![pub package](https://img.shields.io/pub/v/shia_hijri_calendar.svg)](https://pub.dev/packages/shia_hijri_calendar)
[![pub points](https://img.shields.io/pub/points/shia_hijri_calendar)](https://pub.dev/packages/shia_hijri_calendar/score)
[![likes](https://img.shields.io/pub/likes/shia_hijri_calendar)](https://pub.dev/packages/shia_hijri_calendar/score)
[![CI](https://github.com/alialrikabi313/shia_hijri_calendar/actions/workflows/ci.yml/badge.svg)](https://github.com/alialrikabi313/shia_hijri_calendar/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/alialrikabi313/shia_hijri_calendar/badges/coverage.json)](https://github.com/alialrikabi313/shia_hijri_calendar/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Official **Shia (Sistani office) Hijri date** for Dart & Flutter.

The Shia Hijri calendar follows **actual moon sighting** (رؤية الهلال) as
announced by the office of Grand Ayatollah al-Sistani, which can differ by a
day from the calculated Umm al-Qura calendar. This package reads the
authoritative date directly from [sistani.org](https://www.sistani.org/),
caches it, and counts locally between month boundaries — so it only touches the
network at the **start and end of a Hijri month**.

## Why this package?

Most Hijri date libraries compute dates with a fixed arithmetic formula
(Umm al-Qura / tabular). But the Shia calendar is **sighting-based**: the month
begins only when the crescent is actually confirmed by the office of al-Sistani,
which can land a day off from any formula. There was no API for it — the
official date is rendered into the `#home-date` element of the sistani.org home
page. This package treats that as a data source: it fetches the authoritative
date, anchors it, and then derives every other day locally (a Hijri month is
always 29–30 days), fetching again only at month boundaries. The result is an
accurate, offline-friendly, sighting-correct calendar that no formula-only
library can match.

> التقويم الهجري عند الشيعة يعتمد على **رؤية الهلال** كما يعلنها مكتب السيد
> السيستاني، وقد يختلف يوماً عن تقويم أم القرى. هذه الحزمة تجيب التاريخ الرسمي
> من موقع السيستاني، تخزّنه محلياً، وتحسب الأيام بنفسها بين الشهور — فلا تتصل
> بالإنترنت إلا عند **أول وآخر الشهر**.

## Features

- ✅ Today's official Shia Hijri date (`today()`).
- ✅ Bidirectional conversion `gregorianToHijri()` / `hijriToGregorian()`,
  flagged **verified** (known boundary) or **estimated** (tabular fallback).
- ✅ Built-in Shia **religious occasions** (مناسبات) — Ashura, Arbaeen, Eids,
  births/martyrdoms — with holiday flags; fully customizable.
- ✅ Offline between month edges (verified boundaries + local arithmetic).
- ✅ Arabic / English / ISO formatting.
- ✅ Pluggable cache (`MemoryAnchorStore`, or your own via `StringAnchorStore`).
- ✅ Pluggable source (`HijriDateSource`) for testing or other offices.
- ✅ Pure Dart — works on mobile, desktop, server, and CLI.

## Install

```yaml
dependencies:
  shia_hijri_calendar: ^0.3.2
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

### Religious occasions (مناسبات)

```dart
final calendar = ShiaHijriCalendar();

// What falls today?
for (final o in await calendar.occasionsToday()) {
  print('${o.arabicName} (${o.type.name})');
}

// All occasions in a month, or on a specific date:
calendar.occasionsInMonth(1);                 // Muharram: Ashura, Tasua, ...
calendar.occasionsOn(HijriDate(1448, 1, 10)); // عاشوراء
calendar.isHoliday(HijriDate(1448, 12, 18));  // true (Eid al-Ghadir)
```

Dates follow the commonly observed Imami convention. Some occasions have more
than one narration — pass your own list to fully control them:

```dart
final calendar = ShiaHijriCalendar(
  occasions: [
    ...shiaOccasions(), // start from the defaults
    const IslamicOccasion(
      month: 6, day: 13,
      arabicName: 'وفاة السيدة فاطمة (ع) - رواية',
      englishName: 'Martyrdom of Lady Fatima (alt.)',
      type: OccasionType.martyrdom,
    ),
  ],
);
```

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
