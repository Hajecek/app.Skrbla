//
//  Models.swift
//  Skrbla
//
//  Lokální datové modely (zatím bez SQL / API).
//

import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Jídlo"
    case transport = "Doprava"
    case housing = "Bydlení"
    case shopping = "Nákupy"
    case entertainment = "Zábava"
    case health = "Zdraví"
    case subscriptions = "Předplatné"
    case other = "Ostatní"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "ticket.fill"
        case .health: return "heart.fill"
        case .subscriptions: return "calendar"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum ExpenseKind: String, Codable, CaseIterable, Identifiable {
    case expense = "Výdaj"
    case income = "Příjem"

    var id: String { rawValue }

    var signedPrefix: String {
        switch self {
        case .expense: return "− "
        case .income: return "+ "
        }
    }
}

struct Expense: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var amount: Double
    var note: String
    var category: ExpenseCategory
    var kind: ExpenseKind
    var date: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        note: String = "",
        category: ExpenseCategory = .other,
        kind: ExpenseKind = .expense,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.note = note
        self.category = category
        self.kind = kind
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        category = try container.decodeIfPresent(ExpenseCategory.self, forKey: .category) ?? .other
        kind = try container.decodeIfPresent(ExpenseKind.self, forKey: .kind) ?? .expense
        date = try container.decode(Date.self, forKey: .date)
    }
}

enum BillingCycle: String, Codable, CaseIterable, Identifiable {
    case weekly = "Týdně"
    case monthly = "Měsíčně"
    case yearly = "Ročně"

    var id: String { rawValue }

    var monthlyFactor: Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1
        case .yearly: return 1.0 / 12.0
        }
    }
}

struct SubscriptionItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var amount: Double
    var cycle: BillingCycle
    var category: ExpenseCategory
    var nextBillingDate: Date
    var isActive: Bool
    var note: String

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        cycle: BillingCycle = .monthly,
        category: ExpenseCategory = .subscriptions,
        nextBillingDate: Date = Date(),
        isActive: Bool = true,
        note: String = ""
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.cycle = cycle
        self.category = category
        self.nextBillingDate = nextBillingDate
        self.isActive = isActive
        self.note = note
    }

    var monthlyCost: Double {
        amount * cycle.monthlyFactor
    }
}

struct LocalUser: Codable, Equatable {
    var id: UUID
    var name: String
    var email: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let emailName = email.split(separator: "@").first.map(String.init) ?? email
        return emailName.isEmpty ? "Uživatel" : emailName
    }

    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased().isEmpty ? "S" : letters.joined().uppercased()
    }
}
