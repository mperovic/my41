 //
//  CPU.swift
//  my41
//
//  Created by Miroslav Perovic on 8/8/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

typealias Digit = UInt8
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

struct Digits14: Codable {
	var digits = [Digit](repeating: 0, count: 14)

	subscript(_ position: Int) -> Digit {
		get {
			guard position < 14 else { fatalError("Out of range") }

			return digits[position]
		}
		set {
			guard position < 14 else { fatalError("Out of range") }

			digits[position] = newValue
		}
	}
}

final class CPURegisters: Codable {
	var A = Digits14()
	var B = Digits14()
	var C = Digits14()
	var M = Digits14()
	var N = Digits14()
	var P: Bits4			= 0
	var Q: Bits4			= 0
	var PC: Bits16			= 0 {
		willSet(newValue) {
			let page = Int((newValue & 0xf000) >> 12)
			let activeBank = bus.activeBank[page]
			if let romChip = bus.romChips[page][activeBank - 1] {
				cpu.currentPage = page
				cpu.currentRomChip = romChip
			} else {
				cpu.currentPage = 0
				cpu.currentRomChip = bus.romChips[cpu.currentPage][bus.activeBank[cpu.currentPage]]
			}
		}
	}
	var G: [Digit]			= [0, 0]
	var ST: Bits8			= 0
	var T: Bits8			= 0
	var FI: Bits14			= 0
	var KY: Bits8			= 0
	var XST: Bits6			= 0
	var stack: [Bits16]		= [Bits16](repeating: 0, count: 4)
	var R: Bit				= 0 {										// Active pointer
		didSet {
			if R > 1 {
				R = 1
			}
		}
	}
	var carry: Bit			= 0
	var mode: ArithMode		= .dec_mode									// DEC_MODE or HEX_MODE
	var ramAddress: Bits12	= 0											// Selected ram address
	var peripheral: Bits8	= 0											// Selected peripheral
	var keyDown: Bit		= 0											// Set if a key is being held down
	
	let dis: Disassembly = Disassembly()

	enum CodingKeys: String, CodingKey {
		case A
		case B
		case C
		case M
		case N
		case P
		case Q
		case PC
		case G
		case ST
		case T
		case FI
		case KY
		case XST
		case stack
		case R
		case carry
		case mode
		case ramAddress
		case peripheral
	}

	init() {
		//
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		A = try values.decode(Digits14.self, forKey: .A)
		B = try values.decode(Digits14.self, forKey: .B)
		C = try values.decode(Digits14.self, forKey: .C)
		M = try values.decode(Digits14.self, forKey: .M)
		N = try values.decode(Digits14.self, forKey: .N)
		P = try values.decode(Bits4.self, forKey: .P)
		Q = try values.decode(Bits4.self, forKey: .Q)
		PC = try values.decode(Bits16.self, forKey: .PC)
		G = try values.decode([Digit].self, forKey: .G)
		ST = try values.decode(Bits8.self, forKey: .ST)
		T = try values.decode(Bits8.self, forKey: .T)
		FI = try values.decode(Bits14.self, forKey: .FI)
		KY = try values.decode(Bits8.self, forKey: .KY)
		XST = try values.decode(Bits6.self, forKey: .XST)
		stack = try values.decode([Bits16].self, forKey: .stack)
		R = try values.decode(Bit.self, forKey: .R)
		carry = try values.decode(Bit.self, forKey: .carry)
		mode = try values.decode(ArithMode.self, forKey: .mode)
		ramAddress = try values.decode(Bits12.self, forKey: .ramAddress)
		peripheral = try values.decode(Bits8.self, forKey: .peripheral)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(A, forKey: .A)
		try container.encode(B, forKey: .B)
		try container.encode(C, forKey: .C)
		try container.encode(M, forKey: .M)
		try container.encode(N, forKey: .N)
		try container.encode(P, forKey: .P)
		try container.encode(Q, forKey: .Q)
		try container.encode(PC, forKey: .PC)
		try container.encode(G, forKey: .G)
		try container.encode(ST, forKey: .ST)
		try container.encode(T, forKey: .T)
		try container.encode(FI, forKey: .FI)
		try container.encode(KY, forKey: .KY)
		try container.encode(XST, forKey: .XST)
		try container.encode(stack, forKey: .stack)
		try container.encode(R, forKey: .R)
		try container.encode(carry, forKey: .carry)
		try container.encode(mode, forKey: .mode)
		try container.encode(ramAddress, forKey: .ramAddress)
		try container.encode(peripheral, forKey: .peripheral)
	}

