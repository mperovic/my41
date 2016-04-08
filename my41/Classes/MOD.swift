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
	case Undef					= 0		// not categorized
	case OS						= 1		// base Operating System for C,CV,CX
	case HPApplicationPAC		= 2		// HP Application PACs
	case HPILPeripheral			= 3		// any HP-IL related modules and devices
	case StandardPeripheral		= 4		// standard Peripherals: Wand, Printer, Card Reader, XFuns/Mem, Service, Time, IR Printer
	case CustomPeripheral		= 5		// custom Peripherals: AECROM, CCD, HEPAX, PPC, ZENROM, etc
	case Beta					= 6		// BETA releases not fully debugged and finished
	case Experimental			= 7		// test programs not meant for normal usage
}
let CategoryMax: byte			= 7		// maximum CATEGORY_ define value

/* Hardware codes */
enum Hardware: byte {
	case None					= 0		// no additional hardware specified
	case Printer				= 1		// 82143A Printer
	case CardReader				= 2		// 82104A Card Reader
	case Timer					= 3		// 82182A Time Module or HP-41CX built in timer
	case WAND					= 4		// 82153A Barcode Wand
	case HPIL					= 5		// 82160A HP-IL Module
	case Infrared				= 6		// 82242A Infrared Printer Module
	case HEPAX					= 7		// HEPAX Module - has special hardware features (write protect, relocation)
	case WWRAMBox				= 8		// W&W RAMBOX - has special hardware features (RAM block swap instructions)
	case MLDL2000				= 9		// MLDL2000
	case CLONIX					= 10	// CLONIX-41 Module
}
let HardwareMax: byte			= 10	// maximum HARDWARE_ define value

/* 
   relative position codes- do not mix these in a group except ODD/EVEN and UPPER/LOWER
   ODD/EVEN, UPPER/LOWER can only place ROMS in 16K blocks
*/
enum Position: byte {
	case PositionAny			= 0x1f	// position in any port page (8-F)
	case PositionLower			= 0x2f	// position in lower port page relative to any upper image(s) (8-F)
	case PositionUpper			= 0x3f	// position in upper port page
	case PositionEven			= 0x4f	// position in any even port page (8,A,C,E)
	case PositionOdd			= 0x5f	// position in any odd port page (9,B,D,F)
	case PositionOrdered		= 0x6f	// position sequentially in MOD file order, one image per page regardless of bank
}
let PositionMin: byte			= 0x1f	// minimum POSITION_ define value
let PositionMax: byte			= 0x6f	// maximum POSITION_ define value

let PageSize					= 5188	// Size of ModulePageFile Struct
let HeaderSize					= 729	// Size of ModuleFileHeader Struct

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
		name = [CChar](count: 20, repeatedValue: 0)
		ID = [CChar](count: 9, repeatedValue: 0)
		page = 0
		pageGroup = 0
		bank = 0
		bankGroup = 0
		RAM = 0
		writeProtect = 0
		FAT = 0
		image = [byte](count: 5120, repeatedValue: 0)
		pageCustom = [byte](count: 32, repeatedValue: 0)
	}
}

struct ModuleFileHeader {
	var fileFormat: [CChar]			// constant value defines file format and revision
	var title: [CChar]				// the full module name (the short name is the name of the file itself)
	var version: [CChar]			// module version, if any
	var partNumber: [CChar]			// module part number
	var author: [CChar]				// author, if any
	var copyright: [CChar]			// copyright notice, if any
	var license: [CChar]			// license terms, if any
	var comments: [CChar]			// free form comments, if any
	var category: Category			// module category, see codes below
	var hardware: Hardware			// defines special hardware that module contains
	var memModules: byte			// defines number of main memory modules (0-4)
	var XMemModules: byte			// defines number of extended memory modules (0=none, 1=Xfuns/XMem, 2,3=one or two additional XMem modules)
	var original: byte				// allows validation of original contents: 1=images and data are original, 0=this file has been updated by a user application (data in RAM written back to MOD file, etc)
	var appAutoUpdate: byte			// tells any application to: 1=overwrite this file automatically when saving other data, 0=do not update
	var numPages: byte				// the number of pages in this file (0-256, but normally between 1-6)
	var headerCustom: [byte]		// for special hardware attributes
	
	init () {
		fileFormat = [CChar](count: 5, repeatedValue: 0)
		title = [CChar](count: 50, repeatedValue: 0)
		version = [CChar](count: 10, repeatedValue: 0)
		partNumber = [CChar](count: 20, repeatedValue: 0)
		author = [CChar](count: 50, repeatedValue: 0)
		copyright = [CChar](count: 100, repeatedValue: 0)
		license = [CChar](count: 200, repeatedValue: 0)
		comments = [CChar](count: 255, repeatedValue: 0)
		category = .Undef
		hardware = .None
		memModules = 0
		XMemModules = 0
		original = 0
		appAutoUpdate = 0
		numPages = 0
		headerCustom = [byte](count: 32, repeatedValue: 0)
	}
}

