//
//  RomChip.swift
//  my41
//
//  Created by Miroslav Perovic on 8/1/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

final class RomChip {
	var writable: Bool
	var words: [word]
	var actualBankGroup: byte
	var altPage: ModulePage?
	
	init(isWritable: Bool) {
		words = [word](count: 0x1000, repeatedValue: 0x0)
		writable = isWritable
		actualBankGroup = 1
	}
	convenience init(fromBIN bin: [byte], actualBankGroup bankGroup: byte) {
		self.init(isWritable: false)
		binToWords(bin)
		self.actualBankGroup = bankGroup
	}
	convenience init(fromFile path: String) {
		self.init(isWritable: false)
		loadFromFile(path)
	}
	convenience init() {
		self.init(isWritable: false)
	}
	
	func binToWords(bin: [byte]) {
		if bin.count == 0 {
			return
		}
		
		var ptr: Int = 0
		for var idx = 0; idx < 5120; idx += 5 {
			self.words[ptr++] = word(((word(bin[idx+1]) & 0x03) << 8) | word(bin[idx]))
			self.words[ptr++] = word(((word(bin[idx+2]) & 0x0f) << 6) | ((word(bin[idx+1]) & 0xfc) >> 2))
			self.words[ptr++] = word(((word(bin[idx+3]) & 0x3f) << 4) | ((word(bin[idx+2]) & 0xf0) >> 4))
			self.words[ptr++] = word((word(bin[idx+4]) << 2) | ((word(bin[idx+3]) & 0xc0) >> 6))
		}
	}
	
	func loadFromFile(path: String) {
		let data = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
		var range = NSRange(location: 0, length: 2)
		for idx in 0..<0x1000 {
			var i16be: UInt16 = 0
			var i16: UInt16 = 0
			data?.getBytes(&i16be, range: range)
			range.location += 2
			i16 = UInt16(bigEndian: i16be)
			
			words[idx] = i16
		}
	}
	
	subscript(addr: Int) -> UInt16 {
		get {
			return words[addr]
		}
		
		set {
			if writable {
				words[addr] = newValue
			}
		}
	}
}