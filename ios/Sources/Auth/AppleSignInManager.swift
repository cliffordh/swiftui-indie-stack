//
//  AppleSignInManager.swift
//  MyApp
//
//  Handles Apple Sign-In flow with secure nonce generation.
//

import AuthenticationServices
import CryptoKit

class AppleSignInManager: NSObject {

    static let shared = AppleSignInManager()

    /// Un-hashed nonce for the current sign-in request
    fileprivate static var currentNonce: String?

    /// Current un-hashed nonce (read-only)
    static var nonce: String? {
        currentNonce
    }

    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    private override init() {
        super.init()
    }

    /// Request Apple authorization using async/await
    func requestAppleAuthorization() async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let appleIdProvider = ASAuthorizationAppleIDProvider()
            let request = appleIdProvider.createRequest()
            requestAppleAuthorization(request)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }

    /// Configure the Apple Sign-In request with scopes and nonce
    func requestAppleAuthorization(_ request: ASAuthorizationAppleIDRequest) {
        AppleSignInManager.currentNonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(AppleSignInManager.currentNonce!)
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInManager: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
    }
}

// MARK: - Nonce Generation

extension AppleSignInManager {

    /// Generate a cryptographically secure random nonce string
    /// - Parameter length: Length of the nonce (default: 32)
    /// - Returns: Random nonce string
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    /// SHA-256 hash of the input string
    /// - Parameter input: String to hash
    /// - Returns: Hexadecimal hash string
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
