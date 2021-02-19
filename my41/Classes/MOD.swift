//
//  modObject.swift
//  my41
//
//  Created by Miroslav Perovic on 8/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

let MOD_FORMAT = "MOD1"

/* Module type codes */
enum Category: byte {
	case `undef`					= 0		// not categorized
	case os						= 1		// base Operating System for C,CV,CX
	case hpApplicationPAC		= 2		// HP Application PACs
	case hpilPeripheral			= 3		// any HP-IL related modules and devices
	case standardPeripheral		= 4		// standard Peripherals: Wand, Printer, Card Reader, XFuns/Mem, Service, Time, IR Printer
	case customPeripheral		= 5		// custom Peripherals: AECROM, CCD, HEPAX, PPC, ZENROM, etc
	case beta					= 6		// BETA releases not fully debugged and finished
	case experimental			= 7		// test programs not meant for normal usage
}
let categoryMax: byte			= 7		// maximum CATEGORY_ define value

/* Hardware codes */
enum Hardware: byte {
	case none					= 0		// no additional hardware specified
	case printer				= 1		// 82143A Printer
	case cardReader				= 2		// 82104A Card Reader
	case timer					= 3		// 82182A Time Module or HP-41CX built in timer
	case wand					= 4		// 82153A Barcode Wand
	case hpil					= 5		// 82160A HP-IL Module
	case infrared				= 6		// 82242A Infrared Printer Module
	case hepax					= 7		// HEPAX Module - has special hardware features (write protect, relocation)
	case wwramBox				= 8		// W&W RAMBOX - has special hardware features (RAM block swap instructions)
	case mldl2000				= 9		// MLDL2000
	case clonix					= 10	// CLONIX-41 Module
}
let hardwareMax: byte			= 10	// maximum HARDWARE_ define value

/* 
   relative position codes- do not mix these in a group except ODD/EVEN and UPPER/LOWER
   ODD/EVEN, UPPER/LOWER can only place ROMS in 16K blocks
*/
enum Position: byte {
	case positionAny			= 0x1f	// position in any port page (8-F)
	case positionLower			= 0x2f	// position in lower port page relative to any upper image(s) (8-F)
	case positionUpper			= 0x3f	// position in upper port page
	case positionEven			= 0x4f	// position in any even port page (8,A,C,E)
	case positionOdd			= 0x5f	// position in any odd port page (9,B,D,F)
	case positionOrdered		= 0x6f	// position sequentially in MOD file order, one image per page regardless of bank
}
let positionMin: byte			= 0x1f	// minimum POSITION_ define value
let positionMax: byte			= 0x6f	// maximum POSITION_ define value

let pageSize					= 5188	// Size of ModulePageFile Struct
let headerSize					= 729	// Size of ModuleFileHeader Struct

struct ModuleFilePage {
	var name: [CChar]			// normally the name of the original .ROM file, if any
	var ID: [CChar]				// ROM ID code, normally two letters and a number are ID and last letter is revision - if all zeros, will show up as @@@@
	var page: byte				// the page that this image must be in (0-F, although 8-F is not normally used) or defines each page's position relative to other images in a page group, see codes below
	var pageGroup: byte			// 0=not grouped, otherwise images with matching PageGroup values (1..8) are grouped according to POSITION code */
	var bank: byte				// the bank that this image must be in (1-4)
	var bankGroup: byte			// 0=not grouped, otherwise images with matching BankGroup values (1..8) are bankswitched with each other
	var RAM: byte				// 0=ROM, 1=RAM - normally RAM pages are all blank if Original=1
	var writeProtect: byte		// 0=No or N/A, 1=protected - for HEPAX RAM and others that might support it
	var FAT: byte				// 0=no FAT, 1=has FAT
	var image: [byte]			// the image in packed format (.BIN file format)
	var pageCustom: [byte]		// for special hardware attributes
	
