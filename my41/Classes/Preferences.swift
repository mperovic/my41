//
//  Preferences.swift
//  my41
//
//  Created by Miroslav Perovic on 10/17/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

let HPCalculatorType = "CalculatorType"
let HPPort1 = "ModulePort1"
let HPPort2 = "ModulePort2"
let HPPort3 = "ModulePort3"
let HPPort4 = "ModulePort4"
let HPPrinterAvailable = "PrinterAvailable"
let HPCardReaderAvailable = "CardReaderAvailable"
let HPDisplayDebug = "DisplayDebug"
let HPConsoleForegroundColor = "ConsoleForegroundColor"
let HPConsoleBackgroundColor = "ConsoleBackgroundColor"
let HPResetCalculator = "ResetCalculator"


class PreferencesViewController: NSViewController, NSComboBoxDelegate, NSTableViewDataSource, NSTableViewDelegate {
	var calculatorController = CalculatorController.sharedInstance
	var calculatorView: SelectedPreferencesView?
	var modsView: SelectedPreferencesView?
	var calculatorType: CalculatorType?
	var modFiles: Array<AnyObject>?
	var modFileHeaders: [String: ModuleFileHeader]?
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var menuView: NSView!
	@IBOutlet weak var calculatorSelector: NSComboBox!
	@IBOutlet weak var printerButton: NSButton!
	@IBOutlet weak var cardReaderButton: NSButton!
	@IBOutlet weak var calculatorSelectorView: NSView!
	@IBOutlet weak var modSelectorView: NSView!
	@IBOutlet weak var modDetailsView: ModDetailsView!
	
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
	
