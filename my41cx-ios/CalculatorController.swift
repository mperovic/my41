//
//  CalculatorController.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation

class CalculatorController : Calculator {
	static let sharedInstance = CalculatorController()
	
	override init() {
		super.init()
	}
}
