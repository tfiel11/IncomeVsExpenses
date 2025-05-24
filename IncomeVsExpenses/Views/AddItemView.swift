//
//  AddItemView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

struct AddItemView: View {
    @Binding var name: String
    @Binding var amount: String
    @Binding var isIncome: Bool
    
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                        .focused($isNameFocused)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                    
                    Picker("Type", selection: $isIncome) {
                        Text("Income").tag(true)
                        Text("Expense").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                
                // Add button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd()
                    }
                    .disabled(name.isEmpty || amount.isEmpty || !isValidAmount)
                }
                
                // Keyboard done button
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isNameFocused = false
                            isAmountFocused = false
                        }
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isValidAmount: Bool {
        guard let amount = Double(amount) else {
            return false
        }
        return amount > 0
    }
}

#Preview {
    AddItemView(
        name: .constant(""),
        amount: .constant(""),
        isIncome: .constant(true),
        onAdd: {},
        onCancel: {}
    )
} 