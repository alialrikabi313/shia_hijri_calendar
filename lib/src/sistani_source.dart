import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

import 'arabic_digits.dart';
import 'hijri_date.dart';
import 'hijri_date_source.dart';
import 'hijri_month.dart';
import 'shia_hijri_snapshot.dart';

/// Thrown when the Sistani page cannot be fetched or its date block cannot be
/// understood (e.g. the site markup changed).
class ShiaHijriSourceException implements Exception {
  ShiaHijriSourceException(this.message);
  final String message;
  @override
  String toString() => 'ShiaHijriSourceException: $message';
}

/// Fetches the official Shia Hijri date from the Sistani office website.
///
/// The home page at [endpoint] is server-rendered (no JavaScript required) and
/// embeds the date inside `<div id="home-date">`, e.g.:
///
/// ```html
/// <div id="home-date">
///   <span>الأربعاء ١ - المحرم الحرام - ١٤٤٨هـ </span>|| <span></span> (النجف الأشرف)
///    || Wed, 17 Jun 2026
/// </div>
/// <script>var lastHomeUpdate=(new Date).getTime(), uts=1781696659;</script>
/// ```
class SistaniHijriSource implements HijriDateSource {
  SistaniHijriSource({
    http.Client? client,
    Uri? endpoint,
    DateTime Function()? clock,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       endpoint = endpoint ?? Uri.parse('https://www.sistani.org/'),
       _clock = clock ?? DateTime.now;

  final http.Client _client;
  final bool _ownsClient;
  final DateTime Function() _clock;

  /// The page that carries the `#home-date` block. Defaults to the site root.
  final Uri endpoint;

  static const _userAgent =
      'shia_hijri_calendar (+https://pub.dev/packages/shia_hijri_calendar)';

  static const _gregorianMonths = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// Downloads the page and returns the parsed [ShiaHijriSnapshot].
  @override
  Future<ShiaHijriSnapshot> fetch() async {
    final http.Response response;
    try {
      response = await _client.get(
        endpoint,
        headers: {'User-Agent': _userAgent},
      );
    } catch (e) {
      throw ShiaHijriSourceException('network error fetching $endpoint: $e');
    }
    if (response.statusCode != 200) {
      throw ShiaHijriSourceException(
        'unexpected status ${response.statusCode} from $endpoint',
      );
    }
    return parse(response.body);
  }

  /// Parses a previously fetched HTML [body]. Exposed for testing and for
  /// callers that supply their own transport.
  ShiaHijriSnapshot parse(String body) {
    final doc = html.parse(body);
    final dateBlock = doc.getElementById('home-date');
    if (dateBlock == null) {
      throw ShiaHijriSourceException('no #home-date element in the page');
    }

    final span = dateBlock.querySelector('span');
    final hijriText = span?.text.trim() ?? '';
    final blockText = dateBlock.text;

    final hijri = _parseHijri(hijriText);
    final gregorian = _parseGregorian(blockText);
    final serverTime = _parseServerTime(body);

    return ShiaHijriSnapshot(
      hijri: hijri,
      gregorianDate: gregorian,
      fetchedAt: _clock(),
      serverTime: serverTime,
    );
  }

  HijriDate _parseHijri(String text) {
    final month = HijriMonth.fromArabicText(text);
    if (month == null) {
      throw ShiaHijriSourceException('could not read Hijri month from "$text"');
    }
    final ascii = arabicToAsciiDigits(text);
    // Day = first number in the span (the weekday has no digits).
    final dayMatch = RegExp(r'\d+').firstMatch(ascii);
    // Year = the number right before هـ.
    final yearMatch = RegExp(r'(\d+)\s*هـ').firstMatch(ascii);
    if (dayMatch == null || yearMatch == null) {
      throw ShiaHijriSourceException('could not read day/year from "$text"');
    }
    return HijriDate.of(
      int.parse(yearMatch.group(1)!),
      month,
      int.parse(dayMatch.group(0)!),
    );
  }

  DateTime _parseGregorian(String text) {
    final m = RegExp(r'(\d{1,2})\s+([A-Za-z]{3,})\s+(\d{4})').firstMatch(text);
    if (m == null) {
      throw ShiaHijriSourceException('no Gregorian date found in "$text"');
    }
    final month = _gregorianMonths[m.group(2)!.toLowerCase().substring(0, 3)];
    if (month == null) {
      throw ShiaHijriSourceException('unknown month "${m.group(2)}"');
    }
    return DateTime(int.parse(m.group(3)!), month, int.parse(m.group(1)!));
  }

  DateTime? _parseServerTime(String body) {
    final m = RegExp(r'uts\s*=\s*(\d+)').firstMatch(body);
    if (m == null) return null;
    final seconds = int.tryParse(m.group(1)!);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Closes the underlying HTTP client if this source created it.
  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}
