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
                    }
                }
                Section {
                    NavigationLink(destination: CheckoutView().environmentObject(order)) {
                        Text("Place order")
                    }
                }
            }
            .navigationBarTitle(Text("Order"))
            .listStyle(.grouped)
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
