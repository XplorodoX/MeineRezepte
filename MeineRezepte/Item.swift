//
//  Item.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
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
