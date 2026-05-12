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
- Binário `TapOnPhoneHTI.xcframework` (ou `TapOnPhone.framework`)
  fornecido pela Getnet — **não** é distribuído neste repositório.
  O _module name_ exposto pelo framework é `TapOnPhone`, por isso os
  arquivos Swift usam `import TapOnPhone`.

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
└── Frameworks/                   # Coloque aqui o TapOnPhoneHTI.xcframework (ver Frameworks/README.md)
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
2. Copie o `TapOnPhoneHTI.xcframework` (fornecido pela Getnet) para a
   pasta `Frameworks/` deste repositório.
3. No Xcode, em **General → Frameworks, Libraries, and Embedded Content**,
   clique em **+**, escolha **Add Other… → Add Files…**, selecione
   `Frameworks/TapOnPhoneHTI.xcframework` e marque **Embed & Sign**.
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
`TapOnPhoneSDK.operations.authenticateMonoEC(_:)`.

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

## Gerar IPA assinado via GitHub Actions (sem Mac local)

O workflow [`.github/workflows/ios-release.yml`](.github/workflows/ios-release.yml)
compila o app em um runner macOS do GitHub, assina com a sua conta
Apple Developer e publica o `.ipa` como artifact do workflow — que pode
ser baixado via navegador em Windows/Linux e instalado no iPhone usando
**iMazing** ou **3uTools** via USB, sem precisar de Mac.

### Pré-requisitos (Apple)

1. **Conta Apple Developer paga** com o entitlement
   `com.apple.developer.proximity-reader.payment.acceptance` **aprovado**
   (solicitar em <https://developer.apple.com/contact/request/tap-to-pay-on-iphone/>).
2. **App ID** registrado no portal com capability _Tap to Pay on iPhone_
   habilitada.
3. **Certificado de assinatura** exportado como `.p12` (Apple
   Distribution para _ad-hoc_/_app-store_ ou Apple Development para
   _development_).
4. **Provisioning profile** (`.mobileprovision`) que inclui o App ID do
   passo 2, o certificado do passo 3 e o entitlement Tap to Pay.
5. Para _ad-hoc_: os UDIDs dos iPhones de teste precisam estar no
   perfil.

### 1. Publicar o `TapOnPhoneHTI.xcframework` em um Release privado

O binário proprietário da Getnet não está no repo. O workflow baixa-o
de um **GitHub Release** privado do próprio repositório.

```bash
# No seu Windows/Linux, com a ferramenta gh CLI instalada:
gh auth login
gh release create sdk-0.1.0-alpha-0 \
  --repo davibschneid/SampleTapOnPhone \
  --title "TapOnPhone SDK 0.1.0-alpha-0" \
  --notes "Binário proprietário Getnet — uso restrito." \
  TapOnPhoneHTI.xcframework.zip
```

> O release fica privado porque o repositório é privado — só quem tem
> acesso ao repo consegue baixar o asset.

### 2. Configurar os secrets

Em **Repo → Settings → Secrets and variables → Actions → New repository secret**, crie:

| Secret                              | Conteúdo                                                                 |
| ----------------------------------- | ------------------------------------------------------------------------ |
| `APPLE_TEAM_ID`                     | Seu Team ID (10 caracteres, ex.: `ABCDE12345`).                          |
| `APPLE_BUNDLE_IDENTIFIER`           | Bundle Id registrado no App ID (ex.: `br.com.suaempresa.SampleTapOnPhone`). |
| `APPLE_DISTRIBUTION_CERT_P12`       | Conteúdo do `.p12` em base64: `base64 < cert.p12 \| pbcopy`.             |
| `APPLE_DISTRIBUTION_CERT_PASSWORD`  | Senha que você usou ao exportar o `.p12`.                                |
| `APPLE_PROVISIONING_PROFILE`        | Conteúdo do `.mobileprovision` em base64.                                |
| `APPLE_KEYCHAIN_PASSWORD`           | Qualquer string — usada só para criar a keychain temporária do CI.       |

No Linux/Windows, para gerar o base64:

```bash
# Linux / WSL / Git Bash
base64 -w0 cert.p12 > cert.p12.b64
base64 -w0 profile.mobileprovision > profile.b64
```

Cole o conteúdo desses arquivos `.b64` no campo do secret (sem newlines).

### 3. Rodar o workflow

**Repo → Actions → "Build signed IPA (manual)" → Run workflow**:

- **Branch**: `devin/1776373242-initial-ios-app` (ou `main` depois que o
  PR for mergeado).
- **Export method**: `ad-hoc` (recomendado para instalar em iPhones
  específicos) ou `development`.
- **Sdk release tag**: `sdk-0.1.0-alpha-0` (o tag usado no passo 1).

Após ~5 minutos o job termina e o `.ipa` fica disponível em **Actions →
workflow run → Artifacts → `SampleTapOnPhone-ad-hoc-ipa`**.

### 4. Instalar no iPhone (sem Mac)

Baixe o `.ipa` pelo navegador e use uma destas ferramentas:

- **[iMazing](https://imazing.com/)** — Windows/macOS, free trial:
  _Apps → Library → Install from file_ → arrasta o `.ipa` → conecta o
  iPhone por USB → _Install_.
- **[3uTools](https://www.3u.com/)** — Windows free: _Apps → Install .ipa_.
- **[Sideloadly](https://sideloadly.io/)** — Windows/macOS free; útil
  quando o perfil é _development_.

No iPhone, primeira execução: **Settings → General → VPN & Device
Management → Trust** no perfil da sua empresa.

### Limitações

- Em perfil _ad-hoc_ o iPhone tem que estar na lista de UDIDs do
  provisioning profile. Adicionar um UDID depois exige regerar o
  perfil no portal Apple e republicar o secret `APPLE_PROVISIONING_PROFILE`.
- Em perfil _development_ o app expira em 7 dias (conta gratuita) ou 1
  ano (conta paga).
- Tap to Pay **não funciona** em iPhone sem o entitlement ativo no
  perfil — se aparecer erro de "not supported" em runtime, revise
  os passos 1-4 dos pré-requisitos.

## Licença

Código deste sample é distribuído sob a licença MIT — consulte `LICENSE`.
O `TapOnPhoneHTI.xcframework` é de propriedade da Getnet e segue os termos
do contrato assinado com o fornecedor.
