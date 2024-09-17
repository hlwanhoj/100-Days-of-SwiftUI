//
//  _00DaysOfSwiftUIApp.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 5/9/2024.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct _00DaysOfSwiftUIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootFeature.State(),
                    reducer: { RootFeature() }
                )
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
