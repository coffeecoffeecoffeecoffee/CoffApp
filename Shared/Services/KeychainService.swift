// KeychainService.swift
// Provides simple APIs to store and retrieve sensitive data protected by Face ID/biometrics.

import Foundation
import LocalAuthentication
import Security

enum KeychainKey: String {
    case jwtToken = "science.pixel.espresso.jwtToken"
    case email = "science.pixel.espresso.email"
    case password = "science.pixel.espresso.password"
}

struct KeychainService {
    static let shared = KeychainService()

    // Save data protected with Face ID (biometry) and user presence.
    func save(_ data: Data, for key: KeychainKey) throws {
        let context = LAContext()
        context.interactionNotAllowed = true

        let access = try makeAccessControl()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.rawValue,
            kSecAttrAccessControl as String: access,
            kSecValueData as String: data
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain save failed: \(status)"])
        }
    }

    // Retrieve data; this will prompt Face ID/biometric authentication.
    func load(for key: KeychainKey, localizedReason: String = "Authenticate to access secure data") throws -> Data {
        let context = LAContext()
        // Set localizedReason on platforms where it's available (not watchOS).
        #if !os(watchOS)
        context.localizedReason = localizedReason
        #endif

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain load failed: \(status)"])
        }
        return data
    }

    func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func makeAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        // Require biometry and user presence; data is non-migratable to other devices.
        let flags: SecAccessControlCreateFlags = [.biometryCurrentSet]
        guard let sac = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return sac
    }
}

extension KeychainService {
    func saveString(_ string: String, for key: KeychainKey) throws {
        try save(Data(string.utf8), for: key)
    }

    func loadString(for key: KeychainKey, localizedReason: String = "Authenticate to access secure data") throws -> String {
        let data = try load(for: key, localizedReason: localizedReason)
        return String(decoding: data, as: UTF8.self)
    }
}
