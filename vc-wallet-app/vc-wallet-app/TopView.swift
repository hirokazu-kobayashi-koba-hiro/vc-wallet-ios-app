//
//  TopView.swift
//  vc-wallet-app
//
//  Created by 小林弘和 on 2024/10/18.
//


import SwiftUI
import SwiftData
import VcWalletLibrary

struct TopView: View {
    let name: String
    @State private var isShowingScanner = false
    @State private var isError = false
    
    public init(name: String) {
        self.name = name
    }
    
    var body: some View {
        Button(action: {
            print("on click")
            isShowingScanner = true
        },
               label: {
            Text("pre-authorized")
        }
        )
        .alert(
            "alertTitle",
            isPresented: $isError
        ) {
            Button("OK") {
                isError = false
            }
        }
        .padding()
        .sheet(isPresented: $isShowingScanner) {
            QrCodeReaderView(onRecognized: { value in
                guard let url = value else {
                    return
                }
                handlePreAuthorization(url: url)
                isShowingScanner = false
                isError = true
            }).ignoresSafeArea(.all)
        }
    }
}


func handlePreAuthorization(url: String) {
    Task {
        do {
            let viewController = await UIViewController()
            
            let verifiableCredentialsService = VerifiableCredentialsService(
                walletClientConfigurationRepository: WalletClientConfigurationDataSource(),
                verifiableCredentialRecordRepository: VerifiableCredentialRecordDataSource(),
                credentialIssuanceResultRepository: CredentialIssuanceResultDataSource()
            )
            VerifiableCredentialsApi.shared.initialize(
                walletConfiguration: WalletConfiguration(),
                verifiableCredentialsService: verifiableCredentialsService)
            
            try await VerifiableCredentialsApi.shared.handlePreAuthorization(
                from: viewController,
                subject: "test",
                url: url
            )
        } catch {
            print(error)
        }
    }
}


#Preview {
    TopView(name: "Preview")
}
