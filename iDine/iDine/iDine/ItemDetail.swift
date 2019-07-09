//
//  ItemDetail.swift
//  iDine
//
//  Created by Chris Thomas on 09/07/2019.
//  Copyright © 2019 Chris Thomas. All rights reserved.
//

import SwiftUI

struct ItemDetail : View {
    var item: MenuItem
    
    var body: some View {
        VStack {
            Image(item.mainImage)
            Text(item.description)
                .lineLimit(nil)
                .padding()
            Spacer()
        }
        .navigationBarTitle(Text(item.name), displayMode: .inline)
    }
}

#if DEBUG
struct ItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemDetail(item: MenuItem.example)
        }
    }
}
#endif
