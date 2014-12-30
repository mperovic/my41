//
//  Keyboard.swift
//  my41
//
//  Created by Miroslav Perovic on 9/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class Keyboard : NSObject {
	@IBOutlet weak var functionGroup: KeyGroup!
	@IBOutlet weak var arithmeticGroup: KeyGroup!
	@IBOutlet weak var numberGroup: KeyGroup!

	@IBOutlet weak var keyOn: Key!
	@IBOutlet weak var keyUser: Key!
	@IBOutlet weak var keyPrgm: Key!
	@IBOutlet weak var keyAlpha: Key!
	
	override func awakeFromNib() {
		calculatorController.keyboard = self
	}
	
	override init() {
		super.init()
	}
	
	func keyWithCode(code: Int, pressed: Bool) {
		cpu.keyWithCode(code, pressed: pressed)
	}
}

class KeyGroup : NSView {
	@IBOutlet weak var keyboard: Keyboard!
	
	override func drawRect(dirtyRect: NSRect) {
		NSColor.clearColor().setFill()
		NSRectFill(dirtyRect)
		
		super.drawRect(dirtyRect)
	}
	
	func key(key: Key, pressed: Bool) {
		let code: Int = key.keyCode! as Int
		keyboard.keyWithCode(code, pressed: pressed)
	}
	
	override var acceptsFirstResponder: Bool { return true }
	
	override func keyDown(theEvent: NSEvent) {
	}
	
	override func keyUp(theEvent: NSEvent) {
	}
}