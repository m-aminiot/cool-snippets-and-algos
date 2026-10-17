# 🔐 Modern Symmetric Cryptography: From XOR to AES-GCM & ChaCha20-Poly1305

> **A no-nonsense, dev-friendly deep dive into modern symmetric encryption (English Edition).**  
> Learn how stream & block ciphers actually work under the hood, why nonce reuse wrecks everything, what AEAD/AAD really means, and how to write secure cryptography code in Python without shooting yourself in the foot.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
[![Topic: Cryptography](https://img.shields.io/badge/topic-cryptography-green.svg)](#)

---

## ⚡ TL;DR (Quick Overview)

- **Block Cipher vs. Stream Cipher:** AES is a 128-bit block cipher that always needs an operational mode (like GCM). ChaCha20 is a stream cipher that natively emits a keystream.
- **The Core Trick:** Modern stream encryption is just `Ciphertext = Plaintext ⊕ Keystream`. The keystream is **deterministic and pseudo-random**, generated on-the-fly for any length needed.
- **Nonce & Counter:** A nonce is a *public, single-use* value per key (never simply appended to the key). The counter is an *internal block index*. If you repeat a nonce with the same key, `C1 ⊕ C2 = P1 ⊕ P2`, completely destroying confidentiality (and in GCM, it compromises the authentication key!).
- **AEAD & AAD:** Don't encrypt without authentication. AES-GCM and ChaCha20-Poly1305 are both AEAD schemes. AAD (Associated Data) is authenticated but left in plaintext (great for network routing headers).
- **Session Cookies:** Signed cookies (e.g., Flask default `itsdangerous`) prevent tampering, but they are **not encrypted** by default.

---

## 📦 What's Inside?

1. **Intuitive Mental Models:** Real-world developer analogies, bitwise XOR breakdowns, and zero dry math fluff.
2. **Crucial Gotchas & Mythbusters:** Clarifying keystream generation, counter limits, nonce handling, and MAC vs. Digital Signatures.
3. **Production-Ready Python Snippets:** Practical examples with `cryptography` for AES-GCM and ChaCha20-Poly1305.
4. **End-of-Tutorial Quiz & Explanations:** 12 questions (multiple-choice + short answers) to test your grasp.

---

## 🛠️ Prerequisites

- Basic understanding of Python syntax.
- Basic familiarity with bits, bytes, and binary representation.
- Install the standard cryptographic toolkit:
  ```bash
  pip install cryptography flask
  ```

### 🚀 Quick Start (Copy-Paste Ready)

```python
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# 1. Generate a 256-bit cryptographically secure key
key = AESGCM.generate_key(bit_length=256)

# 2. A 96-bit unique nonce for this specific message (NEVER REUSE WITH SAME KEY!)
nonce = os.urandom(12)

# 3. Sensitive data + unencrypted authenticated header (AAD)
plaintext = b"Super sensitive developer secret!"
associated_data = b"packet-id:42;route:eu-central"

# 4. Encrypt & Authenticate
aesgcm = AESGCM(key)
ciphertext = aesgcm.encrypt(nonce, plaintext, associated_data)

# 5. Decrypt & Verify Integrity
decrypted = aesgcm.decrypt(nonce, ciphertext, associated_data)
print("Decrypted:", decrypted.decode())
```

---

## 🎯 What Will You Learn?

After reading this guide, you will be able to:

1. Explain the difference between **symmetric** and **asymmetric** encryption to anyone, over coffee.
2. State exactly how a **block cipher** differs from a **stream cipher**, and why bare AES is nothing on its own!
3. Demolish the mysteries of **XOR** and the **keystream** — and have fun doing it.
4. Understand precisely what **nonce** and **counter** do, and clear up the most common misconceptions about them.
5. Say with your eyes closed why **nonce reuse** is basically suicide for a system's security.
6. Tell apart an authentication **tag / MAC** from a **digital signature** — so you never mix them up again.
7. Grasp the fancy concepts of **AEAD** and **AAD** with concrete, real examples (Flask cookies and network headers).
8. Make an informed choice between **AES-GCM** and **ChaCha20-Poly1305** when writing code, with reasons.
9. Keep a practical checklist handy so you never ship a crypto security bug again.

---

## 📚 Friendly Terminology

Before we dive into code, let's agree on a shared language:

| Term | Symbol / English | In plain developer words |
|---|---|---|
| **Key** | Key | The secret password only the sender and receiver hold. |
| **Symmetric Encryption** | — | The same key locks and unlocks! Fast and painless. |
| **Block Cipher** | — | A meat grinder that eats fixed-size chunks (e.g., 16-byte / 128-bit blocks). |
| **Stream Cipher** | — | Like a water hose: however much data you feed it, it XORs bit-by-bit with a pseudo-random flow. |
| **Keystream** | KS | A pseudo-random bit sequence derived from key + nonce. |
| **XOR** | ⊕ | The magic of crypto: a trivial bitwise operator that powers modern encryption. |
| **Nonce** | Number used ONCE | A value that must be used **only once** per key; it's fine for it to be public. |
| **Counter** | Counter | An internal block index, counting 0, 1, 2… to build consecutive keystream blocks. |
| **Tag / MAC** | Tag | A hologram seal on a parcel: flip one bit of data and it screams. |
| **AEAD** | Authenticated Encryption with Associated Data | All-in-one package: confidentiality + integrity in a single pass! |
| **AAD** | Associated Data | Data that stays in the clear (like a packet header) but is sealed so nobody can swap it. |
| **IV** | Initialization Vector | Practically the nonce's twin cousin in several operational modes. |

---

## 🔀 The Showdown: Block Cipher vs. Stream Cipher

### 1. Block Cipher — The Undisputed King: AES
- **Fixed 128-bit blocks:** AES always, under every circumstance, wants 128-bit (16-byte) chunks. If your data is 17 bytes or 10 bytes, AES alone chokes!
- **Fixing a common developer mistake:** Everybody says "I encrypted my message with AES." That sentence is fundamentally incomplete! **AES by itself has no method for encrypting a particular message.** AES is just an engine. You must always say which **operational mode** you're using; e.g., AES-GCM, AES-CTR, or Lord-knows-what AES-CBC.
- **Strength:** Nearly every modern CPU (Intel, AMD, Apple Silicon) ships hardware instructions called **AES-NI**, making AES processing blazing fast.

### 2. Stream Cipher — Agile and Speedy: ChaCha20
- **Continuous keystream:** ChaCha20 builds an endless string of pseudo-random bits (the keystream) from key + nonce and pours it over your data.
- **No block-size drama:** Whether your message is 3 bytes or 3 gigabytes, exactly that much keystream is produced and then it's over. No padding, no chunking headaches.
- **Strength:** In **pure software** (where there's no AES hardware acceleration — cheap phones, routers, embedded boards), this algorithm is extremely fast and power-efficient.

### Quick comparison table:

| Feature | AES (block) | ChaCha20 (stream) |
|---|---|---|
| **Processing unit** | Fixed 128-bit blocks | Continuous stream of bits/bytes |
| **Depends on a mode?** | Yes — useless without one (GCM, CTR…) | It *is* a stream cipher by nature |
| **Speed without hardware help** | Moderate | ⚡ Blazingly fast in software |
| **Speed with AES-NI** | 🚀 Rocket! | Fast and excellent |
| **Where is it used?** | TLS, encrypted disks (BitLocker/LUKS) | Android/mobile TLS, WireGuard, SSH |

---

## ⚙️ Under the Hood: The Magic of XOR and the Keystream

Folks, all the beauty and subtlety of stream ciphers and pseudo-stream modes (like CTR) reduces to one two-character operator: **XOR (⊕)**!

Encryption formula:
```text
Ciphertext = Plaintext ⊕ Keystream
```

Decryption formula:
```text
Plaintext = Ciphertext ⊕ Keystream
```

See it? XOR the same keystream into the ciphertext again and the original message comes back, byte for byte! That's the beauty of math.

### Let's try it by hand (educational XOR example):

> ⚠️ **Friendly warning:** This tiny table is only here to train your eyes on how bits behave. In the real world the keystream is hundreds of thousands of bits long and is produced by super-secure algorithms!

```text
Plaintext:   1 0 1 1 0 1 0 0
Keystream:   0 1 1 0 1 0 1 1
─────────────────────────────────────────────
XOR (⊕) = :  1 1 0 1 1 1 1 1   ← Ciphertext
```

Let's verify:
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `1 ⊕ 1 = 0`
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `0 ⊕ 1 = 1`

Now XOR the ciphertext with the same keystream again:
```text
Ciphertext:  1 1 0 1 1 1 1 1
Keystream:   0 1 1 0 1 0 1 1
─────────────────────────────────────────────
XOR again:   1 0 1 1 0 1 0 0   ← the original plaintext is back! 🎉
```

### A few very important notes you must not screw up:
1. **The keystream is *pseudo-random*, not truly random:**  
   Why? Because if it were genuinely random, how would the receiver regenerate the exact same bits to decrypt your message?! This keystream is built by a fully deterministic function of (key + nonce); i.e., the same inputs always produce exactly the same bit string.
2. **Key size has nothing to do with message length:**  
   Your key may be 256 bits (32 bytes), while your message is a 2-gigabyte video. The stream algorithm produces as many keystream bits as your message needs and XORs them bit by bit.

---

## 🔢 The Nonce and Counter Story: What Do These Fellows Actually Do?

### What exactly is a Nonce?
- Short for **Number used ONCE** — "a number that is consumed exactly one time".
- **A nonce does NOT need to be secret!** You can print it in huge fonts or send it over the wire next to the ciphertext. The only thing that matters is that it is **never repeated**.
- **Fixing a common wrong idea:** The nonce is *not appended* to the key! It enters the algorithm's internal state as an independent, separate parameter.
- **Reason for existence:** Since the keystream is derived from key + nonce, if you don't change the nonce, every message gets exactly the same keystream — catastrophe!

### What is the Counter?
- In algorithms like AES-GCM or ChaCha20, when processing a long message the keystream is split into consecutive blocks. The counter (block 0, block 1, block 2…) tells the algorithm which part of the message it's processing.
- **Key point:** the counter is an internal block-position variable; **it is not your savior if you reuse a nonce!** If you repeat the nonce, the counter simply restarts at 0, 1, 2 … and the entire keystream repeats.
- Also watch out for counter overflow; in GCM, a single nonce allows encrypting at most about 64 GB.

---

## ☠️ Why Nonce Reuse Is a Disaster (The Nonce-Reuse Disaster)

Suppose you have two important messages: `P1` and `P2`.  
A lazy developer used the same key and the same nonce for both!  
Here is what happens:
```text
C1 = P1 ⊕ KS
C2 = P2 ⊕ KS
```
(where `KS` is that shared keystream)

Now, if an attacker sitting in the middle of the network XORs `C1` and `C2`, what happens?
```text
C1 ⊕ C2 = (P1 ⊕ KS) ⊕ (P2 ⊕ KS) = P1 ⊕ P2
```
Boom! 💥  
The keystream completely cancels out of the equation! The attacker now holds `P1 ⊕ P2`. If the attacker can even guess a few words of one message (e.g., knows messages start with `{"status":`), the second message falls immediately!

- This disaster exists in every stream-like mode (CTR, GCM, ChaCha20).
- **With AES-GCM it's even worse:** nonce reuse not only destroys confidentiality, it also leaks the authentication subkey, letting the attacker forge valid tags for themselves!
- **Golden rule:** with a given key, **never, under any circumstances**, repeat a nonce.

---

## 🏷️ MAC/Tag vs. Digital Signature

This is where tons of candidates blow up in job interviews! Let's see the difference cleanly:

| Feature | Tag / MAC (e.g., Poly1305 or HMAC) | Digital Signature (e.g., Ed25519 or RSA) |
|---|---|---|
| **Key type** | **One shared symmetric key** | Asymmetric key pair (private key signs + public key verifies) |
| **Who can verify?** | Only whoever holds the shared key | **The whole world**, with your public key |
| **Non-repudiation** | ❌ No (the peer also has the key and could forge tags) | ✅ Yes (only you held the private key, so it's legally binding!) |
| **Speed** | ⚡ Extremely fast and light | Relatively heavier and slower |
| **Typical use** | Secure symmetric channels, AEAD, network packets | Authentication, document & software-update signing, SSL certificates |

**Friendly conclusion:** a tag/MAC is for making sure your data wasn't tampered with in transit, but it can't be presented in court as an official signature, because the other side holds the same key!

---

## 🧩 The Big Secret of AEAD and AAD: The Modern Savior

### The AEAD concept: encryption AND watching at the same time!
In the old days developers encrypted data (say with CBC) and then separately appended a hash or HMAC. Because they kept getting the order wrong, famous attacks like Padding Oracle appeared.  
Security experts invented a concept called **AEAD** (short for Authenticated Encryption with Associated Data): a single algorithm that:
1. Makes your data secret (encrypts it).
2. Produces an authentication tag so that anyone who touches the data gets an error and is rejected.
3. Has the standard output: `(nonce, ciphertext, tag)`

**Cool fact:** both **AES-GCM** and **ChaCha20-Poly1305** are standard AEAD algorithms.

### So what does AAD mean here?
Sometimes you have data that you **don't want encrypted** (because, say, a network router or web server must read it to route packets), but you **do want to be sure an attacker doesn't modify it**!  
That's called **AAD (Associated Authenticated Data)**:
- It participates in the tag computation.
- Yet it is transmitted in the clear.

### Example 1: Flask Session Cookie — watch out!
Flask signs its session cookies with the server key (`SECRET_KEY`) by default:

```python
from flask import Flask, session

app = Flask(__name__)
# Never hardcode the key, my friend! Read it from an environment variable
app.secret_key = "یک-کلید-طولانی-و-تصادفی"

@app.route("/login")
def login():
    session["username"] = "sara"
    session["role"] = "admin"
    return "Logged in, champ!"
```

**Notes and common developer pitfalls:**
- Flask's default session cookie is **NOT encrypted; it is only signed.** A user can decode the cookie content in their browser and read it! They just can't change `role` to `superadmin` because the validation tag would break.
- So never put sensitive data (user passwords, card numbers…) in a normal cookie; keep sensitive data server-side (e.g., in Redis), or actually encrypt it with an AEAD scheme.
- Ordinary IP headers on the network create no cryptographic authenticity unless the protocol feeds them into AAD explicitly.

### Example 2: Network Header in TLS 1.3
In modern protocols like TLS 1.3 or QUIC:
```text
AAD        = record header (sequence number + packet type)  ← visible so routers can read it, but sealed
Ciphertext = encrypted user data
Tag        = AEAD authentication tag
```
If an attacker changes a packet's sequence number in flight to replay an old packet, the tag becomes invalid and the packet is instantly dropped!

---

## ⚔️ Technical and Friendly Comparison: AES-GCM vs. ChaCha20-Poly1305

| Criterion | AES-GCM | ChaCha20-Poly1305 |
|---|---|---|
| **Internals** | AES block engine in CTR mode + GHASH | ChaCha20 stream cipher + Poly1305 tag maker |
| **Structure type** | Standard, formal AEAD | Standard, modern AEAD |
| **Standard nonce length** | 96 bits (12 bytes) | 96 bits (12 bytes) |
| **Tag length** | 128 bits (16 bytes) | 128 bits (16 bytes) |
| **Key length** | 128 or 256 bits | 256 bits |
| **Speed with hardware (AES-NI)** | ⚡ Extremely fast | Very good |
| **Speed on ordinary CPU / mobile** | Rather lazy (GHASH especially) | ⚡ Extremely fast and efficient |
| **Nonce-reuse danger** | Fatal! (message leak + tag-key leak) | Very dangerous (XOR leaks plaintexts) |
| **Famous use cases** | Enterprise standards, banking, TLS servers | WireGuard VPN, Android, SSH |

### Which one should I pick for my project?
- **If you code on Linux servers or modern systems:** go with **AES-GCM**.
- **If you write for mobile, Raspberry Pi, IoT, or client apps:** your first and last choice is **ChaCha20-Poly1305**.

---

## 💻 Clean Implementation in Python with the `cryptography` Library

Let's write some real code. Here's the clean, standard version:

```python
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM, ChaCha20Poly1305

# 1. A secure 256-bit key from the OS CSPRNG
master_key = os.urandom(32)

# 2. A 12-byte (96-bit) nonce — golden rule: a fresh one every time!
nonce = os.urandom(12)

# 3. Our confidential data
secret_message = "Buddy, this is a confidential message no hacker should see!".encode('utf-8')

# 4. Header data (AAD): authenticated but not encrypted
metadata = b"user_id:1001;action:transfer"

# ================================
# Method 1: AES-GCM
# ================================
aesgcm_cipher = AESGCM(master_key)
# Encrypt while attaching the AAD
encrypted_box = aesgcm_cipher.encrypt(nonce, secret_message, metadata)

# Decrypt with automatic verification
decrypted_msg = aesgcm_cipher.decrypt(nonce, encrypted_box, metadata)
print("AES-GCM result:", decrypted_msg.decode('utf-8'))


# ================================
# Method 2: ChaCha20-Poly1305
# ================================
chacha_cipher = ChaCha20Poly1305(master_key)
# For the next message, definitely create a fresh nonce!
new_nonce = os.urandom(12)
encrypted_box_chacha = chacha_cipher.encrypt(new_nonce, secret_message, metadata)

# Decrypt
decrypted_chacha = chacha_cipher.decrypt(new_nonce, encrypted_box_chacha, metadata)
print("ChaCha20 result:", decrypted_chacha.decode('utf-8'))
```

> 💡 **Note:** notice that if you change even a single character of `metadata` during decryption, Python immediately raises `cryptography.exceptions.InvalidTag` and returns no data at all. That means complete security!

---

## ✅ Golden Checklist: How to Never Ship a Security Bug

Before you push your code, run through this list:

- [ ] **Don't reinvent the wheel:** never write your own crypto algorithm! Use standard, audited libraries like Python's `cryptography` or `libsodium`.
- [ ] **Be truly random:** for keys and nonces use only the system CSPRNG (`os.urandom` or `secrets`), not the sketchy built-in `random` module!
- [ ] **A nonce is single-use:** with a fixed key, never use a nonce twice.
- [ ] **Always AEAD:** the era of raw modes is over; use only modern AEAD modes (AES-GCM or ChaCha20-Poly1305).
- [ ] **Seal metadata with AAD:** if you have a header, version number, or metadata, pass it as AAD so it can't be tampered with.
- [ ] **Never commit keys to git:** keys belong in environment variables or secret managers (like HashiCorp Vault).
- [ ] **Key rotation:** after a certain volume of encryption or a few months, rotate your keys.
- [ ] **Mind the cookies:** remember, a signed session cookie is not an encrypted one.

---

## 📝 Summary

- **Symmetric encryption:** one shared key for locking and unlocking; fast, efficient, and the backbone of bulk data transfer.
- **AES is a block cipher and needs company:** it must always be used with an operational mode (like GCM), while **ChaCha20 is inherently stream-based.**
- **The heart of stream ciphers is XOR:** with a key and a nonce, the keystream is generated pseudo-randomly and deterministically, stretched to the message length.
- **Nonce reuse equals disaster:** because `C1 ⊕ C2 = P1 ⊕ P2`, and in GCM it even leaks the authentication key!
- **A MAC tag is not a digital signature:** tags use symmetric keys and are non-repudiable-nothing, while digital signatures are asymmetric and legally binding documents.
- **AEAD is the king of modern crypto:** full security (confidentiality + integrity) in one tidy package; use AAD to protect your metadata too.

---

## 🧪 Final Quiz: Let's See How Many of You Survive!

### Part 1: Multiple-Choice Questions

**1. Which category does the AES algorithm inherently belong to?**  
- A) Stream cipher  
- B) Block cipher with 128-bit blocks  
- C) Cryptographic hash function  
- D) Asymmetric digital signature scheme  

