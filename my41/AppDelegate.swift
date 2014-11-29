//
//  AppDelegate.swift
//  my41
//
//  Created by Miroslav Perovic on 7/30/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	var window: CalculatorWindow?
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
		CalculatorApplication.sharedApplication().activateIgnoringOtherApps(true)
		if let aWindow = self.window {
			aWindow.becomeFirstResponder()
			aWindow.becomeKeyWindow()
			aWindow.becomeMainWindow()
		}
	}


	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
		CalculatorController.sharedInstance.saveMemory()
	}

	@IBAction func masterClear(sender: AnyObject) {
		CalculatorController.sharedInstance.resetCalculator(false)
	}	
}

