//
//  Settings.swift
//  my41
//
//  Created by Miroslav Perovic on 3/20/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIAlertViewDelegate {
	@IBOutlet weak var sound: UISwitch!
	@IBOutlet weak var syncClock: UISwitch!
	@IBOutlet weak var calculator: UISegmentedControl!
	
	@IBOutlet weak var expansionModule1: MODsView!
	@IBOutlet weak var expansionModule2: MODsView!
	@IBOutlet weak var expansionModule3: MODsView!
	@IBOutlet weak var expansionModule4: MODsView!
	
	var yRatio: CGFloat = 1.0

	override func viewWillAppear(animated: Bool) {
		let defaults = NSUserDefaults.standardUserDefaults()
		calculator.selectedSegmentIndex = defaults.integerForKey(HPCalculatorType) - 1

		sound.on = SOUND
		self.yRatio = self.view.bounds.size.height / 800.0
	}
	
	@IBAction func clearMemory(sender: AnyObject) {
		var action = UIAlertView(
			title: "Reset Calculator",
			message: "This operation will clear all programs and memory registers",
			delegate: self,
			cancelButtonTitle: "Cancel",
			otherButtonTitles: "Continue"
		)
		action.show()
	}
	
	@IBAction func applyChanges(sender: AnyObject) {
		var needsRestart = false

		let defaults = NSUserDefaults.standardUserDefaults()
		
		// Sound settings
		if sound.on {
			SOUND = true
		} else {
			SOUND = false
		}
		defaults.setBool(SOUND, forKey: "sound")
		
		// Calculator timer
		if syncClock.on {
			SYNCHRONYZE = true
		} else {
			SYNCHRONYZE = false
		}
		defaults.setBool(SYNCHRONYZE, forKey: "synchronyzeTime")

		// Calculator type
		let calculatorType = defaults.integerForKey(HPCalculatorType)
		let currentCalculatorType = calculator.selectedSegmentIndex + 1
		if calculatorType != currentCalculatorType {
			defaults.setInteger(currentCalculatorType, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		// Modules
		if let fPath = self.expansionModule1.filePath {
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
		
		if let fPath = self.expansionModule2.filePath {
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
		
		if let fPath = self.expansionModule3.filePath {
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
		
		if let fPath = self.expansionModule4.filePath {
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

		dismissViewControllerAnimated(
			true,
			completion: nil)
		
		if needsRestart {
			CalculatorController.sharedInstance.resetCalculator(true)
		}
	}
	
	//MARK: - UIAlertViewDelegate
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if buttonIndex == 1 {
			CalculatorController.sharedInstance.resetCalculator(false)
			dismissViewControllerAnimated(
				true,
				completion: nil)
		}
	}
}

class MODsView: UIView, UIAlertViewDelegate {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	var filePath: String?
	var oldFilePath: String?
	var port: Int = 0
	var button: UIButton

	var modFiles: [String] = [String]()
	var allModFiles: [String] = [String]()
	var modFileHeaders: [String: ModuleHeader]?

	@IBOutlet weak var settingsViewController: SettingsViewController!
	
	override func awakeFromNib() {
		allModFiles = modFilesInBundle()

		let defaults = NSUserDefaults.standardUserDefaults()
		switch port {
		case 1:
			if let module1 = defaults.stringForKey(HPPort1) {
				filePath = NSBundle.mainBundle().resourcePath! + "/" + module1
			}
			
		case 2:
			if let module2 = defaults.stringForKey(HPPort2) {
				filePath = NSBundle.mainBundle().resourcePath! + "/" + module2
			}
			
		case 3:
			if let module3 = defaults.stringForKey(HPPort3) {
				filePath = NSBundle.mainBundle().resourcePath! + "/" + module3
			}
			
		case 4:
			if let module4 = defaults.stringForKey(HPPort4) {
				filePath = NSBundle.mainBundle().resourcePath! + "/" + module4
			}
			
		default:
			break
		}
	}
	
	required init(coder aDecoder: NSCoder) {
		self.button = UIButton()
		super.init(coder: aDecoder)

		self.layer.cornerRadius = 5.0
		self.button.frame = self.bounds
		self.button.backgroundColor = UIColor.clearColor()
		self.button.addTarget(
			self,
			action: "buttonAction:",
			forControlEvents: UIControlEvents.TouchUpInside
		)
		self.addSubview(self.button)
	}
	
	func buttonAction(sender: AnyObject) {
		if self.filePath != nil {
			var action = UIAlertView(
				title: "Port \(port)",
				message: "What do you want to do with module",
				delegate: self,
				cancelButtonTitle: "Cancel",
				otherButtonTitles: "Empty port", "Replace module"
			)
			action.show()
		} else {
			self.selectModule()
		}
	}
	
	func selectModule() {
		var action = UIAlertView(
			title: "Port \(port)",
			message: "Choose module",
			delegate: self,
			cancelButtonTitle: "Cancel"
		)
		self.reloadModFiles()
		for (index, element) in enumerate(modFiles) {
			action.addButtonWithTitle(element.lastPathComponent)
		}
		action.show()
	}

	override func drawRect(rect: CGRect) {
		let backColor = UIColor(
			red: 0.1569,
			green: 0.6157,
			blue: 0.8902,
			alpha: 0.95
		)
		let rect = CGRectMake(
			self.bounds.origin.x + 3,
			self.bounds.origin.y + 3,
			self.bounds.size.width - 6,
			self.bounds.size.height - 6
		)
		
		var path = UIBezierPath(
			roundedRect: rect,
			cornerRadius: 5.0
		)
		path.addClip()
		
		backColor.setFill()
		path.fill()
		
		let font = UIFont.systemFontOfSize(15.0 * settingsViewController.yRatio)
		var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.Center
		let attributes = [
			NSFontAttributeName : font,
			NSParagraphStyleAttributeName: textStyle
		]
		if let fPath: NSString = filePath {
			let mod = MOD()
			mod.readModFromFile(fPath as String)
			mod.moduleHeader.title.drawInRect(
				CGRectMake(10.0, 10.0, self.bounds.size.width - 20.0, self.bounds.size.height - 20.0),
				withAttributes: attributes
			)
		} else {
			let title = "Empty module"
			title.drawInRect(
				CGRectMake(10.0, 10.0, self.bounds.size.width - 20.0, self.bounds.size.height - 20.0),
				withAttributes: attributes
			)

		}
	}
	
	//MARK: - UIAlertViewDelegate Methods
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if buttonIndex != 0 {
			// Selected something
			if filePath == nil {
				// Adding new module
				filePath = modFiles[buttonIndex - 1]
				oldFilePath = nil
				self.setNeedsDisplay()
			} else {
				// We already have selected module
				if buttonIndex == 1 {
					// Empty module
					filePath = nil
					self.setNeedsDisplay()
				} else {
					// Change existing module
					oldFilePath = filePath
					filePath = nil
					self.selectModule()
				}
			}
		} else {
			// Cancel
			if oldFilePath != nil {
				filePath = oldFilePath
				oldFilePath = nil
			}
		}
	}
	
	//MARK: - Private methods
	
	func reloadModFiles() {
		modFiles = allModFiles
		removeLoadedModules()
	}
	
	func modFilesInBundle() -> [String] {
		let resourceURL = NSBundle.mainBundle().resourceURL
		let modFiles = NSBundle.mainBundle().pathsForResourcesOfType("mod", inDirectory: nil)
		var realModFiles: [String] = [String]()
		for modFile in modFiles {
			let filePath = modFile as String
			if filePath.lastPathComponent != "nut-c.mod" && filePath.lastPathComponent != "nut-cv.mod" && filePath.lastPathComponent != "nut-cx.mod" {
				realModFiles.append(modFile as String)
			}
		}
		
		return realModFiles
	}
	
	func removeLoadedModules() {
		let defaults = NSUserDefaults.standardUserDefaults()
		if (defaults.stringForKey(HPPort1) != nil) {
			if let path = settingsViewController.expansionModule1.filePath {
				removeModFile(path)
			}
		}
		if (defaults.stringForKey(HPPort2) != nil) {
			if let path = settingsViewController.expansionModule2.filePath {
				removeModFile(path)
			}
		}
		if (defaults.stringForKey(HPPort3) != nil) {
			if let path = settingsViewController.expansionModule3.filePath {
				removeModFile(path)
			}
		}
		if (defaults.stringForKey(HPPort4) != nil) {
			if let path = settingsViewController.expansionModule4.filePath {
				removeModFile(path)
			}
		}
	}
	
	func removeModFile(filename: String) {
		var index = 0
		for aFileName in modFiles {
			if filename == aFileName {
				modFiles.removeAtIndex(index)
				
				break
			}
			index++
		}
	}
}

class MODDetailsView: UIView {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	
	override func drawRect(rect: CGRect) {
		let backColor = UIColor(
			red: 0.99,
			green: 0.99,
			blue: 0.99,
			alpha: 0.95
		)
		let rect = CGRectMake(
			self.bounds.origin.x + 3.0,
			self.bounds.origin.y + 3.0,
			self.bounds.size.width - 6.0,
			self.bounds.size.height - 6.0
		)
		var path = UIBezierPath(
			roundedRect: rect,
			cornerRadius: 5.0
		)
		path.addClip()
		backColor.setFill()
		path.fill()
	}
}