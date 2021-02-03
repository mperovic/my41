//
//  CalculatorController.swift
//  my41
//
//  Created by Miroslav Perovic on 8/1/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class CalculatorController : Calculator {
	static let sharedInstance = CalculatorController()

	override init() {		
		super.init()
		
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSApplication.willBecomeActiveNotification,
			object: nil,
			queue: nil) { active in
				if let tModule = self.timerModule {
					tModule.synchronyzeWithComputer()
				}
		}
	}
}
