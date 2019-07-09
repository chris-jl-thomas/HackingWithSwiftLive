//
//  UploadViewController.swift
//  iRemember
//
//  Created by Paul Hudson on 26/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {
    let stackView = UIStackView()

    var documents: [ScannedDocument]!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        title = "Backup"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true

        showCorrectButton()
    }

    func showCorrectButton() {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
        }

        if UserDefaults.standard.string(forKey: "User") != nil {
            let btn = UIButton(type: .system)
            btn.setTitle("Upload Documents", for: .normal)
            btn.addTarget(self, action: #selector(upload), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
        } else {
            // no user account!
        }
    }

    @objc func upload() {
        guard let userID = UserDefaults.standard.string(forKey: "User") else { return }

        guard let encoded = try? JSONEncoder().encode(documents) else {
            print("Failed to encode documents")
            return
        }

        encoded.send(to: "https://www.hackingwithswift.com/samples/user-json/\(userID)") {
            data, response, error in
            guard let data = data else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // upload was successful!
        }
    }
}
