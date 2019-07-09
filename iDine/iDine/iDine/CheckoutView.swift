//
//  CheckoutView.swift
//  iDine
//
//  Created by Chris Thomas on 09/07/2019.
//  Copyright © 2019 Chris Thomas. All rights reserved.
//

import SwiftUI

struct CheckoutView : View {
    @EnvironmentObject var order: Order
    
    static let paymentTypes = ["Cash", "Credit Card", "iDine Points"]
    
    @State var paymentType = 0
    
    var body: some View {
        VStack {
            Section {
                Picker(selection: $paymentType, label: Text("How do you want to pay")) {
                    ForEach(0 ..< Self.paymentTypes.count) {
                        Text(Self.paymentTypes[$0])
                    }
                }
            }
        }
        .navigationBarTitle(Text("Payment"), displayMode: .inline)
        
    }
}

#if DEBUG
struct CheckoutView_Previews : PreviewProvider {
    static let order = Order()
    static var previews: some View {
        order.add(item: MenuItem.example)
        return CheckoutView().environmentObject(order)
    }
}
#endif
