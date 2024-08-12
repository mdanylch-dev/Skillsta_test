//
//  TCA_PlayerApp.swift
//  TCA_Player
//
//  Created by Mykyta Danylchenko on 10.08.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_PlayerApp: App {
    var body: some Scene {
        WindowGroup {
            PlayerView(
                store: Store(initialState: PlayerReducer.State() , reducer: { PlayerReducer() })
            )
        }
    }
}
