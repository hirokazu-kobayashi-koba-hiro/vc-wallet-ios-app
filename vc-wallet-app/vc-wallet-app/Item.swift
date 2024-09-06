//
//  Item.swift
//  vc-wallet-app
//
//  Created by 小林弘和 on 2024/09/06.
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