	init() {
		name = [CChar](repeating: 0, count: 20)
		ID = [CChar](repeating: 0, count: 9)
		page = 0
		pageGroup = 0
		bank = 0
		bankGroup = 0
		RAM = 0
		writeProtect = 0
		FAT = 0
		image = [byte](repeating: 0, count: 5120)
		pageCustom = [byte](repeating: 0, count: 32)
	}
}

struct ModuleFileHeader {
	var fileFormat = [CChar](repeating: 0, count: 5)		// constant value defines file format and revision
	var title = [CChar](repeating: 0, count: 50)			// the full module name (the short name is the name of the file itself)
	var version = [CChar](repeating: 0, count: 10)			// module version, if any
	var partNumber = [CChar](repeating: 0, count: 20)		// module part number
	var author = [CChar](repeating: 0, count: 50)			// author, if any
	var copyright = [CChar](repeating: 0, count: 100)		// copyright notice, if any
	var license = [CChar](repeating: 0, count: 200)			// license terms, if any
	var comments = [CChar](repeating: 0, count: 255)		// free form comments, if any
	var category = Category.undef							// module category, see codes below
	var hardware = Hardware.none							// defines special hardware that module contains
	var memModules = byte(0)								// defines number of main memory modules (0-4)
	var XMemModules = byte(0)								// defines number of extended memory modules (0=none, 1=Xfuns/XMem, 2,3=one or two additional XMem modules)
	var original = byte(0)									// allows validation of original contents: 1=images and data are original, 0=this file has been updated by a user application (data in RAM written back to MOD file, etc)
	var appAutoUpdate = byte(0)								// tells any application to: 1=overwrite this file automatically when saving other data, 0=do not update
	var numPages = byte(0)									// the number of pages in this file (0-256, but normally between 1-6)
	var headerCustom = [byte](repeating: 0, count: 32)		// for special hardware attributes
}

// Module Memory Structures - see MOD file structures for field descriptions
final class ModuleHeader {
	var fullFileName = ""
	var fileFormat = ""
	var title = ""
	var version = ""
	var partNumber = ""
	var author = ""
	var copyright = ""
	var license = ""
	var comments = ""
	var category = Category.undef
	var hardware = Hardware.none
	var memModules = byte(0)
	var XMemModules = byte(0)
	var original = byte(0)
	var appAutoUpdate = byte(0)
	var numPages = byte(0)
}

class Box<T> {
	var unbox: T
	init (_ value: T) {
		unbox = value
	}
}

final class ModulePage {
	var moduleHeader: ModuleHeader?		// pointer to module that this page is a part of, or NULL if none
	var altPage: ModulePage?			// pointer to alternate page if any (HEPAX, W&W RAMBOX2 use)
	var name = ""
	var ID = ""
	var page = byte(0)					// file data - unchanged
	var actualPage = byte(0)			// running data- the actual location this page is loaded in
	var pageGroup = byte(0)				// file data - unchanged
	var bank = byte(0)
	var bankGroup = byte(0)				// file data - unchanged
	var actualBankGroup = byte(0)		// running data - BankGroup is unique to file only
	var RAM = byte(0)
	var writeProtect = byte(0)
	var FAT = byte(0)					// could be incorrectly set to false if a .ROM file loaded
	var HEPAX = byte(0)					// if a HEPAX page
	var WWRAMBOX = byte(0)				// if a W&W RAMBOX page
	var image = [byte](repeating: 0, count: 4096)
}

enum CheckPageError: Error {
	case pageOutOfRange
	case pageGroupOutOfRange
	case bankOutOfRange
	case bankGroupOutOfRange
	case nonGroupedPagesError
	case ramOutOfRange
	case writeProtect
	case fatOutOfRange
}

struct MOD: Hashable {
	var data: Data?
	var shortName: String?
	var fileSize = 0
	var moduleHeader = ModuleHeader()
	var modulePages = [ModulePage]()
	
	var memoryCheck: Bool

	init (memoryCheck: Bool) {
		data = nil
		self.memoryCheck = memoryCheck
	}
	
	static func == (lhs: MOD, rhs: MOD) -> Bool {
		lhs.moduleHeader.title == rhs.moduleHeader.title
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(moduleHeader.title)
	}

