//
//  ScannedDocument.swift
//  iRemember
//
//  Created by Paul Hudson on 25/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import NaturalLanguage
import UIKit

struct ScannedDocument: Codable, Hashable {
    var filename: String
    var text: String
    var sentiment: Double

    var url: URL {
        return UIApplication.documentsDirectory.appendingPathComponent(filename).appendingPathExtension("png")
    }

    init(filename: String = UUID().uuidString, text: String, sentiment: NLTag?) {
        self.filename = filename
        self.text = text
        self.sentiment = Double(sentiment?.rawValue ?? "0") ?? 0
    }
}
