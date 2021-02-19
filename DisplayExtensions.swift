//
//  DisplayExtensions.swift
//  my41
//
//  Created by Miroslav Perovic on 2/14/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import CoreGraphics

typealias Digits12 = [Digit]
typealias DisplaySegmentMap = UInt32

let emptyDigit12:[Digit] = [Digit](repeating: 0, count: 12)

let annunciatorStrings: [String] = ["BAT  ", "USER  ", "G", "RAD  ", "SHIFT  ", "0", "1", "2", "3", "4  ", "PRGM  ", "ALPHA"]
let CTULookupRsrcName = "display"
let CTULookupRsrcType = "lookup"
var CTULookup: String?					// lookup table hardware character index -> unichar
var CTULookupLength: Int?				// actual lookup table length (file size)

let punctSegmentTable: [DisplaySegmentMap] = [
	0x00000, // no punctuation
	0x08000, // .
	0x0C000, // :
	0x18000, // ,
	0x1C000  // ;  (only used during startup segment test)
]

struct DisplayRegisters {
	var A: Digits12 = emptyDigit12
	var B: Digits12 = emptyDigit12
	var C: Digits12 = emptyDigit12
	var E: Bits12 = 0
}

extension Display {	
	enum DisplayShiftDirection {
		case left
		case right
	}
	
	enum DisplayTransitionSize {
		case short
		case long
	}
	
	enum DisplayRegisterSet : Int {
		case ra = 1
		case rb = 2
		case rc = 4
		case rab = 3
		case rabc = 7
	}
	
	//MARK: - Registers manipulation
	
	func readFromRegister(_ param: Bits4) {
		// Implement READ f or READ DATA instruction with display as selected peripheral.
		switch param {
		case 0x0:	//FLLDA
			displayFetch(&registers, withDirection: .left, andSize: .long, withRegister: .ra, andData: &cpu.reg.C)
		case 0x1:	// FLLDB
			displayFetch(&registers, withDirection: .left, andSize: .long, withRegister: .rb, andData: &cpu.reg.C)
		case 0x2:	// FLLDC
			displayFetch(&registers, withDirection: .left, andSize: .long, withRegister: .rc, andData: &cpu.reg.C)
		case 0x3:	// FLLDAB
			displayFetch(&registers, withDirection: .left, andSize: .long, withRegister: .rab, andData: &cpu.reg.C)
		case 0x4:	// FLLABC
			displayFetch(&registers, withDirection: .left, andSize: .long, withRegister: .rabc, andData: &cpu.reg.C)
		case 0x5:	// READDEN
			bitsToDigits(bits: Int(registers.E), destination: &cpu.reg.C, start: 0, count: 4)
			return					// doesn't change display
		case 0x6:	// FLSDC
			displayFetch(&registers, withDirection: .left, andSize: .short, withRegister: .ra, andData: &cpu.reg.C)
		case 0x7:	// FRSDA
			displayFetch(&registers, withDirection: .right, andSize: .short, withRegister: .ra, andData: &cpu.reg.C)
		case 0x8:	// FRSDB
			displayFetch(&registers, withDirection: .right, andSize: .short, withRegister: .rb, andData: &cpu.reg.C)
		case 0x9:	// FRSDC
			displayFetch(&registers, withDirection: .right, andSize: .short, withRegister: .rc, andData: &cpu.reg.C)
		case 0xA:	// FLSDA
			displayFetch(&registers, withDirection: .left, andSize: .short, withRegister: .ra, andData: &cpu.reg.C) // Original: .RB
		case 0xB:	// FLSDB
			displayFetch(&registers, withDirection: .left, andSize: .short, withRegister: .rb, andData: &cpu.reg.C)
		case 0xC:	// FRSDAB
			displayFetch(&registers, withDirection: .right, andSize: .short, withRegister: .rab, andData: &cpu.reg.C)
		case 0xD:	// FLSDAB
			displayFetch(&registers, withDirection: .left, andSize: .short, withRegister: .rab, andData: &cpu.reg.C)
		case 0xE:	// FRSABC
			displayFetch(&registers, withDirection: .right, andSize: .short, withRegister: .rabc, andData: &cpu.reg.C)
		case 0xF:	// FLSABC
			displayFetch(&registers, withDirection: .left, andSize: .short, withRegister: .rabc, andData: &cpu.reg.C)
		default:
			bus.abortInstruction("Unimplemented display operation")
		}
		scheduleUpdate()
	}
	
