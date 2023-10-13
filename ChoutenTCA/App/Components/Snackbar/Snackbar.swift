//
//  Snackbar.swift
//  ChoutenTCA
//
//  Created by Inumaki on 08.10.23.
//

import SwiftUI

struct Snackbar: View {
    var show: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("This is a Title")
            Text("Description of the error or something")
                .lineLimit(1)
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: show ? 70 : 0)
        .background(.blue)
        .clipped()
    }
}

#Preview {
    VStack {
        Snackbar()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
}
