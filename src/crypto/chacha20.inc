# ChaCha20 RFC 8439 API with a 144-byte x86-64 streaming context.
# The context must not overlap key, nonce, input or output buffers.
# chacha20_block(key32,counter,nonce12,out64) writes one block.
# chacha20_init(ctx,key32,counter,nonce12) initializes streaming state.
# chacha20_xor(ctx,in,out,len) returns 1 on success and 0 on exhaustion.
# Input and output may be identical or disjoint, but not partially overlap.
# Control flow and addresses depend only on public state and lengths.
