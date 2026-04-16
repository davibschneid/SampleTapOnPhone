//
//  MainTabView.swift
//  SampleTapOnPhone
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        TabView {
            NavigationStack {
                TransactionView()
            }
            .tabItem {
                Label("Transação", systemImage: "creditcard")
            }

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Conta", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    MainTabView().environmentObject({
        let s = SessionStore()
        s.isAuthenticated = true
        s.terminalDescription = "Loja Demo • Terminal 00000001"
        return s
    }())
}
