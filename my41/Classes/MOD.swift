//
//  modObject.swift
//  i41CV
//
//  Created by Miroslav Perovic on 8/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation


let MOD_FORMAT = "MOD1"

/* Module type codes */
let CATEGORY_UNDEF: byte			= 0		/* not categorized */
let CATEGORY_OS: byte				= 1		/* base Operating System for C,CV,CX */
let CATEGORY_APP_PAC: byte			= 2		/* HP Application PACs */
let CATEGORY_HPIL_PERPH: byte		= 3		/* any HP-IL related modules and devices */
let CATEGORY_STD_PERPH: byte		= 4		/* standard Peripherals: Wand, Printer, Card Reader, XFuns/Mem, Service, Time, IR Printer */
let CATEGORY_CUSTOM_PERPH: byte		= 5		/* custom Peripherals: AECROM, CCD, HEPAX, PPC, ZENROM, etc */
let CATEGORY_BETA: byte				= 6		/* BETA releases not fully debugged and finished */
let CATEGORY_EXPERIMENTAL: byte		= 7		/* test programs not meant for normal usage */
let CATEGORY_MAX: byte				= 7		/* maximum CATEGORY_ define value */

/* Hardware codes */
let HARDWARE_NONE: byte			= 0		/* no additional hardware specified */
let HARDWARE_PRINTER: byte		= 1		/* 82143A Printer */
let HARDWARE_CARDREADER: byte	= 2		/* 82104A Card Reader */
let HARDWARE_TIMER: byte		= 3		/* 82182A Time Module or HP-41CX built in timer */
let HARDWARE_WAND: byte			= 4		/* 82153A Barcode Wand */
let HARDWARE_HPIL: byte			= 5		/* 82160A HP-IL Module */
let HARDWARE_INFRARED: byte		= 6		/* 82242A Infrared Printer Module */
let HARDWARE_HEPAX: byte		= 7		/* HEPAX Module - has special hardware features (write protect, relocation) */
let HARDWARE_WWRAMBOX: byte		= 8		/* W&W RAMBOX - has special hardware features (RAM block swap instructions) */
let HARDWARE_MLDL2000: byte		= 9		/* MLDL2000 */
let HARDWARE_CLONIX: byte		= 10	/* CLONIX-41 Module */
let HARDWARE_MAX: byte			= 10	/* maximum HARDWARE_ define value */

/* relative position codes- do not mix these in a group except ODD/EVEN and UPPER/LOWER */
/* ODD/EVEN, UPPER/LOWER can only place ROMS in 16K blocks */
let POSITION_MIN			= 0x1f	/* minimum POSITION_ define value */
let POSITION_ANY			= 0x1f	/* position in any port page (8-F) */
let POSITION_LOWER			= 0x2f	/* position in lower port page relative to any upper image(s) (8-F) */
let POSITION_UPPER			= 0x3f	/* position in upper port page */
let POSITION_EVEN			= 0x4f	/* position in any even port page (8,A,C,E) */
let POSITION_ODD			= 0x5f	/* position in any odd port page (9,B,D,F) */
let POSITION_ORDERED		= 0x6f	/* position sequentially in MOD file order, one image per page regardless of bank */
let POSITION_MAX			= 0x6f	/* maximum POSITION_ define value */

let PAGE_SIZE				= 5188	// Size of ModulePageFile Struct
let HEADER_SIZE				= 729	// Size of MOduleFileHeader Struct

struct ModuleFilePage {
	var name: [CChar]			/* normally the name of the original .ROM file, if any */
	var ID: [CChar]			/* ROM ID code, normally two letters and a number are ID and last letter is revision - if all zeros, will show up as @@@@ */
	var page: byte				/* the page that this image must be in (0-F, although 8-F is not normally used) or defines each page's position relative to other images in a page group, see codes below */
	var pageGroup: byte			/* 0=not grouped, otherwise images with matching PageGroup values (1..8) are grouped according to POSITION code */
	var bank: byte				/* the bank that this image must be in (1-4) */
	var bankGroup: byte			/* 0=not grouped, otherwise images with matching BankGroup values (1..8) are bankswitched with each other */
	var RAM: byte				/* 0=ROM, 1=RAM - normally RAM pages are all blank if Original=1 */
	var writeProtect: byte		/* 0=No or N/A, 1=protected - for HEPAX RAM and others that might support it */
	var FAT: byte				/* 0=no FAT, 1=has FAT */
	var image: [byte]			/* the image in packed format (.BIN file format) */
	var pageCustom: [byte]		/* for special hardware attributes */
	
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
	var fileFormat: [CChar]			/* constant value defines file format and revision */
	var title: [CChar]				/* the full module name (the short name is the name of the file itself) */
	var version: [CChar]			/* module version, if any */
	var partNumber: [CChar]			/* module part number */
	var author: [CChar]				/* author, if any */
	var copyright: [CChar]			/* copyright notice, if any */
	var license: [CChar]			/* license terms, if any */
	var comments: [CChar]			/* free form comments, if any */
	var category: byte				/* module category, see codes below */
	var hardware: byte				/* defines special hardware that module contains */
	var memModules: byte			/* defines number of main memory modules (0-4) */
	var XMemModules: byte			/* defines number of extended memory modules (0=none, 1=Xfuns/XMem, 2,3=one or two additional XMem modules) */
	var original: byte				/* allows validation of original contents: 1=images and data are original, 0=this file has been updated by a user application (data in RAM written back to MOD file, etc) */
	var appAutoUpdate: byte			/* tells any application to: 1=overwrite this file automatically when saving other data, 0=do not update */
	var numPages: byte				/* the number of pages in this file (0-256, but normally between 1-6) */
	var headerCustom: [byte]		/* for special hardware attributes */
	
