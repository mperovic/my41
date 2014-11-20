//
//  DebugCPUView.swift
//  my41
//
//  Created by Miroslav Perovic on 11/15/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class DebugCPUAndMemoryViewController: NSViewController {
	var debugCPUViewController: DebugCPUViewController?
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		let segid = segue.identifier ?? "(none)"
		println("\(__FUNCTION__) hit, segue ID = \(segid)")

		if segid == "showCPUView" {
			if debugCPUViewController == nil {
				debugCPUViewController = segue.destinationController as? DebugCPUViewController
			}
		}
	}

	override func viewDidLoad() {
		loadCPUViewController()
	}
	
	func loadCPUViewController() {
		self.performSegueWithIdentifier("showCPUView", sender: self)
	}
}


//MARK: -

class DebugCPUViewController: NSViewController {
	@IBOutlet weak var cpuRegistersView: NSView!
	@IBOutlet weak var cpuRegisterA: NSTextField!
	@IBOutlet weak var cpuRegisterB: NSTextField!
	@IBOutlet weak var cpuRegisterC: NSTextField!
	@IBOutlet weak var cpuRegisterM: NSTextField!
	@IBOutlet weak var cpuRegisterN: NSTextField!
	@IBOutlet weak var cpuRegisterP: NSTextField!
	@IBOutlet weak var cpuRegisterQ: NSTextField!
	@IBOutlet weak var cpuRegisterPC: NSTextField!
	@IBOutlet weak var cpuRegisterG: NSTextField!
	@IBOutlet weak var cpuRegisterT: NSTextField!
	@IBOutlet weak var cpuRegisterXST: NSTextField!
	@IBOutlet weak var cpuRegisterST: NSTextField!
	@IBOutlet weak var cpuRegisterR: NSTextField!
	@IBOutlet weak var cpuRegisterCarry: NSTextField!
	@IBOutlet weak var cpuPowerMode: NSTextField!
	@IBOutlet weak var cpuSelectedRAM: NSTextField!
	@IBOutlet weak var cpuSelectedPeripheral: NSTextField!
	@IBOutlet weak var cpuMode: NSTextField!
	@IBOutlet weak var cpuStack1: NSTextField!
	@IBOutlet weak var cpuStack2: NSTextField!
	@IBOutlet weak var cpuStack3: NSTextField!
	@IBOutlet weak var cpuStack4: NSTextField!
	@IBOutlet weak var cpuRegisterKY: NSTextField!
	@IBOutlet weak var cpuRegisterFI: NSTextField!
	
	@IBOutlet weak var displayRegistersView: NSView!
	@IBOutlet weak var displayRegisterA: NSTextField!
	@IBOutlet weak var displayRegisterB: NSTextField!
	@IBOutlet weak var displayRegisterC: NSTextField!
	@IBOutlet weak var displayRegisterE: NSTextField!
	
	var cpu = CPU.sharedInstance
	var calculatorController = CalculatorController.sharedInstance
	
	override func viewDidLoad() {
		self.cpuRegistersView.wantsLayer = true
		self.cpuRegistersView.layer?.masksToBounds = true
		self.cpuRegistersView.layer?.borderWidth = 2.0
		self.cpuRegistersView.layer?.borderColor = CGColorCreateGenericGray(0.75, 1.0)
		self.cpuRegistersView.layer?.cornerRadius = 6.0
		
		self.displayRegistersView.wantsLayer = true
		self.displayRegistersView.layer?.masksToBounds = true
		self.displayRegistersView.layer?.borderWidth = 2.0
		self.displayRegistersView.layer?.borderColor = CGColorCreateGenericGray(0.75, 1.0)
		self.displayRegistersView.layer?.cornerRadius = 6.0
		
		cpu.debugViewController = self
		
		updateAll()
	}
	
	func updateDisplay() {
		updateAll()
	}
	
	func updateAll() {
		populateCPURegisters()
		populateDisplayRegisters()
	}
	
	func populateCPURegisters() {
		cpuRegisterA.stringValue = cpu.digits14ToString(cpu.reg.A)
		cpuRegisterB.stringValue = cpu.digits14ToString(cpu.reg.B)
		cpuRegisterC.stringValue = cpu.digits14ToString(cpu.reg.C)
		cpuRegisterM.stringValue = cpu.digits14ToString(cpu.reg.M)
		cpuRegisterN.stringValue = cpu.digits14ToString(cpu.reg.N)
		cpuRegisterP.stringValue = cpu.bits4ToString(cpu.reg.P)
		cpuRegisterQ.stringValue = cpu.bits4ToString(cpu.reg.Q)
		cpuRegisterPC.stringValue = NSString(format:"%04X", cpu.reg.PC)
		cpuRegisterG.stringValue = NSString(format:"%02X", cpu.reg.G)
		cpuRegisterT.stringValue = NSString(format:"%02X", cpu.reg.T)
		cpuRegisterXST.stringValue = NSString(format:"%02X", cpu.reg.XST)
		cpuRegisterST.stringValue = NSString(format:"%02X", cpu.reg.ST)
		if cpu.reg.R == 0 {
			cpuRegisterR.stringValue = "P"
		} else {
			cpuRegisterR.stringValue = "Q"
		}
		switch cpu.powerMode {
		case .DeepSleep:
			cpuPowerMode.stringValue = "D"
		case .LightSleep:
			cpuPowerMode.stringValue = "L"
		case .PowerOn:
			cpuPowerMode.stringValue = "P"
		}
		if cpu.reg.carry == 0 {
			cpuRegisterCarry.stringValue = "T"
		} else {
			cpuRegisterCarry.stringValue = "F"
		}
		switch cpu.reg.mode {
		case .DEC_MODE:
			cpuMode.stringValue = "D"
		case .HEX_MODE:
			cpuMode.stringValue = "H"
		}
		cpuStack1.stringValue = NSString(format:"%04X", cpu.reg.stack[0])
		cpuStack2.stringValue = NSString(format:"%04X", cpu.reg.stack[1])
		cpuStack3.stringValue = NSString(format:"%04X", cpu.reg.stack[2])
		cpuStack4.stringValue = NSString(format:"%04X", cpu.reg.stack[3])
		cpuRegisterKY.stringValue = NSString(format:"%02X", cpu.reg.KY)
		cpuRegisterFI.stringValue = NSString(format:"%04X", cpu.reg.FI)
		cpuSelectedRAM.stringValue = NSString(format:"%03X", cpu.reg.ramAddress)
		cpuSelectedPeripheral.stringValue = NSString(format:"%02X", cpu.reg.peripheral)
	}
	
	func populateDisplayRegisters() {
		if let display = calculatorController.display {
			displayRegisterA.stringValue = display.digits12ToString(display.registers.A)
			displayRegisterB.stringValue = display.digits12ToString(display.registers.B)
			displayRegisterC.stringValue = display.digits12ToString(display.registers.C)
			displayRegisterE.stringValue = NSString(format:"%03X", display.registers.E)
		}
	}

	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		let segid = segue.identifier ?? "(none)"
		println("\(__FUNCTION__) hit, segue ID = \(segid)")
	}
	
	
}

class DebugCPUView: NSView {
	
}

class DebugSegue: NSStoryboardSegue {
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
