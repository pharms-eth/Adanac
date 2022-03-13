import UIKit

var greeting = "Hello, playground"


//let abc = ["mark", "fisher", "oil", "hits", "market"]
//let word = "oil"
//if let idx = abc.firstIndex(of: word) {
//    let idxAsInt = abc.startIndex.distance(to: idx)
//    print(idxAsInt)
//    print(idx)
//}
//
//

//func randomString(length: Int) -> String {
//  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//  return String((0..<length).compactMap{ _ in letters.randomElement() })
//}
//
//extension String {
//
//    func leftPad(with character: Character, length: UInt) -> String {
//        let maxLength = Int(length) - count
//        guard maxLength > 0 else {
//            return self
//        }
//        return String(repeating: String(character), count: maxLength) + self
//    }
//}
//    extension UInt8 {
//        var bin: String {
//            String(self, radix: 2).leftPad(with: "0", length: 8)
//        }
//    }

//valid_entropy_bit_sizes = [128, 160, 192, 224, 256]
//let entropy_bit_size = 128
//let entropy_bytes = randomString(length: entropy_bit_size / 8)//bytestring of size
////Do I need hex values instead?
//////b'Q\x83\xe1\xf4\xf1j\xac5\x16\x04<\x0bm`\xcf\x0c'
//print(entropy_bytes)
//let buf2 : [UInt8] = [UInt8](entropy_bytes.utf8)
//let data = Data(buf2)
//print(data.base64EncodedString())
//print(buf2)
//print(String(2, radix: 2))
//let data2 = entropy_bytes.data(using: .utf8)
//data.forEach({ print(String($0, radix: 2)) })
//let binaryArr = data2.map({(byte) -> String in
//    var str = String(byte, radix: 2)
//    let countToAppend = 8 - str.count
//    let extraZerosStr = ([String](repeating: "0", count: countToAppend)).joined()
//    str = extraZerosStr + str
//    return str
//})
//let x: UInt8 = 0b00000110   // 6 using binary format
//print(String(x, radix: 2))  // 110
//print(x.bin)                // 00000110
//print((~x).bin)             // 11111001 - one's complement
//let res = (~x) + 1          // 11111010 - two's complement
//print(res.bin)

//print(binaryArr)

//let entropy_bits = bitarray()
//entropy_bits.frombytes(entropy_bytes)
//print(entropy_bits)
////bitarray('0101000110000011...01100111100001100')




//print("\n--- returning to string ---")
//// Now for the other direction, as far as I can tell we need Foundation:
//print(String(bytes: buf2, encoding: .utf8))
//// Getting NSData:
//let data = x.data(using: .utf8)!
//// Getting byte array:
//let uint8Rep = [UInt8](UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
//print(uint8Rep)
//// Getting back to String:
//print(String(data: data, encoding: .utf8))
//// Getting back to String using byte array:
//print(String(bytes: uint8Rep, encoding: NSUTF8StringEncoding))

//let entropy_bit_size = 128
//let entropy_bytes = randomString(length: entropy_bit_size / 8)//bytestring of size
//print(entropy_bytes)
//let inputData = Data(entropy_bytes.utf8)
//
//let checksum_length = entropy_bit_size / 32
//print(checksum_length)
//
//import CryptoKit
////let hashBytes = SHA256()
////let hashed = SHA256.hash(data: inputData)
////print(hashed.description)
////let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
////print(hashString)
//
//
//let hash_bytes = SHA256.hash(data: inputData)
//print(hash_bytes)
////# b'\xef\x88\xad\x02\x16\x7f\xa6y\xde\xa6T...'
//
//
//
////hash_bits = bitarray()
////hash_bits.frombytes(hash_bytes)
////print(hash_bits)
////# bitarray('111011111000100010...')
////checksum = hash_bits[:checksum_length]
////print(checksum)
////# bitarray('1110')

(UInt32(1) << 31)
