import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: "AuthToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "AuthToken")
            }
        }
        get {
            KeychainWrapper.standard.string(forKey: "AuthToken")
        }
    }
}
