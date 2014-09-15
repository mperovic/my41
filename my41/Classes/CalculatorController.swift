//
//  CalculatorController.swift
//  i41CV
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

var cpu: CPU?
var bus: Bus?
var timer: Timer?

class CalculatorController : NSObject {
	@IBOutlet weak var display: Display!

	var calculatorMod: MOD = MOD()
	var portMod: [MOD?] = [nil, nil, nil, nil]
	var calculatorType: CalculatorType?
	var executionTimer: NSTimer?

	override init() {
		cpu = CPU()
		bus = Bus()
		timer = Timer()
		calculatorMod = MOD()
		
		super.init()
		
		resetCalculator()
	}
	
	override func awakeFromNib() {
//		let x: Bool = self.calculatorWindow.excludedFromWindowsMenu
	}
	
	func resetCalculator() {
		cpu!.setRunning(false)
		bus!.removeAllRomChips()
		readCalculatorDescriptionFromDefaults()
		installBuiltinRoms()
		installBuiltinRam()
		restoreMemory()
		cpu!.reset()
		cpu!.setRunning(true)
		startExecutionTimer()
	}
	
	func readCalculatorDescriptionFromDefaults() {
		println("readCalculatorDescriptionFromDefaults")
		let defaults = NSUserDefaults.standardUserDefaults()
		var filename: String
		let cType = defaults.integerForKey(HPCalculatorType)
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
			defaults.setInteger(CalculatorType.HP41CX.toRaw(), forKey: HPCalculatorType)
			filename = NSBundle.mainBundle().resourcePath! + "/" + "nut-cx.mod"
		}
		calculatorMod.readModFromFile(filename)
		
		// Now we fill each port
		portMod[0]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort1)!)
		portMod[1]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort2)!)
		portMod[2]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort3)!)
		portMod[3]?.readModFromFile(NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort4)!)
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
		for var idx = 0; idx < builtinRamTable.count; idx++ {
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
					for address = ramDesc.firstAddress; address <= ramDesc.lastAddress; address++ {
						bus!.installRamAtAddress(address)
					}
				}
			}
		}
	}
	
	func saveMemory() {
		println("restoreMemory")
		let data = getMemoryContents()
		NSUserDefaults.standardUserDefaults().setObject(data, forKey: "memory")
	}
	
	func restoreMemory() {
		println("restoreMemory")
		let data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey("memory") as? NSData
		if let aData: NSData = data {
			self.setMemoryContents(aData)
		}
	}
	
	func digits14FromArray(array: [Digit], position: Int) -> Digits14 {
		var d14: Digits14 = emptyDigit14
		for idx in 0..<14 {
			d14[idx] = array[position + idx]
		}
		
		return d14
	}

	func setMemoryContents(data: NSData) {
		// the number of elements:
		let count = data.length / sizeof(UInt8)
		
		// create array of appropriate length:
		var memoryArray = [UInt8](count: count, repeatedValue: 0)

		// copy bytes into array
		data.getBytes(&memoryArray, length:count * sizeof(UInt8))

		var ptr: Int = 0
		for addr in 0..<MAX_RAM_SIZE {
			var d14: Digits14 = digits14FromArray(memoryArray, position: ptr)
			bus!.writeRamAddress(Bits12(addr), from: d14)
			ptr += 14
		}
	}
	
	func getMemoryContents() -> NSData {
		//TODO: Implement this method
		var data: NSMutableData = NSMutableData()
//		for addr in 0..<MAX_RAM_SIZE {
//			let result = bus!.readRamAddress(Bits12(addr))
//			if result.success {
//				for idx in 0...13 {
//					data.appendBytes(result.data, length: 14)
//				}
//			}
//		}
		
		return data
	}
	
	func startExecutionTimer() {
		cpu!.setPowerMode(.powerOn)
		executionTimer = NSTimer.scheduledTimerWithTimeInterval(timeSliceInterval, target: self, selector: Selector("timeSlice:"), userInfo: nil, repeats: true)
	}
	
	func timeSlice(timer: NSTimer) {
		cpu!.timeSlice(timer)
		//TODO: IMPLEMENT
		display.timeSlice(timer)
//		[timeModule timeSlice: timer];
	}
}