	override func viewDidLoad() {
		self.title = ""
		comments.stringValue = ""
		
		let defaults = NSUserDefaults.standardUserDefaults()
		expansionModule1.port = 1
		if (defaults.stringForKey(HPPort1) != nil) {
			expansionModule1.filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort1)!
		}
		expansionModule2.port = 2
		if (defaults.stringForKey(HPPort2) != nil) {
			expansionModule2.filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort2)!
		}
		expansionModule3.port = 3
		if (defaults.stringForKey(HPPort3) != nil) {
			expansionModule3.filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort3)!
		}
		expansionModule4.port = 4
		if (defaults.stringForKey(HPPort4) != nil) {
			expansionModule4.filePath = NSBundle.mainBundle().resourcePath! + "/" + defaults.stringForKey(HPPort4)!
		}
		
		self.menuView.layer = CALayer()
		self.menuView.layer?.backgroundColor = NSColor(calibratedRed: 0.9843, green: 0.9804, blue: 0.9725, alpha: 1.0).CGColor
		self.menuView.wantsLayer = true
		
		// Draw border on splitView
		bottomView.layer = CALayer()
		bottomView.layer?.borderWidth = 1.0
		bottomView.wantsLayer = true
		
		calculatorView = SelectedPreferencesView(frame: CGRectMake(0, self.menuView.frame.size.height - 35, 184, 24))
		calculatorView?.text = "Calculator"
		calculatorView?.selected = true
		self.menuView.addSubview(calculatorView!)
		
		modsView = SelectedPreferencesView(frame: CGRectMake(0, self.menuView.frame.size.height - 59, 184, 24))
		modsView?.text = "MODs"
		modsView?.selected = false
		self.menuView.addSubview(modsView!)
		
		let cType = defaults.integerForKey(HPCalculatorType)

		switch cType {
		case 1:
			calculatorType = .HP41C
		case 2:
			calculatorType = .HP41CV
		case 3:
			calculatorType = .HP41CX
		default:
			// Make sure I have a default for next time
			calculatorType = .HP41CX
			defaults.setInteger(CalculatorType.HP41CX.rawValue, forKey: HPCalculatorType)
		}
		calculatorSelector.selectItemAtIndex(cType - 1)
		
		modFiles = modFilesInBundle()
		if let mFiles = modFiles {
			if mFiles.count > 0 {
				tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
				selectedRow(0)
			}
		}
	}
	
	// MARK: -
	func modFilesInBundle() -> Array<AnyObject> {
		let resourceURL = NSBundle.mainBundle().resourceURL
		let modFiles = NSBundle.mainBundle().pathsForResourcesOfType("MOD", inDirectory: nil)
		var realModFiles: Array<AnyObject> = Array()
		for modFile in modFiles {
			let filePath = modFile as String
			if filePath.lastPathComponent != "NUT-C.MOD" && filePath.lastPathComponent != "NUT-CV.MOD" && filePath.lastPathComponent != "NUT-CX.MOD" {
				realModFiles.append(modFile)
			}
		}

		return realModFiles
	}
	
	func displayHeader() {
		if let modDetails = modDetailsView.modDetails {
			modTitle.stringValue = convertCCharToString(modDetails.title)
			modAuthor.stringValue = convertCCharToString(modDetails.author)
			modVersion.stringValue = convertCCharToString(modDetails.version)
			modCopyright.stringValue = convertCCharToString(modDetails.copyright)
			modCategory.stringValue = modDetailsView.category!
			modHardware.stringValue = modDetailsView.hardware!
		}
	}
	
	func selectedRow(row: Int) {
		let filePath = modFiles![row] as String
		if let modDetails = modFileHeaders?[filePath.lastPathComponent] {
			modDetailsView.modDetails = modDetails
		} else {
			let mod = MOD()
			mod.readModFromFile(filePath)
			let modFile: ModuleFile = mod.module()
			modDetailsView.modDetails = mod.moduleFile.header
			modDetailsView.category = mod.categoryDescription()
			modDetailsView.hardware = mod.hardwareDescription()
			modFileHeaders?[filePath.lastPathComponent] = mod.moduleFile.header
		}
		displayHeader()
	}
	
	func applyChanges() {
		// First check calclulator type
		var needsRestart = false
		
		let defaults = NSUserDefaults.standardUserDefaults()
		let cType = defaults.integerForKey(HPCalculatorType)
		if cType != calculatorType!.rawValue {
			defaults.setInteger(calculatorType!.rawValue, forKey: HPCalculatorType)
			needsRestart = true
		}
		
		if let fPath = expansionModule1.filePath {
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort1) {
				if moduleName != dModuleName {
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort1)
					needsRestart = true
				}
			} else {
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort1)
				needsRestart = true
			}
		}
		if let fPath = expansionModule2.filePath {
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort2) {
				if moduleName != dModuleName {
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort2)
					needsRestart = true
				}
			} else {
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort2)
				needsRestart = true
			}
		}
		if let fPath = expansionModule3.filePath {
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort3) {
				if moduleName != dModuleName {
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort3)
					needsRestart = true
				}
			} else {
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort3)
				needsRestart = true
			}
		}
		if let fPath = expansionModule4.filePath {
			let moduleName = fPath.lastPathComponent
			if let dModuleName = defaults.stringForKey(HPPort4) {
				if moduleName != dModuleName {
					defaults.setObject(fPath.lastPathComponent, forKey: HPPort4)
					needsRestart = true
				}
			} else {
				defaults.setObject(fPath.lastPathComponent, forKey: HPPort4)
				needsRestart = true
			}
		}
		
		defaults.synchronize()
		
		if needsRestart {
			calculatorController.resetCalculator()
		}
	}
	
	
	// MARK: Actions
	@IBAction func selectCalculatorAction(sender: AnyObject) {
		calculatorView?.selected = true
		modsView?.selected = false
		calculatorSelectorView.hidden = false
		modSelectorView.hidden = true
		calculatorView!.setNeedsDisplayInRect(calculatorView!.bounds)
		modsView!.setNeedsDisplayInRect(modsView!.bounds)
	}
	
	@IBAction func selectModAction(sender: AnyObject) {
		calculatorView?.selected = false
		modsView?.selected = true
		calculatorSelectorView.hidden = true
		modSelectorView.hidden = false
		calculatorView!.setNeedsDisplayInRect(calculatorView!.bounds)
		modsView!.setNeedsDisplayInRect(modsView!.bounds)
	}
	
	@IBAction func doneAction(sender: AnyObject) {
		applyChanges()
		dismissViewController(self)
	}
	
	@IBAction func cancelAction(sender: AnyObject) {
		dismissViewController(self)
	}
	
	
	// MARK: NSComboBoxDelegate Methods
	func comboBoxSelectionDidChange(notification: NSNotification) {
		if notification.object as NSObject == calculatorSelector {
			let selected = calculatorSelector.indexOfSelectedItem + 1
			let defaults = NSUserDefaults.standardUserDefaults()
			let cType = defaults.integerForKey(HPCalculatorType)

			if selected != cType {
				comments.stringValue = "Please be aware that changing the calculator type may result in some memory loss"
				switch selected {
				case 1:
					calculatorType = .HP41C
				case 2:
					calculatorType = .HP41CV
				case 3:
					calculatorType = .HP41CX
				default:
					// Make sure I have a default for next time
					calculatorType = .HP41CX
				}
			}
		}
	}
	
	
	// MARK: NSTableViewDataSource Methods
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		if let mFiles = modFiles {
			return mFiles.count
		} else {
			return 0
		}
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let filePath = modFiles![row] as String
		
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
			let title = convertCCharToString(modDetailsView.modDetails!.title)
			let row = rowIndexes.firstIndex
			let filePath = modFiles![row] as String
			pboard.setString(filePath, forType: NSPasteboardTypeString)

			return true
		}
	}
}