// Module Memory Structures - see MOD file structures for field descriptions
class ModuleHeader {
	var fullFileName: String
	var fileFormat: String
	var title: String
	var version: String
	var partNumber: String
	var author: String
	var copyright: String
	var license: String
	var comments: String
	var category: Category
	var hardware: Hardware
	var memModules: byte
	var XMemModules: byte
	var original: byte
	var appAutoUpdate: byte
	var numPages: byte
	
	init() {
		fullFileName = ""
		fileFormat = ""
		title = ""
		version = ""
		partNumber = ""
		author = ""
		copyright = ""
		license = ""
		comments = ""
		category = .Undef
		hardware = .None
		memModules = 0
		XMemModules = 0
		original = 0
		appAutoUpdate = 0
		numPages = 0
	}
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
	var name: String
	var ID: String
	var page: byte						// file data - unchanged
	var actualPage: byte				// running data- the actual location this page is loaded in
	var pageGroup: byte					// file data - unchanged
	var bank: byte
	var bankGroup: byte					// file data - unchanged
	var actualBankGroup: byte			// running data - BankGroup is unique to file only
	var RAM: byte
	var writeProtect: byte
	var FAT: byte						// could be incorrectly set to false if a .ROM file loaded
	var HEPAX: byte						// if a HEPAX page
	var WWRAMBOX: byte					// if a W&W RAMBOX page
	var image: [byte]
	
	init() {
		name = ""
		ID = ""
		page = 0
		actualPage = 0
		pageGroup = 0
		bank = 0
		bankGroup = 0
		actualBankGroup = 0
		RAM = 0
		writeProtect = 0
		FAT = 0
		HEPAX = 0
		WWRAMBOX = 0
		image = [byte](count: 4096, repeatedValue: 0)
	}
}

enum CheckPageError: ErrorType {
	case pageOutOfRange
	case pageGroupOutOfRange
	case bankOutOfRange
	case bankGroupOutOfRange
	case nonGroupedPagesError
	case ramOutOfRange
	case writeProtect
	case fatOutOfRange
}

final class MOD {
	var data: NSData?
	var shortName: String?
	var fileSize = 0
	var moduleHeader = ModuleHeader()
	var modulePages = [ModulePage]()

	init () {
		data = nil
	}
	
