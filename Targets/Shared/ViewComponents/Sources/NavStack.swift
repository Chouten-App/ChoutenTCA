//
//  NavStack.swift
//  ViewComponents
//
//  Created by ErrorErrorError on 2/8/24.
//
//

@_spi(Internals)
import ComposableArchitecture
import OrderedCollections
import SwiftUI

public struct NavStack<State: ObservableState, Action, Root: View, Destination: View>: View {
  @SwiftUI.Binding private var store: Store<StackState<State>, StackAction<State, Action>>
  private let root: () -> Root
  private let destination: (Store<State, Action>) -> Destination

  public var body: some View {
    if #available(iOS 16.0, *) {
      NavigationStack(path: $store) {
        root()
      } destination: { store in
        destination(store)
      }
    } else {
      NavigationView {
        root()
          .background {
            let ids = store.currentState.ids

            DrilledView(set: ids, index: ids.startIndex) { id, transaction in
              store.send(.popFrom(id: id), transaction: transaction)
            } destination: { id in
              if var element = store.currentState[id: id] {
                destination(
                  store.scope(
                    id: store.id(state: \.[id: id], action: \.[id: id]),
                    state: ToState {
                      element = $0[id: id] ?? element
                      return element
                    },
                    action: { .element(id: id, action: $0) },
                    isInvalid: { !$0.ids.contains(id) }
                  )
                )
              }
            }
          }
      }
      .navigationViewStyle(.stack)
    }
  }
}

@MainActor
private struct DrilledView<Destination: View>: View {
  typealias Elements = OrderedSet<StackElementID>
  let set: Elements
  let index: Elements.Index
  let popped: (Elements.Element, Transaction) -> Void
  @ViewBuilder let destination: (Elements.Element) -> Destination

  var id: Elements.Element? {
    if set.startIndex <= index, index < set.endIndex {
      set[index]
    } else {
      nil
    }
  }

  @MainActor var body: some View {
    NavigationLink(
      isActive: .init(
        get: { id.flatMap(set.contains) ?? false },
        set: { isActive, transaction in
          if let id, !isActive {
            popped(id, transaction)
          }
        }
      )
    ) {
      if let id {
        destination(id)
          .background(
            Self(
              set: set,
              index: set.index(after: index),
              popped: popped,
              destination: destination
            )
            .hidden()
          )
      }
    } label: {
      EmptyView()
    }
    #if os(iOS)
    .isDetailLink(false)
    #endif
    .hidden()
  }
}