class SelectedPreferencesView: NSView {
	var text: NSString?
	var selected: Bool?
	
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let backColor = NSColor(calibratedRed: 0.1569, green: 0.6157, blue: 0.8902, alpha: 0.95)
		let textColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
		
		let font = NSFont(name: "Helvetica Bold", size: 14.0)
		
		let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
		let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.LeftTextAlignment
		
		if selected! {
			//// Rectangle Drawing
			let rectangleCornerRadius: CGFloat = 5
			let rectangleRect = NSMakeRect(0, 0, 184, 24)
			let rectangleInnerRect = NSInsetRect(rectangleRect, rectangleCornerRadius, rectangleCornerRadius)
			let rectanglePath = NSBezierPath()
			rectanglePath.moveToPoint(NSMakePoint(NSMinX(rectangleRect), NSMinY(rectangleRect)))
			rectanglePath.appendBezierPathWithArcWithCenter(
				NSMakePoint(NSMaxX(rectangleInnerRect), NSMinY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 270,
				endAngle: 360
			)
			rectanglePath.appendBezierPathWithArcWithCenter(
				NSMakePoint(NSMaxX(rectangleInnerRect), NSMaxY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 0,
				endAngle: 90
			)
			rectanglePath.lineToPoint(NSMakePoint(NSMinX(rectangleRect), NSMaxY(rectangleRect)))
			rectanglePath.closePath()
			backColor.setFill()
			rectanglePath.fill()
			
			if let actualFont = font {
				let textFontAttributes: NSDictionary = [
					NSFontAttributeName: actualFont,
					NSForegroundColorAttributeName: textColor,
					NSParagraphStyleAttributeName: textStyle
				]
				
				text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		} else {
			if let actualFont = font {
				let textFontAttributes: NSDictionary = [
					NSFontAttributeName: actualFont,
					NSForegroundColorAttributeName: backColor,
					NSParagraphStyleAttributeName: textStyle
				]
				
				text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		}
	}
}

class ModDetailsView: NSView {
	var modDetails: ModuleFileHeader?
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
	var modDetails: ModuleFileHeader?
	var category: String?
	var hardware: String?
	var filePath: String?
	var port: Int = 0
	
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
		let backColor = NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.99, alpha: 0.95)
		let rect = NSMakeRect(self.bounds.origin.x + 3, self.bounds.origin.y + 3, self.bounds.size.width - 6, self.bounds.size.height - 6);
		
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
		}
		
		return true
	}
	
	override func concludeDragOperation(sender: NSDraggingInfo?) {
		self.setNeedsDisplayInRect(self.bounds)
	}
}
