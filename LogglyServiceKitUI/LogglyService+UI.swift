//
//  LogglyService+UI.swift
//  LogglyServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import LogglyServiceKit
import HealthKit

extension LogglyService: ServiceUI {
    
    public static var image: UIImage? { nil }
    
    public static var providesOnboarding: Bool { return false }
    
    public static func setupViewController(currentTherapySettings: TherapySettings, preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & CompletionNotifying & ServiceSetupNotifying)?
    {
        return ServiceViewController(rootViewController: LogglyServiceTableViewController(service: LogglyService(), for: .create))
    }
    
    public func settingsViewController(currentTherapySettings: TherapySettings, preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & CompletionNotifying & ServiceSettingsNotifying)
    {
        return ServiceViewController(rootViewController: LogglyServiceTableViewController(service: self, for: .update))
    }
    
    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        return nil
    }
}
