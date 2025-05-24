//
//  FinanceItemRow.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

struct FinanceItemRow: View {
    let item: FinanceItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            let color = item.isIncome ? Color.green : Color.red
            let prefix = item.isIncome ? "+" : "-"
            
            Text(prefix)
                .foregroundColor(color)
                + Text("$\(item.amount, specifier: "%.2f")")
                .foregroundColor(color)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let item = FinanceItem(
        name: "Sample Item",
        amount: 150.0,
        isIncome: true,
        date: Date()
    )
    
    return FinanceItemRow(item: item)
        .padding()
        .previewLayout(.sizeThatFits)
} 