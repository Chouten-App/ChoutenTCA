//
//  TCA+Extensions.swift
//
//
//  Created by ErrorErrorError on 4/7/23.
//
//

import ComposableArchitecture
import Foundation
import SwiftUI

extension Effect {
  public static func run(
    animation: Animation? = nil,
    _ operation: @escaping () async throws -> Action
  ) -> Self {
    run { try await $0(operation(), animation: animation) }
  }

  public static func run(
    animation _: Animation? = nil,
    _ operation: @escaping () async throws -> Void
  ) -> Self {
    run { _ in try await operation() }
  }
}

extension Scope {
  public init<ChildAction>(
    _ action: CaseKeyPath<ParentAction, ChildAction>,
    child: () -> Child
  ) where Child.Action == ChildAction, Child.State == ParentState, ParentState: Equatable {
    self.init(state: \.`self`, action: action, child: child)
  }
}

// MARK: Allows to use bindings from subscripts via features

extension Perception.Bindable {
  public subscript<State: ObservableState, Action: FeatureAction & CasePathable, Member: Equatable>(
    dynamicMember keyPath: WritableKeyPath<State, Member>
  ) -> Binding<Member> where Value == Store<State, Action>, Action.ViewAction: BindableAction, Action.ViewAction.State == State {
    .init {
      self.wrappedValue[dynamicMember: keyPath]
    } set: { value in
      self.wrappedValue.send(.view(.set(keyPath, value)))
    }
  }
}
