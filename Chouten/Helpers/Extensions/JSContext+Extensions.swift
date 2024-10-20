//
//  JSContext+Extensions.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

enum CustomError: Error {
    case unexpected
}

extension JSContext: JSRuntime {
    func invokeInstanceMethod<T: Decodable>(functionName: String, args: [Encodable]) throws -> T {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()
        guard let value = try function.call(withArguments: args.map { try encoder.encode($0, into: self) }) else {
            throw CustomError.unexpected
        }
        return try decoder.decode(T.self, from: value)
    }

    func invokeInstanceMethod(functionName: String, args: [Encodable]) throws {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        try function.call(withArguments: args.map { try encoder.encode($0, into: self) })
    }

    func invokeInstanceMethodWithPromise(functionName: String, args: [Encodable]) async throws {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        guard let promise = try function.call(withArguments: args.map { try encoder.encode($0, into: self) }) else {
            throw CustomError.unexpected
        }
        try await promise.value()
    }

    func invokeInstanceMethodWithPromise<T: Decodable>(functionName: String, args: [Encodable]) async throws -> T {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()
        guard let promise = try function.call(withArguments: args.map { try encoder.encode($0, into: self) }) else {
            throw CustomError.unexpected
        }
        return try await decoder.decode(T.self, from: promise.value())
    }

    private func getInstance() throws -> JSValue {
        guard let instance = evaluateScript("Instance"), instance.isObject else {
            throw CustomError.unexpected
        }
        return instance
    }

    private func getFunctionInstance(_ functionName: String) throws -> JSValue {
        let instance = try getInstance()
        // Function is a form of an object
        guard let function = instance[functionName], function.isObject else {
            throw CustomError.unexpected
        }
        return function
    }
}
