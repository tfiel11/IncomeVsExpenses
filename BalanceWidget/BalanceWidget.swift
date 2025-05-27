//
//  BalanceWidget.swift
//  BalanceWidget
//
//  Created by Tyler Fielding on 5/27/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(date: Date(), income: 3500, expenses: 1600)
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> ()) {
        let entry = BalanceEntry(date: Date(), income: 3500, expenses: 1600)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourdomain.IncomeVsExpenses")
        
        let income = userDefaults?.double(forKey: "widget.totalIncome") ?? 0
        let expenses = userDefaults?.double(forKey: "widget.totalExpenses") ?? 0
        
        let entry = BalanceEntry(date: Date(), income: income, expenses: expenses)
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 5))) // Update every 5 minutes
        
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct BalanceEntry: TimelineEntry {
    let date: Date
    let income: Double
    let expenses: Double
    
    var balance: Double {
        income - expenses
    }
    
    var scaleTiltAngle: Double {
        if income == 0 && expenses == 0 {
            return 0
        }
        let maxAmount = max(income, expenses)
        let ratio = min(max(-30, (income - expenses) / maxAmount * 30), 30)
        return ratio
    }
}

struct BalanceWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Scale visualization
            WidgetScaleView(
                tiltAngle: entry.scaleTiltAngle,
                leftAmount: entry.expenses,
                rightAmount: entry.income
            )
            
            // Balance text
            HStack {
                Text("Balance:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(entry.balance, specifier: "%.2f")")
                    .foregroundColor(entry.balance >= 0 ? .green : .red)
                    .fontWeight(.bold)
            }
            .font(.caption)
        }
        .padding()
    }
}

struct BalanceWidget: Widget {
    let kind: String = "BalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BalanceWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BalanceWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Balance Scale")
        .description("Shows your current financial balance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BalanceWidget()
} timelineProvider: {
    Provider()
}

#Preview(as: .systemMedium) {
    BalanceWidget()
} timelineProvider: {
    Provider()
}
