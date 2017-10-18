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
	
	class var sharedInstance: CalculatorController {
		struct Singleton {
			static let instance = CalculatorController()
		}
		
		return Singleton.instance
	}

	override init() {		
		super.init()
		
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSApplicationWillBecomeActive,
			object: nil,
			queue: nil) { active in
				if let tModule = self.timerModule {
					tModule.synchronyzeWithComputer()
				}
		}
	}
}
