//
//  _Client.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

import Foundation

protocol Client: Target {}

extension Client {
    var path: String? {
        "Sources/Clients/\(self.name)"
    }
}
