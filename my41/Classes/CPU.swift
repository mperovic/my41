//
//  CPU.swift
//  my41
//
//  Created by Miroslav Perovic on 8/8/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

typealias Digit = UInt8
typealias Digits14 = [Digit]
typealias Bits16 = UInt16
typealias Bits14 = UInt16
typealias Bits12 = UInt16
typealias Bits10 = UInt16
typealias Bits8 = UInt8
typealias Bits6 = UInt8
typealias Bits4 = UInt8
typealias Bits2 = UInt8
typealias Bit = UInt8
typealias byte = UInt8
typealias word = UInt16

let DEBUG = 0

let emptyDigit14:[Digit] = [Digit](count: 14, repeatedValue: 0)

struct CPURegisters {
	var A: Digits14			= emptyDigit14
	var B: Digits14			= emptyDigit14
	var C: Digits14			= emptyDigit14
	var M: Digits14			= emptyDigit14
	var N: Digits14			= emptyDigit14
	var P: Bits4			= 0
	var Q: Bits4			= 0
	var PC: Bits16			= 0
	var G: Bits8			= 0
	var ST: Bits8			= 0
	var T: Bits8			= 0
	var FI: Bits14			= 0
	var KY: Bits8			= 0
	var XST: Bits6			= 0
	var stack: [Bits16]		= [Bits16](count: 4, repeatedValue: 0)
	var R: Bit				= 0 {										// Active pointer
		didSet {
			if R > 1 {
				R = 1
			}
		}
	}
	var carry: Bit			= 0
	var mode: ArithMode		= .DEC_MODE									// DEC_MODE or HEX_MODE
	var ramAddress: Bits12	= 0											// Selected ram address
	var peripheral: Bits8	= 0											// Selected peripheral
	var keyDown: Bit		= 0											// Set if a key is being held down
	
	var dis: Disassembly = Disassembly()

	func description() {
		println("A=\(A)")
		println("B=\(B)")
		println("C=\(C)")
		println("M=\(M)")
		println("N=\(N)")
		println("P=\(P)")
		println("Q=\(Q)")
		println("PC=\(PC)")
		println("G=\(G)")
		println("ST=\(ST)")
		println("T=\(T)")
		println("FI=\(FI)")
		println("KY=\(KY)")
		println("XST=\(XST)")
		println("stack=\(stack)")
		println("R=\(R)")
		println("Carry=\(carry)")
		println("Mode=\(mode.rawValue)")
		println("ramAddress=\(ramAddress)")
		println("Peripheral=\(peripheral)")
		println("Keydown=\(keyDown)")
	}
}

enum PowerMode: Bits2 {
	case DeepSleep = 0
	case LightSleep = 1
	case PowerOn = 2
}

enum ArithMode: Bit {
	case DEC_MODE = 0
	case HEX_MODE = 1
}

let maxSimulationTimeLag = 0.2
let simulatedInstructionTime: Double = 155e-6

let fTable: [Int] = [
	/* 0 */ 0x3,
	/* 1 */ 0x4,
	/* 2 */ 0x5,
	/* 3 */ 0xA,
	/* 4 */ 0x8,
	/* 5 */ 0x6,
	/* 6 */ 0xB,
	/* 7 */ 0xE,
	/* 8 */ 0x2,
	/* 9 */ 0x9,
	/* A */ 0x7,
	/* B */ 0xD,
	/* C */ 0x1,
	/* D */ 0xC,
	/* E */ 0x0,
	/* F */ 0xF,
]

var zeroes: Digits14 = emptyDigit14

class CPU {
	var runFlag = false
	var simulationTime: NSTimeInterval?
	var reg: CPURegisters = CPURegisters()
	var keyReleaseDelay = 0
	var powerMode: PowerMode = .DeepSleep
	var soundOutput = SoundOutput()
	var cycleLimit = 0
	var currentTyte = 0
	var breakpointIsSet = false
	var breakpointAddr: Bits16 = 0
	var savedPC: Bits16 = 0
	var nextCarry: Bit = 0
	var lastTyte = 0
	var powerOffFlag = false
	var debugViewController: DebugViewController?
	
	let onKeyCode: Bits8 = 0x18
	
	let keyColTable: [Int] = [0x10, 0x30, 0x70, 0x80, 0xC0]
	
	class var sharedInstance :CPU {
		struct Singleton {
			static let instance = CPU()
		}
		
		return Singleton.instance
	}
		
	init() {
	}

	func clearRegisters() {
		reg.A = emptyDigit14
		reg.B = emptyDigit14
		reg.C = emptyDigit14
		reg.M = emptyDigit14
		reg.N = emptyDigit14
		reg.P = 0
		reg.Q = 0
		reg.PC = 0
		reg.G = 0
		reg.ST = 0
		reg.T = 0
		reg.FI = 0
		reg.KY = 0
		reg.XST = 0
		reg.stack = [Bits16](count: 4, repeatedValue: 0)
		reg.R = 0
		reg.carry = 0
		reg.mode = .DEC_MODE
		reg.ramAddress = 0
		reg.peripheral = 0
		reg.keyDown = 0
	}
	
	func setPowerMode(mode: PowerMode) {
		if powerMode != mode {
			if mode == .PowerOn && powerMode == .DeepSleep {
				reg.carry = 1
			}
			if mode == .PowerOn && powerMode == .LightSleep {
				reg.carry = 0
			}
			
			powerMode = mode
			if mode != .PowerOn {
				//TODO: IMPLEMENT
				soundOutput.flushAndSuspendSoundOutput()
				self.lineNo = 0
			}
			debugViewController?.updateDisplay()
		}
	}
	
	func step() {
		executeNextInstruction()
		debugViewController?.updateDisplay()
	}
	
	func reset() {
		clearRegisters()
		// The H41 firmware relies on the ON key being down on wakeup from
		// deep sleep, otherwise the display doesn't get turned on. But it does
		// a dummy test & reset of the keyboard before testing for this, so we
		// have to arrange for it to appear held down for at least 2 kbd tests.
		reg.KY = onKeyCode
		keyReleaseDelay = 1
		setPowerMode(.DeepSleep)
		setPowerMode(.PowerOn)
	}
	
	func keyWithCode(code: Int, pressed: Bool) {
		if pressed {
			let row = code >> 4
			let col = code & 0x0f
			reg.KY = Bits8(row | keyColTable[col])
			reg.keyDown = 1
			
			if reg.KY == onKeyCode && powerMode != .DeepSleep {
				powerOffFlag = true				// will enter deep sleep on next power off
			}
			if powerMode == .LightSleep || reg.KY == onKeyCode {
				setPowerMode(.PowerOn)
			}
		} else {
			reg.keyDown = 0
		}
		debugViewController?.updateDisplay()
	}
	
	func abortInstruction(message: String) {
		reg.PC = savedPC
//		[debugController show: YES];
		setRunning(false)
//		[debugController alert: message];
	}
	
	func running() -> Bool {
		return (powerMode == .PowerOn) && runFlag
	}
	
	func setRunning(state: Bool) {
		if runFlag != state {
			runFlag = state
			//TODO: IMPLEMENT
//			[debugController updateButtons];
			debugViewController?.updateDisplay()
		}
		simulationTime = NSDate.timeIntervalSinceReferenceDate()
	}
	
	func timeSlice(timer: NSTimer) {
		var currentTime = NSDate.timeIntervalSinceReferenceDate()
		if running() {
			let sTime = simulationTime!
			if sTime != 0 {
				if currentTime - sTime > maxSimulationTimeLag {
					simulationTime = currentTime - maxSimulationTimeLag
				}
				cycleLimit = soundOutput.soundAvailableBufferSpace()
				while self.running() && cycleLimit > 2 && simulationTime < currentTime {
					executeNextInstruction()
				}
				debugViewController?.updateDisplay()
			}
		} else {
			simulationTime = currentTime
		}
		//TODO: IMPLEMENT
		soundOutput.soundTimeslice()
	}
	
	func popReturnStack() -> Bits16 {
		var result = reg.stack[0]
		reg.stack[0] = reg.stack[1]
		reg.stack[1] = reg.stack[2]
		reg.stack[2] = reg.stack[3]
		reg.stack[3] = 0
		
		return result
	}
	
	func pushReturnStack(word: Bits16) {
		reg.stack[3] = reg.stack[2]
		reg.stack[2] = reg.stack[1]
		reg.stack[1] = reg.stack[0]
		reg.stack[0] = word
	}
	
	func fetch() -> (success: Bool, data: Int) {
		--cycleLimit
		simulationTime? += simulatedInstructionTime
		soundOutput.soundOutputForWordTime(Int(reg.T))
		if DEBUG != 0 {
			println("bus.readRomLocation \(reg.PC)")
		}
		let romLocation = bus!.readRomLocation(Int(reg.PC++))
		
		return (romLocation.success, romLocation.data)
	}
	
	func enableBank(bankSet: Bits4) {
		let currentBank = bus!.activeRomBankAtAddr(reg.PC)
		for slot: Bits4 in 0..<0x10 {
			let currentRom = bus!.romChipInSlot(slot)
			let newRom = bus!.romChipInSlot(slot, bank: bankSet)
			let slotBank = bus!.activeRomBankInSlot(slot)
			
			if (currentRom == nil) && (newRom == nil) && (slotBank == currentBank) {
				bus!.setActiveRomBankInSlot(slot, bank: bankSet)
			}
		}
	}
	
	func decrementPointer(inout p: Digit) {
		p = (p == 0) ? 13 : p - 1
	}
	
	func regR() -> Digit {
		if reg.R == 0 {
			return reg.P
		} else {
			return reg.Q
		}
	}
	
	func setR(newR: Bits4) {
		if reg.R == 0 {
			reg.P = newR
		} else {
			reg.Q = newR
		}
	}
	
	var lineNo = 0
	
