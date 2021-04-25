//
//  CPU_Class0.swift
//  my41
//
//  Created by Miroslav Perovic on 12/20/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

let opcodeDecrementPointer	= 0x3d4
let opcodeIncrementPointer	= 0x3dc
let opcodePtEq13			= 0x2dc
let oldOpcodePtEq13			= 0x2d4

// MARK: - Subclass 0

func op_NOP() -> Bit																   // NOP
{
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
	
	return 0
}

func op_WROM() -> Bit																  // WROM
{
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
	let slot = cpu.reg.C[6]
	if let rom = bus.romChipInSlot(Bits4(slot)) {
		if rom.writable == false {
			return 0
		}
		
		let addr = (cpu.reg.C[5] << 8) | (cpu.reg.C[4] << 4) | cpu.reg.C[3]
		let toSave = ((cpu.reg.C[2] & 0x03) << 8) | (cpu.reg.C[1] << 4) | cpu.reg.C[0]
		rom[Int(addr)] = UInt16(toSave)
	}
	
	return 0
}

func op_ENROM() -> Bit																// ENROMx
{
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
	if cpu.opcode.row == 0x4 {
		enableBank(1)
	} else if cpu.opcode.row == 0x6 {
		enableBank(2)
	} else if cpu.opcode.row == 0x5 {
		enableBank(3)
	} else if cpu.opcode.row == 0x7 {
		enableBank(4)
	}
	
	return 0
}

func enableBank(_ bankSet: Bits4) {
	if cpu.currentRomChip == nil || cpu.currentRomChip?.actualBankGroup == 0 {
		return
	}
	
	// search for banks that match ActualBankGroup
	for slot in 0...0xf {
		for bank in 1...4 {
			if let rom1 = bus.romChips[slot][bank - 1], let _ = bus.romChips[slot][Int(bankSet) - 1] {
				if let currentROM = cpu.currentRomChip {
					if currentROM.actualBankGroup == rom1.actualBankGroup {
						bus.activeBank[slot] = Int(bankSet)
					}
				}
			}
		}
	}
}


// MARK: - Subclass 1

func op_SDeq0(_ param: Int) -> Bit													  // SD=0
{
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
		cpu.reg.ST &= ~Bits8(1 << param)
	} else {
		cpu.reg.XST &= ~Bits8(1 << (param - 8))
	}
	
	return 0
}

func op_CLRST() -> Bit																 // CLRST
{
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
	cpu.reg.ST = 0
	
	return 0
}


// MARK: - Subclass 2

func op_STeq1(_ param: Int) -> Bit													  // SD=1
{
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
		cpu.reg.ST |= Bits8(1 << param)
	} else {
		cpu.reg.XST |= Bits8(1 << (param - 8))
	}
	
	return 0
}

func op_RSTKB() -> Bit																 // RSTKB
{
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
	if cpu.reg.keyDown == 0 {
		if cpu.keyReleaseDelay != 0 {		// See comment in reset:
			cpu.keyReleaseDelay -= 1
		} else {
			cpu.reg.KY = 0
			cpu.reg.keyDown = 0
		}
	}
	
	return 0
}


// MARK: - Subclass 3

func op_ifSTeq1(_ param: Int) -> Bit													 // ?SD=1
{
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
		return (cpu.reg.ST & Bits8(1 << param)) != 0 ? 1 : 0
	} else {
		return (cpu.reg.XST & Bits6(1 << (param - 8))) != 0 ? 1 : 0
	}
}

func op_CHKBK() -> Bit																 // CHKKB
{
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
	return cpu.reg.KY != Bits8(0) ? 1 : 0
}


// MARK: - Subclass 4