	func writeToRegister(_ param: Bits4) {
		// Implement WRITE f instruction with display as selected peripheral.
		switch param {
		case 0x0:	// SRLDA
			shift(&registers, withDirection: .right, andSize: .long, withRegister: .ra, andData: &cpu.reg.C)
		case 0x1:	// SRLDB
			shift(&registers, withDirection: .right, andSize: .long, withRegister: .rb, andData: &cpu.reg.C)
		case 0x2:	// SRLDC
			shift(&registers, withDirection: .right, andSize: .long, withRegister: .rc, andData: &cpu.reg.C)
		case 0x3:	// SRLDAB
			shift(&registers, withDirection: .right, andSize: .long, withRegister: .rab, andData: &cpu.reg.C)
		case 0x4:	// SRLABC
			shift(&registers, withDirection: .right, andSize: .long, withRegister: .rabc, andData: &cpu.reg.C)
		case 0x5:	// SLLDAB
			shift(&registers, withDirection: .left, andSize: .short, withRegister: .rab, andData: &cpu.reg.C)
		case 0x6:	// SLLABC
			shift(&registers, withDirection: .left, andSize: .long, withRegister: .rabc, andData: &cpu.reg.C)
		case 0x7:	// SRSDA
			shift(&registers, withDirection: .right, andSize: .short, withRegister: .ra, andData: &cpu.reg.C)
		case 0x8:	// SRSDB
			shift(&registers, withDirection: .right, andSize: .short, withRegister: .rb, andData: &cpu.reg.C)
		case 0x9:	// SRSDC
			shift(&registers, withDirection: .right, andSize: .short, withRegister: .rc, andData: &cpu.reg.C)
		case 0xA:	// SLSDA
			shift(&registers, withDirection: .left, andSize: .short, withRegister: .ra, andData: &cpu.reg.C)
		case 0xB:	// SLSDB
			shift(&registers, withDirection: .left, andSize: .short, withRegister: .rb, andData: &cpu.reg.C)
		case 0xC:	// SRSDAB
			shift(&registers, withDirection: .right, andSize: .short, withRegister: .rab, andData: &cpu.reg.C)
		case 0xD:	// SLSDAB
			shift(&registers, withDirection: .left, andSize: .short, withRegister: .rab, andData: &cpu.reg.C)
		case 0xE:	// SRSABC
			shift(&registers, withDirection: .right, andSize: .short, withRegister: .rabc, andData: &cpu.reg.C)
		case 0xF:	// SLSABC
			shift(&registers, withDirection: .left, andSize: .short, withRegister: .rabc, andData: &cpu.reg.C)
		default:
			bus.abortInstruction("Unimplemented display operation")
		}
		scheduleUpdate()
	}
	
