//
//  ChoutenAlert.swift
//
//
//  Created by Inumaki on 12.10.23.
//

import SwiftUI

// MARK: - AlertAction

public struct AlertAction {
  let text: String
  let action: ()
}

// MARK: - ChoutenAlert

public struct ChoutenAlert: View {
  public let title: String
  public let message: String

  public let actions: [AlertAction]

  public init(title: String, message: String, actions: [AlertAction]) {
    self.title = title
    self.message = message
    self.actions = actions
  }

  public var body: some View {
    VStack {
      Text(title)
        .font(.title)
        .fontWeight(.bold)
        .padding(.top, 20)
        .padding(.bottom, 8)

      Text(message)
        .font(.subheadline)
        .opacity(0.7)

      Button {} label: {
        Text("Download")
          .foregroundColor(.black)
          .padding(.vertical, 12)
          .frame(maxWidth: .infinity)
          .background {
            RoundedRectangle(cornerRadius: 8)
              .fill(.white)
          }
      }
    }
    .padding(12)
    .frame(maxWidth: 300)
    .background(.regularMaterial)
    .overlay(alignment: .topTrailing) {
      Image(systemName: "xmark")
        .font(.caption2)
        .padding(6)
        .background {
          Circle()
            .fill(.gray)
        }
        .padding(12)
    }
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }
}
