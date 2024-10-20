//
//  JSRuntime.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

@dynamicMemberLookup
protocol JSRuntime {
    func invokeInstanceMethod<T: Decodable>(functionName: String, args: [any Encodable]) throws -> T
    func invokeInstanceMethod(functionName: String, args: [any Encodable]) throws

    func invokeInstanceMethodWithPromise(functionName: String, args: [any Encodable]) async throws
    func invokeInstanceMethodWithPromise<T: Decodable>(functionName: String, args: [any Encodable]) async throws -> T
}

extension JSRuntime {
    subscript<V: Decodable>(dynamicMember member: String) -> (any Encodable...) async throws -> V {
        { try await invokeInstanceMethodWithPromise(functionName: member, args: $0) }
    }

    subscript(dynamicMember member: String) -> (any Encodable...) async throws -> Void {
        { try await invokeInstanceMethodWithPromise(functionName: member, args: $0) }
    }
}
