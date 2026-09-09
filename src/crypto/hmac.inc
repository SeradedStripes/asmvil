# HMAC (RFC 2104) for ASMVIL. Shared API notes.
# Implementation lives in <arch>/hmac.asm and keys off the SHA-256/SHA-384/
# SHA-512 contexts from sha256.inc / sha512.inc.
#
# hmac_sha256(rdi=key, rsi=keylen, rdx=msg, rcx=msglen, r8=mac)
#   HMAC-SHA-256, writes 32 bytes to mac.
# hmac_sha384(rdi=key, rsi=keylen, rdx=msg, rcx=msglen, r8=mac)
#   HMAC-SHA-384, writes 48 bytes to mac.
# hmac_sha512(rdi=key, rsi=keylen, rdx=msg, rcx=msglen, r8=mac)
#   HMAC-SHA-512, writes 64 bytes to mac.
#
# One-shot: may clobber any registers; mac must not overlap key or msg.
# Key handling follows RFC 2104: keys longer than the block size are
# hashed first, then K is zero-padded to the block size.