**2. The ChaCha20 algorithm is which type of algorithm?**  
- A) Block cipher  
- B) Key derivation function (KDF)  
- C) Stream cipher  
- D) Key exchange algorithm  

**3. If the same key and a repeated nonce are used for two different messages in CTR mode, what is the XOR of the two ciphertexts?**  
- A) The main key is leaked  
- B) It equals the XOR of the two original plaintexts (`P1 ⊕ P2`)  
- C) A new nonce is computed  
- D) Nothing bad happens, because the counter differs  

**4. Which option accurately describes the "keystream"?**  
- A) A truly random, cosmic bit string with no formula  
- B) Exactly as long as the input key  
- C) Pseudo-random and fully deterministic, built from key and nonce, generated as needed  
- D) It must be manually appended to the key before processing  

**5. What is the structural difference between a MAC tag and a digital signature?**  
- A) A MAC tag is more secure than a digital signature  
- B) A tag is made and checked with a shared symmetric key, while a digital signature uses an asymmetric key pair and is provable to third parties  
- C) A digital signature has no private key at all  
- D) There is no difference; they're just different marketing names  

**6. How is Associated Authenticated Data (AAD) processed?**  
- A) It is fully encrypted and authenticated  
- B) It is only authenticated and stays in plaintext  
- C) It is neither encrypted nor authenticated  
- D) It replaces the nonce in the algorithm  

