//
//  Bus.swift
//  my41
//
//  Created by Miroslav Perovic on 8/9/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

protocol Peripheral {
	func pluggedIntoBus(_ bus: Bus?)
	func readFromRegister(_ param: Bits4)
	func writeToRegister(_ param: Bits4)
	func writeDataFrom(_ data: Digits14)
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

//let calculatorController = CalculatorController.sharedInstance

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
		inCX: false,
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
		inCX: false,
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

enum RamError: Error {
	case invalidAddress
}

enum RomError: Error {
	case invalidAddress
}

enum MODError: Error {
	case freeSpace
}


final class Bus {
	// Section defining what type of memory we have
	var memoryModule1: Bool?
	var memoryModule2: Bool?
	var memoryModule3: Bool?
	var memoryModule4: Bool?
	var quadMemory: Bool?
	var xMemory: Bool?
	var xFunction: Bool?
	var ram = [Digits14](repeating: Digits14(), count: MAX_RAM_SIZE)
	var peripherals: [Peripheral?] = [Peripheral?](repeating: nil, count: 0x100)
	
	// Peripherals
	var display: Display?
	var timer: Timer?
	
	var memModules: byte = 0
	var XMemModules: byte = 0
	
	// ROM variables
	var romChips = Array<Array<RomChip?>>()
	var nextActualBankGroup: byte = 1										// counter for loading actual bank groups
	var activeBank: [Int] = [Int](repeating: 1, count: 0x10)
	
	static let sharedInstance = Bus()

	init () {
		// 16 pages of 4 banks
		for page in 0...0xf {
			romChips.append(Array(repeating: RomChip(), count: 4))
			for bank in 1...4 {
				romChips[page][bank - 1] = nil
			}
		}
		ram = [Digits14](repeating: Digits14(), count: MAX_RAM_SIZE)
	}
	