func op_LC(_ param: Int) -> Bit															// LC
{
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
	Note: The pointer decrements to the next lower digit position.
	
				===========================================================
				| current ptr | next ptr |  current digit -> next digit   |
				===========================================================
				|    0000     |   1000   |    3 (Mantissa digit 0) -> 2   |
				|    0001     |   0000   |    4 (Mantissa digit 1) -> 3   |
				|    0010     |   0001   |    5 (Mantissa digit 2) -> 4   |
				|    0011     |   1001   |   10 (Mantissa digit 7) -> 9   |
				|    0100     |   1010   |    8 (mantissa digit 5) -> 7   |
				|    0101     |   0010   |    6 (Mantissa digit 3) -> 5   |
				|    0110     |   0011   |   11 (Mantissa digit 8) -> 10  |
				|    1000     |   1100   |  2 (Exponent Sign digit) -> 1  |
				|    1001     |   0100   |    9 (Mantissa digit 6) -> 8   |
				|    1010     |   0101   |    7 (Mantissa digit 4) -> 6   |
				|    1011     |   1101   | 13 (Mantissa sign digit) -> 12 |
				|    1100     |   1110   |    1 (Exponent digit 1) -> 0   |
				|    1101     |   0110   |   12 (Mantissa digit 9) -> 11  |
				|    1110     |   1011   |   0 (Exponent digit 0) -> 13   |
				===========================================================
	*/
	
	cpu.reg.C[Int(cpu.regR())] = Digit(param)
	cpu.decrementPointer()
	
	return 0
}


// MARK: - Subclass 5

func op_ifPTeqD(_ param: Int) -> Bit								// ?PT=D
{
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
	return cpu.regR() == Digit(param) ? 1 : 0
}

func op_DECPT() -> Bit																// DECPT
{
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
	cpu.decrementPointer()
	
	return 0
}


// MARK: - Subclass 6

func swapRegisterG()
{
	let temp = cpu.reg.G[1]
	cpu.reg.G[1] = cpu.reg.G[0]
	cpu.reg.G[0] = temp
}

func op_GeqC() -> Bit																  // G=C
{
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
	if (cpu.regR() == 13) {
		// PT == 13
		if cpu.prevPT == 13 {
			/*
				1. active pointer wan not changed to point at the most significant nible
				   immediately prior to this instruction
			*/
			cpu.reg.G[1] = cpu.reg.C[13]
			cpu.reg.G[0] = cpu.reg.C[0]
		} else {
			/*
				3. If the active pointer was changed to point at the most significant nibble
				   (using PT=13, INC PT or DEC PT) immediately prior to this instruction
			*/
			cpu.reg.G[0] = cpu.reg.G[1]
			cpu.reg.G[1] = cpu.reg.C[13]
		}
	} else if cpu.prevPT == 13 && (cpu.lastOpCode.opcode == opcodeDecrementPointer) {
		/*
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction
		*/
		cpu.reg.G[1] = cpu.reg.C[13]
		cpu.reg.G[0] = cpu.reg.C[12]
	} else {
		// normal case
		cpu.reg.G[1] = cpu.reg.C[Int(cpu.regR()) + 1]
		cpu.reg.G[0] = cpu.reg.C[Int(cpu.regR())]
	}
	
	return 0
}

func op_CeqG() -> Bit																  // C=G
{
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
	let opcode01c = cpu.lastOpCode.opcode & 0x01c != 0
	let opcode05c = cpu.lastOpCode.opcode & 0x05c != 0
	let opcode09c = cpu.lastOpCode.opcode & 0x09c != 0
	let opcode0dc = cpu.lastOpCode.opcode & 0x0dc != 0
	let opcode11c = cpu.lastOpCode.opcode & 0x11c != 0
	let opcode15c = cpu.lastOpCode.opcode & 0x15c != 0
	let opcode19c = cpu.lastOpCode.opcode & 0x19c != 0
	let opcode21c = cpu.lastOpCode.opcode & 0x21c != 0
	let opcode25c = cpu.lastOpCode.opcode & 0x25c != 0
	let opcode29c = cpu.lastOpCode.opcode & 0x29c != 0
	let opcode31c = cpu.lastOpCode.opcode & 0x31c != 0
	let opcode35c = cpu.lastOpCode.opcode & 0x35c != 0
	let opcode39c = cpu.lastOpCode.opcode & 0x39c != 0
	let additionalPTAsignments = opcode01c || opcode05c || opcode09c || opcode0dc || opcode11c || opcode15c || opcode19c || opcode21c || opcode25c || opcode29c || opcode31c || opcode35c || opcode39c
	if cpu.regR() == 13 {
		if cpu.prevPT == 13 {
			/*
				1. If the active pointer was not changed to point at the most significant nibble
				   immediately prior to this instruction
			*/
			cpu.reg.C[13] = cpu.reg.G[1]
			cpu.reg.C[0] = cpu.reg.G[0]
		} else {
			/*
				2. If the active pointer was changed to point at the most significant nibble
				   (using PT=13, INC PT or DEC PT) immediately prior to this instruction
			*/
			cpu.reg.C[13] = cpu.reg.G[0]
			swapRegisterG()
		}
	} else if cpu.prevPT == 13 && (cpu.lastOpCode.opcode == opcodeDecrementPointer) {
		/*
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction
		*/
		cpu.reg.C[13] = cpu.reg.G[0]
		cpu.reg.C[12] = cpu.reg.G[1]
		cpu.reg.C[0] = cpu.reg.G[0]
		swapRegisterG()
	} else if cpu.prevPT == 13 && (cpu.lastOpCode.opcode == opcodePtEq13 || additionalPTAsignments) {
		/*
			4. If the active pointer was changed from pointing at the most significant nibble
			   (using PT=d only) immediately prior to this instruction
		*/
		cpu.reg.C[Int(cpu.regR()) + 1] = cpu.reg.G[0]
		cpu.reg.C[Int(cpu.regR())] = cpu.reg.G[1]
		cpu.reg.C[0] = cpu.reg.G[0]
		swapRegisterG()
	} else {
		// normal case
		cpu.reg.C[Int(cpu.regR()) + 1] = cpu.reg.G[1]
		cpu.reg.C[Int(cpu.regR())] = cpu.reg.G[0]
	}
	
	return 0
}

