# X25519 RFC 7748 API.
# x25519(out32, scalar32, u32) clamps scalar and writes the 32-byte result.
# The implementation uses ten radix-2^26 limbs and a constant-time ladder.
# field_mul and field_sqr require tight limbs, limbs 0-8 below 2^26 and limb 9 below 2^21.
# field_sub may return loose limbs; normalize its result before multiplication or squaring.
