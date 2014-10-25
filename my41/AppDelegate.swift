//
//  AppDelegate.swift
//  my41
//
//  Created by Miroslav Perovic on 7/30/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	var calculatorController = CalculatorController.sharedInstance

	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
		calculatorController.saveMemory()
	}


}