func op_CGEX() -> Bit																  // CGEX
{
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
	let tempG  = cpu.reg.G
	
	let opcode01c = cpu.lastOpCode.opcode & 0x01c != 0
	let opcode05c = cpu.lastOpCode.opcode & 0x05c != 0
	let opcode09c = cpu.lastOpCode.opcode & 0x09c != 0
	let opcode0dc = cpu.lastOpCode.opcode & 0x0dc != 0
	let opcode11c = cpu.lastOpCode.opcode & 0x11c != 0
	let opcode15c = cpu.lastOpCode.opcode & 0x15c != 0
	let opcode19c = cpu.lastOpCode.opcode & 0x19c != 0
	let opcode21c = cpu.lastOpCode.opcode & 0x21c != 0
	let opcode25c = cpu.lastOpCode.opcode & 0x25c != 0
	let opcode29c = cpu.lastOpCode.opcode & 0x29c != 0
	let opcode31c = cpu.lastOpCode.opcode & 0x31c != 0
	let opcode35c = cpu.lastOpCode.opcode & 0x35c != 0
	let opcode39c = cpu.lastOpCode.opcode & 0x39c != 0
	let additionalPTAsignments = opcode01c || opcode05c || opcode09c || opcode0dc || opcode11c || opcode15c || opcode19c || opcode21c || opcode25c || opcode29c || opcode31c || opcode35c || opcode39c
	if cpu.regR() == 13 {
		if cpu.prevPT == 13 {
			/*
				1. If the active pointer was not changed to point at the most significant nibble
				   immediately prior to this instruction
			*/
			cpu.reg.G[1] = cpu.reg.C[13]
			cpu.reg.G[0] = cpu.reg.G[0]
			cpu.reg.C[13] = tempG[1]
			cpu.reg.C[0] = tempG[0]
		} else {
			/*
				2. If the active pointer was changed to point at the most significant nibble
				   (using PT=13, INC PT or DEC PT) immediately prior to this instruction
			*/
			cpu.reg.G[1] = cpu.reg.C[13]
			cpu.reg.G[0] = tempG[1]
			cpu.reg.C[13] = tempG[0]
		}
	} else if cpu.prevPT == 13 && (cpu.lastOpCode.opcode == opcodeDecrementPointer) {
		/*
			3. If the active pointer was changed from pointing at the most significant nibble
			   (using DEC PT only) immediately prior to this instruction
		*/
		cpu.reg.G[1] = cpu.reg.C[13]
		cpu.reg.G[0] = cpu.reg.C[12]
		cpu.reg.C[13] = cpu.reg.C[0]
		cpu.reg.C[12] = tempG[1]
		cpu.reg.C[0] = tempG[0]
	} else if cpu.prevPT == 13 && (cpu.lastOpCode.opcode == opcodePtEq13 || additionalPTAsignments) {
		/*
			4. If the active pointer was changed from pointing at the most significant nibble
			   (using PT=d only) immediately prior to this instruction
		*/
		cpu.reg.G[1] = cpu.reg.C[Int(cpu.regR()) + 1]
		cpu.reg.G[0] = cpu.reg.C[Int(cpu.regR())]
		cpu.reg.C[Int(cpu.regR()) + 1] = cpu.reg.C[0]
		cpu.reg.C[Int(cpu.regR())] = tempG[1]
		cpu.reg.C[0] = tempG[0]
	} else {
		// normal case
		cpu.reg.G[1] = cpu.reg.C[Int(cpu.regR()) + 1]
		cpu.reg.G[0] = cpu.reg.C[Int(cpu.regR())]
		cpu.reg.C[Int(cpu.regR()) + 1] = tempG[1]
		cpu.reg.C[Int(cpu.regR())] = tempG[0]
	}
	
	return 0
}

