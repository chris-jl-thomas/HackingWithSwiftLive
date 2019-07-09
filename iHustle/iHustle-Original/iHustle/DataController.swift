//
//  DataController.swift
//  iHustle
//
//  Created by Paul Hudson on 23/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class DataController: NSObject {

    static let didUpdateNotifaction = Notification.Name("DidUpdate")

    private override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    static let shared = DataController()

    private(set) var groups = [Group](from: "groups.json") ?? [] {
        didSet {
            didUpdate()
        }
    }

    func append(_ group: Group) {
        groups.append(group)
    }

    @objc private func saveData() {
        groups.save(to: "groups.json")
    }

    func findGoal(withIdentifier identifier: String) -> (group: Group, goal: Goal)? {
        for group in groups {
            for goal in group.goals {
                if goal.id == identifier {
                    return (group, goal)
                }
            }
        }

        return nil
    }

    func didUpdate() {
        NotificationCenter.default.post(name: DataController.didUpdateNotifaction, object: nil)
    }
}
