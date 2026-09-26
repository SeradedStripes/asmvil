#![no_main]

use libfuzzer_sys::fuzz_target;

#[repr(C)]
struct BcryptDecodeRequestV2 {
    version: u32,
    size: u32,
    hash: *const u8,
    hash_len: usize,
    salt: *mut u8,
    cost: *mut u32,
    checksum: *mut u8,
    variant: *mut u32,
}

#[repr(C)]
struct BcryptHashRequestV2 {
    version: u32,
    size: u32,
    variant: u32,
    reserved: u32,
    password: *const u8,
    password_len: usize,
    salt: *const u8,
    salt_len: usize,
    cost: u32,
    max_cost: u32,
    output: *mut u8,
    output_len: usize,
}

#[repr(C)]
struct BcryptEncodeRequestV2 {
    version: u32,
    size: u32,
    variant: u32,
    reserved: u32,
    salt: *const u8,
    checksum: *const u8,
    cost: u32,
    reserved2: u32,
    output: *mut u8,
    output_len: usize,
}

unsafe extern "C" {
    fn bcrypt_decode(
        hash: *const u8,
        hash_len: usize,
        salt: *mut u8,
        cost: *mut u32,
        checksum: *mut u8,
    ) -> u64;
    fn bcrypt_decode_v2(request: *const BcryptDecodeRequestV2) -> u64;
    fn bcrypt_hash(
        password: *const u8,
        password_len: usize,
        salt: *const u8,
        salt_len: usize,
        cost: u32,
        output: *mut u8,
    ) -> u64;
    fn bcrypt_verify(
        password: *const u8,
        password_len: usize,
        salt: *const u8,
        salt_len: usize,
        cost: u32,
        checksum: *const u8,
    ) -> u64;
    fn bcrypt_encode(
        salt: *const u8,
        checksum: *const u8,
        cost: u32,
        output: *mut u8,
    ) -> u64;
    fn bcrypt_hash_v2(request: *const BcryptHashRequestV2) -> u64;
    fn bcrypt_verify_v2(request: *const BcryptHashRequestV2) -> u64;
    fn bcrypt_encode_v2(request: *const BcryptEncodeRequestV2) -> u64;
}

fuzz_target!(|data: &[u8]| {
    let mut hash = [0u8; 60];
    let copy_len = data.len().min(hash.len());
    hash[..copy_len].copy_from_slice(&data[..copy_len]);

    let mut salt = [0xa5u8; 16];
    let mut cost = 0xa5a5_a5a5;
    let mut checksum = [0xa5u8; 23];
    let mut variant = 0xa5a5_a5a5;

    unsafe {
        let _ = bcrypt_decode(
            hash.as_ptr(),
            hash.len(),
            salt.as_mut_ptr(),
            &mut cost,
            checksum.as_mut_ptr(),
        );
    }

    let request = BcryptDecodeRequestV2 {
        version: data.get(0).copied().unwrap_or(2) as u32,
        size: data.get(1).copied().unwrap_or(56) as u32,
        hash: hash.as_ptr(),
        hash_len: data.get(2).copied().unwrap_or(60) as usize,
        salt: salt.as_mut_ptr(),
        cost: &mut cost,
        checksum: checksum.as_mut_ptr(),
        variant: &mut variant,
    };
    unsafe {
        let _ = bcrypt_decode_v2(&request);
    }

    let password_len = data.get(3).copied().unwrap_or(0).min(72) as usize;
    let mut password = [0u8; 72];
    for (index, byte) in password.iter_mut().enumerate().take(password_len) {
        *byte = data.get(4 + index).copied().unwrap_or(0);
    }
    let mut input_salt = [0u8; 16];
    for (index, byte) in input_salt.iter_mut().enumerate() {
        *byte = data.get(76 + index).copied().unwrap_or(0);
    }
    let mut raw = [0xa5u8; 24];
    let variant = data.get(92).copied().unwrap_or(2) % 3 + 1;
    let max_cost = match data.get(93).copied().unwrap_or(0) % 3 {
        0 => 0,
        1 => 3,
        _ => 4,
    };
    let hash_request = BcryptHashRequestV2 {
        version: 2,
        size: 72,
        variant: variant as u32,
        reserved: 0,
        password: password.as_ptr(),
        password_len,
        salt: input_salt.as_ptr(),
        salt_len: if data.get(94).copied().unwrap_or(16) & 1 == 0 { 16 } else { 15 },
        cost: 4,
        max_cost,
        output: raw.as_mut_ptr(),
        output_len: 23,
    };
    unsafe {
        let _ = bcrypt_hash(
            password.as_ptr(),
            password_len,
            input_salt.as_ptr(),
            hash_request.salt_len,
            4,
            raw.as_mut_ptr(),
        );
        let _ = bcrypt_verify(
            password.as_ptr(),
            password_len,
            input_salt.as_ptr(),
            hash_request.salt_len,
            4,
            raw.as_ptr(),
        );
        let _ = bcrypt_hash_v2(&hash_request);
        let _ = bcrypt_verify_v2(&hash_request);
    }

    let mut encoded = [0xa5u8; 61];
    let encode_request = BcryptEncodeRequestV2 {
        version: 2,
        size: 56,
        variant: variant as u32,
        reserved: 0,
        salt: input_salt.as_ptr(),
        checksum: raw.as_ptr(),
        cost: 4,
        reserved2: 0,
        output: encoded.as_mut_ptr(),
        output_len: encoded.len(),
    };
    unsafe {
        let _ = bcrypt_encode(input_salt.as_ptr(), raw.as_ptr(), 4, encoded.as_mut_ptr());
        let _ = bcrypt_encode_v2(&encode_request);
    }
});
