//
//  TransactionViewModel.swift
//  SampleTapOnPhone
//
//  Executes debit and credit card payments through the TapOnPhone
//  SDK and maps the resulting `CardPaymentResult` to a view-friendly
//  `TransactionOutcome` value.
//

import Foundation
import TapOnPhone

@MainActor
final class TransactionViewModel: ObservableObject {
    enum Operation: String, CaseIterable, Identifiable {
        case debit, credit
        var id: String { rawValue }
        var title: String {
            switch self {
            case .debit: return "Débito"
            case .credit: return "Crédito"
            }
        }
    }

    /// Mirrors `TapOnPhone.InstallmentType` with a UI-facing title.
    /// Kept independent from the SDK enum so the view layer never
    /// imports `TapOnPhone` directly.
    enum InstallmentMode: String, CaseIterable, Identifiable {
        case upfront
        case store
        case administrative
        case merchantInstallment

        var id: String { rawValue }

        var title: String {
            switch self {
            case .upfront: return "À vista"
            case .store: return "Parcelado loja"
            case .administrative: return "Administrativo"
            case .merchantInstallment: return "Parcelado lojista"
            }
        }

        var usesInstallmentNumber: Bool {
            self == .store || self == .merchantInstallment
        }

        fileprivate var sdkValue: InstallmentType {
            switch self {
            case .upfront: return .upfront
            case .store: return .store
            case .administrative: return .administrative
            case .merchantInstallment: return .merchantInstallment
            }
        }
    }

    @Published var amount: Decimal = 10
    @Published var operation: Operation = .debit
    @Published var installmentType: InstallmentMode = .upfront
    @Published var installmentNumber: Int = 1

    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var result: TransactionOutcome?

    var canExecute: Bool {
        amount > 0
    }

    func executePayment() async {
        guard canExecute else { return }
        isProcessing = true
        defer { isProcessing = false }

        do {
            let cardResult: CardPaymentResult
            switch operation {
            case .debit:
                cardResult = try await TapOnPhoneSDK.operations.executeDebitCardPayment(
                    value: amount
                )
            case .credit:
                cardResult = try await TapOnPhoneSDK.operations.executeCreditCardPayment(
                    value: amount,
                    installmentType: installmentType.sdkValue,
                    installmentNumber: installmentType.usesInstallmentNumber ? installmentNumber : 0
                )
            }
            result = TransactionOutcome(from: cardResult)
        } catch let error as TapOnPhoneTefError {
            errorMessage = Self.describe(error)
        } catch AuthenticationError.tokenExpired {
            errorMessage = "Sessão expirada. Atualize o accessToken na aba Conta."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func describe(_ error: TapOnPhoneTefError) -> String {
        switch error {
        case let .declined(codeErro, codeResp, message):
            return "Transação negada (erro \(codeErro), resp \(codeResp)): \(message)"
        case .invalidInstallments:
            return "Número de parcelas inválido para o modo selecionado."
        }
    }
}
