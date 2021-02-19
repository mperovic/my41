//
//  SettingsState.swift
//  my41
//
//  Created by Miroslav Perovic on 13.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Combine
import SwiftUI

final class SettingsState: ObservableObject {
	let didChange = PassthroughSubject<SettingsState, Never>()

	@Published var module1: MOD? {
		didSet {
			didChange.send(self)
		}
	}

	@Published var module2: MOD? {
		didSet {
			didChange.send(self)
		}
	}

	@Published var module3: MOD? {
		didSet {
			didChange.send(self)
		}
	}

	@Published var module4: MOD? {
		didSet {
			didChange.send(self)
		}
	}

	
	init() {
		module1 = getModuleForPort(.port1)
		module2 = getModuleForPort(.port2)
		module3 = getModuleForPort(.port3)
		module4 = getModuleForPort(.port4)
	}
	
	private func getModuleForPort(_ port: HPPort) -> MOD? {
		guard let name = getModuleName(port: port) else { return nil}
		
		return try? MOD(modName: Bundle.main.resourcePath! + "/" + name, withMemoryCheck: false)
	}
	
	func setModuleName(_ name: String, port: HPPort) {
		let defaults = UserDefaults.standard
		
		defaults.set(name, forKey: port.rawValue)
		defaults.synchronize()
	}

	func getModuleName(port: HPPort) -> String? {
		let defaults = UserDefaults.standard

		return defaults.string(forKey: port.rawValue)
	}
}
