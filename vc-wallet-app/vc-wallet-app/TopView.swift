//
//  TopView.swift
//  vc-wallet-app
//
//  Created by 小林弘和 on 2024/10/18.
//


import SwiftUI
import SwiftData
import VisionKit
import VcWalletLibrary

struct TopView: View {
    @State private var isShowingScanner = false
    
    var body: some View {
        Button(action: {
            print("on click")
            isShowingScanner = true
        },
               label: {
            Text("pre-authorized")
        }
        )
        .padding()
        .sheet(isPresented: $isShowingScanner) {
            QRCodeReader(onRecognize: { value in
                guard let url = value else {
                    return
                }
                handlePreAuthorization(url: url)
                isShowingScanner = false
            }).ignoresSafeArea(.all)
        }
    }
}

struct QRCodeReader: UIViewControllerRepresentable {
    
    private let onRecognize: (String?) -> Void
    
    public init(onRecognize: @escaping (String?) -> Void) {
        self.onRecognize = onRecognize
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        viewController.delegate = context.coordinator
        
        DispatchQueue.main.async {
            try? viewController.startScanning()
        }
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: QRCodeReader
        
        fileprivate init(parent: QRCodeReader) {
            self.parent = parent
        }
        
        public func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = allItems.first else { return }
            switch item {
            case .barcode(let recognizedCode):
                parent.onRecognize(recognizedCode.payloadStringValue)
            default:
                break
            }
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
    TopView()
}
