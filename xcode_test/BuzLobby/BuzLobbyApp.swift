import SwiftUI

@main
struct BuzLobbyApp: App {
    var body: some Scene {
        WindowGroup {
            LobbyView()
                .preferredColorScheme(.dark)
        }
    }
}
