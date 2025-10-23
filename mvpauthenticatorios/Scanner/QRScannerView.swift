//
//  QRScannerView.swift
//  mvpauthenticatorios
//
//  Created by Chris Phua on 21/10/25.
//

import SwiftUI

struct QRScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = QRScannerViewController
    var onFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onFound = { value in
            DispatchQueue.main.async { onFound(value) }
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}
