//
//  Calculator.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation

enum CalculatorType: Int {
	case hp41C  = 1
	case hp41CV = 2
	case hp41CX = 3
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

class Calculator {
	var calculatorMod = MOD()
	var portMod: [MOD?] = [nil, nil, nil, nil]
	var calculatorType: CalculatorType?
	var executionTimer: Foundation.Timer?
	var timerModule: Timer?
	var display: Display?
	
	var alphaMode = false
	var prgmMode = false

	init() {
		timerModule = Timer()
		calculatorMod = MOD()

		resetCalculator(true)
	}
	
	func resetCalculator(_ restoringMemory: Bool) {
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
	
	func emptyRAM() {
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
		cpu.setPowerMode(.powerOn)
		executionTimer = Foundation.Timer.scheduledTimer(
			timeInterval: timeSliceInterval,
			target: self,
			selector: #selector(Calculator.timeSlice(_:)),
			userInfo: nil,
			repeats: true
		)
	}
	
	func saveMemory() {
		let data = getMemoryContents()
		let defaults = UserDefaults.standard
		defaults.set(data, forKey: "memory")
		defaults.synchronize()
	}
	
	func restoreMemory() {
		let data: Data? = UserDefaults.standard.object(forKey: "memory") as? Data
		if let aData = data {
			self.setMemoryContents(aData)
		}
	}
	
	func setMemoryContents(_ data: Data) {
		// the number of elements:
		let count = data.count / MemoryLayout<UInt8>.size
		
		// create array of appropriate length:
		var memoryArray = [UInt8](repeating: 0, count: count)
		
		// copy bytes into array
		(data as NSData).getBytes(&memoryArray, length:count)
		
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
	
	func getMemoryContents() -> Data {
		var data = Data()
		var memoryArray = [UInt8]()
		for addr in 0..<MAX_RAM_SIZE {
			do {
				let tmpReg = try bus.readRamAddress(Bits12(addr))
				memoryArray.append(contentsOf: tmpReg)
			} catch {
				if TRACE != 0 {
					print("error RAM address: \(addr)")
				}
			}
		}
		data.append(memoryArray, count: 14 * MAX_RAM_SIZE)
		
		return data
	}
	
	func readCalculatorDescriptionFromDefaults() {
		let defaults = UserDefaults.standard
		let cType = defaults.integer(forKey: HPCalculatorType)
		readROMModule(cType)
		
		// Now we fill each port
		do {
			if defaults.string(forKey: HPPort1) != nil {
				portMod[0] = MOD()
				try portMod[0]?.readModFromFile(Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort1)!)
			}
			if defaults.string(forKey: HPPort2) != nil {
				portMod[1] = MOD()
				try portMod[1]?.readModFromFile(Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort2)!)
			}
			if defaults.string(forKey: HPPort3) != nil {
				portMod[2] = MOD()
				try portMod[2]?.readModFromFile(Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort3)!)
			}
			if defaults.string(forKey: HPPort4) != nil {
				portMod[3] = MOD()
				try portMod[3]?.readModFromFile(Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort4)!)
			}
		} catch _ {
			
		}
	}
	
	func readROMModule(_ cType: Int) {
		var filename: String
		switch cType {
		case 1:
			calculatorType = .hp41C
			filename = Bundle.main.resourcePath! + "/" + "nut-c.mod"
		case 2:
			calculatorType = .hp41CV
			filename = Bundle.main.resourcePath! + "/" + "nut-cv.mod"
		case 3:
			calculatorType = .hp41CX
			filename = Bundle.main.resourcePath! + "/" + "nut-cx.mod"
		default:
			// Make sure I have a default for next time
			calculatorType = .hp41CX
			let defaults = UserDefaults.standard
			defaults.set(CalculatorType.hp41CX.rawValue, forKey: HPCalculatorType)
			filename = Bundle.main.resourcePath! + "/" + "nut-cx.mod"
		}
		
		do {
			try calculatorMod.readModFromFile(filename)
		} catch let error as NSError {
			displayAlert(error.description)
		}
	}
	
	func digits14FromArray(_ array: [Digit], position: Int, to: inout Digits14) {
		for idx in 0...13 {
			to[idx] = array[position + idx]
		}
	}
	
	@objc func timeSlice(_ timer: Foundation.Timer)
	{
		cpu.timeSlice(timer)
		display?.timeSlice(timer)
		timerModule?.timeSlice(timer)
	}
}