**7. Which algorithms fully provide the AEAD property?**  
- A) Only AES-GCM  
- B) Only ChaCha20-Poly1305  
- C) Both AES-GCM and ChaCha20-Poly1305  
- D) Only AES-CBC without a MAC code  

**8. What level of protection does Flask's default session cookie provide?**  
- A) Full confidentiality and encryption of the cookie's data  
- B) Integrity and authenticity only (tamper protection); its content is readable by the user  
- C) Hardware authentication based on the user's IP address  
- D) No protection at all; it's sent as plain text  

### Part 2: Short-Answer & Conceptual Questions

**9.** Why is it completely fine for a nonce to be public or leaked, yet so terrifying to reuse?  
**10.** Suppose the nonce is repeated — can an incrementing counter save us from disaster? Why or why not?  
**11.** In a TLS network record, what's the difference between the ciphertext part and the AAD part?  
**12.** In which hardware or deployment scenarios should you prefer ChaCha20-Poly1305 over AES-GCM?  

---

## 🔑 Answer Key & Analysis

**1. (B)** — AES is a 128-bit block cipher and in practice always requires an operational mode such as GCM.  
**2. (C)** — ChaCha20 is a modern stream cipher.  
**3. (B)** — with a repeated nonce, the produced keystream is identical, so XORing the two ciphertexts yields `C1 ⊕ C2 = P1 ⊕ P2`.  
**4. (C)** — the keystream is pseudo-random and deterministic so both parties reach the same bit string from the same inputs; its length is generated on demand for the message.  
**5. (B)** — a MAC tag uses a shared symmetric key and therefore has no non-repudiation, while a digital signature is produced with an asymmetric key pair and is provable to a third-party arbiter.  
**6. (B)** — AAD participates in the tag so it can't be tampered with, but its content isn't encrypted so intermediate systems (like routers) can still read it.  
**7. (C)** — both AES-GCM and ChaCha20-Poly1305 are standard AEAD algorithms.  
**8. (B)** — Flask's default cookie is signed with `itsdangerous`; tampering is detected, but the data inside is readable, not confidential.  
**9.** The nonce is not meant to be secret — even the receiver must see it to place the cipher machine in exactly the same state. But it must be unique, because all of the algorithm's security rests on the assumption that each `(Key, Nonce)` pair yields a unique keystream. Reuse it and `KS` repeats and confidentiality is destroyed.  
**10.** No! The counter is merely an internal block index within one session. Given the same `(Key, Nonce)` pair, the counter restarts from its initial value, so exactly the same repeated keystream is produced.  
**11.** The ciphertext is secret and no observer understands it, while AAD is open and readable (e.g., a packet header containing a sequence number). Both feed the final tag, so the smallest change in the AAD invalidates the whole packet.  
**12.** On processors lacking AES-NI hardware instructions (microcontrollers, cheap phones, Raspberry Pi, some VMs), ChaCha20-Poly1305 runs much faster in pure software and burns less battery and resources.  