	func description() {
		let stack0 = NSString(format:"%04X", stack[0]) as String
		let stack1 = NSString(format:"%04X", stack[1]) as String
		let stack2 = NSString(format:"%04X", stack[2]) as String
		let stack3 = NSString(format:"%04X", stack[3]) as String
		var pointP = " "
		var pointQ = " "
		if R == 0 {
			pointP = " >"
		} else {
			pointQ = " >"
		}
		let ramAddr = NSString(format:"%03X", ramAddress) as String
		let periph = NSString(format:"%02X", peripheral) as String
		let strST = String(ST, radix:2)
		let bitsST = pad(strST, toSize: 8)
		let strXST = String(XST, radix:2)
		let bitsXST = pad(strXST, toSize: 6)
		let pP = NSString(format:"%1X", P) as String
		let pQ = NSString(format:"%1X", Q) as String
		let strFI = String(self.FI, radix:2)
		let FI = pad(strFI, toSize: 14)
		if TRACE != 0 {
			print("A=\(displayOrderedDigits(A.digits)) B=\(displayOrderedDigits(B.digits)) C=\(displayOrderedDigits(C.digits)) Stack=\(stack0) \(stack1) \(stack2) \(stack3)")
			print("M=\(displayOrderedDigits(M.digits)) N=\(displayOrderedDigits(N.digits)) Cr=\(carry)\(pointP)P=\(pP)\(pointQ)Q=\(pQ) G=\(displayOrderedDigits(G)) ST=\(bitsXST) \(bitsST)")
		}
		if let timer = bus.timer {
			let CLK_A = timer.registers.CLK[1]
			let CLK_B = timer.registers.CLK[0]
			let ALM_A = timer.registers.ALM[1]
			let ALM_B = timer.registers.ALM[0]
			let SCR_A = timer.registers.SCR[1]
			let SCR_B = timer.registers.SCR[0]
//			let INT_A = timer.registers.INT[1]
//			let INT_B = timer.registers.INT[0]
			let TMR_Sb = digitsToBits(digits: timer.registers.TMR_S, nbits: 16)
			let ACC_Fb = digitsToBits(digits: timer.registers.ACC_F, nbits: 16)
			let TMR_S = NSString(format:"%04X", TMR_Sb) as String
			let ACC_F = NSString(format:"%04X", ACC_Fb) as String
			let aTimer = timer.timerSelected.rawValue == 0 ? "B" : "A"
			if TRACE != 0 {
				print("CLK_A=\(displayOrderedDigits(CLK_A.digits)) ALM_A=\(displayOrderedDigits(ALM_A.digits)) SCR_A=\(displayOrderedDigits(SCR_A.digits))")
				print("CLK_B=\(displayOrderedDigits(CLK_B.digits)) ALM_B=\(displayOrderedDigits(ALM_B.digits)) SCR_B=\(displayOrderedDigits(SCR_B.digits))")
				print("TMR_S=\(TMR_S) ACC_F=\(ACC_F) Timer=\(aTimer) FI:\(FI)")
			}
		}
		if TRACE != 0 {
			print("RAM Addr=\(ramAddr) Perph Addr=\(periph) Base=\(mode.rawValue) KY=\(KY) Keydown=\(keyDown)")
		}
	}
	
	func displayOrderedDigits(_ digits: [Digit]) -> String {
		var result = ""
		for idx in Array((0...digits.count-1).reversed()) {
			result = result + (NSString(format: "%1X", digits[idx]) as String)
		}
		
		return result
	}
	
	func pad(_ string : String, toSize: Int) -> String {
		var padded = string
		for _ in 0..<toSize - string.count {
			padded = "0" + padded
		}
		return padded
	}
}


/*
	10 bit opcodes composed of the following parts
	rrrrcCCCss
	r  = row
	cC = col
	s  = set
	C  = tef
*/
struct OpCode: Codable {
	var opcode: Int
	
	init (opcode code: Int) {
		self.opcode = code
	}
	
	var row: Int {
		(self.opcode & 0x03c0) >> 6
	}
	
