//
//  CalculatorController.swift
//  my41
//
//  Created by Miroslav Perovic on 8/1/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

enum CalculatorType: Int {
	case HP41C  = 1
	case HP41CV = 2
	case HP41CX = 3
}

let timeSliceInterval	= 0.01
let MAX_RAM_SIZE		= 0x400

var bus: Bus?
var timerModule: Timer?

class CalculatorController : NSObject {
//	@IBOutlet weak var display: Display!
//	@IBOutlet weak var keyboard: Keyboard!

	var calculatorMod: MOD = MOD()
	var portMod: [MOD?] = [nil, nil, nil, nil]
	var calculatorType: CalculatorType?
	var executionTimer: NSTimer?
	var cpu: CPU
	var display: Display?
	var keyboard: Keyboard?
	
	class var sharedInstance :CalculatorController {
		struct Singleton {
			static let instance = CalculatorController()
		}
		
		return Singleton.instance
	}

	override init() {
		cpu = CPU.sharedInstance
		bus = Bus()
		timerModule = Timer()
		calculatorMod = MOD()
		
		super.init()
		
		resetCalculator()
	}
	
	override func awakeFromNib() {
//		let x: Bool = self.calculatorWindow.excludedFromWindowsMenu
	}
	
	func resetCalculator() {
		cpu.setRunning(false)
		bus!.removeAllRomChips()
		readCalculatorDescriptionFromDefaults()
		installBuiltinRoms()
		installBuiltinRam()
		restoreMemory()
		cpu.reset()
		cpu.setRunning(true)
		startExecutionTimer()
	}
	
	func readCalculatorDescriptionFromDefaults() {
		println("readCalculatorDescriptionFromDefaults")
		let defaults = NSUserDefaults.standardUserDefaults()
		let cType = defaults.integerForKey(HPCalculatorType)
		readROMModule(cType)
		
		// Now we fill each port
		if defaults.stringForKey(HPPort1) != nil {
			portMod[0] = MOD()
			portMod[0]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort1)!)
		}
		if defaults.stringForKey(HPPort2) != nil {
			portMod[1] = MOD()
			portMod[1]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort2)!)
		}
		if defaults.stringForKey(HPPort3) != nil {
			portMod[2] = MOD()
			portMod[2]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort3)!)
		}
		if defaults.stringForKey(HPPort4) != nil {
			portMod[3] = MOD()
			portMod[3]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort4)!)
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
		calculatorMod.readModFromFile(filename)
	}
	
	func installBuiltinRoms() {
		println("installBuiltinRoms")
		if calculatorMod.data? != nil {
			// Install ROMs which came with the calculator module
			println("reading module...")
			var modFile: ModuleFile = calculatorMod.module()
			for idx: UInt8 in 0..<modFile.header.numPages {
				println("installing page \(idx)")
				var page: ModuleFilePage = calculatorMod.moduleFile.pages[Int(idx)]
				var romChip = RomChip(fromBIN: page.image)
				bus!.installRomChip(romChip, inSlot: page.page, andBank: page.bank-1)
			}
		}
	}
	
	func installBuiltinRam() {
		println("installBuiltinRam")
		var address: Bits12
		for idx in 0..<builtinRamTable.count {
			var ramDesc = builtinRamTable[idx]
			if let cType :CalculatorType = calculatorType? {
				let condition1: Bool = ramDesc.inC && (cType == .HP41C)
				let condition2: Bool = ramDesc.inCV && (cType == .HP41CV)
				let condition3: Bool = ramDesc.inCX && (cType == .HP41CX)
				let condition4: Bool = ramDesc.memModule1 && (calculatorMod.module().header.memModules >= 1)
				let condition5: Bool = ramDesc.memModule2 && (calculatorMod.module().header.memModules >= 2)
				let condition6: Bool = ramDesc.memModule3 && (calculatorMod.module().header.memModules >= 3)
				let condition7: Bool = ramDesc.memModule4 && (calculatorMod.module().header.memModules >= 4)
				let condition8: Bool = ramDesc.quad && (calculatorMod.module().header.memModules == 4)
				let condition9: Bool = ramDesc.xMem && (calculatorMod.module().header.XMemModules == 1)
				let conditionA: Bool = ramDesc.xFunction && (calculatorMod.module().header.XMemModules >= 2)
				if condition1 || condition2 || condition3 || condition4 || condition5 || condition6 || condition7 || condition8 || condition9 || conditionA {
					for address in ramDesc.firstAddress...ramDesc.lastAddress {
						bus!.installRamAtAddress(address)
					}
				}
			}
		}
	}
	
	func saveMemory() {
		println("saveMemory")
		let data = getMemoryContents()
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(data, forKey: "memory")
		defaults.synchronize()
	}
	
	func restoreMemory() {
		println("restoreMemory")
		let data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey("memory") as? NSData
		if let aData = data {
			self.setMemoryContents(aData)
		}
	}
	
	func digits14FromArray(array: [Digit], position: Int, inout to: Digits14) {
		for idx in 0...13 {
			to[idx] = array[position + idx]
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
			println(tmpReg)
			bus!.writeRamAddress(Bits12(addr), from: tmpReg)
			ptr += 14
		}
	}
	
	func getMemoryContents() -> NSData {
		var data: NSMutableData = NSMutableData()
		let count = 14 * MAX_RAM_SIZE
		var memoryArray = [UInt8](count: count, repeatedValue: 0)
		var ptr = 0
		for addr in 0..<MAX_RAM_SIZE {
			var tmpReg = emptyDigit14
			bus!.readRamAddress(Bits12(addr), into: &tmpReg)
			for idx in 0...13 {
				memoryArray[ptr+idx] = tmpReg[idx]
			}
			ptr += 14
		}
		data.appendBytes(memoryArray, length: count)
		
		return data
	}
	
	func startExecutionTimer() {
		cpu.setPowerMode(.PowerOn)
		executionTimer = NSTimer.scheduledTimerWithTimeInterval(timeSliceInterval, target: self, selector: Selector("timeSlice:"), userInfo: nil, repeats: true)
	}
	
	func timeSlice(timer: NSTimer) {
		cpu.timeSlice(timer)
		display?.timeSlice(timer)
		timerModule?.timeSlice(timer)
	}
}