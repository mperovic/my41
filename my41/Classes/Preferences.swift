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

class PreferencesWindowController: NSWindowController {
	
}

class PreferencesContainerViewController: NSViewController {
	var preferencesCalculatorViewController: PreferencesCalculatorViewController?
	var preferencesModsViewController: PreferencesModsViewController?
	
	var newMod1: String?
	var newMod2: String?
	var newMod3: String?
	var newMod4: String?

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		let segid = segue.identifier ?? "(none)"
		
		if segid == "showSelectCalculatorView" {
			preferencesCalculatorViewController = segue.destinationController as? PreferencesCalculatorViewController
			preferencesCalculatorViewController?.preferencesContainerViewController = self
		}
		if segid == "showModsView" {
			preferencesModsViewController = segue.destinationController as? PreferencesModsViewController
			preferencesModsViewController?.preferencesContainerViewController = self
		}
	}
	
	override func viewDidLoad() {
		let defaults = UserDefaults.standard
		if (defaults.string(forKey: HPPort1) != nil) {
			newMod1 = defaults.string(forKey: HPPort1)!
		}
		if (defaults.string(forKey: HPPort2) != nil) {
			newMod2 = defaults.string(forKey: HPPort2)!
		}
		if (defaults.string(forKey: HPPort3) != nil) {
			newMod3 = defaults.string(forKey: HPPort3)!
		}
		if (defaults.string(forKey: HPPort4) != nil) {
			newMod4 = defaults.string(forKey: HPPort4)!
		}

		loadPreferencesCalculatorViewController()
	}
	
	func loadPreferencesCalculatorViewController() {
		self.performSegue(withIdentifier: "showSelectCalculatorView", sender: self)
	}
	
	func loadPreferencesModsViewController() {
		self.performSegue(withIdentifier: "showModsView", sender: self)
	}
	
	func applyChanges() {
		// First check calclulator type
		var needsRestart = false
		
		let defaults = UserDefaults.standard
		let cType = defaults.integer(forKey: HPCalculatorType)
		let currentCalculatorType = preferencesCalculatorViewController?.calculatorType?.rawValue
		if cType != currentCalculatorType {
			defaults.set(currentCalculatorType!, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		if let fPath = preferencesModsViewController?.expansionModule1.filePath {
			// We have something in Port1
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort1) {
				// And we had something in Port1 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort1)
					needsRestart = true
				}
			} else {
				// Port1 was empty
				defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort1)
				needsRestart = true
			}
		} else {
			// Port1 is empty now
			if let _ = defaults.string(forKey: HPPort1) {
				// But we had something in Port1
				defaults.removeObject(forKey: HPPort1)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule2.filePath {
			// We have something in Port2
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort2) {
				// And we had something in Port2 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort2)
					needsRestart = true
				}
			} else {
				// Port2 was empty
				defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort2)
				needsRestart = true
			}
		} else {
			// Port2 is empty now
			if let _ = defaults.string(forKey: HPPort2) {
				// But we had something in Port2
				defaults.removeObject(forKey: HPPort2)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule3.filePath {
			// We have something in Port3
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort3) {
				// And we had something in Port3 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort3)
					needsRestart = true
				}
			} else {
				// Port3 was empty
				defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort3)
				needsRestart = true
			}
		} else {
			// Port3 is empty now
			if let _ = defaults.string(forKey: HPPort3) {
				// But we had something in Port3
				defaults.removeObject(forKey: HPPort3)
			}
		}
		
		if let fPath = preferencesModsViewController?.expansionModule4.filePath {
			// We have something in Port4
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort4) {
				// And we had something in Port4 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort4)
					needsRestart = true
				}
			} else {
				// Port4 was empty
				defaults.set((fPath as NSString).lastPathComponent, forKey: HPPort4)
				needsRestart = true
			}
		} else {
			// Port4 is empty now
			if let _ = defaults.string(forKey: HPPort4) {
				// But we had something in Port4
				defaults.removeObject(forKey: HPPort4)
			}
		}
		
		defaults.synchronize()
		
		if needsRestart {
			CalculatorController.sharedInstance.resetCalculator(restoringMemory: true)
		}
	}
}

class PreferencesViewController: NSViewController {
	
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
		let menuVC = self.splitViewItems[0].viewController as! PreferencesMenuViewController
		let containerVC = self.splitViewItems[1].viewController as! PreferencesContainerViewController
		menuVC.preferencesContainerViewController = containerVC
		
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.width,
				relatedBy: NSLayoutRelation.equal,
				toItem: nil,
				attribute: NSLayoutAttribute.notAnAttribute,
				multiplier: 0,
				constant: 194
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.height,
				relatedBy: NSLayoutRelation.equal,
				toItem: nil,
				attribute: NSLayoutAttribute.notAnAttribute,
				multiplier: 0,
				constant: 587
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.width,
				relatedBy: NSLayoutRelation.equal,
				toItem: nil,
				attribute: NSLayoutAttribute.notAnAttribute,
				multiplier: 0,
				constant: 528
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.height,
				relatedBy: NSLayoutRelation.equal,
				toItem: nil,
				attribute: NSLayoutAttribute.notAnAttribute,
				multiplier: 0,
				constant: 587
			)
		)
	}
}


//MARK: -

class PreferencesSegue: NSStoryboardSegue {
	override func perform() {
		let source = self.sourceController as! NSViewController
		let destination = self.destinationController as! NSViewController
		
		if source.view.subviews.count > 0 {
			let aView: AnyObject = source.view.subviews[0]
			if aView is NSView {
				aView.removeFromSuperview()
			}
		}
		
		let dView = destination.view
		source.view.addSubview(dView)
		source.view.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[dView]|",
				options: [],
				metrics: nil,
				views: ["dView": dView]
			)
		)
		source.view.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[dView]|",
				options: [],
				metrics: nil,
				views: ["dView": dView]
			)
		)
	}
}
