//
//  CPU_Class2.swift
//  my41
//
//  Created by Miroslav Perovic on 12/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

func op_Aeq0(start start: Int, count: Int) -> Bit										   // A=0
{
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
	fillDigits(
		&cpu.reg.A,
		value: 0,
		start: start,
		count: count
	)
	
	return 0
}

func op_Beq0(start start: Int, count: Int) -> Bit										   // B=0
{
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
	fillDigits(
		&cpu.reg.B,
		value: 0,
		start: start,
		count: count
	)
	
	return 0
}

func op_Ceq0(start start: Int, count: Int) -> Bit										   // C=0
{
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
	fillDigits(
		&cpu.reg.C,
		value: 0,
		start: start,
		count: count
	)
	
	return 0
}

func op_ABEX(start start: Int, count: Int) -> Bit										  // ABEX
{
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
	var x = cpu.reg.A
	var y = cpu.reg.B
	exchangeDigits(
		X: &x,
		Y: &y,
		startPos: start,
		count: count
	)
	cpu.reg.A = x
	cpu.reg.B = y
	
	return 0
}

func op_BeqA(start start: Int, count: Int) -> Bit										   // B=A
{
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
	copyDigits(cpu.reg.A,
		sourceStartAt: start,
		destination: &cpu.reg.B,
		destinationStartAt: start,
		count: count
	)
	
	return 0
}

func op_ACEX(start start: Int, count: Int) -> Bit										  // ACEX
{
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
	var x = cpu.reg.A
	var y = cpu.reg.C
	exchangeDigits(
		X: &x,
		Y: &y,
		startPos: start,
		count: count
	)
	cpu.reg.A = x
	cpu.reg.C = y
	
	return 0
}

func op_CeqB(start start: Int, count: Int) -> Bit										   // C=B
{
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
	copyDigits(
		cpu.reg.B,
		sourceStartAt: start,
		destination: &cpu.reg.C,
		destinationStartAt: start,
		count: count
	)
	
	return 0
}

func op_BCEX(start start: Int, count: Int) -> Bit										  // ACEX
{
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
	var x = cpu.reg.B
	var y = cpu.reg.C
	exchangeDigits(
		X: &x,
		Y: &y,
		startPos: start,
		count: count
	)
	cpu.reg.B = x
	cpu.reg.C = y
	
	return 0
}

func op_AeqC(start start: Int, count: Int) -> Bit										   // A=C
{
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
	copyDigits(
		cpu.reg.C,
		sourceStartAt: start,
		destination: &cpu.reg.A,
		destinationStartAt: start,
		count: count
	)
	
	return 0
}

func op_AeqAplusB(start start: Int, count: Int)											// A=A+B
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.B,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry
	for idx in start..<start+count {
		cpu.reg.A[idx] = adder(nib1: cpu.reg.A[idx], nib2: cpu.reg.B[idx])
	}
}

func op_AeqAplusC(start start: Int, count: Int)											// A=A+C
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry
	for idx in start..<start+count {
		cpu.reg.A[idx] = adder(nib1: cpu.reg.A[idx], nib2: cpu.reg.C[idx])
	}
}

func op_AeqAplus1(start start: Int, count: Int)											// A=A+1
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: zeroes,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//
//	return carry
	cpu.reg.carry = 1
	for idx in start..<start+count {
		cpu.reg.A[idx] = adder(nib1: cpu.reg.A[idx], nib2: 0)
	}
}

func op_AeqAminuB(start start: Int, count: Int)											// A=A-B
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.B,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		cpu.reg.A[idx] = subtractor(nib1: cpu.reg.A[idx], nib2: cpu.reg.B[idx])
	}
}

func op_AeqAminus1(start start: Int, count: Int)										 // A=A-1
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: zeroes,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	cpu.reg.carry = 1
	for idx in start..<start+count {
		cpu.reg.A[idx] = subtractor(nib1: cpu.reg.A[idx], nib2: 0)
	}
}

func op_AeqAminuC(start start: Int, count: Int)											// A=A-C
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.A,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		cpu.reg.A[idx] = subtractor(nib1: cpu.reg.A[idx], nib2: cpu.reg.C[idx])
	}
}

func op_CeqCplusC(start start: Int, count: Int)											// C=C+C
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.C,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//
//	return carry
	for idx in start..<start+count {
		cpu.reg.C[idx] = adder(nib1: cpu.reg.C[idx], nib2: cpu.reg.C[idx])
	}
}

func op_CeqAplusC(start start: Int, count: Int)									 // C=A+C
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.C,
//		secondNum: cpu.reg.A,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry
	for idx in start..<start+count {
		cpu.reg.C[idx] = adder(nib1: cpu.reg.C[idx], nib2: cpu.reg.A[idx])
	}
}

func op_CeqCplus1(start start: Int, count: Int)											// C=C+1
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .ADD,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.C,
//		secondNum: zeroes,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry
	cpu.reg.carry = 1
	for idx in start..<start+count {
		cpu.reg.C[idx] = adder(nib1: cpu.reg.C[idx], nib2: 0)
	}
}