	var col: Int {
		((self.opcode & 0x003c) >> 2) & 0xf
	}
	
	var tef: Int {
		(self.opcode & 0x1c) >> 2
	}
	
	var set: Int {
		return (self.opcode & 0x03)
	}
}

enum PowerMode: Bits2, Codable {
	case deepSleep = 0
	case lightSleep = 1
	case powerOn = 2
}

enum ArithMode: Digit, Codable {
	case dec_mode = 0xa
	case hex_mode = 0x10
}

let maxSimulationTimeLag = 0.2
let simulatedInstructionTime: Double = 155e-6

/* map from high opcode bits to register index */
let fTable: [Int] = [
	/* 0 */ 0x3,
	/* 1 */ 0x4,
	/* 2 */ 0x5,
	/* 3 */ 0xA,
	/* 4 */ 0x8,
	/* 5 */ 0x6,
	/* 6 */ 0xB,
	/* 7 */ 0x0,	// old 0xE
	/* 8 */ 0x2,
	/* 9 */ 0x9,
	/* A */ 0x7,
	/* B */ 0xD,
	/* C */ 0x1,
	/* D */ 0xC,
	/* E */ 0x0,
	/* F */ 0x0		// old 0xF
]

var zeroes: Digits14 = Digits14()

final class CPU: Codable {
	static let sharedInstance = CPU()

	// Processor performance characteristics
	// ProcCycles / ProcInterval=5.8 for a real machine: 578 cycles / 100 ms per interval
	// 5780 inst/sec = 1E6 / 173 ms for a halfnut HP-41CX instruction (older models run at 158 ms)
	// time in milliseconds between processor runs:
	let DEFAULT_PROC_INTERVAL	=  50
	let MAX_PROC_INTERVAL		= 100
	let MIN_PROC_INTERVAL		=  10
	// number of processor cycles to run each time:
	let DEFAULT_PROC_CYCLES		= 578

	let onKeyCode: Bits8 = 0x18

	let keyColTable: [Bits8] = [0x10, 0x30, 0x70, 0x80, 0xC0]

	var runFlag = false
	var simulationTime: TimeInterval?
	var reg = CPURegisters()
	var keyReleaseDelay = 0
	var powerMode: PowerMode = .deepSleep
	var soundOutput = SoundOutput()
	var cycleLimit = 0
	var currentTyte = 0
	var breakpointIsSet = false
	var breakpointAddr: Bits16 = 0
	var savedPC: Bits16 = 0
	var lastOpCode = OpCode(opcode: 0)
	var powerOffFlag = false
	var debugCPUViewController: DebugCPUViewController?
	var debugMemoryViewController: DebugMemoryViewController?
	
	var opcode = OpCode(opcode: 0)
	var prevPT: Bits4 = 0

	var currentRomChip: RomChip?
	var currentPage: Int = 0
	
	enum CodingKeys: String, CodingKey {
		case powerMode
		case cycleLimit
		case currentTyte
		case savedPC
		case lastOpCode
		case powerOffFlag
		case opcode
		case prevPT
		case currentPage
	}
		
	init() {
		TRACE = UserDefaults.standard.integer(forKey: "traceActive")
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		powerMode = try values.decode(PowerMode.self, forKey: .powerMode)
		cycleLimit = try values.decode(Int.self, forKey: .cycleLimit)
		currentTyte = try values.decode(Int.self, forKey: .currentTyte)
		savedPC = try values.decode(Bits16.self, forKey: .savedPC)
		lastOpCode = try values.decode(OpCode.self, forKey: .lastOpCode)
		powerOffFlag = try values.decode(Bool.self, forKey: .powerOffFlag)
		opcode = try values.decode(OpCode.self, forKey: .opcode)
		prevPT = try values.decode(Bits4.self, forKey: .prevPT)
		currentPage = try values.decode(Int.self, forKey: .currentPage)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(powerMode, forKey: .powerMode)
		try container.encode(cycleLimit, forKey: .cycleLimit)
		try container.encode(currentTyte, forKey: .currentTyte)
		try container.encode(savedPC, forKey: .savedPC)
		try container.encode(lastOpCode, forKey: .lastOpCode)
		try container.encode(powerOffFlag, forKey: .powerOffFlag)
		try container.encode(opcode, forKey: .opcode)
		try container.encode(prevPT, forKey: .prevPT)
		try container.encode(currentPage, forKey: .currentPage)
	}

