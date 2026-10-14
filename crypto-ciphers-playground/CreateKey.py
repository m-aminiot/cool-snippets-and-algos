from Crypto.Random import get_random_bytes
import os 


KeySize = int(os.getenv("KeySize",32))
try:    
    key = get_random_bytes(KeySize)
    try:
        with open("key.txt", "w") as f:
            f.write(f"key={key.hex()}")
        print("success! CHECK KEY.TXT :)")
    
    except ExceptionType as EROR:
        print("Key didn't be saved",EROR)

except ExceptionType as EROR:
    print("Key didn't be created!",EROR)





