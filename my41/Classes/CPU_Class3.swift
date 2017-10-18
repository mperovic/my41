//
//  CPU_Class3.swift
//  my41
//
//  Created by Miroslav Perovic on 12/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

func op_GONC(offset: Int) -> Bit													  // GONC
{
	/*
	GONC
	Branch (Relative) on No Carry
	=========================================================================================
	GONC											   operand: relative offset
	
	Operation: if CY (PC <= PC + rel_offset)
	=========================================================================================
	Flag:      Cleared
	=========================================================================================
	Dec/Hex:   Independent
	Turbo:     Independent
	=========================================================================================
	Assembly Syntax							Encoding						Machine Cycles
	-----------------------------------------------------------------------------------------
	GOC rel_offset							AAAA_AAA0_11							1
	=========================================================================================
	Note: The relative offset is a 7-bit 2’s complement number that is sign-extended to
		  16 bits and added to the PC of this instruction if the CY flag is true. This allows
		  a jump in the range of -64 to +63 from the address of this instruction.
	*/
	if cpu.reg.carry == 0 {
		cpu.reg.PC = Bits16(Int(cpu.reg.PC) - 1 + offset) & 0xffff
	}
	
	return 0
}

func op_GOC(offset: Int) -> Bit													   // GOC
{
	/*
	GNC
	Branch (Relative) on Carry
	=========================================================================================
	GOC											    operand: relative offset
	
	Operation: if CY (PC <= PC + rel_offset)
	=========================================================================================
	Flag:      Cleared
	=========================================================================================
	Dec/Hex:   Independent
	Turbo:     Independent
	=========================================================================================
	Assembly Syntax							Encoding						Machine Cycles
	-----------------------------------------------------------------------------------------
	GOC rel_offset							AAAA_AAA1_11							1
	=========================================================================================
	Note: The relative offset is a 7-bit 2’s complement number that is sign-extended to
	      16 bits and added to the PC of this instruction if the CY flag is true. This allows
	      a jump in the range of -64 to +63 from the address of this instruction.
	*/
	if cpu.reg.carry == 1 {
		cpu.reg.PC = Bits16(Int(cpu.reg.PC) - 1 + offset) & 0xffff
	}
	
	return 0
}
