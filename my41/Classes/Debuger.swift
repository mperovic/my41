//
//  Debuger.swift
//  my41
//
//  Created by Miroslav Perovic on 9/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class DebugViewController: NSViewController {
	var cpu: CPU = CPU.sharedInstance
	var registersView: SelectedView?
	var memoryView: SelectedView?
	
	@IBOutlet weak var menuView: NSView!
	
	override func viewDidLoad() {
		self.menuView.layer = CALayer()
		self.menuView.layer?.backgroundColor = NSColor(calibratedRed: 0.4824, green: 0.6667, blue: 0.2941, alpha: 1.0).CGColor
		self.menuView.wantsLayer = true

		cpu.debugViewController = self
		
		registersView = SelectedView(frame: CGRectMake(0, self.menuView.frame.size.height - 35, 184, 24))
		registersView?.text = "Registers"
		registersView?.selected = true
		self.menuView.addSubview(registersView!)
		
		memoryView = SelectedView(frame: CGRectMake(0, self.menuView.frame.size.height - 59, 184, 24))
		memoryView?.text = "Memory"
		memoryView?.selected = false
		self.menuView.addSubview(memoryView!)
	}
	
	func updateDisplay() {
		var debugerView: DebugerView = self.view as DebugerView
		debugerView.updateAll()
	}
	
	@IBAction func registersAction(sender: AnyObject) {
		registersView!.selected = true
		memoryView!.selected = false
		registersView!.setNeedsDisplayInRect(registersView!.bounds)
		memoryView!.setNeedsDisplayInRect(memoryView!.bounds)
	}
	@IBAction func memoryAction(sender: AnyObject) {
		registersView!.selected = false
		memoryView!.selected = true
		registersView!.setNeedsDisplayInRect(registersView!.bounds)
		memoryView!.setNeedsDisplayInRect(memoryView!.bounds)
	}
}

class SelectedView: NSView {
	var text: String?
	var selected: Bool?
	
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let backColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.95)
		let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1)
		
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
			
			//// Text Drawing
			let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
			let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
			textStyle.alignment = NSTextAlignment.LeftTextAlignment
			
			let textFontAttributes = [NSFontAttributeName: NSFont(name: "Helvetica Bold", size: 14), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: textStyle]
			
			text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
		} else {
			//// Text Drawing
			let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
			let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
			textStyle.alignment = NSTextAlignment.LeftTextAlignment
			
			let textFontAttributes = [NSFontAttributeName: NSFont(name: "Helvetica Bold", size: 14), NSForegroundColorAttributeName: backColor, NSParagraphStyleAttributeName: textStyle]
			
			text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
		}
	}
}

class DebugerView: NSView {
	@IBOutlet weak var registersView: NSView!
	@IBOutlet weak var cpuPowerMode: NSTextField!
	@IBOutlet weak var cpuRegistersView: NSView!
	@IBOutlet weak var cpuRegisterA: NSTextField!
	@IBOutlet weak var cpuRegisterB: NSTextField!
	@IBOutlet weak var cpuRegisterC: NSTextField!
	@IBOutlet weak var cpuRegisterM: NSTextField!
	@IBOutlet weak var cpuRegisterN: NSTextField!
	@IBOutlet weak var cpuRegisterP: NSTextField!
	@IBOutlet weak var cpuRegisterQ: NSTextField!
	@IBOutlet weak var cpuRegisterPC: NSTextField!
	@IBOutlet weak var cpuRegisterG: NSTextField!
	@IBOutlet weak var cpuRegisterT: NSTextField!
	@IBOutlet weak var cpuRegisterXST: NSTextField!
	@IBOutlet weak var cpuRegisterST: NSTextField!
	@IBOutlet weak var cpuRegisterR: NSTextField!
	@IBOutlet weak var cpuRegisterCarry: NSTextField!
	@IBOutlet weak var cpuMode: NSTextField!
	@IBOutlet weak var cpuStack1: NSTextField!
	@IBOutlet weak var cpuStack2: NSTextField!
	@IBOutlet weak var cpuStack3: NSTextField!
	@IBOutlet weak var cpuStack4: NSTextField!
	@IBOutlet weak var cpuRegisterKY: NSTextField!
	@IBOutlet weak var cpuRegisterFI: NSTextField!
	@IBOutlet weak var cpuSelectedRAM: NSTextField!
	@IBOutlet weak var cpuSelectedPeripheral: NSTextField!
	
	@IBOutlet weak var displayRegistersView: NSView!
	@IBOutlet weak var displayRegisterA: NSTextField!
	@IBOutlet weak var displayRegisterB: NSTextField!
	@IBOutlet weak var displayRegisterC: NSTextField!
	@IBOutlet weak var displayRegisterE: NSTextField!
	
	@IBOutlet weak var ROMTableView: NSTableView!
	
