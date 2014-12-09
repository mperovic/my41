//
//  AppDelegate.swift
//  my41
//
//  Created by Miroslav Perovic on 7/30/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	var window: CalculatorWindow?
	var buttonPressed = false
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
		let defaults = NSUserDefaults.standardUserDefaults()
		if let memory = defaults.objectForKey("memory") as? NSData {
			CalculatorApplication.sharedApplication().activateIgnoringOtherApps(false)
		} else {
			CalculatorApplication.sharedApplication().activateIgnoringOtherApps(true)
		}
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
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey("memory")
		defaults.synchronize()
		CalculatorController.sharedInstance.resetCalculator(false)
	}	
}

