//
//  Bus.swift
//  my41
//
//  Created by Miroslav Perovic on 8/9/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

protocol Peripheral {
	func pluggedIntoBus(bus: Bus?)
	func readFromRegister(register: Bits4, inout into: Digits14)
	func writeToRegister(register: Bits4, inout from data: Digits14)
	func writeDataFrom(data: Digits14)
}

struct RomDesc {
	var name: String
	var slot: byte
	var bank: byte
}

struct RamDesc {
	var firstAddress: Bits12
	var lastAddress: Bits12
	var inC: Bool
	var inCV: Bool
	var inCX: Bool
	var memModule1: Bool
	var memModule2: Bool
	var memModule3: Bool
	var memModule4: Bool
	var quad: Bool
	var xMem: Bool
	var xFunction: Bool
}

var builtinRomTable: [RomDesc] = [
	RomDesc(name: "XNUT0",   slot: 0, bank: 0),
	RomDesc(name: "XNUT1",   slot: 1, bank: 0),
	RomDesc(name: "XNUT2",   slot: 2, bank: 0),
	RomDesc(name: "CXFUNS0", slot: 2, bank: 0),
	RomDesc(name: "CXFUNS1", slot: 5, bank: 1),
	RomDesc(name: "TIMER",   slot: 5, bank: 0)
]

var builtinRamTable: [RamDesc] = [
	RamDesc(
		firstAddress: 0x0000,
		lastAddress: 0x000F,
		inC: true,
		inCV: true,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: false,
		xMem: false,
		xFunction: false
	),									// Base memory of all calculators
	//0x0010 - 0x0030 nonexistent
	RamDesc(
		firstAddress: 0x0040,
		lastAddress: 0x00BF,
		inC: false,
		inCV: false,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: false,
		xMem: false,
		xFunction: true
	),									// X-func, X-mem
	RamDesc(
		firstAddress: 0x00C0,
		lastAddress: 0x00FF,
		inC: true,
		inCV: true,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: false,
		xMem: false,
		xFunction: false
	),									// 41C, CV CX Main memory
	RamDesc(
		firstAddress: 0x0100,
		lastAddress: 0x013F,
		inC: false,
		inCV: true,
		inCX: true,
		memModule1: true,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: true,
		xMem: false,
		xFunction: false
	),									// CV, CX Mem module 1
	RamDesc(
		firstAddress: 0x0140,
		lastAddress: 0x017F,
		inC: false,
		inCV: true,
		inCX: true,
		memModule1: false,
		memModule2: true,
		memModule3: false,
		memModule4: false,
		quad: true,
		xMem: false,
		xFunction: false
	),									// CV, CX Mem module 2
	RamDesc(
		firstAddress: 0x0180,
		lastAddress: 0x01BF,
		inC: false,
		inCV: true,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: true,
		memModule4: false,
		quad: true,
		xMem: false,
		xFunction: false
	),									// CV, CX Mem module 3
	RamDesc(
		firstAddress: 0x01C0,
		lastAddress: 0x01FF,
		inC: false,
		inCV: true,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: true,
		quad: true,
		xMem: false,
		xFunction: false
	),									// CV, CX Mem module 4
	// Hole at 0x200
	RamDesc(
		firstAddress: 0x0201,
		lastAddress: 0x02EF,
		inC: false,
		inCV: false,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: false,
		xMem: true,
		xFunction: false
	),									// Extended memory 1
	// 0x02f0 nonexistent
	RamDesc(
		firstAddress: 0x0301,
		lastAddress: 0x03EF,
		inC: false,
		inCV: false,
		inCX: true,
		memModule1: false,
		memModule2: false,
		memModule3: false,
		memModule4: false,
		quad: false,
		xMem: true,
		xFunction: false
	)									// Extended memory 2
	//0x03f nonexistent
]


final class Bus {
	// Section defining what type of memory we have
	var memoryModule1: Bool?
	var memoryModule2: Bool?
	var memoryModule3: Bool?
	var memoryModule4: Bool?
	var quadMemory: Bool?
	var xMemory: Bool?
	var xFunction: Bool?
	var ramValid: [Bool]
	var ram: [Digits14]
	var activeRomBank: [Bits4] = [Bits4](count: 0x10, repeatedValue: 0)
	var peripherals: [Peripheral?] = [Peripheral?](count: 0x100, repeatedValue:nil)
	
	var romChips = Array<Array<RomChip?>>()
	
