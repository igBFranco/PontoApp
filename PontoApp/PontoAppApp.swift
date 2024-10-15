//
//  PontoAppApp.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 20/09/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PontoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        UITabBar.appearance().tintColor = UIColor(Color(hex: "5300FF"))
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