	func displayWrite()
	{
		switch cpu.opcode.row() {
		case 0x0:
			// 028          SRLDA    WRA12L   SRLDA
			registers.A[0] = cpu.reg.C[0]
			registers.A[1] = cpu.reg.C[1]
			registers.A[2] = cpu.reg.C[2]
			registers.A[3] = cpu.reg.C[3]
			registers.A[4] = cpu.reg.C[4]
			registers.A[5] = cpu.reg.C[5]
			registers.A[6] = cpu.reg.C[6]
			registers.A[7] = cpu.reg.C[7]
			registers.A[8] = cpu.reg.C[8]
			registers.A[9] = cpu.reg.C[9]
			registers.A[10] = cpu.reg.C[10]
			registers.A[11] = cpu.reg.C[11]
		case 0x1:
			// 068          SRLDB    WRB12L   SRLDB
			registers.B[0] = cpu.reg.C[0]
			registers.B[1] = cpu.reg.C[1]
			registers.B[2] = cpu.reg.C[2]
			registers.B[3] = cpu.reg.C[3]
			registers.B[4] = cpu.reg.C[4]
			registers.B[5] = cpu.reg.C[5]
			registers.B[6] = cpu.reg.C[6]
			registers.B[7] = cpu.reg.C[7]
			registers.B[8] = cpu.reg.C[8]
			registers.B[9] = cpu.reg.C[9]
			registers.B[10] = cpu.reg.C[10]
			registers.B[11] = cpu.reg.C[11]
		case 0x2:
			// 0A8          SRLDC    WRC12L   SRLDC
			registers.C[0] = cpu.reg.C[0]
			registers.C[1] = cpu.reg.C[1]
			registers.C[2] = cpu.reg.C[2]
			registers.C[3] = cpu.reg.C[3]
			registers.C[4] = cpu.reg.C[4]
			registers.C[5] = cpu.reg.C[5]
			registers.C[6] = cpu.reg.C[6]
			registers.C[7] = cpu.reg.C[7]
			registers.C[8] = cpu.reg.C[8]
			registers.C[9] = cpu.reg.C[9]
			registers.C[10] = cpu.reg.C[10]
			registers.C[11] = cpu.reg.C[11]
		case 0x3:
			// 0E8          SRLDAB   WRAB6L   SRLDAB
			rotateDisplayRegisterLeft(&registers.A, times: 6)
			rotateDisplayRegisterLeft(&registers.B, times: 6)
			registers.A[6] = cpu.reg.C[0]
			registers.B[6] = cpu.reg.C[1]
			registers.A[7] = cpu.reg.C[2]
			registers.B[7] = cpu.reg.C[3]
			registers.A[8] = cpu.reg.C[4]
			registers.B[8] = cpu.reg.C[5]
			registers.A[9] = cpu.reg.C[6]
			registers.B[9] = cpu.reg.C[7]
			registers.A[10] = cpu.reg.C[8]
			registers.B[10] = cpu.reg.C[9]
			registers.A[11] = cpu.reg.C[10]
			registers.B[11] = cpu.reg.C[11]
		case 0x4:
			// 128          SRLABC   WRABC4L  SRLABC                       ;also HP:SRLDABC
			rotateDisplayRegisterLeft(&registers.A, times: 4)
			rotateDisplayRegisterLeft(&registers.B, times: 4)
			rotateDisplayRegisterLeft(&registers.C, times: 4)
			registers.A[8] = cpu.reg.C[0]
			registers.B[8] = cpu.reg.C[1]
			registers.C[8] = cpu.reg.C[2] & 0x01
			registers.A[9] = cpu.reg.C[3]
			registers.B[9] = cpu.reg.C[4]
			registers.C[9] = cpu.reg.C[5] & 0x01
			registers.A[10] = cpu.reg.C[6]
			registers.B[10] = cpu.reg.C[7]
			registers.C[10] = cpu.reg.C[8] & 0x01
			registers.A[11] = cpu.reg.C[9]
			registers.B[11] = cpu.reg.C[10]
			registers.C[11] = cpu.reg.C[11] & 0x01
		case 0x5:
			// 168          SLLDAB   WRAB6R   SLLDAB
			rotateDisplayRegisterRight(&registers.A, times: 6)
			rotateDisplayRegisterRight(&registers.B, times: 6)
			registers.A[5] = cpu.reg.C[0]
			registers.B[5] = cpu.reg.C[1]
			registers.A[4] = cpu.reg.C[2]
			registers.B[4] = cpu.reg.C[3]
			registers.A[3] = cpu.reg.C[4]
			registers.B[3] = cpu.reg.C[5]
			registers.A[2] = cpu.reg.C[6]
			registers.B[1] = cpu.reg.C[7]
			registers.A[1] = cpu.reg.C[8]
			registers.B[1] = cpu.reg.C[9]
			registers.A[0] = cpu.reg.C[10]
			registers.B[0] = cpu.reg.C[11]
		case 0x6:
			// 1A8          SLLABC   WRABC4R  SLLABC                       ;also HP:SLLDABC
			rotateDisplayRegisterRight(&registers.A, times: 4)
			rotateDisplayRegisterRight(&registers.B, times: 4)
			rotateDisplayRegisterRight(&registers.C, times: 4)
			registers.A[3] = cpu.reg.C[0]
			registers.B[3] = cpu.reg.C[1]
			registers.C[3] = cpu.reg.C[2] & 0x01
			registers.A[2] = cpu.reg.C[3]
			registers.B[2] = cpu.reg.C[4]
			registers.C[2] = cpu.reg.C[5] & 0x01
			registers.A[1] = cpu.reg.C[6]
			registers.B[1] = cpu.reg.C[7]
			registers.C[1] = cpu.reg.C[8] & 0x01
			registers.A[0] = cpu.reg.C[9]
			registers.B[0] = cpu.reg.C[10]
			registers.C[0] = cpu.reg.C[11] & 0x01
		case 0x7:
			// 1E8          SRSDA    WRA1L    SRSDA
			rotateDisplayRegisterLeft(&registers.A, times: 1)
			registers.A[11] = cpu.reg.C[0]
		case 0x8:
			// 228          SRSDB    WRB1L    SRSDB
			rotateDisplayRegisterLeft(&registers.B, times: 1)
			registers.B[11] = cpu.reg.C[0]
		case 0x9:
			// 268          SRSDC    WRC1L    SRSDC
			rotateDisplayRegisterLeft(&registers.C, times: 1)
			registers.C[11] = cpu.reg.C[0] & 0x01
		case 0xa:
			// 2A8          SLSDA    WRA1R    SLSDA
			rotateDisplayRegisterRight(&registers.A, times: 1)
			registers.A[0] = cpu.reg.C[0]
		case 0xb:
			// 2E8          SLSDB    WRB1R    SLSDB
			rotateDisplayRegisterRight(&registers.B, times: 1)
			registers.B[0] = cpu.reg.C[0]
		case 0xc:
			// 328          SRSDAB   WRAB1L   SRSDAB                        ;Zenrom manual incorrectly says this is WRC1R
			rotateDisplayRegisterLeft(&registers.A, times: 1)
			rotateDisplayRegisterLeft(&registers.B, times: 1)
			registers.A[11] = cpu.reg.C[0]
			registers.B[11] = cpu.reg.C[1]
		case 0xd:
			// 368          SLSDAB   WRAB1R   SLSDAB
			rotateDisplayRegisterRight(&registers.A, times: 1)
			rotateDisplayRegisterRight(&registers.B, times: 1)
			registers.A[0] = cpu.reg.C[0]
			registers.B[0] = cpu.reg.C[1]
		case 0xe:
			// 3A8          SRSABC   WRABC1L  SRSABC                        ;also HP:SRSDABC
			rotateDisplayRegisterLeft(&registers.A, times: 1)
			rotateDisplayRegisterLeft(&registers.B, times: 1)
			rotateDisplayRegisterLeft(&registers.C, times: 1)
			registers.A[11] = cpu.reg.C[0]
			registers.B[11] = cpu.reg.C[1]
			registers.C[11] = cpu.reg.C[2] & 0x01
		case 0xf:
			// 3E8          SLSABC   WRABC1R  SLSABC                        ;also HP:SLSDABC
			rotateDisplayRegisterRight(&registers.A, times: 1)
			rotateDisplayRegisterRight(&registers.B, times: 1)
			rotateDisplayRegisterRight(&registers.C, times: 1)
			registers.A[0] = cpu.reg.C[0]
			registers.B[0] = cpu.reg.C[1]
			registers.C[0] = cpu.reg.C[2] & 0x01
		default:
			break
		}
		
		scheduleUpdate()
	}
	
