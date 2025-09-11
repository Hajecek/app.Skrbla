//
//  AppIntent.swift
//  SkrblaWidget
//
//  Created by Michal Hájek on 11.09.2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Přehled financí" }
    static var description: IntentDescription { "Widget pro přehled financí s progress barem" }
}
