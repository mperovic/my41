//
//  Bus.swift
//  i41CV
//
//  Created by Miroslav Perovic on 8/9/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation


protocol Peripheral {
	func pluggedIntoBus(bus: Bus)
	func readFromRegister(register: Bits4, into: Digits14) -> Digits14
	func writeToRegister(register: Bits4, var from data: Digits14) -> (data: Digits14, registers: DisplayRegisters?)
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
	RamDesc(firstAddress: 0x0000, lastAddress: 0x000F, inC: true, inCV: true, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: false, quad: false, xMem: false, xFunction: false),		// Base memory of all calculators
	//0x0010 - 0x0030 nonexistent
	RamDesc(firstAddress: 0x0040, lastAddress: 0x00BF, inC: false, inCV: false, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: false, quad: false, xMem: false, xFunction: true),		// X-func, X-mem
	RamDesc(firstAddress: 0x00C0, lastAddress: 0x00FF, inC: true, inCV: true, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: false, quad: false, xMem: false, xFunction: false),		// 41C, CV CX Main memory
	RamDesc(firstAddress: 0x0100, lastAddress: 0x013F, inC: false, inCV: true, inCX: true, memModule1: true, memModule2: false, memModule3: false, memModule4: false, quad: true, xMem: false, xFunction: false),		// CV, CX Mem module 1
	RamDesc(firstAddress: 0x0140, lastAddress: 0x017F, inC: false, inCV: true, inCX: true, memModule1: false, memModule2: true, memModule3: false, memModule4: false, quad: true, xMem: false, xFunction: false),		// CV, CX Mem module 2
	RamDesc(firstAddress: 0x0180, lastAddress: 0x01BF, inC: false, inCV: true, inCX: true, memModule1: false, memModule2: false, memModule3: true, memModule4: false, quad: true, xMem: false, xFunction: false),		// CV, CX Mem module 3
	RamDesc(firstAddress: 0x01C0, lastAddress: 0x01FF, inC: false, inCV: true, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: true, quad: true, xMem: false, xFunction: false),		// CV, CX Mem module 4
	// Hole at 0x200
	RamDesc(firstAddress: 0x0201, lastAddress: 0x02EF, inC: false, inCV: false, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: false, quad: false, xMem: true, xFunction: false),		// Extended memory 1
	// 0x02f0 nonexistent
	RamDesc(firstAddress: 0x0301, lastAddress: 0x03EF, inC: false, inCV: false, inCX: true, memModule1: false, memModule2: false, memModule3: false, memModule4: false, quad: false, xMem: true, xFunction: false)		// Extended memory 2
	//0x03f nonexistent
]


class Bus {
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
	
	struct Static {
		static var token : dispatch_once_t = 0
		static var instance : Bus?
	}
	
	class var instance: Bus {
	dispatch_once(&Static.token) {  Static.instance = Bus() }
		return Static.instance!
	}

	init () {
		assert(Static.instance == nil, "Singleton already initialized!")

		// 16 pages of 8 banks
		for _ in 0..<0x10 {
			romChips.append(Array(count:8, repeatedValue:RomChip()))
		}
		ramValid = [Bool](count:0x400, repeatedValue:false)
		ram = [Digits14](count:0x400, repeatedValue:emptyDigit14)
	}
	
	func installRomChip(chip: RomChip, inSlot slot: byte, andBank bank: byte) {
		romChips[Int(slot)][Int(bank)] = chip
	}
	
	func a(address: Bits12) {
		ramValid[Int(address)] = true
	}
	
	func installRamAtAddress(address: Bits12) {
		ramValid[Int(address)] = true
	}
	
	func readRamAddress(address: Bits12, var data: Digits14) -> (success:Bool, data: Digits14) {
		// Read specified location of specified chip. If chip or location is
		// nonexistent, set data to 0 and return false.
		if ramValid[Int(address)] {
			data = copyDigits(ram[Int(address)], sourceStartAt: 0, destination: data, destinationStartAt: 0, count: 14)
			return (true, data)
		} else {
			return (false, emptyDigit14)
		}
	}
	
	func removeAllRomChips() {
		for page in 0..<16 {
			for bank in 0..<8 {
				romChips[page][bank] = nil
			}
			
		}
	}
	
	func readRomLocation(addr: Int) -> (success: Bool, data: Int) {
		// Read ROM location at the given address and return true.
		// If there is no ROM at that address, sets data to 0 and returns false.
		var address = addr
		address = address & 0xffff;
		let page = Int(address >> 12)
		let bank = Int(activeRomBank[address >> 12])
		var rom: RomChip? = romChips[page][bank]
		var data: Int
		if let aRom = rom {
			return (true, Int(aRom.readLocation(address & 0xfff)))
		} else {
			return (false, 0)
		}
	}
	
	func writeRamAddress(address: Bits12, from data: Digits14) -> Bool {
		// Write to specified location of specified chip. If chip or location is nonexistent, do nothing and return false.
		if ramValid[Int(address)] {
			ram[Int(address)] = copyDigits(data, sourceStartAt: 0, destination: ram[Int(address)], destinationStartAt: 0, count: 14)
			return true
		} else {
			return false
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
	
	func writeToRegister(register: Bits4, ofPeripheral slot: Bits8, from data: Digits14) {
		if let peripheral = peripherals[Int(slot)] {
			peripheral.writeToRegister(register, from: data)
		}
	}
	
	func writeDataToPeripheral(slot aSlot: Bits8, from data: Digits14) {
		var peripheral: Peripheral = peripherals[Int(aSlot)]!
		peripheral.writeDataFrom(data)
	}
	
	func readFromRegister(register reg: Bits4, ofPeripheral slot: Bits8) -> Digits14 {
		var result: Digits14 = emptyDigit14
		if let periph = peripherals[Int(slot)]? {
			result = periph.readFromRegister(reg, into: result)
		}
		
		return result
	}
	
	func installPeripheral(peripheral: Peripheral, inSlot slot: Bits8) {
		peripherals[Int(slot)] = peripheral
		peripheral.pluggedIntoBus(self)
	}
	
	func abortInstruction(message: String) {
		cpu!.abortInstruction(message)
	}
	
	
	/*
	- (void) readFromRegister:(Bits_4)reg ofPeripheral:(Bits_8)slot into:(Digits_14)data
	{
	id <Peripheral> periph = peripherals[slot];
	if (periph)
	[periph readFromRegister:reg into:data];
	else
	clearDigits(data);
	}
	*/
}