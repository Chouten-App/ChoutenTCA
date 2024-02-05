//
//  NavigationBackButton.swift
//
//
//  Created by Inumaki on 20.12.23.
//

import SwiftUI

public struct NavigationBackButton: View {
  public var completion: () -> Void

  public init(completion: @escaping () -> Void) {
    self.completion = completion
  }

  public var body: some View {
    Button {
      completion()
    } label: {
      Image(systemName: "chevron.left")
        .font(.subheadline)
        .foregroundColor(.primary)
        .padding(8)
        .background {
          Circle()
            .fill(.regularMaterial)
        }
    }
  }
}

#Preview {
  NavigationBackButton {}
}
