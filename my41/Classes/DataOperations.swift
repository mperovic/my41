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

func copyDigits(src: Digits14, var sourceStartAt startS: Int, inout destination dst: Digits14, destinationStartAt startD: Int, count cnt: Int) {
	for idx in 0..<cnt {
		dst[startD+idx] = src[startS+idx]
	}
}

func fillDigits(var src: Digits14, value v: Digit, start startPos: Int, count cnt: Int) -> Digits14 {
	for idx in startPos..<startPos+cnt  {
		src[idx] = v
	}
	
	return src
}

func clearDigits(inout destination dst: [Digit]) {
	for idx in reverse(0...13) {
		dst[idx] = Digit(0)
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

func bitsToDigits(var bits aBits: Int, inout destination digits: Digits14, var start startPos: Int, var count cnt: Int) {
	while cnt-- > 0 {
		digits[startPos++] = Digit(aBits & 0xF)
		aBits >>= 4
	}
}

func orDigits(X x: [Digit], Y y: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
	var z: Digits14 = emptyDigit14
	for i in aStart..<aCount {
		z[i] = x[i] | y[i]
	}
	return z
}

func andDigits(X x: [Digit], Y y: [Digit], start aStart: Int, count aCount: Int) -> [Digit] {
	var z: Digits14 = emptyDigit14
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
func addOrSubtractDigits(arithOp op: ArithOp, arithMode mode: ArithMode, firstNum src1: [Digit], secondNum src2: [Digit], inout destination dst: [Digit], from start: Int, count cnt: Int, inout carry aCarry: Bit, inout zero aZero: Bit) {
	var d: Digit = 0
	var m: Digit = 0
	var i = start
	var c: Bit = aCarry
	var z: Bit = 1
	
	if op == .SUB {
		if mode == ArithMode.DEC_MODE {
			m = 0x9
		} else {
			m = 0xF
		}
	}
	for _ in 0..<cnt {
		if op == .ADD {
			d = src1[i] + src2[i] + Digit(c)
		} else {
			d = src1[i] + m - src2[i] + Digit(c)
		}
		if mode == ArithMode.DEC_MODE && d > 9 {
			d += 6
		}
		c = d >> 4
		d &= 0xf
		if d != 0 {
			z = 0
		}
		dst[i] = d
		++i
	}
	
	aCarry = c
	aZero = z
}
