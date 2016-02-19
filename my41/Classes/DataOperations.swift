//
//  DataOperations.swift
//  my41
//
//  Created by Miroslav Perovic on 8/10/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

let kCPUDebugUpdateDisplay = "com.my41cx.debuger.cpudebugupdatedisplay"
let kMemoryDebugUpdateDisplay = "com.my41cx.debuger.memorydebugupdatedisplay"

enum ArithOp {
	case ADD
	case SUB
}

func copyDigits(
	src: Digits14,
	sourceStartAt: Int,
	inout destination: Digits14,
	destinationStartAt: Int,
	count cnt: Int)
{
	for idx in 0..<cnt {
		destination[destinationStartAt+idx] = src[sourceStartAt+idx]
	}
}

func fillDigits(
	inout src: Digits14,
	value v: Digit,
	start: Int,
	count: Int)
{
	for idx in start..<start+count  {
		src[idx] = v
	}
}

func clearDigits(inout destination destination: [Digit])
{
	for idx in Array((0...13).reverse()) {
		destination[idx] = Digit(0)
	}
}

func digitsToBitsWrap(
	digits digits: Digits14,
	inout bits: Bits8,
	start: Digit,
	var count: Int)
{
	var result: Bits8 = 0
	var i: Int = Int(start)
	var j: Digit = 0
	while count-- > 0 {
		result |= Bits8(digits[i] << j)
		i++
		if i > 13 {
			i = 0
		}
		j += 4
	}
	bits = result
}

func bitsToDigitsWrap(
	var bits bits: Bits8,
	inout digits: Digits14,
	start: Digit,
	var count: Int)
{
	var i: Int = Int(start)
	while count-- > 0 {
		digits[i] = Digit(bits & 0xF)
		bits >>= 4
		++i
		if i > 13 {
			i = 0
		}
	}
}

func exchangeDigits(
	inout X X: Digits14,
	inout Y: Digits14,
	startPos start: Int,
	var count: Int)
{
	var i = start
	while count-- > 0 {
		swap(&X[i], &Y[i])
		++i
	}
}

func digitsToBits(
	digits digits: [Digit],
	nbits: Int) -> UInt16
{
	var result: UInt16 = 0
	var ndigits = (nbits + 3) >> 2
	var dp = ndigits
	while ndigits-- > 0 {
		result = UInt16(result << 4) | UInt16(digits[--dp])
	}
	let res = ((1 << nbits) - 1)
	
	return (result & UInt16(res))
}

func bitsToDigits(
	var bits bits: Int,
	inout destination digits: Digits14,
	var start: Int,
	var count: Int)
{
	while count-- > 0 {
		digits[start++] = Digit(bits & 0xF)
		bits >>= 4
	}
}

func orDigits(
	X X: [Digit],
	Y: [Digit],
	start: Int,
	count: Int) -> [Digit]
{
	var z: Digits14 = emptyDigit14
	for i in start..<count {
		z[i] = X[i] | Y[i]
	}
	return z
}

func andDigits(
	X X: [Digit],
	Y: [Digit],
	start: Int,
	count: Int) -> [Digit]
{
	var z: Digits14 = emptyDigit14
	for i in start..<count {
		z[i] = X[i] & Y[i]
	}
	return z
}

func shiftDigitsLeft(
	var X X: [Digit],
	start: Int,
	count: Int) -> [Digit]
{
	for var idx = start + count - 1; idx > start; idx-- {
		X[idx] = X[idx-1]
	}
	X[start] = 0
	
	return X
}

func shiftDigitsRight(
	var X X: [Digit],
	start: Int,
	count: Int) -> [Digit]
{
	for idx in start+1..<start+count {
		X[idx-1] = X[idx]
	}
	X[start + count - 1] = 0
	
	return X
}

/*
   Perform a hex or decimal add or subtract operation on the specified
   range of digits. Carry is an inout parameter specifying the initial
   carry and returning the final carry. Zero is an out parameter returning
   true if all digits of the result are zero.
*/
func addOrSubtractDigits(
	arithOp op: ArithOp,
	arithMode mode: ArithMode,
	firstNum: [Digit],
	secondNum: [Digit],
	inout destination: [Digit],
	from: Int,
	count: Int,
	inout carry: Bit,
	inout zero: Bit)
{
	var d: Int = 0
	var c = Int(carry)
	var z: Bit = 1
	
	for idx in from..<from+count {
		if op == .ADD {
			d = Int(firstNum[idx]) + Int(secondNum[idx]) + Int(c)
		} else {
			if mode == .DEC_MODE {
				d = Int(firstNum[idx]) + 0x9 - Int(secondNum[idx]) + Int(c)
			} else {
				d = Int(firstNum[idx]) + 0xF - Int(secondNum[idx]) + Int(c)
			}
			if d < 0 {
				print("\(idx) - \(firstNum), \(secondNum) -> \(d)")
			}
		}
		if mode == ArithMode.DEC_MODE && d > 9 {
			d += 6
		}
		c = d >> 4
		d &= 0xf
		if d != 0 {
			z = 0
		}
		destination[idx] = Digit(d)
	}
	
	carry = Bit(c)
	zero = z
}

func adder(nib1 nib1: Digit, nib2: Digit) -> Digit
{
	var result = nib1 + nib2 + Digit(cpu.reg.carry)
	if result >= cpu.reg.mode.rawValue {
		result -= cpu.reg.mode.rawValue
		cpu.reg.carry = 1
	} else {
		cpu.reg.carry = 0
	}
	
	result = result & 0x0f
	
	return result
}

func subtractor(nib1 nib1: Digit, nib2: Digit) -> Digit
{
	var result = Int(nib1) - Int(nib2) - Int(cpu.reg.carry)
	if result < 0 {
		result += Int(cpu.reg.mode.rawValue)
		cpu.reg.carry = 1
	} else {
		cpu.reg.carry = 0
	}
	
	result = result & 0x0f
	
	return Digit(result)
}

func compareDigits(
	source: Digits14,
	withDigits destination: Digits14
) -> Bool
{
	for idx in 0...13 {
		if source[idx] != destination[idx] {
			return false
		}
	}
	
	return true
}

func decToHex(dec: Int) -> String
{
	return NSString(format:"%2X", dec) as String
}
