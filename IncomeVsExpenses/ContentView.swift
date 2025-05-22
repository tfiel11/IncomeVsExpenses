//
//  ContentView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

// MARK: - Data Model
struct FinanceItem: Identifiable, Codable, Equatable {
    var id = UUID()  // Changed from 'let' to 'var' to fix the Codable warning
    let name: String
    let amount: Double
    let isIncome: Bool
    let date: Date
}

// MARK: - Scale View - Simplified version
struct ScaleView: View {
    let tiltAngle: Double
    let leftAmount: Double
    let rightAmount: Double
    let showAnimation: Bool
    let lastAddedItemIsIncome: Bool
    
    @State private var animatedTiltAngle: Double = 0
    @State private var dropAnimation: Bool = false
    @State private var dropPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            let centerY = height / 2
            
            ZStack {
                // T-shaped stand
                standView(centerX: centerX, centerY: centerY, width: width, height: height)
                
                // Scale with beam and pans
                balanceScaleView(centerX: centerX, centerY: centerY, width: width, height: height)
                
                // Coin animation
                coinAnimation(centerX: centerX, centerY: centerY, width: width, height: height)
            }
            .onChange(of: tiltAngle) { _, newAngle in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    animatedTiltAngle = newAngle
                }
            }
            .onChange(of: showAnimation) { _, newValue in
                if newValue {
                    triggerCoinAnimation(centerX: centerX, centerY: centerY, width: width, height: height)
                }
            }
            .onAppear {
                animatedTiltAngle = tiltAngle
            }
        }
    }
    
    // T-shaped stand
    private func standView(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            // Vertical part
            let verticalWidth: CGFloat = 20
            let verticalHeight: CGFloat = height * 0.35
            let verticalX = centerX - verticalWidth/2
            let verticalY = centerY + height * 0.05
            
            path.addRect(CGRect(x: verticalX, y: verticalY, width: verticalWidth, height: verticalHeight))
            
            // Horizontal base
            let baseWidth: CGFloat = width * 0.4
            let baseHeight: CGFloat = 15
            let baseX = centerX - baseWidth/2
            let baseY = verticalY + verticalHeight - baseHeight
            
            path.addRect(CGRect(x: baseX, y: baseY, width: baseWidth, height: baseHeight))
        }
        .fill(Color.gray)
    }
    
    // Improved balance scale visualization
    private func balanceScaleView(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        let pivotY = centerY - height * 0.05
        let panDistance = width * 0.3
        
        // Calculate positions based on angle
        let angleInRadians = Angle.degrees(animatedTiltAngle).radians
        let beamLength = width * 0.7
        
        // Calculate left and right pan centers
        let leftPanY = pivotY + CGFloat(sin(angleInRadians)) * 40
        let rightPanY = pivotY - CGFloat(sin(angleInRadians)) * 40
        
        return ZStack {
            // Beam
            Path { path in
                path.move(to: CGPoint(x: centerX - beamLength/2, y: pivotY + CGFloat(sin(angleInRadians)) * 15))
                path.addLine(to: CGPoint(x: centerX + beamLength/2, y: pivotY - CGFloat(sin(angleInRadians)) * 15))
            }
            .stroke(Color.gray, lineWidth: 8)
            .rotationEffect(.degrees(animatedTiltAngle), anchor: .center)
            
            // Center pivot
            Circle()
                .fill(Color.gray)
                .frame(width: 16, height: 16)
                .position(x: centerX, y: pivotY)
                .shadow(color: .black.opacity(0.2), radius: 1)
            
            // Left pan (expenses)
            VStack(spacing: 0) {
                // Connection line
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 35)
                
                // Pan circle
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 85, height: 85)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                    
                    Text("$\(Int(leftAmount))")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .position(x: centerX - panDistance, y: leftPanY)
            
            // Right pan (income)
            VStack(spacing: 0) {
                // Connection line
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 35)
                
                // Pan circle
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 85, height: 85)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                    
                    Text("$\(Int(rightAmount))")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .position(x: centerX + panDistance, y: rightPanY)
        }
    }
    
    // Coin animation drop
    private func coinAnimation(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        Group {
            if dropAnimation {
                Circle()
                    .fill(lastAddedItemIsIncome ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .position(dropPosition)
            }
        }
    }
    
    // Trigger the animation
    private func triggerCoinAnimation(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        // Target x-position based on income or expense
        let panDistance = width * 0.3
        let targetX = lastAddedItemIsIncome ? (centerX + panDistance) : (centerX - panDistance)
        
        // Initial position (top of screen)
        dropPosition = CGPoint(x: targetX, y: 0)
        dropAnimation = true
        
        // Calculate final y-position
        let pivotY = centerY - height * 0.05
        let angleInRadians = Angle.degrees(animatedTiltAngle).radians
        let panOffset = CGFloat(sin(angleInRadians)) * 40
        let finalY = pivotY + (lastAddedItemIsIncome ? -panOffset : panOffset) + 60 // Position above the pan
        
        // Animate drop
        withAnimation(.easeIn(duration: 0.8)) {
            dropPosition = CGPoint(x: targetX, y: finalY)
        }
        
        // Hide after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                dropAnimation = false
            }
        }
    }
}

