//
//  Settings.swift
//  my41
//
//  Created by Miroslav Perovic on 3/20/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SettingsViewController: UIViewController, UIAlertViewDelegate {
	@EnvironmentObject var calculator: Calculator

	@IBOutlet weak var sound: UISwitch!
	@IBOutlet weak var syncClock: UISwitch!
	@IBOutlet weak var calculatorSelector: UISegmentedControl!
	
	@IBOutlet weak var expansionModule1: MODsView?
	@IBOutlet weak var expansionModule2: MODsView?
	@IBOutlet weak var expansionModule3: MODsView?
	@IBOutlet weak var expansionModule4: MODsView?
	
//	@ObservedObject private var calculator = Calculator.shared
	
	var yRatio: CGFloat = 1.0

	override func viewWillAppear(_ animated: Bool) {
		calculatorSelector.selectedSegmentIndex = UserDefaults.standard.integer(forKey: HPCalculatorType) - 1

		sound.isOn = SOUND
		self.yRatio = self.view.bounds.size.height / 800.0
	}
	
	@IBAction func clearMemory(_ sender: AnyObject) {
		let alertController = UIAlertController(
			title: "Reset Calculator",
			message: "This operation will clear all programs and memory registers",
			preferredStyle: .alert
		)

		let destructiveAction = UIAlertAction(title: "Continue", style: .destructive) { (result : UIAlertAction) -> Void in
			self.calculator.resetCalculator(restoringMemory: false)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
			print("Cancel clear memory")
		}
		alertController.addAction(cancelAction)
		alertController.addAction(destructiveAction)
		self.present(alertController, animated: true, completion: nil)
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
		let currentCalculatorType = calculatorSelector.selectedSegmentIndex + 1
		if calculatorType != currentCalculatorType {
			defaults.set(currentCalculatorType, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		// Modules
		if let fPath = self.expansionModule1?.filePath {
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

		if let fPath = self.expansionModule2?.filePath {
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

		if let fPath = self.expansionModule3?.filePath {
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

		if let fPath = self.expansionModule4?.filePath {
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
			calculator.resetCalculator(restoringMemory: true)
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

	var modFiles = [String]()
	var allModFiles = [String]()

	@IBOutlet weak var settingsViewController: SettingsViewController?
	
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
		self.button.backgroundColor = UIColor.clear
		self.button.addTarget(
			self,
			action: #selector(MODsView.buttonAction(_:)),
			for: UIControl.Event.touchUpInside
		)
		self.addSubview(self.button)
	}
	
	@objc func buttonAction(_ sender: AnyObject) {
		if filePath != nil {
			let alertController = UIAlertController(
				title: "Reset Calculator",
				message: "What do you want to do with module",
				preferredStyle: .alert
			)

			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
				if let oldFilePath = oldFilePath {
					filePath = oldFilePath
					oldFilePath = nil
				}
			}
			let emptyAction = UIAlertAction(title: "Empty port", style: .default) { (result : UIAlertAction) -> Void in
				filePath = nil
				setNeedsDisplay()
			}
			let replaceAction = UIAlertAction(title: "Replace module", style: .default) { (result : UIAlertAction) -> Void in
				oldFilePath = filePath
				filePath = nil
				selectModule()
			}
			alertController.addAction(cancelAction)
			alertController.addAction(emptyAction)
			alertController.addAction(replaceAction)
			settingsViewController?.present(alertController, animated: true, completion: nil)
		} else {
			selectModule()
		}
	}
	
	func selectModule() {
		let alertController = UIAlertController(
			title: "Port \(port)",
			message: "Choose module",
			preferredStyle: .alert
		)

		self.reloadModFiles()
		for (_, element) in modFiles.enumerated() {
			let modAction = UIAlertAction(title: (element as NSString).lastPathComponent, style: .default) { (result : UIAlertAction) -> Void in
				self.filePath = element
				self.oldFilePath = nil
				self.setNeedsDisplay()
			}
			alertController.addAction(modAction)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
			if let oldFilePath = self.oldFilePath {
				self.filePath = oldFilePath
				self.oldFilePath = nil
			}
		}
		alertController.addAction(cancelAction)
		settingsViewController?.present(alertController, animated: true, completion: nil)
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
		
		let font = UIFont.systemFont(ofSize: 15.0 * (settingsViewController?.yRatio)!)
		let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.center
		let attributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font,
			convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
		]
		if let fPath = filePath {
			let mod = MOD()
			do {
				try mod.readModFromFile(fPath)
				mod.moduleHeader.title.draw(
					in: CGRect(x: 10.0, y: 10.0, width: self.bounds.size.width - 20.0, height: self.bounds.size.height - 20.0),
					withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes)
				)
			} catch {
				
			}
		} else {
			let title = "Empty module"
			title.draw(
				in: CGRect(x: 10.0, y: 10.0, width: self.bounds.size.width - 20.0, height: self.bounds.size.height - 20.0),
				withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes)
			)

		}
	}
	
	//MARK: - Private methods
	
	func reloadModFiles() {
		modFiles = allModFiles
		removeLoadedModules()
	}
	
	func modFilesInBundle() -> [String] {
		var realModFiles: [String] = [String]()
		let modFiles = Bundle.main.paths(forResourcesOfType: "mod", inDirectory: nil)
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
			if let path = settingsViewController?.expansionModule1?.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort2) != nil) {
			if let path = settingsViewController?.expansionModule2?.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort3) != nil) {
			if let path = settingsViewController?.expansionModule3?.filePath {
				removeModFile(path)
			}
		}
		if (defaults.string(forKey: HPPort4) != nil) {
			if let path = settingsViewController?.expansionModule4?.filePath {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