---

> 🎉 **Thanks for sticking around to the end!**  
> You now know modern symmetric crypto fundamentals like a battle-hardened engineer. If you want to go deeper, we recommend studying **Diffie-Hellman key exchange** and **XChaCha20 encryption modes with a 192-bit nonce**!

---
---

# 🇮🇷 بخش فارسی: آموزش خودمانی و صفر تا صد رمزنگاری متقارن

خب رفقا، دم همگی گرم که وقت گذاشتید تا یک‌بار برای همیشه رمزنگاری متقارن مدرن رو اصولی، جذاب و بدون فرمول‌های وحشتناک ریاضی یاد بگیرید.  
این یادداشت‌ها حاصل گشت‌وگذار و غرق شدن تو دنیای واقعی کریپتوگرافیه؛ چیزایی که هر دولوپر و مهندس بک‌اند/دواپس باید تو جعبه‌ابزارش داشته باشه تا یه وقت توی پروداکشن سوتی نده و دیتای کاربرا رو به باد فنا نده!

بزن بریم از ریشه داستان رو شخم بزنیم. 🚀

---

## 🎯 قراره ته این ماجرا چی یاد بگیریم؟

بعد خوندن این راهنما، با خیال راحت می‌تونید:
1. مثل آب خوردن فرق رمزنگاری **متقارن (Symmetric)** و **نامتقارن (Asymmetric)** رو به هر کسی توضیح بدید.
2. دقیقاً بگید فرق **رمز بلوکی (Block Cipher)** با **رمز جریانی (Stream Cipher)** چیه و چرا AES تنهایی هیچی نیست!
3. مغز ماجرای **XOR** و **جریان کلید (Keystream)** رو بشکافید و باهاش حال کنید.
4. بفهمید این **nonce** و **counter** بنده‌های خدا دقیقاً نقششون چیه و سوءتفاهم‌های رایج درباره‌شون چیه.
5. چشم‌بسته بگید چرا **استفاده‌ی مجدد از nonce** حکم خودکشی توی امنیت سیستم‌ها رو داره.
6. فرق ناموسی **تگ احراز اصالت (Tag / MAC)** با **امضای دیجیتال (Digital Signature)** رو بفهمید تا دیگه این دو تا رو اشتباه نگیرید.
7. مفهوم‌های خفن **AEAD** و **AAD** رو با مثال‌های واقعی و ملموس (کوکی‌های Flask و هدرهای شبکه) درک کنید.
8. موقع کد زدن، با دلیل و منطق بین **AES-GCM** و **ChaCha20-Poly1305** دست به انتخاب بزنید.
9. یه چک‌لیست کاربردی داشته باشید تا هروقت خواستید کد کریپتو بزنید، سوتی امنیتی ندید.

---

## 📚 واژه‌نامه رفاقتی (Terminology)

قبل اینکه شیرجه بزنیم تو کد، بیاید زبون مشترکمون رو یکی کنیم:

| اصطلاح | معادل انگلیسی | به زبان خودمون یعنی چی؟ |
|---|---|---|
| **کلید (Key)** | Key | همون رمز مخفی و ناموسی که فقط من و تو (فرستنده و گیرنده) باید داشته باشیم. |
| **رمزنگاری متقارن** | Symmetric Encryption | همون کلیدی که باهاش در قفل کردی، همون هم کلید باز کردنشه! سریع و بی‌دردسر. |
| **رمز بلوکی** | Block Cipher | چرخ‌گوشتی که ورودی رو لقمه‌لقمه (مثلاً بلوک‌های ۱۶ بایتی / ۱۲۸ بیتی) می‌خوره و پردازش می‌کنه. |
| **رمز جریانی** | Stream Cipher | شبیه شلنگ آب! دیتات هرچقدر باشه، بیت‌به‌بیت با یه جریان تصادفی قاطی می‌کنه. |
| **جریان کلید** | Keystream | یه دنباله از بیت‌های شبه‌تصادفی که با فرمول‌های خاص از روی کلید و nonce ساخته میشه. |
| **ایکس‌اور (XOR)** | ⊕ | جادوی کریپتو! عملیات بیتی ساده ولی شگفت‌انگیز که پایه و اساس رمزنگاری مدرنه. |
| **نانس (nonce)** | Number once | عددی که **فقط و فقط یک‌بار** به ازای یک کلید اجازه داره استفاده بشه؛ عمومی هم باشه مشکلی نیست. |
| **شمارنده (counter)** | Counter | عدد داخلی بلوک‌ها؛ یکی‌یکی میره بالا تا بلوک‌های متوالی جریان کلید رو بسازه. |
| **تگ / مَک** | Tag / MAC | برچسب اصالت؛ مثل هولوگرام پلمپ روی بسته که اگه یه بیت دیتات دستکاری بشه، صداش درمیاد. |
| **ای‌اید (AEAD)** | AEAD | همه‌چیز در یک پکیج: رمزگذاری (محرمانگی) + احراز اصالت (یکپارچگی) با هم و همزمان! |
| **ای‌ای‌دی (AAD)** | AAD | دیتایی که جلو چشم همه بازه و رمز نمیشه (مثل هدر بسته)، اما پلمپ و احراز اصالت میشه تا کسی عوضش نکنه. |
| **بردار اولیه (IV)** | Initialization Vector | تقریباً همون داداش دوقلوی nonce در بعضی حالت‌های عملیاتی. |

---

## 🔀 دوئل غول‌ها: رمز بلوکی در برابر رمز جریانی

### ۱. رمز بلوکی (Block Cipher) — سلطان بی‌چون‌وچرا: AES
- **بلوک‌های ثابت ۱۲۸ بیتی:** الگوریتم AES همیشه و در هر شرایطی لقمه‌های ۱۲۸ بیتی (یعنی ۱۶ بایتی) می‌خواد. اگه دیتات ۱۷ بایت باشه یا ۱۰ بایت، تنهایی گیر می‌کنه!
- **اصلاح یک سوتی رایج بین برنامه‌نویس‌ها:** خیلیا میگن «من پیامم رو با AES رمز کردم». این جمله از بیخ ناقصه! **AES به‌تنهایی هیچ متدی برای رمزگذاری یه پیام مشخص نداره.** AES صرفاً یه موتوره. شما حتماً باید بگی از چه **حالت عملیاتی (Mode)** استفاده می‌کنی؛ مثلاً AES-GCM یا AES-CTR یا خدابیامرز AES-CBC.
- **نقطه قوت:** تقریباً روی تمام CPUهای مدرن (اینتل، AMD، تراشه‌های اپل سیلیکون) دستورالعمل‌های سخت‌افزاری به اسم **AES-NI** هست که باعث میشه پردازش AES مثل برق و باد انجام بشه.

