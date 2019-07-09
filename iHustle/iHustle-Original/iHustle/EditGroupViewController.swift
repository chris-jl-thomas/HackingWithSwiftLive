//
//  EditGroupViewController.swift
//  iHustle
//
//  Created by Paul Hudson on 23/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class EditGroupViewController: UITableViewController {
    var group: Group!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = group.name

        let rename = UIBarButtonItem(image: UIImage(named: "edit"), style: .plain, target: self, action: #selector(renameGroup))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGoal))
        navigationItem.rightBarButtonItems = [add, rename]

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdate), name: DataController.didUpdateNotifaction, object: nil)
        didUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func didUpdate() {
        title = group.name
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if group.goals.count > 0 {
            return "Created: \(group.created)"
        } else {
            return "No goals in this group"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group.goals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Goal", for: indexPath)
        let goal = group.goals[indexPath.row]

        cell.textLabel?.text = goal.name
        cell.detailTextLabel?.text = goal.priority.rawValue.capitalized

        if goal.isCompleted {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    @IBAction func renameGroup(_ sender: Any) {
        let ac = UIAlertController(title: "Rename group", message: "Please enter your new name below.", preferredStyle: .alert)
        ac.addTextField { [weak self] in
            $0.text = self?.group.name
            $0.placeholder = "New group"
        }

        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self, ac] action in
            guard var newName = ac.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            if newName.isEmpty {
                newName = "New group"
            }

            self?.group.name = newName
            self?.title = newName
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    @IBAction func addGoal(_ sender: Any) {
        let goal = Goal(name: "New Goal", priority: .medium, isCompleted: false)
        group.goals.append(goal)
        tableView.insertRows(at: [IndexPath(row: group.goals.count - 1, section: 0)], with: .automatic)
        edit(goal)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = group.goals[indexPath.row]
        edit(goal)
    }

    func edit(_ goal: Goal) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EditGoal") as? EditGoalViewController else {
            fatalError("Failed to load EditGoalViewController from storyboard.")
        }

        vc.goal = goal
        navigationController?.pushViewController(vc, animated: true)
    }
}
