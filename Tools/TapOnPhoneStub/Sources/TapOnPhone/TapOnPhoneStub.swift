//
//  TapOnPhoneStub.swift
//
//  CI-only stub of the Getnet TapOnPhone iOS SDK. All symbols mirror
//  the signatures documented in the `SDK Tap On Phone iOS
//  Documentation - 0.1.0-alpha-0` PDF so the sample app can be
//  compiled on CI without access to the proprietary framework.
//
//  Every function body here is intentionally a no-op that returns a
//  mocked result. DO NOT use this module in production — replace it
//  with the real `TapOnPhone.xcframework` distributed by Getnet.
//

import Foundation

// MARK: - Authentication payloads

public struct AuthenticationTokens: Codable {
    public let ssoToken: String
    /// This property will be removed in future versions of the SDK.
    public let expiresIn: Int
    /// This property will be removed in future versions of the SDK.
    public let creationDate: Date

    public init(ssoToken: String, expiresIn: Int, creationDate: Date) {
        self.ssoToken = ssoToken
        self.expiresIn = expiresIn
        self.creationDate = creationDate
    }
}

public protocol SilentLoginParamsProtocol {
    var tokens: AuthenticationTokens { get }
    var appToken: String { get }
    var document: String { get }
    var packageName: String { get }
    var deviceName: String? { get }
    var nickName: String? { get }
    var user: String? { get }
}

public struct SilentLoginParams: SilentLoginParamsProtocol {
    public let tokens: AuthenticationTokens
    public let appToken: String
    public let document: String
    public let packageName: String
    public let deviceName: String?
    public let nickName: String?
    public let user: String?

    public init(
        tokens: AuthenticationTokens,
        appToken: String,
        document: String,
        packageName: String,
        deviceName: String? = nil,
        nickName: String? = nil,
        user: String? = nil
    ) {
        self.tokens = tokens
        self.appToken = appToken
        self.document = document
        self.packageName = packageName
        self.deviceName = deviceName
        self.nickName = nickName
        self.user = user
    }
}

public struct ConfigurationLoginSDK {
    public let token: TokenConfiguration?
    public let codeTerminal: String?
    public let storeName: String?

    public struct TokenConfiguration {
        public let prefix: String?
        public init(prefix: String? = nil) { self.prefix = prefix }
    }

    public init(
        token: TokenConfiguration? = nil,
        codeTerminal: String? = nil,
        storeName: String? = nil
    ) {
        self.token = token
        self.codeTerminal = codeTerminal
        self.storeName = storeName
    }
}

public struct LoginResult {
    public let isSuccessful: Bool
    public let statusCode: Int
    public let message: String
    public let configuration: ConfigurationLoginSDK?

    public init(
        isSuccessful: Bool,
        statusCode: Int,
        message: String,
        configuration: ConfigurationLoginSDK?
    ) {
        self.isSuccessful = isSuccessful
        self.statusCode = statusCode
        self.message = message
        self.configuration = configuration
    }
}

public enum AuthenticationError: Error {
    case invalidCredentials
    case networkError(Error)
    case invalidResponse
    case serverError(String)
    case tokenExpired
}

// MARK: - MonoEC

public struct MonoECAuthParameters {
    public let companyDocument: String
    public let username: String
    public let password: String
    public let storeCode: String?

    public init(
        companyDocument: String,
        username: String,
        password: String,
        storeCode: String?
    ) {
        self.companyDocument = companyDocument
        self.username = username
        self.password = password
        self.storeCode = storeCode
    }
}

public struct MonoECConfiguration {
    public let storeName: String?
    public let terminalCode: String?

    public init(storeName: String? = nil, terminalCode: String? = nil) {
        self.storeName = storeName
        self.terminalCode = terminalCode
    }
}

public struct MonoECAuthResult {
    public let isSuccessful: Bool
    public let statusCode: Int
    public let message: String
    public let configuration: MonoECConfiguration?

    public init(
        isSuccessful: Bool,
        statusCode: Int,
        message: String,
        configuration: MonoECConfiguration?
    ) {
        self.isSuccessful = isSuccessful
        self.statusCode = statusCode
        self.message = message
        self.configuration = configuration
    }
}

// MARK: - Transactions