	func is41C() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .OS && sName.rangeOfString("nut-c.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	func is41CV() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .OS && sName.rangeOfString("nut-cv.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	func is41CX() -> Bool {
		if let sName = self.shortName {
			if moduleHeader.category == .OS && sName.rangeOfString("nut-cx.mod") != nil {
				return true
			}
		}
		
		return false
	}
	
	// Check Page
	func checkPage(page: ModulePage) throws {
		if page.page > 0x0f && page.page < PositionMin {
			throw CheckPageError.pageOutOfRange
		}
		if page.page > PositionMax && page.pageGroup > 8 {
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
		if page.pageGroup == 1 && page.page <= Position.PositionAny.rawValue {
			throw CheckPageError.pageGroupOutOfRange
		}
		
		// non-grouped pages cannot use grouped position codes
		if page.pageGroup == 0 && page.page > Position.PositionAny.rawValue {
			throw CheckPageError.nonGroupedPagesError
		}
	}
	
	func populateModuleHeader() {
		var header = ModuleFileHeader()
		data!.getBytes(&header.fileFormat, range: NSMakeRange(0, 5))
		data!.getBytes(&header.title, range: NSMakeRange(5, 50))
		data!.getBytes(&header.version, range: NSMakeRange(55, 10))
		data!.getBytes(&header.partNumber, range: NSMakeRange(65, 20))
		data!.getBytes(&header.author, range: NSMakeRange(85, 50))
		data!.getBytes(&header.copyright, range: NSMakeRange(135, 100))
		data!.getBytes(&header.license, range: NSMakeRange(235, 200))
		data!.getBytes(&header.comments, range: NSMakeRange(435, 255))
		data!.getBytes(&header.category, range: NSMakeRange(690, 1))
		data!.getBytes(&header.hardware, range: NSMakeRange(691, 1))
		data!.getBytes(&header.memModules, range: NSMakeRange(692, 1))
		data!.getBytes(&header.XMemModules, range: NSMakeRange(693, 1))
		data!.getBytes(&header.original, range: NSMakeRange(694, 1))
		data!.getBytes(&header.appAutoUpdate, range: NSMakeRange(695, 1))
		data!.getBytes(&header.numPages, range: NSMakeRange(696, 1))
		data!.getBytes(&header.headerCustom, range: NSMakeRange(697, 32))
		
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
	
	enum modHeaderError: ErrorType {
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
		if fileSize != HeaderSize + Int(moduleHeader.numPages) * PageSize {
			throw modHeaderError.wrongFileSize
		}
		
		if !moduleHeader.fileFormat.hasPrefix(MOD_FORMAT) {
			throw modHeaderError.noModExtension
		}
		
		let mem = bus.memModules + moduleHeader.memModules
		if mem > 4 {
			throw modHeaderError.tooManyMEMModules
		}
		
		let xmem = bus.XMemModules + moduleHeader.XMemModules
		if xmem > 3 {
			throw modHeaderError.tooManyXMEMModules
		}
		
		if moduleHeader.original > 1 {
			throw modHeaderError.wrongOriginalValue
		}
		
		if moduleHeader.appAutoUpdate > 1 {
			throw modHeaderError.wrongAppAutoUpdateValue
		}
		
		if moduleHeader.category.rawValue > CategoryMax {
			throw modHeaderError.wrongCategoryValue
		}
		
		if moduleHeader.hardware.rawValue > HardwareMax {
			throw modHeaderError.wrongHardwareValue
		}
	}
	
	func populateModulePage(pageNo: Int) {
		let startPosition: Int = HeaderSize + (PageSize * pageNo)
		var page = ModuleFilePage()
		
		data!.getBytes(&page.name, range: NSMakeRange(startPosition, 20))
		data!.getBytes(&page.ID, range: NSMakeRange(startPosition+20, 9))
		data!.getBytes(&page.page, range: NSMakeRange(startPosition+29, 1))
		data!.getBytes(&page.pageGroup, range: NSMakeRange(startPosition+30, 1))
		data!.getBytes(&page.bank, range: NSMakeRange(startPosition+31, 1))
		data!.getBytes(&page.bankGroup, range: NSMakeRange(startPosition+32, 1))
		data!.getBytes(&page.RAM, range: NSMakeRange(startPosition+33, 1))
		data!.getBytes(&page.writeProtect, range: NSMakeRange(startPosition+34, 1))
		data!.getBytes(&page.FAT, range: NSMakeRange(startPosition+35, 1))
		data!.getBytes(&page.image, range: NSMakeRange(startPosition+36, 5120))
		data!.getBytes(&page.pageCustom, range: NSMakeRange(startPosition+5156, 32))

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
	
	enum readModFileError: ErrorType {
		case errorLoadingFile
	}
	
	func readModFromFile(filename: String) throws {
		// Read the file
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(filename) {
			do {
				let fileAttributes: NSDictionary = try fileManager.attributesOfItemAtPath(filename)
				self.fileSize = fileAttributes[NSFileSize]! as! Int
				self.data = try NSData(contentsOfFile: filename, options: .DataReadingMappedIfSafe)
				self.shortName = (filename as NSString).lastPathComponent.lowercaseString
				moduleHeader.fullFileName = filename
				
				populateModuleHeader()
				
				try validateModuleHeader()
				bus.memModules += moduleHeader.memModules
				bus.XMemModules += moduleHeader.XMemModules
				
//				for var idx: UInt8 = 0; idx < moduleHeader.numPages; idx++ {
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
		if self.data == nil {
			return nil
		}
		
		switch moduleHeader.category {
		case .Undef:
			return "Undefined"
		case .OS:
			return "Operating system"
		case .HPApplicationPAC:
			return "HP Application PACs"
		case .HPILPeripheral:
			return "HP-IL related modules and devices"
		case .StandardPeripheral:
			return "Standard Peripherals"
		case .CustomPeripheral:
			return "Custom Peripherals"
		case .Beta:
			return "BETA releases"
		case .Experimental:
			return "Test programs"
		}
	}
	
	func hardwareDescription() -> String? {
		if self.data == nil {
			return nil
		}
		
		switch moduleHeader.hardware {
		case .None:
			return "no additional hardware specified"
		case .Printer:
			return "82143A Printer"
		case .CardReader:
			return "82104A Card Reader"
		case .Timer:
			if is41CX() {
				return "HP-41CX built in timer"
			} else {
				return "82182A Time Module"
			}
		case .WAND:
			return "82153A Barcode Wand"
		case .HPIL:
			return "82160A HP-IL Module"
		case .Infrared:
			return "82242A Infrared Printer Module"
		case .HEPAX:
			return "HEPAX Module"
		case .WWRAMBox:
			return "W&W RAMBOX"
		case .MLDL2000:
			return "MLDL2000"
		case .CLONIX:
			return "CLONIX-41 Module"
		}
	}
	
	func description() {
		headerDescription()
//		for idx = 0; idx < moduleHeader.numPages; idx++ {
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
	
	func pageDescription(pageNo: UInt8) {
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

func convertCCharToString(cstring: [CChar]) -> String {
	return NSString(bytes: cstring, length: Int(cstring.count), encoding: NSASCIIStringEncoding) as String!
}