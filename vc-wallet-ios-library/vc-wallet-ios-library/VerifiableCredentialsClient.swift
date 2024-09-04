//
//  VerifiableCredentialsClient.swift
//  vc-wallet-ios-library
//
//  Created by 小林弘和 on 2024/09/05.
//

import Foundation

public class VerifiableCredentialsClient {
    
    public static let shared = VerifiableCredentialsClient()
    private var configuration: WalletConfiguration?
    
    private init() {
        
    }
    
    public func configure(configuration: WalletConfiguration) {
        self.configuration = configuration
    }
    
}
