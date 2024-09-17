//
//  JoseUtilTests.swift
//  vc-wallet-libraryTests
//
//  Created by 小林弘和 on 2024/09/14.
//

import XCTest
@testable import vc_wallet_library
import JOSESwift

final class JoseUtilTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSign() throws {
        let keyPair = try ECKeyPair.generateWith(.P256)
        let privateKey = keyPair.getPrivate()

        guard let privateKeyValue = privateKey.jsonString() else {
           return
        }
        
        do {
            let jws = try JoseUtil.shared.sign(algorithm: "ES256", privateKeyAsJwk: privateKeyValue, headers: [:], claims: ["sub": "123"])
            print(jws)
        } catch (let error) {
            print(error)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
