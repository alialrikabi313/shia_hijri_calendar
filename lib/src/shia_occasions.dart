import 'islamic_occasion.dart';

/// The default set of Shia religious occasions, by Hijri month/day.
///
/// Dates follow the **commonly observed** Imami (Ja'fari) convention. Some
/// occasions have more than one narration (e.g. the martyrdom of Lady Fatima
/// is variously marked on 13 Jumada I or 3 Jumada II); the widely-used date is
/// used here. Pass your own list to `ShiaHijriCalendar(occasions: ...)`, or
/// start from this one and adjust, to match the convention you follow.
List<IslamicOccasion> shiaOccasions() => const [
  // ── Muharram ──────────────────────────────────────────────
  IslamicOccasion(
    month: 1,
    day: 1,
    arabicName: 'غرّة محرم - رأس السنة الهجرية',
    englishName: 'Islamic New Year',
    type: OccasionType.religious,
  ),
  IslamicOccasion(
    month: 1,
    day: 9,
    arabicName: 'تاسوعاء',
    englishName: 'Tasua',
    type: OccasionType.mourning,
  ),
  IslamicOccasion(
    month: 1,
    day: 10,
    arabicName: 'عاشوراء - استشهاد الإمام الحسين (ع)',
    englishName: 'Ashura — Martyrdom of Imam al-Husayn',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 1,
    day: 25,
    arabicName: 'استشهاد الإمام زين العابدين (ع)',
    englishName: 'Martyrdom of Imam al-Sajjad',
    type: OccasionType.martyrdom,
  ),
  // ── Safar ─────────────────────────────────────────────────
  IslamicOccasion(
    month: 2,
    day: 20,
    arabicName: 'أربعين الإمام الحسين (ع)',
    englishName: 'Arbaeen',
    type: OccasionType.mourning,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 2,
    day: 28,
    arabicName: 'وفاة النبي محمد (ص) واستشهاد الإمام الحسن (ع)',
    englishName: 'Passing of the Prophet & Martyrdom of Imam al-Hasan',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 2,
    day: 30,
    arabicName: 'استشهاد الإمام الرضا (ع)',
    englishName: 'Martyrdom of Imam al-Rida',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  // ── Rabi al-Awwal ─────────────────────────────────────────
  IslamicOccasion(
    month: 3,
    day: 8,
    arabicName: 'استشهاد الإمام الحسن العسكري (ع) وبدء إمامة المهدي (عج)',
    englishName: 'Martyrdom of Imam al-Askari',
    type: OccasionType.martyrdom,
  ),
  IslamicOccasion(
    month: 3,
    day: 17,
    arabicName: 'المولد النبوي الشريف وولادة الإمام الصادق (ع)',
    englishName: 'Birth of the Prophet & Imam al-Sadiq',
    type: OccasionType.birth,
    isHoliday: true,
  ),
  // ── Rabi al-Thani ─────────────────────────────────────────
  IslamicOccasion(
    month: 4,
    day: 10,
    arabicName: 'ولادة الإمام الحسن العسكري (ع)',
    englishName: 'Birth of Imam al-Askari',
    type: OccasionType.birth,
  ),
  // ── Jumada al-Ula ─────────────────────────────────────────
  IslamicOccasion(
    month: 5,
    day: 5,
    arabicName: 'ولادة السيدة زينب (ع)',
    englishName: 'Birth of Lady Zaynab',
    type: OccasionType.birth,
  ),
  // ── Jumada al-Akhira ──────────────────────────────────────
  IslamicOccasion(
    month: 6,
    day: 3,
    arabicName: 'استشهاد السيدة فاطمة الزهراء (ع)',
    englishName: 'Martyrdom of Lady Fatima al-Zahra',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 6,
    day: 20,
    arabicName: 'ولادة السيدة فاطمة الزهراء (ع)',
    englishName: 'Birth of Lady Fatima al-Zahra',
    type: OccasionType.birth,
  ),
  // ── Rajab ─────────────────────────────────────────────────
  IslamicOccasion(
    month: 7,
    day: 1,
    arabicName: 'ولادة الإمام الباقر (ع)',
    englishName: 'Birth of Imam al-Baqir',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 7,
    day: 3,
    arabicName: 'استشهاد الإمام الهادي (ع)',
    englishName: 'Martyrdom of Imam al-Hadi',
    type: OccasionType.martyrdom,
  ),
  IslamicOccasion(
    month: 7,
    day: 10,
    arabicName: 'ولادة الإمام الجواد (ع)',
    englishName: 'Birth of Imam al-Jawad',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 7,
    day: 13,
    arabicName: 'ولادة الإمام علي (ع) في الكعبة',
    englishName: 'Birth of Imam Ali',
    type: OccasionType.birth,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 7,
    day: 25,
    arabicName: 'استشهاد الإمام الكاظم (ع)',
    englishName: 'Martyrdom of Imam al-Kazim',
    type: OccasionType.martyrdom,
  ),
  IslamicOccasion(
    month: 7,
    day: 27,
    arabicName: 'المبعث النبوي الشريف',
    englishName: "Mab'ath (Prophetic Mission)",
    type: OccasionType.religious,
    isHoliday: true,
  ),
  // ── Shaban ────────────────────────────────────────────────
  IslamicOccasion(
    month: 8,
    day: 3,
    arabicName: 'ولادة الإمام الحسين (ع)',
    englishName: 'Birth of Imam al-Husayn',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 8,
    day: 4,
    arabicName: 'ولادة أبي الفضل العباس (ع)',
    englishName: 'Birth of Abu al-Fadl al-Abbas',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 8,
    day: 5,
    arabicName: 'ولادة الإمام زين العابدين (ع)',
    englishName: 'Birth of Imam al-Sajjad',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 8,
    day: 15,
    arabicName: 'ولادة الإمام المهدي (عج) - النصف من شعبان',
    englishName: 'Birth of Imam al-Mahdi',
    type: OccasionType.birth,
    isHoliday: true,
  ),
  // ── Ramadan ───────────────────────────────────────────────
  IslamicOccasion(
    month: 9,
    day: 10,
    arabicName: 'وفاة السيدة خديجة (ع)',
    englishName: 'Passing of Lady Khadija',
    type: OccasionType.martyrdom,
  ),
  IslamicOccasion(
    month: 9,
    day: 15,
    arabicName: 'ولادة الإمام الحسن المجتبى (ع)',
    englishName: 'Birth of Imam al-Hasan',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 9,
    day: 19,
    arabicName: 'ليلة القدر - ضربة الإمام علي (ع)',
    englishName: 'Laylat al-Qadr — Striking of Imam Ali',
    type: OccasionType.mourning,
  ),
  IslamicOccasion(
    month: 9,
    day: 21,
    arabicName: 'استشهاد الإمام علي (ع)',
    englishName: 'Martyrdom of Imam Ali',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 9,
    day: 23,
    arabicName: 'ليلة القدر',
    englishName: 'Laylat al-Qadr',
    type: OccasionType.religious,
  ),
  // ── Shawwal ───────────────────────────────────────────────
  IslamicOccasion(
    month: 10,
    day: 1,
    arabicName: 'عيد الفطر',
    englishName: 'Eid al-Fitr',
    type: OccasionType.eid,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 10,
    day: 25,
    arabicName: 'استشهاد الإمام الصادق (ع)',
    englishName: 'Martyrdom of Imam al-Sadiq',
    type: OccasionType.martyrdom,
    isHoliday: true,
  ),
  // ── Dhu al-Qadah ──────────────────────────────────────────
  IslamicOccasion(
    month: 11,
    day: 11,
    arabicName: 'ولادة الإمام الرضا (ع)',
    englishName: 'Birth of Imam al-Rida',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 11,
    day: 29,
    arabicName: 'استشهاد الإمام الجواد (ع)',
    englishName: 'Martyrdom of Imam al-Jawad',
    type: OccasionType.martyrdom,
  ),
  // ── Dhu al-Hijjah ─────────────────────────────────────────
  IslamicOccasion(
    month: 12,
    day: 1,
    arabicName: 'زواج الإمام علي والسيدة فاطمة (ع)',
    englishName: 'Marriage of Imam Ali & Lady Fatima',
    type: OccasionType.religious,
  ),
  IslamicOccasion(
    month: 12,
    day: 7,
    arabicName: 'استشهاد الإمام الباقر (ع)',
    englishName: 'Martyrdom of Imam al-Baqir',
    type: OccasionType.martyrdom,
  ),
  IslamicOccasion(
    month: 12,
    day: 9,
    arabicName: 'يوم عرفة',
    englishName: 'Day of Arafah',
    type: OccasionType.religious,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 12,
    day: 10,
    arabicName: 'عيد الأضحى',
    englishName: 'Eid al-Adha',
    type: OccasionType.eid,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 12,
    day: 15,
    arabicName: 'ولادة الإمام الهادي (ع)',
    englishName: 'Birth of Imam al-Hadi',
    type: OccasionType.birth,
  ),
  IslamicOccasion(
    month: 12,
    day: 18,
    arabicName: 'عيد الغدير',
    englishName: 'Eid al-Ghadir',
    type: OccasionType.eid,
    isHoliday: true,
  ),
  IslamicOccasion(
    month: 12,
    day: 24,
    arabicName: 'يوم المباهلة',
    englishName: 'Day of Mubahala',
    type: OccasionType.religious,
  ),
];
