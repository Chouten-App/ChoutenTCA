//
//  NextChapterView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 17.09.23.
//

import SwiftUI
import ActivityIndicatorView

enum ChapterLoadingStatus : CustomStringConvertible {
    case notStarted
    case loading
    case success
    case error
    
    var description : String {
        switch self {
            // Use Internationalization, as appropriate.
            case .notStarted: return "Not Started"
            case .loading: return "Loading..."
            case .success: return "Done"
            case .error: return "Error"
        }
    }
}

struct NextChapterView: View {
    let currentChapter: String
    let nextChapter: String
    @StateObject var Colors = DynamicColors.shared
    @State var loadingStatus: ChapterLoadingStatus = .notStarted
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Chapter Complete")
                .font(.title2)
                .fontWeight(.bold)
            Text(currentChapter)
                .fontWeight(.semibold)
                .opacity(0.7)
            
            Spacer()
            
            Image("reading")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
            
            Spacer()
            
            VStack {
                Text("Next up!")
                    .fontWeight(.semibold)
                    .opacity(0.7)
                Text(nextChapter)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Thanks to Mantton for the UI Idea")
                    .font(.caption)
                    .opacity(0.7)
                    .padding(.vertical, 20)
            }
            
            if loadingStatus != .notStarted {
                VStack {
                    if loadingStatus == .loading {
                        ActivityIndicatorView(
                            isVisible: .constant(true),
                            type: .growingArc(Color(hex: Colors.onSurface.dark), lineWidth: 2)
                        )
                        .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: loadingStatus == .error ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.title2)
                    }
                    
                    Text(loadingStatus.description)
                        .fontWeight(.bold)
                }
                .foregroundColor(
                    loadingStatus == .error
                    ? Color.red : (
                        loadingStatus == .loading
                        ? Color(hex: Colors.onSurface.dark)
                        : Color.green
                    )
                )
            }
            
            Spacer()
        }
        .foregroundColor(Color(hex: Colors.onSurface.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.black
                .ignoresSafeArea()
        }
        .onAppear {
            loadingStatus = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                loadingStatus = .success
            }
        }
    }
}

struct NextChapterView_Previews: PreviewProvider {
    static var previews: some View {
        NextChapterView(
            currentChapter: "Chapter 1: Prologue",
            nextChapter: "Chapter 2: Next Level"
        )
    }
}