	init () {
		fileFormat = [CChar](count: 5, repeatedValue: 0)
		title = [CChar](count: 50, repeatedValue: 0)
		version = [CChar](count: 10, repeatedValue: 0)
		partNumber = [CChar](count: 20, repeatedValue: 0)
		author = [CChar](count: 50, repeatedValue: 0)
		copyright = [CChar](count: 100, repeatedValue: 0)
		license = [CChar](count: 200, repeatedValue: 0)
		comments = [CChar](count: 255, repeatedValue: 0)
		category = 0
		hardware = 0
		memModules = 0
		XMemModules = 0
		original = 0
		appAutoUpdate = 0
		numPages = 0
		headerCustom = [byte](count: 32, repeatedValue: 0)
	}
}


struct ModuleFile {
	var header: ModuleFileHeader			// A file consists of a header
	var pages: [ModuleFilePage]				// Followed by a bunch of pages
	
	init () {
		header = ModuleFileHeader()
		pages = [ModuleFilePage]()
	}	
}


class MOD {
	var data: NSData?
	var shortName: String
	var moduleFile: ModuleFile = ModuleFile()

	init () {
		shortName = ""
		data = nil
	}
	
	func is41C() -> Bool {
		let sName: NSString = shortName
		if module().header.category == CATEGORY_OS && sName.rangeOfString("nut-c.mod").location != NSNotFound {
			return true
		}
		
		return false
	}
	
	func is41CV() -> Bool {
		let sName: NSString = shortName
		if module().header.category == CATEGORY_OS && sName.rangeOfString("nut-cv.mod").location != NSNotFound {
			return true
		}
		
		return false
	}
	
	func is41CX() -> Bool {
		let sName: NSString = shortName
		if module().header.category == CATEGORY_OS && sName.rangeOfString("nut-cx.mod").location != NSNotFound {
			return true
		}
		
		return false
	}

	
	func module() -> ModuleFile {
		populateModuleHeader(&moduleFile)
		for var idx: UInt8 = 0; idx < moduleFile.header.numPages; idx++ {
			populateModulePage(&moduleFile, pageNo: Int(idx))
		}
		
//		description()
		
		return moduleFile
	}
	
	func populateModuleHeader(inout moduleFile: ModuleFile) {
		data!.getBytes(&moduleFile.header.fileFormat, range: NSMakeRange(0, 5))
		data!.getBytes(&moduleFile.header.title, range: NSMakeRange(5, 50))
		data!.getBytes(&moduleFile.header.version, range: NSMakeRange(55, 10))
		data!.getBytes(&moduleFile.header.partNumber, range: NSMakeRange(65, 20))
		data!.getBytes(&moduleFile.header.author, range: NSMakeRange(85, 50))
		data!.getBytes(&moduleFile.header.copyright, range: NSMakeRange(135, 100))
		data!.getBytes(&moduleFile.header.license, range: NSMakeRange(235, 200))
		data!.getBytes(&moduleFile.header.comments, range: NSMakeRange(435, 255))
		data!.getBytes(&moduleFile.header.category, range: NSMakeRange(690, 1))
		data!.getBytes(&moduleFile.header.hardware, range: NSMakeRange(691, 1))
		data!.getBytes(&moduleFile.header.memModules, range: NSMakeRange(692, 1))
		data!.getBytes(&moduleFile.header.XMemModules, range: NSMakeRange(693, 1))
		data!.getBytes(&moduleFile.header.original, range: NSMakeRange(694, 1))
		data!.getBytes(&moduleFile.header.appAutoUpdate, range: NSMakeRange(695, 1))
		data!.getBytes(&moduleFile.header.numPages, range: NSMakeRange(696, 1))
		data!.getBytes(&moduleFile.header.headerCustom, range: NSMakeRange(697, 32))
	}
	
