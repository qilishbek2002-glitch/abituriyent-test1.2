// ============================================================
//  SHU FAYLNI O'ZINGIZGA MOSLAB TO'LDIRING
// ============================================================

const String kAppName = 'Abituriyent Test';

/// Obuna narxi (so'm) va muddati (kun).
const int kPriceSom = 15000;
const int kSubscriptionDays = 30;

/// Obuna talab qilinsinmi?
/// false = ilova hozircha butunlay BEPUL (to'lov oynasi chiqmaydi).
/// Keyinchalik pullik qilmoqchi bo'lsangiz true qiling.
const bool kSubscriptionRequired = false;

/// Obunasiz beriladigan bepul testlar soni (faqat kSubscriptionRequired = true bo'lganda ishlaydi).
/// 0 qilsangiz, ilova to'liq pullik bo'ladi (birinchi kirishdayoq to'lov oynasi chiqadi).
const int kFreeTests = 2;

/// To'lov ma'lumotlari (to'lov oynasida ko'rsatiladi).
const String kPayCardNumber = '8600 0000 0000 0000';
const String kPayCardOwner = 'ISM FAMILIYA';

/// Telegram username (@ belgisiz). O'quvchi shu yerga chek va Qurilma ID yuboradi.
const String kAdminTelegram = 'telegram_username';

/// Aktivatsiya kodlarini tekshirish uchun maxfiy so'z.
/// GitHub Secrets (ACTIVATION_SECRET) orqali beriladi, bu yerga yozmang!
const String kActivationSecret =
    String.fromEnvironment('ACTIVATION_SECRET', defaultValue: 'CHANGE_ME');

/// Google AI Studio: foydalanuvchi shu yerdan o'z Gemini kalitini oladi.
const String kGeminiKeyUrl = 'https://aistudio.google.com/apikey';

/// Gemini modellari. Birinchisi ishlamasa (model topilmasa yoki limit tugasa),
/// keyingisi sinab ko'riladi.
const List<String> kGeminiModels = [
  'gemini-2.5-flash',
  'gemini-3.5-flash-lite',
  'gemini-2.5-flash-lite',
  'gemini-3.5-flash',
];

const String kAppVersion = '1.0.0';
