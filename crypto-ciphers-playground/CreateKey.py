from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305
import os 



try:    
    key = ChaCha20Poly1305.generate_key()
    try:
        with open("key.txt", "w") as f:
            f.write(f"key={key.hex()}")
        print("success! CHECK KEY.TXT :)")
    
    except ExceptionType as EROR:
        print("Key didn't be saved",EROR)

except ExceptionType as EROR:
    print("Key didn't be created!",EROR)





