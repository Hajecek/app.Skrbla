//
//  SkrblaWidget.swift
//  SkrblaWidget
//
//  Created by Michal Hájek on 11.09.2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct SkrblaWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    // Ukázkové finanční údaje - v reálné aplikaci by se načítaly z databáze
    private let utraceno: Double = 1250.50
    private let budget: Double = 2000.0
    private var progress: Double {
        utraceno / budget
    }
    private var zbyva: Double {
        budget - utraceno
    }

    var body: some View {
        if family == .systemSmall {
            // Kompaktní verze pro nejmenší widget
            VStack(spacing: 8) {
                // Hlavní částka
                Text("\(utraceno, specifier: "%.0f") Kč")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Z celkové částky
                Text("z \(budget, specifier: "%.0f") Kč")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Progress bar
                VStack(spacing: 4) {
                    HStack {
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progress > 0.8 ? .red : .blue)
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(12)
        } else {
            // Plná verze pro větší widgety
            VStack(spacing: 0) {
                // Horní část - informace o utracené částce
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Utraceno")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text("\(utraceno, specifier: "%.0f") Kč")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Ikona peněz
                        Image(systemName: "creditcard.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Z celkové částky
                    HStack {
                        Text("z \(budget, specifier: "%.0f") Kč")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Zbývá \(zbyva, specifier: "%.0f") Kč")
                            .font(.subheadline)
                            .foregroundColor(zbyva > 0 ? .green : .red)
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // Spodní část - progress bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Rozpočet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    
                    // Moderní progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Pozadí progress baru
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(height: 12)
                            
                            // Progress bar s animací
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            progress > 0.8 ? .red : .blue,
                                            progress > 0.8 ? .orange : .cyan
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 12)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

// Komponenta pro ikonu peněz
struct MoneyIcon: View {
    var body: some View {
        ZStack {
            // Hlavní tvar peněz
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.8))
                .frame(width: 20, height: 16)
            
            // Symbol dolaru
            Text("$")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.purple.opacity(0.7))
            
            // Křídla
            HStack {
                // Levé křídlo
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(x: -12, y: -2)
                
                Spacer()
                
                // Pravé křídlo
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(x: 12, y: -2)
            }
        }
        .frame(width: 30, height: 20)
    }
}

struct SkrblaWidget: Widget {
    let kind: String = "SkrblaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SkrblaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Přehled financí")
        .description("Zobrazuje přehled utracených peněz s progress barem")
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

#Preview(as: .systemSmall) {
    SkrblaWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .defaultConfig)
}
