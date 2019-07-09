//
//  TabView.swift
//  iDine
//
//  Created by Chris Thomas on 09/07/2019.
//  Copyright © 2019 Chris Thomas. All rights reserved.
//

import SwiftUI

struct TabView: View {
    
    var body: some View {
        
        TabbedView {
            
            ContentView()
                .tabItem {
                    VStack {
                        Image("system-list")
                        Text("Menu")
                    }
            }.tag(0)
            
            OrderView()
                .tabItem {
                    VStack {
                        Image("system-compose")
                        Text("Order")
                    }
            }.tag(1)
        }
    }
}

#if DEBUG
struct TabView_Previews : PreviewProvider {
    static let order = Order()
    static var previews: some View {
        order.add(item: MenuItem.example)
        return TabView().environmentObject(order)
    }
}
#endif
