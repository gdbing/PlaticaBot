//
//  PlaticaBotApp.swift
//  PlaticaBot
//
//  Created by Miguel de Icaza on 3/21/23.
//
#if os(iOS)
import SwiftUI

@main
struct PlaticaBotApp: App {
    @StateObject private var settings = SettingsStorage()
    @State private var showSettings: Bool = false
    var body: some Scene {
        WindowGroup (id: "chat") {
            NavigationStack {
                ContentView()
                    .sheet (isPresented: $showSettings) {
                        iOSGeneralSettings(settingsShown: $showSettings, dismiss: true)
                    }
                    .onAppear {
                        showSettings = settings.apiKey == ""
                    }
            }
            .environmentObject(settings)
        }
    }
}
#endif