// A simple line shape
struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

// MARK: - Main View
struct ContentView: View {
    // State properties
    @State private var financeItems: [FinanceItem] = []
    @State private var newItemName: String = ""
    @State private var newItemAmount: String = ""
    @State private var isNewItemIncome: Bool = true
    @State private var showAddItemSheet: Bool = false
    @State private var lastAddedItem: FinanceItem?
    @State private var showingAnimation: Bool = false
    
    // AppStorage for data persistence
    @AppStorage("savedFinanceItems") private var savedItemsData: Data = Data()
    
    // Computed properties for totals
    private var totalIncome: Double {
        financeItems.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        financeItems.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpenses
    }
    
    // Scale tilt angle based on balance
    private var scaleTiltAngle: Double {
        if totalIncome == 0 && totalExpenses == 0 {
            return 0
        }
        let maxAmount = max(totalIncome, totalExpenses)
        let ratio = min(max(-30, (totalIncome - totalExpenses) / maxAmount * 30), 30)
        return ratio
    }
    
    var body: some View {
        NavigationStack {
            mainContent
        }
    }
    
    // MARK: - Extracted Views
    
    // Main content to simplify body
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Scale visualization
            ScaleView(
                tiltAngle: scaleTiltAngle,
                leftAmount: totalExpenses,
                rightAmount: totalIncome,
                showAnimation: showingAnimation,
                lastAddedItemIsIncome: lastAddedItem?.isIncome ?? true
            )
            .frame(height: 250)
            .padding(.top)
            
            // Summary
            summarySection
            
            // Items list
            financeItemsList
        }
        .navigationTitle("Balance Scale")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddItemSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddItemView(
                name: $newItemName,
                amount: $newItemAmount,
                isIncome: $isNewItemIncome,
                onAdd: addItem,
                onCancel: {
                    resetNewItemFields()
                    showAddItemSheet = false
                }
            )
        }
        .onAppear(perform: loadItems)
    }
    
    // Summary section
    private var summarySection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Expenses",
                    amount: totalExpenses,
                    color: .red
                )
                
                SummaryCard(
                    title: "Income",
                    amount: totalIncome,
                    color: .green
                )
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Balance indicator
            BalanceIndicator(balance: balance)
                .padding(.horizontal)
        }
    }
    
    private var financeItemsList: some View {
        List {
            Section("Recent Items") {
                if financeItems.isEmpty {
                    Text("No items yet. Add your first item using the + button.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(financeItems) { item in
                        FinanceItemRow(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Methods
    private func addItem() {
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
            showingAnimation = false
        }
        
        resetNewItemFields()
        showAddItemSheet = false
        saveItems()
    }
    
    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            financeItems.remove(atOffsets: offsets)
        }
        saveItems()
    }
    
    private func resetNewItemFields() {
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

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
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
                .font(.headline)
            
            Text("$\(balance, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Finance Item Row
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

// MARK: - Add Item View
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
    
    private var isValidAmount: Bool {
        guard let amount = Double(amount) else {
            return false
        }
        return amount > 0
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
