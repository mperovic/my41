//
//  DebugCPUView.swift
//  my41
//
//  Created by Miroslav Perovic on 11/15/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

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
	
	@IBOutlet weak var traceSwitch: NSButton!
	
	var debugContainerViewController: DebugContainerViewController?
	
	override func viewDidLoad() {
		self.cpuRegistersView.wantsLayer = true
		self.cpuRegistersView.layer?.masksToBounds = true
		self.cpuRegistersView.layer?.borderWidth = 2.0
		self.cpuRegistersView.layer?.borderColor = CGColor(gray: 0.75, alpha: 1.0)
		self.cpuRegistersView.layer?.cornerRadius = 6.0
		
		self.displayRegistersView.wantsLayer = true
		self.displayRegistersView.layer?.masksToBounds = true
		self.displayRegistersView.layer?.borderWidth = 2.0
		self.displayRegistersView.layer?.borderColor = CGColor(gray: 0.75, alpha: 1.0)
		self.displayRegistersView.layer?.cornerRadius = 6.0
		
		cpu.debugCPUViewController = self
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(DebugCPUViewController.updateDisplay),
			name: NSNotification.Name(rawValue: kCPUDebugUpdateDisplay),
			object: nil
		)
		
		updateDisplay()
	}
	
	@objc func updateDisplay() {
		populateCPURegisters()
		populateDisplayRegisters()
	}
	
	func populateCPURegisters() {
		cpuRegisterA.stringValue = cpu.digitsToString(cpu.reg.A.digits)
		cpuRegisterB.stringValue = cpu.digitsToString(cpu.reg.B.digits)
		cpuRegisterC.stringValue = cpu.digitsToString(cpu.reg.C.digits)
		cpuRegisterM.stringValue = cpu.digitsToString(cpu.reg.M.digits)
		cpuRegisterN.stringValue = cpu.digitsToString(cpu.reg.N.digits)
		cpuRegisterP.stringValue = cpu.bits4ToString(cpu.reg.P)
		cpuRegisterQ.stringValue = cpu.bits4ToString(cpu.reg.Q)
		cpuRegisterPC.stringValue = NSString(format:"%04X", cpu.reg.PC) as String
		cpuRegisterG.stringValue = cpu.digitsToString(cpu.reg.G)
		cpuRegisterT.stringValue = NSString(format:"%02X", cpu.reg.T) as String
		let strXST = String(cpu.reg.XST, radix:2)
		cpuRegisterXST.stringValue = pad(string: strXST, toSize: 6)
		let strST = String(cpu.reg.ST, radix:2)
		cpuRegisterST.stringValue = pad(string: strST, toSize: 8)
		if cpu.reg.R == 0 {
			cpuRegisterR.stringValue = "P"
		} else {
			cpuRegisterR.stringValue = "Q"
		}
		switch cpu.powerMode {
		case .deepSleep:
			cpuPowerMode.stringValue = "D"
		case .lightSleep:
			cpuPowerMode.stringValue = "L"
		case .powerOn:
			cpuPowerMode.stringValue = "P"
		}
		if cpu.reg.carry == 0 {
			cpuRegisterCarry.stringValue = "T"
		} else {
			cpuRegisterCarry.stringValue = "F"
		}
		switch cpu.reg.mode {
		case .dec_mode:
			cpuMode.stringValue = "D"
		case .hex_mode:
			cpuMode.stringValue = "H"
		}
		cpuStack1.stringValue = NSString(format:"%04X", cpu.reg.stack[0]) as String
		cpuStack2.stringValue = NSString(format:"%04X", cpu.reg.stack[1]) as String
		cpuStack3.stringValue = NSString(format:"%04X", cpu.reg.stack[2]) as String
		cpuStack4.stringValue = NSString(format:"%04X", cpu.reg.stack[3]) as String
		cpuRegisterKY.stringValue = NSString(format:"%02X", cpu.reg.KY) as String
		cpuRegisterFI.stringValue = NSString(format:"%04X", cpu.reg.FI) as String
		cpuSelectedRAM.stringValue = NSString(format:"%03X", cpu.reg.ramAddress) as String
		cpuSelectedPeripheral.stringValue = NSString(format:"%02X", cpu.reg.peripheral) as String
	}
	
	func pad(string : String, toSize: Int) -> String {
		var padded = string
		for _ in 0..<toSize - string.count {
			padded = "0" + padded
		}
		return padded
	}
	
	func populateDisplayRegisters() {
		if let display = calculator.display {
			displayRegisterA.stringValue = display.digits12ToString(display.registers.A)
			displayRegisterB.stringValue = display.digits12ToString(display.registers.B)
			displayRegisterC.stringValue = display.digits12ToString(display.registers.C)
			displayRegisterE.stringValue = NSString(format:"%03X", display.registers.E) as String
		}
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		let segid = segue.identifier ?? "(none)"
		if TRACE != 0 {
			print("\(#function) hit, segue ID = \(segid)")
		}
	}
	
	@IBAction func traceAction(sender: AnyObject) {
		if sender as? NSObject == traceSwitch {
			if traceSwitch.state == NSControl.StateValue.on {
				TRACE = 1
			} else {
				TRACE = 0
			}
			let defaults = UserDefaults.standard
			defaults.set(TRACE, forKey: "traceActive")
			defaults.synchronize()
		}
	}
}
