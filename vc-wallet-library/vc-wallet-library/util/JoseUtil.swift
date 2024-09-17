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
        
        let secKey = try SecKey.convertFromJwk(algorithm: algorithm, privateKey: privateKeyAsJwk)
        guard let signer = Signer(signatureAlgorithm: algorithm, key: secKey) else {
            throw NSError(domain: "SignerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid signer, privaet key or algorithm is invalid"])
        }
        
        guard let jws = try? JWS(header: jwsHeader, payload: payload, signer: signer) else {
            throw NSError(domain: "JwsError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid jws"])
        }
        let jwtValue = jws.compactSerializedString
        Logger.shared.debug(jwtValue)
        
        return jwtValue
    }
}

extension SecKey {
    
    static func convertFromJwk(algorithm: SignatureAlgorithm, privateKey: String) throws -> SecKey {
        
        switch algorithm {
            
        case .HS256, .HS384, .HS512:
            
            throw NSError(domain: "unsupported algorithim", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(algorithm.rawValue) is unsupported"])
            
        case .RS256, .RS384, .RS512, .PS256, .PS384, .PS512:
            
            throw NSError(domain: "unsupported algorithim", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(algorithm.rawValue) is unsupported"])
            
        case .ES256, .ES384, .ES512:
            
            return try convertECPrivateKey(privateKeyAsJwk: privateKey)
        }
    }
}

//FIXME unsupported
func convertRSAPrivateKey(privateKeyAsJwk: String) throws -> SecKey {
    
    guard let jsonData = privateKeyAsJwk.data(using: .utf8),
              let jwk = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
            throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JWK format"])
        }
    
    guard let n = jwk["n"],
          let e = jwk["e"],
          let d = jwk["d"] else {
        throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing RSA JWK parameters"])
    }
    
    let modulus = Data(base64URLEncoded: n)!
    let publicExponent = Data(base64URLEncoded: e)!
    let privateExponent = Data(base64URLEncoded: d)!
    
    // Create the key attributes for the RSA private key
    let keyAttributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        kSecAttrKeySizeInBits as String: modulus.count * 8,
        kSecPrivateKeyAttrs as String: [
            kSecAttrIsPermanent as String: false
        ]
    ]
    
    // Create the private key from the components
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateWithData(privateExponent as CFData, keyAttributes as CFDictionary, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    
    return privateKey
}

func convertECPrivateKey(privateKeyAsJwk: String) throws -> SecKey {
    
    guard let jsonData = privateKeyAsJwk.data(using: .utf8),
              let jwk = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
        
            throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JWK format"])
        }
    
    guard let crv = jwk["crv"],
              let x = jwk["x"],
              let y = jwk["y"],
              let d = jwk["d"],
              let xData = Data(base64URLEncoded: x),
              let yData = Data(base64URLEncoded: y),
              let dData = Data(base64URLEncoded: d) else {
        
            throw NSError(domain: "JWKError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid JWK parameters"])
        }
    
    let components = (
        crv: crv,
        x: xData,
        y: yData,
        d: dData
    )
    
    return try SecKey.representing(ecPrivateKeyComponents: components)
}

extension RSAKeyPair {
    
    // Function to generate RSA key pair
    public static func generateRSAKeyPair(keySize: Int = 2048) throws -> (privateKey: SecKey, publicKey: SecKey) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false // In-memory key (not stored in keychain)
            ]
        ]
        
        var error: Unmanaged<CFError>?
        
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(domain: "KeyError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create public key"])
        }
        
        return (privateKey: privateKey, publicKey: publicKey)
    }
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
