//
//  ModuleSheetFeature+View.swift
//
//
//  Created by Inumaki on 19.10.23.
//
// swiftlint:disable identifier_name

import Architecture
import ComposableArchitecture
import Kingfisher
import ModuleClient
import SharedModels
import SwiftUI

// MARK: - ModuleSheetFeature.View + View

extension ModuleSheetFeature.View: View {
  public var body: some View {
    WithPerceptionTracking {
      GeometryReader { proxy in
        let height = proxy.frame(in: .global).height

        VStack {
          // Title bar
          HStack {
            if let module = store.selectedModule {
              Text(module.name)
                .font(.title2)
                .fontWeight(.bold)
            } else {
              Text("No Module Selected")
                .font(.title2)
                .fontWeight(.bold)
            }

            Spacer()
          }
          .padding()
          .background(.regularMaterial)

          ScrollView {
            VStack {
              ModuleList(type: "Video", store.availableModules)
              ModuleList(type: "Book", store.availableModules)
              ModuleList(type: "Text", store.availableModules)
            }
          }
          .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .overlay(alignment: .top) {
          ZStack {
            Color.clear

            RoundedRectangle(cornerRadius: 4)
              .frame(
                maxWidth: 40,
                maxHeight: 6
              )
              .padding(.top, 4)
              .padding(.leading, 0)
          }
          .frame(
            maxWidth: .infinity,
            maxHeight: 20
          )
          .contentShape(Rectangle())
        }
        .animation(.spring(), value: animateScroll)
        .offset(y: height - minimum)
        .offset(y: offset)
        .gesture(
          DragGesture(minimumDistance: 0.01)
            .onChanged { value in
              // suppress overscroll and underscroll
              animateScroll = false
              offset = lastOffset + value.translation.height
            }
            .onEnded { _ in
              let maxHeight = height - minimum
              let actualOffset = -offset

              // FIXME: improve drag gesture based on velocity (predictedEndTranslation)

              if actualOffset < 0 {
                offset = 0
              } else if actualOffset > maxHeight {
                offset = -maxHeight
              } else if actualOffset < maxHeight / 2 {
                offset = -maxHeight / 3
              } else {
                offset = -maxHeight
              }

              lastOffset = offset
              animateScroll = true
            }
        )
      }
      .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 64, alignment: .bottom)
      .clipped()
      .ignoresSafeArea(.all, edges: .bottom)
      .onAppear {
        send(.onAppear)
      }
    }
  }
}

extension ModuleSheetFeature.View {
  @MainActor
  func ModuleList(type: String, _ availableModules: [Module]) -> some View {
    VStack {
      let filteredModules = availableModules.filter { $0.type == type }
      Text(type)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

      if !filteredModules.isEmpty {
        VStack {
          ForEach(0..<filteredModules.count, id: \.self) { index in
            let module = filteredModules[index]

            ModuleButton(module: module)

            // ModuleSelectorButton(
            // store: Store(
            // initialState: ModuleSelectorButtonDomain.State(module: filteredModules[index]),
            // reducer: ModuleSelectorButtonDomain()
            // )
            // )
          }
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
      } else {
        VStack(spacing: 20) {
          Text("(ㅠ﹏ㅠ)")
            .font(.title3)
            .fontWeight(.bold)

          Text("No \(type) Modules are installed...")
            .font(.subheadline)
            .opacity(0.7)
        }
        .padding(.vertical, 30)
      }
    }
  }

  @MainActor
  func ModuleButton(module: Module) -> some View {
    Button {
      send(.selectModule(module: module))
    } label: {
      HStack(alignment: .center) {
        if let icon = module.icon.flatMap({ URL(string: $0) }) {
          KFImage(icon)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 40, height: 40)
            .cornerRadius(12)
        } else {
          ZStack {
            Color(.white).opacity(0.6)
              .blur(radius: 6)

            Image(systemName: "questionmark")
              .padding(.vertical, 12)
              .padding(.horizontal, 14)
              .foregroundColor(.indigo)
          }
          .fixedSize()
          .cornerRadius(40)
        }

        VStack(alignment: .leading) {
          Text(module.name)
            .fontWeight(.bold)
            .lineLimit(1)

          HStack {
            Text(module.general.author)
              .opacity(0.7)
              .font(.system(size: 12, weight: .semibold))
              .lineLimit(1)
            Text("v\(module.version)")
              .opacity(0.7)
              .font(.system(size: 12, weight: .semibold))
          }
        }
        .foregroundColor(.primary)

        Spacer()

        Button {
          // open popup
          // showPopover = true
        } label: {
          Image(systemName: "ellipsis")
            .padding(12)
            .foregroundColor(
              .white
            )
            .background {
              Circle()
                .fill(
                  .indigo
                )
            }
        }
      }
      .padding(12)
      .frame(
        maxWidth: .infinity,
        alignment: .leading
      )
    }
    .frame(
      maxWidth: .infinity,
      alignment: .topLeading
    )
    .buttonStyle(PlainButtonStyle())
    .foregroundColor(
      .indigo
    )
  }
}

#Preview {
  VStack(spacing: 0) {
    ModuleSheetFeature.View(
      store: .init(
        initialState: .init(),
        reducer: { ModuleSheetFeature() }
      )
    )

    Rectangle()
      .fill(.regularMaterial)
      .frame(height: 80)
      .background(.regularMaterial)
      .ignoresSafeArea()
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
}
