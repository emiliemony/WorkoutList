//
//  Item.swift
//  WorkoutList
//
//  Created by Emilie on 7/4/25.
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
