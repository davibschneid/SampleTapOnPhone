# TapOnPhone iOS SDK — Especificação técnica (0.1.0-alpha-0)

> Este documento consolida as **assinaturas públicas reais** extraídas
> do arquivo `arm64-apple-ios.swiftinterface` contido no
> `TapOnPhoneHTI.xcframework`. Serve como referência para a integração
> neste repositório e substitui o PDF original de `0.1.0-alpha-0` nos
> pontos em que as assinaturas divergem.
>
> Fonte: `TapOnPhoneHTI.xcframework/ios-arm64/TapOnPhone.framework/Modules/TapOnPhone.swiftmodule/arm64-apple-ios.swiftinterface`.
>
> - **Nome do arquivo (xcframework):** `TapOnPhoneHTI.xcframework`
> - **Module name (import):** `TapOnPhone`
> - **Compilador:** Swift 6.2.4 (effective-5.10)
> - **Target mínimo:** `arm64-apple-ios18.4` (binário entregue; o app
>   pode declarar `IPHONEOS_DEPLOYMENT_TARGET` menor, como `16.4`, desde
>   que não use APIs >= 18.4 em runtime).
> - **Dependências:** `Foundation`, `ProximityReader`, `Security`,
>   `UIKit`, `_Concurrency`.

## Sumário de divergências vs. PDF `0.1.0-alpha-0`

| Área                                 | PDF                                                         | Framework real                                           |
| ------------------------------------ | ----------------------------------------------------------- | -------------------------------------------------------- |
| Entry point MonoEC                   | `TapOnPhoneSDK.authentication.authenticateMonoEC`           | **`TapOnPhoneSDK.operations.authenticateMonoEC`**        |
| Throwing?                            | Exemplos usam `try await`                                   | `authenticateMonoEC` e `authenticationSilentLogin` são **`async`** não-throwing |
| `ConfigurationLoginSDK.codeTerminal` | Campo `codeTerminal`                                        | Campo real é `codeTerm`                                  |
| `MonoECConfiguration` campos         | PDF mostra `token`, `terminalCode`, `storeName`             | Tem também `companyDocument`, `username`, `parameters?`, `certificateData?`, `urlCTFPrimary?` |
| `MonoECConfiguration.storeName/terminalCode` | Aparentam opcionais                                  | **Não-opcionais** (`String`)                              |
| `TapOnPhoneTefError`                 | Documentado no PDF                                          | **Não existe** no framework — substitua por `CardReaderError` + `Error` genérico |
| `AuthenticationTokens.expiresIn`     | PDF às vezes mostra string                                  | Real é `Int`                                              |
| `AuthenticationTokens.creationDate`  | Não aparece no PDF                                          | Obrigatório no init (`Date`)                              |
| `CardPaymentResult.returnCode`       | Não documentado o tipo                                      | `String`                                                  |
| `CardPaymentStatus`                  | PDF fala em sucesso/falha                                   | `approved`, `denied`, `error`, `unknown`, `cancelled`    |

---

## Entry point — `TapOnPhoneSDK`

```swift
public struct TapOnPhoneSDK {
    public static var operations: any TapOnPhoneOperationsProtocol { get }
    public static var configuration: any TapOnPhoneConfigurationProtocol { get }
    weak public static var messageDelegate: (any TapOnPhoneMessageDelegate)?
    weak public static var uiDelegate: (any TapOnPhoneUIDelegate)?
}
```

`TapOnPhoneSDK` é uma `struct` (não `enum`). **Não existe**
`TapOnPhoneSDK.authentication` — todas as operações de autenticação
estão em `TapOnPhoneSDK.operations`.

### `TapOnPhoneConfigurationProtocol`

```swift
public protocol TapOnPhoneConfigurationProtocol {
    var frameworkVersion: String { get }
    var terminalID: String { get }
}
```

### `TapOnPhoneOperationsProtocol`

```swift
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
```

Notas:
- `authenticateMonoEC` e `authenticationSilentLogin` são `async` mas
  **não lançam exceção** — qualquer falha é reportada via
  `isSuccessful: Bool` e `statusCode` / `message` no valor de retorno.
