//
//  my41cx-ios_App.swift
//  my41cx-ios
//
//  Created by Miroslav Perovic on 20.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

@main
struct My41cx_ios_App: App {
	@Environment(\.scenePhase) var scenePhase
	
	@ObservedObject private var calculator = Calculator()

	var body: some Scene {
		WindowGroup {
			My41View()
				.environmentObject(Keys())
				.environmentObject(calculator)
		}
		.onChange(of: scenePhase) { newScenePhase in
			switch newScenePhase {
			case .active:
				print("App is active")
			case .inactive:
				print("App is inactive")
				calculator.saveMemory()
				calculator.saveCPU()
			case .background:
				print("App is in background")
			@unknown default:
				print("Oh - interesting: I received an unexpected new value.")
			}
		}
	}
}
