//
//  Notification+Extensions.swift
//  Inspectly
//
//  Created by Agus Cahyono on 19/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let inspectlyRequestsDidChange = Notification.Name("inspectly.requests.didChange")
    static let inspectlySettingsDidChange = Notification.Name("inspectly.settings.didChange")
    static let inspectlyStubsDidChange = Notification.Name("inspectly.stubs.didChange")
}
