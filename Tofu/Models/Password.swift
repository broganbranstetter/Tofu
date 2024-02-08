import Foundation
import CommonCrypto

class Password: Equatable, Hashable {

    static func == (lhs: Password, rhs: Password) -> Bool {
        return lhs.algorithm == rhs.algorithm && lhs.secret == rhs.secret && lhs.digits == rhs.digits &&
        lhs.period == rhs.period && lhs.counter == rhs.counter && lhs.timeBased == rhs.timeBased
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(algorithm)
        hasher.combine(counter)
        hasher.combine(digits)
        hasher.combine(secret)
        hasher.combine(period)
        hasher.combine(timeBased)
    }

    var algorithm: Algorithm = .sha1
    var counter = 0

    private var _digits = 6
    var digits: Int {
        get { return _digits }
        set {
            if newValue < 6 {
                assertionFailure("digits must be >= 6")
                _digits = 6
            } else if newValue > 9 {
                assertionFailure("digits must be <= 9")
                _digits = 9
            } else {
                _digits = newValue
            }
        }
    }

    private var _period = 30
    var period: Int {
        get { return _period }
        set {
            if newValue < 1 {
                assertionFailure("period must be > 1")
                _period = 30
            } else {
                _period = newValue
            }
        }
    }

    var secret = Data()
    var timeBased = false
    
    func valueForDate(_ date: Date) -> String {
        let counter = timeBased ? UInt64(date.timeIntervalSince1970) / UInt64(period) : UInt64(self.counter)
        var input = counter.bigEndian
        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: algorithm.digestLength)
        defer { digest.deallocate() }
        secret.withUnsafeBytes { secretBytes in CCHmac(algorithm.hmacAlgorithm, secretBytes.baseAddress, secret.count, &input, MemoryLayout.size(ofValue: input), digest) }
        let offset = digest[algorithm.digestLength - 1] & 0x0f
        let digestData = Data(bytes: digest, count: algorithm.digestLength)
        let bigEndianNumber = try! digestData.alignmentSafeLoad(fromByteOffset: Int(offset), as: UInt32.self)
        let number = UInt32(bigEndian: bigEndianNumber) & 0x7fffffff
        return String(format: "%0\(digits)d", number % UInt32(pow(10, Float(digits))))
    }
    
    func progressForDate(_ date: Date) -> Double {
        return timeIntervalRemainingForDate(date) / Double(period)
    }
    
    func timeIntervalRemainingForDate(_ date: Date) -> Double {
        let period = Double(self.period)
        return period - (date.timeIntervalSince1970.truncatingRemainder(dividingBy: period))
    }
}
