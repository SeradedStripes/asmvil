# HKDF (RFC 5869) for ASMVIL. Shared API notes.
# Implementation lives in <arch>/hkdf.asm and builds directly on the HMAC
# entry points from hmac.asm. okm may be as large as 255 * hash length.
#
# Extract: prk = HMAC(hash, salt, ikm). An empty salt (saltlen 0) matches
# RFC 5869 (salt defaults to hash-length zero bytes; HMAC pads a zero-length
# key to hash length anyway).
#
# hkdf_sha256_extract(rdi=salt, rsi=saltlen, rdx=ikm, rcx=ikmlen, r8=prk)
#   Writes 32 bytes to prk.
# hkdf_sha256_expand(rdi=prk, rsi=info, rdx=infolen, rcx=okm, r8=okmlen)
#   Expands up to 8160 bytes to okm.
# hkdf_sha384_extract / hkdf_sha384_expand
#   SHA-384 variants: 48-byte prk, write 48 bytes per block.
# hkdf_sha512_extract / hkdf_sha512_expand
#   SHA-512 variants: 64-byte prk, write 64 bytes per block.
#
# TLS 1.3 helpers (RFC 8446 7.1), one per hash. Hash.length is the digest
# length for that hash.
#
# hkdf_expand_label_sha256(rdi=secret, rsi=label, rdx=labellen, rcx=context,
#                          r8=contextlen, r9=out, outlen=[rsp+8])
#   Builds HkdfLabel = u16(outlen) || "tls13 " || label || u8(contextlen)
#   || context, then runs expand. Writes outlen bytes to out.
# hkdf_derive_secret_sha256(rdi=secret, rsi=label, rdx=labellen, rcx=context,
#                           r8=contextlen, r9=out)
#   Same envelope with outlen fixed to Hash.length.
# The sha384 and sha512 variants use the same signatures.