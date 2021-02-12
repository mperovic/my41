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
	
	@Binding var selectedModule: MOD?
	var onDismiss: () -> ()

    var body: some View {
		List {
			ForEach(mods, id: \.self) { mod in
				MODDetailsView(module: mod)
					.onTapGesture {
						selectedModule = mod
					}
					.listRowBackground(selectedModule == mod ? Color(UIColor.lightGray) : Color.clear)
			}
		}
	}
}

struct MODList_Previews: PreviewProvider {
	@State static var selectedModule = MODs.getModFiles().first
    static var previews: some View {
		MODList(selectedModule: $selectedModule, onDismiss: {})
    }
}
