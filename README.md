# SampleTapOnPhone

Aplicativo iOS de exemplo em **Swift + SwiftUI** demonstrando a integração com
o **SDK Getnet Tap On Phone iOS** (versão `0.1.0-alpha-0`).

O projeto cobre os fluxos descritos na documentação oficial da SDK:

| Fluxo                                 | Local no app                                           |
| ------------------------------------- | ------------------------------------------------------ |
| Silent Authentication (recomendado)   | Aba **Autenticação → Silent Login**                    |
| MonoEC (apenas para certificações)    | Aba **Autenticação → MonoEC**                          |
| Atualização de `accessToken`          | Aba **Conta → Atualizar accessToken**                  |
| Pagamento Débito                      | Aba **Transação → Débito**                             |
| Pagamento Crédito (à vista/parcelado) | Aba **Transação → Crédito**                            |
| Resultado (`CardPaymentResult`)       | Modal **Resultado** exibido após a transação           |

> ⚠️ Na versão `0.1.0-alpha-0` da SDK, **todas as transações retornam
> sucesso com dados mockados**, conforme indicado na documentação.

## Requisitos

- Xcode 15.0+
- iOS 16.4+ no dispositivo físico (Tap to Pay não funciona no simulador).
- Conta Apple Developer com a capability **Tap to Pay on iPhone** habilitada
  (é necessário solicitar à Apple em
  <https://developer.apple.com/support/contact/>).
- Provisioning profile com o entitlement
  `com.apple.developer.proximity-reader.payment.acceptance`.
- Conta Apple **sandbox** ativa no iPhone de testes
  (<https://developer.apple.com/help/app-store-connect/test-in-app-purchases/create-sandbox-apple-accounts/>).
- Binário `TapOnPhone.xcframework` (ou `TapOnPhone.framework`)
  fornecido pela Getnet — **não** é distribuído neste repositório.

## Estrutura do projeto

```
SampleTapOnPhone/
├── project.yml                   # Spec do XcodeGen (gera o .xcodeproj)
├── SampleTapOnPhone/
│   ├── SampleTapOnPhoneApp.swift # Entrypoint @main
│   ├── SessionStore.swift        # Estado compartilhado via @EnvironmentObject
│   ├── TransactionOutcome.swift  # DTO amigável derivado de CardPaymentResult
│   ├── Views/
│   │   ├── RootView.swift
│   │   ├── MainTabView.swift
│   │   ├── AuthenticationView.swift
│   │   ├── TransactionView.swift
│   │   ├── ResultView.swift
│   │   └── AccountView.swift
│   ├── ViewModels/
│   │   ├── SilentLoginViewModel.swift
│   │   ├── MonoECViewModel.swift
│   │   ├── TransactionViewModel.swift
│   │   └── TokenRefreshViewModel.swift
│   └── Resources/
│       ├── Info.plist
│       └── SampleTapOnPhone.entitlements
└── Frameworks/                   # (criado por você) coloque aqui o TapOnPhone.xcframework
```

## Gerando o projeto Xcode

Este repositório usa o [XcodeGen](https://github.com/yonaskolb/XcodeGen)
para manter o `.xcodeproj` gerado a partir de `project.yml`, evitando
conflitos de merge em um arquivo `project.pbxproj` manual.

```bash
brew install xcodegen
cd SampleTapOnPhone
xcodegen           # gera SampleTapOnPhone.xcodeproj
open SampleTapOnPhone.xcodeproj
```

> O `.xcodeproj` está no `.gitignore` — sempre regenere com `xcodegen`
> após alterar `project.yml`.

### Alternativa sem XcodeGen

Se você prefere trabalhar direto no Xcode:

1. `File → New → Project… → iOS → App → Interface: SwiftUI`.
2. Arraste a pasta `SampleTapOnPhone/` deste repositório para dentro do
   novo projeto, marcando **Copy items if needed** e **Create groups**.
3. Configure `Info.plist` e `SampleTapOnPhone.entitlements` nas
   _Build Settings_ do target.
4. Siga o passo **Adicionando a TapOnPhone SDK** abaixo.

## Adicionando a TapOnPhone SDK

1. Habilite a capability _Tap to Pay on iPhone_ no target
   (`Signing & Capabilities → + Capability → Tap to Pay on iPhone`).
   Isso acrescenta `com.apple.developer.proximity-reader.payment.acceptance`
   ao provisioning profile.
2. Crie a pasta `Frameworks/` na raiz e copie o `TapOnPhone.xcframework`
   (fornecido pela Getnet) para dentro dela.
3. No Xcode, em **General → Frameworks, Libraries, and Embedded Content**,
   clique em **+**, escolha **Add Other… → Add Files…**, selecione
   `Frameworks/TapOnPhone.xcframework` e marque **Embed & Sign**.
4. Confirme que **Build Settings → Framework Search Paths** inclui
   `$(PROJECT_DIR)/Frameworks`.
5. Compile (`⌘B`). Os `import TapOnPhone` serão resolvidos.

## Autenticação

### Silent Login (recomendado)

1. Obtenha `accessToken` em `POST /v1/tef-embarcado/oauth/token`.
2. Obtenha `appToken` em `POST /v1/tef-embarcado/top-auth-adp/app-token`.
3. Na aba **Autenticação → Silent Login**, cole os dois tokens e
   informe documento, bundle id, e opcionalmente nome do dispositivo,
   nickname e usuário.
4. Toque em **Entrar**. O app chama
   `TapOnPhoneSDK.operations.authenticationSilentLogin(_:)` e, em caso
   de sucesso, navega para a aba **Transação**.

### Atualização de token

Quando qualquer operação lançar `AuthenticationError.tokenExpired`,
abra a aba **Conta → Atualizar accessToken**, cole o novo `ssoToken`
e toque em **Aplicar novo token** — internamente o app invoca
`TapOnPhoneSDK.operations.setAccessToken(_:)`.

### MonoEC

Usado apenas para certificações internas. Colete documento da empresa,
usuário, senha e (opcionalmente) código da loja. O app chama
`TapOnPhoneSDK.authentication.authenticateMonoEC(_:)`.

## Transações

Na aba **Transação**:

- **Valor**: `Decimal` formatado em BRL.
- **Tipo**: Débito (`executeDebitCardPayment(value:)`) ou Crédito
  (`executeCreditCardPayment(value:installmentType:installmentNumber:)`).
- **Parcelamento** (somente Crédito):
  - `À vista` → `InstallmentType.upfront`
  - `Parcelado loja` → `InstallmentType.store`
  - `Administrativo` → `InstallmentType.administrative`
  - `Parcelado lojista` → `InstallmentType.merchantInstallment`

O resultado é exibido em `ResultView`, mapeando `CardPaymentResult` /
`CTFResult` para campos legíveis (status, autorização, NSUs,
bandeira, comprovantes, etc.).

## Testes

A SDK expõe apenas o ambiente de **homologação** na versão
`0.1.0-alpha-0`. Para testes ponta-a-ponta, use um iPhone físico com
Tap to Pay habilitado e uma Apple Sandbox Account.

## Licença

Código deste sample é distribuído sob a licença MIT — consulte `LICENSE`.
O `TapOnPhone.xcframework` é de propriedade da Getnet e segue os termos
do contrato assinado com o fornecedor.
