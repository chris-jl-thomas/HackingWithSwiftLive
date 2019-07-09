//
//  Group.swift
//  iHustle
//
//  Created by Paul Hudson on 23/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import Foundation

class Group: Codable, Hashable {
    let id: String
    var name: String
    var goals: [Goal]
    var created: Date

    init(name: String, goals: [Goal], created: Date) {
        self.id = UUID().uuidString
        self.name = name
        self.goals = goals
        self.created = created
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }

    func goal(with identifier: String) -> Goal? {
        for goal in goals {
            if goal.id == identifier {
                return goal
            }
        }

        return nil
    }
}
