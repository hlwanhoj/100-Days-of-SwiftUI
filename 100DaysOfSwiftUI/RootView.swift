//
//  RootView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 23/9/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("WeSplit", destination: WeSplitView())
            }
            .navigationTitle("Menu")
        }
    }
}

#Preview {
    RootView()
}