func op_MeqC() -> Bit																   // M=C
{
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
	cpu.reg.M = cpu.reg.C

	return 0
}

func op_CeqM() -> Bit																   // C=M
{
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
	cpu.reg.C = cpu.reg.M

	return 0
}

func op_CMEX() -> Bit																  // CMEX
{
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
//	let temp = cpu.reg.M
//	cpu.reg.M = cpu.reg.C
//	cpu.reg.C = temp
	var x = cpu.reg.C
	var y = cpu.reg.M
	exchangeDigits(
		X: &x,
		Y: &y,
		startPos: 0,
		count: 14
	)
	cpu.reg.C = x
	cpu.reg.M = y
	
	return 0
}

func op_FeqSB() -> Bit																  // F=SB
{
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
	cpu.reg.T = cpu.reg.ST

	return 0
}

func op_SBeqF() -> Bit																  // SB=F
{
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
	cpu.reg.ST = cpu.reg.T

	return 0
}

func op_FEXSB() -> Bit																 // FEXSB
{
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
	
	// this is used to create tones.  Normally FF and 00 are switched back and forth.
	// one machine cycle is about 158 microseconds.
	// frequency = 1/((number of FFh cycles + number of 00h cycles)x 158 10E-6
	// Hepax Vol II pg 111,131, Zenrom Manual pg. 81, HP41 Schematic
	swap(&cpu.reg.ST, &cpu.reg.T)
//	let temp = cpu.reg.ST
//	cpu.reg.ST = cpu.reg.T
//	cpu.reg.T = temp
	if cpu.soundOutput.soundMode == .speaker {
//		Speaker(F_REG, 1)
	}
	
	return 0
}

func op_STeqC() -> Bit																  // ST=C
{
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
	cpu.reg.ST = cpu.reg.C[1] << 4 | cpu.reg.C[0]

	return 0
}

func op_CeqST() -> Bit																  // C=ST
{
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
	cpu.reg.C[1] = (cpu.reg.ST & 0xf0) >> 4
	cpu.reg.C[0] = cpu.reg.ST & 0xf

	return 0
}

func op_CSTEX() -> Bit																 // CSTEX
{
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
	let temp1 = cpu.reg.C[1]
	let temp0 = cpu.reg.C[0]
	
	cpu.reg.C[1] = (cpu.reg.ST & 0xf0) >> 4
	cpu.reg.C[0] = cpu.reg.ST & 0xf
	cpu.reg.ST = (temp1 << 4) | temp0

	return 0
}


// MARK: - Subclass 7

func op_INCPT() -> Bit																 // INCPT
{
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
	cpu.incrementPointer()

	return 0
}

func op_PTeqD(_ param: Int) -> Bit													  // PT=D
{
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
	PT=D									dddd_0111_00							1
	=========================================================================================
	*/
	cpu.setR(Digit(param))

	return 0
}


// MARK: - Subclass 8

func op_SPOPND() -> Bit																// SPOPND
{
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
	cpu.popReturnStack()
	
	return 0
}

