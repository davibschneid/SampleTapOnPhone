# Frameworks

Esta pasta é o destino do **binário proprietário da SDK Getnet**:

```
Frameworks/
└── TapOnPhoneHTI.xcframework/
```

O _nome do arquivo_ é `TapOnPhoneHTI.xcframework`, mas o _module name_
que ele expõe é `TapOnPhone`, por isso os arquivos Swift fazem
`import TapOnPhone`.

## Como adicionar o binário

1. Obtenha o `TapOnPhoneHTI.xcframework` com o seu contato comercial /
   técnico da Getnet. O arquivo **não é distribuído** neste
   repositório.
2. Copie o diretório `TapOnPhoneHTI.xcframework` inteiro para dentro
   desta pasta.
3. No Xcode, abra o target `SampleTapOnPhone` →
   **General → Frameworks, Libraries, and Embedded Content → +** →
   **Add Other… → Add Files…** → selecione
   `Frameworks/TapOnPhoneHTI.xcframework` → marque **Embed & Sign**.
4. Confirme em **Build Settings → Framework Search Paths** que
   `$(PROJECT_DIR)/Frameworks` está presente.

## Por que essa pasta está no `.gitignore`

O `.gitignore` ignora qualquer `*.framework/` e `*.xcframework/` dentro
desta pasta (inclusive `TapOnPhoneHTI.xcframework/`) para evitar que o
binário proprietário seja commitado por acidente. Apenas este
`README.md` é versionado para documentar o layout.

## CI (build sem o binário real)

O job do GitHub Actions (`.github/workflows/ios.yml`) usa o arquivo
alternativo `project.ci.yml`, que substitui o framework por um **stub**
Swift Package em `Tools/TapOnPhoneStub/` com as mesmas assinaturas
públicas documentadas no PDF. Isso permite que o CI compile o app sem
acesso ao binário proprietário. **Não use o stub em produção.**