	func clearRegisters() {
		reg.A = Digits14()
		reg.B = Digits14()
		reg.C = Digits14()
		reg.M = Digits14()
		reg.N = Digits14()
		reg.P = 0
		reg.Q = 0
		reg.PC = 0
		reg.G = [0, 0]
		reg.ST = 0
		reg.T = 0
		reg.FI = 0
		reg.KY = 0
		reg.XST = 0
		reg.stack = [Bits16](repeating: 0, count: 4)
		reg.R = 0
		reg.carry = 0
		reg.mode = .dec_mode
		reg.ramAddress = 0
		reg.peripheral = 0
		reg.keyDown = 0
	}
	
	func setPowerMode(_ mode: PowerMode) {
		if powerMode != mode {
			if mode == .powerOn && self.powerMode == .deepSleep {
				reg.carry = 1
			}
			if mode == .powerOn && self.powerMode == .lightSleep {
				reg.carry = 0
			}
			
			powerMode = mode
			if mode != .powerOn {
				soundOutput.flushAndSuspendSoundOutput()
				self.lineNo = 0
			}
			NotificationCenter.default.post(name: Notification.Name(rawValue: kCPUDebugUpdateDisplay), object: nil)
			NotificationCenter.default.post(name: Notification.Name(rawValue: kMemoryDebugUpdateDisplay), object: nil)
		}
	}
	
