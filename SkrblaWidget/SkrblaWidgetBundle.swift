//
//  SkrblaWidgetBundle.swift
//  SkrblaWidget
//
//  Created by Michal Hájek on 11.09.2025.
//

import WidgetKit
import SwiftUI

@main
struct SkrblaWidgetBundle: WidgetBundle {
    var body: some Widget {
        SkrblaWidget()
        SkrblaWidgetControl()
        SkrblaWidgetLiveActivity()
    }
}
