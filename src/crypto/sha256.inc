# SHA-256 API and context layout (FIPS 180-4).

# Context layout, identical on both architectures:
    .equ SHA256_STATE,  0
    .equ SHA256_BUF,    32
    .equ SHA256_TOTAL,  96
    .equ SHA256_BUF_LEN, 104
    .equ SHA256_CTX_SIZE, 112

# sha256_init(ctx): reset state to the SHA-256 IV.
# sha256_update(ctx, data, len): absorb len message bytes, buffering partial
#   blocks; len is 64-bit.
# sha256_final(ctx, digest): pad (0x80, zeros, 64-bit big-endian bit length)
#   and emit the 32-byte big-endian digest.
# sha256_compress(state, block): one compression on a full 64-byte block,
#   atomic against ctx so partial blocks can be spooled. Not required by the
#   public API but exported for testing large bulk input.

# Constants: 64 rounds (K) and the 8-word IV are in .rodata.