### ۲. رمز جریانی (Stream Cipher) — چابک و سریع: ChaCha20
- **جریان کلید پیوسته:** چاچا۲۰ از کلید و nonce یه رشته‌ی بی‌پایان از بیت‌های شبه‌تصادفی (Keystream) می‌سازه و اون رو روی دیتای شما می‌ریزه.
- **بدون دردسر بلوک‌بندی:** پیام شما ۳ بایت باشه یا ۳ گیگابایت، دقیقاً همون‌قدر جریان کلید تولید میشه و تموم. نیازی به پرکردن (Padding) و لقمه‌لقمه کردن نداره.
- **نقطه قوت:** این الگوریتم توی **نرم‌افزار خالص** (جایی که شتاب‌دهنده سخت‌افزاری AES نداریم، مثل گوشی‌های ارزان‌قیمت، روترها و سیستم‌های امبدد) فوق‌العاده چابکه و باتری کمتری هم مصرف می‌کنه.

### جدول مقایسه سریع و کاربردی:

| ویژگی | AES (بلوکی) | ChaCha20 (جریانی) |
|---|---|---|
| **واحد پردازش** | بلوک‌های ثابت ۱۲۸ بیتی | بیت/بایت به صورت جریان روان |
| **وابستگی به Mode** | بله، بدون Mode کار نمی‌کنه (مثلاً GCM لازمه) | خودش ماهیت جریانی داره |
| **سرعت بدون کمک سخت‌افزار** | متوسط | ⚡ فوق‌العاده سریع در نرم‌افزار |
| **سرعت با AES-NI** | 🚀 موشک! | سریع و عالی |
| **کجاها استفاده میشه؟** | TLS، دیسک‌های رمزگذاری‌شده (BitLocker/LUKS) | TLS اندروید/موبایل، پروتکل WireGuard، SSH |

---

## ⚙️ زیر کاپوت چه خبره؟ جادوی XOR و جریان کلید

رفقا، تمام جذابیت و ظرافت رمزهای جریانی و حالت‌های شبه‌جریانی (مثل CTR) توی یک عملگر دوحرفی خلاصه میشه: **XOR (⊕)**!

فرمول رمز کردن:
```text
متن رمز (Ciphertext) = متن آشکار (Plaintext) ⊕ جریان کلید (Keystream)
```

فرمول رمزگشایی:
```text
متن آشکار (Plaintext) = متن رمز (Ciphertext) ⊕ جریان کلید (Keystream)
```
دقت کردید؟ همون جریان کلید رو دوباره با متن رمز XOR کنید، متن اصلی بدون هیچ کم‌وکاستی برمی‌گرده بیرون! به این میگن زیبایی ریاضیات.

### بیاید دستی امتحان کنیم (مثال آموزشی XOR):

> ⚠️ **هشدار دوستانه:** این جدول کوچولو فقط و فقط واسه اینه که چشمتون به کارکرد بیت‌ها عادت کنه. توی دنیای واقعی جریان کلید صدها و هزاران بیت پیچیده‌ست و توسط الگوریتم‌های فوق‌امن تولید میشه!

```text
متن آشکار (Plaintext):   1 0 1 1 0 1 0 0
جریان کلید (Keystream):   0 1 1 0 1 0 1 1
─────────────────────────────────────────────
XOR (⊕) متن رمز شد:      1 1 0 1 1 1 1 1   ← متن رمز (Ciphertext)
```

چک کنیم ببینیم درسته؟  
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `1 ⊕ 1 = 0`
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `1 ⊕ 0 = 1`
- `0 ⊕ 1 = 1`
- `0 ⊕ 1 = 1`

حالا متن رمز رو دوباره با همون جریان کلید XOR کن:
```text
متن رمز:                 1 1 0 1 1 1 1 1
جریان کلید:              0 1 1 0 1 0 1 1
─────────────────────────────────────────────
XOR دوباره:              1 0 1 1 0 1 0 0   ← متن آشکار اولی برگشت! دستخوش! 🎉
```

### چند تا نکته و اصلاحیه خیلی مهم که نباید سوتی بدی:
1. **جریان کلید «شبه‌تصادفی (Pseudo-random)» است نه تصادفی محض:**  
   چرا؟ چون اگه واقعاً رندوم خالص کیهانی بود، گیرنده‌ی بخت‌برگشته چطوری می‌خواست دوباره دقیقاً همون بیت‌ها رو بسازه تا پیام رو باز کنه؟! این جریان کلید با یه تابع ریاضی کاملاً قطعی (Deterministic) از روی (کلید + nonce) ساخته میشه؛ یعنی با همون ورودی‌ها، همیشه دقیقاً همون رشته بیت تولید میشه.
2. **اندازه کلید هیچ ربطی به طول پیامت نداره:**  
   کلیدت ممکنه ۲۵۶ بیت (۳۲ بایت) باشه، ولی پیامت یه فیلم ویدیویی ۲ گیگابایتی باشه. الگوریتم جریانی به هر اندازه‌ای که پیامت بیت داشته باشه، همون‌قدر برات بیت‌های Keystream تولید می‌کنه و بیت‌به‌بیت باهاش XOR می‌کنه.

---

## 🔢 داستان Nonce و Counter: این بندگان خدا چی‌کار می‌کنن؟

### نانس (Nonce) دقیقاً چیه؟
- نام مخفف **Number used ONCE** یعنی «عددی که فقط و فقط یک‌بار مصرف میشه».
- **نانس اصلاً لازم نیست مخفی باشه!** می‌تونید با فونت درشت جارش بزنید یا همراه متن رمز توی شبکه بفرستیدش. فقط مهمه که **تکراری نشه**.
- **اصلاح یک تفکر غلط رایج:** نانس به کلید نمی‌چسبه (Append نمیشه)! نانس به عنوان یه پارامتر مستقل و جدا وارد وضعیت داخلی الگوریتم میشه.
- **فلسفه وجودی:** چون جریان کلید از ترکیب کلید و نانس ساخته میشه، اگر نانس رو عوض نکنید، برای هر پیام دقیقاً همون جریان کلید قبلی تولید میشه و فاجعه رقم می‌خوره!

### شمارنده (Counter) چیه؟
- توی الگوریتم‌هایی مثل AES-GCM یا ChaCha20، وقتی قراره یه پیام طولانی رو پردازش کنیم، جریان کلید به بلوک‌های متوالی تقسیم میشه. شمارنده (بلوک ۰، بلوک ۱، بلوک ۲...) میاد و به الگوریتم میگه الان داریم کدوم قسمت از پیام رو پردازش می‌کنیم.
- **نکته کلیدی:** کانتر یک متغیر داخلی برای موقعیت بلوکه؛ **فرشته‌ی نجات شما در صورت تکرار نانس نیست!** اگه نانس رو تکرار کنی، کانتر هم از اول همون دنباله‌ی ۰ و ۱ و ۲ رو میره و کل جریان کلید دقیقاً تکرار میشه.
- همچنین حواستون باشه شمارنده نباید سرریز (Overflow) کنه؛ مثلاً توی GCM حداکثر مجاز رمزگذاری با یک نانس حدود ۶۴ گیگابایته.

---

## ☠️ چرا تکرار نانس فاجعه‌ست؟ (The Nonce-Reuse Disaster)

