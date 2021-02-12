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

    public static func setupViewController(colorPalette: LoopUIColorPalette) -> SetupUIResult<UIViewController & ServiceCreateNotifying & ServiceOnboardNotifying & CompletionNotifying, ServiceUI>
    {
        return .userInteractionRequired(ServiceViewController(rootViewController: LogglyServiceTableViewController(service: LogglyService(), for: .create)))
    }
    
    public func settingsViewController(colorPalette: LoopUIColorPalette) -> (UIViewController & ServiceOnboardNotifying & CompletionNotifying)
    {
        return ServiceViewController(rootViewController: LogglyServiceTableViewController(service: self, for: .update))
    }
    
    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        return nil
    }
}