	func installMod(_ mod: MOD) throws {
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
				let modulePage = mod.modulePages[Int(pageIndex)]
				var load = false
				switch pass {
				case 1:
					// pass 1: validate page variables, flag grouped pages
					do {
						try mod.checkPage(modulePage)
					} catch CheckPageError.pageOutOfRange {
						displayAlert("page: \(modulePage) is out of range")
					} catch CheckPageError.pageGroupOutOfRange {
						displayAlert("group pages cannot use non-grouped position codes")
					} catch CheckPageError.bankOutOfRange {
						displayAlert("bank: \(modulePage.bank) is out of range")
					} catch CheckPageError.bankGroupOutOfRange {
						displayAlert("bank group: \(modulePage.bankGroup) is out of range")
					} catch CheckPageError.ramOutOfRange {
						displayAlert("ram: \(modulePage.RAM) is out of range")
					} catch CheckPageError.writeProtect {
						displayAlert("wrong write protect value")
					} catch CheckPageError.fatOutOfRange {
						displayAlert("FAT: \(modulePage.FAT) is out of range")
					} catch CheckPageError.nonGroupedPagesError {
						displayAlert("non-grouped pages cannot use grouped position codes")
					} catch {
						
					}
					
					if modulePage.pageGroup == 0 {
						// if not grouped do nothing in this pass
						break
					}
					
					// save the count of pages with each attribute as a negative number
					if modulePage.page == Position.positionLower.rawValue {
						lowerGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.positionUpper.rawValue {
						upperGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.positionOdd.rawValue {
						oddGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.positionEven.rawValue {
						evenGroup[Int(modulePage.pageGroup) - 1] -= 1
					} else if modulePage.page == Position.positionOrdered.rawValue {
						orderedGroup[Int(modulePage.pageGroup) - 1] -= 1
					}
					
				case 2:
					// pass 2: find free location for grouped pages
					if modulePage.pageGroup == 0 {
						// if not grouped do nothing in this pass
						break
					}
					
					// a matching page has already been loaded
					if modulePage.page == Position.positionLower.rawValue && upperGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is the lower page and the upper page has already been loaded
						page = byte(upperGroup[Int(modulePage.pageGroup - 1)] - 1)
					} else if modulePage.page == Position.positionLower.rawValue && lowerGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is another lower page
						page = byte(lowerGroup[Int(modulePage.pageGroup - 1)])
					} else if modulePage.page == Position.positionUpper.rawValue && lowerGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is the upper page and the lower page has already been loaded
						page = byte(lowerGroup[Int(modulePage.pageGroup - 1)] + 1)
					} else if modulePage.page == Position.positionUpper.rawValue && upperGroup[Int(modulePage.pageGroup) - 1] > 0 {
						// this is another upper page
						page = byte(upperGroup[Int(modulePage.pageGroup - 1)])
					} else if modulePage.page == Position.positionOdd.rawValue && evenGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(evenGroup[Int(modulePage.pageGroup - 1)] + 1)
					} else if modulePage.page == Position.positionOdd.rawValue && oddGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(oddGroup[Int(modulePage.pageGroup) - 1])
					} else if modulePage.page == Position.positionEven.rawValue && oddGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(oddGroup[Int(modulePage.pageGroup) - 1] - 1)
					} else if modulePage.page == Position.positionEven.rawValue && evenGroup[Int(modulePage.pageGroup) - 1] > 0 {
						page = byte(evenGroup[Int(modulePage.pageGroup) - 1])
					} else if modulePage.page == Position.positionOrdered.rawValue && orderedGroup[Int(modulePage.pageGroup) - 1] > 0 {
//						page = byte(++orderedGroup[Int(modulePage.pageGroup) - 1])
						page = byte(1 + orderedGroup[Int(modulePage.pageGroup) - 1])
					} else {
						// find first page in group
						// find free space depending on which combination of positions are specified
						if lowerGroup[Int(modulePage.pageGroup) - 1] != 0 && upperGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// lower and upper
							page = 8
							while (page <= 0xe && (romChips[Int(page)][Int(modulePage.bank) - 1] != nil || romChips[Int(page) + 1][Int(modulePage.bank) - 1] != nil)) {
								page += 1
							}
						} else if lowerGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// lower but no upper
							page = 8
							while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page += 1
							}
						} else if upperGroup[Int(modulePage.pageGroup) - 1] != 0 {
							// upper but no lower
							page = 8
							while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
								page += 1
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
								for _ in page..<0x0f {
									// count up free spaces
									if romChips[Int(page)][Int(modulePage.bank) - 1] == nil {
										nFree += 1
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
								page += 1
							}
						}
						
						// save the position that was found in the appropriate array
						if modulePage.page == Position.positionLower.rawValue {
							lowerGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.positionUpper.rawValue {
							// found two positions - take the upper one
							page += 1
							upperGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.positionEven.rawValue {
							evenGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.positionOdd.rawValue {
							oddGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						} else if modulePage.page == Position.positionOrdered.rawValue {
							orderedGroup[Int(modulePage.pageGroup) - 1] = Int8(page)
						}
					}
					load = true
					
				case 3:
					// pass 3 - find location for non-grouped pages
					if Int(modulePage.pageGroup) == 1 {
						break
					}
					
					if modulePage.page == Position.positionAny.rawValue {
						// a single page that can be loaded anywhere 8-F
						page = 8
						while (page <= 0xf && romChips[Int(page)][Int(modulePage.bank) - 1] != nil) {
							page += 1
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
					if mod.moduleHeader.hardware == Hardware.hepax {
						modulePage.HEPAX = 1
					}
					if mod.moduleHeader.hardware == Hardware.wwramBox {
						modulePage.WWRAMBOX = 1
					}
					if modulePage.bankGroup != 0 {
						// ensures each bank group has a number that is unique to the entire simulator
						modulePage.actualBankGroup = modulePage.bankGroup + nextActualBankGroup * 8
					} else {
						modulePage.actualBankGroup = 0
					}
					// HEPAX special case
					if hepPage != 0 && modulePage.HEPAX == 1 && modulePage.RAM == 1 {
						// hepax was just loaded previously and this is the first RAM page after it
						modulePage.actualPage = hepPage
						let romChip = romChipInSlot(Bits4(hepPage), bank: Bits4(modulePage.bank))
						// load this RAM into alternate page
						romChip?.altPage = modulePage
					} else if wwPage != 0 && modulePage.WWRAMBOX != 0 && modulePage.RAM != 0 {
						// W&W code was just loaded previously and this is the first RAM page after it
						modulePage.actualPage = wwPage
						let romChip = romChipInSlot(Bits4(wwPage), bank: Bits4(modulePage.bank))
						// load this RAM into alternate page
						romChip?.altPage = modulePage
					} else if page > 0xf || romChips[Int(page)][Int(modulePage.bank) - 1] != nil {
						// there is no free space or some load conflict exists
						throw MODError.freeSpace
					} else {
						// otherwise load into primary page
						let romChip = RomChip(fromBIN: modulePage.image, actualBankGroup: modulePage.actualBankGroup)
						romChip.HEPAX = modulePage.HEPAX
						romChip.WWRAMBOX = modulePage.WWRAMBOX
						romChip.RAM = modulePage.RAM
						installRomChip(romChip, inSlot: page, andBank: modulePage.bank-1)
					}
					
					hepPage = 0
					wwPage = 0
					if modulePage.HEPAX == 1 && modulePage.RAM == 0 {
						// detect HEPAX ROM
						hepPage = page
					}
					if modulePage.HEPAX == 1 && modulePage.RAM == 0 {
						// detect W&W RAMBOXII ROM
						wwPage = page
					}
				}
			}
		}
		nextActualBankGroup += 1
	}
	
	func installRomChip(_ chip: RomChip, inSlot slot: byte, andBank bank: byte) {
		romChips[Int(slot)][Int(bank)] = chip
	}

	func readRamAddress(_ address: Bits12) throws -> Digits14 {
		/*
			Read specified location of specified chip.
			If chip or location is nonexistent, set data to 0 and return false.
		*/
		if RAMExists(Int(address)) {
			return ram[Int(address)]
		} else {
			throw RamError.invalidAddress
		}
	}
	
	func writeRamAddress(_ address: Bits12, from data: Digits14) throws {
		// Write to specified location of specified chip. If chip or location is nonexistent, do nothing and return false.
		if RAMExists(Int(address)) {
			ram[Int(address)] = data
		} else {
			throw RamError.invalidAddress
		}
	}
	
	func removeAllRomChips() {
		for page in 0...0xf {
			for bank in 1...4 {
				self.romChips[page][bank - 1] = nil
			}
			
		}
	}
	
	func readRomAddress(_ addr: Int) throws -> Int {
		// Read ROM location at the given address and return true.
		// If there is no ROM at that address, sets data to 0 and returns
		let address = addr & 0xffff
		let page = Int(address >> 12)
		let bank = Int(activeBank[page])
		let rom: RomChip? = romChips[page][bank - 1]
		if let aRom = rom {
			return Int(aRom[Int(address & 0xfff)])
		} else {
			throw RomError.invalidAddress
		}
	}

	func romChipInSlot(_ slot: Bits4, bank: Bits4) -> RomChip? {
		return romChips[Int(slot)][Int(bank) - 1]
	}

	func romChipInSlot(_ slot: Bits4) -> RomChip? {
		let bank = activeBank[Int(slot)]
		
		return romChips[Int(slot)][Int(bank) - 1]
	}
	
	func activeBankAtAddr(_ addr: Bits16) -> Bits4 {
		let slot = addr >> 12
		return Bits4(activeBank[Int(slot)])
	}
	
	func activeBankInSlot(_ slot: Bits4) -> Int {
		return activeBank[Int(slot)]
	}
	
	func setActiveBankInSlot(_ slot: Bits4, bank: Int) {
		activeBank[Int(slot)] = bank
	}
	
	func writeToRegister(_ register: Bits4, ofPeripheral slot: Bits8) {
		if let peripheral = peripherals[Int(slot)] {
			peripheral.writeToRegister(register)
		}
	}
	
	func writeDataToPeripheral(slot aSlot: Bits8, from data: Digits14) {
		if let peripheral: Peripheral = peripherals[Int(aSlot)] {
			peripheral.writeDataFrom(data)
		}
	}
	
	func readFromRegister(register reg: Bits4, ofPeripheral slot: Bits8) {
		if let periph = peripherals[Int(slot)] {
			periph.readFromRegister(reg)
		}
	}
	
	func installPeripheral(_ peripheral: Peripheral, inSlot slot: Bits8) {
		if let oldPeripheral = peripherals[Int(slot)] {
			oldPeripheral.pluggedIntoBus(nil)
		}
		peripherals[Int(slot)] = peripheral
		peripheral.pluggedIntoBus(self)
	}
	
	func abortInstruction(_ message: String) {
		cpu.abortInstruction(message)
	}
	
	func checkAddress(_ address: Bits12, calculatorModHeader: ModuleFileHeader) -> Bool {
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
	
	func RAMExists(_ address: Int) -> Bool {
		if address >= 0x000 && address <= 0x00f	{			// status registers
			return true
		}
		if address >= 0x010 && address <= 0x03f	{			// void
			return false
		}
		if address >= 0x040 && address <= 0x0bf {			// extended functions - 128 regs
			return self.XMemModules >= 1
		}
		if address >= 0x0c0 && address <= 0x0ff {			// main memory for C
			return true
		}
		if address >= 0x100 && address <= 0x13f {			// memory module 1
			return self.memModules >= 1
		}
		if address >= 0x140 && address <= 0x17f {			// memory module 2
			return self.memModules >= 2
		}
		if address >= 0x180 && address <= 0x1bf {			// memory module 3
			return self.memModules >= 3
		}
		if address >= 0x1c0 && address <= 0x1ff {			// memory module 4
			return self.memModules >= 4
		}
		// void: 200
		if address >= 0x201 && address <= 0x2ef {			// extended memory 1 - 239 regs
			return self.XMemModules >= 2
		}
		// void: 2f0-300
		if address >= 0x301 && address <= 0x3ef {			// extended memory 2 - 239 regs
			return self.XMemModules >= 3
		}
		// void: 3f0-3ff
		// end of memory: 3ff
		
		return false
	}
}
