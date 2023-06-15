//
//  LogsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 07.06.23.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct LogsView: View {
    let store: StoreOf<LogsDomain>
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                ScrollView {
                    if viewStore.logs.count > 0 {
                        VStack(alignment: .leading) {
                            ForEach(0..<viewStore.logs.count, id:\.self) { index in
                                ZStack {
                                    if viewStore.logs[index].type == "error" {
                                        Color(hex: Colors.Error.dark)
                                    } else {
                                        Color(hex: Colors.SurfaceContainer.dark)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            KFImage(URL(string: viewStore.logs[index].moduleIconPath))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 34)
                                                .cornerRadius(8)
                                            
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(
                                                    viewStore.logs[index].type == "error" ? "Error" :
                                                        "Log"
                                                )
                                                .fontWeight(.bold)
                                                Text(viewStore.logs[index].moduleName)
                                                    .font(.caption)
                                                    .opacity(0.7)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(viewStore.logs[index].time)
                                                .font(.subheadline)
                                                .opacity(0.7)
                                        }
                                        
                                        Text(viewStore.logs[index].msg)
                                            .lineLimit(4)
                                            .multilineTextAlignment(.leading)
                                        
                                        /*
                                         if viewStore.logs[index].lines != nil {
                                         HStack {
                                         Spacer()
                                         
                                         Text("\(globalData.currentFileExecuted)(\(viewStore.logs[index].lines!))")
                                         .font(.caption)
                                         .opacity(0.7)
                                         }
                                         }
                                         */
                                    }
                                    .padding(12)
                                }
                                .foregroundColor(
                                    Color(
                                        hex:
                                            viewStore.logs[index].type == "error" ?
                                        Colors.onError.dark
                                        : Colors.onSurface.dark
                                    )
                                )
                                .cornerRadius(16)
                            }
                        }
                        .padding(.top, 130)
                    } else {
                        VStack {
                            Text("No logs...Yay?")
                        }
                        .foregroundColor(Color(hex: Colors.onSurface.dark))
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height, maxHeight: .infinity, alignment: .center)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background {
                    Color(hex: Colors.Surface.dark)
                }
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                
                                Text("Logs")
                                    .font(.title)
                                    .fontWeight(.semibold)
                            }
                            .padding(.bottom, 8)
                            .padding(.horizontal, 20)
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                        }
                        .padding(.leading, 12)
                        
                        Button {
                            viewStore.send(.setLogs(newList: []))
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.subheadline)
                                
                                Text("Clear Logs")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .foregroundColor(Color(hex: Colors.onSecondaryContainer.dark))
                            .background {
                                Capsule()
                                    .fill(Color(hex: Colors.SecondaryContainer.dark))
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: (viewStore.isDownloadedOnly || viewStore.isIncognito ? 16 : 64) + 92,
                        alignment: .bottomLeading
                    )
                    .background {
                        //Color(hex: Colors.SurfaceContainer.dark)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                    print(viewStore.logs)
                }
            }
        }
    }
}

struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        LogsView(
            store: Store(
                initialState: LogsDomain.State(),
                reducer: LogsDomain()
            )
        )
    }
}
