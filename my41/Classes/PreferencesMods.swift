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
			expansionModule1.filePath = NSBundle.mainBundle().resourcePath! + "/" + newMod
			removeModule1.enabled = true
		}
		expansionModule2.port = 2
		if let newMod = preferencesContainerViewController?.newMod2 {
			expansionModule2.filePath = NSBundle.mainBundle().resourcePath! + "/" + newMod
			removeModule2.enabled = true
		}
		expansionModule3.port = 3
		if let newMod = preferencesContainerViewController?.newMod3 {
			expansionModule3.filePath = NSBundle.mainBundle().resourcePath! + "/" + newMod
			removeModule3.enabled = true
		}
		expansionModule4.port = 4
		if let newMod = preferencesContainerViewController?.newMod4 {
			expansionModule4.filePath = NSBundle.mainBundle().resourcePath! + "/" + newMod
			removeModule4.enabled = true
		}
		
		reloadModFiles()
		if modFiles.count > 0 {
			tableView.reloadData()
			tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
			selectedRow(0)
		}
	}
	
	func removeModFile(filename: String) {
		var index = 0
		for aFileName in modFiles {
			if filename == aFileName {
				modFiles.removeAtIndex(index)
				
				break
			}
			index++;
		}
	}
	
	func reloadModFiles() {
		modFiles = modFilesInBundle()
		removeLoadedModules()
		
		tableView.reloadData()
	}
	
	func removeLoadedModules() {
		let defaults = NSUserDefaults.standardUserDefaults()
		if (defaults.stringForKey(HPPort1) != nil) {
			removeModFile(expansionModule1.filePath!)
		}
		if (defaults.stringForKey(HPPort2) != nil) {
			removeModFile(expansionModule2.filePath!)
		}
		if (defaults.stringForKey(HPPort3) != nil) {
			removeModFile(expansionModule3.filePath!)
		}
		if (defaults.stringForKey(HPPort4) != nil) {
			removeModFile(expansionModule4.filePath!)
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
		if let modDetails = modFileHeaders?[filePath.lastPathComponent] {
			modDetailsView.modDetails = modDetails
		} else {
			let mod = MOD()
			mod.readModFromFile(filePath)
			modDetailsView.modDetails = mod.moduleHeader
			modDetailsView.category = mod.categoryDescription()
			modDetailsView.hardware = mod.hardwareDescription()
			modFileHeaders?[filePath.lastPathComponent] = mod.moduleHeader
		}
		displayHeader()
	}
	
	// MARK: -
	func modFilesInBundle() -> [String] {
		let resourceURL = NSBundle.mainBundle().resourceURL
		let modFiles = NSBundle.mainBundle().pathsForResourcesOfType("MOD", inDirectory: nil)
		var realModFiles: [String] = [String]()
		for modFile in modFiles {
			let filePath = modFile as String
			if filePath.lastPathComponent != "NUT-C.MOD" && filePath.lastPathComponent != "NUT-CV.MOD" && filePath.lastPathComponent != "NUT-CX.MOD" {
				realModFiles.append(modFile as String)
			}
		}
		
		return realModFiles
	}
	
	
	//MARK: - Actions
	@IBAction func removeModule1Action(sender: AnyObject) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(HPPort1)
		removeModule1.enabled = false
		expansionModule1.filePath = nil
		expansionModule1.setNeedsDisplayInRect(expansionModule1.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule2Action(sender: AnyObject) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(HPPort2)
		removeModule2.enabled = false
		expansionModule2.filePath = nil
		expansionModule2.setNeedsDisplayInRect(expansionModule2.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule3Action(sender: AnyObject) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(HPPort3)
		removeModule3.enabled = false
		expansionModule3.filePath = nil
		expansionModule3.setNeedsDisplayInRect(expansionModule3.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func removeModule4Action(sender: AnyObject) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(HPPort4)
		removeModule4.enabled = false
		expansionModule4.filePath = nil
		expansionModule4.setNeedsDisplayInRect(expansionModule4.bounds)
		
		reloadModFiles()
	}
	
	@IBAction func applyChanges(sender: AnyObject) {
		preferencesContainerViewController?.applyChanges()
	}
	
	
	//MARK: - NSTableViewDataSource Methods
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return modFiles.count
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let filePath = modFiles[row]
		
		var cellView: NSTableCellView?
		if let tColumn = tableColumn {
			let cView = tableView.makeViewWithIdentifier(tColumn.identifier, owner: self) as NSTableCellView
			cView.textField?.stringValue = filePath.lastPathComponent
			cellView = cView
		}
		
		return cellView
	}
	
	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		selectedRow(row)
		
		return true
	}
	
	func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
		if rowIndexes.count > 1 {
			return false
		} else {
			let title = modDetailsView.modDetails?.title
			let row = rowIndexes.firstIndex
			let filePath = modFiles[row]
			pboard.setString(filePath, forType: NSPasteboardTypeString)
			
			return true
		}
	}
}


