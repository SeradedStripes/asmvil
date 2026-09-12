# GCM/GMAC SP 800-38D API; x86-64 uses AES-NI, PCLMULQDQ and SSSE3.
# The 384-byte context supports only 12-byte nonces and must be isolated.
# gcm_init(ctx,key,nr,nonce12) returns 1 for nr 10/14, otherwise 0.
# gcm_update_aad(ctx,aad,len) absorbs AAD before ciphertext processing.
# gcm_seal(ctx,in,out,len) encrypts and authenticates ciphertext.
# gcm_open(ctx,in,out,len) decrypts while authenticating ciphertext.
# gcm_final_tag(ctx,tag16) finalizes GHASH and caches the tag.
# gcm_verify(ctx,candidate16) compares the cached tag in constant time.
# Input and output must not overlap; open plaintext needs successful verify.