	func displayFetch(
		_ registers: inout DisplayRegisters,
		withDirection direction:DisplayShiftDirection,
		andSize size:DisplayTransitionSize,
		withRegister regset:DisplayRegisterSet,
		andData data: inout Digits14
		)
	{
		/*
			Fetch digits from the specified registers, rotating them in the specified direction,
			and assemble them into the specified destination.
			For size == LONG, fetches a total of 12 digits into the destination;
			for size == SHORT, fetches one digit from each specified register.
		*/
		var cp = 0
		while cp < 12 {
			if (regset.rawValue & DisplayRegisterSet.ra.rawValue) != 0 {
				fetchDigit(direction, from: &registers.A, to: &data[cp])
				cp += 1
			}
			if (regset.rawValue & DisplayRegisterSet.rb.rawValue) != 0 {
				fetchDigit(direction, from: &registers.B, to: &data[cp])
				cp += 1
			}
			if (regset.rawValue & DisplayRegisterSet.rc.rawValue) != 0 {
				fetchDigit(direction, from: &registers.C, to: &data[cp])
				cp += 1
			}
			if size == .short {
				break
			}
		}
	}

	@discardableResult
	func fetchDigit(
		_ direction: DisplayShiftDirection,
		from register: inout Digits12,
		to dst: inout Digit
		) -> Digits12
	{
		/*
			Fetch a digit from the appropriate end of the given register into the specified destination,
			and rotate the register in the specified direction.
		*/
		switch direction {
		case .left:
			dst = register[11]
			rotateRegisterLeft(&register)
		case .right:
			dst = register[0]
			rotateRegisterRight(&register)
		}
		
		return register
	}
	
