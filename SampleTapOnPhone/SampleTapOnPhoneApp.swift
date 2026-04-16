//
//  SampleTapOnPhoneApp.swift
//  SampleTapOnPhone
//
//  Sample application demonstrating integration with the Getnet
//  TapOnPhone iOS SDK (version 0.1.0-alpha-0).
//

import SwiftUI

@main
struct SampleTapOnPhoneApp: App {
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}
