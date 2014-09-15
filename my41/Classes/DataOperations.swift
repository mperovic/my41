//
//  DataOperations.swift
//  i41CV
//
//  Created by Miroslav Perovic on 8/10/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

enum ArithOp {
	case ADD
	case SUB
}

func copyDigits(src: Digits14, var sourceStartAt startS: Int, destination dst: Digits14, var destinationStartAt startD: Int, count cnt: Int) -> Digits14 {
	var result = dst
	for _ in 0..<cnt {
		result[startD++] = src[startS++]
	}
	
	return result
}

func fillDigits(var src: Digits14, value v: Digit, start startPos: Int, count cnt: Int) -> Digits14 {
	for idx in startPos..<startPos+cnt  {
		src[idx] = v
	}
	
	return src
}

func clearDigits(inout destination dst: [Digit]) {
//	for var idx: UInt8 = 13; idx >= 0; idx-- {
	for idx: UInt8 in reverse(13...0) {
		dst[Int(idx)] = Digit(0)
	}
}

func digitsToBitsWrap(digits aDigits: Digits14, inout bits aBits: Bits8, start aStart: Digit, var count cnt: Int) {
	var result: Bits8 = 0
	var i: Int = Int(aStart)
	var j: Digit = 0
	while cnt-- > 0 {
		result |= Bits8(aDigits[i] << j)
		i++
		if i > 13 {
			i = 0
		}
		j += 4
	}
	aBits = result
}

func bitsToDigitsWrap(var bits aBits: Bits8, inout digits aDigits: Digits14, start aStart: Digit, var count cnt: Int) {
	var i: Int = Int(aStart)
	while cnt-- > 0 {
		aDigits[i] = Digit(aBits & 0xF)
		aBits >>= 4
		++i
		if i > 13 {
			i = 0
		}
	}
}

func exchangeDigits(inout X x: Digits14, inout Y y: Digits14, startPos start: Int, var count cnt: Int) {
	var i = start
	while cnt-- > 0 {
		swap(&x[i], &y[i])
		++i
	}
}

func digitsToBits(digits aDigits: [Digit], nbits aNBits: Int) -> UInt16 {
	var result: UInt16 = 0
	var ndigits = (aNBits + 3) >> 2
	var dp = ndigits
	while ndigits-- > 0 {
		result = UInt16(result << 4) | UInt16(aDigits[--dp])
	}
	var res = ((1 << aNBits) - 1)
	
	return (result & UInt16(res))
}

func bitsToDigits(var bits aBits: Int, source src: Digits14, start startPos: Int, var count cnt: Int) -> Digits14 {
	var pos: Int = startPos
	var result = src
	while cnt-- > 0 {
		result[pos++] = Digit(aBits & 0xF)
		aBits >>= 4
	}
	
	return result
}

func orDigits(X x: [Digit], Y y: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
	var z = Digits14()
	for i in aStart..<aCount {
		z[i] = x[i] | y[i]
	}
	return z
}

func andDigits(X x: [Digit], Y y: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
	var z = Digits14()
	for i in aStart..<aCount {
		z[i] = x[i] & y[i]
	}
	return z
}

func shiftDigitsLeft(var X x: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
	for var idx = aStart + aCount - 1; idx > aStart; idx-- {
		x[idx] = x[idx-1]
	}
	x[aStart] = 0
	
	return x
}

func shiftDigitsRight(var X x: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
//	for var idx = aStart + 1; idx < aStart + aCount; idx++ {
	for idx in aStart+1..<aStart+aCount {
		x[idx-1] = x[idx]
	}
	x[aStart + aCount - 1] = 0
	
	return x
}

/*
   Perform a hex or decimal add or subtract operation on the specified
   range of digits. Carry is an inout parameter specifying the initial
   carry and returning the final carry. Zero is an out parameter returning
   true if all digits of the result are zero.
*/
func addOrSubtractDigits(arithOp op: ArithOp, arithMode mode: ArithMode, firstNum src1: [Digit], secondNum src2: [Digit], destination dst: [Digit], from start: Int, count cnt: Int, carry aCarry: Bit, zero aZero: Bit) -> (value: [Digit], newCarry: Bit, newZero: Bit) {
	var d: Digit = 0
	var m: Digit = 0
	var newCarry: Bit = aCarry
	var newZero: Bit = 1
	var i = start
	var value = dst
	
	if op == .SUB {
		if mode == ArithMode.DEC_MODE {
			m = 0x9
		} else {
			m = 0xF
		}
	}
	for _ in 0..<cnt {
		if op == .ADD {
			d = src1[i] + src2[i] + Digit(newCarry)
		} else {
			d = src1[i] + m - src2[i] + Digit(newCarry)
		}
		newCarry = d >> 4
		d &= 0xf
		if d != 0 {
			newZero = 0
		}
		value[i] = d
		++i
	}
	
	return (value, newCarry, newZero)
}