func op_POWOFF() -> Bit																// POWOFF
{
	/*
	POWOFF
	Power Down
	=========================================================================================
	POWOFF														operand: none
	
	Operation: Power Down
	=========================================================================================
	Flag: Cleared
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
	
	for page in 0...0xf {
		bus.activeBank[page] = 1
	}
	
	cpu.reg.PC = 0
	enableBank(1)

	let regN = cpu.reg.N
	if regN[11] == 11 && regN[12] == 0 && regN[13] == 3 {
		// Check if exiting ED mode
		cpu.powerOffFlag = false
		cpu.setPowerMode(.lightSleep)
		
		return 0
	} else {
		if cpu.powerOffFlag {
			cpu.setPowerMode(.deepSleep)
			cpu.powerOffFlag = false
			
			return 1
		} else {
			cpu.setPowerMode(.lightSleep)
			
			return 0
		}
	}
}

func op_SELP() -> Bit																 // SELP
{
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
	cpu.reg.R = 0
	
	return 0
}

func op_SELQ() -> Bit																 // SELQ
{
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
	cpu.reg.R = 1
	
	return 0
}

func op_ifPeqQ() -> Bit																  // ?P=Q
{
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
	return cpu.reg.P == cpu.reg.Q ? 1 : 0
}

func op_ifLLD() -> Bit																 // ?LLD
{
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
	
	return 0
}

func op_CLRABC() -> Bit																// CLRABC
{
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
	cpu.reg.A = Digits14()
	cpu.reg.B = Digits14()
	cpu.reg.C = Digits14()
	
	return 0
}

func op_GOTOC() -> Bit																// GOTOC
{
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
	var digits = Digits14()
	var pos = 0
	for idx in 3...6 {
		digits[pos] = cpu.reg.C[idx]
		pos += 1
	}
	cpu.reg.PC = digitsToBits(
		digits: digits,
		nbits: 16
	)
	
	return 0
}

func op_CeqKEYS() -> Bit															// C=KEYS
{
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
	bitsToDigits(
		bits: Int(cpu.reg.KY),
		destination: &cpu.reg.C,
		start: 3,
		count: 2
	)

	return 0
}

func op_SETHEX() -> Bit																// SETHEX
{
	/*
	SETHEX
	Set Hex Mode
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
	cpu.reg.mode = .hex_mode
	
	return 0
}

func op_SETDEC() -> Bit																// SETDEC
{
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
	cpu.reg.mode = .dec_mode
	
	return 0
}

func op_DISOFF() -> Bit																// DISOFF
{
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
	NotificationCenter.default.post(name: Notification.Name(rawValue: "displayOff"), object: nil)
	
	return 0
}

func op_DISTOG() -> Bit																// DISTOG
{
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
	NotificationCenter.default.post(name: Notification.Name(rawValue: "displayToggle"), object: nil)
	
	return 0
}

func op_RTNC() -> Bit																  // RTNC
{
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
	if cpu.reg.carry != 0 {
		cpu.reg.PC = cpu.popReturnStack()
	}
	
	return 0
}

func op_RTNNC() -> Bit																// RTNNC
{
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
	if cpu.reg.carry == 0 {
		cpu.reg.PC = cpu.popReturnStack()
	}
	
	return 0
}

func op_RTN() -> Bit																  // RTN
{
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
	cpu.reg.PC = cpu.popReturnStack()
	
	return 0
}


// MARK: - Subclass 9

func op_SELPF(_ param: Int) -> Bit												 // SELPF
{
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
		if let _ = bus.romChipInSlot(6) {
			cpu.reg.peripheral = 1
		}
	default:
		break
	}
	
	return 0
}


// MARK: - Subclass A

func op_REGNeqC(_ param: Int) -> Bit													// REGN=C
{
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
	if cpu.reg.peripheral == 0 || cpu.reg.ramAddress <= 0x00F || cpu.reg.ramAddress >= 0x020 {
		// RAM is currently selected peripheral
		cpu.reg.ramAddress = (cpu.reg.ramAddress & 0x0FF0) | Bits12(param)
		do {
			try bus.writeRamAddress(cpu.reg.ramAddress, from: cpu.reg.C)
		} catch _ {
//			displayAlert("error writing ram at address: \(cpu.reg.ramAddress)")
		}
	} else {
		switch (cpu.reg.peripheral) {
		case 0x10:
			// Halfnut display
			if let display = bus.display {
				display.halfnutWrite()
			}
		case 0xfb:
			// Timer write
			bus.writeToRegister(
				Bits4(param),
				ofPeripheral: cpu.reg.peripheral
			)
		case 0xfc:
			// Card reader
			break
		case 0xfd:
			// LCD display
			if let display = bus.display {
				display.displayWrite()
			}
//			bus.writeToRegister(
//				Bits4(param),
//				ofPeripheral: cpu.reg.peripheral,
//				from: &cpu.reg.C
//			)
		case 0xfe:
			// Wand
			break
		default:
			break
		}
	}
	
	return 0
}


// MARK: - Subclass B

func op_FDeq1(_ param: Int) -> Bit														// ?Fd=1
{
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
	if param == 0x7 || param == 0xf {
		return 0
	} else {
		return (cpu.reg.FI & Bits14(1 << param)) != 0 ? 1 : 0
	}
}


// MARK: - Subclass C

func op_ROMBLK() -> Bit																  // ROMBLK
{
	//TODO: HEPAX Support
	/*
		ROMBLK - Eramco pg. 125
		Moves Hepax ROM to page specified in C[0]- only known to work with HEPAX module
		HEPAX may be on top of a RAM page and when it moves the RAM (alternate)
		becomes visible
	*/
	
	//TODO: CHECK!!!!
	let destination = cpu.reg.C[0] - 1
	for slot in 0x5..<0xf {
		for bank in 1..<4 {
			guard (bus.romChips[slot][bank - 1] != nil) else {
				continue
			}
			if let rom = bus.romChips[slot][bank - 1] {
				if rom.HEPAX == 0 || rom.RAM != 0 {
					// only move hepax ROM and not RAM
					continue
				}
			}
			
			let altRom = bus.romChips[Int(destination)][bank - 1]							// if there is something at the dest page, save it as the dest alt page (does not normally happen)
			bus.romChips[Int(destination)][bank - 1] = bus.romChips[slot][bank - 1]
			if let modulePage = bus.romChips[slot][bank - 1]?.altPage {
				bus.romChips[slot][bank - 1] = RomChip(fromBIN: modulePage.image, actualBankGroup: modulePage.actualBankGroup)		// move src alt page to primary now that hepax is moved off it
				bus.romChips[Int(destination)][bank - 1] = altRom
			}
		}
	}

	return 0
}

