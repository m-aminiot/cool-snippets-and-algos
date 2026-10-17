import ChaCha20
import os, pwd


crypto_choice = os.getenv("choice","nothing")
plainText = os.getenv("plaintext", "test").encode("utf-8")




if crypto_choice == "chacha20":
    ct, nonce =  ChaCha20.encode_ChaCha20(plainText)
    with open("result.txt","w") as f:
        f.write(f"Cipher text = {ct.hex()} \nNonce = {nonce.hex()}" )

    print(f"Chpher text (hex) = ( {ct.hex()} ) \nNonce (hex) = ( {nonce.hex()} )")