فرض کن دو تا پیام مهم داری: `P1` و `P2`.  
برنامه‌نویس تنبلی کرده و برای هر دوتاش از یک کلید و یک نانس استفاده کرده!  
اتفاقی که می‌افته اینه:
```text
C1 = P1 ⊕ KS
C2 = P2 ⊕ KS
```
(که در اون `KS` همون جریان کلید مشترکه).

حالا اگه یه هکر وسط شبکه نشسته باشه و `C1` و `C2` رو با هم XOR کنه، چی میشه؟
```text
C1 ⊕ C2 = (P1 ⊕ KS) ⊕ (P2 ⊕ KS) = P1 ⊕ P2
```
بوم! 💥  
جریان کلید کاملاً از معادله حذف شد! حالا هکر `P1 ⊕ P2` رو داره. اگه هکر حتی چند کلمه از یکی از پیام‌ها رو بتونه حدس بزنه (مثلاً بدونه پیام‌ها با فرمت `{"status":` شروع میشن)، متن پیام دوم بلافاصله لو میره!

- این بدبختی توی همه حالت‌های جریانی (CTR، GCM، ChaCha20) وجود داره.
- **توی AES-GCM اوضاع حتی بدتره:** تکرار نانس نه تنها محرمانگی رو به باد میده، بلکه کلید احراز اصالت (Authentication Subkey) رو لو میده و مهاجم می‌تونه برای خودش تگ‌های معتبر جعل کنه!
- **قانون طلایی:** با یک کلید مشخص، نانس رو **هرگز و تحت هیچ شرایطی** دوباره تکرار نکنید.

---

## 🏷️ مقایسه: تگ احراز اصالت (MAC) در برابر امضای دیجیتال

اینجا جاییه که توی مصاحبه‌های استخدامی کلی از بچه‌ها سوتی میدن! بیاید فرقشون رو شسته‌رفته ببینیم:

| ویژگی | تگ / MAC (مثل Poly1305 یا HMAC) | امضای دیجیتال (مثل Ed25519 یا RSA) |
|---|---|---|
| **نوع کلید** | **یک کلید مشترک متقارن** | جفت‌کلید نامتقارن (کلید خصوصی برای امضا + کلید عمومی برای بررسی) |
| **چه کسی می‌تونه اعتبارسنجی کنه؟** | فقط کسی که کلید مشترک رو داره | **همه دنیا** با داشتن کلید عمومی شما |
| **انکارناپذیری (Non-repudiation)** | ❌ ندارد (چون طرف مقابل هم کلید رو داشته و می‌تونسته تگ بسازه) | ✅ دارد (فقط شما کلید خصوصی رو داشتید، پس سند محکمه‌پسنده!) |
| **سرعت پردازش** | ⚡ به شدت سریع و سبک | نسبتاً سنگین‌تر و کندتر |
| **کاربرد معمول** | کانال‌های امن متقارن، AEAD، پکت‌های شبکه | احراز هویت، امضای اسناد و آپدیت نرم‌افزار، گواهی SSL |

**نتیجه رفاقتی:** تگ/MAC برای اینه که مطمئن بشی وسط راه داده‌هات دستکاری نشده، اما به عنوان امضای رسمی به دادگاه ارائه نمیشه داد چون طرفت هم همون کلید رو داشته!

---

## 🧩 راز بزرگ AEAD و AAD: نجات‌بخش دنیای مدرن

### مفهوم AEAD: هم فال، هم تماشا!
در زمان‌های قدیم برنامه‌نویس‌ها دیتارو رمز می‌کردن (مثلاً با CBC)، بعد جداگانه یه هش یا HMAC بهش می‌چسبوندن. اما چون ترتیب این کار رو اشتباه می‌کردن، حملات معروفی مثل Padding Oracle به وجود اومد.  
متخصص‌های امنیت اومدن مفهومی ساختن به اسم **AEAD** (مخفف Authenticated Encryption with Associated Data). یعنی یه الگوریتم واحد که:
1. دیتات رو محرمانه (رمز) می‌کنه.
2. یه تگ احراز اصالت میده که هر کی دست به دیتات زد، سیستم خطا بده و ردش کنه.
3. خروجی استاندارد: `(nonce, ciphertext, tag)`

**نکته باحال:** هم **AES-GCM** و هم **ChaCha20-Poly1305** هر دو الگوریتم‌های استاندارد AEAD هستن.

### حالا AAD چی میگه این وسط؟
گاهی اوقات یه داده‌ای داری که **نمی‌خوای رمز بشه** (چون مثلاً روتر شبکه یا وب‌سرور باید بتونه بخونهش تا بسته‌ها رو مسیریابی کنه)، اما **می‌خوای مطمئن باشی هکر تغییرش نده**!  
به این میگن **AAD (Associated Authenticated Data)**:
- توی محاسبه‌ی تگ پلمپ شرکت داده میشه.
- اما خودش به صورت متن باز و شفاف (Plaintext) فرستاده میشه.

### مثال ۱: کوکی نشست (Session Cookie) در Flask — حواست به این باشه!
فلاسک به صورت پیش‌فرض سشن‌ها رو با کلید سرور (`SECRET_KEY`) امضا می‌کنه:

```python
from flask import Flask, session

app = Flask(__name__)
# کلید رو هیچ‌وقت هاردکد نکن رفیق! از Environment Variable بخون
app.secret_key = "یک-کلید-طولانی-و-تصادفی"

@app.route("/login")
def login():
    session["username"] = "sara"
    session["role"] = "admin"
    return "لاگین شدی مشتی!"
```

**نکته و سوتی رایج برنامه‌نویس‌ها:**
- کوکی سشن پیش‌فرض Flask **رمزنگاری نشده است! فقط امضا (Sign) شده.** یعنی کاربر می‌تونه محتوای کوکی رو به راحتی توی مرورگرش Decode کنه و ببینه داخلش چیه! فقط نمی‌تونه مقدار `role` رو به `superadmin` تغییر بده چون تگ اعتبارسنجی خراب میشه.
- پس اطلاعات حساس (رمز عبور کاربر، شماره کارت و...) رو هرگز توی کوکی معمولی نریزید؛ یا دیتای حساس رو سمت سرور (مثلاً تو Redis) نگه دارید، یا واقعاً با AEAD رمزش کنید.
- سرآیندهای معمولی IP در شبکه هیچ اصالت رمزنگارانه‌ای ایجاد نمی‌کنند مگر اینکه پروتکل اختصاصی اون‌ها رو داخل AAD وارد کرده باشه.

### مثال ۲: هدر شبکه (Network Header) در TLS 1.3
توی پروتکل‌های مدرن مثل TLS 1.3 یا QUIC:
```text
AAD        = هدر رکورد (شماره توالی + نوع بسته)  ← بازه تا روترها بخونن، ولی پلمپ شده
Ciphertext = متن رمزشده دیتای کاربر
Tag        = تگ احراز اصالت AEAD
```
اگه هکری وسط راه شماره توالی پکت رو عوض کنه تا یه پکت قدیمی رو دوباره بفرسته (Replay Attack)، تگ نامعتبر میشه و پکت بلافاصله دور ریخته میشه!

---

## ⚔️ مقایسه فنی و رفاقتی AES-GCM در برابر ChaCha20-Poly1305

