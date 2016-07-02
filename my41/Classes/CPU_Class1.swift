//
//  CPU_Class1.swift
//  my41
//
//  Created by Miroslav Perovic on 12/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

func op_GSUBNC(_ addr: Int) -> Bit													// GSUBNC
{
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
	if cpu.reg.carry == 0 {
		longJumpTo(addr, withReturn: true)
	}

	return 0
}

func op_GSUBC(_ addr: Int) -> Bit														// GSUBC
{
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
	if cpu.reg.carry == 1 {
		longJumpTo(addr, withReturn: true)
	}
	
	return 0
}

func op_GOLNC(_ addr: Int) -> Bit														 // GOLNC
{
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
	if cpu.reg.carry == 0 {
		longJumpTo(addr, withReturn: false)
	}
	
	return 0
}

func op_GOLC(_ addr: Int) -> Bit														 // GOLC
{
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
	if cpu.reg.carry == 1 {
		longJumpTo(addr, withReturn: false)
	}
	
	return 0
}


func longJumpTo(_ addr: Int, withReturn push: Bool) {
	let page = (addr & 0xf000) >> 12
	let activePage = bus.activeBank[page]
	if let rom = bus.romChips[page][activePage - 1] {
		if rom.words[addr & 0x0fff] == 0 {
			// long jumps dont jump to NOP
			return
		}
		
		if push {
			cpu.pushReturnStack(cpu.reg.PC)
		}
		
		// We do not jump to a NOP tyte
		if rom[Int(addr & 0xfff)] == 0 {
			return
		}
		
		cpu.reg.PC = Bits16(addr)
		cpu.currentPage = page
		cpu.currentRomChip = rom
	}
}
