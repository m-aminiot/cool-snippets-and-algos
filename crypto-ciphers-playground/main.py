import ChaCha20
import os


crypto_choice = os.getenv("choice","nothing")
plainText = os.getenv("plaintext", "test").encode("utf-8")



if crypto_choice == "chacha20":
    ct, nonce =  ChaCha20.encode_ChaCha20(plainText,)
    print("result: ", ct)

elif crypto_choice == "aegs":
    pass

else:
    pass


