## 0.3.3

- Docs: fix the README install snippet (was `^0.2.0`, a version that was never
  published) to `^0.3.2`.

## 0.3.2

- Switch the coverage badge to a self-hosted shields.io endpoint (no external
  service required) after Codecov dropped tokenless uploads.

## 0.3.1

- Docs: status badges (pub, CI, coverage, license) and a "Why this package?"
  section in the README.
- CI: measure coverage and upload to Codecov; exclude live tests from CI.
- Add a weekly source-monitor workflow that opens an issue if the sistani.org
  scraper breaks, plus a `live`-tagged integration test.

## 0.3.0

- **Religious occasions** (مناسبات): bundled Shia occasions dataset
  (`shiaOccasions()`) with Arabic/English names, type, and holiday flag.
- New API: `occasionsOn()`, `occasionsInMonth()`, `occasionsToday()`,
  `isHoliday()`, and an `occasions:` constructor argument to fully customize the
  set.
- `IslamicOccasion` / `OccasionType` models.

## 0.2.0

- **Bidirectional conversion**: `gregorianToHijri()` and `hijriToGregorian()`,
  each returning a result flagged `verified` (backed by a known Sistani month
  boundary) or `estimated` (tabular approximation).
- `TabularIslamicCalendar` — offline arithmetic (Kuwaiti) conversion used as the
  fallback; exact round-trips.
- `MonthStart` / `MonthStartTable` — verified month boundaries, seeded from
  `officialMonthStarts()` and learned from every successful fetch.
- `today()` now answers offline from seeded/learned data when unambiguous, and
  reads persisted state via `load()`.

## 0.1.0

- Initial release.
- `ShiaHijriCalendar.today()` — official Shia (Sistani office) Hijri date,
  fetched from sistani.org, cached, and computed locally between month edges.
- `SistaniHijriSource` — server-rendered scraper for `#home-date` (no JS).
- `HijriDate` value type with Arabic/English/ISO formatting.
- `HijriMonth` enum with tolerant Arabic month-name parsing.
- Pluggable `AnchorStore` (`MemoryAnchorStore`, `StringAnchorStore`) and
  `HijriDateSource` interfaces.
