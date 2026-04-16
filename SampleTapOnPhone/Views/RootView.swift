//
//  RootView.swift
//  SampleTapOnPhone
//
//  Top level navigation. When the user is not authenticated we show
//  the authentication screen, otherwise we show the transaction tabs.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    AuthenticationView()
                }
            }
        }
    }
}

#Preview {
    RootView().environmentObject(SessionStore())
}
