//
//  MODList.swift
//  my41
//
//  Created by Miroslav Perovic on 3.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODList: View {
	@ObservedObject var settingsState: SettingsState
	
	private let mods: [MOD] = Array(MODs.getModFiles().values)
	
	@Binding var showList: Bool
	
	@State private var selectedModule: MOD?
	var port: HPPort

    var body: some View {
		VStack {
			HStack {
				Button(action: {
					showList = false
				}, label: {
					Text("Cancel")
				})
				.padding([.top, .leading], 10)
				Spacer()
				Button(action: {
					switch port {
					case .port1:
						settingsState.module1 = selectedModule
					case .port2:
						settingsState.module2 = selectedModule
					case .port3:
						settingsState.module3 = selectedModule
					case .port4:
						settingsState.module4 = selectedModule
					}
					showList = false
				}, label: {
					Text("Apply")
				})
				.padding([.top, .trailing], 10)
			}
			
			List {
				ForEach(mods, id: \.self) { mod in
					MODDetailsView(module: mod, short: false)
						.onTapGesture {
							selectedModule = mod
						}
						.listRowBackground(selectedModule == mod ? Color(UIColor.lightGray) : Color.clear)
				}
			}
		}
	}
}

struct MODList_Previews: PreviewProvider {
	@State static var showList = true
	
    static var previews: some View {
		MODList(settingsState: SettingsState(), showList: $showList, port: .port3)
    }
}
