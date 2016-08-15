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
	case add
	case sub
}

func copyDigits(
	_ src: Digits14,
	sourceStartAt: Int,
	destination: inout Digits14,
	destinationStartAt: Int,
	count cnt: Int)
{
	for idx in 0..<cnt {
		destination[destinationStartAt+idx] = src[sourceStartAt+idx]
	}
}

func fillDigits(
	_ src: inout Digits14,
	value v: Digit,
	start: Int,
	count: Int)
{
	for idx in start..<start+count  {
		src[idx] = v
	}
}

func clearDigits(destination: inout [Digit])
{
	destination = destination.map { _ in Digit(0) }
//	for idx in Array((0...13).reversed()) {
//		destination[idx] = Digit(0)
//	}
}

func digitsToBitsWrap(
	digits: Digits14,
	bits: inout Bits8,
	start: Digit,
	count: Int)
{
	var result: Bits8 = 0
	var i: Int = Int(start)
	var j: Digit = 0
//	while count-- > 0 {
	for _ in (1...count) {
		result |= Bits8(digits[i] << j)
		i += 1
		if i > 13 {
			i = 0
		}
		j += 4
	}
	bits = result
}

func bitsToDigitsWrap(
	bits: Bits8,
	digits: inout Digits14,
	start: Digit,
	count: Int)
{
	var i: Int = Int(start)
	var b = bits
//	while count-- > 0 {
	for _ in (1...count) {
		digits[i] = Digit(bits & 0xF)
		b >>= 4
		i += 1
		if i > 13 {
			i = 0
		}
	}
}

func exchangeDigits(
	X: inout Digits14,
	Y: inout Digits14,
	startPos start: Int,
	count: Int)
{
	var i = start
//	while count-- > 0 {
	for _ in (1...count) {
		swap(&X[i], &Y[i])
		i += 1
	}
}

func digitsToBits(
	digits: [Digit],
	nbits: Int) -> UInt16
{
	var result: UInt16 = 0
	let ndigits = (nbits + 3) >> 2
	var dp = ndigits
//	while ndigits-- > 0 {
	for _ in (1...ndigits) {
		dp -= 1
		result = UInt16(result << 4) | UInt16(digits[dp])
	}
	let res = ((1 << nbits) - 1)
	
	return (result & UInt16(res))
}

func bitsToDigits(
	bits b: Int,
	destination digits: inout Digits14,
	start s: Int,
	count: Int)
{
	var start = s
	var bits = b
//	while count-- > 0 {
	for _ in (1...count) {
		digits[start] = Digit(bits & 0xF)
		start += 1
		bits >>= 4
	}
}

func orDigits(
	X: [Digit],
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
	X: [Digit],
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
	X: [Digit],
	start: Int,
	count: Int
	) -> [Digit]
{
	var x = X
	var idx = start + count - 1
//	for var idx = start + count - 1; idx > start; idx-- {
	while idx > start {
		x[idx] = x[idx-1]
		idx -= 1
	}
	x[start] = 0
	
	return x
}

func shiftDigitsRight(
	X: [Digit],
	start: Int,
	count: Int
	) -> [Digit]
{
	var x = X
	for idx in start+1..<start+count {
		x[idx-1] = x[idx]
	}
	x[start + count - 1] = 0
	
	return x
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
	destination: inout [Digit],
	from: Int,
	count: Int,
	carry: inout Bit,
	zero: inout Bit)
{
	var d: Int = 0
	var c = Int(carry)
	var z: Bit = 1
	
	for idx in from..<from+count {
		if op == .add {
			d = Int(firstNum[idx]) + Int(secondNum[idx]) + Int(c)
		} else {
			if mode == .dec_MODE {
				d = Int(firstNum[idx]) + 0x9 - Int(secondNum[idx]) + Int(c)
			} else {
				d = Int(firstNum[idx]) + 0xF - Int(secondNum[idx]) + Int(c)
			}
			if d < 0 {
				if TRACE != 0 {
					print("\(idx) - \(firstNum), \(secondNum) -> \(d)")
				}
			}
		}
		if mode == ArithMode.dec_MODE && d > 9 {
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

func adder(nib1: Digit, nib2: Digit) -> Digit
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

func subtractor(nib1: Digit, nib2: Digit) -> Digit
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
	_ source: Digits14,
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

func decToHex(_ dec: Int) -> String
{
	return NSString(format:"%2X", dec) as String
}
