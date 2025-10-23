//
//  Payload.swift
//  mvpauthenticatorios
//
//  Created by Chris Phua on 21/10/25.
//

import Foundation

struct Payload: Codable, Identifiable {
    var id: String
    var name: String
    var extra: String?
}
