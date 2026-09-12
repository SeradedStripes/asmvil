# AES-128/256 FIPS 197 API; x86-64 uses AES-NI.
# Expand: aes128_expand(key,sched) writes 176 bytes.
# Expand: aes256_expand(key,sched) writes 240 bytes.
# Encrypt: aes128_encrypt(sched,in,out) processes one block.
# Encrypt: aes256_encrypt(sched,in,out) processes one block.
# Decrypt: aes128_decrypt(sched,in,out) uses a forward schedule.
# Decrypt: aes256_decrypt(sched,in,out) uses a forward schedule.
# Generic encrypt: aes_encrypt(sched,in,out,nr), with nr equal to 10 or 14.
# The schedule stores FIPS round keys in order; input and output may overlap.
