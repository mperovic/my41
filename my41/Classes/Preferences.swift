//
//  Preferences.swift
//  my41
//
//  Created by Miroslav Perovic on 10/17/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

let HPCalculatorType = "CalculatorType"
let HPPort1 = "ModulePort1"
let HPPort2 = "ModulePort2"
let HPPort3 = "ModulePort3"
let HPPort4 = "ModulePort4"
let HPPrinterAvailable = "PrinterAvailable"
let HPCardReaderAvailable = "CardReaderAvailable"
let HPDisplayDebug = "DisplayDebug"
let HPConsoleForegroundColor = "ConsoleForegroundColor"
let HPConsoleBackgroundColor = "ConsoleBackgroundColor"
let HPResetCalculator = "ResetCalculator"

class PreferencesWindowController: NSWindowController {
	
}

class PreferencesContainerViewController: NSViewController {
	var preferencesCalculatorViewController: PreferencesCalculatorViewController?
	var preferencesModsViewController: PreferencesModsViewController?
	
	var oldMod1: String?
	var oldMod2: String?
	var oldMod3: String?
	var oldMod4: String?
	var newMod1: String?
	var newMod2: String?
	var newMod3: String?
	var newMod4: String?
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		let segid = segue.identifier ?? "(none)"
		println("\(__FUNCTION__) hit, segue ID = \(segid)")
		
		if segid == "showSelectCalculatorView" {
			preferencesCalculatorViewController = segue.destinationController as? PreferencesCalculatorViewController
			preferencesModsViewController?.preferencesContainerViewController = self
		}
		if segid == "showModsView" {
			preferencesModsViewController = segue.destinationController as? PreferencesModsViewController
			preferencesModsViewController?.preferencesContainerViewController = self
		}
	}
	
	override func viewDidLoad() {
		let defaults = NSUserDefaults.standardUserDefaults()
		if (defaults.stringForKey(HPPort1) != nil) {
			oldMod1 = defaults.stringForKey(HPPort1)!
			newMod1 = oldMod1
		}
		if (defaults.stringForKey(HPPort2) != nil) {
			oldMod2 = defaults.stringForKey(HPPort2)!
			newMod2 = oldMod2
		}
		if (defaults.stringForKey(HPPort3) != nil) {
			oldMod3 = defaults.stringForKey(HPPort3)!
			newMod3 = oldMod3
		}
		if (defaults.stringForKey(HPPort4) != nil) {
			oldMod4 = defaults.stringForKey(HPPort4)!
			newMod4 = oldMod4
		}

		loadPreferencesCalculatorViewController()
	}
	
	func loadPreferencesCalculatorViewController() {
		self.performSegueWithIdentifier("showSelectCalculatorView", sender: self)
	}
	
	func loadPreferencesModsViewController() {
		self.performSegueWithIdentifier("showModsView", sender: self)
	}
	
	func applyChanges() {
		// First check calclulator type
		var needsRestart = false
		
		let defaults = NSUserDefaults.standardUserDefaults()
		let cType = defaults.integerForKey(HPCalculatorType)
		let currentCalculatorType = preferencesCalculatorViewController?.calculatorType?.rawValue
		if cType != currentCalculatorType {
			defaults.setInteger(currentCalculatorType!, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		if let fPath = preferencesModsViewController?.expansionModule1.filePath {
			// We have something in Port1
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort1) {
				// And we had something in Port1 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort1)
					needsRestart = true
				}
			} else {
				// Port1 was empty
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort1)
				needsRestart = true
			}
		} else {
			// Port1 is empty now
			if let dModuleName = defaults.stringForKey(HPPort1) {
				// But we had something in Port1
				defaults.removeObjectForKey(HPPort1)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule2.filePath {
			// We have something in Port2
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort2) {
				// And we had something in Port2 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort2)
					needsRestart = true
				}
			} else {
				// Port2 was empty
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort2)
				needsRestart = true
			}
		} else {
			// Port2 is empty now
			if let dModuleName = defaults.stringForKey(HPPort2) {
				// But we had something in Port2
				defaults.removeObjectForKey(HPPort2)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule3.filePath {
			// We have something in Port3
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort3) {
				// And we had something in Port3 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort3)
					needsRestart = true
				}
			} else {
				// Port3 was empty
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort3)
				needsRestart = true
			}
		} else {
			// Port3 is empty now
			if let dModuleName = defaults.stringForKey(HPPort3) {
				// But we had something in Port3
				defaults.removeObjectForKey(HPPort3)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule4.filePath {
			// We have something in Port4
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort4) {
				// And we had something in Port4 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort4)
					needsRestart = true
				}
			} else {
				// Port4 was empty
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort4)
				needsRestart = true
			}
		} else {
			// Port4 is empty now
			if let dModuleName = defaults.stringForKey(HPPort4) {
				// But we had something in Port4
				defaults.removeObjectForKey(HPPort4)
			}
		}
		
		defaults.synchronize()
		
		if needsRestart {
			CalculatorController.sharedInstance.resetCalculator()
		}
	}
}

