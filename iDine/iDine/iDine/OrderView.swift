//
//  OrderView.swift
//  iDine
//
//  Created by Chris Thomas on 09/07/2019.
//  Copyright © 2019 Chris Thomas. All rights reserved.
//

import SwiftUI

struct OrderView : View {
    @EnvironmentObject var order: Order
    
    var clearEnabled: Bool {
        !order.items.isEmpty
    }
    
    func deleteOrderItem(at offsets: IndexSet) {
        
        if let first = offsets.first {
            order.delete(at: first)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(order.items) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("$\(item.price)")
                        }
                    }.onDelete(perform: deleteOrderItem)
                }
                
                Section {
                    NavigationLink(destination: CheckoutView().environmentObject(order)) {
                        Text("Place order")
                    }
                }.disabled(order.items.isEmpty)
                
                Section {
                    
                    Button(action: {
                        self.order.clear()
                    }) {
                        Text("Clear order")
                            .color(clearEnabled ? .red : .gray)
                    }.disabled(order.items.isEmpty)
                }
            }
            .navigationBarTitle(Text("Order"))
                .listStyle(.grouped)
            .navigationBarItems(trailing: EditButton())
        }
    }
}

#if DEBUG
struct OrderView_Previews : PreviewProvider {
    static let order = Order()
    static var previews: some View {
        order.add(item: MenuItem.example)
        return OrderView().environmentObject(order)
    }
}
#endif
