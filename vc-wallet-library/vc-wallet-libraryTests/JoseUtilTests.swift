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

    func testSignAndVerifyWithECKey() throws {
        // Given
        let keyPair = try ECKeyPair.generateWith(.P256)
        let privateKey = keyPair.getPrivate()
        let publicKey = keyPair.getPublic()
        guard let privateKeyValue = privateKey.jsonString(), let publicKeyValue = publicKey.jsonString() else {
            XCTFail("failed convert privateKey to String")
            return
        }
        
        do {
            // When
            let jws = try JoseUtil.shared.sign(algorithm: "ES256", privateKeyAsJwk: privateKeyValue, headers: ["cty": "JWT"], claims: ["sub": "123"])
            print(jws)
            
            // Then
            XCTAssertNotNil(jws)
            XCTAssertTrue(jws.hasPrefix("eyJ"))
            
            let verifiedJose = try JoseUtil.shared.verify(jws: jws, algorithm: "ES256", publicKeyAsJwk: publicKeyValue)
            print(verifiedJose)
            
        } catch (let error) {
            
            XCTFail("Signing failed with error: \(error.localizedDescription)")
        }
        
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
