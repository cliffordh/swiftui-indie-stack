//
//  MyAppWidgetBundle.swift
//  MyAppWidget
//
//  Widget extension entry point for home screen and lock screen widgets.
//

import WidgetKit
import SwiftUI

@main
struct MyAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()           // Home screen widget (small, medium)
        LockScreenStreakWidget() // Lock screen widgets (circular, inline, rectangular)
    }
}
