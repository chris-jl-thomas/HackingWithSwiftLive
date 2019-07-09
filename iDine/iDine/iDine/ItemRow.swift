//
//  ItemRow.swift
//  iDine
//
//  Created by Chris Thomas on 09/07/2019.
//  Copyright © 2019 Chris Thomas. All rights reserved.
//

import SwiftUI

struct ItemRow: View {
    
    var item: MenuItem
    
    var body: some View {
        
        HStack {
            Image(item.thumbnailImage)
            
            VStack(alignment: .leading) {
                Text(item.name)
                Text(String("$\(item.price)"))
            }
        }
    }
}

#if DEBUG
struct ItemRow_Previews : PreviewProvider {
    static var previews: some View {
        ItemRow(item: MenuItem.example)
    }
}
#endif
