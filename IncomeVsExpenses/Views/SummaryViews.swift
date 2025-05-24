//
//  SummaryViews.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Balance Indicator
struct BalanceIndicator: View {
    let balance: Double
    
    var body: some View {
        let isPositive = balance >= 0
        let color = isPositive ? Color.green : Color.red
        
        return HStack {
            Text("Balance:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("$\(balance, specifier: "%.2f")")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct SummaryViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SummaryCard(title: "Income", amount: 3500, color: .green)
            SummaryCard(title: "Expenses", amount: 1600, color: .red)
            BalanceIndicator(balance: 1900)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 