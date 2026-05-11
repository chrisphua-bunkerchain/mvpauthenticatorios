//
//  ContentView.swift
//  mvpauthenticatorios
//
//  Created by Chris Phua on 21/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    
    @State private var result = ""
    @State private var lastScannedText: String = ""
    @State private var parsedDict: [String: Any] = [:]
    @State private var parsedPayload: Payload?
    @State private var parsedArray: [Any] = []
    @State private var showScanner = false
    @State private var showPopup = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if !result.isEmpty { Text(result) }
                    Button("MVP App Installed?") {
                        if canOpenMarineVesselPass() {
                            result = "✅ MVP installed"
                        } else {
                            result = "❌ MVP not installed"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if showScanner {
                        QRScannerView { scanned in
                            handle(scanned: scanned)
                            showScanner = false
                        }
                        .frame(height: 320)
                        .cornerRadius(12)
                        .shadow(radius: 6)
                        .padding()
                    } else {
                        Button {
                            showScanner = true
                        } label: {
                            Text("Scan MVP Authenticator's QR Code")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Authenticate with MVP Authenticator") {
                        startSession()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if !lastScannedText.isEmpty {
                        Group {
                            Text(lastScannedText)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                    
                    if let error = errorMessage {
                        Text(error).foregroundColor(.red).padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .navigationTitle("iOS")
                // 👇 Handle deep link right here
                .onOpenURL { url in
                    handleDeepLink(url)
                }
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("📩 Received URL:", url.absoluteString)
        
        // Example: mvpauthenticatorios://callback?identity=1234567&code=123456&codeType=imoNumber&verifyStatus=true
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let status = components.queryItems?.first(where: { $0.name == "verifyStatus" })?.value {
            if status == "true" {
                result = "✅ Verification success"
            } else {
                result = "❌ Verification failed"
            }
        }
    }
    
    private func handle(scanned: String) {
        lastScannedText = scanned
        parsedDict = [:]
        parsedPayload = nil
        parsedArray = []
        errorMessage = nil
        
        switch parseScannedJSON(scanned) {
        case .payload(let p): parsedPayload = p
        case .dictionary(let d): parsedDict = d
        case .array(let a): parsedArray = a
        case .error(let msg): errorMessage = msg
        }
        
        print("Scanned Text:", lastScannedText)
    }
    
    private func startSession() {
        if (parsedDict.isEmpty) {
            errorMessage = "Please scan QR code!"
            return
        }
        
        // Add your app’s callback scheme
        let scheme = "mvpauthenticatorios" // your app's registered URL scheme
        let callback = "\(scheme)://callback"
        
        var comps = URLComponents()
        comps.scheme = "MarineVesselPass"
        comps.host   = "verify"
        comps.queryItems = [
            .init(name: "code", value: stringify(parsedDict["code"])),
            .init(name: "codeType", value: stringify(parsedDict["codeType"])),
            .init(name: "imoNumber", value: stringify(parsedDict["imoNumber"])),
            .init(name: "shipMvpNumber", value: stringify(parsedDict["shipMvpNumber"])),
            .init(name: "callSign", value: stringify(parsedDict["callSign"])),
            .init(name: "mmsi", value: stringify(parsedDict["mmsi"])),
            .init(name: "licenseNumber", value: stringify(parsedDict["licenseNumber"])),
            .init(name: "accountNumber", value: stringify(parsedDict["accountNumber"])),
            .init(name: "vesselName", value: stringify(parsedDict["vesselName"])),
            .init(name: "position", value: stringify(parsedDict["position"])),
            .init(name: "getInfo", value: stringify(parsedDict["getInfo"])),
            .init(name: "appName", value: "demo_broadcast"),
            .init(name: "bundleId", value: Bundle.main.bundleIdentifier),
            .init(name: "deviceId", value: UIDevice.current.identifierForVendor?.uuidString),
            .init(name: "scheme", value: scheme),
            .init(name: "callback", value: callback)
        ]
        guard let url = comps.url else { result = "Bad deeplink"; return }
        // Optional: check install with canOpenURL (needs LSApplicationQueriesSchemes)
        if canOpenMarineVesselPass() {
            openURL(url)
        } else {
            result = "MarineVesselPass app not installed."
        }
    }
    
    private func canOpenMarineVesselPass() -> Bool {
        if let url = URL(string: "MarineVesselPass://"),
           UIApplication.shared.canOpenURL(url) {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    ContentView()
}
