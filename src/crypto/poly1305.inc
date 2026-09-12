# Poly1305 RFC 8439 API with a 176-byte x86-64 context.
# The context and all key, message, tag and candidate buffers must be isolated.
# poly1305_init(ctx,key32) initializes a one-time key.
# poly1305_update(ctx,message,len) absorbs data and returns 1 before finalizing.
# poly1305_final(ctx,tag16) writes and caches the tag, then wipes key state.
# poly1305_verify(ctx,candidate16) performs a constant-time tag comparison.
# Poly1305 keys must never be reused for different messages.
