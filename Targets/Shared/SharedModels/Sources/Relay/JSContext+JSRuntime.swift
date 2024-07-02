//
//  JSContext+JSRuntime.swift
//  SharedModels
//
//  Created by Inumaki on 23.03.24.
//

import Foundation
import JavaScriptCore

public enum CustomError: Error {
    case unexpected
}

extension JSContext: JSRuntime {
    public func invokeInstanceMethod<T: Decodable>(functionName: String, args: [Encodable]) throws -> T {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()
        guard let value = try function.call(withArguments: args.map { try encoder.encode($0, into: self) }) else {
            throw CustomError.unexpected
        }
        return try decoder.decode(T.self, from: value)
    }

    public func invokeInstanceMethod(functionName: String, args: [Encodable]) throws {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        try function.call(withArguments: args.map { try encoder.encode($0, into: self) })
    }

    public func invokeInstanceMethodWithPromise(functionName: String, args: [Encodable]) async throws {
        let function = try getFunctionInstance(functionName)
        let encoder = JSValueEncoder()
        guard let promise = try function.call(withArguments: args.map { try encoder.encode($0, into: self) }) else {
            throw CustomError.unexpected
        }
        try await promise.value()
    }

    public func invokeInstanceMethodWithPromise<T: Decodable>(functionName: String, args: [Encodable]) async throws -> T {
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
