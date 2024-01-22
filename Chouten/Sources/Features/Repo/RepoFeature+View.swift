//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 14.12.23.
//

import Architecture
import SwiftUI
import ComposableArchitecture
import Kingfisher
import NukeUI
import Shimmer
import ViewComponents
import SharedModels

enum ModuleVersionStatus {
    case upToDate
    case uninstalled
    case updateAvailable
}

extension RepoFeature.View {
    @MainActor
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Repos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Enter Repo url here...", text: .constant("https://example.com"))
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.regularMaterial)
                    }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 140, alignment: .bottomLeading)
            .background(.regularMaterial)
            .padding(.horizontal, -20)
            
            
            // Repos
            ScrollView {
                VStack(alignment: .leading) {
                    // Local Repo
                    HStack {
                        KFImage(URL(string: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text("Local Repository")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Unknown")
                                .opacity(0.7)
                        }
                    }
                    
                    HStack {
                        KFImage(URL(string: "https://i.pinimg.com/736x/1e/33/d0/1e33d05a1efed65b7a5611764a0f051f.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text("Inus Modules")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Inumaki")
                                .opacity(0.7)
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
        .overlay {
            RepoDetails()
        }
    }
}

struct CustomContextMenu: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Text("HMMM")
                .background(.regularMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

extension RepoFeature.View {
    @MainActor
    func RepoDetails() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .bottom, spacing: 20) {
                    KFImage(URL(string: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("Local Repo")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Unknown")
                            .opacity(0.7)
                        
                    }
                }
                .padding(.top, 50)
                .blur(radius: showContextMenu || press ? 4 : 0)
                
                ScrollView(.horizontal) {
                    HStack {
                        let subtypesSet: Set<String> = Set(installedModules.flatMap { $0.subtypes })

                        // Convert the Set back to an array to remove duplicates
                        let uniqueSubtypesArray: [String] = Array(subtypesSet).sorted(using: .localized)
                        
                        ForEach(0..<uniqueSubtypesArray.count, id: \.self) { index in
                            Text(uniqueSubtypesArray[index])
                                .font(.footnote)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    if selectedTags.contains(where: { element in
                                        element == index
                                    }) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.indigo)
                                    } else {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.regularMaterial)
                                    }
                                }
                                .onTapGesture {
                                    if selectedTags.contains(where: { element in
                                        element == index
                                    }) {
                                        selectedTags.removeAll { element in
                                            element == index
                                        }
                                    } else {
                                        selectedTags.append(index)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, -20)
                .blur(radius: showContextMenu || press ? 4 : 0)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .lineLimit(6)
                    .opacity(0.7)
                    .blur(radius: showContextMenu || press ? 4 : 0)
                
                VStack(alignment: .leading) {
                    Text("INSTALLED")
                        .fontWeight(.bold)
                        .opacity(0.7)
                        .blur(radius: showContextMenu || press ? 4 : 0)
                    
                    ForEach(getFilteredModules().enumerated().map { $0 }, id: \.element) { index, module in
                        ModuleButton(module: module, show: $showContextMenu, press: press, hoveredIndex: $hoveredIndex, index: index, state: index == 0 ? ModuleVersionStatus.updateAvailable : ModuleVersionStatus.upToDate)
                            .blur(radius: (showContextMenu || press) && hoveredIndex != index ? 4.0 : 0.0)
                            .zIndex((showContextMenu || press) && hoveredIndex == index ? 10.0 : 1.0)
                            .animation(.easeInOut, value: selectedTags)
                    }
                }
                .animation(.easeInOut, value: selectedTags)
                
                VStack(alignment: .leading) {
                    Text("ALL")
                        .fontWeight(.bold)
                        .opacity(0.7)
                    
                    ForEach(0..<4, id: \.self) { _ in
                        ModuleButtonShimmer()
                    }
                }
                .blur(radius: showContextMenu || press ? 4 : 0)
            }
            .padding()
        }
        .scaleEffect(showContextMenu || press ? 0.95 : 1.0)
        .animation(.easeInOut, value: showContextMenu)
        .animation(.easeInOut, value: press)
        .animation(.easeInOut, value: selectedTags)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.black)
        .overlay(alignment: .top) {
            HStack {
                NavigationBackButton {
                    
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(.regularMaterial)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

public struct ModuleButton: View {
    let module: Module
    @Binding var show: Bool
    @GestureState var press: Bool
    @Binding var hoveredIndex: Int
    let index: Int
    let state: ModuleVersionStatus
    
    public var body: some View {
        HStack(alignment: .center) {
            if let icon = module.icon {
                LazyImage(
                    url: URL(string: icon),
                    transaction: .init(animation: .easeInOut(duration: 0.4))
                ) { state in
                    if let image = state.image {
                        image
                            .resizable()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(module.name)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                HStack {
                    Text(module.general.author)
                        .opacity(0.7)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    Text(module.version)
                        .opacity(0.7)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            switch module.updateStatus {
            case .upToDate:
                Button {
                    // open popup
                    //showPopover = true
                } label: {
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(6)
                        .background {
                            Circle()
                                .fill(.indigo)
                        }
                }
            case .uninstalled:
                Button {
                    // open popup
                    //showPopover = true
                } label: {
                    Text("Install")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background {
                            Capsule()
                                .fill(.indigo)
                        }
                }
            case .updateAvailable:
                Button {
                    // open popup
                    //showPopover = true
                } label: {
                    Text("Update")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background {
                            Capsule()
                                .fill(.indigo)
                        }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .contentShape(Rectangle())
        .overlay(alignment: .top) {
            if show && hoveredIndex == index {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 600)
                    .alignmentGuide(.top) {$0[.bottom]}
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hoveredIndex = -1
                        show = false
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if show && hoveredIndex == index {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 600)
                    .alignmentGuide(.bottom) {$0[.top]}
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hoveredIndex = -1
                        show = false
                    }
            }
        }
        .scaleEffect((press || show) && hoveredIndex == index ? 1.05 : 1.0)
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Button {
                    print("Options")
                } label: {
                    HStack {
                        Text("Options")
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                    }
                    .foregroundColor(.primary)
                }
                
                Rectangle()
                    .fill(.gray)
                    .frame(height: 1)
                    .opacity(0.16)
                
                HStack {
                    Text("Delete")
                    
                    Spacer()
                    
                    Image(systemName: "trash")
                }
                .foregroundColor(.red)
            }
            .padding(12)
            .frame(width: 180)
            .background(.regularMaterial)
            .cornerRadius(12)
            .padding(.bottom, 12)
            .alignmentGuide(.top) {$0[.bottom]}
            .opacity(show && hoveredIndex == index ? 1.0 : 0.0)
        }
        .animation(.easeInOut, value: press)
        .gesture(
            LongPressGesture(minimumDuration: 0.4)
                .updating($press) { currentState, gestureState, transaction in
                    //hoveredIndex = index
                    gestureState = currentState
                }
                .onEnded { _ in
                    hoveredIndex = index
                    show.toggle()
                    print(index)
                    print(hoveredIndex)
                }
        )
    }
}

struct BlurredContentOverlay: UIViewRepresentable {
    let blurRadius: CGFloat
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        let snapshotView = UIApplication.shared.windows.first?.rootViewController?.view.snapshotView(afterScreenUpdates: true)
        
        let blurredImage = snapshotView?.applyBlur(radius: blurRadius)
        let blurredImageView = UIImageView(image: blurredImage)
        
        uiView.contentView.addSubview(blurredImageView)
        blurredImageView.frame = uiView.contentView.bounds
    }
}

extension UIView {
    func applyBlur(radius: CGFloat) -> UIImage? {
        let imageRenderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = imageRenderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image.applyBlur(radius: radius)
    }
}

extension UIImage {
    func applyBlur(radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

extension RepoFeature.View {
    @MainActor
    func ModuleButtonShimmer() -> some View {
        HStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 40, height: 40)
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.3)
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 120, height: 16)
                    .redacted(reason: .placeholder)
                    .shimmering()
                    .opacity(0.2)
                
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 40, height: 12)
                        .redacted(reason: .placeholder)
                        .shimmering()
                        .opacity(0.2)
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 40, height: 12)
                        .redacted(reason: .placeholder)
                        .shimmering()
                        .opacity(0.2)
                }
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            
            Circle()
                .frame(width: 28)
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.3)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}

#Preview {
    RepoFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { RepoFeature() }
        )
    )
}
