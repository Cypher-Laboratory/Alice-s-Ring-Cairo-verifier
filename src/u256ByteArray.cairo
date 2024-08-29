use core::byte_array::ByteArray;


pub fn u256_to_byte_array_string(value: u256) -> ByteArray {
    let mut byte_array = "";

    // Add '0x' prefix
    byte_array.append_byte(0x30); // '0'
    byte_array.append_byte(0x78); // 'x'

    // Convert u256 to bytes
    let bytes = u256_to_bytes(value);

    // Convert bytes to hex string
    let mut i: usize = 0;
    loop {
        if i >= bytes.len() {
            break;
        }
        let byte = *bytes.at(i);
        byte_array.append_byte(nibble_to_hex_char(byte / 16));
        byte_array.append_byte(nibble_to_hex_char(byte % 16));
        i += 1;
    };

    byte_array
}

fn u256_to_bytes(value: u256) -> Array<u8> {
    let mut bytes = ArrayTrait::new();
    let mut i = 31;

    loop {
        if i == 0 {
            let shift_amount = i * 8;
            let byte: u8 = if shift_amount < 128 {
                ((value.low / pow_256(shift_amount)) & 0xFF).try_into().unwrap()
            } else {
                ((value.high / pow_256(shift_amount - 128)) & 0xFF).try_into().unwrap()
            };
            bytes.append(byte);
            break;
        }
        let shift_amount = i * 8;
        let byte: u8 = if shift_amount < 128 {
            ((value.low / pow_256(shift_amount)) & 0xFF).try_into().unwrap()
        } else {
            ((value.high / pow_256(shift_amount - 128)) & 0xFF).try_into().unwrap()
        };
        bytes.append(byte);
        i -= 1;
    };

    bytes
}

fn pow_256(exp: u32) -> u128 {
    if exp == 0 {
        1
    } else {
        256 * pow_256(exp - 1)
    }
}

fn nibble_to_hex_char(nibble: u8) -> u8 {
    if nibble < 10 {
        nibble + 48 // '0' to '9'
    } else {
        nibble + 87 // 'a' to 'f'
    }
}

