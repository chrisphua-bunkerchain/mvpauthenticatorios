//
//  JSONHelpers.swift
//  mvpauthenticatorios
//
//  Created by Chris Phua on 21/10/25.
//

import Foundation

enum JSONParseResult {
    case payload(Payload)
    case dictionary([String: Any])
    case array([Any])
    case error(String)
}

func parseScannedJSON(_ raw: String) -> JSONParseResult {
    guard let data = raw.data(using: .utf8) else {
        return .error("Scanned text is not valid UTF-8.")
    }

    // Try decoding into your model first
    if let payload = try? JSONDecoder().decode(Payload.self, from: data) {
        return .payload(payload)
    }

    // Fallback to generic JSON
    do {
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = obj as? [String: Any] {
            return .dictionary(dict)
        } else if let arr = obj as? [Any] {
            return .array(arr)
        } else {
            return .error("JSON parsed but not a dictionary/array.")
        }
    } catch {
        return .error("Not valid JSON: \(error.localizedDescription)")
    }
}

/// Best-effort stringify for display
func stringify(_ value: Any?) -> String {
    guard let v = value else { return "null" }
    switch v {
    case let s as String: return s
    case let n as NSNumber: return n.stringValue
    case let b as Bool: return String(b)
    case let arr as [Any]: return "[\(arr.map { stringify($0) }.joined(separator: ", "))]"
    case let dict as [String: Any]:
        return "{\(dict.map { "\($0): \(stringify($1))" }.joined(separator: ", "))}"
    default:
        return "\(v)"
    }
}