	func executeNextInstruction() {
		if DEBUG != 0 {
			println("--------------------------------------------------------------------------------------------------")
			println("Step: \(++lineNo)")
			reg.description()
		}
		savedPC = reg.PC
		nextCarry = 0
		lastTyte = currentTyte
		let fetchResult = fetch()
		currentTyte = fetchResult.data
		if DEBUG != 0 {
			println("currentTyte: \(currentTyte)")
		}
		if fetchResult.success {
			switch currentTyte & 0x03 {
			case 0:		 // miscellaneous
				executeClass0(currentTyte)
			case 1:		 // long jumps
				executeClass1(currentTyte)
			case 2:		 // Arithmetic operations
				executeClass2(currentTyte)
			case 3:		 // short jumps
				executeClass3(currentTyte)
			default:	// Error
				println("PROBLEM!")
			}
		} else {
			reg.PC = popReturnStack()
		}
		reg.carry = Bit(nextCarry)
		if breakpointIsSet && reg.PC >= breakpointAddr {
			setRunning(false)
		}
	}

	func unimplementedInstruction(instr: Int) {
		abortInstruction("Unimplemented instruction: \(instr)")
	}

	
	//---------------------------- Class 0 ---------------------------------------------
	
	
	func executeClass0(instr: Int) {
		let param = (instr & 0x03C0) >> 6
		let opcode = ((instr & 0x003C) >> 2) & 0xf
		if DEBUG != 0 {
			println("executeClass0: opcode: \(opcode) - param: \(param)")
		}
		switch opcode {
		case 0x0:
			executeClass0Line0(param)
			
		case 0x1:
			executeClass0Line1(fTable[param])
			
		case 0x2:
			executeClass0Line2(fTable[param])
			
		case 0x3:
			executeClass0Line3(fTable[param])
			
		case 0x4:
			executeClass0Line4(param)
			
		case 0x5:
			executeClass0Line5(fTable[param])
			
		case 0x6:
			executeClass0Line6(param)
			
		case 0x7:
			executeClass0Line7(fTable[param])
			
		case 0x8:
			executeClass0Line8(param)
			
		case 0x9:
			// Printer control
			executeClass0Line9(param)
			
		case 0xA: // WRITE r
			executeClass0LineA(param)
			
		case 0xB:
			executeClass0LineB(fTable[param])
			
		case 0xC:
			executeClass0LineC(param)
			
		case 0xD:
			executeClass0LineD(param)
			
		case 0xE:
			executeClass0LineE(param)
			
		case 0xF:
			executeClass0LineF(fTable[param])
			
		default:
			unimplementedInstruction(param)
		}
	}
	
	func executeClass0Line0(param: Int) {
		switch param {
		case 0x0:
			/*
			NOP
			No Operation
			=========================================================================================
			NOP														operand: none
			
			Operation: None
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			NOP										0000_0000_00							1
			=========================================================================================
			*/
			break
			
		case 0x1:
			/*
			WROM
			Write ROM
			=========================================================================================
			WROM													operand: none
			
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			WROM									0001_0000_00							1
			=========================================================================================
			Note: This instruction is a NOP as far as the processor is concerned, but is used in
				  legacy software to write to the program address space, similar to the WCMD Write to
				  Logical Address. The contents of the C register are used as follows: digits 6-3 are
				  the logical address and digits 2-0 are the data. The write is performed to the
				  currently active bank in the logical address page. This is different from the WCMD
				  case, where the bank must be explicitly specified.
			
			Only twelve bits of data are available to be written to the memory. The other four bits
			are always zero. This means that there is no way to control the Turbo mode tag bits in
			memory when using this write.
			
							-----------------------------------------------------------------------
			nibble			| 13 | 12 | 11 | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
							-----------------------------------------------------------------------

			
							-----------------------------------------------------------------------
			write ROM		|                                  |  logical address  |      data    |
							-----------------------------------------------------------------------
			*/
			let slot = reg.C[6]
			if let rom = bus!.romChipInSlot(Bits4(slot)) {
				if rom.writable == false {
					break
				}
				
				let addr = (reg.C[5] << 8) | (reg.C[4] << 4) | reg.C[3]
				let toSave = ((reg.C[2] & 0x03) << 8) | (reg.C[1] << 4) | reg.C[0]
				rom[Int(addr)] = UInt16(toSave)
			}
			
		case 0x2, 0x3:
			// Not used
			break
			
		case 0x4, 0x5, 0x6, 0x7:
			/*
			ENROMx
			Enable ROM bank x
			=========================================================================================
			ENROMx													operand: none
			
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ENROM1									0100_0000_00							1
			ENROM2									0110_0000_00							1
			ENROM3									0101_0000_00							1
			ENROM4									0111_0000_00							1
			=========================================================================================
			Note: This instruction is a NOP for the processor, but is interpreted by either the
				  on-chip memory controller (if the current page is in system memory) or an external
				  ROM module (if the current page is in an external ROM module).
			
			For the on-chip memory controller, the actual bank select changes at the end of the
			current machine cycle. This means that the instruction following the ENROMx and all
			subsequent instructions are fetched from the new bank. This operation in the original NUT
			is not specified, but the usual code to execute a bank change is duplicated in all of the
			banks that are physically present. This makes the operation independent of the actual
			timing. The HP documentation for the 12K ROM chip specifies that the bank changes at the
			end of the current machine cycle.
			*/
			if param == 0x4 {
				enableBank(0)
			} else if param == 0x6 {
				enableBank(1)
			} else if param == 0x5 {
				enableBank(2)
			} else if param == 0x7 {
				enableBank(3)
			}
			
		case 0xE, 0xF:
			unimplementedInstruction(currentTyte)
			
		default:
			// NOP
			break
		}
	}
	
	func executeClass0Line1(param: Int) {
		switch param {
		case 0xE:
			unimplementedInstruction(param)
		
		case 0xF:
			/*
			CLRST
			Clear ST
			=========================================================================================
			CLRST													operand: none
				
			Operation: ST[7:0] <= 0
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CLRST									1111_0001_00							1
			=========================================================================================
			*/
			reg.ST = 0
		
		default:
			/*
			ST=0
			Clear Status bit
			=========================================================================================
			ST=0													operand: none
			
			Operation: ST[7:0] <= 0
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ST=0 d									dddd_0001_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction. This restriction is not present in the NEWT
				  implementation.
			*/
			if param <= 7 {
				reg.ST &= ~Bits8(1 << param)
			} else {
				reg.XST &= ~Bits8(1 << (param - 8))
			}
		}
	}
	
