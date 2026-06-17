import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';

Future<void> main() async {
  final calendar = ShiaHijriCalendar();
  try {
    final today = await calendar.today();
    print('Arabic : ${today.formatArabic()}'); // ١ المحرم ١٤٤٨هـ
    print('English: ${today.formatEnglish()}'); // 1 Muharram 1448 AH
    print('ISO    : ${today.toIso()}'); // 1448-01-01

    final snapshot = calendar.lastSnapshot;
    if (snapshot != null) {
      print('Anchor : ${snapshot.gregorianDate} -> ${snapshot.hijri}');
    }

    // Bidirectional conversion (exact where verified, else tabular estimate).
    final g2h = calendar.gregorianToHijri(DateTime(2026, 6, 20));
    print(
      'G->H   : 2026-06-20 = ${g2h.hijri.formatEnglish()} '
      '(${g2h.isVerified ? "verified" : "estimate"})',
    );

    final h2g = calendar.hijriToGregorian(HijriDate(1448, 1, 10));
    print('H->G   : 10 Muharram 1448 = $h2g');
  } finally {
    calendar.close();
  }
}
