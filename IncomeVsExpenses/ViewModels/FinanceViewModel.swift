//
//  FinanceViewModel.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

class FinanceViewModel: ObservableObject {
    // Published properties
    @Published var financeItems: [FinanceItem] = []
    @Published var newItemName: String = ""
    @Published var newItemAmount: String = ""
    @Published var isNewItemIncome: Bool = true
    @Published var lastAddedItem: FinanceItem?
    @Published var showingAnimation: Bool = false
    
    // AppStorage for data persistence
    @AppStorage("savedFinanceItems") private var savedItemsData: Data = Data()
    
    // MARK: - Computed Properties
    
    var totalIncome: Double {
        financeItems.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        financeItems.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    // Scale tilt angle based on balance
    var scaleTiltAngle: Double {
        if totalIncome == 0 && totalExpenses == 0 {
            return 0
        }
        let maxAmount = max(totalIncome, totalExpenses)
        let ratio = min(max(-30, (totalIncome - totalExpenses) / maxAmount * 30), 30)
        return ratio
    }
    
    // MARK: - Initialization
    
    init() {
        loadItems()
    }
    
    // MARK: - Methods
    
    func addItem() {
        guard !newItemName.isEmpty,
              let amount = Double(newItemAmount),
              amount > 0 else {
            return
        }
        
        let newItem = FinanceItem(
            name: newItemName,
            amount: amount,
            isIncome: isNewItemIncome,
            date: Date()
        )
        
        withAnimation {
            financeItems.insert(newItem, at: 0)
        }
        
        // Trigger animation
        lastAddedItem = newItem
        showingAnimation = true
        
        // Reset animation state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showingAnimation = false
        }
        
        resetNewItemFields()
        saveItems()
    }
    
    func deleteItems(at offsets: IndexSet) {
        withAnimation {
            financeItems.remove(atOffsets: offsets)
        }
        saveItems()
    }
    
    func resetNewItemFields() {
        newItemName = ""
        newItemAmount = ""
    }
    
    private func saveItems() {
        do {
            let encoder = JSONEncoder()
            savedItemsData = try encoder.encode(financeItems)
        } catch {
            print("Failed to save finance items: \(error.localizedDescription)")
        }
    }
    
    private func loadItems() {
        do {
            let decoder = JSONDecoder()
            if !savedItemsData.isEmpty {
                financeItems = try decoder.decode([FinanceItem].self, from: savedItemsData)
            } else {
                // Add sample data for first launch
                financeItems = [
                    FinanceItem(name: "Salary", amount: 3000, isIncome: true, date: Date()),
                    FinanceItem(name: "Rent", amount: 1200, isIncome: false, date: Date()),
                    FinanceItem(name: "Groceries", amount: 400, isIncome: false, date: Date()),
                    FinanceItem(name: "Freelance Work", amount: 500, isIncome: true, date: Date())
                ]
                saveItems()
            }
        } catch {
            print("Failed to load finance items: \(error.localizedDescription)")
        }
    }
} 