	func rotateRegisterLeft(_ register: inout Digits12)
	{
		let temp = register[11]
		for idx in Array((1...11).reversed()) {
			register[idx] = register[idx - 1]
		}
		register[0] = temp
	}
	
	func rotateDisplayRegisterLeft(_ register: inout Digits12, times: Int) {
		if times > 0 {
			for _ in 0..<times {
				let temp = register[0]
				for idx in 0...10 {
					register[idx] = register[idx + 1]
				}
				register[11] = temp
			}
		}
	}
	
	func rotateRegisterRight(_ register: inout Digits12) {
		let temp = register[0]
		for idx in 0...10 {
			register[idx] = register[idx + 1]
		}
		register[11] = temp
	}
	
	func rotateDisplayRegisterRight(_ register: inout Digits12, times: Int)
	{
		if times > 0 {
			for _ in 0..<times {
				let temp = register[11]
				for idx in Array((1...11).reversed()) {
					register[idx] = register[idx - 1]
				}
				register[0] = temp
			}
		}
	}

	
	//MARK: -
	
	func shift(
		_ registers: inout DisplayRegisters,
		withDirection direction:DisplayShiftDirection,
		andSize size:DisplayTransitionSize,
		withRegister regset:DisplayRegisterSet,
		andData data: inout Digits14
		)
	{
		/*
			Distribute digits from the given source and rotate them into the specified registers.
			For size == LONG, shifts a total of 12 digits from the source;
			for size == SHORT, shifts one digit into each specified register.
		*/
		var cp = 0
		while cp < 12 {
			if (regset.rawValue & DisplayRegisterSet.ra.rawValue) != 0 {
				shiftDigit(direction, from: &registers.A, withFilter: data[cp])
				cp += 1
			}
			if (regset.rawValue & DisplayRegisterSet.rb.rawValue) != 0 {
				shiftDigit(direction, from: &registers.B, withFilter: data[cp])
				cp += 1
			}
			if (regset.rawValue & DisplayRegisterSet.rc.rawValue) != 0 {
				shiftDigit(direction, from: &registers.C, withFilter: data[cp])
				cp += 1
			}
			if size == .short {
				break
			}
		}
	}
	
	func shiftDigit(_ direction: DisplayShiftDirection, from register: inout Digits12, withFilter src: Digit) {
		// Rotate the given digit into the specified register in the specified direction.
		switch direction {
		case .left:
			rotateRegisterLeft(&register)
			register[0] = src
		case .right:
			rotateRegisterRight(&register)
			register[11] = src
		}
	}
	
	func segmentsForCell(_ i: Int) -> DisplaySegmentMap {
		/*
			Determine which segments should be on for cell i based on the contents of the display registers.
			Note that cells are numbered from left to right, which is the opposite of the digit numbering in the display registers.
		*/
		let j = 11 - i
		let nineBitCode: Int = Int((Int(registers.C[j]) << 8) | (Int(registers.B[j]) << 4) | (Int(registers.A[j]))) & 0x1ff
		let charCode: Int = ((nineBitCode & 0x100) >> 2) | (nineBitCode & 0x3f)
		let punctCode = Int((Int(registers.C[j]) & 0x2) << 1) | (nineBitCode & 0xc0) >> 6
		
		return displayFont[Int(charCode)] | punctSegmentTable[Int(punctCode)]
	}
	
	func annunciatorOn(_ i: Int) -> Bool {
		/*
			Determine whether annunciator number i should be on based on the contents of the E register.
			Note that i is not the same as the bit number in E, because the annunciators are numbered from left to right.
		*/
		let j: Bits12 = 11 - Bits12(i)
		
		return (registers.E & (1 << j)) != 0
	}
	