	func populateModulePage(inout moduleFile: ModuleFile, pageNo: Int) {
		let startPosition: Int = HEADER_SIZE + (PAGE_SIZE * pageNo)
		var page: ModuleFilePage = ModuleFilePage()
		
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

		moduleFile.pages.append(page)
	}
	
	func readModFromFile(filename: String) {
		// Read the file
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(filename) {
			data = NSData(contentsOfFile: filename, options: .DataReadingMappedIfSafe, error: nil)
			shortName = filename.lastPathComponent.lowercaseString
		} else {
			data = nil
		}
	}
	
	func categoryDescription() -> String? {
		if self.data == nil {
			return nil
		}
		
		switch module().header.category {
		case CATEGORY_UNDEF:
			return "Undefined"
		case CATEGORY_OS:
			return "Operating system"
		case CATEGORY_APP_PAC:
			return "HP Application PACs"
		case CATEGORY_HPIL_PERPH:
			return "HP-IL related modules and devices"
		case CATEGORY_STD_PERPH:
			return "Standard Peripherals"
		case CATEGORY_CUSTOM_PERPH:
			return "Custom Peripherals"
		case CATEGORY_BETA:
			return "BETA releases"
		case CATEGORY_EXPERIMENTAL:
			return "Test programs"
		default:
			return nil
		}
	}
	
	func hardwareDescription() -> String? {
		if self.data == nil {
			return nil
		}
		
		switch module().header.hardware {
		case HARDWARE_NONE:
			return "no additional hardware specified"
		case HARDWARE_PRINTER:
			return "82143A Printer"
		case HARDWARE_CARDREADER:
			return "82104A Card Reader"
		case HARDWARE_TIMER:
			if is41CX() {
				return "HP-41CX built in timer"
			} else {
				return "82182A Time Module"
			}
		case HARDWARE_WAND:
			return "82153A Barcode Wand"
		case HARDWARE_HPIL:
			return "82160A HP-IL Module"
		case HARDWARE_INFRARED:
			return "82242A Infrared Printer Module"
		case HARDWARE_HEPAX:
			return "HEPAX Module"
		case HARDWARE_WWRAMBOX:
			return "W&W RAMBOX"
		case HARDWARE_MLDL2000:
			return "MLDL2000"
		case HARDWARE_CLONIX:
			return "CLONIX-41 Module"
		default:
			return nil
		}
	}
	
	func description() {
		headerDescription()
		var idx: UInt8
		for idx = 0; idx < moduleFile.header.numPages; idx++ {
			pageDescription(idx)
		}
	}
	
	func headerDescription() {
		println(">>>>>     HEADER     <<<<<")
		println("fileFormat: \(convertCCharToString(moduleFile.header.fileFormat))")
		println("title: \(convertCCharToString(moduleFile.header.title))")
		println("version: \(convertCCharToString(moduleFile.header.version))")
		println("partNumber: \(convertCCharToString(moduleFile.header.partNumber))")
		println("copyright: \(convertCCharToString(moduleFile.header.copyright))")
		println("author: \(convertCCharToString(moduleFile.header.author))")
		println("license: \(convertCCharToString(moduleFile.header.license))")
		println("comments: \(convertCCharToString(moduleFile.header.comments))")
		println("category: \(moduleFile.header.category)")
		println("hardware: \(moduleFile.header.hardware)")
		println("memModules: \(moduleFile.header.memModules)")
		println("XMemModules: \(moduleFile.header.XMemModules)")
		println("original: \(moduleFile.header.original)")
		println("appAutoUpdate: \(moduleFile.header.appAutoUpdate)")
		println("numPages: \(moduleFile.header.numPages)")
		println("headerCustom: \(moduleFile.header.headerCustom)")
		println(">>>>>     END HEADER     <<<<<")
	}
	
	func pageDescription(pageNo: UInt8) {
		let page = moduleFile.pages[Int(pageNo)]
		println(">>>>>     PAGE: \(pageNo)     <<<<<")
		println("name: \(convertCCharToString(page.name))")
		println("ID: \(convertCCharToString(page.ID))")
		println(">>>>>     END PAGE     <<<<<")
	}
}

func convertCCharToString(cstring: [CChar]) -> String {
	return NSString(bytes: cstring, length: Int(cstring.count), encoding: NSASCIIStringEncoding)!
}