//
//  SkrblaWidgetLiveActivity.swift
//  SkrblaWidget
//
//  Created by Michal Hájek on 11.09.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SkrblaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var currentAmount: Double
        var monthlyGoal: Double
        var lastTransaction: String
        var lastTransactionAmount: Double
        var isPositive: Bool
        var category: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SkrblaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SkrblaWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skrbla")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Měsíční přehled")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // App icon
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Main content
                VStack(spacing: 12) {
                    // Current amount
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(context.state.currentAmount, specifier: "%.0f") Kč")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        Spacer()
                        
                        // Progress indicator
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int((context.state.currentAmount / context.state.monthlyGoal) * 100))%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("z cíle")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: min(geometry.size.width * (context.state.currentAmount / context.state.monthlyGoal), geometry.size.width),
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.3), value: context.state.currentAmount)
                        }
                    }
                    .frame(height: 8)
                    
                    // Last transaction
                    HStack(spacing: 12) {
                        Circle()
                            .fill(context.state.isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: context.state.isPositive ? "plus" : "minus")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(context.state.isPositive ? .green : .red)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.lastTransaction)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(context.state.category)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Text("\(context.state.isPositive ? "+" : "-")\(context.state.lastTransactionAmount, specifier: "%.0f") Kč")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(context.state.isPositive ? .green : .red)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Skrbla")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Měsíční přehled")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.currentAmount, specifier: "%.0f") Kč")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        Text("\(Int((context.state.currentAmount / context.state.monthlyGoal) * 100))%")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: min(geometry.size.width * (context.state.currentAmount / context.state.monthlyGoal), geometry.size.width),
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)
                        
                        // Last transaction - kompaktnější layout
                        HStack(spacing: 6) {
                            Circle()
                                .fill(context.state.isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: context.state.isPositive ? "plus" : "minus")
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundColor(context.state.isPositive ? .green : .red)
                                )
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(context.state.lastTransaction)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(context.state.category)
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text("\(context.state.isPositive ? "+" : "-")\(context.state.lastTransactionAmount, specifier: "%.0f") Kč")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(context.state.isPositive ? .green : .red)
                                .monospacedDigit()
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    )
            } compactTrailing: {
                Text("\(context.state.currentAmount, specifier: "%.0f") Kč")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
            } minimal: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            .widgetURL(URL(string: "skrbla://home"))
            .keylineTint(Color.blue)
        }
    }
}

extension SkrblaWidgetAttributes {
    fileprivate static var preview: SkrblaWidgetAttributes {
        SkrblaWidgetAttributes(name: "Skrbla")
    }
}

extension SkrblaWidgetAttributes.ContentState {
    fileprivate static var sample: SkrblaWidgetAttributes.ContentState {
        SkrblaWidgetAttributes.ContentState(
            currentAmount: 12500.0,
            monthlyGoal: 20000.0,
            lastTransaction: "Nákup v obchodě",
            lastTransactionAmount: 250.0,
            isPositive: false,
            category: "Potraviny"
        )
    }
    
    fileprivate static var sample2: SkrblaWidgetAttributes.ContentState {
        SkrblaWidgetAttributes.ContentState(
            currentAmount: 18500.0,
            monthlyGoal: 20000.0,
            lastTransaction: "Příjem z práce",
            lastTransactionAmount: 15000.0,
            isPositive: true,
            category: "Příjem"
        )
    }
}

#Preview("Notification", as: .content, using: SkrblaWidgetAttributes.preview) {
   SkrblaWidgetLiveActivity()
} contentStates: {
    SkrblaWidgetAttributes.ContentState.sample
    SkrblaWidgetAttributes.ContentState.sample2
}