	func scheduleUpdate() {
		updateCountdown = 2
	}
	
	func displayToggle() {
		// Toggle the display between on and off.
		on = !on
		scheduleUpdate()
	}
	
	func displayOff() {
		if on {
			on = false
			scheduleUpdate()
		}
	}
	
	func cellWidth() -> CGFloat {
		return self.bounds.size.width / CGFloat(numDisplayCells)
	}
	
	// Read the current content of the display as an String:
	// Reads the actual hardware registers and converts the content to a normalized
	// unicode string (suppressing leading and trailing spaces).
	func readDisplayAsText() -> String {
		// access the hardware display registers A, B, C:
		let r  = registers
		
		// we need up to two characters per display cell (character+punctuation):
		var text: String = ""
		
		// prepare the punctuation lookup table (8 characters for 3 bit punctuation code)
		let punct: String = " .:,;???"
		
		// loop through the display cells and translate their content:
		for idx in Array((0...numDisplayCells-1).reversed()) {
			// assemble the actual hardware character index from the register bits:
			// charCode = C0 B1 B0  A3 A2 A1 A0
			let charCode = ((r.C[idx] & 0x1) << 6) | ((r.B[idx] & 0x3) << 4) | (r.A[idx] & 0xf)
			
			// if valid, look up unicode for X-41 hardware character index:
			if charCode < UInt8(CTULookupLength!) {
				// translate:
				let aChar: Character = CTULookup![Int(charCode)]
				let scalars = String(aChar).unicodeScalars
				
				// only if we already have some valid characters or if this one is valid:
				if scalars[scalars.startIndex].value != 0x20 {
					// not a leading space: save
					text.append(aChar)
				}
			}
			
			let punctCode = ((r.C[idx] & 0x2) << 1) | ((r.B[idx] & 0xc) >> 2)
			
			// if there is any punctuation, insert the respective character from the table:
			if punctCode != 0 {
				text.append(punct[Int(punctCode)])
			}
		}
		
		// now return the completed string as an NSString without any trailing spaces:
		return text
	}
	
	func timeSlice(_ timer: Foundation.Timer) {
		if (updateCountdown > 0) {
			updateCountdown -= 1
			if (updateCountdown == 0) {
				setNeedsDisplay(self.bounds)
			}
		}
	}
	
	//MARK: - Halfnut
	func halfnutWrite()
	{
		// REG=C 5
		if cpu.opcode.row() == 5 {
			contrast = cpu.reg.C[0]
		}
	}
	
	func halfnutRead() {
		if cpu.opcode.row() == 5 {
			cpu.reg.C[0] = contrast
		}
	}
	
	func digits12ToString(_ register: Digits12) -> String {
		var result = String()
		for idx in Array((0...11).reversed()) {
			result += NSString(format:"%1X", register[idx]) as String
		}
		
		return result
	}
	
	
	//MARK: - Font support
	
	func loadFont(_ resourceName: String) -> DisplayFont {
		var font: DisplayFont = DisplayFont(repeating: 0, count: 128)
		let filename = Bundle.main.path(forResource: resourceName, ofType: "hpfont")
		var data: Data?
		do {
			data = try Data(contentsOf: URL(fileURLWithPath: filename!), options: [.mappedIfSafe])
		} catch _ {
			data = nil
		}
//		var range = NSRange(location: 0, length: 4)
		var location = 0
		for idx in 0..<127 {
			var tmp: UInt32 = 0
			var tmp2: UInt32 = 0
			let buffer = UnsafeMutableBufferPointer(start: &tmp, count: 4)
			let _ = data?.copyBytes(to: buffer, from: location..<location+4)
//			data?.getBytes(&tmp, range: range)
			location += 4
			tmp2 = UInt32(bigEndian: tmp)
			
			font[idx] = tmp2
		}
		
		return font
	}
	
	
	//MARK: - Peripheral Protocol Method
	
	func pluggedIntoBus(_ theBus: Bus?) {
//		self.aBus = theBus
	}
	
	func writeDataFrom(_ data: Digits14) {
		// Implement WRITE DATA instruction with display as selected peripheral.
		registers.E = digitsToBits(digits: data, nbits: 12)
		scheduleUpdate()
	}
}