class ModDetailsView: NSView {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	
	override func drawRect(dirtyRect: NSRect) {
		let backColor = NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.99, alpha: 0.95)
		let rect = NSMakeRect(self.bounds.origin.x + 3, self.bounds.origin.y + 3, self.bounds.size.width - 6, self.bounds.size.height - 6);
		
		var path = NSBezierPath(roundedRect: rect, xRadius: 5.0, yRadius: 5.0)
		path.addClip()
		
		backColor.setFill()
		path.fill()
	}
}

class ExpansionView: NSView, NSDraggingDestination {
	var modDetails: ModuleHeader?
	var category: String?
	var hardware: String?
	var filePath: String?
	var port: Int = 0
	
	var preferencesModsViewController: PreferencesModsViewController!
	
	init(port: Int) {
		let defaults = NSUserDefaults.standardUserDefaults()
		switch port {
		case 1:
			filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort1)!
			
		case 2:
			filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort2)!
			
		case 3:
			filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort3)!
			
		case 4:
			filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort4)!
			
		default:
			break
		}
		
		super.init()
		
		self.port = port
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func awakeFromNib() {
		let theArray = [
			"NSStringPboardType"
		]
		
		registerForDraggedTypes(theArray)
	}
	
	override func drawRect(dirtyRect: NSRect) {
		let backColor = NSColor(calibratedRed: 0.1569, green: 0.6157, blue: 0.8902, alpha: 0.95)
		let rect = NSMakeRect(
			self.bounds.origin.x + 3,
			self.bounds.origin.y + 3,
			self.bounds.size.width - 6,
			self.bounds.size.height - 6
		);
		
		var path = NSBezierPath(roundedRect: rect, xRadius: 5.0, yRadius: 5.0)
		path.addClip()
		
		backColor.setFill()
		path.fill()
		
		if let fPath: NSString = filePath {
			let font = NSFont.systemFontOfSize(12.0)
			var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
			textStyle.alignment = .CenterTextAlignment
			let attributes = [
				NSFontAttributeName : font,
				NSParagraphStyleAttributeName: textStyle
			]
			fPath.lastPathComponent.drawInRect(NSMakeRect(20.0, 85.0, 100.0, 17.0), withAttributes: attributes)
		}
	}
	
	
	//MARK: - Drag & Drop
	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
		if NSDragOperation.Generic & sender.draggingSourceOperationMask() == NSDragOperation.Generic {
			return NSDragOperation.Generic
		} else {
			return NSDragOperation.None
		}
	}
	
	override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
		if NSDragOperation.Generic & sender.draggingSourceOperationMask() == NSDragOperation.Generic {
			return NSDragOperation.Generic
		} else {
			return NSDragOperation.None
		}
	}
	
	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		return true
	}
	
	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		let paste = sender.draggingPasteboard()
		let theArray = [
			"NSStringPboardType"
		]
		let desiredType = paste.availableTypeFromArray(theArray)
		if let data = paste.dataForType(desiredType!) {
			filePath = NSString(data: data, encoding: NSUTF8StringEncoding)
			preferencesModsViewController.removeModFile(filePath!)
			preferencesModsViewController.tableView.reloadData()
			
			switch port {
			case 1:
				preferencesModsViewController.removeModule1.enabled = true
				preferencesModsViewController.preferencesContainerViewController?.newMod1 = filePath?.lastPathComponent
				
			case 2:
				preferencesModsViewController.removeModule2.enabled = true
				preferencesModsViewController.preferencesContainerViewController?.newMod2 = filePath?.lastPathComponent
				
			case 3:
				preferencesModsViewController.removeModule3.enabled = true
				preferencesModsViewController.preferencesContainerViewController?.newMod3 = filePath?.lastPathComponent
				
			case 4:
				preferencesModsViewController.removeModule4.enabled = true
				preferencesModsViewController.preferencesContainerViewController?.newMod4 = filePath?.lastPathComponent
				
			default:
				break
			}
		}
		
		return true
	}
	
	override func concludeDragOperation(sender: NSDraggingInfo?) {
		self.setNeedsDisplayInRect(self.bounds)
	}
}