func op_NeqC() -> Bit																   // N=C
{
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
	cpu.reg.N = cpu.reg.C

	return 0
}

func op_CeqN() -> Bit																   // C=N
{
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
	cpu.reg.C = cpu.reg.N

	return 0
}

func op_CNEX() -> Bit																 // CNEX
{
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
	var x = cpu.reg.C
	var y = cpu.reg.N
	exchangeDigits(
		X: &x,
		Y: &y,
		startPos: 0,
		count: 14
	)
	cpu.reg.C = x
	cpu.reg.N = y
	
	return 0
}

func op_LDI() -> Bit																  // LDI
{
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
	var value: Int
	do {
		value = try cpu.fetch()
	} catch {
		value = 0
	}
	bitsToDigits(
		bits: value,
		destination: &cpu.reg.C,
		start: 0,
		count: 3
	)

	return 0
}

func op_STKeqC() -> Bit																// STK=C
{
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
//	var word: UInt16 = 0
	var digits = Digits14()
	var pos = 0
	for idx in 3...6 {
		digits[pos] = cpu.reg.C[idx]
		pos += 1
	}
	let word: UInt16 = digitsToBits(
		digits: digits,
		nbits: 16
	)
	cpu.pushReturnStack(Bits16(word))
	
	return 0
}

func op_CeqSTK() -> Bit																// C=STK
{
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
	let word = cpu.popReturnStack()
	bitsToDigits(
		bits: Int(word),
		destination: &cpu.reg.C,
		start: 3,
		count: 4
	)

	return 0
}

func op_WPTOG() -> Bit
{
	/* WPTOG - Toggles write protection on HEPAX RAM at page C[0] */
	let page = cpu.reg.C[0] - 1
	if let romChip = bus.romChipInSlot(Bits4(page), bank: Bits4(1)) {
		if romChip.HEPAX != 0 || romChip.RAM != 0 {
			romChip.writable = !romChip.writable
		}
	}

	return 0
}

func op_GOKEYS() -> Bit																// GOKEYS
{
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
	cpu.reg.PC = (cpu.reg.PC & 0xff00) | Bits16(cpu.reg.KY)
	
	return 0
}

func op_DADDeqC() -> Bit															// DADD=C
{
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
	cpu.reg.ramAddress = digitsToBits(
		digits: cpu.reg.C,
		nbits: 12
	)
	
	return 0
}

func op_CLRDATA() -> Bit														   // CLRDATA
{
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
//	cpu.clearRegisters()
	
	return 0
}

