//
//  Application.swift
//  my41
//
//  Created by Miroslav Perovic on 11/26/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

final class CalculatorApplication: NSApplication {
	override func sendEvent(_ theEvent: NSEvent) {
		if theEvent.type == NSEvent.EventType.keyUp && (theEvent.modifierFlags.intersection(.command)).rawValue != 0 {
			self.keyWindow?.sendEvent(theEvent)
		} else {
			super.sendEvent(theEvent)
		}
	}
}
