//
//  JoseUtil.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/14.
//

import Foundation
import JOSESwift
import CryptoKit

public class JoseUtil {
    
    public static let shared = JoseUtil()
    
    
    public func sign(algorithm: String, privateKeyAsJwk: String, headers: [String: Any], claims: [String: Any]) throws -> String {
        let algorithm = try toAlgorithm(algorithm: algorithm)
        var jwsHeader = JWSHeader(algorithm: algorithm)
        
        let claimsAsString = try JSONSerialization.data(withJSONObject: claims, options: [])
        let payload = Payload(claimsAsString)
        let secKey = try SecKey.representing(ecPrivateKeyComponents: convertJWKToECPrivateKeyComponents(privateKeyAsJwk: privateKeyAsJwk))
        let optionalSigner = Signer(signatureAlgorithm: algorithm, key: secKey)
        guard let signer = optionalSigner else {
            throw NSError(domain: "JoseUtil", code: 1)
        }
        
        guard let jws = try? JWS(header: jwsHeader, payload: payload, signer: signer) else {
            throw NSError(domain: "JoseUtil", code: 2)
        }
        let jwtValue = jws.compactSerializedString
        Logger.shared.debug(jwtValue)
        return jwtValue
    }
}

func convertJWKToECPrivateKeyComponents(privateKeyAsJwk: String) throws -> ECPrivateKeyComponents {
    
    guard let jsonData = privateKeyAsJwk.data(using: .utf8),
              let jwk = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
            throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JWK format"])
        }
    
    guard let crv = jwk["crv"],
          let x = jwk["x"],
          let y = jwk["y"],
          let d = jwk["d"] else {
        throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing JWK parameters"])
    }
    
    return (
        crv: crv,
        x: Data(base64URLEncoded: x)!,
        y: Data(base64URLEncoded: y)!,
        d: Data(base64URLEncoded: d)!
    )
}

// Base64 URL decoding (handles padding)
extension Data {
    init?(base64URLEncoded base64URLString: String) {
        var base64String = base64URLString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let paddedLength = (4 - base64String.count % 4) % 4
        base64String += String(repeating: "=", count: paddedLength)
        
        self.init(base64Encoded: base64String)
    }
}

func toAlgorithm(algorithm: String) throws -> SignatureAlgorithm {

    switch algorithm {
    case "HS256":
         return SignatureAlgorithm.HS256
    case "HS384":
         return SignatureAlgorithm.HS384
    case "HS512":
         return SignatureAlgorithm.HS512
    case "RS256":
         return SignatureAlgorithm.RS256
    case "RS384":
         return SignatureAlgorithm.RS384
    case "RS512":
         return SignatureAlgorithm.RS512
    case "PS256":
         return SignatureAlgorithm.PS256
    case "PS384":
         return SignatureAlgorithm.PS384
    case "PS512":
         return SignatureAlgorithm.PS512
    case "ES256":
         return SignatureAlgorithm.ES256
    case "ES384":
         return SignatureAlgorithm.ES384
    case "ES512":
         return SignatureAlgorithm.ES512
    default:
        throw NSError(domain: "JoseUtil", code: -1)
    }
}
