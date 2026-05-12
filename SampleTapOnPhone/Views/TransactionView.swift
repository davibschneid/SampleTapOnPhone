//
//  TransactionView.swift
//  SampleTapOnPhone
//
//  Main transaction screen. Lets the user choose the amount, the
//  operation type (debit or credit) and, when applicable, the
//  installment mode and number of installments.
//

import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Form {
            Section("Terminal") {
                Text(session.terminalDescription.isEmpty
                     ? "Terminal autenticado"
                     : session.terminalDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Valor") {
                TextField("R$ 0,00", value: $viewModel.amount, format: .currency(code: "BRL"))
                    .keyboardType(.decimalPad)
            }

            Section("Tipo de operação") {
                Picker("Operação", selection: $viewModel.operation) {
                    ForEach(TransactionViewModel.Operation.allCases) { op in
                        Text(op.title).tag(op)
                    }
                }
                .pickerStyle(.segmented)
            }

            if viewModel.operation == .credit {
                creditOptionsSection
            }

            Section {
                Button {
                    Task { await viewModel.executePayment() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isProcessing {
                            ProgressView()
                        } else {
                            Label("Cobrar \(viewModel.amount.formatted(.currency(code: "BRL")))",
                                  systemImage: "wave.3.right.circle.fill")
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canExecute || viewModel.isProcessing)
            } footer: {
                Text("Aproxime o cartão ou carteira (Apple/Google Pay) do iPhone quando solicitado.")
            }
        }
        .navigationTitle("Nova Transação")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sair") { session.logout() }
            }
        }
        .sheet(item: $viewModel.result) { result in
            ResultView(result: result)
        }
        .alert("Erro na transação",
               isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
               )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var creditOptionsSection: some View {
        Section("Parcelamento") {
            Picker("Modo", selection: $viewModel.installmentType) {
                ForEach(TransactionViewModel.InstallmentMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            if viewModel.installmentType.usesInstallmentNumber {
                Stepper(value: $viewModel.installmentNumber,
                        in: 1...24) {
                    Text("Parcelas: \(viewModel.installmentNumber)x")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionView()
    }
    .environmentObject({
        let s = SessionStore()
        s.isAuthenticated = true
        s.terminalDescription = "Loja Demo • Terminal 00000001"
        return s
    }())
}
