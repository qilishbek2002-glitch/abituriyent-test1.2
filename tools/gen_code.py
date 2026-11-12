"""Aktivatsiya kodi yaratish.

Ishlatish:
    ACTIVATION_SECRET="maxfiy-soz" python3 tools/gen_code.py QURILMA_ID [KUN]

Masalan:
    ACTIVATION_SECRET="maxfiy-soz" python3 tools/gen_code.py K7M2QX9A 30
"""
import hashlib
import hmac
import os
import secrets
import sys

ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def make_code(secret: str, device_id: str, days: int, serial: str = "") -> str:
    dev = device_id.strip().upper()
    if not serial:
        serial = "".join(secrets.choice(ALPHABET) for _ in range(4))
    payload = f"{dev}|{days}|{serial}"
    sig = hmac.new(secret.encode("utf-8"), payload.encode("utf-8"), hashlib.sha256).hexdigest()[:10].upper()
    return f"{dev}-{days:03d}-{serial}-{sig}"


if __name__ == "__main__":
    secret = os.environ.get("ACTIVATION_SECRET", "")
    if not secret or len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    device = sys.argv[1]
    days = int(sys.argv[2]) if len(sys.argv) > 2 else 30
    print(make_code(secret, device, days))
