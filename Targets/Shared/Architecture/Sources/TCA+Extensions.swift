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
    (self[dynamicMember: keyPath] as _StoreBindable_Perception<State, Action, Member>)
      .sending(\Action.Cases.view.binding[member: keyPath])
  }
}

extension CasePaths.Case where Value: FeatureAction & CasePathable {
  fileprivate var view: CasePaths.Case<Value.ViewAction> {
    .init { action in
      Value.view(action)
    } extract: { root in
      AnyCasePath(unsafe: Value.view).extract(from: root)
    }
  }
}

extension CasePaths.Case where Value: BindableAction {
  fileprivate var binding: CasePaths.Case<BindingAction<Value.State>> {
    .init { value in
      Value.binding(value)
    } extract: { root in
      root.binding
    }
  }
}

extension CasePaths.Case {
  fileprivate subscript<Root: ObservableState, Member: Equatable & Sendable>(
    member keyPath: WritableKeyPath<Root, Member>
  ) -> CasePaths.Case<Member> where Value == BindingAction<Root> {
    .init { (member: Member) in
      Value.set(keyPath, member)
    } extract: { (root: Value) in
      Value.allCasePaths[dynamicMember: keyPath].extract(from: root)
    }
  }
}
