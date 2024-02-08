import Foundation

private enum DecodedByte {
    case valid(UInt8)
    case invalid
    case padding
}

private let padding: UInt8 = 61 // =

private let byteMappings: [CountableRange<UInt8>] = [
    65 ..< 91, // A-Z
    50 ..< 56, // 2-7
]

private func decode(byte encodedByte: UInt8) -> DecodedByte {
    if encodedByte == padding { return .padding }
    var decodedStart: UInt8 = 0
    for range in byteMappings {
        if range.contains(encodedByte) {
            let result = decodedStart + (encodedByte - range.lowerBound)
            return .valid(result)
        }
        decodedStart += range.upperBound - range.lowerBound
    }
    return .invalid
}

private func decoded(bytes encodedBytes: [UInt8]) -> [UInt8]? {
    var decodedBytes = [UInt8]()
    decodedBytes.reserveCapacity(encodedBytes.count / 8 * 5)

    var decodedByte: UInt8 = 0
    var characterCount = 0
    var paddingCount = 0
    var index = 0

    for encodedByte in encodedBytes {
        let value: UInt8

        switch decode(byte: encodedByte) {
        case .valid(let v):
            value = v
            characterCount += 1
        case .invalid:
            return nil
        case .padding:
            paddingCount += 1
            continue
        }

        // Only allow padding at the end of the sequence
        if paddingCount > 0 { return nil }

        switch index % 8 {
        case 0:
            decodedByte = value << 3
        case 1:
            decodedByte |= value >> 2
            decodedBytes.append(decodedByte)
            decodedByte = value << 6
        case 2:
            decodedByte |= value << 1
        case 3:
            decodedByte |= value >> 4
            decodedBytes.append(decodedByte)
            decodedByte = value << 4
        case 4:
            decodedByte |= value >> 1
            decodedBytes.append(decodedByte)
            decodedByte = value << 7
        case 5:
            decodedByte |= value << 2
        case 6:
            decodedByte |= value >> 3
            decodedBytes.append(decodedByte)
            decodedByte = value << 5
        case 7:
            decodedByte |= value
            decodedBytes.append(decodedByte)
        default:
            fatalError()
        }

        index += 1
    }

    let characterCountIsValid = [0, 2, 4, 5, 7].contains(characterCount % 8)
    let paddingCountIsValid = paddingCount == 0 || (characterCount + paddingCount) % 8 == 0
    guard characterCountIsValid && paddingCountIsValid else { return nil }

    return decodedBytes
}

extension Data {
    init?(base32Encoded string: String) {
        let encodedBytes = Array(string.uppercased().utf8)
        guard let decodedBytes = decoded(bytes: encodedBytes) else { return nil }
        self.init(decodedBytes)
    }

    /// Read a given type from a Data's buffer.
    ///
    /// Very much like UnsafeRawBufferPointer's load(fromByteOffset:as:), but doesn't barf if the value
    /// isn't at an aligned position.
    ///
    /// - Parameters:
    ///   - offset: The offset to load the value from.
    ///   - type: The type of the value.
    /// - Returns: The value loaded from the data.
    func alignmentSafeLoad<T>(fromByteOffset offset: Int = 0, as type: T.Type) throws -> T {
        guard count >= (offset + MemoryLayout<T>.size) else { throw NSError(domain: "com.calleerlandsson.Tofu", code: -1) }
        let chunk = subdata(in: offset..<(offset + MemoryLayout<T>.size))
        return chunk.withUnsafeBytes({ (bytePointer: UnsafeRawBufferPointer) -> T in
            return bytePointer.load(as: T.self)
        })
    }
}
