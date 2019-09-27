//
//  LogglyService+UI.swift
//  LogglyServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit
import LoopKitUI
import LogglyServiceKit

extension LogglyService: ServiceUI {

    public static func setupViewController() -> (UIViewController & ServiceNotifying & CompletionNotifying)? {
        return ServiceViewController(rootViewController: LogglyServiceTableViewController(logglyService: LogglyService(), for: .create))
    }

    public func settingsViewController() -> (UIViewController & ServiceNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: LogglyServiceTableViewController(logglyService: self, for: .update))
    }

}
