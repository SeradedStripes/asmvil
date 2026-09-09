# SHA-384/SHA-512 for ASMVIL. Shared API and context layout.
# Both are SHA-512 variants: identical compression, SHA-384 uses dedicated
# IVs and a 48-byte truncation. See include/<arch>/common.inc for the
# syscall constants and <arch>/sha512.asm for the implementation.
#
# Context layout (SHA512_CTX_SIZE bytes, 8-byte aligned):
#   SHA512_STATE       0   8 working words (8 bytes each), big-endian in memory
#   SHA512_BUF         64  128-byte block buffer
#   SHA512_TOTAL       192 cumulative message length in bytes
#   SHA512_BUF_LEN     200 bytes buffered in SHA512_BUF
#   SHA512_DIGEST_LEN  208 digest size in bytes: 48 (SHA-384) or 64 (SHA-512)
#   SHA512_CTX_SIZE    216
#
# sha512_init(rdi=ctx)
#   Reset context for SHA-512 (64-byte digest).
# sha384_init(rdi=ctx)
#   Reset context for SHA-384 (48-byte digest).
# sha512_update(rdi=ctx, rsi=data, rdx=len)
#   Absorb data; may compress internally. Any length is allowed, including 0.
# sha512_final(rdi=ctx, rsi=digest)
#   Append SHA-512 padding and emit SHA512_DIGEST_LEN bytes to digest.
#   ctx must be re-init before further use.
# sha512_compress is internal and arch-specific.