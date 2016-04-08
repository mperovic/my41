//
//  Calculator.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation

enum CalculatorType: Int {
	case HP41C  = 1
	case HP41CV = 2
	case HP41CX = 3
}

let MAX_RAM_SIZE		= 0x400
let epromAddress		= 0x4000

let HPPort1 = "ModulePort1"
let HPPort2 = "ModulePort2"
let HPPort3 = "ModulePort3"
let HPPort4 = "ModulePort4"

let HPCalculatorType = "CalculatorType"
let HPPrinterAvailable = "PrinterAvailable"
let HPCardReaderAvailable = "CardReaderAvailable"
let HPDisplayDebug = "DisplayDebug"
let HPConsoleForegroundColor = "ConsoleForegroundColor"
let HPConsoleBackgroundColor = "ConsoleBackgroundColor"
let HPResetCalculator = "ResetCalculator"

class Calculator: NSObject {
	var calculatorMod = MOD()
	var portMod: [MOD?] = [nil, nil, nil, nil]
	var calculatorType: CalculatorType?
	var executionTimer: NSTimer?
	var timerModule: Timer?
	var display: Display?
	
	var alphaMode = false
	var prgmMode = false

	override init() {
		timerModule = Timer()
		calculatorMod = MOD()

		super.init()
		
		resetCalculator(true)
	}
	
	func resetCalculator(restoringMemory: Bool) {
		// Show progress indicator & status label
		
		bus.memModules = 0
		bus.XMemModules = 0
		cpu.setRunning(false)
		
		bus.removeAllRomChips()
		
		self.installBuiltinRoms()
		
		self.installExternalModules()
		
		if restoringMemory {
			restoreMemory()
		} else {
			emptyRAM()
		}
		
		cpu.reset()
		cpu.setRunning(true)
		self.startExecutionTimer()
	}
	
	func installBuiltinRoms() {
		self.readCalculatorDescriptionFromDefaults()
		
		let debugSupportRom = RomChip()
		debugSupportRom.writable = true
		debugSupportRom[0] = 0x3E0
		debugSupportRom.writable = false
		bus.installRomChip(
			debugSupportRom,
			inSlot: byte(epromAddress >> 12),
			andBank: byte(0)
		)
		
		if self.calculatorMod.data != nil {
			// Install ROMs which came with the calculator module
			do {
				try bus.installMod(self.calculatorMod)
			} catch MODError.freeSpace {
				displayAlert("No free space")
			} catch {
				
			}
		}
	}
	
	func installExternalModules() {
		for idx in 0...3 {
			if self.portMod[idx]?.data != nil {
				do {
					try bus.installMod(self.portMod[idx]!)
				} catch MODError.freeSpace {
					displayAlert("No free space")
				} catch {
					
				}
			}
		}
	}
	
	func emptyRAM()
	{
		let tmpReg = emptyDigit14
		for addr in 0..<MAX_RAM_SIZE {
			do {
				try bus.writeRamAddress(Bits12(addr), from: tmpReg)
			} catch _ {
//				displayAlert("error writing ram at address: \(addr)")
			}
		}
	}
	
	func startExecutionTimer() {
		cpu.setPowerMode(.PowerOn)
		executionTimer = NSTimer.scheduledTimerWithTimeInterval(
			timeSliceInterval,
			target: self,
			selector: #selector(Calculator.timeSlice(_:)),
			userInfo: nil,
			repeats: true
		)
	}
	
	func saveMemory() {
		let data = getMemoryContents()
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(data, forKey: "memory")
		defaults.synchronize()
	}
	
	func restoreMemory() {
		let data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey("memory") as? NSData
		if let aData = data {
			self.setMemoryContents(aData)
		}
	}
	
	func setMemoryContents(data: NSData) {
		// the number of elements:
		let count = data.length / sizeof(UInt8)
		
		// create array of appropriate length:
		var memoryArray = [UInt8](count: count, repeatedValue: 0)
		
		// copy bytes into array
		data.getBytes(&memoryArray, length:count)
		
		var ptr = 0
		for addr in 0..<MAX_RAM_SIZE {
			var tmpReg = emptyDigit14
			digits14FromArray(memoryArray, position: ptr, to: &tmpReg)
			do {
				try bus.writeRamAddress(Bits12(addr), from: tmpReg)
			} catch _ {
//				displayAlert("error writing ram at address: \(addr)")
			}

			ptr += 14
		}
	}
	
	func getMemoryContents() -> NSData {
		let data: NSMutableData = NSMutableData()
		let count = 14 * MAX_RAM_SIZE
		var memoryArray = [UInt8](count: count, repeatedValue: 0)
		var ptr = 0
		for addr in 0..<MAX_RAM_SIZE {
			var tmpReg = emptyDigit14
			do {
				try bus.readRamAddress(Bits12(addr), into: &tmpReg)
				
				for idx in 0...13 {
					memoryArray[ptr+idx] = tmpReg[idx]
				}
				ptr += 14
			} catch {
				if TRACE != 0 {
					print("error RAM address: \(addr)")
				}
			}
		}
		data.appendBytes(memoryArray, length: count)
		
		return data
	}
	
	func readCalculatorDescriptionFromDefaults() {
		let defaults = NSUserDefaults.standardUserDefaults()
		let cType = defaults.integerForKey(HPCalculatorType)
		readROMModule(cType)
		
		// Now we fill each port
		do {
			if defaults.stringForKey(HPPort1) != nil {
				portMod[0] = MOD()
				try portMod[0]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort1)!)
			}
			if defaults.stringForKey(HPPort2) != nil {
				portMod[1] = MOD()
				try portMod[1]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort2)!)
			}
			if defaults.stringForKey(HPPort3) != nil {
				portMod[2] = MOD()
				try portMod[2]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort3)!)
			}
			if defaults.stringForKey(HPPort4) != nil {
				portMod[3] = MOD()
				try portMod[3]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort4)!)
			}
		} catch _ {
			
		}
	}
	
	func readROMModule(cType: Int) {
		var filename: String
		switch cType {
		case 1:
			calculatorType = .HP41C
			filename = NSBundle.mainBundle().resourcePath! + "/" + "nut-c.mod"
		case 2:
			calculatorType = .HP41CV
			filename = NSBundle.mainBundle().resourcePath! + "/" + "nut-cv.mod"
		case 3:
			calculatorType = .HP41CX
			filename = NSBundle.mainBundle().resourcePath! + "/" + "nut-cx.mod"
		default:
			// Make sure I have a default for next time
			calculatorType = .HP41CX
			let defaults = NSUserDefaults.standardUserDefaults()
			defaults.setInteger(CalculatorType.HP41CX.rawValue, forKey: HPCalculatorType)
			filename = NSBundle.mainBundle().resourcePath! + "/" + "nut-cx.mod"
		}
		
		do {
			try calculatorMod.readModFromFile(filename)
		} catch let error as NSError {
			displayAlert(error.description)
		}
	}
	
	func digits14FromArray(array: [Digit], position: Int, inout to: Digits14) {
		for idx in 0...13 {
			to[idx] = array[position + idx]
		}
	}
	
	func timeSlice(timer: NSTimer)
	{
		cpu.timeSlice(timer)
		display?.timeSlice(timer)
		timerModule?.timeSlice(timer)
	}
}
