//
//  Calculator.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation

let MAX_RAM_SIZE		= 0x400
let epromAddress		= 0x4000

var TRACE = 0
var SYNCHRONYZE = false
var SOUND = false

enum HPPort: String, CaseIterable {
	case port1 = "ModulePort1"
	case port2 = "ModulePort2"
	case port3 = "ModulePort3"
	case port4 = "ModulePort4"
	
	func getFilePath() -> String? {
		guard let module = UserDefaults.standard.string(forKey: self.rawValue) else { return nil }

		return Bundle.main.resourcePath! + "/" + module
	}
}

enum HPCalculator: String, CaseIterable, Identifiable {
	case hp41c = "HP 41C"
	case hp41cv = "HP 41CV"
	case hp41cx = "HP 41CX"

	var id: String { rawValue }
}

let hpCalculatorType = "CalculatorType"
let HPPrinterAvailable = "PrinterAvailable"
let HPCardReaderAvailable = "CardReaderAvailable"
let HPDisplayDebug = "DisplayDebug"
let HPConsoleForegroundColor = "ConsoleForegroundColor"
let HPConsoleBackgroundColor = "ConsoleBackgroundColor"
let HPResetCalculator = "ResetCalculator"

class Calculator: ObservableObject {
	var calculatorMod = MOD(memoryCheck: false)
	var portMod: [MOD?] = [nil, nil, nil, nil]
	var calculatorType: HPCalculator?
	var executionTimer: Foundation.Timer?
	var timerModule: Timer?
	var display: Display?
	
	var alphaMode = false
	var prgmMode = false

	init() {
		timerModule = Timer()
		calculatorMod = MOD(memoryCheck: false)

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

	let timeSliceInterval	= 0.01

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
		readROMModule(defaults.string(forKey: hpCalculatorType) ?? "")
		
		// Now we fill each port
		var portNo = 0
		HPPort.allCases.forEach {
			do {
				portMod[portNo] = MOD(memoryCheck: true)
				if let modName = defaults.string(forKey: $0.rawValue) {
					try portMod[portNo]?.readModFromFile(Bundle.main.resourcePath! + "/" + modName, withMemoryCheck: true)
				}
				
				portNo += 1
			} catch _ {
				
			}
		}
	}
	
	func readROMModule(_ cType: String) {
		var filename: String
		switch cType {
		case HPCalculator.hp41c.rawValue:
			calculatorType = .hp41c
			filename = Bundle.main.resourcePath! + "/" + "nut-c.mod"
		case HPCalculator.hp41cv.rawValue:
			calculatorType = .hp41cv
			filename = Bundle.main.resourcePath! + "/" + "nut-cv.mod"
		case HPCalculator.hp41cx.rawValue:
			calculatorType = .hp41cx
			filename = Bundle.main.resourcePath! + "/" + "nut-cx.mod"
		default:
			// Make sure I have a default for next time
			calculatorType = .hp41cx
			let defaults = UserDefaults.standard
			defaults.set(HPCalculator.hp41cx.rawValue, forKey: hpCalculatorType)
			filename = Bundle.main.resourcePath! + "/" + "nut-cx.mod"
			defaults.synchronize()
		}
		
		do {
			try calculatorMod.readModFromFile(filename, withMemoryCheck: true)
		} catch let error as NSError {
			displayAlert(error.description)
		}
	}
	
	@objc func timeSlice(_ timer: Foundation.Timer) {
		cpu.timeSlice(timer)
		display?.timeSlice(timer)
		timerModule?.timeSlice(timer)
	}
}
