//
//  SkrblaTheme.swift
//  Skrbla
//

import SwiftUI

enum SkrblaTheme {
    static let primary = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let primaryDeep = Color(red: 0.10, green: 0.55, blue: 0.35)
    static let secondary = Color(red: 0.10, green: 0.74, blue: 0.72)
    static let secondaryDeep = Color(red: 0.05, green: 0.52, blue: 0.55)
    static let accent = Color(red: 0.98, green: 0.65, blue: 0.10)
    static let info = Color(red: 0.18, green: 0.42, blue: 0.98)
    static let slate = Color(red: 0.10, green: 0.14, blue: 0.20)

    static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        formatter.minimumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number) Kč"
    }

    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "cs_CZ")
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func formatDayHeader(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Dnes" }
        if cal.isDateInYesterday(date) { return "Včera" }
        return formatDate(date, style: .full)
    }

    static func formatSignedAmount(_ expense: Expense) -> String {
        "\(expense.kind.signedPrefix)\(formatCurrency(expense.amount))"
    }
}
