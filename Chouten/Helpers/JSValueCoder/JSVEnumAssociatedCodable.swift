//
//  JSVEnumAssociatedCodable.swift
//
//
//  Created by ErrorErrorError on 11/11/23.
//
//

import Foundation

 protocol JSValueEnumCodingKey: CodingKey {
  static var type: Self { get }
}

//  protocol JSVEnumAssociatedEncodable: Encodable {}
//  protocol JSVEnumAssociatedDecodable: Decodable {}
//
// extension JSVEnumAssociatedEncodable {
// }
//
//  typealias JSVEnumAssociatedCodable = JSVEnumAssociatedEncodable & JSVEnumAssociatedDecodable
