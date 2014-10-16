//
//  Disassembly.swift
//  my41
//
//  Created by Miroslav Perovic on 9/27/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

enum DisassemblyMode: Int {
	case disassemblyHex = 0
	case disassemblyOct = 1
}

enum NumberMode {
	case Hex
	case Oct
}

struct NUTCode {
	var codeStr: String = ""
	var desc: String = ""
	var encoding: [String] = [String]()
}

class Disassembly {
	var numberMode: NumberMode = .Hex
	
	func bitRepresentation(var value intValue: Int, lenght aLenght: Int) -> String? {
		var max: Int = Int(pow(Double(2), Double(aLenght)) - 1)
		if intValue > max {
			return nil
		}
		
		var rep = ""
		for idx in reverse(0..<aLenght) {
			var m: Int = Int(pow(Double(2), Double(idx)))
			if intValue >= m {
				rep += "1"
				intValue -= m
			} else {
				rep += "0"
			}
		}
		
		return rep
	}

	func disassemblyClass0Line0(param: Int) -> NUTCode? {
		switch param {
		case 0x0:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0000_0000_00"])
			
		case 0x1:
			return NUTCode(codeStr: "WROM", desc: "Write ROM", encoding: ["0001_0000_00"])
			
		case 0x2, 0x3:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["\(digit!)_0000_00"])
			
		case 0x4:
			return NUTCode(codeStr: "ENROM1", desc: "Enable ROM bank 1", encoding: ["0100_0000_00"])

		case 0x5:
			return NUTCode(codeStr: "ENROM3", desc: "Enable ROM bank 3", encoding: ["0101_0000_00"])
			
		case 0x6:
			return NUTCode(codeStr: "ENROM2", desc: "Enable ROM bank 2", encoding: ["0110_0000_00"])
			
		case 0x7:
			return NUTCode(codeStr: "ENROM4", desc: "Enable ROM bank 4", encoding: ["0111_0000_00"])
			
		case 0xE, 0xF:
			return nil
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["\(digit!)_0000_00"])
		}
	}

	func disassemblyClass0Line1(param: Int) -> NUTCode? {
		switch param {
		case 0xE:
			return nil
			
		case 0xF:
			return NUTCode(codeStr: "CLRST", desc: "Clear ST", encoding: ["1111_0001_00"])
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "ST=0 \(param)", desc: "Clear Status bit", encoding: ["\(digit!)_0001_00"])
		}
	}
	
	func disassemblyClass0Line2(param: Int) -> NUTCode? {
		switch param {
		case 0xE:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0111_0010_00"])
			
		case 0xF:
			return NUTCode(codeStr: "RSTKB", desc: "Reset Keyboard", encoding: ["1111_0010_00"])

		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "ST=1 \(param)", desc: "Set Status bit", encoding: ["\(digit!)_0010_00"])
		}
	}

	func disassemblyClass0Line3(param: Int) -> NUTCode? {
		switch (param) {
		case 0xE:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0111_0011_00"])

		case 0xF:
			return NUTCode(codeStr: "CHKKB", desc: "Check Keyboard", encoding: ["1111_0011_00"])
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "ST=1? \(param)", desc: "Test Status Equal To One", encoding: ["\(digit!)_0011_00"])
		}
	}
	
	func disassemblyClass0Line4(param: Int) -> NUTCode? {
		let digit = bitRepresentation(value: param, lenght: 4)
		return NUTCode(codeStr: "LC \(param)", desc: "Load Constant", encoding: ["\(digit!)_0100_00"])
	}

	func disassemblyClass0Line5(param: Int) -> NUTCode? {
		switch (param) {
		case 0xE:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0111_0101_00"])
			
		case 0xF:
			return NUTCode(codeStr: "DECPT", desc: "Decrement Pointer", encoding: ["1111_0101_00"])
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "?PT=\(param)", desc: "Test Pointer Equal To", encoding: ["\(digit!)_0101_00"])
		}
	}
	
	func disassemblyClass0Line6(param: Int) -> NUTCode? {
		switch param {
		case 0x1:
			return NUTCode(codeStr: "G=C", desc: "Load G From C", encoding: ["0001_0110_00"])
			
		case 0x2:
			return NUTCode(codeStr: "C=G", desc: "Load C From G", encoding: ["0010_0110_00"])

		case 0x3:
			return NUTCode(codeStr: "CGEX", desc: "Exchange C and G", encoding: ["0011_0110_00"])
			
		case 0x5:
			return NUTCode(codeStr: "M=C", desc: "Load M from C", encoding: ["0101_0110_00"])
			
		case 0x6:
			return NUTCode(codeStr: "C=M", desc: "Load C From M", encoding: ["0110_0110_00"])
			
		case 0x7:
			return NUTCode(codeStr: "CMEX", desc: "Exchange C and M", encoding: ["0111_0110_00"])
			
		case 0x9:
			return NUTCode(codeStr: "F=SB", desc: "Load Flag Out from Status Byte", encoding: ["1001_0110_00"])
			
		case 0xA:
			return NUTCode(codeStr: "SB=F", desc: "Load Status Byte from Flag Out", encoding: ["1010_0110_00"])
			
		case 0xB:
			return NUTCode(codeStr: "FEXSB", desc: "Exchange Flag Out with Status Byte", encoding: ["1011_0110_00"])
			
		case 0xD:
			return NUTCode(codeStr: "ST=C", desc: "Load Status from C", encoding: ["1101_0110_00"])
			
		case 0xE:
			return NUTCode(codeStr: "C=ST", desc: "Load C From ST", encoding: ["1110_0110_00"])
			
		case 0xF:
			return NUTCode(codeStr: "CSTEX", desc: "Exchange C and ST", encoding: ["1110_0110_00"])
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["\(digit!)_0110_00"])
		}
	}
	
	func disassemblyClass0Line7(param: Int) -> NUTCode? {
		switch (param) {
		case 0xE:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0111_0111_00"])
			
		case 0xF:
			return NUTCode(codeStr: "INCPT", desc: "Increment Pointer", encoding: ["1111_0111_00"])
			
		default:
			return NUTCode(codeStr: "?PT=\(param)", desc: "Test Pointer Equal To", encoding: ["dddd_0111_00"])
		}
	}
	
	func disassemblyClass0Line8(param: Int) -> NUTCode? {
		switch param {
		case 0x0:
			return NUTCode(codeStr: "SPOPND", desc: "Pop Stack", encoding: ["0000_1000_00"])

		case 0x1:
			return NUTCode(codeStr: "POWOFF", desc: "Power Down", encoding: ["0001_1000_00", "0000_0000_00"])
			
		case 0x2:
			return NUTCode(codeStr: "SELP", desc: "Select Pointer P", encoding: ["0010_1000_00"])
			
		case 0x3:
			return NUTCode(codeStr: "SELQ", desc: "Select Pointer Q", encoding: ["0011_1000_00"])
			
		case 0x4:
			return NUTCode(codeStr: "?P=Q", desc: "Test P Equal To Q", encoding: ["0100_1000_00"])
			
		case 0x5:
			return NUTCode(codeStr: "?LLD", desc: "Low Level Detect", encoding: ["0101_1000_00"])
			
		case 0x6:
			return NUTCode(codeStr: "CLRABC", desc: "Clear A, B and C", encoding: ["0110_1000_00"])
			
		case 0x7:
			return NUTCode(codeStr: "GOTOC", desc: "Branch using C register", encoding: ["0111_1000_00"])
			
		case 0x8:
			return NUTCode(codeStr: "C=KEYS", desc: "Load C From KEYS", encoding: ["1000_1000_00"])
			
		case 0x9:
			return NUTCode(codeStr: "SETHEX", desc: "Set Hexadecimal Mode", encoding: ["1001_1000_00"])
			
		case 0xA:
			return NUTCode(codeStr: "SETDEC", desc: "Set Decimal Mode", encoding: ["1010_1000_00"])
			
		case 0xB:
			return NUTCode(codeStr: "DISOFF", desc: "Display off", encoding: ["1011_1000_00"])
			
		case 0xC:
			return NUTCode(codeStr: "DISTOG", desc: "Display Toggle", encoding: ["1100_1000_00"])
			
		case 0xD:
			return NUTCode(codeStr: "RTNC", desc: "Return from subroutine on Carry", encoding: ["1101_1000_00"])
			
		case 0xE:
			return NUTCode(codeStr: "RTNNC", desc: "Return from subroutine on No Carry", encoding: ["1110_1000_00"])
			
		case 0xF:
			return NUTCode(codeStr: "RTN", desc: "Return from subroutine", encoding: ["1111_1000_00"])
			
		default:
			return nil
		}
	}
	
	func disassemblyClass0Line9(param: Int) -> NUTCode? {
		let digit = bitRepresentation(value: param, lenght: 4)
		return NUTCode(codeStr: "SELPF \(param)", desc: "Select Peripheral", encoding: ["\(digit!)_1001_00"])
	}
	
	func disassemblyClass0LineA(param: Int) -> NUTCode? {
		let digit = bitRepresentation(value: param, lenght: 4)
		return NUTCode(codeStr: "REGN=C \(param)", desc: "Load Register from C", encoding: ["\(digit!)_1010_00"])
	}
	
	func disassemblyClass0LineB(param: Int) -> NUTCode? {
		switch param {
		case 0xE, 0xF:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["\(digit!)_1011_00"])

		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "?Fd=1", desc: "Test Flag Input Equal to One", encoding: ["\(digit!)_1011_00"])
		}
	}
	
	func disassemblyClass0LineC(param: Int) -> NUTCode? {
		switch param {
		case 0x0:
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["0000_1100_00"])
			
		case 0x1:
			return NUTCode(codeStr: "N=C", desc: "Load N from C", encoding: ["0001_1100_00"])
			
		case 0x2:
			return NUTCode(codeStr: "C=N", desc: "Load C From N", encoding: ["0010_1100_00"])
			
		case 0x3:
			return NUTCode(codeStr: "CNEX", desc: "Exchange C and N", encoding: ["0011_1100_00"])
			
		case 0x4:
			return NUTCode(codeStr: "LDI", desc: "Load Immediate", encoding: ["0100_1100_00"])
			
		default:
			let digit = bitRepresentation(value: param, lenght: 4)
			return NUTCode(codeStr: "NOP", desc: "No Operation", encoding: ["\(digit!)_1100_00"])
		}
	}
	
	struct DisassembledLine {
		var address: String? = nil
		var instruction: String? = nil
		var desc: String? = nil
		var sufix: String? = nil
		var nwords: Int? = 0
	}
	
	func disassembleInstruction(numberMode: NumberMode, programCounter: Int, word1: Int, word2: Int) -> DisassembledLine {
		var line = DisassembledLine()
		if word1 == 0x130 {
			line.desc = "LDI S&X"
			line.sufix = formatNumber(word2, bits: 10)
			line.nwords = 2
		} else {
			switch (word1 & 0x3) {
			case 0:
//				DisassembleClass0(word1, prefix, suffix);
				line.nwords = 1;
				
			case 1:
//				DisassembleClass1(word1, word2, prefix, suffix);
				line.nwords = 2;

			case 2:
//				DisassembleClass2(word1, prefix, suffix);
				line.nwords = 1;
				
			case 3:
//				DisassembleClass3(pc, word1, prefix, suffix);
				line.nwords = 1;

			default:
				break
			}
		}
		
		return line
	}
	
	func formatNumber(value: Int, bits: Int) -> String {
		switch numberMode {
		case .Hex:
			return NSString(format:"%0*X", (bits + 3) / 4, value) as String
		case .Oct:
			return NSString(format:"%0*o", (bits + 2) / 3, value) as String
		}
	}
}