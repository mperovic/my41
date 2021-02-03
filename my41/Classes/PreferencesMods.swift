//
//  PreferencesMods.swift
//  my41
//
//  Created by Miroslav Perovic on 11/16/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesModsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	@IBOutlet weak var modTitle: NSTextField!
	@IBOutlet weak var modAuthor: NSTextField!
	@IBOutlet weak var modVersion: NSTextField!
	@IBOutlet weak var modCopyright: NSTextField!
	@IBOutlet weak var modCategory: NSTextField!
	@IBOutlet weak var modHardware: NSTextField!
	@IBOutlet weak var expansionModule1: ExpansionView!
	@IBOutlet weak var expansionModule2: ExpansionView!
	@IBOutlet weak var expansionModule3: ExpansionView!
	@IBOutlet weak var expansionModule4: ExpansionView!
	@IBOutlet weak var comments: NSTextField!
	@IBOutlet weak var bottomView: NSView!
	
	@IBOutlet weak var removeModule1: NSButton!
	@IBOutlet weak var removeModule2: NSButton!
	@IBOutlet weak var removeModule3: NSButton!
	@IBOutlet weak var removeModule4: NSButton!
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var modDetailsView: ModDetailsView!

	var modFiles: [String] = [String]()
	var modFileHeaders: [String: ModuleHeader]?
	var preferencesContainerViewController: PreferencesContainerViewController?
	
	override func viewDidLoad() {
		expansionModule1.preferencesModsViewController = self
		expansionModule2.preferencesModsViewController = self
		expansionModule3.preferencesModsViewController = self
		expansionModule4.preferencesModsViewController = self
		
		expansionModule1.port = 1
		if let newMod = preferencesContainerViewController?.newMod1 {
			expansionModule1.filePath = Bundle.main.resourcePath! + "/" + newMod
			removeModule1.isEnabled = true
		}
		expansionModule2.port = 2
		if let newMod = preferencesContainerViewController?.newMod2 {
			expansionModule2.filePath = Bundle.main.resourcePath! + "/" + newMod
			removeModule2.isEnabled = true
		}
		expansionModule3.port = 3
		if let newMod = preferencesContainerViewController?.newMod3 {
			expansionModule3.filePath = Bundle.main.resourcePath! + "/" + newMod
			removeModule3.isEnabled = true
		}
		expansionModule4.port = 4
		if let newMod = preferencesContainerViewController?.newMod4 {
			expansionModule4.filePath = Bundle.main.resourcePath! + "/" + newMod
			removeModule4.isEnabled = true
		}
		
		reloadModFiles()
		if modFiles.count > 0 {
			tableView.reloadData()
			tableView.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: false)
			selectedRow(row: 0)
		}
	}
	
	func removeModFile(filename: String) {
		var index = 0
		for aFileName in modFiles {
			if filename == aFileName {
				modFiles.remove(at: index)
				
				break
			}
			index += 1
		}
	}
	
	func reloadModFiles() {
		modFiles = modFilesInBundle()
		removeLoadedModules()
		
		tableView.reloadData()
	}
	
	func removeLoadedModules() {
		let defaults = UserDefaults.standard
		if (defaults.string(forKey: HPPort.port1.rawValue) != nil) {
			removeModFile(filename: expansionModule1.filePath!)
		}
		if (defaults.string(forKey: HPPort.port2.rawValue) != nil) {
			removeModFile(filename: expansionModule2.filePath!)
		}
		if (defaults.string(forKey: HPPort.port3.rawValue) != nil) {
			removeModFile(filename: expansionModule3.filePath!)
		}
		if (defaults.string(forKey: HPPort.port4.rawValue) != nil) {
			removeModFile(filename: expansionModule4.filePath!)
		}
	}
	
	func displayHeader() {
		if let modDetails = modDetailsView.modDetails {
			modTitle.stringValue = modDetails.title
			modAuthor.stringValue = modDetails.author
			modVersion.stringValue = modDetails.version
			modCopyright.stringValue = modDetails.copyright
			modCategory.stringValue = modDetailsView.category!
			modHardware.stringValue = modDetailsView.hardware!
		}
	}
	
	func selectedRow(row: Int) {
		let filePath = modFiles[row]
		if let modDetails = modFileHeaders?[(filePath as NSString).lastPathComponent] {
			modDetailsView.modDetails = modDetails
		} else {
			let mod = MOD()

			do {
				try mod.readModFromFile(filePath)
				
				modDetailsView.modDetails = mod.moduleHeader
				modDetailsView.category = mod.categoryDescription()
				modDetailsView.hardware = mod.hardwareDescription()
				modFileHeaders?[(filePath as NSString).lastPathComponent] = mod.moduleHeader
			} catch let error as NSError {
				displayAlert(error.localizedDescription)
			}
		}
		displayHeader()
	}
	
	// MARK: -
	func modFilesInBundle() -> [String] {
//		let resourceURL = NSBundle.mainBundle().resourceURL
		let modFiles = Bundle.main.paths(forResourcesOfType: "mod", inDirectory: nil)
		var realModFiles: [String] = [String]()
		for modFile in modFiles {
			let filePath = modFile 
			if (filePath as NSString).lastPathComponent != "nut-c.mod" && (filePath as NSString).lastPathComponent != "nut-cv.mod" && (filePath as NSString).lastPathComponent != "nut-cx.mod" {
				realModFiles.append(modFile )
			}
		}
		
		return realModFiles
	}
	
	
	//MARK: - Actions
	@IBAction func removeModule1Action(sender: AnyObject) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: HPPort.port1.rawValue)
		removeModule1.isEnabled = false
		expansionModule1.filePath = nil
		expansionModule1.setNeedsDisplay(expansionModule1.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule2Action(sender: AnyObject) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: HPPort.port2.rawValue)
		removeModule2.isEnabled = false
		expansionModule2.filePath = nil
		expansionModule2.setNeedsDisplay(expansionModule2.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule3Action(sender: AnyObject) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: HPPort.port3.rawValue)
		removeModule3.isEnabled = false
		expansionModule3.filePath = nil
		expansionModule3.setNeedsDisplay(expansionModule3.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule4Action(sender: AnyObject) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: HPPort.port4.rawValue)
		removeModule4.isEnabled = false
		expansionModule4.filePath = nil
		expansionModule4.setNeedsDisplay(expansionModule4.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func applyChanges(sender: AnyObject) {
		preferencesContainerViewController?.applyChanges()
	}
	
	
	//MARK: - NSTableViewDataSource Methods
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return modFiles.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let filePath = modFiles[row]
		
		var cellView: NSTableCellView?
		if let tColumn = tableColumn {
			let cView = tableView.makeView(withIdentifier: tColumn.identifier, owner: self) as! NSTableCellView
			cView.textField?.stringValue = (filePath as NSString).lastPathComponent
			cellView = cView
		}
		
		return cellView
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		selectedRow(row: row)
		
		return true
	}

	func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
		if rowIndexes.count > 1 {
			return false
		} else {
//			let title = modDetailsView.modDetails?.title
			let row = rowIndexes.first
			let filePath = modFiles[row!]
			pboard.setString(filePath, forType: NSPasteboard.PasteboardType.string)
			
			return true
		}
	}
}


