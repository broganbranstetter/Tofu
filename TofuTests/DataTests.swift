import XCTest
@testable import Tofu

class DataTests: XCTestCase {
    func testInitBase32Encoded() {
        let examples: [(encoded: String, decoded: String)] = [
            ("", ""),
            ("MY======", "f"),
            ("MZXQ====", "fo"),
            ("MZXW6===", "foo"),
            ("MZXW6YQ=", "foob"),
            ("MZXW6YTB", "fooba"),
            ("MZXW6YTBOI======", "foobar"),
            ("MY", "f"),
            ("MZXQ", "fo"),
            ("MZXW6", "foo"),
            ("MZXW6YQ", "foob"),
            ("MZXW6YTB", "fooba"),
            ("MZXW6YTBOI", "foobar"),
            ("mzxw6ytboi", "foobar"),
        ]
        
        for example in examples {
            let actual = Data(base32Encoded: example.encoded)
            let expected = example.decoded.data(using: .ascii)

            XCTAssertEqual(actual, expected)
        }
        
        XCTAssertNil(Data(base32Encoded: "1")) // Invalid character
        XCTAssertNil(Data(base32Encoded: "A")) // Invalid length
        XCTAssertNil(Data(base32Encoded: "AAA"))
        XCTAssertNil(Data(base32Encoded: "AAAAAA"))
        XCTAssertNil(Data(base32Encoded: "MY==")) // Invalid padding
        XCTAssertNil(Data(base32Encoded: "MY====="))
        XCTAssertNil(Data(base32Encoded: "MZXW6Y==="))
    }

    func testExportRoundTrip() throws {
        let interop = ExternalDataInterop()

        let account1 = Account()
        account1.name = "Test"
        account1.issuer = "Xcode"
        account1.password.algorithm = .sha1
        account1.password.secret = Data(base32Encoded: "aaaaaaa")!
        account1.password.timeBased = true
        account1.password.period = 30
        account1.password.digits = 6

        let account2 = Account()
        account2.name = "Test 2"
        account2.issuer = "Xcode"
        account2.password.algorithm = .sha1
        account2.password.secret = Data(base32Encoded: "bbbbbbb")!
        account2.password.timeBased = true
        account2.password.period = 30
        account2.password.digits = 6

        XCTAssertNotEqual(account1, account2)

        let sourceAccounts: [Account] = [account1, account2]
        let encryptedAccounts = try interop.encryptedData(for: sourceAccounts, with: "12345678")
        let decryptedAccounts = try interop.decryptAccounts(from: encryptedAccounts, with: "12345678")
        XCTAssertEqual(sourceAccounts, decryptedAccounts)
        XCTAssertThrowsError(try interop.decryptAccounts(from: encryptedAccounts, with: "87654321"))
    }
}
