import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private let authTokenKeyString = "AuthToken"
    
    var token: String? {
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: authTokenKeyString)
            } else {
                KeychainWrapper.standard.removeObject(forKey: authTokenKeyString)
            }
        }
        get {
            KeychainWrapper.standard.string(forKey: authTokenKeyString)
        }
    }
}