	func step() {
		executeNextInstruction()
		NotificationCenter.default.post(name: Notification.Name(rawValue: kCPUDebugUpdateDisplay), object: nil)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kMemoryDebugUpdateDisplay), object: nil)
	}
	
	func reset() {
		clearRegisters()
		/* 
		   The H41 firmware relies on the ON key being down on wakeup from deep sleep,
		   otherwise the display doesn't get turned on. But it does a dummy test & reset
		   of the keyboard before testing for this, so we have to arrange for it to appear
		   held down for at least 2 kbd tests.
		*/
		reg.KY = onKeyCode
		keyReleaseDelay = 1
		setPowerMode(.deepSleep)
		setPowerMode(.powerOn)
	}

	func keyWithCode(_ code: Bits8, pressed: Bool) {
		if pressed {
			let row = code >> 4
			let col = Int(code & 0x0f)
			reg.KY = row | keyColTable[col]
			reg.keyDown = 1
			
			if reg.KY == onKeyCode && powerMode != .deepSleep {
				powerOffFlag = true				// will enter deep sleep on next power off
			}
			if powerMode == .lightSleep || reg.KY == onKeyCode {
				setPowerMode(.powerOn)
			}
		} else {
			reg.keyDown = 0
		}
		NotificationCenter.default.post(name: Notification.Name(rawValue: kCPUDebugUpdateDisplay), object: nil)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kMemoryDebugUpdateDisplay), object: nil)
	}
	
	func abortInstruction(_ message: String) {
		reg.PC = savedPC
		setRunning(false)
	}
	
	func isRunning() -> Bool {
		return (powerMode == .powerOn) && runFlag
	}
	
	func setRunning(_ state: Bool) {
		if runFlag != state {
			runFlag = state
			NotificationCenter.default.post(name: Notification.Name(rawValue: kCPUDebugUpdateDisplay), object: nil)
			NotificationCenter.default.post(name: Notification.Name(rawValue: kMemoryDebugUpdateDisplay), object: nil)
		}
		simulationTime = Date.timeIntervalSinceReferenceDate
	}
	
	func timeSlice(_ timer: Foundation.Timer) {
		let currentTime = Date.timeIntervalSinceReferenceDate
		if isRunning() {
			if let sTime = simulationTime {
				if currentTime - sTime > maxSimulationTimeLag {
					simulationTime = currentTime - maxSimulationTimeLag
				}
				cycleLimit = soundOutput.soundAvailableBufferSpace()
				while self.isRunning() && cycleLimit > 2 && simulationTime! < currentTime {
					executeNextInstruction()
				}
				NotificationCenter.default.post(name: Notification.Name(rawValue: kCPUDebugUpdateDisplay), object: nil)
				NotificationCenter.default.post(name: Notification.Name(rawValue: kMemoryDebugUpdateDisplay), object: nil)
			}
		} else {
			simulationTime = currentTime
		}
		soundOutput.soundTimeslice()
	}

	@discardableResult
	func popReturnStack() -> Bits16 {
		let result = reg.stack[0]
		reg.stack[0] = reg.stack[1]
		reg.stack[1] = reg.stack[2]
		reg.stack[2] = reg.stack[3]
		reg.stack[3] = 0
		
		return result
	}
	
	func pushReturnStack(_ word: Bits16) {
		reg.stack[3] = reg.stack[2]
		reg.stack[2] = reg.stack[1]
		reg.stack[1] = reg.stack[0]
		reg.stack[0] = word
	}
	
	func fetch() throws -> Int {
		cycleLimit -= 1
		simulationTime? += simulatedInstructionTime
		soundOutput.soundOutputForWordTime(Int(reg.T))
		if TRACE != 0 {
			print("readRomAddress \(reg.PC)")
		}
		do {
			let result = try bus.readRomAddress(Int(reg.PC))
			reg.PC += 1
			
			return result
		} catch {
			if TRACE != 0 {
				print("error read ROM at Address: \(reg.PC)")
			}
			throw RomError.invalidAddress
		}
	}
	
	func decrementPointer() {
		if reg.R == 0 {
			reg.P = (reg.P == 0) ? 13 : reg.P - 1
		} else {
			reg.Q = (reg.Q == 0) ? 13 : reg.Q - 1
		}
	}
	
	func incrementPointer() {
		if reg.R == 0 {
			reg.P = (reg.P == 13) ? 0 : reg.P + 1
		} else {
			reg.Q = (reg.Q == 13) ? 0 : reg.Q + 1
		}
	}
	
	func regR() -> Digit {
		if reg.R == 0 {
			return reg.P
		} else {
			return reg.Q
		}
	}
	
	func setR(_ newR: Bits4) {
		if reg.R == 0 {
			reg.P = newR
		} else {
			reg.Q = newR
		}
	}
	
	var lineNo = 0
	
	func executeNextInstruction() {
		if TRACE != 0 {
			print("--------------------------------------------------------------------------------------------------")
			lineNo += 1
			print("Step: \(lineNo)")
			print("")
			reg.description()
		}
		savedPC = reg.PC
		prevPT = regR()
		self.lastOpCode = self.opcode
		do {
			let result = try fetch()
			
			currentTyte = result
			
			self.opcode = OpCode(opcode: result)
			
			if TRACE != 0 {
				print("currentTyte: \(currentTyte)")
			}
			switch self.opcode.set {
			case 0:	executeClass0()				// miscellaneous
			case 1:	executeClass1()				// long jumps
			case 2:	executeClass2()				// Arithmetic operations
			case 3:	executeClass3()				// short jumps
			default: print("PROBLEM!")		// Error
			}
		} catch {
			if TRACE != 0 {
				print("currentTyte: \(currentTyte)")
			}
			reg.PC = 0
		}
		if breakpointIsSet && reg.PC >= breakpointAddr {
			setRunning(false)
		}
	}

	func unimplementedInstruction(_ instr: Int) {
		abortInstruction("Unimplemented instruction: \(instr)")
	}

	
	// MARK: - Class 0
	func executeClass0() {
		if TRACE != 0 {
			print("executeClass0: opcode: \(self.opcode.col) - param: \(self.opcode.row)")
		}
		switch self.opcode.col {
		case 0x0: executeClass0Line0()
		case 0x1: executeClass0Line1()
		case 0x2: executeClass0Line2()
		case 0x3: executeClass0Line3()
		case 0x4: executeClass0Line4()
		case 0x5: executeClass0Line5()
		case 0x6: executeClass0Line6()
		case 0x7: executeClass0Line7()
		case 0x8: executeClass0Line8()
		case 0x9: executeClass0Line9() // Printer control
		case 0xA: executeClass0LineA() // WRITE r
		case 0xB: executeClass0LineB()
		case 0xC: executeClass0LineC()
		case 0xD: executeClass0LineD()
		case 0xE: executeClass0LineE()
		case 0xF: executeClass0LineF()
		default: unimplementedInstruction(self.opcode.row)
		}
	}
	
	func executeClass0Line0() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line0(self.opcode))
		}
		switch self.opcode.row {
		case 0x0:
			reg.carry = op_NOP()
		case 0x1:
			reg.carry = op_WROM()
		case 0x4, 0x5, 0x6, 0x7:
			reg.carry = op_ENROM()
		default:
			reg.carry = op_INVALID("executeClass0Line0: \(self.opcode.row)")
		}
	}
	
	func executeClass0Line1() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line1(self.opcode))
		}
		switch self.opcode.row {
		case 0x7:
			reg.carry = 0				// Not used
		case 0xF:
			reg.carry = op_CLRST()
		default:
			reg.carry = op_SDeq0(fTable[self.opcode.row])
		}
	}
	
	func executeClass0Line2() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line2(self.opcode))
		}
		switch self.opcode.row {
		case 0x7:
			reg.carry = 0				// Not used
		case 0xF:
			reg.carry = op_RSTKB()
		default:
			reg.carry = op_STeq1(fTable[self.opcode.row])
		}
	}
	
	func executeClass0Line3() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line3(self.opcode))
		}
		switch self.opcode.row {
		case 0x7:
			reg.carry = 0				// Not used
		case 0xF:
			reg.carry = op_CHKBK()
		default:
			reg.carry = op_ifSTeq1(fTable[self.opcode.row])
		}
	}
	
	func executeClass0Line4() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line4(self.opcode))
		}
		reg.carry = op_LC(self.opcode.row)
	}

	func executeClass0Line5() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line5(self.opcode))
		}
		switch self.opcode.row {
		case 0x7:
			reg.carry = 0				// Not used
		case 0xF:
			reg.carry = op_DECPT()
		default:
			reg.carry = op_ifPTeqD(fTable[self.opcode.row])
		}
	}

	func executeClass0Line6() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line6(self.opcode))
		}
		switch self.opcode.row {
		case 0x1:
			reg.carry = op_GeqC()
		case 0x2:
			reg.carry = op_CeqG()
		case 0x3:
			reg.carry = op_CGEX()
		case 0x5:
			reg.carry = op_MeqC()
		case 0x6:
			reg.carry = op_CeqM()
		case 0x7:
			reg.carry = op_CMEX()
		case 0x9:
			reg.carry = op_FeqSB()
		case 0xA:
			reg.carry = op_SBeqF()
		case 0xB:
			reg.carry = op_FEXSB()
		case 0xD:
			reg.carry = op_STeqC()
		case 0xE:
			reg.carry = op_CeqST()
		case 0xF:
			reg.carry = op_CSTEX()
		default:
			reg.carry = op_INVALID("executeClass0Line6: \(self.opcode.row)")
		}
	}
	
	func executeClass0Line7() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line7(self.opcode))
		}
