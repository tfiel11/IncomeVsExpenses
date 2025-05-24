//
//  ContentView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

// MARK: - Main View
struct ContentView: View {
    // ViewModel
    @StateObject private var viewModel = FinanceViewModel()
    @State private var showAddItemSheet: Bool = false
    @State private var showIncomeItemsSheet: Bool = false
    @State private var showExpenseItemsSheet: Bool = false
    
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
                tiltAngle: viewModel.scaleTiltAngle,
                leftAmount: viewModel.totalExpenses,
                rightAmount: viewModel.totalIncome,
                showAnimation: viewModel.showingAnimation,
                lastAddedItemIsIncome: viewModel.lastAddedItem?.isIncome ?? true,
                onExpenseTapped: {
                    showExpenseItemsSheet = true
                },
                onIncomeTapped: {
                    showIncomeItemsSheet = true
                }
            )
            .frame(height: 280)
            .padding(.top, 16)
            
            Spacer(minLength: 24)
            
            // Summary
            summarySection
                .padding(.bottom, 24)
        }
        .navigationTitle("Finances")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddItemSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddItemView(
                name: $viewModel.newItemName,
                amount: $viewModel.newItemAmount,
                isIncome: $viewModel.isNewItemIncome,
                onAdd: {
                    viewModel.addItem()
                    showAddItemSheet = false
                },
                onCancel: {
                    viewModel.resetNewItemFields()
                    showAddItemSheet = false
                }
            )
        }
        .sheet(isPresented: $showIncomeItemsSheet) {
            RecentItemsView(
                items: viewModel.financeItems,
                filterType: .income,
                onDelete: viewModel.deleteItems,
                onDismiss: {
                    showIncomeItemsSheet = false
                }
            )
        }
        .sheet(isPresented: $showExpenseItemsSheet) {
            RecentItemsView(
                items: viewModel.financeItems,
                filterType: .expense,
                onDelete: viewModel.deleteItems,
                onDismiss: {
                    showExpenseItemsSheet = false
                }
            )
        }
    }
    
    // Summary section
    private var summarySection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                SummaryCard(
                    title: "Expenses",
                    amount: viewModel.totalExpenses,
                    color: .red,
                    onTap: {
                        showExpenseItemsSheet = true
                    }
                )
                
                SummaryCard(
                    title: "Income",
                    amount: viewModel.totalIncome,
                    color: .green,
                    onTap: {
                        showIncomeItemsSheet = true
                    }
                )
            }
            .padding(.horizontal, 20)
            
            // Balance indicator
            BalanceIndicator(balance: viewModel.balance)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
} 
