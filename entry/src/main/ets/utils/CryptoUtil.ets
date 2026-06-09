/**
 * MD5 hash utility - pure ArkTS implementation.
 * Produces a 32-character lowercase hexadecimal string.
 */

// MD5 constants
const T: number[] = [];
for (let i = 0; i < 64; i++) {
  T[i] = Math.floor(Math.abs(Math.sin(i + 1)) * 4294967296);
}

function rotateLeft(value: number, amount: number): number {
  return ((value << amount) | (value >>> (32 - amount))) >>> 0;
}

function toLittleEndian(bytes: number[]): number[] {
  const result: number[] = [];
  for (let i = 0; i < bytes.length; i += 4) {
    result.push(
      bytes[i] | (bytes[i + 1] << 8) | (bytes[i + 2] << 16) | (bytes[i + 3] << 24)
    );
  }
  return result;
}

function fromLittleEndian(words: number[]): number[] {
  const result: number[] = [];
  for (let i = 0; i < words.length; i++) {
    const w = words[i];
    result.push(w & 0xff, (w >>> 8) & 0xff, (w >>> 16) & 0xff, (w >>> 24) & 0xff);
  }
  return result;
}

function stringToUtf8Bytes(str: string): number[] {
  const bytes: number[] = [];
  for (let i = 0; i < str.length; i++) {
    let code = str.charCodeAt(i);
    if (code < 0x80) {
      bytes.push(code);
    } else if (code < 0x800) {
      bytes.push(0xc0 | (code >>> 6), 0x80 | (code & 0x3f));
    } else if (code < 0xd800 || code >= 0xe000) {
      bytes.push(
        0xe0 | (code >>> 12),
        0x80 | ((code >>> 6) & 0x3f),
        0x80 | (code & 0x3f)
      );
    } else {
      // Surrogate pair
      i++;
      if (i < str.length) {
        code = 0x10000 + ((code & 0x3ff) << 10) + (str.charCodeAt(i) & 0x3ff);
        bytes.push(
          0xf0 | (code >>> 18),
          0x80 | ((code >>> 12) & 0x3f),
          0x80 | ((code >>> 6) & 0x3f),
          0x80 | (code & 0x3f)
        );
      }
    }
  }
  return bytes;
}

function md5Core(inputBytes: number[]): number[] {
  // Step 1: Padding
  const msgLen = inputBytes.length;
  const padded: number[] = [...inputBytes, 0x80];
  while ((padded.length % 64) !== 56) {
    padded.push(0);
  }
  // Append original length in bits as 64-bit little-endian
  const bitLen = msgLen * 8;
  for (let i = 0; i < 4; i++) {
    padded.push((bitLen >>> (i * 8)) & 0xff);
  }
  for (let i = 0; i < 4; i++) {
    padded.push((bitLen / Math.pow(2, 32) >>> (i * 8)) & 0xff);
  }

  // Step 2: Initialize variables
  let a0 = 0x67452301;
  let b0 = 0xefcdab89;
  let c0 = 0x98badcfe;
  let d0 = 0x10325476;

  // Step 3: Process each 512-bit block
  for (let i = 0; i < padded.length; i += 64) {
    const block = toLittleEndian(padded.slice(i, i + 64));

    let A = a0;
    let B = b0;
    let C = c0;
    let D = d0;

    for (let j = 0; j < 64; j++) {
      let F: number;
      let g: number;
      if (j < 16) {
        F = (B & C) | (~B & D);
        g = j;
      } else if (j < 32) {
        F = (D & B) | (~D & C);
        g = (5 * j + 1) % 16;
      } else if (j < 48) {
        F = B ^ C ^ D;
        g = (3 * j + 5) % 16;
      } else {
        F = C ^ (B | ~D);
        g = (7 * j) % 16;
      }
      const temp = D;
      D = C;
      C = B;
      B = (B + rotateLeft(A + F + T[j] + block[g], [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
        5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21][j])) >>> 0;
      A = temp;
    }

    a0 = (a0 + A) >>> 0;
    b0 = (b0 + B) >>> 0;
    c0 = (c0 + C) >>> 0;
    d0 = (d0 + D) >>> 0;
  }

  return fromLittleEndian([a0, b0, c0, d0]);
}

function bytesToHex(bytes: number[]): string {
  const hexChars = '0123456789abcdef';
  let result = '';
  for (let i = 0; i < bytes.length; i++) {
    result += hexChars.charAt((bytes[i] >>> 4) & 0x0f);
    result += hexChars.charAt(bytes[i] & 0x0f);
  }
  return result;
}

/**
 * Computes the MD5 hash of the input string.
 * @param input - The string to hash
 * @returns 32-character lowercase hexadecimal MD5 hash
 */
export function md5(input: string): string {
  const utf8Bytes = stringToUtf8Bytes(input);
  const hashBytes = md5Core(utf8Bytes);
  return bytesToHex(hashBytes);
}
