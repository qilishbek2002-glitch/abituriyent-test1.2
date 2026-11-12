/// Ilova matnlari: [uz, ru, kk] (O'zbek, Rus, Qoraqalpoq)
String currentLang = 'uz';

int _idx() => currentLang == 'ru' ? 1 : (currentLang == 'kk' ? 2 : 0);

String tr(String key, [Map<String, String>? args]) {
  final v = _s[key];
  var out = v == null ? key : v[_idx()];
  if (args != null) {
    args.forEach((k, val) {
      out = out.replaceAll('{$k}', val);
    });
  }
  return out;
}

const Map<String, List<String>> _s = {
  // --- umumiy ---
  'app_title': ["Abituriyent Test", "Абитуриент Тест", "Abituriyent Test"],
  'choose_language': ["Tilni tanlang", "Выберите язык", "Tildi tańlań"],
  'language': ["Til", "Язык", "Til"],
  'yes': ["Ha", "Да", "Awa"],
  'no': ["Yo'q", "Нет", "Yaq"],
  'cancel': ["Bekor qilish", "Отмена", "Biykar etiw"],
  'delete': ["O'chirish", "Удалить", "Óshiriw"],
  'copy': ["Nusxalash", "Копировать", "Kóshiriw"],
  'copied': ["Nusxalandi", "Скопировано", "Kóshirildi"],
  'retry': ["Qayta urinish", "Повторить", "Qayta urınıp kóriw"],
  'home': ["Bosh sahifa", "Главная", "Bas bet"],
  'settings': ["Sozlamalar", "Настройки", "Sazlawlar"],
  'version': ["Versiya", "Версия", "Nusqa"],

  // --- fanlar ---
  'home_subjects': ["Fanlar", "Предметы", "Pánler"],
  'subject_math': ["Matematika", "Математика", "Matematika"],
  'subject_physics': ["Fizika", "Физика", "Fizika"],
  'subject_literature': ["Adabiyot", "Литература", "Ádebiyat"],
  'subject_history': ["Tarix", "История", "Tariyx"],
  'subject_biology': ["Biologiya", "Биология", "Biologiya"],
  'subject_chemistry': ["Kimyo", "Химия", "Ximiya"],
  'subject_mothertongue': ["Ona tili", "Родной язык", "Ana tili"],
  'subject_informatics': ["Informatika", "Информатика", "Informatika"],
  'personal_book': ["Shaxsiy kitob", "Своя книга", "Jeke kitap"],
  'ready_materials': ["Tayyor materiallar", "Готовые материалы", "Tayın materiallar"],
  'textbooks': ["Darsliklar", "Учебники", "Dárslikler"],
  'no_books': [
    "Hozircha bu bo'limda kitoblar yo'q.",
    "Пока в этом разделе нет книг.",
    "Házirshe bul bólimde kitaplar joq."
  ],
  'books_count': ["{n} ta kitob", "Книг: {n}", "{n} kitap"],

  // --- shaxsiy kitoblar ---
  'my_books': ["Mening kitoblarim", "Мои книги", "Meniń kitaplarım"],
  'add_pdf': ["PDF qo'shish", "Добавить PDF", "PDF qosıw"],
  'personal_empty': [
    "PDF kitobingizni qo'shing, undan test tuzib beramiz.",
    "Добавьте свою PDF-книгу, и мы составим по ней тест.",
    "PDF kitabıńızdı qosıń, ol boyınsha test dúzip beremiz."
  ],
  'delete_book_q': ["Kitob o'chirilsinmi?", "Удалить книгу?", "Kitap óshirilsinbe?"],

  // --- test sozlash ---
  'pages_total': ["Sahifalar soni: {n}", "Страниц: {n}", "Betler sanı: {n}"],
  'questions_count': ["Savollar soni", "Количество вопросов", "Sorawlar sanı"],
  'page_range': [
    "Sahifalar oralig'i: {a}–{b}",
    "Диапазон страниц: {a}–{b}",
    "Betler aralıǵı: {a}–{b}"
  ],
  'page_range_hint': [
    "Butun kitob yoki faqat kerakli mavzu sahifalari",
    "Вся книга или только страницы нужной темы",
    "Pútkil kitap yamasa tek kerekli tema betleri"
  ],
  'make_test': ["Test tuzish", "Составить тест", "Test dúziw"],

  // --- yaratish jarayoni ---
  'reading_pdf': ["Kitob o'qilmoqda...", "Читаю книгу...", "Kitap oqılmaqta..."],
  'generating': [
    "Savollar tuzilmoqda: {done}/{total}",
    "Составляю вопросы: {done}/{total}",
    "Sorawlar dúzilmekte: {done}/{total}"
  ],
  'generating_hint': [
    "Biroz kuting, ilovadan chiqmang",
    "Подождите, не закрывайте приложение",
    "Biraz kútiń, qosımshadan shıqpań"
  ],
  'partial': [
    "{n} ta savol tuzildi (so'ralgani: {m})",
    "Составлено вопросов: {n} (запрошено: {m})",
    "{n} soraw dúzildi (soralǵanı: {m})"
  ],

  // --- xatolar ---
  'error_title': ["Xatolik", "Ошибка", "Qátelik"],
  'err_no_text': [
    "Bu PDF'dan matn o'qib bo'lmadi. Ehtimol u skaner qilingan rasm. Matnli PDF tanlang.",
    "Не удалось извлечь текст из этого PDF. Возможно, это скан. Выберите PDF с текстом.",
    "Bul PDF ten tekst oqıp bolmadı. Ol skaner etilgen súwret bolıwı múmkin. Tekstli PDF saylań."
  ],
  'err_pdf_open': [
    "PDF ochilmadi. Fayl buzilgan yoki parol bilan himoyalangan bo'lishi mumkin.",
    "PDF не открылся. Файл повреждён или защищён паролем.",
    "PDF ashılmadı. Fayl buzılǵan yamasa parol menen qorǵalǵan bolıwı múmkin."
  ],
  'err_key_invalid': [
    "API kalit noto'g'ri. Kalitni qayta kiriting.",
    "Неверный ключ API. Введите ключ заново.",
    "API kalit qáte. Kalitti qayta kiritiń."
  ],
  'err_quota': [
    "Gemini limiti tugadi. Birozdan keyin qayta urinib ko'ring.",
    "Лимит Gemini исчерпан. Попробуйте чуть позже.",
    "Gemini limiti tawsıldı. Biraz keyin qayta urınıp kóriń."
  ],
  'err_network': [
    "Internet bilan muammo. Ulanishni tekshiring.",
    "Проблема с интернетом. Проверьте соединение.",
    "Internet penen mashqala. Baylanıstı tekseriń."
  ],
  'err_region': [
    "Gemini ruxsat bermadi (403). Kalit yoki hudud (VPN) bilan bog'liq bo'lishi mumkin.",
    "Gemini отказал в доступе (403). Возможно, дело в ключе или регионе (VPN).",
    "Gemini ruxsat bermedi (403). Kalit yamasa region (VPN) menen baylanıslı bolıwı múmkin."
  ],
  'err_overloaded': [
    "Gemini serveri band. Birozdan keyin qayta urinib ko'ring.",
    "Сервер Gemini перегружен. Попробуйте чуть позже.",
    "Gemini serveri bánt. Biraz keyin qayta urınıp kóriń."
  ],
  'err_bad': [
    "Gemini kutilmagan javob qaytardi. Qayta urinib ko'ring.",
    "Gemini вернул неожиданный ответ. Попробуйте ещё раз.",
    "Gemini kútilmegen juwap qaytardı. Qayta urınıp kóriń."
  ],
  'err_generic': [
    "Savollar tuzib bo'lmadi: {e}",
    "Не удалось составить вопросы: {e}",
    "Sorawlar dúzilmedi: {e}"
  ],

  // --- test ---
  'question_of': ["Savol {i}/{n}", "Вопрос {i}/{n}", "Soraw {i}/{n}"],
  'next': ["Keyingi", "Далее", "Keyingisi"],
  'finish': ["Yakunlash", "Завершить", "Juwmaqlaw"],
  'correct': ["To'g'ri!", "Верно!", "Durıs!"],
  'wrong': [
    "Noto'g'ri. To'g'ri javob: {a}",
    "Неверно. Правильный ответ: {a}",
    "Qáte. Durıs juwap: {a}"
  ],
  'explanation': ["Izoh", "Пояснение", "Túsindirme"],
  'exit_test_q': [
    "Testdan chiqasizmi? Natija saqlanmaydi.",
    "Выйти из теста? Результат не сохранится.",
    "Testten shıǵasızba? Nátiyje saqlanbaydı."
  ],

  // --- natija ---
  'result_title': ["Natija", "Результат", "Nátiyje"],
  'result_score': ["{c} / {n} to'g'ri", "{c} / {n} верно", "{c} / {n} durıs"],
  'mistakes': ["Xatolar tahlili", "Разбор ошибок", "Qátelerdi analizlew"],
  'your_answer': ["Sizning javobingiz", "Ваш ответ", "Sizdiń juwabıńız"],
  'right_answer': ["To'g'ri javob", "Правильный ответ", "Durıs juwap"],
  'no_mistakes': ["Ajoyib! Xato yo'q.", "Отлично! Ошибок нет.", "Ájayıp! Qáte joq."],
  'retry_mistakes': [
    "Xatolarni qayta yechish",
    "Решить ошибки заново",
    "Qátelerdi qayta sheshiw"
  ],
  'retry_all': ["Testni qayta yechish", "Пройти тест заново", "Testti qayta sheshiw"],

  // --- tarix ---
  'history': ["Testlarim", "Мои тесты", "Testlerim"],
  'history_empty': ["Hali test tuzilmagan.", "Тестов пока нет.", "Házirshe test dúzilmegen."],
  'best_result': ["Eng yaxshi: {p}%", "Лучший: {p}%", "Eń jaqsı: {p}%"],
  'questions_short': ["{n} ta savol", "Вопросов: {n}", "{n} soraw"],
  'delete_test_q': ["Test o'chirilsinmi?", "Удалить тест?", "Test óshirilsinbe?"],

  // --- API kalit ---
  'api_key': ["Gemini API kalit", "Ключ Gemini API", "Gemini API kalit"],
  'key_none': ["Kalit kiritilmagan", "Ключ не введён", "Kalit kiritilmegen"],
  'key_saved': ["Kalit saqlangan", "Ключ сохранён", "Kalit saqlanǵan"],
  'key_steps': [
    "1. «Kalit olish» tugmasini bosing — Google AI Studio ochiladi.\n2. Google akkauntingiz bilan kiring.\n3. «Create API key» tugmasini bosing.\n4. Kalitni nusxalab (copy), pastdagi maydonga qo'ying.\n\nGoogle odatda shaxsiy foydalanish uchun bepul limit beradi. Kalit faqat sizning telefoningizda saqlanadi.",
    "1. Нажмите «Получить ключ» — откроется Google AI Studio.\n2. Войдите в аккаунт Google.\n3. Нажмите «Create API key».\n4. Скопируйте ключ и вставьте в поле ниже.\n\nGoogle обычно даёт бесплатный лимит для личного использования. Ключ хранится только на вашем телефоне.",
    "1. «Kalit alıw» túymesin basıń — Google AI Studio ashıladı.\n2. Google akkauntıńız benen kiriń.\n3. «Create API key» túymesin basıń.\n4. Kalitti kóshirip (copy), tómendegi maydanǵa qoyıń.\n\nGoogle kóbinese jeke paydalanıw ushın biypul limit beredi. Kalit tek sizdiń telefonıńızda saqlanadı."
  ],
  'get_key': ["Kalit olish", "Получить ключ", "Kalit alıw"],
  'paste_key': ["Kalitni shu yerga qo'ying", "Вставьте ключ сюда", "Kalitti usı jerge qoyıń"],
  'paste': ["Qo'yish", "Вставить", "Qoyıw"],
  'save_check': ["Saqlash va tekshirish", "Сохранить и проверить", "Saqlaw hám tekseriw"],
  'key_ok': ["Kalit ishlayapti ✓", "Ключ работает ✓", "Kalit isleydi ✓"],
  'key_remove': ["Kalitni o'chirish", "Удалить ключ", "Kalitti óshiriw"],
  'need_key_banner': [
    "Test tuzish uchun Gemini API kalit kerak",
    "Для составления тестов нужен ключ Gemini API",
    "Test dúziw ushın Gemini API kalit kerek"
  ],
  'enter': ["Kiritish", "Ввести", "Kiritiw"],
  'cannot_open_link': [
    "Havolani ochib bo'lmadi",
    "Не удалось открыть ссылку",
    "Siltemeni ashıp bolmadı"
  ],

  // --- obuna ---
  'subscription': ["Obuna", "Подписка", "Abuna"],
  'tariff_monthly': ["Oylik tarif", "Тариф на месяц", "Aylıq tarif"],
  'price_month': ["{p} so'm / oy", "{p} сум / месяц", "{p} swm / ay"],
  'pay_steps': [
    "1. {p} so'mni quyidagi kartaga o'tkazing.\n2. «Telegramga yozish» tugmasini bosib, to'lov chekini va Qurilma ID'ni yuboring.\n3. Sizga aktivatsiya kodi beriladi — uni pastga kiriting.",
    "1. Переведите {p} сум на карту ниже.\n2. Нажмите «Написать в Telegram» и отправьте чек и ID устройства.\n3. Вам пришлют код активации — введите его ниже.",
    "1. {p} swm di tómendegi kartaǵa ótkeriń.\n2. «Telegramǵa jazıw» túymesin basıp, tólem chegin hám Qurılma ID ni jiberiń.\n3. Sizge aktivlestiriw kodı beriledi — onı tómenge kiritiń."
  ],
  'card_number': ["Karta raqami", "Номер карты", "Karta nomeri"],
  'device_id': ["Qurilma ID", "ID устройства", "Qurılma ID"],
  'write_tg': ["Telegramga yozish", "Написать в Telegram", "Telegramǵa jazıw"],
  'enter_code': ["Aktivatsiya kodi", "Код активации", "Aktivlestiriw kodı"],
  'activate': ["Faollashtirish", "Активировать", "Aktivlestiriw"],
  'code_ok': [
    "Obuna faollashdi! +{d} kun.",
    "Подписка активирована! +{d} дн.",
    "Abuna aktivlestirildi! +{d} kún."
  ],
  'code_bad': ["Kod noto'g'ri", "Неверный код", "Kod qáte"],
  'code_other_device': [
    "Bu kod boshqa qurilma uchun",
    "Этот код для другого устройства",
    "Bul kod basqa qurılma ushın"
  ],
  'code_used': ["Bu kod ishlatilgan", "Этот код уже использован", "Bul kod isletilgen"],
  'sub_active': [
    "Obuna faol: {d} kun qoldi",
    "Подписка активна: осталось {d} дн.",
    "Abuna aktiv: {d} kún qaldı"
  ],
  'sub_none': ["Obuna yo'q", "Нет подписки", "Abuna joq"],
  'trial_left': [
    "Bepul testlar: {n} ta qoldi",
    "Бесплатных тестов: {n}",
    "Biypul testler: {n} qaldı"
  ],
  'trial_over': [
    "Bepul testlar tugadi. Davom etish uchun obuna bo'ling.",
    "Бесплатные тесты закончились. Оформите подписку, чтобы продолжить.",
    "Biypul testler tawsıldı. Dawam etiw ushın abuna bolıń."
  ],
  'subscribe': ["Obuna bo'lish", "Оформить подписку", "Abuna bolıw"],
};