	func executeClass0Line2(param: Int) {
		switch param {
		case 0xE:
			unimplementedInstruction(param)
		
		case 0xF:
			/*
			RST KB
			Reset Keyboard
			=========================================================================================
			RST KB													operand: none
				
			Operation: KYF <= 0
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			RSTKB									1111_0010_00							1
			=========================================================================================
			Note: The keyboard flag is only cleared if the key has been released before this
				  instruction is executed. If the key is still down while this instruction is
				  executed the flag will remain set.
			*/
			if reg.keyDown == 0 {
				if keyReleaseDelay != 0 {		// See comment in reset:
					--keyReleaseDelay
				} else {
					reg.KY = 0
					reg.keyDown = 0
				}
			}
		
		default:
			/*
			ST=1
			Set Status bit
			=========================================================================================
			ST=1													operand: Digit Number
				
			Operation: ST[digit] <= 1
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ST=1 d									dddd_0010_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			if param <= 7 {
				reg.ST |= Bits8(1 << param)
			} else {
				reg.XST |= Bits8(1 << (param - 8))
			}
		}
	}
	
	func executeClass0Line3(param: Int) {
		switch (param) {
		case 0xE:
			unimplementedInstruction(param)
		
		case 0xF:
			/*
			CHKKB
			Check Keyboard
			=========================================================================================
			CHKKB													operand: none
			
			Operation: CY <= KYF
			=========================================================================================
			Flag: Set/Cleared according to the state of the keyboard flag
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CHKKB									1111_0011_00							1
			=========================================================================================
			*/
			if reg.KY != Bits8(0) {
				nextCarry = 1
			} else {
				nextCarry = 0
			}
		
		default:
			/*
			ST=1?
			Test Status Equal To One
			=========================================================================================
			ST=1?													operand: Digit Number
					
			Operation: CY <= Status<digit>
			=========================================================================================
			Flag: Set/Cleared as a the result of the test
			=========================================================================================
			Dec/Hex: Independent
			Turbo:   Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ST=1? d									dddd_0011_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			if param <= 7 {
				if (reg.ST & Bits8(1 << param)) != 0 {
					nextCarry = 1
				} else {
					nextCarry = 0
				}
			} else {
				if (reg.XST & Bits6(1 << (param - 8))) != 0 {
					nextCarry = 1
				} else {
					nextCarry = 0
				}
			}
		}
	}
	
	func executeClass0Line4(param: Int) {
		/*
		LC
		Load Constant
		=========================================================================================
		LC														operand: immediate nibble
				
		Operation: C<ptr> <= nnnn
				   ptr    <= ptr-
		=========================================================================================
		Flag: Cleared
		=========================================================================================
		Dec/Hex: Independent
		Turbo:   Independent
		=========================================================================================
		Assembly Syntax							Encoding						Machine Cycles
		-----------------------------------------------------------------------------------------
		LC n									nnnn_0100_00							1
		=========================================================================================
		*/
		
		var R: Bits4 = regR()
		reg.C[Int(R)] = Digit(param)
		if reg.R == 0 {
			decrementPointer(&reg.P)
		} else {
			decrementPointer(&reg.Q)
		}
	}

	func executeClass0Line5(param: Int) {
		var R: Bits4 = regR()
		switch param {
		case 0xE:
			unimplementedInstruction(param)
			
		case 0xF:
			/*
			DECPT
			Decrement Pointer
			=========================================================================================
			DECPT														operand: none
			
			Operation: ptr <= ptr-
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			DECPT									1111_0101_00							1
			=========================================================================================
			Note: This is not a binary or decimal decrement. The pointer decrements to the next lower
				  digit position.
			
						===========================================================
						| current ptr | next ptr |  current digit -> next digit   |
						===========================================================
						|     0000    |   1000   |   3 (Mantissa digit 0) -> 2    |
						|     0001    |   0000   |   4 (Mantissa digit 1) -> 3    |
						|     0010    |   0001   |   5 (Mantissa digit 2) -> 4    |
						|     0011    |   1001   |  10 (Mantissa digit 7) -> 9    |
						|     0100    |   1010   |   8 (Mantissa digit 5) -> 7    |
						|     0101    |   0010   |   6 (Mantissa digit 3) -> 5    |
						|     0110    |   0011   |  11 (Mantissa digit 8) -> 10   |
						|     1000    |   1100   |  2 (Exponent Sign digit) -> 1  |
						|     1001    |   0100   |   9 (Mantissa digit 6) -> 8    |
						|     1010    |   0101   |   7 (Mantissa digit 4) -> 6    |
						|     1011    |   1101   | 13 (Mantissa sign digit) -> 12 |
						|     1100    |   1110   |   1 (Exponent digit 1) -> 0    |
						|     1101    |   0110   |  12 (Mantissa digit 9) -> 11   |
						|     1110    |   1011   |   0 (Exponent digit 0) -> 13   |
						===========================================================
			*/
			R = (R == 0) ? 13 : R - 1
			setR(R)
			
		default:
			/*
			?PT=
			Test Pointer Equal To
			=========================================================================================
			?PT=														operand: Digit Number
				
			Operation: CY <= (PT == digit)
			=========================================================================================
			Flag: Set if the pointer is equal to the dddd field in the instruction; cleared otherwise
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?PT= d									dddd_0101_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			if R == Digit(param) {
				nextCarry = 1
			} else {
				nextCarry = 0
			}
		}
	}

	func executeClass0Line6(param: Int) {
		var R: Bits4 = regR()
		switch param {
		case 0x1:
			/*
			G=C
			Load G From C
			=========================================================================================
			G=C															operand: none
			
			Operation: G <= C<ptr+:ptr>
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			G=C										0001_0110_00							1
			=========================================================================================
			Note: There are several boundary conditions that can occur when the pointer is pointing
			      at the most significant nibble. These are detailed below:
			
			1. If the active pointer was not changed to point at the most significant nibble
			   immediately prior to this instruction, then:
							G <= {C<13>, C<0>}
			
			2. If the active pointer was changed to point at the most significant nibble
			   (using PT=13, INC PT or DEC PT) immediately prior to this instruction, then:
							G <= {C<13>, G<1>}
			
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction, then:
							G <= C<13:12> which is normal operation
			*/
			if (R == 13) {
				// 2 special cases
				if ((lastTyte != 0x2d4) && (lastTyte != 0x3d4) && (lastTyte != 0x3dc)) {
					reg.G = Bits8((reg.C[13] << 4) | reg.C[0])
				} else {
					var op1: Bits8 = Bits8(reg.C[13] << 4)
					var op2: Bits8 = ((reg.G & 0xf0) >> 4)
					reg.G = Bits8(op1 | op2)
				}
			} else {
				digitsToBitsWrap(digits: reg.C, bits: &reg.G, start: R, count: 2)
			}
			
		case 0x2:
			/*
			C=G
			Load C From G
			=========================================================================================
			C=G															operand: none
			
			Operation: C<ptr+:ptr> <= G
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=G										0010_0110_00							1
			=========================================================================================
			Note: There are several boundary conditions that can occur when the pointer is pointing
				  at the most significant nibble. These are detailed below:
			
			1. If the active pointer was not changed to point at the most significant nibble
			   immediately prior to this instruction, then:
								C<13> <= G<1>
								C<0>  <= G<0>
			
			2. If the active pointer was changed to point at the most significant nibble
			   (using PT=13, INC PT or DEC PT) immediately prior to this instruction, then:
							fork
								C<13> <= G<0>
								G     <= {G<0>, G<1>}
							join
			
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction, then:
							fork
								C<13:12> <= {G<0>, G<1>}
								C<0>     <= G<0>
								G        <= {G<0>, G<1>}
							join
			
			4. If the active pointer was changed from pointing at the most significant nibble
			(using PT=d only) immediately prior to this instruction, then:
							fork
								C<ptr+:ptr> <= {G<0>, G<1>}
								C<0>        <= G<0>
								G           <= {G<0>, G<1>}
							join
			*/
			if (R == 13) {
				// 3 special cases
				if ((lastTyte != 0x2d4) && (lastTyte != 0x3d4) && (lastTyte != 0x3dc)) {
					reg.C[13] = Digit(((reg.G & 0xf0) >> 4))
					reg.C[0] = Digit((reg.G & 0xf))
				} else {
					reg.C[13] = Digit((reg.G & 0xf))
					reg.G = Bits8(((reg.G & 0xf) << 4) | ((reg.G & 0xf) >> 4))
				}
			} else if ((R == 12) && (lastTyte == 0x3d4)) {
				reg.G = ((reg.G & 0xf) << 4) | ((reg.G & 0xf0) >> 4)
				reg.C[13] = Digit((reg.G & 0xf0) >> 4)
				reg.C[12] = Digit(reg.G & 0xf)
				reg.C[0] = reg.C[13]
			} else {
				bitsToDigitsWrap(bits: reg.G, digits: &reg.C, start: R, count: 2)
			}
			
		case 0x3:
			/*
			CGEX
			Exchange C and G
			=========================================================================================
			CGEX														operand: none
				
			Operation: fork
							C<ptr+:ptr> <= G
							G <= C<ptr+,ptr>
					   join
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CGEX									0011_0110_00							1
			=========================================================================================
			Note: There are several boundary conditions that can occur when the pointer is pointing
				  at the most significant nibble. These are detailed below:
				
			1. If the active pointer was not changed to point at the most significant nibble
			   immediately prior to this instruction, then:
							fork
								C<13> <= G<1>
								C<0>  <= G<0>
								G     <= {C<13>, C<0>}
							join
				
			2. If the active pointer was changed to point at the most significant nibble
			   (using PT=13, INC PT or DEC PT) immediately prior to this instruction, then:
							fork
								C<13> <= G<0>
								G     <= {C<13>, G<1>}
							join
				
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction, then:
							fork
								C<13:12> <= {C<0>, G<1>}
								C<0>     <= G<0>
								G        <= C<13:12>
							join
				
			4. If the active pointer was changed from pointing at the most significant nibble
			   (using PT=d only) immediately prior to this instruction, then:
							fork
								C<ptr+:ptr> <= {C<0>, G<1>}
								C<0>        <= G<0>
								G           <= C<ptr+:ptr>
							join
			*/
			var temp: Bits8
			
			if (R == 13) {
				// 3 special cases
				if ((lastTyte != 0x2d4) && (lastTyte != 0x3d4) && (lastTyte != 0x3dc)) {
					temp = reg.G;
					reg.G = (reg.C[13] << 4) | reg.C[0]
					reg.C[13] = ((temp & 0xf0) >> 4)
					reg.C[0] = (temp & 0xf)
				}
				else {
					temp = reg.G;
					reg.G = (reg.C[13] << 4) | ((reg.G & 0xf) >> 4)
					reg.C[13] = (temp & 0xf)
				}
			}
			else if ((R == 12) && (lastTyte == 0x3d4)) {
				temp = reg.G
				reg.G = (reg.C[13] << 4) | reg.C[12]
				reg.C[13] = reg.C[0]
				reg.C[12] = (temp & 0xf0) >> 4
				reg.C[0] = temp & 0xf
			} else {
				temp = reg.G;
				digitsToBitsWrap(digits: reg.C, bits: &reg.G, start: R, count: 2)
				bitsToDigitsWrap(bits: temp, digits: &reg.C, start: R, count: 2)
			}
			
		case 0x5:
			/*
			M=C
			Load M from C
			=========================================================================================
			M=C															operand: none
						
			Operation: M <= C
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			M=C										0101_0110_00							1
			=========================================================================================
			*/
			copyDigits(reg.C, sourceStartAt: 0, destination: &reg.M, destinationStartAt: 0, count: 14)
			
		case 0x6:
			/*
			C=M
			Load C From M
			=========================================================================================
			C=M															operand: none
				
			Operation: C <= M
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=M										0110_0110_00							1
			=========================================================================================
			*/
			copyDigits(reg.M, sourceStartAt: 0, destination: &reg.C, destinationStartAt: 0, count: 14)
			
		case 0x7:
			/*
			CMEX
			Exchange C and M
			=========================================================================================
			CMEX														operand: none
				
			Operation: fork
							C <= M
							M <= C
					   join
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CMEX									0111_0110_00							1
			=========================================================================================
			*/
			var x = reg.C
			var y = reg.M
			exchangeDigits(X: &x, Y: &y, startPos: 0, count: 14)
			reg.C = x
			reg.M = y
			
		case 0x8:
			unimplementedInstruction(param)
			
		case 0x9:
			/*
			F=SB
			Load Flag Out from Status Byte
			=========================================================================================
			F=SB														operand: none
				
			Operation: FO<7:0> <= ST[7:0]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed a bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			F=SB									1001_0110_00							1
			=========================================================================================
			Note: The fo_bus output timing is not independent of the Turbo mode, so the timing is
				  identical to normal operation only during the execution of this instruction. Thus a
				  timing loop that times the duration of the fo_bus output should be tagged to
				  execute at normal bus speed.
			*/
			reg.T = reg.ST
			
		case 0xA:
			/*
			SB=F
			Load Status Byte from Flag Out
			=========================================================================================
			SB=F														operand: none
				
			Operation: ST[7:0] <= FO[7:0]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed a bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SB=F									1010_0110_00							1
			=========================================================================================
			*/
			reg.ST = reg.T
			
		case 0xB:
			/*
			FEXSB
			Load Status Byte from Flag Out
			=========================================================================================
			FEXSB														operand: none
				
			Operation: fork
							FO<7:0> <= ST[7:0]
							ST[7:0] <= FO<7:0>
					   join
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			FEXSB									1011_0110_00							1
			=========================================================================================
			Note: The fo_bus output timing is not independent of the Turbo mode, so the timing is
				  identical to normal operation only during the execution of this instruction. Thus a
				  timing loop that times the duration of the fo_bus output should be tagged to
				  execute at normal bus speed
			*/
			let temp = reg.ST
			reg.ST = reg.T
			reg.T = temp
			
		case 0xC:
				unimplementedInstruction(param)
			
		case 0xD:
			/*
			ST=C
			Load Status from C
			=========================================================================================
			ST=C														operand: none
			
			Operation: ST[7:0] <= C<1:0>
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ST=C									1101_0110_00							1
			=========================================================================================
			*/
			reg.ST = (reg.C[1] << 4) | reg.C[0]
			
		case 0xE:
			/*
			C=ST
			Load C From ST
			=========================================================================================
			C=ST														operand: none
				
			Operation: C<1:0> <= ST[7:0]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=ST									1110_0110_00							1
			=========================================================================================
			*/
			reg.C[1] = (reg.ST & 0xf0) >> 4
			reg.C[0] = (reg.ST & 0xf)
			
		case 0xF:
			/*
			CSTEX
			Exchange C and M
			=========================================================================================
			CSTEX														operand: none
				
			Operation: fork
							C<1:0> <= ST[7:0]
							ST[7:0] <= C<1:0>
					   join
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CSTEX									1111_0110_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			let temp1 = reg.C[1]
			let temp0 = reg.C[0]
			
			reg.C[1] = (reg.ST & 0xf0) >> 4;
			reg.C[0] = reg.ST & 0xf;
			reg.ST = (temp1 << 4) | temp0
			
		default:
			unimplementedInstruction(param)
		}
	}
	
	func executeClass0Line7(param: Int) {
		var R: Bits4 = regR()
		switch (param) {
		case 0xE:
			unimplementedInstruction(param)
				
		case 0xF:
			/*
			INCPT
			Increment Pointer
			=========================================================================================
			INCPT														operand: none
				
			Operation: ptr <= ptr+
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			INCPT									1111_0111_00							1
			=========================================================================================
			Note: This is not a binary or decimal increment. The pointer increments to the next
				  higher digit position.
				
							===========================================================
							| current ptr | next ptr |  current digit -> next digit   |
							===========================================================
							|     0000    |   0001   |   3 (Mantissa digit 0) -> 4    |
							|     0001    |   0010   |   4 (Mantissa digit 1) -> 5    |
							|     0010    |   0101   |   5 (Mantissa digit 2) -> 6    |
							|     0011    |   0110   |  10 (Mantissa digit 7) -> 11   |
							|     0100    |   1001   |   8 (Mantissa digit 5) -> 9    |
							|     0101    |   1010   |   6 (Mantissa digit 3) -> 7    |
							|     0110    |   1101   |  11 (Mantissa digit 8) -> 12   |
							|     1000    |   0000   |  2 (Exponent Sign digit) -> 3  |
							|     1001    |   0011   |   9 (Mantissa digit 6) -> 10   |
							|     1010    |   0100   |   7 (Mantissa digit 4) -> 8    |
							|     1011    |   1110   | 13 (Mantissa sign digit) -> 0  |
							|     1100    |   1000   |   1 (Exponent digit 1) -> 2    |
							|     1101    |   1011   |  12 (Mantissa digit 9) -> 13   |
							|     1110    |   1100   |   0 (Exponent digit 0) -> 1    |
							===========================================================
			*/
			R = (R >= 13) ? 0 : R + 1
			setR(R)
			
		default:
			/*
			PT=
			Load Pointer immediate
			=========================================================================================
			PT=															operand: digit
				
			Operation: ptr <= digit
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			PT= d									dddd_0111_00							1
			=========================================================================================
			*/
			R = Digit(param)
			setR(R)
		}
	}
	
	func executeClass0Line8(param: Int) {
		switch param {
		case 0x0:
			/*
			SPOPND
			Pop Stack
			=========================================================================================
			SPOPND														operand: none
			
			Operation: STK0 <= STK1
					   STK1 <= STK2
					   STK2 <= STK3
					   STK3 <= 0000
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SPOPND									0000_1000_00							1
			=========================================================================================
			*/
			popReturnStack()
			
		case 0x1:
			/*
			POWOFF
			Power Down
			=========================================================================================
			POWOFF														operand: none
			
			Operation: Power Down
			=========================================================================================
			Flag: Set if P equals Q; cleared otherwise.
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			POWOFF									0001_1000_00							2
													0000_0000_00
			=========================================================================================
			*/
			if powerOffFlag {
				//printf("POWOFF: going into deep sleep and resetting powerOffFlag\n");
				setPowerMode(.DeepSleep)
				powerOffFlag = false
			} else {
				//printf("POWOFF: going into light sleep\n");
				setPowerMode(.LightSleep)
			}
			reg.PC = 0
			enableBank(0)
			
		case 0x2:
			/*
			SELP
			Select Pointer P
			=========================================================================================
			SELP														operand: none
			
			Operation: ptr = P
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SELP									0010_1000_00							1
			=========================================================================================
			*/
			reg.R = 0
			
		case 0x3:
			/*
			SELQ
			Select Pointer Q
			=========================================================================================
			SELQ														operand: none
			
			Operation: ptr = Q
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SELQ									0011_1000_00							1
			=========================================================================================
			*/
			reg.R = 1
			
		case 0x4:
			/*
			?P=Q
			Test P Equal To Q
			=========================================================================================
			?P=Q														operand: none
			
			Operation: CY <= (P == Q)
			=========================================================================================
			Flag: Set if P equals Q; cleared otherwise.
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?P=Q									0100_1000_00							1
			=========================================================================================
			*/
			if reg.P == reg.Q {
				nextCarry = 1
			} else {
				nextCarry = 0
			}
			
		case 0x5:
			/*
			?LLD
			Low Level Detect
			=========================================================================================
			?LLD														operand: none
			
			Operation: CY <= low_battery_status
			=========================================================================================
			Flag: Set if the lld input is Low, signaling a Low Battery; cleared otherwise.
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?LLD									0101_1000_00							1
			=========================================================================================
			Note: Our batteries NEVER go flat! Or your money back!
			*/
			break
			
		case 0x6:
			/*
			CLRABC
			Clear A, B and C
			=========================================================================================
			CLRABC														operand: none
			
			Operation: A <= 0
					   B <= 0
					   C <= 0
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CLRABC									0110_1000_00							1
			=========================================================================================
			*/
			reg.A = emptyDigit14
			reg.B = emptyDigit14
			reg.C = emptyDigit14
			
		case 0x7:
			/*
			GOTOC
			Branch using C register
			=========================================================================================
			GOTOC														operand: none
				
			Operation: PC <= C<6:3>
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GOTOC									0111_1000_00							1
			=========================================================================================
			*/
//			var digits: [Digit] = [reg.C[3]]
			var digits: [Digit] = [Digit]()
			for idx in 3..<14 {
				digits.append(reg.C[idx])
			}
			reg.PC = digitsToBits(digits: digits, nbits: 16)
			
		case 0x8:
			/*
			C=KEYS
			Load C From KEYS
			=========================================================================================
			C=KEYS														operand: none
			
			Operation: C<4:3> <= KEYS
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=KEYS									1000_1000_00							1
			=========================================================================================
			*/
			bitsToDigits(bits: Int(reg.KY), destination: &reg.C, start: 3, count: 2)
			
		case 0x9:
			/*
			SETHEX
			Set Decimal Mode
			=========================================================================================
			SETHEX														operand: none
				
			Operation: hex_mode = 1
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SETHEX									1001_1000_00							1
			=========================================================================================
			*/
			reg.mode = .HEX_MODE
			
		case 0xA:
			/*
			SETDEC
			Set Decimal Mode
			=========================================================================================
			SETDEC														operand: none
			
			Operation: hex_mode = 0
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			SETDEC									1010_1000_00							1
			=========================================================================================
			*/
			reg.mode = .DEC_MODE
			
		case 0xB:
			/*
			DISOFF
			Display off
			=========================================================================================
			DISOFF														operand: none
			
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			DISOFF									1011_1000_00							1
			=========================================================================================
			Note: This instruction is a NOP for the processor, but is interpreted by the (off-chip)
				  LCD display controller, which turns off the display.
			*/
			NSNotificationCenter.defaultCenter().postNotificationName("displayOff", object: nil)
			break
			
		case 0xC:
			/*
			DISTOG
			Display Toggle
			=========================================================================================
			DISTOG														operand: none
				
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			DISTOG									1100_1000_00							1
			=========================================================================================
			Note: This instruction is a NOP for the processor, but is interpreted by the (off-chip)
			LCD display controller, which toggles the display.
			*/
			NSNotificationCenter.defaultCenter().postNotificationName("displayToggle", object: nil)
			break
			
		case 0xD:
			/*
			RTNC
			Return from subroutine on Carry
			=========================================================================================
			RTNC														operand: none
				
			Operation: if (CY) begin
							  PC <= STK0
							STK0 <= STK1
							STK1 <= STK2
							STK2 <= STK3
							STK3 <= 0000
					   end
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			RTNC									1101_1000_00							1
			=========================================================================================
			*/
			if reg.carry != 0 {
				reg.PC = popReturnStack()
			}
			
		case 0xE:
			/*
			RTNNC
			Return from subroutine on No Carry
			=========================================================================================
			RTNNC														operand: none
			
			Operation: if (!CY) begin
							  PC <= STK0
							STK0 <= STK1
							STK1 <= STK2
							STK2 <= STK3
							STK3 <= 0000
					   end
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			RTNNC									1110_1000_00							1
			=========================================================================================
			*/
			if reg.carry == 0 {
				reg.PC = popReturnStack()
			}
			
		case 0xF:
			/*
			RTN
			Return from subroutine
			=========================================================================================
			RTN															operand: none
					
			Operation: PC   <= STK0
					   STK0 <= STK1
					   STK1 <= STK2
					   STK2 <= STK3
					   STK3 <= 0000
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			RTN										1111_1000_00							1
			=========================================================================================
			*/
			reg.PC = popReturnStack()
			
		default:
			unimplementedInstruction(param)
		}
	}
	
	func executeClass0Line9(param: Int) {
		/*
		SELPF
		Select Peripheral
		=========================================================================================
		SELPF														operand: peripheral number
						
		Operation: transfer control to peripheral n
		=========================================================================================
		Flag: Cleared
		=========================================================================================
		Dec/Hex: Independent
		Turbo: Automatically fetched and executed at bus speed
		=========================================================================================
		Assembly Syntax							Encoding						Machine Cycles
		-----------------------------------------------------------------------------------------
		SELPF n									nnnn_1001_00					   2 or more
		=========================================================================================
		Note: This instruction transfers control from the CPU to an intelligent peripheral. The
			  CPU continues to fetch instructions, incrementing the PC with each fetch, but in
			  general ignores the instructions fetched from the isa_bus. Control is returned to
			  the CPU when the instruction fetched has the LSB set to one. All of these fetches
			  are executed at normal bus speed, including the first fetch after control is
			  returned to the CPU.
						
		Two instructions are available to transfer information from the peripheral back to the
		CPU: First, the ?PFLGn=1 instruction transfers the contents of one of sixteen flags
		internal to the peripheral back to the CY flag during the first clock cycle of the
		following instruction (which is executed by the CPU). Second, the C=DATAPn instruction
		sets the data_bus as an input and the contents of the data_bus during the execution of
		this instruction is loaded into the C register. With these two instructions, either
		status information or data may be communicated from the peripheral to the CPU.
		*/
		switch param {
		case 0xE, 0x9:
			// Printer ROM is loaded?
			if let printerRom = bus!.romChipInSlot(6) {
				reg.peripheral = 1
			}
		default:
			unimplementedInstruction(param)
		}
	}
	
	func executeClass0LineA(param: Int) {
		/*
		REGN=C
		Load Register from C
		=========================================================================================
		REGN=C														operand: register number
				
		Operation: reg_addr      <= {reg_addr[11:4], nnnn}
				   REG[reg_addr] <= C
		=========================================================================================
		Flag: Cleared
		=========================================================================================
		Dec/Hex: Independent
		Turbo: Independent for valid register address; fetched and executed at bus speed for an
			   unimplemented register or a peripheral register.
		=========================================================================================
		Assembly Syntax							Encoding						Machine Cycles
		-----------------------------------------------------------------------------------------
		REGN=C n								nnnn_1010_00							1
		=========================================================================================
		Note: Bits 11-4 of the register address must have been previously loaded into reg_addr by
			  a DADD=C instruction. The data is actually written to the parallel memory bus using
			  the RAM chip select.
				
		The value nnnn replaces the least significant four bits of the current value in the
		latched register address reg_addr.
		*/
		if reg.peripheral == 0 {
			// RAM is currently selected peripheral
			reg.ramAddress = (reg.ramAddress & 0x0FF0) | Bits12(param)
			bus!.writeRamAddress(reg.ramAddress, from: reg.C)
		} else {
			switch (reg.peripheral) {
			case 0x10:
				// Halfnut display
				break;
			case 0xfb:
				// Timer write
				break;
			case 0xfc:
				// Card reader
				break;
			case 0xfd:
				// LCD display
				break;
			case 0xfe:
				// Wand
				break;
			default:
				break;
			}
			bus!.writeToRegister(Bits4(param), ofPeripheral: reg.peripheral, from: &reg.C)
		}
	}
	
	func executeClass0LineB(param: Int) {
		switch param {
		case 0xE, 0xF:
			/*
			Operation: No operation
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
													0111_1011_00							1
													1111_1011_00							1
			=========================================================================================
			*/
			unimplementedInstruction(param)
			
		default:
			/*
			?Fd=1
			Test Flag Input Equal to One
			=========================================================================================
			?Fd=1														operand: Digit Number
			
			Operation: CY <= FI<digit>
			=========================================================================================
			Flag: Set/Cleared to match the selected Flag Input
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at normal bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?Fd=1									dddd_1011_00							1
			=========================================================================================
			Note: The flag input, fi_bus, is sampled near the middle of the appropriate digit time
			      (on the falling edge of the second ph1 clock) during the execution phase of this
			      instruction. The following flags are currently used in an HP-41 system:
			
							================================================================
							| flag number | device | Mnemonic |            Used for        |
							================================================================
							|      0      | 82143A |   ?PBSY  |         Printer Busy       |
							|             | 82242A |          |                            |
							|      1      | 82104A |   ?CRDR  |         Card Reader        |
							|      2      | 82153A |   ?WNDB  |     Wand Byte Available    |
							|      5      | 82242A |   ?EDAV  |   Emitter Diode Available  |
							|      6      | 82160A |   ?IFCR  |  Interface Clear Received  |
							|      7      | 82160A |   ?SRQR  |  Service Request Received  |
							|      8      | 82160A |   ?FRAV  |      Frame Available       |
							|      9      | 82160A |   ?FRNS  | Frame Received Not As Sent |
							|	  10      | 82160A |   ?ORAV  | Output Register Available  |
							|	  12      | 82182A |   ?ALM   |           Alarm            |
							|     13      |   all  |   ?SER   |      Service Request       |
							================================================================
			*/
			if (reg.FI & Bits14(1 << param)) != 0 {
				nextCarry = 1
			} else {
				nextCarry = 0
			}
		}
	}
	
	func executeClass0LineC(param: Int) {
		switch param {
		case 0x0:
			// Special HEPAX Module treatment
			/*
			Operation: No operation
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
													0000_1100_00							1
			=========================================================================================
			*/
			unimplementedInstruction(param)
			
		case 0x1:
			/*
			N=C
			Load N from C
			=========================================================================================
			N=C															operand: none
			
			Operation: N <= C
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			N=C										0001_1100_00							1
			=========================================================================================
			*/
			copyDigits(reg.C, sourceStartAt: 0, destination: &reg.N, destinationStartAt: 0, count: 14)
			
		case 0x2:
			/*
			C=N
			Load C from N
			=========================================================================================
			C=N															operand: none
			
			Operation: C <= N
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=N										0010_1100_00							1
			=========================================================================================
			*/
			copyDigits(reg.N, sourceStartAt: 0, destination: &reg.C, destinationStartAt: 0, count: 14)
			
		case 0x3:
			/*
			CNEX
			Exchange C and N
			=========================================================================================
			CNEX														operand: none
			
			Operation: fork
							C <= N
							N <= C
					   join
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CNEX									0011_1100_00							1
			=========================================================================================
			*/
			var x = reg.C
			var y = reg.N
			exchangeDigits(X: &x, Y: &y, startPos: 0, count: 14)
			reg.C = x
			reg.N = y
			
		case 0x4:
			/*
			LDI
			Load Immediate
			=========================================================================================
			LDI														operand: immediate 10-bit value
			
			Operation: C<2:0> <= {2’b00, const}
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			LDI const								0100_1100_00							2
														const
			=========================================================================================
			Note: When executed at bus speed the sync signal is suppressed during the fetch of the
			      second word of the instruction to prevent external devices from incorrectly
				  interpreting the contents of the isa_bus during the second machine cycle as an
				  instruction.
			*/
			let fetchResult = fetch()
			bitsToDigits(bits: Int(fetchResult.data), destination: &reg.C, start: 0, count: 3)
			
		case 0x5:
			/*
			STK=C
			Push C
			=========================================================================================
			STK=C													operand: none
				
			Operation: STK3 <= STK2
					   STK2 <= STK1
					   STK1 <= STK0
					   STK0 <= C<6:3>
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			STK=C									0101_1100_00							1
			=========================================================================================
			*/
			var word: UInt16 = 0
//			var digits: [Digit] = [reg.C[3]]
			var digits: [Digit] = [Digit]()
			for idx in 3...13 {
				digits.append(reg.C[idx])
			}
			word = digitsToBits(digits: digits, nbits: 16)
			pushReturnStack(Bits16(word))
			
		case 0x6:
			/*
			C=STK
			Load C From STK
			=========================================================================================
			C=STK													operand: none
			
			Operation: C<6:3> <= STK0
					   STK0   <= STK1
					   STK1   <= STK2
					   STK2   <= STK3
					   STK3   <= 0000
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=STK									0110_1100_00							1
			=========================================================================================
			*/
			var word = popReturnStack()
			bitsToDigits(bits: Int(word), destination: &reg.C, start: 3, count: 4)
			
		case 0x7:
			// HEPAX Toggle write protection on HEPAX at page C[0]
			/*
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
													0111_1100_00							1
			=========================================================================================
			*/
			unimplementedInstruction(param)
			
		case 0x8:
			/*
			GOKEYS
			Branch to Keys
			=========================================================================================
			GOKEYS													operand: none
			
			Operation: PC <= {PC[15:8], KEYS}
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GOKEYS									1000_1100_00							1
			=========================================================================================
			*/
			reg.PC = (reg.PC & 0xff00) | Bits16(reg.KY)
			
		case 0x9:
			/*
			DADD=C
			Load Register address from C
			=========================================================================================
			DADD=C													operand: none
				
			Operation: reg_addr <= C<2:0>
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			DADD=C									1001_1100_00							1
			=========================================================================================
			Note: The register address is loaded into reg_addr (at memory location 0x804000) by the
			DADD=C instruction.
			*/
			reg.ramAddress = digitsToBits(digits: reg.C, nbits: 12)
			
		case 0xA:
			/*
			CLRDATA
			Clear Registers
			=========================================================================================
			CLRDATA													operand: none
			
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CLRDATA									1010_1100_00							1
			=========================================================================================
			Note: This instruction is a NOP for the processor. The original data storage chips used
				  in the HP-41 series cleared all 16 registers on the selected data storage chip as
				  a result of this instruction.
			*/
			clearRegisters()
			
		case 0xB:
			/*
			DATA=C
			Load Register from C
			=========================================================================================
			DATA=C													operand: none
				
			Operation: REG[reg_addr] <= C
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent for valid register address; fetched and executed at bus speed for an
				   unimplemented register or a peripheral register.
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			DATA=C									1011_1100_00							1
			=========================================================================================
			Note: The register address must have been previously loaded into reg_addr by a
			DADD=C instruction. The data is actually written to the parallel memory bus using the
			RAM chip select.
			*/
			if reg.peripheral == 0 || reg.peripheral == 0xFB {
				bus!.writeRamAddress(reg.ramAddress, from: reg.C)
			} else {
				bus!.writeDataToPeripheral(slot: reg.peripheral, from: reg.C)
			}
			
		case 0xC:
			/*
			CXISA
			Exchange C and ISA
			=========================================================================================
			CXISA													operand: none
				
			Operation: mem_addr <= C<6:3>
					   C<2:0>   <= ISA[mem_addr]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CXISA									1100_1100_00							2
			=========================================================================================
			Note: During the second machine cycle of this instruction the contents of C<6:3> are used
				  as a program memory address on isa_bus. The contents of this program memory
				  location are then loaded into C<2:0>, right-justified, with the two most
				  significant bits set to 0.
			*/
			var addr: UInt16 = 0
			var digits: [Digit] = [Digit]()
			for idx in 3...13 {
				digits.append(reg.C[idx])
			}
			addr = digitsToBits(digits: digits, nbits: 16)
			let romLocation = bus!.readRomLocation(Int(addr))
			bitsToDigits(bits: romLocation.data, destination: &reg.C, start: 0, count: 3)
			
		case 0xD:
			/*
			C=CORA
			Load C With C OR A
			=========================================================================================
			C=CORA													operand: none
			
			Operation: C <= C | A
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=CORA									1101_1100_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			reg.C = orDigits(X: reg.C, Y: reg.A, start: 0, count: 14)
			
		case 0xE:
			/*
			C=C&A
			Load C With C AND A
			=========================================================================================
			C=C&A													operand: none
					
			Operation: C <= C & A
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=C&A									1110_1100_00							1
			=========================================================================================
			Note: In the original NUT implementation this instruction cannot immediately follow an
				  arithmetic (type 10) instruction.
			*/
			reg.C = andDigits(X: reg.C, Y: reg.A, start: 0, count: 14)
			
		case 0xF:
			/*
			PFAD=C
			Load Peripheral Address from C
			=========================================================================================
			PFAD=C													operand: none
				
			Operation: No operation
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			PFAD=C									1110_1100_00							1
			=========================================================================================
			Note: This instruction is a NOP for the processor, but is interpreted by peripheral
				  devices to perform the chip select function. The peripheral chip select remains
				  active until another PFAD=C instruction selects a different peripheral. Peripheral
				  devices decode the least-significant byte on the data_bus according to the
				  following table:
				
											===============================
											| c<1:0> |  Peripheral Device |
											===============================
											|  0xF0  |  NEWT On-chip Port |
											|  0xFB  |        Timer       |
											|  0xFC  |     Card Reader    |
											|  0xFD  | LCD Display Driver |
											|  0xFE	 |        Wand        |
											===============================
			*/
			var temp: UInt16 = UInt16(reg.peripheral)
			temp = digitsToBits(digits: reg.C, nbits: 8)
			reg.peripheral = Bits8(temp)
			
		default:
			unimplementedInstruction(param)
		}
	}
	
	func executeClass0LineD(param: Int) {
		// Doing still nothing
		unimplementedInstruction(param)
	}
	
	func executeClass0LineE(param: Int) {
		switch param {
		case 0:
			/*
			C=DATA
			Load C From Register (Indirect)
			=========================================================================================
			C=DATA													operand: none
					
			Operation: C <= REG[reg_addr]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo:   Independent for valid register address; fetched and executed at bus speed for an
					 unimplemented register or a peripheral register.
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=DATA									0000_1110_00							1
			=========================================================================================
			Note: The register address must have been previously loaded into reg_addr by a
				  DADD=C instruction. The data is actually loaded from the parallel memory bus using
				  the RAM chip select.
					
			There are unimplemented areas in the register map in 41C mode. Accessing an unimplemented
			register causes the data_bus to remain floating, allowing an external device to drive the
			data_bus.
			*/
			if (reg.peripheral == 0 || (reg.ramAddress <= 0x000F) || (reg.ramAddress >= 0x0020)) {
				bus!.readRamAddress(reg.ramAddress, into: &reg.C)
			} else {
				//printf("Peripheral Read: %02X %x \n", reg.peripheral, param);
				bus!.readFromRegister(register: Bits4(param), ofPeripheral: reg.peripheral, into: &reg.C)
			}
		default:
			/*
			C=REGN
			Load C From Register
			=========================================================================================
			C=REGN													operand: register number
				
			Operation: reg_addr <= {reg_addr[11:4], nnnn}
					          C <= REG[reg_addr]
			=========================================================================================
			Flag: Cleared
			=========================================================================================
			Dec/Hex: Independent
			Turbo: Independent for valid register address; fetched and executed at bus speed for an
				   unimplemented register or a peripheral register.
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=REGN n								nnnn_1110_00							1
			=========================================================================================
			Note: Bits 11-4 of the register address must have been previously loaded into reg_addr by
				  a DADD=C instruction. The data is actually loaded from the parallel memory bus
				  using the RAM chip select.
				
			As discussed in the Memory Organization chapter, there are unimplemented areas in the
			register map in 41C mode. Accessing an unimplemented register causes the data_bus to
			remain floating, allowing an external device to drive the data_bus.
			
			Only fifteen encodings are valid for nnnn. The all zeros case is the C=DATA instruction,
			with indirect register addressing.
			*/
			if (reg.peripheral == 0 || (reg.ramAddress <= 0x000F) || (reg.ramAddress >= 0x0020)) {
				reg.ramAddress = Bits12(reg.ramAddress & 0x03F0) | Bits12(param)
				bus!.readRamAddress(reg.ramAddress, into: &reg.C)
			} else {
				//printf("Peripheral Read: %02X %x \n", reg.peripheral, param);
				bus!.readFromRegister(register: Bits4(param), ofPeripheral: reg.peripheral, into: &reg.C)
			}
		}
	}
	
	func executeClass0LineF(param: Int) {
		switch (param) {
		case 0x0, 0xE, 0xF:
			unimplementedInstruction(param)
		
		case 0x7:
			/*
			WCMD
			Write Command
			=========================================================================================
			WCMD													operand: none
		
			Operation: No operation
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:  Independent
			Turbo:    Automatically fetched and executed at bus speed
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			WCMD									0111_1111_00							1
			=========================================================================================
			Note: This instruction is a NOP as far as the processor is concerned, but is interpreted
				  by the Memory Management Unit or Turbo Control Unit. Writes automatically transfer
				  the contents of the C register to the destination. Reads latch the relevant data,
				  which can then be accessed via the on-chip I/O Port. The contents of digit 4 are
				  interpreted as a command, and some of the remaining digit contents are used for
				  data. The write commands are:
		
									====================================
									| Command |         Meaning        |
									|==================================|
									|    0    |  Write MMU (per bank)  |
									|----------------------------------|
									|    2    | Write Logical Address  |
									|----------------------------------|
									|    4    | Write Physical Address |
									|----------------------------------|
									|    6    |   Global MMU Disable   |
									|----------------------------------|
									|    7    |   Global MMU Enable    |
									|----------------------------------|
									|    8    |   Disable Turbo Mode   |
									|----------------------------------|
									|    9    |  Enable 2X Turbo Mode  |
									|----------------------------------|
									|    A    |  Enable 5X Turbo Mode  |
									|----------------------------------|
									|    B    | Enable 10X Turbo Mode  |
									|----------------------------------|
									|    C    | Enable 20X Turbo Mode  |
									|----------------------------------|
									|    D    | Enable 50X Turbo Mode  |
									|----------------------------------|
									|    E    |  Special MMU Disable   |
									|----------------------------------|
									|    F    |  Special MMU Enable    |
									====================================
			
			The read commands are:
				
								  ========================================
								  | Command |           Meaning          |
								  |======================================|
								  |    1    |     Read MMU (per bank)    |
								  |--------------------------------------|
								  |    3    | Read from Logical Address  |
								  |--------------------------------------|
								  |    5    | Read from Physical Address |
								  ========================================
				
			The table below shows the format of the data used by these commands. Refer to the
			Memory Organization, Turbo Mode or I/O Port chapter for more details.
				
				
									-----------------------------------------------------------------------
			nibble					| 13 | 12 | 11 | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
									-----------------------------------------------------------------------
				
				
									-----------------------------------------------------------------------
			Write MMU				|                   |page|              |bank|  0 | en |    ph addr   |
									|---------------------------------------------------------------------|
			Read MMU				|                   |page|              |bank|  1 |                   |
									|---------------------------------------------------------------------|
			Write Logical Address	|                   |  logical address  |bank|  2 |    write data     |
									|---------------------------------------------------------------------|
			Read Logical Address	|                   |  logical address  |bank|  3 |                   |
									|---------------------------------------------------------------------|
			Write Physical Address	|         |  physical address           |    |  4 |    write data     |
									|---------------------------------------------------------------------|
			Read Physical Address	|         |  physical address           |    |  5 |                   |
									|---------------------------------------------------------------------|
			Global MMU Disable		|                                            |  6 |                   |
									|---------------------------------------------------------------------|
			Global MMU Enable		|                                            |  7 |                   |
									|---------------------------------------------------------------------|
			Disable Turbo Mode		|                                            |  8 |                   |
									|---------------------------------------------------------------------|
			Enable 2x Turbo Mode	|                                            |  9 |                   |
									|---------------------------------------------------------------------|
			Enable 5x Turbo Mode	|                                            |  A |                   |
									|---------------------------------------------------------------------|
			Enable 10x Turbo Mode	|                                            |  B |                   |
									|---------------------------------------------------------------------|
			Enable 20x Turbo Mode	|                                            |  C |                   |
									|---------------------------------------------------------------------|
			Enable 50x Turbo Mode	|                                            |  D |                   |
									|---------------------------------------------------------------------|
			Special MMU Disable		|                                            |  E |                   |
									|---------------------------------------------------------------------|
			Special MMU Enable		|                                            |  F |                   |
									-----------------------------------------------------------------------
			*/
			break
		
		default:
			/*
			RCR
			Rotate C right by digits
			=========================================================================================
			RCR													operand: none
										
			Operation: for (i=0; i<d; i++) begin
							C <= {C<0>, C<13:1>}
					   end
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			RCR d									dddd_1111_00							1
			=========================================================================================
			*/
			var temp = emptyDigit14
			copyDigits(reg.C, sourceStartAt: 0, destination: &temp, destinationStartAt: 0, count: param)
			copyDigits(reg.C, sourceStartAt: param, destination: &reg.C, destinationStartAt: 0, count: 14-param)
			copyDigits(temp, sourceStartAt: 0, destination: &reg.C, destinationStartAt: 14-param, count: param)
		}
	}
	
//---------------------------- Class 1 ---------------------------------------------
	
	func longJumpTo(addr: Int, withReturn push: Bool) {
		let address: Bits4 = Bits4(addr >> 12)
		if let rom = bus!.romChipInSlot(address) {
			if push {
				pushReturnStack(reg.PC)
			}
			
			// We do not jump to a NOP tyte
			if rom[Int(addr & 0xfff)] == 0 {
				return
			}
			
			reg.PC = Bits16(addr);
		}
	}

	func executeClass1(instr: Int) {
		let fetchResult = fetch()
		let word = Int(fetchResult.data)
		var addr = ((word & 0x3fc) << 6) | ((instr & 0x3fc) >> 2)
		if DEBUG != 0 {
			println("executeClass1: \(instr) - addr: \(addr) word: \(word & 0x3)")
		}
		switch (word & 0x3) {
		case 0:
			/*
			GSUBNC
			Branch (to Subroutine) on No Carry
			=========================================================================================
			GSUBNC												operand: jump address
			
			Operation: if CY begin
							STK3 <= STK2
							STK2 <= STK1
							STK1 <= STK0
							STK0 <= PC
							PC   <= jump_addr
					   end
			=========================================================================================
			Flag:     Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GSUBNC jump_addr						aaaa_aaaa_01							2
													aaaa_aaaa_00
			=========================================================================================
			Note: The first word of the instruction contains bits 7-0 of the jump address, and the
			second word of the instruction contains bits 15-8 of the jump address.
			
			The sync signal is suppressed during the fetch of the second word of the instruction to
			prevent external devices from incorrectly interpreting the contents of the isa_bus during
			the second machine cycle as an instruction.
			
			The PC pushed onto the return stack is the PC of the instruction following the second
			word of this instruction.
			
			If the instruction at jump_addr is NOP, it is automatically executed as RET to protect
			against executing from a non-existent ROM.
			*/
			if reg.carry == 0 {
				longJumpTo(addr, withReturn: true)
			}
			
		case 1:
			/*
			GSUBC
			Branch (to Subroutine) on Carry
			=========================================================================================
			GSUBC												operand: jump address
			
			Operation: if CY begin
							STK3 <= STK2
							STK2 <= STK1
							STK1 <= STK0
							STK0 <= PC
							PC   <= jump_addr
					   end
			=========================================================================================
			Flag:     Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GSUBC jump_addr							aaaa_aaaa_01							2
													aaaa_aaaa_01
			=========================================================================================
			Note: The first word of the instruction contains bits 7-0 of the jump address, and the
				  second word of the instruction contains bits 15-8 of the jump address.
			
			The sync signal is suppressed during the fetch of the second word of the instruction to
			prevent external devices from incorrectly interpreting the contents of the isa_bus during
			the second machine cycle as an instruction.
			
			The PC pushed onto the return stack is the PC of the instruction following the second
			word of this instruction.
			
			If the instruction at jump_addr is NOP, it is automatically executed as RET to protect
			against executing from a non-existent ROM.
			*/
			if reg.carry == 1 {
				longJumpTo(addr, withReturn: true)
			}
			
		case 2:
			/*
			GOLNC
			Branch (Long) on No Carry
			=========================================================================================
			GOLNC												operand: jump address
			
			Operation: if !CY (PC <= jump_addr)
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GOLNC jump_addr							aaaa_aaaa_01							2
													aaaa_aaaa_10
			=========================================================================================
			Note: The first word of the instruction contains bits 7-0 of the jump address, and the
				  second word of the instruction contains bits 15-8 of the jump address.
			
			The sync signal is suppressed during the fetch of the second word of the instruction to
			prevent external devices from incorrectly interpreting the contents of the isa_bus during
			the second machine cycle as an instruction.
			*/
			if reg.carry == 0 {
				longJumpTo(addr, withReturn: false)
			}
			
		case 3:
			/*
			GOLC
			Branch (Long) on Carry
			=========================================================================================
			GOLC												operand: jump address
			
			Operation: if CY (PC <= jump_addr)
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			GOLC jump_addr							aaaa_aaaa_01							2
													aaaa_aaaa_11
			=========================================================================================
			Note: The first word of the instruction contains bits 7-0 of the jump address, and the
				  second word of the instruction contains bits 15-8 of the jump address.
				
			The sync signal is suppressed during the fetch of the second word of the instruction to
			prevent external devices from incorrectly interpreting the contents of the isa_bus during
			the second machine cycle as an instruction.
			*/
			if reg.carry == 1 {
				longJumpTo(addr, withReturn: false)
			}
			
		default:
			unimplementedInstruction(instr)
		}
	}
	
	func executeClass2(instr: Int) {
		let opcode = (instr & 0x3e0) >> 5
		let field = (instr & 0x1c) >> 2
		var start = 0
		var cnt = 0
		var carry: Bit = 0
		var zero: Bit = 0
		var scratch = emptyDigit14
		if DEBUG != 0 {
			println("executeClass2: opcode: \(opcode) - field: \(field)")
		}
		switch field {
		case 0x0: // @R
			start = Int(regR())
			cnt = 1
		case 0x1: // S&X
			start = 0
			cnt = 3
		case 0x2: // R<
			start = 0
			cnt = Int(regR()) + 1
		case 0x3: // ALL
			start = 0
			cnt = 14
		case 0x4: // P-Q
			start = Int(reg.P);
			cnt = (Int(reg.Q) >= Int(reg.P)) ? Int(reg.Q) - Int(reg.P) + 1 : 14 - Int(reg.P);
		case 0x5: // XS
			start = 2
			cnt = 1
		case 0x6: // M
			start = 3
			cnt = 10
		case 0x7: // MS
			start = 13
			cnt = 1
		default:
			unimplementedInstruction(instr)
			return
		}
				
		switch opcode {
		case 0x00:
			/*
			A=0
			Clear A
			=========================================================================================
			A=0												operand: Time Enable Field
			
			Operation: A<time_enable_field> <= 0
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=0 TEF									0000_0TEF_10							1
			=========================================================================================
			*/
			fillDigits(&reg.A, value: 0, start: start, count: cnt)
			
		case 0x01:
			/*
			B=0
			Clear B
			=========================================================================================
			B=0												operand: Time Enable Field
				
			Operation: B<time_enable_field> <= 0
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			B=0 TEF									0000_1TEF_10							1
			=========================================================================================
			*/
			fillDigits(&reg.B, value: 0, start: start, count: cnt)
			
		case 0x02:
			/*
			C=0
			Clear C
			=========================================================================================
			C=0													operand: Time Enable Field
				
			Operation: C<time_enable_field> <= 0
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=0 TEF									0001_0TEF_10							1
			=========================================================================================
			*/
			fillDigits(&reg.C, value: 0, start: start, count: cnt)

		case 0x03:
			/*
			ABEX
			Exchange A and B
			=========================================================================================
			ABEX												operand: Time Enable Field
			
			Operation: fork
							A<time_enable_field> <= B<time_enable_field>
							B<time_enable_field> <= A<time_enable_field>
					   join
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ABEX TEF								0001_1TEF_10							1
			=========================================================================================
			*/
			var x = reg.A
			var y = reg.B
			exchangeDigits(X: &x, Y: &y, startPos: start, count: cnt)
			reg.A = x
			reg.B = y
			
		case 0x04:
			/*
			B=A
			Load B From A
			=========================================================================================
			B=A													operand: Time Enable Field
							
			Operation: B<time_enable_field> <= A<time_enable_field>
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			B=A TEF									0010_0TEF_10							1
			=========================================================================================
			*/
			copyDigits(reg.A, sourceStartAt: start, destination: &reg.B, destinationStartAt: start, count: cnt)

		case 0x05:
			/*
			ACEX
			Exchange A and C
			=========================================================================================
			ACEX												operand: Time Enable Field
					
			Operation: fork
							A<time_enable_field> <= C<time_enable_field>
							C<time_enable_field> <= A<time_enable_field>
					   join
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ACEX TEF								0010_1TEF_10							1
			=========================================================================================
			*/
			var x = reg.A
			var y = reg.C
			exchangeDigits(X: &x, Y: &y, startPos: start, count: cnt)
			reg.A = x
			reg.C = y

		case 0x06:
			/*
			C=B
			Load C From B
			=========================================================================================
			C=B													operand: Time Enable Field
				
			Operation: C<time_enable_field> <= B<time_enable_field>
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=B TEF									0011_0TEF_10							1
			=========================================================================================
			*/
			copyDigits(reg.B, sourceStartAt: start, destination: &reg.C, destinationStartAt: start, count: cnt)

		case 0x07: // C<>B
			/*
			BCEX
			Exchange B and C
			=========================================================================================
			BCEX												operand: Time Enable Field
				
			Operation: fork
							B<time_enable_field> <= C<time_enable_field>
							C<time_enable_field> <= B<time_enable_field>
					   join
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			BCEX TEF								0011_1TEF_10							1
			=========================================================================================
			*/
			var x = reg.B
			var y = reg.C
			exchangeDigits(X: &x, Y: &y, startPos: start, count: cnt)
			reg.B = x
			reg.C = y

		case 0x08:
			/*
			A=C
			Load A From C
			=========================================================================================
			A=C												operand: Time Enable Field
				
			Operation: A<time_enable_field> <= C<time_enable_field>
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=C TEF									0100_0TEF_10							1
			=========================================================================================
			*/
			copyDigits(reg.C, sourceStartAt: start, destination: &reg.A, destinationStartAt: start, count: cnt)

		case 0x09:
			/*
			A=A+B
			Load A With A + B
			=========================================================================================
			A=A+B											operand: Time Enable Field
				
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> + B<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A+B TEF								0100_1TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.B,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry

		case 0x0A:
			/*
			A=A+C
			Load A With A + C
			=========================================================================================
			A=A+C											operand: Time Enable Field
				
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> + C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A+C TEF								0101_0TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.C,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry;

		case 0x0B:
			/*
			A=A+1
			Increment A
			=========================================================================================
			A=A+1											operand: Time Enable Field
				
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> + 1
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A+1 TEF								0101_1TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: zeroes,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry;
			
		case 0x0C:
			/*
			A=A-B
			Load A With A - B
			=========================================================================================
			A=A-B											operand: Time Enable Field
			
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> - B<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A-B TEF								0110_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.B,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x0D: // A=A-1
			/*
			A=A-1
			Decrement A
			=========================================================================================
			A=A-1											operand: Time Enable Field
				
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> - 1
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A-1 TEF								0110_1TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: zeroes,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x0E:
			/*
			A=A-C
			Load A With A - C
			=========================================================================================
			A=A-C											operand: Time Enable Field
				
			Operation: {CY, A<time_enable_field>} <= A<time_enable_field> - C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			A=A-C TEF								0111_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.C,
				destination: &reg.A,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x0F:
			/*
			C=C+C
			Load C With C + C
			=========================================================================================
			C=C+C											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= C<time_enable_field> + C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=C+C TEF								0111_1TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.C,
				secondNum: reg.C,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry

		case 0x10:
			/*
			C=A+C
			Load C With A + C
			=========================================================================================
			C=A+C											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= A<time_enable_field> + C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=A+C TEF								1000_0TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.C,
				secondNum: reg.A,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry

		case 0x11:
			/*
			C=C+1
			Increment C
			=========================================================================================
			C=C+1											operand: Time Enable Field
				
			Operation: {CY, C<time_enable_field>} <= C<time_enable_field> + 1
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=C+1 TEF								1000_1TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .ADD,
				arithMode: reg.mode,
				firstNum: reg.C,
				secondNum: zeroes,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry

		case 0x12:
			/*
			C=A-C
			Load C With A - C
			=========================================================================================
			C=A-C											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= A<time_enable_field> - C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=A-C TEF								1001_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.C,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x13:
			/*
			C=C-1
			Decrement C
			=========================================================================================
			C=C-1											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= C<time_enable_field> + 1
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   Decimal adjusted in Decimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=C-1 TEF								1001_1TEF_10							1
			=========================================================================================
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.C,
				secondNum: zeroes,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x14:
			/*
			C=-C
			Negate C
			=========================================================================================
			C=C-1											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= 0 - C<time_enable_field>
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   10’s complement in Decimal Mode, 16’s complement in Hexadecimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=-C TEF								1010_0TEF_10							1
			=========================================================================================
			Note: This is the arithmetic complement, or the value subtracted from zero.
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: zeroes,
				secondNum: reg.C,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x15:
			/*
			C=-C-1
			Complement C
			=========================================================================================
			C=-C-1											operand: Time Enable Field
			
			Operation: {CY, C<time_enable_field>} <= 0 - C<time_enable_field> - 1
			=========================================================================================
			Flag:      Set/Cleared as a result of the operation
			=========================================================================================
			Dec/Hex:   9’s complement in Decimal Mode, 15’s complement in Hexadecimal Mode
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			C=-C-1 TEF								1010_1TEF_10							1
			=========================================================================================
			Note: This is the logical complement, which is the same as subtracting the value from
				  negative one.
			*/
			carry = 0
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: zeroes,
				secondNum: reg.C,
				destination: &reg.C,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0
			
		case 0x16:
			/*
			?B#0
			Test B Equal To Zero
			=========================================================================================
			?B#0											operand: Time Enable Field
				
			Operation: CY <= (B<time_enable_field> != 0)
			=========================================================================================
			Flag:      Set if B is not zero at any time during the Time Enable Field;
					   cleared otherwise.
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?B#0 TEF								1011_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.B,
				secondNum: zeroes,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = zero == 0 ? 1 : 0

		case 0x17:
			/*
			?C#0
			Test C Equal To Zero
			=========================================================================================
			?C#0											operand: Time Enable Field
	
			Operation: CY <= (C<time_enable_field> != 0)
			=========================================================================================
			Flag:      Set if C is not zero at any time during the Time Enable Field;
					   cleared otherwise
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?C#0 TEF								1011_1TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.C,
				secondNum: zeroes,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = zero == 0 ? 1 : 0

		case 0x18:
			/*
			?A<C
			Test A Less Than C
			=========================================================================================
			?A<C											operand: Time Enable Field
	
			Operation: CY <= (A<time_enable_field> < C<time_enable_field>)
			=========================================================================================
			Flag:      Set if A is less than C, for the bits during the Time Enable Field;
					   cleared otherwise
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?A<C TEF								1100_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.C,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x19:
			/*
			?A<B
			Test A Less Than B
			=========================================================================================
			?A<B											operand: Time Enable Field

			Operation: CY <= (A<time_enable_field> < B<time_enable_field>)
			=========================================================================================
			Flag:      Set if A is less than B, for the bits during the Time Enable Field;
					   cleared otherwise
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?A<B TEF								1100_1TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.B,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = carry == 0 ? 1 : 0

		case 0x1A:
			/*
			?A#0
			Test A Not Equal To Zero
			=========================================================================================
			?A#0											operand: Time Enable Field
	
			Operation: CY <= (A<time_enable_field> != 0)
			=========================================================================================
			Flag:      Set if A is not zero at any time during the Time Enable Field;
					   cleared otherwise.
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?A#0 TEF								1101_0TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: zeroes,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = zero == 0 ? 1 : 0

		case 0x1B:
			/*
			?A#C
			Test A Not Equal To C
			=========================================================================================
			?A#C											operand: Time Enable Field
	
			Operation: CY <= (A<time_enable_field> != C<time_enable_field>)
			=========================================================================================
			Flag:      Set if A is not equal to C at any time during the Time Enable Field;
					   cleared otherwise.
			=========================================================================================
			Dec/Hex:   Independent
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			?A#C TEF								1101_1TEF_10							1
			=========================================================================================
			*/
			carry = 1
			addOrSubtractDigits(
				arithOp: .SUB,
				arithMode: reg.mode,
				firstNum: reg.A,
				secondNum: reg.C,
				destination: &scratch,
				from: start,
				count: cnt,
				carry: &carry,
				zero: &zero
			)
			nextCarry = zero == 0 ? 1 : 0

		case 0x1C:
			/*
			ASR
			Shift Right A
			=========================================================================================
			ASR												operand: Time Enable Field
			
			Operation: A<time_enable_field> <= A<time_enable_field> >> 1
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent (no decimal adjust)
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ASR TEF									1110_0TEF_10							1
			=========================================================================================
			Note: Zero is shifted into the most-significant (time-enabled) digit.
			*/
			reg.A = shiftDigitsRight(X: reg.A, start: start, count: cnt)

		case 0x1D:
			/*
			BSR
			Shift Right B
			=========================================================================================
			BSR												operand: Time Enable Field
	
			Operation: B<time_enable_field> <= B<time_enable_field> >> 1
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent (no decimal adjust)
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			BSR TEF									1110_1TEF_10							1
			=========================================================================================
			Note: Zero is shifted into the most-significant (time-enabled) digit.
			*/
			reg.B = shiftDigitsRight(X: reg.B, start: start, count: cnt)

		case 0x1E:
			/*
			CSR
			Shift Right C
			=========================================================================================
			CSR												operand: Time Enable Field
	
			Operation: C<time_enable_field> <= C<time_enable_field> >> 1
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent (no decimal adjust)
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			CSR TEF									1111_0TEF_10							1
			=========================================================================================
			Note: Zero is shifted into the most-significant (time-enabled) digit.
			*/
			reg.C = shiftDigitsRight(X: reg.C, start: start, count: cnt)

		case 0x1F:
			/*
			ASL
			Shift Left A
			=========================================================================================
			ASL												operand: Time Enable Field

			Operation: A<time_enable_field> <= A<time_enable_field> << 1
			=========================================================================================
			Flag:      Cleared
			=========================================================================================
			Dec/Hex:   Independent (no decimal adjust)
			Turbo:     Independent
			=========================================================================================
			Assembly Syntax							Encoding						Machine Cycles
			-----------------------------------------------------------------------------------------
			ASL TEF									1111_1TEF_10							1
			=========================================================================================
			Note: Zero is shifted into the least-significant (time-enabled) digit.
			*/
			reg.A = shiftDigitsLeft(X: reg.A, start: start, count: cnt)

		default:
			unimplementedInstruction(instr)
		}
	}
	
	func executeClass3(instr: Int) {
		println("executeClass3: \(instr)")
		let v = ((instr >> 2) & 1)
		var disp = instr >> 3
		if disp >= 64 {
			disp = disp - 128
		}
		if Bit(v) == reg.carry {
			reg.PC = (reg.PC - 1 + disp) & 0xffff
		}
	}
	
	func digits14ToString(register: Digits14) -> String {
		var result = String()
		for idx in reverse(0...13) {
			result += NSString(format:"%1X", register[idx])
		}
		
		return result
	}
	
	func bits4ToString(register: Bits4) -> String {
		return NSString(format:"%1X", register)
	}
}
