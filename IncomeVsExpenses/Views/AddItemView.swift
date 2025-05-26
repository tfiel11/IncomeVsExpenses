//
//  AddItemView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

struct ItemForm: Identifiable {
    let id = UUID()
    var name: String = ""
    var amount: String = ""
    var isIncome: Bool = true
}

struct AddItemView: View {
    @Binding var name: String
    @Binding var amount: String
    @Binding var isIncome: Bool
    
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    @State private var additionalForms: [ItemForm] = []
    @FocusState private var isNameFocused: Bool
    @FocusState private var isAmountFocused: Bool
    @FocusState private var focusedField: UUID?
    
    var body: some View {
        NavigationStack {
            Form {
                // Primary item form
                Section("New Item") {
                    mainItemForm
                }
                
                // Additional item forms
                ForEach($additionalForms) { $form in
                    Section {
                        itemForm(for: form)
                        
                        Button(role: .destructive) {
                            withAnimation {
                                if let index = additionalForms.firstIndex(where: { $0.id == form.id }) {
                                    additionalForms.remove(at: index)
                                }
                            }
                        } label: {
                            Label("Remove Item", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Add another item button
                Section {
                    Button {
                        withAnimation {
                            let newForm = ItemForm()
                            additionalForms.append(newForm)
                            // Focus the name field of the new form after a brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedField = newForm.id
                            }
                        }
                    } label: {
                        Label("Add Another Item", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetAll()
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(additionalForms.isEmpty ? "Add" : "Add All") {
                        // Add main item
                        if isMainFormValid {
                            onAdd()
                        }
                        
                        // Add all additional items
                        for form in additionalForms {
                            if isFormValid(form) {
                                // Set the bindings to the form values
                                name = form.name
                                amount = form.amount
                                isIncome = form.isIncome
                                // Call onAdd for each valid form
                                onAdd()
                            }
                        }
                        
                        // Reset and dismiss
                        resetAll()
                        onCancel()
                    }
                    .disabled(!isMainFormValid && !additionalForms.contains(where: isFormValid))
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isNameFocused = false
                            isAmountFocused = false
                            focusedField = nil
                        }
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
    
    private var mainItemForm: some View {
        Group {
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
    
    private func itemForm(for form: ItemForm) -> some View {
        Group {
            TextField("Name", text: .init(
                get: { form.name },
                set: { newValue in
                    if let index = additionalForms.firstIndex(where: { $0.id == form.id }) {
                        additionalForms[index].name = newValue
                    }
                }
            ))
            .focused($focusedField, equals: form.id)
            
            TextField("Amount", text: .init(
                get: { form.amount },
                set: { newValue in
                    if let index = additionalForms.firstIndex(where: { $0.id == form.id }) {
                        additionalForms[index].amount = newValue
                    }
                }
            ))
            .keyboardType(.decimalPad)
            
            Picker("Type", selection: .init(
                get: { form.isIncome },
                set: { newValue in
                    if let index = additionalForms.firstIndex(where: { $0.id == form.id }) {
                        additionalForms[index].isIncome = newValue
                    }
                }
            )) {
                Text("Income").tag(true)
                Text("Expense").tag(false)
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Helper Methods
    
    private var isMainFormValid: Bool {
        !name.isEmpty && !amount.isEmpty && isValidAmount(amount)
    }
    
    private func isFormValid(_ form: ItemForm) -> Bool {
        !form.name.isEmpty && !form.amount.isEmpty && isValidAmount(form.amount)
    }
    
    private func isValidAmount(_ amount: String) -> Bool {
        guard let amount = Double(amount) else {
            return false
        }
        return amount > 0
    }
    
    private func resetAll() {
        name = ""
        amount = ""
        additionalForms.removeAll()
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