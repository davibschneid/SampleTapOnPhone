//
//  TapOnPhoneStub.swift
//
//  CI-only stub of the Getnet TapOnPhone iOS SDK. Every symbol here
//  matches the public signatures exposed by the real
//  `TapOnPhoneHTI.xcframework` (module name `TapOnPhone`,
//  version 0.1.0-alpha-0), extracted from its `.swiftinterface`.
//
//  Function bodies are intentional no-ops that return mocked results
//  so the sample app can be type-checked and linked on CI without
//  access to the proprietary binary. DO NOT ship this module — swap
//  it out for the real framework before building a distributable
//  artifact.
//

import Foundation

// MARK: - Configuration protocol

public protocol TapOnPhoneConfigurationProtocol {
    var frameworkVersion: String { get }
    var terminalID: String { get }
}

// MARK: - Operations protocol

public protocol TapOnPhoneOperationsProtocol {
    func authenticateMonoEC(_ parameters: MonoECAuthParameters) async -> MonoECAuthResult
    func authenticationSilentLogin(_ parameters: SilentLoginParams) async -> LoginResult
    func setAccessToken(_ tokens: AuthenticationTokens) -> Bool
    func checkForExpiredToken() async throws -> String?
    func executeCreditCardPayment(
        value: Decimal,
        installmentType: InstallmentType,
        installmentNumber: Int
    ) async throws -> CardPaymentResult
    func executeDebitCardPayment(value: Decimal) async throws -> CardPaymentResult
    func logout()
}

// MARK: - Authentication payloads

public struct AuthenticationTokens: Codable {
    public let ssoToken: String
    public let expiresIn: Int
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
    public let packageName: String
    public let deviceName: String?
    public let nickName: String?
    public let user: String?
    public let document: String

    public init(
        tokens: AuthenticationTokens,
        appToken: String,
        packageName: String,
        document: String,
        deviceName: String? = nil,
        nickName: String? = nil,
        user: String? = nil
    ) {
        self.tokens = tokens
        self.appToken = appToken
        self.packageName = packageName
        self.document = document
        self.deviceName = deviceName
        self.nickName = nickName
        self.user = user
    }
}

public struct ConfigurationLoginSDK: Codable {
    public var token: String?
    public var certificatePath: String
    public var md5ReceivedByServer: String
    public var codeTerm: String?
    public var getnetEC: String?
    public var protocolValue: String
    public var host: String
    public var port: String
    public var environmentCTF: String
    public var cnpj: String
    public var user: String
    public var groupEC: String
    public var storeName: String?

    public init(
        token: String? = nil,
        certificatePath: String = "",
        md5ReceivedByServer: String = "",
        codeTerm: String? = nil,
        getnetEC: String? = nil,
        protocolValue: String = "",
        host: String = "",
        port: String = "",
        environmentCTF: String = "",
        cnpj: String = "",
        user: String = "",
        groupEC: String = "",
        storeName: String? = nil
    ) {
        self.token = token
        self.certificatePath = certificatePath
        self.md5ReceivedByServer = md5ReceivedByServer
        self.codeTerm = codeTerm
        self.getnetEC = getnetEC
        self.protocolValue = protocolValue
        self.host = host
        self.port = port
        self.environmentCTF = environmentCTF
        self.cnpj = cnpj
        self.user = user
        self.groupEC = groupEC
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
        configuration: ConfigurationLoginSDK? = nil
    ) {
        self.isSuccessful = isSuccessful
        self.statusCode = statusCode
        self.message = message
        self.configuration = configuration
    }

    public static func success(_ configuration: ConfigurationLoginSDK) -> LoginResult {
        LoginResult(isSuccessful: true, statusCode: 200, message: "ok", configuration: configuration)
    }

    public static func error(statusCode: Int, message: String) -> LoginResult {
        LoginResult(isSuccessful: false, statusCode: statusCode, message: message)
    }

    public static func fromLoginError(_ error: LoginError) -> LoginResult {
        LoginResult(isSuccessful: false, statusCode: -1, message: String(describing: error))
    }
}

public enum LoginError: Error {
    case invalidInput(message: String)
    case network(message: String)
    case httpError(code: Int, message: String)
    case decoding(message: String)
    case unknown(message: String = "Unknown error")
}

public enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case invalidResponse
    case serverError(String)
    case tokenExpired

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid credentials"
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .invalidResponse: return "Invalid response"
        case .serverError(let m): return "Server error: \(m)"
        case .tokenExpired: return "Access token expired"
        }
    }

    public static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials),
             (.invalidResponse, .invalidResponse),
             (.tokenExpired, .tokenExpired):
            return true
        case (.serverError(let a), .serverError(let b)):
            return a == b
        case (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
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
        storeCode: String? = nil
    ) {
        self.companyDocument = companyDocument
        self.username = username
        self.password = password
        self.storeCode = storeCode
    }
}

public struct MonoECParametersItem: Codable {
    public let id: String
    public let valor: String

    public init(id: String, valor: String) {
        self.id = id
        self.valor = valor
    }
}

public struct MonoECConfiguration: Codable {
    public let token: String
    public let terminalCode: String
    public let storeName: String
    public let companyDocument: String
    public let username: String
    public let parameters: [MonoECParametersItem]?
    public let certificateData: Data?
    public let urlCTFPrimary: String?

    public init(
        token: String,
        terminalCode: String,
        storeName: String,
        companyDocument: String,
        username: String,
        parameters: [MonoECParametersItem]? = nil,
        certificateData: Data? = nil,
        urlCTFPrimary: String? = nil
    ) {
        self.token = token
        self.terminalCode = terminalCode
        self.storeName = storeName
        self.companyDocument = companyDocument
        self.username = username
        self.parameters = parameters
        self.certificateData = certificateData
        self.urlCTFPrimary = urlCTFPrimary
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
        configuration: MonoECConfiguration? = nil
    ) {
        self.isSuccessful = isSuccessful
        self.statusCode = statusCode
        self.message = message
        self.configuration = configuration
    }

    public static func success(_ configuration: MonoECConfiguration) -> MonoECAuthResult {
        MonoECAuthResult(isSuccessful: true, statusCode: 200, message: "ok", configuration: configuration)
    }

    public static func error(statusCode: Int, message: String) -> MonoECAuthResult {
        MonoECAuthResult(isSuccessful: false, statusCode: statusCode, message: message)
    }

    public static func fromLoginError(_ error: LoginError) -> MonoECAuthResult {
        MonoECAuthResult(isSuccessful: false, statusCode: -1, message: String(describing: error))
    }
}

// MARK: - Transactions

public enum InstallmentType: Equatable, Hashable {
    case store
    case administrative
    case upfront
    case merchantInstallment
}

public enum CardPaymentStatus: Equatable, Hashable {
    case approved
    case denied
    case error
    case unknown
    case cancelled
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

    public init(
        operationCode: String,
        establishmentCode: String,
        storeCode: String,
        terminalCode: String,
        authorizationCode: String,
        acquirerCode: String,
        authorizationResponseCode: String,
        extendedErrorCode: String,
        nsuCTF: String,
        nsuHost: String,
        brandName: String,
        acquirerName: String,
        maskedPan: String,
        installmentCount: Int,
        transactionNumber: Int,
        transactionDate: String,
        transactionTime: String,
        totalAmount: Decimal,
        transactionAmount: Decimal,
        displayMessages: [String]
    ) {
        self.operationCode = operationCode
        self.establishmentCode = establishmentCode
        self.storeCode = storeCode
        self.terminalCode = terminalCode
        self.authorizationCode = authorizationCode
        self.acquirerCode = acquirerCode
        self.authorizationResponseCode = authorizationResponseCode
        self.extendedErrorCode = extendedErrorCode
        self.nsuCTF = nsuCTF
        self.nsuHost = nsuHost
        self.brandName = brandName
        self.acquirerName = acquirerName
        self.maskedPan = maskedPan
        self.installmentCount = installmentCount
        self.transactionNumber = transactionNumber
        self.transactionDate = transactionDate
        self.transactionTime = transactionTime
        self.totalAmount = totalAmount
        self.transactionAmount = transactionAmount
        self.displayMessages = displayMessages
    }
}

public struct CardPaymentResult {
    public let returnCode: String
    public let customerReceipt: String
    public let merchantReceipt: String
    public let reducedReceipt: String
    public let ctf: CTFResult
    public let status: CardPaymentStatus

