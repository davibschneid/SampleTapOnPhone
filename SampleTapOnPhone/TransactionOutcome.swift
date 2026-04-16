//
//  TransactionOutcome.swift
//  SampleTapOnPhone
//
//  View-friendly snapshot of the `CardPaymentResult` returned by the
//  SDK. Keeping a dedicated value type here means the SwiftUI layer
//  can render previews without importing the SDK binary.
//

import Foundation
import TapOnPhone

struct TransactionOutcome: Identifiable, Hashable {
    let id = UUID()
    let returnCode: String
    let customerReceipt: String
    let merchantReceipt: String
    let statusText: String
    let isApproved: Bool

    let authorizationCode: String
    let nsuCTF: String
    let nsuHost: String
    let brandName: String
    let maskedPan: String
    let transactionDate: String
    let transactionTime: String
    let totalAmount: Decimal
    let installmentCount: Int

    init(from result: CardPaymentResult) {
        self.returnCode = result.returnCode
        self.customerReceipt = result.customerReceipt
        self.merchantReceipt = result.merchantReceipt
        self.statusText = Self.statusText(for: result.status)
        self.isApproved = result.status == .approved

        let ctf = result.ctf
        self.authorizationCode = ctf.authorizationCode
        self.nsuCTF = ctf.nsuCTF
        self.nsuHost = ctf.nsuHost
        self.brandName = ctf.brandName
        self.maskedPan = ctf.maskedPan
        self.transactionDate = ctf.transactionDate
        self.transactionTime = ctf.transactionTime
        self.totalAmount = ctf.totalAmount
        self.installmentCount = ctf.installmentCount
    }

    private init(
        returnCode: String,
        customerReceipt: String,
        merchantReceipt: String,
        statusText: String,
        isApproved: Bool,
        authorizationCode: String,
        nsuCTF: String,
        nsuHost: String,
        brandName: String,
        maskedPan: String,
        transactionDate: String,
        transactionTime: String,
        totalAmount: Decimal,
        installmentCount: Int
    ) {
        self.returnCode = returnCode
        self.customerReceipt = customerReceipt
        self.merchantReceipt = merchantReceipt
        self.statusText = statusText
        self.isApproved = isApproved
        self.authorizationCode = authorizationCode
        self.nsuCTF = nsuCTF
        self.nsuHost = nsuHost
        self.brandName = brandName
        self.maskedPan = maskedPan
        self.transactionDate = transactionDate
        self.transactionTime = transactionTime
        self.totalAmount = totalAmount
        self.installmentCount = installmentCount
    }

    private static func statusText(for status: CardPaymentStatus) -> String {
        switch status {
        case .approved: return "Aprovada"
        case .denied: return "Negada"
        case .error: return "Erro"
        case .cancelled: return "Cancelada"
        case .unknown: return "Desconhecido"
        @unknown default: return "Desconhecido"
        }
    }
}

extension TransactionOutcome {
    /// Sample outcome used only by SwiftUI previews.
    static let preview = TransactionOutcome(
        returnCode: "00",
        customerReceipt: "COMPROVANTE DO CLIENTE\n...",
        merchantReceipt: "COMPROVANTE DO LOJISTA\n...",
        statusText: "Aprovada",
        isApproved: true,
        authorizationCode: "123456",
        nsuCTF: "000000123",
        nsuHost: "000000456",
        brandName: "VISA",
        maskedPan: "**** **** **** 1234",
        transactionDate: "16/04/2026",
        transactionTime: "20:58:10",
        totalAmount: 42.50,
        installmentCount: 1
    )
}
