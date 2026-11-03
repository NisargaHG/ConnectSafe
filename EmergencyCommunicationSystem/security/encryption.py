import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

# 16-byte secret key
SECRET_KEY = b"1234567890123456"


def encrypt_message(message):
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    encrypted = cipher.encrypt(
        pad(message.encode(), AES.block_size)
    )
    return base64.b64encode(encrypted).decode()


def decrypt_message(encrypted_message):
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    decrypted = unpad(
        cipher.decrypt(base64.b64decode(encrypted_message)),
        AES.block_size,
    )
    return decrypted.decode()