- `setAccessToken` é síncrono e devolve `Bool` indicando aceitação.
- `checkForExpiredToken` devolve `nil` se ainda válido ou o ssoToken
  atualizado; pode lançar.
- `executeDebit…` / `executeCredit…` lançam em caso de erro de leitor
  (`CardReaderError`) ou token (`AuthenticationError.tokenExpired`).

---

## Autenticação

### `AuthenticationTokens`

```swift
public struct AuthenticationTokens: Codable {
    public let ssoToken: String
    public let expiresIn: Int
    public let creationDate: Date
    public init(ssoToken: String, expiresIn: Int, creationDate: Date)
}
```

### `SilentLoginParams` / `SilentLoginParamsProtocol`

```swift
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
    )
}
```

> **Atenção:** a ordem dos parâmetros do init é
> `(tokens, appToken, packageName, document, …)` — não
> `(tokens, appToken, document, packageName, …)` como sugere alguns
> exemplos do PDF.

### `ConfigurationLoginSDK`

```swift
public struct ConfigurationLoginSDK: Codable {
    public var token: String?
    public var certificatePath: String
    public var md5ReceivedByServer: String
    public var codeTerm: String?        // (PDF: "codeTerminal")
    public var getnetEC: String?
    public var protocolValue: String
    public var host: String
    public var port: String
    public var environmentCTF: String
    public var cnpj: String
    public var user: String
    public var groupEC: String
    public var storeName: String?
}
```

### `LoginResult`

```swift
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
    )

    public static func success(_ configuration: ConfigurationLoginSDK) -> LoginResult
    public static func error(statusCode: Int, message: String) -> LoginResult
    public static func fromLoginError(_ error: LoginError) -> LoginResult
}
```

### `LoginError`

```swift
public enum LoginError: Error {
    case invalidInput(message: String)
    case network(message: String)
    case httpError(code: Int, message: String)
    case decoding(message: String)
    case unknown(message: String = "Unknown error")
}
```

### `AuthenticationError`

```swift
public enum AuthenticationError: Error, LocalizedError, Equatable {
    case invalidCredentials
    case networkError(any Error)
    case invalidResponse
    case serverError(String)
    case tokenExpired
}
```

---

## MonoEC

### `MonoECAuthParameters`

```swift
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
    )
}
```

### `MonoECConfiguration`

```swift
public struct MonoECConfiguration: Codable {
    public let token: String
    public let terminalCode: String
    public let storeName: String
    public let companyDocument: String
    public let username: String
    public let parameters: [MonoECParametersItem]?
    public let certificateData: Data?
    public let urlCTFPrimary: String?
}
```

> Os três primeiros (`token`, `terminalCode`, `storeName`) **não são
> opcionais**.

### `MonoECParametersItem`

```swift
public struct MonoECParametersItem: Codable {
    public let id: String
    public let valor: String
}
```

### `MonoECAuthResult`

```swift
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
    )

    public static func success(_ configuration: MonoECConfiguration) -> MonoECAuthResult
    public static func error(statusCode: Int, message: String) -> MonoECAuthResult
    public static func fromLoginError(_ error: LoginError) -> MonoECAuthResult
}
```

---

## Pagamentos

### `InstallmentType`

```swift
public enum InstallmentType: Equatable, Hashable {
    case store
    case administrative
    case upfront
    case merchantInstallment
}
```

### `CardPaymentStatus`

```swift
public enum CardPaymentStatus: Equatable, Hashable {
    case approved
    case denied
    case error
    case unknown
    case cancelled
}
```

### `CardPaymentResult`

```swift
public struct CardPaymentResult {
    public let returnCode: String           // ex: "00"
    public let customerReceipt: String
    public let merchantReceipt: String
    public let reducedReceipt: String
    public let ctf: CTFResult
    public let status: CardPaymentStatus

    public var isApproved: Bool { get }     // status == .approved
    public var formattedAmount: String { get }

    public init(
        returnCode: String,
        customerReceipt: String,
        merchantReceipt: String,
        reducedReceipt: String,
        ctf: CTFResult,
        status: CardPaymentStatus
    )

    public static var mock: CardPaymentResult { get }
}
```