    public var isApproved: Bool { status == .approved }

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: ctf.totalAmount as NSDecimalNumber) ?? "\(ctf.totalAmount)"
    }

    public init(
        returnCode: String,
        customerReceipt: String,
        merchantReceipt: String,
        reducedReceipt: String,
        ctf: CTFResult,
        status: CardPaymentStatus
    ) {
        self.returnCode = returnCode
        self.customerReceipt = customerReceipt
        self.merchantReceipt = merchantReceipt
        self.reducedReceipt = reducedReceipt
        self.ctf = ctf
        self.status = status
    }
}

extension CardPaymentResult {
    public static var mock: CardPaymentResult {
        CardPaymentResult(
            returnCode: "00",
            customerReceipt: "STUB CUSTOMER RECEIPT",
            merchantReceipt: "STUB MERCHANT RECEIPT",
            reducedReceipt: "STUB",
            ctf: CTFResult(
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
                installmentCount: 1,
                transactionNumber: 1,
                transactionDate: "01/01/2026",
                transactionTime: "00:00:00",
                totalAmount: Decimal(0),
                transactionAmount: Decimal(0),
                displayMessages: ["APROVADO"]
            ),
            status: .approved
        )
    }
}

public enum CardReaderError: Error, CustomStringConvertible {
    case notSupported
    case prepareFailed(Error)
    case readFailed(Error)
    case cancelled
    case accountNotLinked

    public var description: String {
        switch self {
        case .notSupported: return "Card reader not supported on this device"
        case .prepareFailed(let e): return "Failed to prepare reader: \(e.localizedDescription)"
        case .readFailed(let e): return "Failed to read card: \(e.localizedDescription)"
        case .cancelled: return "Card reading was cancelled"
        case .accountNotLinked: return "Apple account not linked to Tap to Pay"
        }
    }

    public var errorCode: Int {
        switch self {
        case .notSupported: return 1
        case .prepareFailed: return 2
        case .readFailed: return 3
        case .cancelled: return 4
        case .accountNotLinked: return 5
        }
    }
}

// MARK: - Entry point

public struct TapOnPhoneSDK {
    public static var operations: any TapOnPhoneOperationsProtocol { StubOperations() }
    public static var configuration: any TapOnPhoneConfigurationProtocol { StubConfiguration() }
}

private struct StubConfiguration: TapOnPhoneConfigurationProtocol {
    var frameworkVersion: String { "0.1.0-alpha-0-stub" }
    var terminalID: String { "00000000" }
}

private struct StubOperations: TapOnPhoneOperationsProtocol {
    func authenticateMonoEC(_ parameters: MonoECAuthParameters) async -> MonoECAuthResult {
        .success(
            MonoECConfiguration(
                token: "stub-token",
                terminalCode: "00000000",
                storeName: "CI Stub Store",
                companyDocument: parameters.companyDocument,
                username: parameters.username
            )
        )
    }

    func authenticationSilentLogin(_ parameters: SilentLoginParams) async -> LoginResult {
        .success(
            ConfigurationLoginSDK(
                token: parameters.tokens.ssoToken,
                codeTerm: "00000000",
                storeName: "CI Stub Store"
            )
        )
    }

    func setAccessToken(_ tokens: AuthenticationTokens) -> Bool { true }

    func checkForExpiredToken() async throws -> String? { nil }

    func executeCreditCardPayment(
        value: Decimal,
        installmentType: InstallmentType,
        installmentNumber: Int
    ) async throws -> CardPaymentResult {
        Self.mockResult(
            amount: value,
            installments: installmentNumber <= 0 ? 1 : installmentNumber
        )
    }

    func executeDebitCardPayment(value: Decimal) async throws -> CardPaymentResult {
        Self.mockResult(amount: value, installments: 1)
    }

    func logout() {}

    private static func mockResult(amount: Decimal, installments: Int) -> CardPaymentResult {
        CardPaymentResult(
            returnCode: "00",
            customerReceipt: "STUB CUSTOMER RECEIPT",
            merchantReceipt: "STUB MERCHANT RECEIPT",
            reducedReceipt: "STUB",
            ctf: CTFResult(
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
            ),
            status: .approved
        )
    }
}
