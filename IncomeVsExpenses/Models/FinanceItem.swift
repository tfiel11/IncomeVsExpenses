//
//  FinanceItem.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import Foundation

struct FinanceItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let amount: Double
    let isIncome: Bool
    let date: Date
} 