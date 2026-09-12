# ChaCha20-Poly1305 AEAD RFC 8439 API with a 408-byte x86-64 context.
# Context and all key, nonce, input, output and tag buffers must be isolated.
# aead_init(ctx,key32,nonce12) derives the one-time Poly1305 key.
# aead_update_aad(ctx,aad,len) adds AAD before text processing.
# aead_seal(ctx,plaintext,ciphertext,len) encrypts and authenticates.
# aead_open(ctx,ciphertext,plaintext,len) decrypts and authenticates.
# aead_final(ctx,tag16) writes and caches the final tag.
# aead_verify(ctx,candidate16) compares the tag in constant time.
# Open plaintext must not be used unless verification succeeds.
