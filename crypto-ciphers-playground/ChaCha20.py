from base64 import b64encode
from Crypto.Cipher import ChaCha20
from Crypto.Random import get_random_bytes



def encode_ChaCha20(plainText):
    with open("key.txt","r") as f:
        content = f.read().strip()
        x, key_hex = content.split("=")
        key = bytes.fromhex(key_hex.strip())

    cipher = ChaCha20.new(key=key)
    ciphertext = cipher.encrypt(plainText)
    nonce = b64encode(cipher.nonce).decode('utf-8')
    ct = b64encode(ciphertext).decode('utf-8')
    
    return ct, nonce




