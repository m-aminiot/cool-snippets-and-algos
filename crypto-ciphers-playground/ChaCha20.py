from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305
import os


def encode_ChaCha20(plainText):
    with open("key.txt","r") as f:
        content = f.read().strip()
        x, key_hex = content.split("=")
        key = bytes.fromhex(key_hex.strip())
    chacha = ChaCha20Poly1305(key)
    nonce = os.urandom(12)
    ct = chacha.encrypt(nonce, plainText, b"")
    return ct, nonce

   




