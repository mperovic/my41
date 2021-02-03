//
//  MODList.swift
//  my41
//
//  Created by Miroslav Perovic on 3.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODList: View {
	var mods = MODs.getModFiles()
	
    var body: some View {
		List(mods) { mod in
			MODDetailsView(module: mod)
		}
    }
}

struct MODList_Previews: PreviewProvider {
    static var previews: some View {
        MODList()
    }
}
