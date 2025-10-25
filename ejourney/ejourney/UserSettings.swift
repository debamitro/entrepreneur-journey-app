//
//  UserSettings.swift
//  ejourney
//
//  Created by Claude on 10/25/25.
//

import Foundation
import SwiftUI

@Observable
class UserSettings {
    static let shared = UserSettings()
    
    var isEntrepreneur: Bool {
        didSet {
            UserDefaults.standard.set(isEntrepreneur, forKey: "isEntrepreneur")
        }
    }
    
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    var darkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }
    
    var selectedTheme: String {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    private init() {
        self.isEntrepreneur = UserDefaults.standard.bool(forKey: "isEntrepreneur")
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Default"
    }
    
    var userTypeDisplayName: String {
        return isEntrepreneur ? "Entrepreneur" : "Wannapreneur"
    }
}