| معیار | AES-GCM | ChaCha20-Poly1305 |
|---|---|---|
| **الگوریتم‌های داخلی** | موتور بلوکی AES در مود CTR + هشینگ GHASH | رمز جریانی ChaCha20 + تگ‌ساز Poly1305 |
| **نوع ساختار** | AEAD استاندارد و رسمی | AEAD استاندارد و مدرن |
| **طول نانس استاندارد** | ۹۶ بیت (۱۲ بایت) | ۹۶ بیت (۱۲ بایت) |
| **طول تگ اصالت** | ۱۲۸ بیت (۱۶ بایت) | ۱۲۸ بیت (۱۶ بایت) |
| **طول کلید** | ۱۲۸ یا ۲۵۶ بیت | ۲۵۶ بیت |
| **سرعت با سخت‌افزار (AES-NI)** | ⚡ بی‌نهایت پرسرعت | بسیار خوب |
| **سرعت روی CPU معمولی/موبایل** | نسبتاً تنبل (مخصوصاً GHASH) | ⚡ فوق‌العاده سریع و بهینه |
| **خطر تکرار نانس** | آخرالزمان! (افشای پیام + لو رفتن کلید تگ) | بسیار خطرناک (افشای پیام‌ها با XOR) |
| **کاربردهای معروف** | استانداردهای سازمانی، بانک‌ها، TLS سرورها | پروتکل WireGuard VPN، اندروید، SSH |

### کدوم رو برای پروژم بردارم؟
- **اگه روی سرور لینوکسی یا سیستم‌های مدرن کد می‌زنی:** برو سمت **AES-GCM**.
- **اگه واسه موبایل، رزبری‌پای، اینترنت اشیاء (IoT) یا اپ‌های کلاینت می‌نویسی:** انتخاب اول و آخرت **ChaCha20-Poly1305** باشه.

---

## 💻 پیاده‌سازی تمیز در پایتون با کتابخانه `cryptography`

بیاید کد واقعی بزنیم. این کد تمیز و استاندارد رو ببینید:

```python
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM, ChaCha20Poly1305

# یک کلید ۲۵۶ بیتی امن با تولیدکننده‌ی استاندارد سیستم‌عامل
master_key = os.urandom(32)

# نانس ۱۲ بایتی (۹۶ بیتی) — طلایی‌ترین قانون: هر بار یکی جدید!
nonce = os.urandom(12)

# دیتای محرمانه ما
secret_message = "رفیق این یه پیام محرمانه است که هیچ هکری نباید ببینه!".encode('utf-8')

# دیتای هدر (AAD) که احراز میشه ولی رمز نمیشه
metadata = b"user_id:1001;action:transfer"

# ================================
# روش اول: استفاده از AES-GCM
# ================================
aesgcm_cipher = AESGCM(master_key)
# رمزگذاری همراه با ضمیمه کردن AAD
encrypted_box = aesgcm_cipher.encrypt(nonce, secret_message, metadata)

# رمزگشایی و اعتبارسنجی خودکار
decrypted_msg = aesgcm_cipher.decrypt(nonce, encrypted_box, metadata)
print("AES-GCM نتیجه:", decrypted_msg.decode('utf-8'))


# ================================
# روش دوم: استفاده از ChaCha20-Poly1305
# ================================
chacha_cipher = ChaCha20Poly1305(master_key)
# برای پیام بعدی، حتماً نانس تازه می‌سازیم!
new_nonce = os.urandom(12)
encrypted_box_chacha = chacha_cipher.encrypt(new_nonce, secret_message, metadata)

# رمزگشایی
decrypted_chacha = chacha_cipher.decrypt(new_nonce, encrypted_box_chacha, metadata)
print("ChaCha20 نتیجه:", decrypted_chacha.decode('utf-8'))
```

> 💡 **نکته:** دقت کنید اگه حتی یه کاراکتر از `metadata` رو موقع decrypt تغییر بدید، پایتون بلافاصله خطای `cryptography.exceptions.InvalidTag` میده و هیچ دیتایی برنمی‌گردونه. این یعنی امنیت کامل!

---

## ✅ چک‌لیست طلایی: چطور سوتی امنیتی ندیم؟

قبل اینکه کدت رو Push کنی، این لیست رو چک کن:

- [ ] **چرخ رو از اول اختراع نکن:** هرگز خودت الگوریتم رمزنگاری ننویس! از کتابخانه‌های استاندارد و ممیزی‌شده مثل `cryptography` پایتون یا `libsodium` استفاده کن.
- [ ] **رندوم واقعی باش:** برای تولید کلید و نانس فقط از CSPRNG سیستم (مثل `os.urandom` یا `secrets`) استفاده کن، نه ماژول درب‌وداغون `random` معمولی!
- [ ] **نانس یک‌بارمصرف است:** با یک کلید ثابت، هیچ‌وقت یک نانس رو دوبار استفاده نکن.
- [ ] **همیشه AEAD:** دوران مودهای خام تموم شده؛ فقط و فقط از حالت‌های مدرن AEAD (مثل AES-GCM یا ChaCha20-Poly1305) استفاده کن.
- [ ] **پلمپ متادیتا با AAD:** اگه هدر، شماره نسخه، یا متادیتا داری، اون رو بفرست توی AAD تا دستکاری نشه.
- [ ] **کلید رو توی سورس‌کد گیت کامیت نکن:** کلیدها باید توی متغیر محیطی (Environment Variable) یا سرویس‌های مدیریت سکرت (مثل HashiCorp Vault) باشن.
- [ ] **چرخش کلید (Key Rotation):** بعد از حجم مشخصی از رمزگذاری یا گذشت چند ماه، کلیدها رو عوض کن.
- [ ] **حواست به کوکی‌ها باشه:** بدون که صرف امضا شدن کوکی سشن معنیش رمز بودنش نیست.

---

## 📝 جمع‌بندی لپ‌کلام

- **رمزنگاری متقارن:** یک کلید مشترک برای قفل کردن و باز کردن؛ سریع، بهینه و ستون فقرات انتقال دیتای حجیم.
- **AES بلوکی است و تنها نیست:** همیشه باید با یک حالت عملیاتی (مثل GCM) استفاده بشه؛ در حالی که **ChaCha20 ذاتاً جریانی است.**
- **هسته رمز جریانی XOR است:** با یک کلید و یک نانس، جریان کلید به صورت شبه‌تصادفی و قطعی تولید میشه و به اندازه طول پیام بسط داده میشه.
- **تکرار نانس یعنی فاجعه:** چون `C1 ⊕ C2 = P1 ⊕ P2` میشه و در GCM حتی کلید احراز اصالت لو میره!
- **تگ احراز اصالت امضای دیجیتال نیست:** تگ با کلید متقارن کار می‌کنه و غیرقابل انکار نیست، در حالی که امضای دیجیتال نامتقارنه و سند حقوقی محسوب میشه.
- **AEAD پادشاه رمزنگاری مدرن است:** امنیت کامل (محرمانگی + یکپارچگی) در یک پکیج شسته‌رفته؛ با AAD متادیتا رو هم محافظت کنید.

---

## 🧪 کوییز آخر کار: ببینیم چند مرده حلاجی!

### بخش اول: سوالات چهارگزینه‌ای

**۱. الگوریتم AES ذاتا در کدام دسته قرار می‌گیرد؟**  
- الف) رمز جریانی  
- ب) رمز بلوکی با بلوک‌های ۱۲۸ بیتی  
- ج) تابع درهم‌سازی رمزنگارانه (Hash)  
- د) سیستم امضای دیجیتال نامتقارن  

**۲. الگوریتم ChaCha20 جزو کدام دسته از الگوریتم‌هاست؟**  
- الف) رمز بلوکی  
- ب) الگوریتم مشتق‌گیری کلید (KDF)  
- ج) رمز جریانی  
- د) الگوریتم تبادل کلید  

**۳. اگر برای دو پیام متفاوت در حالت CTR نانس تکراری با کلید یکسان به کار رود، خروجی XOR دو متن رمز شده چه خواهد بود؟**  
- الف) کلید اصلی افشا می‌شود  
- ب) برابر با XOR دو پیام متن آشکار اولیه است (`P1 ⊕ P2`)  
- ج) نانس جدید محاسبه می‌شود  
- د) هیچ مشکلی پیش نمی‌آید چون کانتر فرق می‌کند  

