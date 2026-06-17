import 'shia_hijri_snapshot.dart';

/// A source of verified Shia Hijri anchors.
///
/// The bundled implementation is [SistaniHijriSource], which scrapes
/// sistani.org. Provide your own (e.g. a different office, a test fake, or a
/// cached API) by implementing this interface. On failure, implementations
/// should throw a [ShiaHijriSourceException].
abstract interface class HijriDateSource {
  /// Retrieves the current verified anchor.
  Future<ShiaHijriSnapshot> fetch();

  /// Releases any held resources (e.g. an HTTP client). No-op is acceptable.
  void close();
}