//		var _: Bits4 = regR()
		switch self.opcode.row {
		case 0x7:
			reg.carry = 0				// Not used
		case 0xF:
			reg.carry = op_INCPT()
		default:
			reg.carry = op_PTeqD(fTable[self.opcode.row])
		}
	}
	
	func executeClass0Line8() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line8(self.opcode))
		}
		switch self.opcode.row {
		case 0x0:
			reg.carry = op_SPOPND()
		case 0x1:
			reg.carry = op_POWOFF()
		case 0x2:
			reg.carry = op_SELP()
		case 0x3:
			reg.carry = op_SELQ()
		case 0x4:
			reg.carry = op_ifPeqQ()
		case 0x5:
			reg.carry = op_ifLLD()
		case 0x6:
			reg.carry = op_CLRABC()
		case 0x7:
			reg.carry = op_GOTOC()
		case 0x8:
			reg.carry = op_CeqKEYS()
		case 0x9:
			reg.carry = op_SETHEX()
		case 0xA:
			reg.carry = op_SETDEC()
		case 0xB:
			reg.carry = op_DISOFF()
		case 0xC:
			reg.carry = op_DISTOG()
		case 0xD:
			reg.carry = op_RTNC()
		case 0xE:
			reg.carry = op_RTNNC()
		case 0xF:
			reg.carry = op_RTN()
		default:
			reg.carry = op_INVALID("executeClass0Line8: \(self.opcode.row)")
		}
	}
	
	func executeClass0Line9() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0Line9(self.opcode))
		}
		reg.carry = op_SELPF(self.opcode.row)
	}
	
	func executeClass0LineA() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineA(self.opcode))
		}
		reg.carry = op_REGNeqC(self.opcode.row)
	}
	
	func executeClass0LineB() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineB(self.opcode))
		}
		switch fTable[self.opcode.row] {
		case 0xE, 0xF:
			reg.carry = op_INVALID("executeClass0LineB: \(fTable[self.opcode.row])")
		default:
			reg.carry = op_FDeq1(fTable[self.opcode.row])
		}
	}
	
	func executeClass0LineC() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineC(self.opcode))
		}
		switch self.opcode.row {
		case 0x0:
			reg.carry = op_ROMBLK()
		case 0x1:
			reg.carry = op_NeqC()
		case 0x2:
			reg.carry = op_CeqN()
		case 0x3:
			reg.carry = op_CNEX()
		case 0x4:
			reg.carry = op_LDI()
		case 0x5:
			reg.carry = op_STKeqC()
		case 0x6:
			reg.carry = op_CeqSTK()
		case 0x7:
			reg.carry = op_WPTOG()
		case 0x8:
			reg.carry = op_GOKEYS()
		case 0x9:
			reg.carry = op_DADDeqC()
		case 0xA:
			reg.carry = op_CLRDATA()
		case 0xB:
			reg.carry = op_DATAeqC()
		case 0xC:
			reg.carry = op_CXISA()
		case 0xD:
			reg.carry = op_CeqCorA()
		case 0xE:
			reg.carry = op_CeqCandA()
		case 0xF:
			reg.carry = op_PFADeqC()
		default:
			reg.carry = op_INVALID("executeClass0LineC: \(self.opcode.row)")
		}
	}
	
	func executeClass0LineD() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineD(self.opcode))
		}
		op_INVALID("executeClass0LineD: \(self.opcode.row)")
	}
	
	func executeClass0LineE() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineE(self.opcode))
		}
		switch self.opcode.row {
		case 0:
			reg.carry = op_CeqDATA(self.opcode.row)
		default:
			reg.carry = op_CeqREGN(self.opcode.row)
		}
	}
	
	func executeClass0LineF() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass0LineF(self.opcode))
		}
		switch (self.opcode.row) {
		case 0x7, 0xF:
			reg.carry = op_INVALID("executeClass0LineF: \(self.opcode.row)")
		default:
			reg.carry = op_RCR(fTable[self.opcode.row])
		}
	}
	
	
	// MARK: - Class 1
	func executeClass1() {
		var newTyte = OpCode(opcode: 0)
		var addr: Int = 0
		do {
			let result = try fetch()
			newTyte = OpCode(opcode: result)
		} catch {
			newTyte = OpCode(opcode: 0)
		}
		addr = (newTyte.opcode & 0x3fc) << 6 | (self.opcode.opcode & 0x3fc) >> 2
		if TRACE != 0 {
//			println("executeClass1: \(self.opcode.opcode) - addr: 0x\(decToHex(addr)) word: \(newTyte.row())")
			if TRACE != 0 {
				print(Disassembly.sharedInstance.disassemblyClass1(self.opcode))
			}
		}
		switch (newTyte.set) {
		case 0:
			reg.carry = op_GSUBNC(addr)
		case 1:
			reg.carry = op_GSUBC(addr)
		case 2:
			reg.carry = op_GOLNC(addr)
		case 3:
			reg.carry = op_GOLC(addr)
		default:
			reg.carry = op_INVALID("executeClass1: \(newTyte.set)")
		}
	}
	
	
	// MARK: - Class 2
	func executeClass2() {
		let opcode = (self.opcode.opcode & 0x3e0) >> 5
		let field = (self.opcode.opcode & 0x1c) >> 2
		var start = 0
		var cnt = 0
//		var carry: Bit = 0
//		var zero: Bit = 0
		if TRACE != 0 {
//			println("executeClass2: opcode: \(opcode) - field: \(field)")
			if TRACE != 0 {
				print(Disassembly.sharedInstance.disassemblyClass2(self.opcode))
			}
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
			start = Int(reg.P)
			cnt = (Int(reg.Q) >= Int(reg.P)) ? Int(reg.Q) - Int(reg.P) + 1 : 14 - Int(reg.P)
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
			reg.carry = op_INVALID("executeClass2: \(self.opcode.opcode)")
			return
		}
		
		cpu.reg.carry = 0
		switch opcode {
		case 0x00:
			reg.carry = op_Aeq0(start: start, count: cnt)
		case 0x01:
			reg.carry = op_Beq0(start: start, count: cnt)
		case 0x02:
			reg.carry = op_Ceq0(start: start, count: cnt)
		case 0x03:
			reg.carry = op_ABEX(start: start, count: cnt)
		case 0x04:
			reg.carry = op_BeqA(start: start, count: cnt)
		case 0x05:
			reg.carry = op_ACEX(start: start, count: cnt)
		case 0x06:
			reg.carry = op_CeqB(start: start, count: cnt)
		case 0x07:
			reg.carry = op_BCEX(start: start, count: cnt)
		case 0x08:
			reg.carry = op_AeqC(start: start, count: cnt)
		case 0x09:
			op_AeqAplusB(start: start, count: cnt)
		case 0x0A:
			op_AeqAplusC(start: start, count: cnt)
		case 0x0B:
			op_AeqAplus1(start: start, count: cnt)
		case 0x0C:
			op_AeqAminuB(start: start, count: cnt)
		case 0x0D:
			op_AeqAminus1(start: start, count: cnt)
		case 0x0E:
			op_AeqAminuC(start: start, count: cnt)
		case 0x0F:
			op_CeqCplusC(start: start, count: cnt)
		case 0x10:
			op_CeqAplusC(start: start, count: cnt)
		case 0x11:
			op_CeqCplus1(start: start, count: cnt)
		case 0x12:
			op_CeqAminusC(start: start, count: cnt)
		case 0x13:
			op_CeqCminus1(start: start, count: cnt)
		case 0x14:
			op_CeqminusC(start: start, count: cnt)
		case 0x15:
			op_CeqminusCminus1(start: start, count: cnt)
		case 0x16:
			reg.carry = op_isBeq0(start: start, count: cnt)
		case 0x17:
			reg.carry = op_isCeq0(start: start, count: cnt)
		case 0x18:
			op_isAlessthanC(start: start, count: cnt)
		case 0x19:
			op_isAlessthanB(start: start, count: cnt)
		case 0x1A:
			reg.carry = op_isAnoteq0(start: start, count: cnt)
		case 0x1B:
			reg.carry = op_isAnoteqC(start: start, count: cnt)
		case 0x1C:
			reg.carry = op_shiftrigthA(start: start, count: cnt)
		case 0x1D:
			reg.carry = op_shiftrigthB(start: start, count: cnt)
		case 0x1E:
			reg.carry = op_shiftrigthC(start: start, count: cnt)
		case 0x1F:
			reg.carry = op_shiftleftA(start: start, count: cnt)
		default:
			reg.carry = op_INVALID("executeClass2: \(opcode)")
		}
	}
	
	
	// MARK: - Class 3
	func executeClass3() {
		if TRACE != 0 {
			print(Disassembly.sharedInstance.disassemblyClass3(self.opcode))
		}
		let value = (self.opcode.opcode >> 2) & 1
		var offset = 0
		if self.opcode.opcode & 0x0200 != 0 {
			offset = ((self.opcode.opcode >> 3) & 0x03f) - 64
		} else {
			offset = (self.opcode.opcode >> 3) & 0x03f
		}
		if offset == 0 {
			offset = 1
		}
		
		switch value {
		case 0:
			reg.carry = op_GONC(offset: offset)
		case 1:
			reg.carry = op_GOC(offset: offset)
		default:
			reg.carry = op_INVALID("executeClass3: \(self.opcode.opcode)")
		}
	}
	
	
	// MARK: -
	func digitsToString(_ register: [Digit]) -> String {
		var result = String()
		let limit = register.count - 1
		for idx in Array((0...limit).reversed()) {
			result += NSString(format:"%1X", register[idx]) as String
		}
		
		return result
	}
	
	func bits4ToString(_ register: Bits4) -> String {
		return NSString(format:"%1X", register) as String
	}
	
	// MARK: - CPU Invalid Instruction
	@discardableResult
	func op_INVALID(_ parameter: String) -> Bit {
		if TRACE != 0 {
			print("Invalid: " + parameter)
		}
		return 0
	}
}
