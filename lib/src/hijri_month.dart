/// The twelve months of the Islamic (Hijri) lunar calendar.
///
/// Index values are 1-based (Muharram = 1 ... Dhul-Hijjah = 12) so they map
/// directly onto the numbers used by the Sistani office and most calendars.
enum HijriMonth {
  muharram(1, 'Muharram', 'المحرم'),
  safar(2, 'Safar', 'صفر'),
  rabiAlAwwal(3, 'Rabi al-Awwal', 'ربيع الأول'),
  rabiAlThani(4, 'Rabi al-Thani', 'ربيع الآخر'),
  jumadaAlUla(5, 'Jumada al-Ula', 'جمادى الأولى'),
  jumadaAlAkhira(6, 'Jumada al-Akhira', 'جمادى الآخرة'),
  rajab(7, 'Rajab', 'رجب'),
  shaban(8, 'Shaban', 'شعبان'),
  ramadan(9, 'Ramadan', 'رمضان'),
  shawwal(10, 'Shawwal', 'شوال'),
  dhuAlQadah(11, 'Dhu al-Qadah', 'ذو القعدة'),
  dhuAlHijjah(12, 'Dhu al-Hijjah', 'ذو الحجة');

  const HijriMonth(this.number, this.englishName, this.arabicName);

  /// 1-based month number (1..12).
  final int number;

  /// Latin transliteration, e.g. `Ramadan`.
  final String englishName;

  /// Canonical Arabic name, e.g. `رمضان`.
  final String arabicName;

  /// Looks up a month by its 1-based [number] (1..12).
  static HijriMonth fromNumber(int number) {
    if (number < 1 || number > 12) {
      throw RangeError.range(number, 1, 12, 'number', 'Hijri month');
    }
    return HijriMonth.values[number - 1];
  }

  /// Parses an Arabic month label as written on sistani.org
  /// (e.g. `المحرم الحرام`, `ربيع الآخر`, `ذي القعدة`).
  ///
  /// Matching is tolerant of the decorative suffixes the office adds
  /// (الحرام، المعظم، المكرم ...), of `ال` prefixes, and of Arabic letter
  /// variants (أ/إ/آ → ا, ة → ه, ى → ي). Returns `null` if no month matches.
  static HijriMonth? fromArabicText(String input) {
    final t = _normalizeArabic(input);

    bool has(String needle) => t.contains(_normalizeArabic(needle));

    if (has('محرم')) return muharram;
    if (has('صفر')) return safar;
    if (has('ربيع')) {
      return (has('اول') || has('اولى')) ? rabiAlAwwal : rabiAlThani;
    }
    if (has('جماد')) {
      return (has('اول') || has('اولى')) ? jumadaAlUla : jumadaAlAkhira;
    }
    if (has('رجب')) return rajab;
    if (has('شعبان')) return shaban;
    if (has('رمضان')) return ramadan;
    if (has('شوال')) return shawwal;
    if (has('قعد')) return dhuAlQadah;
    if (has('حج')) return dhuAlHijjah;
    return null;
  }

  @override
  String toString() => englishName;
}

/// Normalizes Arabic text for tolerant matching: strips diacritics, the
/// leading `ال`, and unifies common letter variants.
String _normalizeArabic(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    switch (ch) {
      case 'أ':
      case 'إ':
      case 'آ':
        buffer.write('ا');
      case 'ة':
        buffer.write('ه');
      case 'ى':
        buffer.write('ي');
      // Drop tatweel and the common Arabic diacritics.
      case 'ـ':
      case 'ً': // ً
      case 'ٌ': // ٌ
      case 'ٍ': // ٍ
      case 'َ': // َ
      case 'ُ': // ُ
      case 'ِ': // ِ
      case 'ّ': // ّ
      case 'ْ': // ْ
        break;
      default:
        buffer.write(ch);
    }
  }
  // Remove the definite article so "المحرم" matches "محرم".
  return buffer.toString().replaceAll('ال', '').trim();
}