### `CTFResult`

```swift
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
    public let transactionDate: String       // "dd/MM/yyyy"
    public let transactionTime: String       // "HH:mm:ss"
    public let totalAmount: Decimal
    public let transactionAmount: Decimal
    public let displayMessages: [String]
    public init(/* todos os campos acima */)
}
```

### `CardReaderError`

```swift
public enum CardReaderError: Error, CustomStringConvertible {
    case notSupported
    case prepareFailed(any Error)
    case readFailed(any Error)
    case cancelled
    case accountNotLinked

    public var description: String { get }
    public var errorCode: Int { get }
}
```

> O PDF menciona um `TapOnPhoneTefError` com casos `declined(...)` e
> `invalidInstallments` — **esse tipo não existe** no framework. Erros
> de leitor são expostos via `CardReaderError`; demais falhas usam
> `Error` genérico ou `AuthenticationError.tokenExpired`.

---

## Delegates de UI (opcionais, mas recomendados)

### `TapOnPhoneMessageDelegate` / `TapOnPhoneMessage`

```swift
public protocol TapOnPhoneMessageDelegate: AnyObject {
    func tapOnPhoneDidReceiveMessage(_ message: TapOnPhoneMessage)
}

public enum TapOnPhoneMessageType: Sendable { case info, warning, error }

public struct TapOnPhoneMessage: Sendable {
    public let text: String
    public let type: TapOnPhoneMessageType
    public let canCancel: Bool
    public let sleepSeconds: Float
}
```

### `TapOnPhoneUIDelegate`

```swift
public protocol TapOnPhoneUIDelegate: AnyObject {
    func requestKeyboard(_ request: KeyboardRequest) async -> String?
    func showMenu(_ request: MenuRequest) async -> String?
    func showMessage(_ request: MessageRequest)
    func showImage(_ request: ImageRequest) async -> Int
}

public struct KeyboardRequest {
    public let title: String
    public let mask: String?
    public let minLength: Int
    public let maxLength: Int
}

public struct MenuRequest {
    public let title: String
    public let options: [String]
}

public struct MessageRequest {
    public let message: String
    public let canCancel: Bool
    public let sleep: Float
}

public struct ImageRequest {
    public let title: String?
    public let firstLine: String?
    public let secondLine: String?
    public let data: Data
}
```

Para uso básico o sample não implementa os delegates; a SDK expõe uma
UI default quando `uiDelegate` é `nil`.

---

## Protocolos / enums adicionais

Outros tipos públicos expostos pelo binário (não usados diretamente
pelo sample, mas disponíveis):

- `ProximityReaderManagerProtocol`
- `MonoECServiceProtocol`
- `TapOnPhoneAuthenticationServiceProtocol`
- `Environment` (`baseURL`, `ssoClientId`, `ssoClientSecret`)
- `TransactionContextUtils` (`getSavedCNPJ()`)
- Modelos Codable de transporte: `SSORequest`, `SSOResponse`,
  `TapOnPhoneRequest`, `MonoECRequest`, `MonoECResponse`,
  `MonoECErrorResponse`, `RequestSilentLogin`, `ResponseSilentLogin`,
  `AuthSilentResponse`, `Param`, `CertGroup`, `CertItem`, `CardData`,
  `TokensPayload`.

---

## Como este repositório está alinhado ao framework real

- O **stub de CI** em `Tools/TapOnPhoneStub/Sources/TapOnPhone/TapOnPhoneStub.swift`
  expõe exatamente a mesma hierarquia pública documentada acima (mínus
  os _transport models_ que o app de exemplo não usa).
- Os ViewModels em `SampleTapOnPhone/ViewModels/` chamam
  `TapOnPhoneSDK.operations.*` (não `.authentication.*`) e tratam os
  resultados via `isSuccessful` / `statusCode`, sem depender de
  `TapOnPhoneTefError`.
- O `project.yml` (build local) e o `project.ci.yml` (build em CI)
  compartilham exatamente o mesmo código-fonte do app; só mudam a
  dependência binária: o primeiro espera `Frameworks/TapOnPhoneHTI.xcframework`
  e o segundo usa o stub Swift Package.