	var cpu = CPU.sharedInstance
	var calculatorController = CalculatorController.sharedInstance
	
	override func awakeFromNib() {
		self.cpuRegistersView.wantsLayer = true
		self.cpuRegistersView.layer?.masksToBounds = true
		self.cpuRegistersView.layer?.borderWidth = 2.0
		self.cpuRegistersView.layer?.borderColor = CGColorCreateGenericGray(0.75, 1.0)
		self.cpuRegistersView.layer?.cornerRadius = 6.0

		self.displayRegistersView.wantsLayer = true
		self.displayRegistersView.layer?.masksToBounds = true
		self.displayRegistersView.layer?.borderWidth = 2.0
		self.displayRegistersView.layer?.borderColor = CGColorCreateGenericGray(0.75, 1.0)
		self.displayRegistersView.layer?.cornerRadius = 6.0

		updateAll()
	}
	
	func updateAll() {
		populateCPURegisters()
		populateDisplayRegisters()
	}
	
	func populateCPURegisters() {
		cpuRegisterA.stringValue = cpu.digits14ToString(cpu.reg.A)
		cpuRegisterB.stringValue = cpu.digits14ToString(cpu.reg.B)
		cpuRegisterC.stringValue = cpu.digits14ToString(cpu.reg.C)
		cpuRegisterM.stringValue = cpu.digits14ToString(cpu.reg.M)
		cpuRegisterN.stringValue = cpu.digits14ToString(cpu.reg.N)
		cpuRegisterP.stringValue = cpu.bits4ToString(cpu.reg.P)
		cpuRegisterQ.stringValue = cpu.bits4ToString(cpu.reg.Q)
		cpuRegisterPC.stringValue = NSString(format:"%04X", cpu.reg.PC)
		cpuRegisterG.stringValue = NSString(format:"%02X", cpu.reg.G)
		cpuRegisterT.stringValue = NSString(format:"%02X", cpu.reg.T)
		cpuRegisterXST.stringValue = NSString(format:"%02X", cpu.reg.XST)
		cpuRegisterST.stringValue = NSString(format:"%02X", cpu.reg.ST)
		if cpu.reg.R == 0 {
			cpuRegisterR.stringValue = "P"
		} else {
			cpuRegisterR.stringValue = "Q"
		}
		switch cpu.powerMode {
		case .DeepSleep:
			cpuPowerMode.stringValue = "D"
		case .LightSleep:
			cpuPowerMode.stringValue = "L"
		case .PowerOn:
			cpuPowerMode.stringValue = "P"
		}
		if cpu.reg.carry == 0 {
			cpuRegisterCarry.stringValue = "T"
		} else {
			cpuRegisterCarry.stringValue = "F"
		}
		switch cpu.reg.mode {
		case .DEC_MODE:
			cpuMode.stringValue = "D"
		case .HEX_MODE:
			cpuMode.stringValue = "H"
		}
		cpuStack1.stringValue = NSString(format:"%04X", cpu.reg.stack[0])
		cpuStack2.stringValue = NSString(format:"%04X", cpu.reg.stack[1])
		cpuStack3.stringValue = NSString(format:"%04X", cpu.reg.stack[2])
		cpuStack4.stringValue = NSString(format:"%04X", cpu.reg.stack[3])
		cpuRegisterKY.stringValue = NSString(format:"%02X", cpu.reg.KY)
		cpuRegisterFI.stringValue = NSString(format:"%04X", cpu.reg.FI)
		cpuSelectedRAM.stringValue = NSString(format:"%03X", cpu.reg.ramAddress)
		cpuSelectedPeripheral.stringValue = NSString(format:"%02X", cpu.reg.peripheral)
	}
	
	func populateDisplayRegisters() {
		if let display = calculatorController.display {
			displayRegisterA.stringValue = display.digits12ToString(display.registers.A)
			displayRegisterB.stringValue = display.digits12ToString(display.registers.B)
			displayRegisterC.stringValue = display.digits12ToString(display.registers.C)
			displayRegisterE.stringValue = NSString(format:"%03X", display.registers.E)
		}
	}
}

class LabelView: NSView {
	override func awakeFromNib() {
		var viewLayer: CALayer = CALayer()
		viewLayer.backgroundColor = CGColorCreateGenericRGB(0.5412, 0.7098, 0.3804, 1.0)
		self.wantsLayer = true
		self.layer = viewLayer
	}
}

class DebugTableCellView: NSTableCellView {
	
}

class DebugerTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
//	func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
//		return 2
//	}
//	
//	func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
//		var cell = tableView.makeViewWithIdentifier("DebugItem", owner: self) as NSTableCellView
//		switch row {
//		case 0:
//			cell.textField.stringValue = "Registers"
//		case 1:
//			cell.textField.stringValue = "Memory"
//		default:
//			cell.textField.stringValue = ""
//		}
//		
//		return cell
//	}
}