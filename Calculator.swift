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

		resetCalculator(restoringMemory: true)
	}
	
	func resetCalculator(restoringMemory: Bool) {
		bus.memModules = 0
		bus.XMemModules = 0
		cpu.setRunning(false)
		cpu.reset()

		bus.removeAllRomChips()
		
		self.installBuiltinRoms()
		
		self.installExternalModules()
		emptyRAM()

		if restoringMemory {
			restoreCPU()
			restoreMemory()
		} else {
			let defaults = UserDefaults.standard
			defaults.removeObject(forKey: "cpu")
			defaults.removeObject(forKey: "reg")
			defaults.removeObject(forKey: "memory")
			defaults.synchronize()
		}

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
		bus.ram = [Digits14](repeating: Digits14(), count: MAX_RAM_SIZE)
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
		let defaults = UserDefaults.standard

		do {
			let data = try JSONEncoder().encode(bus.ram)
			defaults.set(data, forKey: "memory")
			defaults.synchronize()
		} catch {
			print(error)
		}
	}

	func saveCPU() {
		do {
			let defaults = UserDefaults.standard

			let cpu = try JSONEncoder().encode(CPU.sharedInstance)
			defaults.set(cpu, forKey: "cpu")

			let reg = try JSONEncoder().encode(CPU.sharedInstance.reg)
			defaults.set(reg, forKey: "reg")
			defaults.synchronize()
		} catch {
			print(error)
		}
	}

	func restoreMemory() {
		if let data = UserDefaults.standard.object(forKey: "memory") as? Data {
			let decoder = JSONDecoder()
			do {
				bus.ram = try decoder.decode([Digits14].self, from: data)
			} catch {
				print(error)
			}
		}
	}

	func restoreCPU() {
		if let archivedCPU = UserDefaults.standard.object(forKey: "cpu") as? Data {
			let decoder = JSONDecoder()
			do {
				let decoded = try decoder.decode(CPU.self, from: archivedCPU)
				cpu.currentTyte = decoded.currentTyte
				cpu.savedPC = decoded.savedPC
				cpu.lastOpCode = decoded.lastOpCode
				cpu.powerOffFlag = decoded.powerOffFlag
				cpu.opcode = decoded.opcode
				cpu.prevPT = decoded.prevPT
			} catch {
				print(error)
			}
		}
		if let archivedCPURegisters = UserDefaults.standard.object(forKey: "reg") as? Data {
			let decoder = JSONDecoder()
			do {
				let decoded = try decoder.decode(CPURegisters.self, from: archivedCPURegisters)
				cpu.reg.A = decoded.A
				cpu.reg.B = decoded.B
				cpu.reg.C = decoded.C
				cpu.reg.M = decoded.M
				cpu.reg.N = decoded.N
				cpu.reg.P = decoded.P
				cpu.reg.Q = decoded.Q
				cpu.reg.PC = decoded.PC
				cpu.reg.G = decoded.G
				cpu.reg.ST = decoded.ST
				cpu.reg.T = decoded.T
				cpu.reg.FI = decoded.FI
				cpu.reg.XST = decoded.XST
				cpu.reg.stack = decoded.stack
				cpu.reg.R = decoded.R
				cpu.reg.mode = decoded.mode
				cpu.reg.ramAddress = decoded.ramAddress
				cpu.reg.peripheral = decoded.peripheral
			} catch {
				print(error)
			}
		}
	}
	
	private func getMemoryContents() -> [Digits14] {
		var memoryArray = [Digits14](repeating: Digits14(), count: MAX_RAM_SIZE)
		for addr in 0..<MAX_RAM_SIZE {
			do {
				let tmpReg = try bus.readRamAddress(Bits12(addr))
				memoryArray[Int(addr)] = tmpReg
				print("save from \(addr): \(tmpReg)")
			} catch {
				if TRACE != 0 {
					print("error RAM address: \(addr)")
				}
			}
		}

		return memoryArray
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
			defaults.synchronize()
		}
		
		do {
			try calculatorMod.readModFromFile(filename)
		} catch let error as NSError {
			displayAlert(error.description)
		}
	}
	
	private func digits14FromArray(_ array: [Digit], position: Int) -> Digits14 {
		var to = Digits14()
		for idx in 0...13 {
			to[idx] = array[position + idx]
		}

		return to
	}
	
	@objc func timeSlice(_ timer: Foundation.Timer)
	{
		cpu.timeSlice(timer)
		display?.timeSlice(timer)
		timerModule?.timeSlice(timer)
	}
}