class ModDetailsView: NSView {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	
	override func draw(_ dirtyRect: NSRect) {
		let backColor = NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.99, alpha: 0.95)
		let rect = NSMakeRect(self.bounds.origin.x + 3, self.bounds.origin.y + 3, self.bounds.size.width - 6, self.bounds.size.height - 6)
		
		let path = NSBezierPath(roundedRect: rect, xRadius: 5.0, yRadius: 5.0)
		path.addClip()
		
		backColor.setFill()
		path.fill()
	}
}

class ExpansionView: NSView {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	var filePath: String?
	var port: Int = 0
	
	var preferencesModsViewController: PreferencesModsViewController!
	
	convenience init(port: Int) {
		self.init()
		
		let defaults = UserDefaults.standard
		switch port {
		case 1:
			filePath = Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort.port1.rawValue)!
			
		case 2:
			filePath = Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort.port2.rawValue)!
			
		case 3:
			filePath = Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort.port3.rawValue)!
			
		case 4:
			filePath = Bundle.main.resourcePath! + "/" + defaults.string(forKey: HPPort.port4.rawValue)!
			
		default:
			break
		}
		
		self.port = port
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func awakeFromNib() {
		let theArray = [
			"NSStringPboardType"
		]
		
		register(forDraggedTypes: theArray)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		let backColor = NSColor(calibratedRed: 0.1569, green: 0.6157, blue: 0.8902, alpha: 0.95)
		let rect = NSMakeRect(
			self.bounds.origin.x + 3,
			self.bounds.origin.y + 3,
			self.bounds.size.width - 6,
			self.bounds.size.height - 6
		)
		
		let path = NSBezierPath(roundedRect: rect, xRadius: 5.0, yRadius: 5.0)
		path.addClip()
		
		backColor.setFill()
		path.fill()
		
		if let fPath = filePath {
			let font = NSFont.systemFont(ofSize: 11.0)
			let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
			textStyle.alignment = .center
			let attributes = [
				NSAttributedString.Key.font : font,
				NSAttributedString.Key.paragraphStyle: textStyle
			]
			
			let mod = MOD()
			do {
				try mod.readModFromFile(fPath as String)
				mod.moduleHeader.title.draw(in: NSMakeRect(20.0, 40.0, 100.0, 58.0), withAttributes: attributes)
			} catch _ {
				
			}
		}
	}
	
	
	//MARK: - Drag & Drop
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		if NSDragOperation.generic.intersection(sender.draggingSourceOperationMask) == NSDragOperation.generic {
			return NSDragOperation.generic
		} else {
			return NSDragOperation()
		}
	}
	
	override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
		if NSDragOperation.generic.intersection(sender.draggingSourceOperationMask) == NSDragOperation.generic {
			return NSDragOperation.generic
		} else {
			return NSDragOperation()
		}
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		return true
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		if filePath != nil {
			return false
		}

		let paste = sender.draggingPasteboard
		let theArray = [
			"NSStringPboardType"
		]
		let desiredType = paste.availableType(from: theArray)
		if let data = paste.data(forType: desiredType!) {
			if let fPath = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
				filePath = fPath as String
				preferencesModsViewController.removeModFile(filename: fPath as String)
				preferencesModsViewController.tableView.reloadData()
				
				switch port {
				case 1:
					preferencesModsViewController.removeModule1.isEnabled = true
					preferencesModsViewController.preferencesContainerViewController?.newMod1 = fPath.lastPathComponent
					preferencesModsViewController.expansionModule1.setNeedsDisplay(preferencesModsViewController.expansionModule1.bounds)
					
				case 2:
					preferencesModsViewController.removeModule2.isEnabled = true
					preferencesModsViewController.preferencesContainerViewController?.newMod2 = fPath.lastPathComponent
					
				case 3:
					preferencesModsViewController.removeModule3.isEnabled = true
					preferencesModsViewController.preferencesContainerViewController?.newMod3 = fPath.lastPathComponent
					
				case 4:
					preferencesModsViewController.removeModule4.isEnabled = true
					preferencesModsViewController.preferencesContainerViewController?.newMod4 = fPath.lastPathComponent
					
				default:
					break
				}
			}
		}
		
		return true
	}
	
	override func concludeDragOperation(_ sender: NSDraggingInfo?) {
		self.setNeedsDisplay(self.bounds)
	}
}
