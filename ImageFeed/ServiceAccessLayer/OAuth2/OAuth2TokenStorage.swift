import Foundation

class OAuth2TokenStorage {
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "OAuth2Token")
        }
        get {
            UserDefaults.standard.string(forKey: "OAuth2Token")
        }
    }
}