**۴. کدام گزینه توصیف دقیقی از «جریان کلید (Keystream)» است؟**  
- الف) یک رشته بیت تصادفی واقعی کیهانی که هیچ فرمولی ندارد  
- ب) طولی دقیقاً برابر با طول کلید ورودی دارد  
- ج) شبه‌تصادفی و کاملاً قطعی است که از کلید و نانس ساخته می‌شود و به میزان نیاز تولید می‌گردد  
- د) حتماً باید قبل از پردازش به صورت دستی به کلید الحاق شود  

**۵. فرق ساختاری تگ احراز اصالت (MAC) با امضای دیجیتال در چیست؟**  
- الف) تگ MAC از امضای دیجیتال امن‌تر است  
- ب) تگ با کلید متقارن مشترک ساخته و چک می‌شود، اما امضای دیجیتال با جفت‌کلید نامتقارن کار می‌کند و قابل اثبات به شخص ثالث است  
- ج) امضای دیجیتال اصلاً کلید خصوصی ندارد  
- د) هیچ فرقی با هم ندارند و فقط اسم‌های تجاری مختلف هستند  

**۶. داده همراه احراز اصالت شده (AAD) چگونه پردازش می‌شود؟**  
- الف) هم کاملاً رمزگذاری می‌شود و هم احراز اصالت  
- ب) فقط احراز اصالت می‌شود و متن آن به صورت آشکار باقی می‌ماند  
- ج) نه رمز می‌شود و نه احراز اصالت می‌گردد  
- د) جایگزین نانس در الگوریتم می‌شود  

**۷. کدام الگوریتم‌ها خاصیت AEAD را به طور کامل ارائه می‌دهند؟**  
- الف) فقط AES-GCM  
- ب) فقط ChaCha20-Poly1305  
- ج) هر دوی AES-GCM و ChaCha20-Poly1305  
- د) فقط AES-CBC بدون کد MAC  

**۸. کوکی سشن پیش‌فرض فریم‌ورک Flask چه سطحی از حفاظت را فراهم می‌کند؟**  
- الف) محرمانگی و رمزگذاری صددرصد دیتای داخل کوکی  
- ب) صرفاً یکپارچگی و اصالت (جلوگیری از دستکاری)؛ محتوای آن برای کاربر قابل خواندن است  
- ج) احراز هویت سخت‌افزاری بر اساس آدرس IP کاربر  
- د) هیچ محافظتی ندارد و با متن ساده فرستاده می‌شود  

### بخش دوم: سوالات تشریحی و درک مفهوم

**۹.** چرا نانس (nonce) اگر لو برود یا عمومی باشد هیچ اشکالی ندارد، اما تکرار شدنش این‌قدر وحشتناک و خطرناک است؟  
**۱۰.** فرض کنید نانس تکرار شده است؛ آیا بالا رفتن و تغییر خودکار شمارنده (counter) می‌تواند جلوی فاجعه را بگیرد؟ چرا؟  
**۱۱.** در یک بسته شبکه TLS، چه تفاوتی میان بخش متن رمز (Ciphertext) و بخش داده همراه (AAD) وجود دارد؟  
**۱۲.** در چه شرایط سخت‌افزاری یا سناریویی بهتر است ChaCha20-Poly1305 را به AES-GCM ترجیح دهیم؟  

---

## 🔑 پاسخ‌نامه و تحلیل سوالات

**۱. گزینه (ب)** — الگوریتم AES یک رمز بلوکی ۱۲۸ بیتی است و در عمل حتماً نیازمند یک حالت عملیاتی مثل GCM می‌باشد.  
**۲. گزینه (ج)** — چاچا۲۰ یک رمز جریانی مدرن است.  
**۳. گزینه (ب)** — با تکرار نانس، Keystream تولید شده یکسان بوده و در نتیجه با XOR دو متن رمز، `C1 ⊕ C2 = P1 ⊕ P2` به دست می‌آید.  
**۴. گزینه (ج)** — جریان کلید شبه‌تصادفی و قطعی است تا دو طرف بتوانند با دادن ورودی‌های یکسان، دقیقاً به همان رشته بیت برسند؛ طول آن نیز متناسب با نیاز پیام تولید می‌شود.  
**۵. گزینه (ب)** — تگ MAC به دلیل استفاده از کلید متقارن مشترک، ویژگی عدم انکارپذیری ندارد؛ در حالی که امضای دیجیتال با جفت‌کلید نامتقارن تولید شده و قابل اثبات به داور سوم‌شخص است.  
**۶. گزینه (ب)** — داده‌های AAD در تگ شرکت می‌کنند تا دستکاری نشوند، اما محتوای آنها رمزگذاری نمی‌شود تا برای سامانه‌های میانی (مانند مسیریاب‌ها) خوانا باقی بماند.  
**۷. گزینه (ج)** — هم AES-GCM و هم ChaCha20-Poly1305 الگوریتم‌های استاندارد AEAD هستند.  
**۸. گزینه (ب)** — کوکی Flask پیش‌فرض با itsdangerous امضا می‌شود، دستکاری‌اش کشف می‌شود اما متن دیتای درون آن قابل خواندن و رمزگشایی ظاهری است.  
**۹. پاسخ تشریحی نانس:** نانس قرار نیست راز باشد؛ حتی گیرنده پیام باید نانس را ببیند تا بتواند ماشین رمزگشایی را دقیقا در همان وضعیت قرار دهد. اما نباید تکرار شود، چون تمام امنیت الگوریتم بر این فرض استوار است که جفت `(Key, Nonce)` هر بار یک جریان کلید کامپیوتر-تولیدشده‌ی منحصر‌به‌فرد بسازد. در صورت تکرار، `KS` تکرار شده و محرمانگی منهدم می‌شود.  
**۱۰. پاسخ تشریحی کانتر:** خیر! کانتر صرفاً اندیس بلوک‌های داخلی درون یک سشن است. با ورود همان جفت `(Key, Nonce)`، کانتر دوباره از مقدار اولیه‌اش شروع به شمردن می‌کند؛ بنابراین دقیقاً همان جریان کلید تکراری قبلی تولید خواهد شد.  
**۱۱. پاسخ تشریحی AAD vs Ciphertext:** بخش Ciphertext محرمانه است و هیچ ناظری محتوای آن را نمی‌فهمد، ولی AAD باز و خواناست (مثلا هدر بسته حاوی شماره پکت). هر دو در تگ نهایی سهیم هستند، پس کوچک‌ترین تغییری در AAD کل پکت را باطل می‌کند.  
**۱۲. پاسخ تشریحی مقایسه عملیاتی:** در محیط‌هایی که پردازنده فاقد دستورالعمل‌های سخت‌افزاری AES-NI است (مانند میکروکنترلرها، گوشی‌های ارزان‌قیمت، رزبری‌پای، یا ماشین‌های مجازی خاص)، الگوریتم ChaCha20-Poly1305 در نرم‌افزار خالص بسیار سریع‌تر عمل کرده و باتری و منابع کمتری هدر می‌دهد.  

---

> 🎉 **دمتون گرم که تا تهش همراه بودید!**  
> حالا دیگه مبانی کریپتوگرافی متقارن رو مثل یه مهندس کارکشته بلدید. اگه دوست داشتید عمیق‌تر بشید، پیشنهاد می‌کنم درباره‌ی **تبادل کلید Diffie-Hellman** و **حالت‌های رمزنگاری XChaCha20 با نانس ۱۹۲ بیتی** مطالعه کنید!