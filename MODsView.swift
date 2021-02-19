//
//  MODsView.swift
//  my41
//
//  Created by Miroslav Perovic on 30.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODsView: View {
	var port: HPPort {
		didSet {
			filePath = port.getFilePath()
		}
	}

	var filePath: String?

	@ObservedObject var settingsState: SettingsState

	var onPress: (HPPort) -> () = {_ in }

//	@ViewBuilder
	var body: some View {
		GeometryReader { geometry in
			if getModule() == nil {
				Button(action: {
					onPress(port)
				}, label: {
					Image(systemName: "pencil")
						.font(.system(size: 32))
				})
				.frame(width: geometry.size.width, height: geometry.size.height)
				.clipShape(RoundedRectangle(cornerRadius: 5.0, style: .continuous))
				.foregroundColor(.white)
			} else {
				VStack {
					Spacer()
					MODDetailsView(module: getModule()!, short: true)
						.padding([.leading, .trailing], 5)
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							switch port {
							case .port1:
								settingsState.module1 = nil
							case .port2:
								settingsState.module2 = nil
							case .port3:
								settingsState.module3 = nil
							case .port4:
								settingsState.module4 = nil
							}
						}, label: {
							Image(systemName: "trash")
								.font(.system(size: 26))
								.foregroundColor(.white)
						})
						.padding(.trailing, 10)
						.padding(.bottom, 5)
					}
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
	}
	
	func onPress(_ callback: @escaping (HPPort) -> ()) -> some View {
		MODsView(port: port, settingsState: settingsState, onPress: callback)
	}
	
	func getModule() -> MOD? {
		switch port {
		case .port1:
			return settingsState.module1
		case .port2:
			return settingsState.module2
		case .port3:
			return settingsState.module3
		case .port4:
			return settingsState.module4
		}
	}
}

struct MODsView_Previews: PreviewProvider {
    static var previews: some View {
		MODsView(port: .port1, settingsState: SettingsState())
    }
}
