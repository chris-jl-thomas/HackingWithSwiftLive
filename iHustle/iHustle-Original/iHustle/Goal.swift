//
//  Goal.swift
//  iHustle
//
//  Created by Paul Hudson on 23/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import Foundation

enum Priority: String, Codable {
    case low
    case medium
    case high
}

class Goal: Codable, Hashable {
    var id: String
    var name: String
    var priority: Priority
    var isCompleted: Bool

    init(name: String, priority: Priority, isCompleted: Bool) {
        self.id = UUID().uuidString
        self.name = name
        self.priority = priority
        self.isCompleted = isCompleted
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Goal, rhs: Goal) -> Bool {
        return lhs.id == rhs.id
    }
}
