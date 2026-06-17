import 'dart:convert';

import 'shia_hijri_snapshot.dart';

/// Persists the most recent verified [ShiaHijriSnapshot] so the calendar can
/// answer offline and avoid hitting the network on every call.
///
/// The default [MemoryAnchorStore] keeps the value for the process lifetime.
/// On Flutter, back it with `shared_preferences` or a file by extending
/// [StringAnchorStore].
abstract class AnchorStore {
  Future<ShiaHijriSnapshot?> read();
  Future<void> write(ShiaHijriSnapshot snapshot);
}

/// Keeps the snapshot in memory only (lost when the process exits).
class MemoryAnchorStore implements AnchorStore {
  ShiaHijriSnapshot? _value;

  @override
  Future<ShiaHijriSnapshot?> read() async => _value;

  @override
  Future<void> write(ShiaHijriSnapshot snapshot) async => _value = snapshot;
}

/// Convenience base for persistent stores: implement the two string hooks and
/// JSON (de)serialization is handled for you.
///
/// ```dart
/// class PrefsAnchorStore extends StringAnchorStore {
///   PrefsAnchorStore(this.prefs);
///   final SharedPreferences prefs;
///   @override
///   Future<String?> readString() async => prefs.getString('shia_hijri');
///   @override
///   Future<void> writeString(String value) async =>
///       prefs.setString('shia_hijri', value);
/// }
/// ```
abstract class StringAnchorStore implements AnchorStore {
  Future<String?> readString();
  Future<void> writeString(String value);

  @override
  Future<ShiaHijriSnapshot?> read() async {
    final raw = await readString();
    if (raw == null || raw.isEmpty) return null;
    try {
      return ShiaHijriSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null; // ignore corrupt cache
    }
  }

  @override
  Future<void> write(ShiaHijriSnapshot snapshot) =>
      writeString(jsonEncode(snapshot.toJson()));
}
