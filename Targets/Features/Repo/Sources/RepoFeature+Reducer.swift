//
//  RepoFeature+Reducer.swift
//
//
//  Created by Inumaki on 14.12.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI

extension RepoFeature: Reducer {
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case _:
          .none
        }
      }
    }
  }
}
