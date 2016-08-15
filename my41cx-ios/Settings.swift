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

	override func viewWillAppear(_ animated: Bool) {
		let defaults = UserDefaults.standard
		calculator.selectedSegmentIndex = defaults.integer(forKey: HPCalculatorType) - 1

		sound.isOn = SOUND
		self.yRatio = self.view.bounds.size.height / 800.0
	}
	
	@IBAction func clearMemory(_ sender: AnyObject) {
		let action = UIAlertView(
			title: "Reset Calculator",
			message: "This operation will clear all programs and memory registers",
			delegate: self,
			cancelButtonTitle: "Cancel",
			otherButtonTitles: "Continue"
		)
		action.show()
	}
	
	@IBAction func applyChanges(_ sender: AnyObject) {
		var needsRestart = false
		
		let defaults = UserDefaults.standard
		
		// Sound settings
		if sound.isOn {
			SOUND = true
		} else {
			SOUND = false
		}
		defaults.set(SOUND, forKey: "sound")
		
		// Calculator timer
		if syncClock.isOn {
			SYNCHRONYZE = true
		} else {
			SYNCHRONYZE = false
		}
		defaults.set(SYNCHRONYZE, forKey: "synchronyzeTime")

		// Calculator type
		let calculatorType = defaults.integer(forKey: HPCalculatorType)
		let currentCalculatorType = calculator.selectedSegmentIndex + 1
		if calculatorType != currentCalculatorType {
			defaults.set(currentCalculatorType, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		// Modules
		if let fPath = self.expansionModule1.filePath {
			// We have something in Port1
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort1) {
				// And we had something in Port1 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort1)
					needsRestart = true
				}
			} else {
				// Port1 was empty
				defaults.set(moduleName, forKey: HPPort1)
				needsRestart = true
			}
		} else {
			// Port1 is empty now
			if let _ = defaults.string(forKey: HPPort1) {
				// But we had something in Port1
				defaults.removeObject(forKey: HPPort1)
			}
		}

		if let fPath = self.expansionModule2.filePath {
			// We have something in Port2
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort2) {
				// And we had something in Port2 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort2)
					needsRestart = true
				}
			} else {
				// Port2 was empty
				defaults.set(moduleName, forKey: HPPort2)
				needsRestart = true
			}
		} else {
			// Port2 is empty now
			if let _ = defaults.string(forKey: HPPort2) {
				// But we had something in Port2
				defaults.removeObject(forKey: HPPort2)
			}
		}

		if let fPath = self.expansionModule3.filePath {
			// We have something in Port3
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort3) {
				// And we had something in Port3 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort3)
					needsRestart = true
				}
			} else {
				// Port3 was empty
				defaults.set(moduleName, forKey: HPPort3)
				needsRestart = true
			}
		} else {
			// Port3 is empty now
			if let _ = defaults.string(forKey: HPPort3) {
				// But we had something in Port3
				defaults.removeObject(forKey: HPPort3)
			}
		}

		if let fPath = self.expansionModule4.filePath {
			// We have something in Port4
			let moduleName = (fPath as NSString).lastPathComponent
			if let dModuleName = defaults.string(forKey: HPPort4) {
				// And we had something in Port4 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort4)
					needsRestart = true
				}
			} else {
				// Port4 was empty
				defaults.set(moduleName, forKey: HPPort4)
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

		dismiss(
			animated: true,
			completion: nil)
		
		if needsRestart {
			CalculatorController.sharedInstance.resetCalculator(true)
		}
	}
	
	//MARK: - UIAlertViewDelegate
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if buttonIndex == 1 {
			CalculatorController.sharedInstance.resetCalculator(false)
			dismiss(
				animated: true,
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

		let defaults = UserDefaults.standard
		switch port {
		case 1:
			if let module1 = defaults.string(forKey: HPPort1) {
				filePath = Bundle.main.resourcePath! + "/" + module1
			}
			
		case 2:
			if let module2 = defaults.string(forKey: HPPort2) {
				filePath = Bundle.main.resourcePath! + "/" + module2
			}
			
		case 3:
			if let module3 = defaults.string(forKey: HPPort3) {
				filePath = Bundle.main.resourcePath! + "/" + module3
			}
			
		case 4:
			if let module4 = defaults.string(forKey: HPPort4) {
				filePath = Bundle.main.resourcePath! + "/" + module4
			}
			
		default:
			break
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.button = UIButton()
		super.init(coder: aDecoder)

		self.layer.cornerRadius = 5.0
		self.button.frame = self.bounds
		self.button.backgroundColor = UIColor.clear()
		self.button.addTarget(
			self,
			action: #selector(MODsView.buttonAction(_:)),
			for: UIControlEvents.touchUpInside
		)
		self.addSubview(self.button)
	}
	
	func buttonAction(_ sender: AnyObject) {
		if self.filePath != nil {
			let action = UIAlertView(
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
		let action = UIAlertView(
			title: "Port \(port)",
			message: "Choose module",
			delegate: self,
			cancelButtonTitle: "Cancel"
		)
		self.reloadModFiles()
		for (_, element) in modFiles.enumerated() {
			action.addButton(withTitle: (element as NSString).lastPathComponent)
		}
		action.show()
	}

	override func draw(_ rect: CGRect) {
		let backColor = UIColor(
			red: 0.1569,
			green: 0.6157,
			blue: 0.8902,
			alpha: 0.95
		)
		let rect = CGRect(
			x: self.bounds.origin.x + 3,
			y: self.bounds.origin.y + 3,
			width: self.bounds.size.width - 6,
			height: self.bounds.size.height - 6
		)
		
		let path = UIBezierPath(
			roundedRect: rect,
			cornerRadius: 5.0
		)
		path.addClip()
		
		backColor.setFill()
		path.fill()
		
		let font = UIFont.systemFont(ofSize: 15.0 * settingsViewController.yRatio)
		let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.center
		let attributes = [
			NSFontAttributeName : font,
			NSParagraphStyleAttributeName: textStyle
		]
		if let fPath = filePath {
			let mod = MOD()
			do {
				try mod.readModFromFile(fPath)
				mod.moduleHeader.title.draw(
					in: CGRect(x: 10.0, y: 10.0, width: self.bounds.size.width - 20.0, height: self.bounds.size.height - 20.0),
					withAttributes: attributes
				)
			} catch {
				
			}
		} else {
			let title = "Empty module"
			title.draw(
				in: CGRect(x: 10.0, y: 10.0, width: self.bounds.size.width - 20.0, height: self.bounds.size.height - 20.0),
				withAttributes: attributes
			)

		}
	}
	
	//MARK: - UIAlertViewDelegate Methods
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
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
//		let resourceURL = NSBundle.mainBundle().resourceURL
		let modFiles = Bundle.main.pathsForResources(ofType: "mod", inDirectory: nil)
		var realModFiles: [String] = [String]()
		for modFile in modFiles {
			if (modFile as NSString).lastPathComponent != "nut-c.mod" && (modFile as NSString).lastPathComponent != "nut-cv.mod" && (modFile as NSString).lastPathComponent != "nut-cx.mod" {
				realModFiles.append(modFile)
			}
		}
		
		return realModFiles
	}
	
	func removeLoadedModules() {
		let defaults = UserDefaults.standard
		if (defaults.string(forKey: HPPort1) != nil) {
			if let path = settingsViewController.expansionModule1.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort2) != nil) {
			if let path = settingsViewController.expansionModule2.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort3) != nil) {
			if let path = settingsViewController.expansionModule3.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort4) != nil) {
			if let path = settingsViewController.expansionModule4.filePath {
				removeModFile(path)
			}
		}
	}
	
	func removeModFile(_ filename: String) {
		var index = 0
		for aFileName in modFiles {
			if filename == aFileName {
				modFiles.remove(at: index)
				
				break
			}
			index += 1
		}
	}
}

class MODDetailsView: UIView {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	
	override func draw(_ rect: CGRect) {
		let backColor = UIColor(
			red: 0.99,
			green: 0.99,
			blue: 0.99,
			alpha: 0.95
		)
		let rect = CGRect(
			x: self.bounds.origin.x + 3.0,
			y: self.bounds.origin.y + 3.0,
			width: self.bounds.size.width - 6.0,
			height: self.bounds.size.height - 6.0
		)
		let path = UIBezierPath(
			roundedRect: rect,
			cornerRadius: 5.0
		)
		path.addClip()
		backColor.setFill()
		path.fill()
	}
}
