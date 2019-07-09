//
//  Order.swift
//  iDine
//
//  Created by Paul Hudson on 27/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import Combine
import SwiftUI

class Order: BindableObject {
    var items = [MenuItem]() {
        didSet {
            didChange.send()
        }
    }
    
    var didChange = PassthroughSubject<Void, Never>()

    var total: Int {
        if items.count > 0 {
            return items.reduce(0) { $0 + $1.price }
        } else {
            return 0
        }
    }

    func add(item: MenuItem) {
        items.append(item)
    }

    func remove(item: MenuItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
    
    func clear() {
        items.removeAll()
    }
    
    func delete(at offset: Int) {
        items.remove(at: offset)
    }
}
