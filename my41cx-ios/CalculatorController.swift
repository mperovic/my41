//
//  CalculatorController.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation

class CalculatorController : Calculator {
	
	class var sharedInstance: CalculatorController {
		struct Singleton {
			static let instance = CalculatorController()
		}
		
		return Singleton.instance
	}
	
	override init() {
		super.init()
	}
}