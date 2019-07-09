//
//  EditGoalViewController.swift
//  iHustle
//
//  Created by Paul Hudson on 23/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class EditGoalViewController: UITableViewController, UITextFieldDelegate {
    var goal: Goal!

    @IBOutlet var name: UITextField!
    @IBOutlet var completed: UISwitch!

    @IBOutlet var priorityLow: UITableViewCell!
    @IBOutlet var priorityMedium: UITableViewCell!
    @IBOutlet var priorityHigh: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdate), name: DataController.didUpdateNotifaction, object: nil)
        didUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func didUpdate() {
        title = goal.name

        name.text = goal.name
        completed.isOn = goal.isCompleted
        updatePriorityCheckmark()
    }

    func updatePriorityCheckmark() {
        switch goal.priority {
        case .low:
            priorityLow.accessoryType = .checkmark
            priorityMedium.accessoryType = .none
            priorityHigh.accessoryType = .none

        case .medium:
            priorityLow.accessoryType = .none
            priorityMedium.accessoryType = .checkmark
            priorityHigh.accessoryType = .none

        default:
            priorityLow.accessoryType = .none
            priorityMedium.accessoryType = .none
            priorityHigh.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            name.becomeFirstResponder()
        } else {
            switch indexPath.row {
            case 0:
                goal.priority = .low

            case 1:
                goal.priority = .medium

            default:
                goal.priority = .high
            }

            updatePriorityCheckmark()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func nameChanged(_ sender: Any) {
        goal.name = name.text ?? ""
        title = goal.name
    }

    @IBAction func completionChanged(_ sender: Any) {
        goal.isCompleted = completed.isOn
    }
}