public enum InstallmentType {
    case store
    case administrative
    case upfront
    case merchantInstallment
}

public enum CardPaymentStatus: Equatable {
    case approved
    case denied
    case error
    case cancelled
    case unknown
}

public struct CTFResult {
    public let operationCode: String
    public let establishmentCode: String
    public let storeCode: String
    public let terminalCode: String
    public let authorizationCode: String
    public let acquirerCode: String
    public let authorizationResponseCode: String
    public let extendedErrorCode: String
    public let nsuCTF: String
    public let nsuHost: String
    public let brandName: String
    public let acquirerName: String
    public let maskedPan: String
    public let installmentCount: Int
    public let transactionNumber: Int
    public let transactionDate: String
    public let transactionTime: String
    public let totalAmount: Decimal
    public let transactionAmount: Decimal
    public let displayMessages: [String]
}

public struct CardPaymentResult {
    public let returnCode: String
    public let customerReceipt: String
    public let merchantReceipt: String
    public let reducedReceipt: String
    public let ctf: CTFResult
    public let status: CardPaymentStatus
}

public enum TapOnPhoneTefError: LocalizedError {
    case declined(codeErro: String, codeResp: String, message: String)
    case invalidInstallments

    public var errorDescription: String? {
        switch self {
        case let .declined(codeErro, codeResp, message):
            return "Declined (\(codeErro)/\(codeResp)): \(message)"
        case .invalidInstallments:
            return "Invalid installments"
        }
    }
}

// MARK: - Entry points

public enum TapOnPhoneSDK {
    public static let operations = Operations()
    public static let authentication = Authentication()

    public struct Operations {
        public func authenticationSilentLogin(
            _ parameters: SilentLoginParams
        ) async -> LoginResult {
            LoginResult(
                isSuccessful: true,
                statusCode: 200,
                message: "CI stub",
                configuration: ConfigurationLoginSDK(
                    token: .init(prefix: "stub"),
                    codeTerminal: "00000000",
                    storeName: "CI Stub Store"
                )
            )
        }

        public func setAccessToken(_ tokens: AuthenticationTokens) -> Bool { true }

        /// Executes a debit payment via TEF service (stub).
        public func executeDebitCardPayment(
            value: Decimal
        ) async throws -> CardPaymentResult {
            Self.mockResult(amount: value, installments: 1)
        }

        /// Executes a credit payment via TEF service (stub).
        public func executeCreditCardPayment(
            value: Decimal,
            installmentType: InstallmentType,
            installmentNumber: Int
        ) async throws -> CardPaymentResult {
            Self.mockResult(
                amount: value,
                installments: installmentNumber <= 0 ? 1 : installmentNumber
            )
        }

        private static func mockResult(amount: Decimal, installments: Int) -> CardPaymentResult {
            let ctf = CTFResult(
                operationCode: "00",
                establishmentCode: "00000000",
                storeCode: "00000000",
                terminalCode: "00000000",
                authorizationCode: "123456",
                acquirerCode: "000",
                authorizationResponseCode: "00",
                extendedErrorCode: "",
                nsuCTF: "000000000",
                nsuHost: "000000000",
                brandName: "STUB",
                acquirerName: "Stub Acquirer",
                maskedPan: "**** **** **** 0000",
                installmentCount: installments,
                transactionNumber: 1,
                transactionDate: "01/01/2026",
                transactionTime: "00:00:00",
                totalAmount: amount,
                transactionAmount: amount,
                displayMessages: ["APROVADO"]
            )
            return CardPaymentResult(
                returnCode: "00",
                customerReceipt: "STUB CUSTOMER RECEIPT",
                merchantReceipt: "STUB MERCHANT RECEIPT",
                reducedReceipt: "STUB",
                ctf: ctf,
                status: .approved
            )
        }
    }

    public struct Authentication {
        public func authenticateMonoEC(
            _ parameters: MonoECAuthParameters
        ) async throws -> MonoECAuthResult {
            MonoECAuthResult(
                isSuccessful: true,
                statusCode: 200,
                message: "CI stub",
                configuration: MonoECConfiguration(
                    storeName: "CI Stub Store",
                    terminalCode: "00000000"
                )
            )
        }
    }
}
