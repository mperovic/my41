//
//  Keyboard.swift
//  my41
//
//  Created by Miroslav Perovic on 9/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

//class Keyboard {
//	class var sharedInstance: Keyboard {
//	struct Singleton {
//		static let instance = Keyboard()
//		}
//		
//		return Keyboard.instance
//	}
//}

class KeyGroup : NSView {
	override func drawRect(dirtyRect: NSRect) {
		NSColor.clearColor().setFill()
		NSRectFill(dirtyRect);
		
		super.drawRect(dirtyRect)
	}
}