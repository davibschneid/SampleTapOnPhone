//
//  ResultView.swift
//  SampleTapOnPhone
//
//  Displays the outcome of a card payment. Mirrors the fields exposed
//  by CardPaymentResult / CTFResult in the SDK.
//

import SwiftUI

struct ResultView: View {
    let result: TransactionOutcome

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    statusBadge
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }

                Section("Detalhes") {
                    row("Código de retorno", result.returnCode)
                    row("Status", result.statusText)
                    row("Valor", result.totalAmount.formatted(.currency(code: "BRL")))
                    row("Parcelas", "\(result.installmentCount)")
                }

                Section("CTF") {
                    row("Código de autorização", result.authorizationCode)
                    row("NSU CTF", result.nsuCTF)
                    row("NSU Host", result.nsuHost)
                    row("Bandeira", result.brandName)
                    row("PAN", result.maskedPan)
                    row("Data", "\(result.transactionDate) \(result.transactionTime)")
                }

                if !result.customerReceipt.isEmpty {
                    Section("Comprovante do cliente") {
                        Text(result.customerReceipt)
                            .font(.system(.footnote, design: .monospaced))
                    }
                }

                if !result.merchantReceipt.isEmpty {
                    Section("Comprovante do lojista") {
                        Text(result.merchantReceipt)
                            .font(.system(.footnote, design: .monospaced))
                    }
                }
            }
            .navigationTitle("Resultado")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var statusBadge: some View {
        VStack(spacing: 8) {
            Image(systemName: result.isApproved ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(result.isApproved ? .green : .red)
            Text(result.isApproved ? "Aprovado" : "Negado")
                .font(.title2.weight(.semibold))
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ResultView(result: TransactionOutcome.preview)
}
