// Helpers for converting between Western (ASCII) digits and the
// Arabic-Indic / Persian digit forms used on sistani.org.

const _arabicIndicZero = 0x0660; // ٠ .. ٩  (U+0660 .. U+0669)
const _persianZero = 0x06F0; // ۰ .. ۹  (U+06F0 .. U+06F9)
const _asciiZero = 0x30; // 0 .. 9

/// Replaces every Arabic-Indic or Persian digit in [input] with its ASCII
/// equivalent. Non-digit characters are left untouched.
String arabicToAsciiDigits(String input) {
  final buffer = StringBuffer();
  for (final code in input.codeUnits) {
    if (code >= _arabicIndicZero && code <= _arabicIndicZero + 9) {
      buffer.writeCharCode(_asciiZero + (code - _arabicIndicZero));
    } else if (code >= _persianZero && code <= _persianZero + 9) {
      buffer.writeCharCode(_asciiZero + (code - _persianZero));
    } else {
      buffer.writeCharCode(code);
    }
  }
  return buffer.toString();
}

/// Renders [value] using Arabic-Indic digits (e.g. `1448` → `١٤٤٨`).
String asciiToArabicDigits(Object value) {
  final buffer = StringBuffer();
  for (final code in value.toString().codeUnits) {
    if (code >= _asciiZero && code <= _asciiZero + 9) {
      buffer.writeCharCode(_arabicIndicZero + (code - _asciiZero));
    } else {
      buffer.writeCharCode(code);
    }
  }
  return buffer.toString();
}

/// Extracts the first run of digits (Arabic or ASCII) from [input] and parses
/// it as an `int`, or returns `null` when there is no digit run.
int? firstIntIn(String input) {
  final match = RegExp(r'\d+').firstMatch(arabicToAsciiDigits(input));
  return match == null ? null : int.parse(match.group(0)!);
}
