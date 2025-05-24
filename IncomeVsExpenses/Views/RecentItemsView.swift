//
//  RecentItemsView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

struct RecentItemsView: View {
    let items: [FinanceItem]
    let onDelete: (IndexSet) -> Void
    let filterType: ItemFilterType?
    let onDismiss: () -> Void
    
    init(items: [FinanceItem], filterType: ItemFilterType? = nil, onDelete: @escaping (IndexSet) -> Void, onDismiss: @escaping () -> Void) {
        self.items = items
        self.filterType = filterType
        self.onDelete = onDelete
        self.onDismiss = onDismiss
    }
    
    var filteredItems: [FinanceItem] {
        guard let filterType = filterType else {
            return items
        }
        
        switch filterType {
        case .income:
            return items.filter { $0.isIncome }
        case .expense:
            return items.filter { !$0.isIncome }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredItems.isEmpty {
                    Text(emptyStateMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(filteredItems) { item in
                        FinanceItemRow(item: item)
                    }
                    .onDelete(perform: { indexSet in
                        // Convert filtered indices to original indices
                        let originalIndices = indexSet.map { filteredItems[$0] }
                            .compactMap { item in
                                items.firstIndex(where: { $0.id == item.id })
                            }
                        
                        onDelete(IndexSet(originalIndices))
                    })
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        guard let filterType = filterType else {
            return "Recent Items"
        }
        
        switch filterType {
        case .income:
            return "Income"
        case .expense:
            return "Expenses"
        }
    }
    
    private var emptyStateMessage: String {
        guard let filterType = filterType else {
            return "No items yet. Add your first item using the + button."
        }
        
        switch filterType {
        case .income:
            return "No income items yet. Add your first income using the + button."
        case .expense:
            return "No expense items yet. Add your first expense using the + button."
        }
    }
}

enum ItemFilterType {
    case income
    case expense
}

#Preview {
    let sampleItems: [FinanceItem] = [
        FinanceItem(name: "Salary", amount: 3000, isIncome: true, date: Date()),
        FinanceItem(name: "Rent", amount: 1200, isIncome: false, date: Date().addingTimeInterval(-86400)),
        FinanceItem(name: "Groceries", amount: 400, isIncome: false, date: Date().addingTimeInterval(-172800))
    ]
    
    return RecentItemsView(items: sampleItems, filterType: .income, onDelete: { _ in }, onDismiss: {})
} 