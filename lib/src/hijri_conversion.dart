import 'hijri_date.dart';

/// How a converted date was obtained.
enum ConversionSource {
  /// Backed by a verified Sistani month boundary — exact.
  verified,

  /// Arithmetic tabular approximation — may be off by a day or two.
  estimated,
}

/// Result of converting a Gregorian date to Shia Hijri.
class HijriConversion {
  HijriConversion(this.hijri, this.source);
  final HijriDate hijri;
  final ConversionSource source;

  bool get isVerified => source == ConversionSource.verified;

  @override
  String toString() => '${hijri.toIso()} (${source.name})';
}

/// Result of converting a Shia Hijri date to Gregorian.
class GregorianConversion {
  GregorianConversion(this.gregorian, this.source);

  /// Date-only Gregorian value.
  final DateTime gregorian;
  final ConversionSource source;

  bool get isVerified => source == ConversionSource.verified;

  @override
  String toString() =>
      '${gregorian.toIso8601String().split('T').first} (${source.name})';
}