func op_DATAeqC() -> Bit														    // DATA=C
{
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
		  DADD=C instruction. The data is actually written to the parallel memory bus using
		  the RAM chip select.
	*/
	if cpu.reg.peripheral == 0 || cpu.reg.peripheral == 0xFB {
		do {
			try bus.writeRamAddress(cpu.reg.ramAddress, from: cpu.reg.C)
		} catch _ {
			if TRACE != 0 {
				print("error writing ram at address: \(cpu.reg.ramAddress)")
			}
		}
	} else {
		bus.writeDataToPeripheral(
			slot: cpu.reg.peripheral,
			from: cpu.reg.C
		)
	}
	
	return 0
}

func op_CXISA() -> Bit																// CXISA
{
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
	let page = Int(cpu.reg.C[6])
	let addr = (Int(cpu.reg.C[5]) << 8) | (Int(cpu.reg.C[4]) << 4) | Int(cpu.reg.C[3])
	var opcode: Int
	if let rom = bus.romChips[page][bus.activeBank[page] - 1] {
		opcode = Int(rom.words[addr])
	} else {
		opcode = 0
	}
	cpu.reg.C[2] = Digit(((opcode & 0x0300) >> 8))
	cpu.reg.C[1] = Digit(((opcode & 0x00f0) >> 4))
	cpu.reg.C[0] = Digit(opcode & 0x000f)
	
	return 0
}

func op_CeqCorA() -> Bit															// C=CORA
{
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
	cpu.reg.C = orDigits(
		X: cpu.reg.C,
		Y: cpu.reg.A,
		start: 0,
		count: 14
	)
	
	//TODO: David Assembler pg 60 CPU errors
	
	return 0
}

func op_CeqCandA() -> Bit															 // C=C&A
{
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
	cpu.reg.C = andDigits(
		X: cpu.reg.C,
		Y: cpu.reg.A,
		start: 0,
		count: 14
	)
	
	//TODO: David Assembler pg 60 CPU errors
	
	return 0
}

func op_PFADeqC() -> Bit															// PFAD=C
{
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
	PFAD=C									1111_1100_00							1
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
	var digits = Digits14()
	for idx in 0...1 {
		digits[idx] = cpu.reg.C[idx]
	}
	let temp = digitsToBits(
		digits: digits,
		nbits: 8
	)
	cpu.reg.peripheral = Bits8(temp)
	
	return 0
}


// MARK: - Subclass E

func op_CeqDATA(_ param: Int) -> Bit													// C=DATA
{
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
	if (cpu.reg.peripheral == 0 || (cpu.reg.ramAddress <= 0x000F) || (cpu.reg.ramAddress >= 0x0020)) {
		do {
			cpu.reg.C = try bus.readRamAddress(cpu.reg.ramAddress)
		} catch {
			if TRACE != 0 {
				print("error RAM address: \(cpu.reg.ramAddress)")
			}
		}
	} else {
		bus.readFromRegister(
			register: Bits4(param),
			ofPeripheral: cpu.reg.peripheral
		)
	}
	
	return 0
}

func op_CeqREGN(_ param: Int) -> Bit												// C=REGN
{
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
	if (cpu.reg.peripheral == 0 || (cpu.reg.ramAddress <= 0x000F) || (cpu.reg.ramAddress >= 0x0020)) {
		cpu.reg.ramAddress = Bits12(cpu.reg.ramAddress & 0x03F0) | Bits12(param)
		do {
			cpu.reg.C = try bus.readRamAddress(cpu.reg.ramAddress)
		} catch {
			if TRACE != 0 {
				print("error RAM address: \(cpu.reg.ramAddress)")
			}
		}
	} else {
		bus.readFromRegister(
			register: Bits4(param),
			ofPeripheral: cpu.reg.peripheral
		)
	}
	
	return 0
}


// MARK: - Subclass F

func op_WCMD() -> Bit																// WCMD
{
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
	
	return 0
}

func op_RCR(_ param: Int) -> Bit															// RCR
{
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
	var temp = Digits14()
	var tempC = cpu.reg.C
	copyDigits(
		cpu.reg.C,
		sourceStartAt: 0,
		destination: &temp,
		destinationStartAt: 0,
		count: param
	)
	copyDigits(
		cpu.reg.C,
		sourceStartAt: param,
		destination: &tempC,
		destinationStartAt: 0,
		count: 14-param
	)
	copyDigits(
		temp,
		sourceStartAt: 0,
		destination: &tempC,
		destinationStartAt: 14-param,
		count: param
	)
	cpu.reg.C = tempC

	return 0
}