func op_CeqAminusC(start start: Int, count: Int)										// C=A-C
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	cpu.reg.carry = carry == 0 ? 1 : 0
//
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		cpu.reg.C[idx] = subtractor(nib1: cpu.reg.A[idx], nib2: cpu.reg.C[idx])
	}
}

func op_CeqCminus1(start start: Int, count: Int)										 // C=C-1
{
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
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.C,
//		secondNum: zeroes,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	cpu.reg.carry = 1
	for idx in start..<start+count {
		cpu.reg.C[idx] = subtractor(nib1: cpu.reg.C[idx], nib2: 0)
	}
}

func op_CeqminusC(start start: Int, count: Int)											  // C=-C
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: zeroes,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		cpu.reg.C[idx] = subtractor(nib1: 0, nib2: cpu.reg.C[idx])
	}
}

func op_CeqminusCminus1(start start: Int, count: Int)									 // C=C-1
{
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
	C=-C-1 TEF								1011_1TEF_10							1
	=========================================================================================
	Note: This is the logical complement, which is the same as subtracting the value from
		  negative one.
	*/
//	var carry: Bit = 0
//	var zero: Bit = 0
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: zeroes,
//		secondNum: cpu.reg.C,
//		destination: &cpu.reg.C,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	cpu.reg.carry = 1
	for idx in start..<start+count {
		cpu.reg.C[idx] = subtractor(nib1: 0, nib2: cpu.reg.C[idx])
	}
}

func op_isBeq0(start start: Int, count: Int) -> Bit										  // ?B#0
{
	/*
	?B=0
	Test B Equal To Zero
	=========================================================================================
	?B=0											operand: Time Enable Field
	
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.B,
//		secondNum: zeroes,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return zero == 0 ? 1 : 0
	for idx in start..<start+count {
		if cpu.reg.B[idx] != 0 {
			return 1
		}
	}
	
	return 0
}

func op_isCeq0(start start: Int, count: Int) -> Bit										  // ?C#0
{
	/*
	?C=0
	Test C Equal To Zero
	=========================================================================================
	?C=0											operand: Time Enable Field
	
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.C,
//		secondNum: zeroes,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return zero == 0 ? 1 : 0
	for idx in start..<start+count {
		if cpu.reg.C[idx] != 0 {
			return 1
		}
	}
	
	return 0
}

func op_isAlessthanC(start start: Int, count: Int)										  // ?A<C
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.C,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		_ = subtractor(nib1: cpu.reg.A[idx], nib2: cpu.reg.C[idx])
	}
}

func op_isAlessthanB(start start: Int, count: Int)										  // ?A<B
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.B,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//
//	return carry == 0 ? 1 : 0
	for idx in start..<start+count {
		_ = subtractor(nib1: cpu.reg.A[idx], nib2: cpu.reg.B[idx])
	}
}

func op_isAnoteq0(start start: Int, count: Int) -> Bit									  // ?A#0
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: zeroes,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return zero == 0 ? 1 : 0
	for idx in start..<start+count {
		if cpu.reg.A[idx] != 0 {
			return 1
		}
	}
	
	return 0
}

func op_isAnoteqC(start start: Int, count: Int) -> Bit									  // ?A#C
{
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
//	var carry: Bit = 1
//	var zero: Bit = 0
//	var emptyD14 = emptyDigit14
//	addOrSubtractDigits(
//		arithOp: .SUB,
//		arithMode: cpu.reg.mode,
//		firstNum: cpu.reg.A,
//		secondNum: cpu.reg.C,
//		destination: &emptyD14,
//		from: start,
//		count: count,
//		carry: &carry,
//		zero: &zero
//	)
//	
//	return zero == 0 ? 1 : 0
	for idx in start..<start+count {
		if cpu.reg.A[idx] != cpu.reg.C[idx] {
			return 1
		}
	}
	
	return 0
}

func op_shiftrigthA(start start: Int, count: Int) -> Bit								   // ASR
{
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
	cpu.reg.A = shiftDigitsRight(
		X: cpu.reg.A,
		start: start,
		count: count
	)
	
	return 0
}

func op_shiftrigthB(start start: Int, count: Int) -> Bit								   // BSR
{
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
	cpu.reg.B = shiftDigitsRight(
		X: cpu.reg.B,
		start: start,
		count: count
	)
	
	return 0
}

func op_shiftrigthC(start start: Int, count: Int) -> Bit								   // CSR
{
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
	cpu.reg.C = shiftDigitsRight(
		X: cpu.reg.C,
		start: start,
		count: count
	)
	
	return 0
}

func op_shiftleftA(start start: Int, count: Int) -> Bit									   // ASL
{
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
	cpu.reg.A = shiftDigitsLeft(
		X: cpu.reg.A,
		start: start,
		count: count
	)
	
	return 0
}