	class var sharedInstance : Bus {
		struct Singleton {
			static let instance = Bus()
		}
		
		return Singleton.instance
	}

	init () {
		// 16 pages of 8 banks
		for _ in 0..<0x10 {
			romChips.append(Array(count:8, repeatedValue:RomChip()))
		}
		ramValid = [Bool](count:0x400, repeatedValue:false)
		ram = [Digits14](count:0x400, repeatedValue:emptyDigit14)
	}
	
	func installMod(mod: MOD) -> Result<Bool> {
		/*
			these are arrays indexed on the page group number (1-8) (unique only within each mod file)
			dual use: values are either a count stored as a negative number or a (positive) page number 1-f
		*/
		var lowerGroup: [Int8]   = [0, 0, 0, 0, 0, 0, 0, 0]				// <0, or =page # if lower page(s) go in group
		var upperGroup: [Int8]   = [0, 0, 0, 0, 0, 0, 0, 0]				// <0, or =page # if upper page(s) go in group
		var oddGroup: [Int8]     = [0, 0, 0, 0, 0, 0, 0, 0]				// <0, or =page # if odd page(s) go in group
		var evenGroup: [Int8]    = [0, 0, 0, 0, 0, 0, 0, 0]				// <0, or =page # if even page(s) go in group
		var orderedGroup: [Int8] = [0, 0, 0, 0, 0, 0, 0, 0]				// <0, or =page # if ordered page(s) go in group
		
		var page: byte = 0
		var hepPage: byte = 0
		var wwPage: byte = 0
		
		// load ROM pages with three pass process
		for pass in 1...3 {
			for pageIndex in 0..<mod.moduleHeader.numPages {
				var modulePage = mod.modulePages[Int(pageIndex)]
				var load = false
				switch pass {
				case 1:
					// pass 1: validate page variables, flag grouped pages
					switch mod.checkPage(modulePage) {
					case .Success:
						break
					case .Error(let error): error
						var alert:NSAlert = NSAlert()
						alert.messageText = error
						alert.runModal()
					
						return .Error(error)
					}

					if modulePage.pageGroup == 0 {
						// if not grouped do nothing in this pass
						break
					}
					
					// save the count of pages with each attribute as a negative number
					if modulePage.page == Position.PositionLower.rawValue {
						lowerGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.PositionUpper.rawValue {
						upperGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.PositionOdd.rawValue {
						oddGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.PositionEven.rawValue {
						evenGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.PositionOrdered.rawValue {
						orderedGroup[Int(modulePage.pageGroup) - 1] -= 1
					}
					
				case 2:
					// pass 2: find free location for grouped pages
					if modulePage.pageGroup == 0 {
						// if not grouped do nothing in this pass
						break
					}
					
					// a matching page has already been loaded
					if modulePage.page == Position.PositionLower.rawValue && upperGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is the lower page and the upper page has already been loaded
						page = byte(upperGroup[modulePage.pageGroup - 1] - 1)
					} else if modulePage.page == Position.PositionLower.rawValue && lowerGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is another lower page
						page = byte(lowerGroup[modulePage.pageGroup - 1])
					} else if modulePage.page == Position.PositionUpper.rawValue && lowerGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is the upper page and the lower page has already been loaded
						page = byte(lowerGroup[modulePage.pageGroup - 1] + 1)
					} else if modulePage.page == Position.PositionUpper.rawValue && upperGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is another upper page
						page = byte(upperGroup[modulePage.pageGroup - 1])
					} else if modulePage.page == Position.PositionOdd.rawValue && evenGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(evenGroup[modulePage.pageGroup - 1] + 1)
					} else if modulePage.page == Position.PositionOdd.rawValue && oddGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(oddGroup[Int(modulePage.pageGroup) - 1])
					} else if modulePage.page == Position.PositionEven.rawValue && oddGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(oddGroup[Int(modulePage.pageGroup) - 1] - 1)
					} else if modulePage.page == Position.PositionEven.rawValue && evenGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(evenGroup[Int(modulePage.pageGroup) - 1])
					} else if modulePage.page == Position.PositionOrdered.rawValue && orderedGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(++orderedGroup[Int(modulePage.pageGroup) - 1])
					} else {
						// find first page in group
						// find free space depending on which combination of positions are specified
						if lowerGroup[Int(modulePage.pageGroup) - 1] != 0 && upperGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// lower and upper
							page = 8
							while (page <= 0xe && (romChips[Int(page)][Int(modulePage.bank) - 1] != nil || romChips[Int(page) + 1][Int(modulePage.bank) - 1] != nil)) {
								page++
							}
						} else if lowerGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// lower but no upper
							page = 8
							while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page++
							}
						} else if upperGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// upper but no lower
							page = 8
							while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page++
							}
						} else if evenGroup[Int(modulePage.pageGroup) - 1] != 0 && oddGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// even and odd
							page = 8
							while (page <= 0xe && (romChips[Int(page)][Int(modulePage.bank) - 1] != nil || romChips[Int(page) + 1][Int(modulePage.bank) - 1] != nil)) {
								page += 2
							}
						} else if evenGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// even only
							page = 8
							while (page <= 0xe && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page += 2
							}
						} else if oddGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// odd only
							page = 9
							while (page <= 0xe && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page += 2
							}
						} else if orderedGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// a block
							let count: Int8 = -1 * orderedGroup[Int(modulePage.pageGroup) - 1]
							for page in 8..<0x10-count {
								var nFree: Int8 = 0
								for page2 in page..<0x0f {
									// count up free spaces
									if romChips[Int(page)][Int(modulePage.bank) - 1] == nil {
										nFree++
									} else {
										break
									}
								}
								if count <= nFree {
									// found a space
									break
								}
							}
						} else {
							page = 8
							while page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil {
								page++
							}
						}
						
						// save the position that was found in the appropriate array
						if modulePage.page == Position.PositionLower.rawValue {
							lowerGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.PositionUpper.rawValue {
							// found two positions - take the upper one
							page++
							upperGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.PositionEven.rawValue {
							evenGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.PositionOdd.rawValue {
							oddGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.PositionOrdered.rawValue {
							orderedGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						}
					}
					load = true
					
				case 3:
					// pass 3 - find location for non-grouped pages
					if Int(modulePage.pageGroup) == 1 {
						break
					}
					
					if modulePage.page == Position.PositionAny.rawValue {
						// a single page that can be loaded anywhere 8-F
						page = 8
						while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
							page++
						}
					} else {
						// page number is hardcoded
						page = modulePage.page
					}
					load = true
					
				default:
					break
				}
				
				if load {
					// HEPAX special case
					if hepPage != 0 && mod.moduleHeader.hardware == Hardware.HEPAX && modulePage.RAM == 1 {
						// hepax was just loaded previously and this is the first RAM page after it
						modulePage.page = hepPage
						let romChip = romChipInSlot(Bits4(hepPage), bank: Bits4(modulePage.bank - 1))
						// load this RAM into alternate page
						romChip?.altPage = modulePage
					} else if wwPage != 0 && modulePage.WWRAMBOX != 0 && modulePage.RAM != 0 {
						// W&W code was just loaded previously and this is the first RAM page after it
						modulePage.actualPage = wwPage
						let romChip = romChipInSlot(Bits4(wwPage), bank: Bits4(modulePage.bank - 1))
						// load this RAM into alternate page
						romChip?.altPage = modulePage
					} else if page > 0xf || romChips[Int(page)][Int(modulePage.bank) - 1] != nil {
						// there is no free space or some load conflict exists
						return .Error("No free space")
					} else {
						// otherwise load into primary page
						let romChip = RomChip(fromBIN: modulePage.image)
						installRomChip(romChip, inSlot: page, andBank: modulePage.bank-1)
					}
				}
			}
		}
		
		return .Success(Box(true))
	}
	
	func installRomChip(chip: RomChip, inSlot slot: byte, andBank bank: byte) {
		romChips[Int(slot)][Int(bank)] = chip
	}
	
	func installRamAtAddress(address: Bits12) {
		ramValid[Int(address)] = true
	}
	
	func readRamAddress(address: Bits12, inout into data: Digits14) -> Result<Bool> {
		/*
			Read specified location of specified chip.
			If chip or location is nonexistent, set data to 0 and return false.
		*/
		if Int(address) > ramValid.count - 1 || !ramValid[Int(address)] {
			clearDigits(destination: &data)
			return .Error("readRamAddress: invalid address: \(address)")
		} else {
			copyDigits(
				ram[Int(address)],
				sourceStartAt: 0,
				destination: &data,
				destinationStartAt: 0,
				count: 14
			)
			return .Success(Box(true))
		}
	}
	
	func writeRamAddress(address: Bits12, from data: Digits14) -> Result<Bool> {
		// Write to specified location of specified chip. If chip or location is nonexistent, do nothing and return false.
		if Int(address) > ramValid.count - 1 || !ramValid[Int(address)] {
			return .Error("writeRamAddress: invalid address: \(address)")
		} else {
			copyDigits(data, sourceStartAt: 0, destination: &ram[Int(address)], destinationStartAt: 0, count: 14)
			return .Success(Box(true))
		}
	}
	
	func removeAllRomChips() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			for page in 0..<16 {
				for bank in 0..<8 {
					self.romChips[page][bank] = nil
				}
				
			}
		})
	}
	
	func readRomAddress(addr: Int) -> Result<Int> {
		// Read ROM location at the given address and return true.
		// If there is no ROM at that address, sets data to 0 and returns
		var address = addr
		address = address & 0xffff
		let page = Int(address >> 12)
		let bank = Int(activeRomBank[address >> 12])
		var rom: RomChip? = romChips[page][bank]
		if let aRom = rom {
			return .Success(Box(Int(aRom[Int(address & 0xfff)])))
		} else {
			return .Error("readRomAddress: invalid address: \(address)")
		}
	}

	func romChipInSlot(slot: Bits4, bank: Bits4) -> RomChip? {
		return romChips[Int(slot)][Int(bank)]
	}

	func romChipInSlot(slot: Bits4) -> RomChip? {
		let bank = activeRomBank[Int(slot)]
		
		return romChips[Int(slot)][Int(bank)]
	}
	
	func activeRomBankAtAddr(addr: Bits16) -> Bits4 {
		let slot = addr >> 12
		return Bits4(activeRomBank[Int(slot)])
	}
	
	func activeRomBankInSlot(slot: Bits4) -> Bits4 {
		return activeRomBank[Int(slot)]
	}
	
	func setActiveRomBankInSlot(slot: Bits4, bank: Bits4) {
		activeRomBank[Int(slot)] = bank
	}
	
	func writeToRegister(register: Bits4, ofPeripheral slot: Bits8, inout from data: Digits14) {
		if let peripheral = peripherals[Int(slot)] {
			peripheral.writeToRegister(register, from: &data)
		}
	}
	
	func writeDataToPeripheral(slot aSlot: Bits8, from data: Digits14) {
		var peripheral: Peripheral = peripherals[Int(aSlot)]!
		peripheral.writeDataFrom(data)
	}
	
	func readFromRegister(register reg: Bits4, ofPeripheral slot: Bits8, inout into data: Digits14) {
		if let periph = peripherals[Int(slot)]? {
			periph.readFromRegister(reg, into: &data)
		}
	}
	
	func installPeripheral(peripheral: Peripheral, inSlot slot: Bits8) {
		if let oldPeripheral = peripherals[Int(slot)] {
			oldPeripheral.pluggedIntoBus(nil)
		}
		peripherals[Int(slot)] = peripheral
		peripheral.pluggedIntoBus(self)
	}
	
	func abortInstruction(message: String) {
		CPU.sharedInstance.abortInstruction(message)
	}
	
	func checkAddress(address: Bits12, calculatorModHeader: ModuleFileHeader) -> Bool {
		if address >= 0x000 && address <= 0x00f	{			// status registers
			return true
		}
		if address >= 0x010 && address <= 0x03f	{			// void
			return false
		}
		if address >= 0x040 && address <= 0x0bf {			// extended functions - 128 regs
			return calculatorModHeader.XMemModules >= 1
		}
		if address >= 0x0c0 && address <= 0x0ff {			// main memory for C
			return true
		}
		if address >= 0x100 && address <= 0x13f {			// memory module 1
			return calculatorModHeader.memModules >= 1
		}
		if address >= 0x140 && address <= 0x17f {			// memory module 2
			return calculatorModHeader.memModules >= 2
		}
		if address >= 0x180 && address <= 0x1bf {			// memory module 3
			return calculatorModHeader.memModules >= 3
		}
		if address >= 0x1c0 && address <= 0x1ff {			// memory module 4
			return calculatorModHeader.memModules >= 4
		}
		// void: 200
		if address >= 0x201 && address <= 0x2ef {			// extended memory 1 - 239 regs
			return calculatorModHeader.XMemModules >= 2
		}
		// void: 2f0-300
		if address >= 0x301 && address <= 0x3ef {			// extended memory 2 - 239 regs
			return calculatorModHeader.XMemModules >= 3
		}
		// void: 3f0-3ff
		// end of memory: 3ff

		return false
	}
}