class PreferencesViewController: NSViewController {
	var calculatorController = CalculatorController.sharedInstance
	
	@IBOutlet weak var modTitle: NSTextField!
	@IBOutlet weak var modAuthor: NSTextField!
	@IBOutlet weak var modVersion: NSTextField!
	@IBOutlet weak var modCopyright: NSTextField!
	@IBOutlet weak var modCategory: NSTextField!
	@IBOutlet weak var modHardware: NSTextField!
	@IBOutlet weak var expansionModule1: ExpansionView!
	@IBOutlet weak var expansionModule2: ExpansionView!
	@IBOutlet weak var expansionModule3: ExpansionView!
	@IBOutlet weak var expansionModule4: ExpansionView!
	@IBOutlet weak var comments: NSTextField!
	@IBOutlet weak var bottomView: NSView!
	
	@IBOutlet weak var removeModule1: NSButton!
	@IBOutlet weak var removeModule2: NSButton!
	@IBOutlet weak var removeModule3: NSButton!
	@IBOutlet weak var removeModule4: NSButton!
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var calculatorSelectorView: NSView!
	@IBOutlet weak var modSelectorView: NSView!
	@IBOutlet weak var modDetailsView: ModDetailsView!
	
	override func viewDidLoad() {
		self.title = ""
		comments.stringValue = ""
		
		// Draw border on splitView
		bottomView.layer = CALayer()
		bottomView.layer?.borderWidth = 1.0
		bottomView.wantsLayer = true
	}
}


// MARK: - SpitView

class PreferencesSplitViewController: NSSplitViewController {
	
	override func viewWillAppear() {
		let menuVC = self.splitViewItems[0].viewController as PreferencesMenuViewController
		let containerVC = self.splitViewItems[1].viewController as PreferencesContainerViewController
		menuVC.preferencesContainerViewController = containerVC
		
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.Width,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 194
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 587
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.Width,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 528
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 587
			)
		)
	}
}


//MARK: -

class PreferencesSegue: NSStoryboardSegue {
	override func perform() {
		let source = self.sourceController as NSViewController
		let destination = self.destinationController as NSViewController
		
		if source.view.subviews.count > 0 {
			let aView: AnyObject = source.view.subviews[0]
			if aView.isKindOfClass(NSView) {
				aView.removeFromSuperview()
			}
		}
		
		let dView = destination.view
		source.view.addSubview(dView)
		source.view.addConstraints(
			NSLayoutConstraint.constraintsWithVisualFormat(
				"H:|[dView]|",
				options: nil,
				metrics: nil,
				views: ["dView": dView]
			)
		)
		source.view.addConstraints(
			NSLayoutConstraint.constraintsWithVisualFormat(
				"V:|[dView]|",
				options: nil,
				metrics: nil,
				views: ["dView": dView]
			)
		)
	}
}
