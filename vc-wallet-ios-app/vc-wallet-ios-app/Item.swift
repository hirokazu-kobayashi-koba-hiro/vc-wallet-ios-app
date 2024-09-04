//
//  Item.swift
//  vc-wallet-ios-app
//
//  Created by 小林弘和 on 2024/09/05.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
