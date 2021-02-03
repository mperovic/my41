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

	func applicationDidFinishLaunching(_ notification: Notification) {
		let defaults = UserDefaults.standard
		if let _ = defaults.object(forKey: "memory") as? NSData {
			CalculatorApplication.shared.activate(ignoringOtherApps: false)
		} else {
			CalculatorApplication.shared.activate(ignoringOtherApps: true)
		}
		if let aWindow = self.window {
			aWindow.becomeFirstResponder()
			aWindow.becomeKey()
			aWindow.becomeMain()
		}
	}

	func applicationWillResignActive(_ notification: Notification) {
	}

	func applicationWillBecomeActive(_ notification: Notification) {
	}

	func applicationWillTerminate(_ notification: Notification) {
		CalculatorController.sharedInstance.saveMemory()
		CalculatorController.sharedInstance.saveCPU()
	}

	@IBAction func masterClear(sender: AnyObject) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: "memory")
		defaults.synchronize()
		CalculatorController.sharedInstance.resetCalculator(restoringMemory: false)
	}
	
	func application(_ app: NSApplication, willEncodeRestorableState coder: NSCoder) {
		// Implement this functionality
	}
	
	func application(_ app: NSApplication, didDecodeRestorableState coder: NSCoder) {
		// Implement this functionality
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}

