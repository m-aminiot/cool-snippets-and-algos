# User and Key File Setup

Run from the project directory. The user and group should not already exist.

## Ubuntu / Debian

```sh
# Create group
sudo groupadd key_python

# Create user without interactive login
sudo useradd -m -g key_python -s /usr/sbin/nologin crypto_user

# Set file owner and group
sudo chown crypto_user:key_python key.txt

# Owner: read/write; group: read; others: no access
sudo chmod 640 key.txt
```