	init?(modName: String, withMemoryCheck memoryCheck: Bool) throws {
		self.init(memoryCheck: memoryCheck)

		try self.readModFromFile(modName, withMemoryCheck: memoryCheck)
	}
	
	func is41C() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .os && sName.range(of: "nut-c.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	func is41CV() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .os && sName.range(of: "nut-cv.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	func is41CX() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .os && sName.range(of: "nut-cx.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	// Check Page
	func checkPage(_ page: ModulePage) throws {
		if page.page > 0x0f && page.page < positionMin {
			throw CheckPageError.pageOutOfRange
		}
		if page.page > positionMax && page.pageGroup > 8 {
			throw CheckPageError.pageOutOfRange
		}
		
		// out of range values
		if page.bank == 0 || page.bank > 4 {
			throw CheckPageError.bankOutOfRange
		}
		if page.bankGroup > 8 {
			throw CheckPageError.bankGroupOutOfRange
		}
		if page.RAM > 1 {
			throw CheckPageError.ramOutOfRange
		}
		if page.writeProtect > 1 {
			throw CheckPageError.writeProtect
		}
		if page.FAT > 1 {
			throw CheckPageError.fatOutOfRange
		}
		
		// group pages cannot use non-grouped position codes
		if page.pageGroup == 1 && page.page <= Position.positionAny.rawValue {
			throw CheckPageError.pageGroupOutOfRange
		}
		
		// non-grouped pages cannot use grouped position codes
		if page.pageGroup == 0 && page.page > Position.positionAny.rawValue {
			throw CheckPageError.nonGroupedPagesError
		}
	}
	
	func populateModuleHeader() {
		var header = ModuleFileHeader()

		// header.fileFormat
		let fileFormat = UnsafeMutableBufferPointer(start: &header.fileFormat, count: 5)
		let _ = data?.copyBytes(to: fileFormat, from: 0..<5)
//		data!.getBytes(&header.fileFormat, range: NSMakeRange(0, 5))
		
		// title
		let title = UnsafeMutableBufferPointer(start: &header.title, count: 50)
		let _ = data?.copyBytes(to: title, from: 5..<55)
//		data!.getBytes(&header.title, range: NSMakeRange(5, 50))
		
		// version
		let version = UnsafeMutableBufferPointer(start: &header.version, count: 10)
		let _ = data?.copyBytes(to: version, from: 55..<65)
//		data!.getBytes(&header.version, range: NSMakeRange(55, 10))
		
		// partNumber
		let partNumber = UnsafeMutableBufferPointer(start: &header.partNumber, count: 20)
		let _ = data?.copyBytes(to: partNumber, from: 65..<85)
//		data!.getBytes(&header.partNumber, range: NSMakeRange(65, 20))
		
		// author
		let author = UnsafeMutableBufferPointer(start: &header.author, count: 50)
		let _ = data?.copyBytes(to: author, from: 85..<135)
//		data!.getBytes(&header.author, range: NSMakeRange(85, 50))
		
		// copyright
		let copyright = UnsafeMutableBufferPointer(start: &header.copyright, count: 100)
		let _ = data?.copyBytes(to: copyright, from: 135..<235)
//		data!.getBytes(&header.copyright, range: NSMakeRange(135, 100))
		
		// license
		let license = UnsafeMutableBufferPointer(start: &header.license, count: 200)
		let _ = data?.copyBytes(to: license, from: 235..<435)
//		data!.getBytes(&header.license, range: NSMakeRange(235, 200))
		
		// comments
		let comments = UnsafeMutableBufferPointer(start: &header.comments, count: 255)
		let _ = data?.copyBytes(to: comments, from: 435..<690)
//		data!.getBytes(&header.comments, range: NSMakeRange(435, 255))

		// category
		let category = UnsafeMutableBufferPointer(start: &header.category, count: 1)
		let _ = data?.copyBytes(to: category, from: 690..<691)
//		data!.getBytes(&header.category, range: NSMakeRange(690, 1))

		// hardware
		let hardware = UnsafeMutableBufferPointer(start: &header.hardware, count: 1)
		let _ = data?.copyBytes(to: hardware, from: 691..<692)
//		data!.getBytes(&header.hardware, range: NSMakeRange(691, 1))

		// memModules
		let memModules = UnsafeMutableBufferPointer(start: &header.memModules, count: 1)
		let _ = data?.copyBytes(to: memModules, from: 692..<693)
//		data!.getBytes(&header.memModules, range: NSMakeRange(692, 1))

		// XMemModules
		let XMemModules = UnsafeMutableBufferPointer(start: &header.XMemModules, count: 1)
		let _ = data?.copyBytes(to: XMemModules, from: 693..<694)
//		data!.getBytes(&header.XMemModules, range: NSMakeRange(693, 1))

		// original
		let original = UnsafeMutableBufferPointer(start: &header.original, count: 1)
		let _ = data?.copyBytes(to: original, from: 694..<695)
//		data!.getBytes(&header.original, range: NSMakeRange(694, 1))

		// appAutoUpdate
		let appAutoUpdate = UnsafeMutableBufferPointer(start: &header.appAutoUpdate, count: 1)
		let _ = data?.copyBytes(to: appAutoUpdate, from: 695..<696)
//		data!.getBytes(&header.appAutoUpdate, range: NSMakeRange(695, 1))

		// numPages
		let numPages = UnsafeMutableBufferPointer(start: &header.numPages, count: 1)
		let _ = data?.copyBytes(to: numPages, from: 696..<697)
//		data!.getBytes(&header.numPages, range: NSMakeRange(696, 1))

		// headerCustom
		let headerCustom = UnsafeMutableBufferPointer(start: &header.headerCustom, count: 32)
		let _ = data?.copyBytes(to: headerCustom, from: 697..<729)
//		data!.getBytes(&header.headerCustom, range: NSMakeRange(697, 32))
		
		moduleHeader.fileFormat = convertCCharToString(header.fileFormat)
		moduleHeader.title = convertCCharToString(header.title)
		moduleHeader.version = convertCCharToString(header.version)
		moduleHeader.partNumber = convertCCharToString(header.partNumber)
		moduleHeader.author = convertCCharToString(header.author)
		moduleHeader.comments = convertCCharToString(header.comments)
		moduleHeader.category = header.category
		moduleHeader.hardware = header.hardware
		moduleHeader.memModules = header.memModules
		moduleHeader.XMemModules = header.XMemModules
		moduleHeader.original = header.original
		moduleHeader.appAutoUpdate = header.appAutoUpdate
		moduleHeader.numPages = header.numPages
	}
	
	enum modHeaderError: Error {
		case wrongFileSize
		case noModExtension
		case tooManyMEMModules
		case tooManyXMEMModules
		case wrongOriginalValue
		case wrongAppAutoUpdateValue
		case wrongCategoryValue
		case wrongHardwareValue
	}
	
	func validateModuleHeader() throws {
		// check size
		guard fileSize == headerSize + Int(moduleHeader.numPages) * pageSize else { throw modHeaderError.wrongFileSize }
		
		guard moduleHeader.fileFormat.hasPrefix(MOD_FORMAT) else { throw modHeaderError.noModExtension }
		
		let mem = bus.memModules + moduleHeader.memModules
		guard mem <= 4 else { throw modHeaderError.tooManyMEMModules }
		
		let xmem = bus.XMemModules + moduleHeader.XMemModules
		guard xmem <= 3 else { throw modHeaderError.tooManyXMEMModules }
		
		guard moduleHeader.original <= 1 else { throw modHeaderError.wrongOriginalValue }
		
		guard moduleHeader.appAutoUpdate <= 1 else { throw modHeaderError.wrongAppAutoUpdateValue }
		
		guard moduleHeader.category.rawValue <= categoryMax else { throw modHeaderError.wrongCategoryValue }
		
		guard moduleHeader.hardware.rawValue <= hardwareMax else { throw modHeaderError.wrongHardwareValue }
	}
	
	mutating func populateModulePage(_ pageNo: Int) {
		var startPosition: Int = headerSize + (pageSize * pageNo)
		var page = ModuleFilePage()
		
		// name
		let name = UnsafeMutableBufferPointer(start: &page.name, count: 20)
		let _ = data?.copyBytes(to: name, from: startPosition..<startPosition+20)
		startPosition += 20
//		data!.getBytes(&page.name, range: NSMakeRange(startPosition, 20))

		// ID
		let ID = UnsafeMutableBufferPointer(start: &page.ID, count: 9)
		let _ = data?.copyBytes(to: ID, from: startPosition..<startPosition+9)
		startPosition += 9
//		data!.getBytes(&page.ID, range: NSMakeRange(startPosition+20, 9))

		// page
		let ppage = UnsafeMutableBufferPointer(start: &page.page, count: 1)
		let _ = data?.copyBytes(to: ppage, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.page, range: NSMakeRange(startPosition+29, 1))

		// pageGroup
		let pageGroup = UnsafeMutableBufferPointer(start: &page.pageGroup, count: 1)
		let _ = data?.copyBytes(to: pageGroup, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.pageGroup, range: NSMakeRange(startPosition+30, 1))

		// bank
		let bank = UnsafeMutableBufferPointer(start: &page.bank, count: 1)
		let _ = data?.copyBytes(to: bank, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.bank, range: NSMakeRange(startPosition+31, 1))

		// bankGroup
		let bankGroup = UnsafeMutableBufferPointer(start: &page.bankGroup, count: 1)
		let _ = data?.copyBytes(to: bankGroup, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.bankGroup, range: NSMakeRange(startPosition+32, 1))

		// RAM
		let RAM = UnsafeMutableBufferPointer(start: &page.RAM, count: 1)
		let _ = data?.copyBytes(to: RAM, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.RAM, range: NSMakeRange(startPosition+33, 1))

		// writeProtect
		let writeProtect = UnsafeMutableBufferPointer(start: &page.writeProtect, count: 1)
		let _ = data?.copyBytes(to: writeProtect, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.writeProtect, range: NSMakeRange(startPosition+34, 1))

		// FAT
		let FAT = UnsafeMutableBufferPointer(start: &page.FAT, count: 1)
		let _ = data?.copyBytes(to: FAT, from: startPosition..<startPosition+1)
		startPosition += 1
//		data!.getBytes(&page.FAT, range: NSMakeRange(startPosition+35, 1))

		// image
		let image = UnsafeMutableBufferPointer(start: &page.image, count: 5120)
		let _ = data?.copyBytes(to: image, from: startPosition..<startPosition+5120)
		startPosition += 5120
//		data!.getBytes(&page.image, range: NSMakeRange(startPosition+36, 5120))

		// pageCustom
		let pageCustom = UnsafeMutableBufferPointer(start: &page.pageCustom, count: 32)
		let _ = data?.copyBytes(to: pageCustom, from: startPosition..<startPosition+32)
		startPosition += 32
//		data!.getBytes(&page.pageCustom, range: NSMakeRange(startPosition+5156, 32))

		let modulePage = ModulePage()
		modulePage.moduleHeader = self.moduleHeader
		modulePage.name = convertCCharToString(page.name)
		modulePage.ID = convertCCharToString(page.ID)
		modulePage.page = page.page
		modulePage.pageGroup = page.pageGroup
		modulePage.bank = page.bank
		modulePage.bankGroup = page.bankGroup
		modulePage.RAM = page.RAM
		modulePage.writeProtect = page.writeProtect
		modulePage.FAT = page.FAT
		modulePage.image = page.image

		modulePages.append(modulePage)
	}
	
	enum readModFileError: Error {
		case errorLoadingFile
	}
	
	mutating func readModFromFile(_ filename: String, withMemoryCheck memoryCheck: Bool) throws {
		// Read the file
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: filename) {
			do {
				let fileAttributes: NSDictionary = try fileManager.attributesOfItem(atPath: filename) as NSDictionary
				self.fileSize = fileAttributes[FileAttributeKey.size]! as! Int
				self.data = try Data(contentsOf: URL(fileURLWithPath: filename), options: [.mappedIfSafe])
				self.shortName = (filename as NSString).lastPathComponent.lowercased()
				moduleHeader.fullFileName = filename
				
				populateModuleHeader()
				
				if memoryCheck {
					try validateModuleHeader()
				}
				bus.memModules += moduleHeader.memModules
				bus.XMemModules += moduleHeader.XMemModules
				
				for idx: UInt8 in 0..<moduleHeader.numPages {
					populateModulePage(Int(idx))
				}
			} catch let error as NSError {
				data = nil
				displayAlert(error.localizedDescription)
			}
		} else {
			data = nil
		}
		
//		description()
	}
	
	func categoryDescription() -> String? {
		guard self.data != nil else { return nil }
		
		switch moduleHeader.category {
		case .undef:
			return "Undefined"
		case .os:
			return "Operating system"
		case .hpApplicationPAC:
			return "HP Application PACs"
		case .hpilPeripheral:
			return "HP-IL related modules and devices"
		case .standardPeripheral:
			return "Standard Peripherals"
		case .customPeripheral:
			return "Custom Peripherals"
		case .beta:
			return "BETA releases"
		case .experimental:
			return "Test programs"
		}
	}
	
	func hardwareDescription() -> String? {
		guard self.data != nil else { return nil }
		
		switch moduleHeader.hardware {
		case .none:
			return "no additional hardware specified"
		case .printer:
			return "82143A Printer"
		case .cardReader:
			return "82104A Card Reader"
		case .timer:
			if is41CX() {
				return "HP-41CX built in timer"
			} else {
				return "82182A Time Module"
			}
		case .wand:
			return "82153A Barcode Wand"
		case .hpil:
			return "82160A HP-IL Module"
		case .infrared:
			return "82242A Infrared Printer Module"
		case .hepax:
			return "HEPAX Module"
		case .wwramBox:
			return "W&W RAMBOX"
		case .mldl2000:
			return "MLDL2000"
		case .clonix:
			return "CLONIX-41 Module"
		}
	}
	
	func description() {
		headerDescription()
		for idx: UInt8 in 0..<moduleHeader.numPages {
			pageDescription(idx)
		}
	}
	
	func headerDescription() {
		print(">>>>>     HEADER     <<<<<")
		print("fileFormat: \(moduleHeader.fileFormat)")
		print("title: \(moduleHeader.title)")
		print("version: \(moduleHeader.version)")
		print("partNumber: \(moduleHeader.partNumber)")
		print("copyright: \(moduleHeader.copyright)")
		print("author: \(moduleHeader.author)")
		print("license: \(moduleHeader.license)")
		print("comments: \(moduleHeader.comments)")
		print("category: \(moduleHeader.category)")
		print("hardware: \(moduleHeader.hardware)")
		print("memModules: \(moduleHeader.memModules)")
		print("XMemModules: \(moduleHeader.XMemModules)")
		print("original: \(moduleHeader.original)")
		print("appAutoUpdate: \(moduleHeader.appAutoUpdate)")
		print("numPages: \(moduleHeader.numPages)")
		print(">>>>>     END HEADER     <<<<<")
	}
	
	func pageDescription(_ pageNo: UInt8) {
		let page = modulePages[Int(pageNo)]
		print(">>>>>     PAGE: \(pageNo)     <<<<<")
		print("name: \(page.name)")
		print("ID: \(page.ID)")
		print("page: \(page.page)")
		print("pageGroup: \(page.pageGroup)")
		print("bank: \(page.bank)")
		print("bankGroup: \(page.bankGroup)")
		print("RAM: \(page.RAM)")
		print("writeProtect: \(page.writeProtect)")
		print(">>>>>     END PAGE     <<<<<")
	}
}

func convertCCharToString(_ cstring: [CChar]) -> String {
	return NSString(bytes: cstring, length: Int(cstring.count), encoding: String.Encoding.ascii.rawValue)! as String
}
