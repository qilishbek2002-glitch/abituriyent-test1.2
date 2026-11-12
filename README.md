# Abituriyent Test — APK yig'ish qo'llanmasi

Ilova: o'quvchi PDF kitob tanlaydi (yoki o'zi yuklaydi), Gemini shu kitobdan 10/30/50/100 ta test tuzadi.
Tillar: O'zbek, Qoraqalpoq, Rus. Obuna: oyiga 15 000 so'm (aktivatsiya kodi orqali).

## 0. Bepul rejim
Hozir ilova **bepul**: `lib/config.dart` da `kSubscriptionRequired = false`. Pullik qilmoqchi bo'lsangiz `true` qiling (obuna oynasi va kodlar tizimi tayyor). Har bir fan ichida (Tayyor materiallar / Darsliklar) «PDF qo'shish» tugmasi bor: o'quvchi o'z PDF'ini shu fanga qo'shadi.

## 1. Sozlamalar (`lib/config.dart`)
- `kPayCardNumber`, `kPayCardOwner` — to'lov kartangiz
- `kAdminTelegram` — Telegram username (@ siz)
- `kFreeTests` — bepul testlar soni (0 = darhol to'lov)

## 2. Kitoblarni qo'shish
PDF fayllarni shu papkalarga tashlang (fayl nomi lotin harfida, bo'shliqsiz, masalan `Algebra_9.pdf`):

```
assets/books/math/textbooks/      assets/books/math/materials/
assets/books/physics/...          assets/books/literature/...
assets/books/history/...          assets/books/biology/...
assets/books/chemistry/...        assets/books/mothertongue/...
assets/books/informatics/...
```
`textbooks` = «Darsliklar», `materials` = «Tayyor materiallar». Fan rasmlari ixtiyoriy: `assets/subjects/math.jpg` va hokazo (rasm bo'lmasa, ikonka chiqadi).
Eslatma: ilovaga ko'p katta PDF qo'ysangiz APK hajmi oshadi (GitHub limiti: bitta fayl 100 MB).

## 3. GitHub'da APK qilish
1. GitHub'da yangi repository oching va shu papkadagi hamma fayllarni yuklang (`.github` papkasi ham!).
2. Repository → Settings → Secrets and variables → Actions → New repository secret:
   - Name: `ACTIVATION_SECRET`
   - Value: o'zingiz o'ylab topgan uzun maxfiy so'z (masalan 20+ belgi). **Hech kimga bermang.**
3. Actions → Build APK → Run workflow. 5–10 daqiqadan so'ng APK:
   - Actions → shu run → Artifacts → `abituriyent-test-apk`, yoki
   - Releases bo'limida `app-release.apk`.

## 4. Obuna kodini berish
O'quvchi to'laydi → Telegramga chek va **Qurilma ID** yuboradi → siz kod yaratasiz:
- Telefondan: `tools/kod_generator.html` faylini brauzerda oching, maxfiy so'z + Qurilma ID + kun kiriting.
- Yoki kompyuterda: `ACTIVATION_SECRET="maxfiy" python3 tools/gen_code.py QURILMA_ID 30`

Kod faqat o'sha telefon uchun ishlaydi va bir marta qo'llanadi.

## 5. Gemini kaliti
Har bir o'quvchi o'z kalitini oladi: ilovada «Kalit olish» → Google AI Studio → «Create API key» → nusxalab ilovaga qo'yadi. Kalit faqat o'quvchining telefonida saqlanadi. Modellar ro'yxati `kGeminiModels` da; Google biror modelni o'chirsa, shu ro'yxatni yangilang.

## Cheklovlar (bilib qo'ying)
- Skaner qilingan (rasm ko'rinishidagi) PDF'lardan matn olib bo'lmaydi — ilova buni xabar qiladi.
- Matematika/fizika/kimyo formulalari PDF'dan buzilib chiqishi mumkin; sifat kitobga bog'liq.
- Obuna qurilmada saqlanadi: o'quvchi ilova ma'lumotini tozalasa, obuna yo'qoladi (siz qayta kod berasiz). Kodlar maxfiy so'z orqali tekshiriladi — oddiy foydalanuvchilar uchun yetarli, lekin APK'ni maxsus tahlil qiladigan odamga qarshi 100% himoya emas. Jiddiy himoya kerak bo'lsa, keyin server qo'shiladi.
- Darsliklarni tarqatishdan oldin ularning mualliflik huquqini tekshiring.
- PDF o'qish uchun `syncfusion_flutter_pdf` ishlatiladi (Community litsenziya yakka tartibdagi va kichik jamoalar uchun bepul).
