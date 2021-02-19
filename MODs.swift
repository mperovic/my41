//
//  MODs.swift
//  my41
//
//  Created by Miroslav Perovic on 2.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Foundation

struct MODs {
	private var allMODFiles = [String]()
	
	private init() {
		allMODFiles = modFilesInBundle()
		removeLoadedModules()
	}
	
	private func modFilesInBundle() -> [String] {
		return Bundle.main.paths(forResourcesOfType: "mod", inDirectory: nil)
			.map {
				NSString(string: $0)
			}.filter {
				$0.lastPathComponent != "nut-c.mod" && $0.lastPathComponent != "nut-cv.mod" && $0.lastPathComponent != "nut-cx.mod"
			} as [String]
	}
	
	private mutating func removeLoadedModules() {
		let defaults = UserDefaults.standard
		
		HPPort.allCases.forEach {
			if let path = defaults.string(forKey: $0.rawValue) {
				allMODFiles.remove(path)
			}
		}
	}
	
	static func getModFiles() -> [String : MOD] {
		let mods = MODs()
		var modFiles = [String : MOD]()
		
		mods.allMODFiles.forEach {
			if let modFile = try? MOD(modName: $0, withMemoryCheck: false) {
				let name = NSString(string: $0).lastPathComponent as String
				modFiles[name] = modFile
			}
		}

		return modFiles
	}
}
