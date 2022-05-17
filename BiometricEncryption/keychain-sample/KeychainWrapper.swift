//
//  KeychainWrapper.swift
//  BiometricEncryption
//
//  Created by Sukhjeet Singh on 12/04/22.
//

import Foundation

private let SecMatchLimit: String! = kSecMatchLimit as String
private let SecReturnData: String! = kSecReturnData as String
private let SecValueData: String! = kSecValueData as String
private let SecAttrAccessible: String! = kSecAttrAccessible as String
private let SecClass: String! = kSecClass as String
private let SecAttrService: String! = kSecAttrService as String
private let SecAttrGeneric: String! = kSecAttrGeneric as String
private let SecAttrAccount: String! = kSecAttrAccount as String

final class KeychainWrapper {
    
    static let shared = KeychainWrapper()
    
    private let serviceName: String!
    private let accessGroup: String!
    
    private static let defaultServiceName = Bundle.main.bundleIdentifier ?? "TestKeychain"
    
    private convenience init() {
        self.init(serviceName: KeychainWrapper.defaultServiceName)
    }
    
    private init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
    
    public func get(for key: String) -> Data? {
        var query = setupQueryDictionary(for: key)
        
        query[SecMatchLimit] = kSecMatchLimitOne
        query[SecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    public func set(value: Data, key: String) -> Bool {
        var query = setupQueryDictionary(for: key)
        
        query[SecValueData] = value
        
        query[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value: value, key: key)
        } else {
            return false
        }
    }
    
    private func update(value: Data, key: String) -> Bool {
        let query: [String:Any] = setupQueryDictionary(for: key)
        
        let updateDictionary = [SecValueData:value]
        
        let status: OSStatus = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    public func remove(for key: String) -> Bool {
        let queryDictionary: [String:Any] = setupQueryDictionary(for: key)
        
        let status: OSStatus = SecItemDelete(queryDictionary as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    private func setupQueryDictionary(for key: String) -> [String: Any] {
        var queryDictionary: [String: Any] = [SecClass: kSecClassGenericPassword]
        
        queryDictionary[SecAttrService] = serviceName
        
        let encodedIdentifier: Data? = key.data(using: .utf8)
        
        queryDictionary[SecAttrGeneric] = encodedIdentifier
        
        queryDictionary[SecAttrAccount] = encodedIdentifier
        
        return queryDictionary
    }
    
    
}
