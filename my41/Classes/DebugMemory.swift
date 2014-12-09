//
//  DebugMemory.swift
//  my41
//
//  Created by Miroslav Perovic on 11/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class DebugMemoryViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	var debugContainerViewController: DebugContainerViewController?
	var bus = Bus.sharedInstance
	var cpu = CPU.sharedInstance
	var bankSelected: Int = 0

	@IBOutlet weak var memory0: NSTextField!
	@IBOutlet weak var memory1: NSTextField!
	@IBOutlet weak var memory2: NSTextField!
	@IBOutlet weak var memory3: NSTextField!
	@IBOutlet weak var memory4: NSTextField!
	@IBOutlet weak var memory5: NSTextField!
	@IBOutlet weak var memory6: NSTextField!
	@IBOutlet weak var memory7: NSTextField!
	@IBOutlet weak var memory8: NSTextField!
	@IBOutlet weak var memory9: NSTextField!
	@IBOutlet weak var memoryA: NSTextField!
	@IBOutlet weak var memoryB: NSTextField!
	@IBOutlet weak var memoryC: NSTextField!
	@IBOutlet weak var memoryD: NSTextField!
	@IBOutlet weak var memoryE: NSTextField!
	@IBOutlet weak var memoryF: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	
	override func awakeFromNib() {
		cpu.debugMemoryViewController = self
	}
	
	override func viewDidAppear() {
		let indexSet = NSIndexSet(index: 0)
		tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
		tableView.scrollRowToVisible(0)
	}
	
	func displaySelectedMemoryBank() {
		displayCurrentRAM(bankSelected << 4)
	}
	
	func displayCurrentRAM(address: Int) {
		if bus.ramValid[address] {
			displayMemory(false)

			var ptr = 0
			for addr in address...(address + 0x0f) {
				var tmpReg = emptyDigit14
				switch bus.readRamAddress(Bits12(addr), into: &tmpReg) {
				case .Success(let result):
					switch ptr {
					case 0x0:
						memory0.stringValue = cpu.digits14ToString(tmpReg)
					case 0x1:
						memory1.stringValue = cpu.digits14ToString(tmpReg)
					case 0x2:
						memory2.stringValue = cpu.digits14ToString(tmpReg)
					case 0x3:
						memory3.stringValue = cpu.digits14ToString(tmpReg)
					case 0x4:
						memory4.stringValue = cpu.digits14ToString(tmpReg)
					case 0x5:
						memory5.stringValue = cpu.digits14ToString(tmpReg)
					case 0x6:
						memory6.stringValue = cpu.digits14ToString(tmpReg)
					case 0x7:
						memory7.stringValue = cpu.digits14ToString(tmpReg)
					case 0x8:
						memory8.stringValue = cpu.digits14ToString(tmpReg)
					case 0x9:
						memory9.stringValue = cpu.digits14ToString(tmpReg)
					case 0xA:
						memoryA.stringValue = cpu.digits14ToString(tmpReg)
					case 0xB:
						memoryB.stringValue = cpu.digits14ToString(tmpReg)
					case 0xC:
						memoryC.stringValue = cpu.digits14ToString(tmpReg)
					case 0xD:
						memoryD.stringValue = cpu.digits14ToString(tmpReg)
					case 0xE:
						memoryE.stringValue = cpu.digits14ToString(tmpReg)
					case 0xF:
						memoryF.stringValue = cpu.digits14ToString(tmpReg)
					default:
						// do nothing
						break
					}
					ptr++
				case .Error (let error):
					println(error)
				}
			}
		} else {
			displayMemory(true)
		}
	}
	
	func displayMemory(hidden: Bool) {
		memory0.hidden = hidden
		memory1.hidden = hidden
		memory2.hidden = hidden
		memory3.hidden = hidden
		memory4.hidden = hidden
		memory5.hidden = hidden
		memory6.hidden = hidden
		memory7.hidden = hidden
		memory8.hidden = hidden
		memory9.hidden = hidden
		memoryA.hidden = hidden
		memoryB.hidden = hidden
		memoryC.hidden = hidden
		memoryD.hidden = hidden
		memoryE.hidden = hidden
		memoryF.hidden = hidden
	}

	//MARK: - TableView DataSource & Delegate
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return 0x40		// Number of RAM banks
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		var value: AnyObject?
		
		if tableColumn?.identifier == "avail" {
			if bus.ramValid[row << 4] {
				value = NSNumber(integer: NSOnState)
			} else {
				value = NSNumber(integer: NSOffState)
			}
		}
		
		if tableColumn?.identifier == "bank" {
			value = NSString(format:"0x%.2X", row)
		}
		
		if tableColumn?.identifier == "begins" {
			value = NSString(format:"0x%.3X", row << 4)
		}
		
		if tableColumn?.identifier == "ends" {
			value = NSString(format:"0x%.3X", (row << 4) + 0x0f)
		}
		
		return value
	}
	
	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		return true
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		let tv = notification.object as NSTableView
		bankSelected = tv.selectedRow
		displaySelectedMemoryBank()
	}
}
