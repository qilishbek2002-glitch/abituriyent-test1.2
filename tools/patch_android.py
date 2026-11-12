"""flutter create dan keyin Android manifestga kerakli sozlamalarni qo'shadi:
- INTERNET ruxsati (release APK da bo'lmasa, Gemini ishlamaydi)
- havolalarni ochish uchun <queries>
- ilova nomi
"""
import pathlib
import re

p = pathlib.Path("android/app/src/main/AndroidManifest.xml")
s = p.read_text(encoding="utf-8")

if "android.permission.INTERNET" not in s:
    s = s.replace(
        "<application",
        '<uses-permission android:name="android.permission.INTERNET"/>\n    <application',
        1,
    )

intents = (
    '<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>\n'
    '        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tg"/></intent>'
)
if "<queries>" in s:
    s = s.replace("<queries>", "<queries>\n        " + intents, 1)
else:
    s = s.replace(
        "</manifest>",
        "    <queries>\n        " + intents + "\n    </queries>\n</manifest>",
        1,
    )

s = re.sub(r'android:label="[^"]*"', 'android:label="Abituriyent Test"', s, count=1)
p.write_text(s, encoding="utf-8")
print("AndroidManifest.xml yangilandi")
