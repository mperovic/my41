//
//  PreferencesCalculator.swift
//  my41
//
//  Created by Miroslav Perovic on 11/16/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesCalculatorViewController: NSViewController, NSComboBoxDelegate {
	@IBOutlet weak var calculatorSelector: NSComboBox!
	@IBOutlet weak var printerButton: NSButton!
	@IBOutlet weak var cardReaderButton: NSButton!
	@IBOutlet weak var synchronyzeButton: NSButton!

	var calculatorType: CalculatorType?
	var preferencesContainerViewController: PreferencesContainerViewController?

	override func viewDidLoad() {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		let cType = defaults.integerForKey(HPCalculatorType)
		
		switch cType {
		case 1:
			calculatorType = .HP41C
		case 2:
			calculatorType = .HP41CV
		case 3:
			calculatorType = .HP41CX
		default:
			// Make sure I have a default for next time
			calculatorType = .HP41CX
			defaults.setInteger(CalculatorType.HP41CX.rawValue, forKey: HPCalculatorType)
		}
		calculatorSelector.selectItemAtIndex(cType - 1)
	}
	
	
	//MARK: - Actions
	
	@IBAction func applyChanges(sender: AnyObject)
	{
		preferencesContainerViewController?.applyChanges()
	}
	
	@IBAction func synchronize(sender: AnyObject)
	{
		if sender as NSObject == synchronyzeButton {
			if synchronyzeButton.state == NSOnState {
				SYNCHRONYZE = 1
			} else {
				SYNCHRONYZE = 0
			}
			let defaults = NSUserDefaults.standardUserDefaults()
			defaults.setInteger(SYNCHRONYZE, forKey: "synchronyzeTime")
			defaults.synchronize()
		}
	}

	
	// MARK: - NSComboBoxDelegate Methods
	func comboBoxSelectionDidChange(notification: NSNotification)
	{
		if notification.object as NSObject == calculatorSelector {
			let selected = calculatorSelector.indexOfSelectedItem + 1
			let defaults = NSUserDefaults.standardUserDefaults()
			let cType = defaults.integerForKey(HPCalculatorType)
			
			if selected != cType {
//				comments.stringValue = "Please be aware that changing the calculator type may result in some memory loss"
				switch selected {
				case 1:
					calculatorType = .HP41C
				case 2:
					calculatorType = .HP41CV
				case 3:
					calculatorType = .HP41CX
				default:
					// Make sure I have a default for next time
					calculatorType = .HP41CX
				}
			}
		}
	}
}