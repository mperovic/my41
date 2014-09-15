//
//  TwoButtons.swift
//  my41
//
//  Created by Miroslav Perovic on 9/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

enum ButtonsState : Int {
	case Centre = 0
	case Left = 1
	case Right = 2
}


class TwoButtons : NSView {
	var images: [NSImage?] = [nil, nil]
	var keyCodes: [Int] = [0, 0]
	
	var state: ButtonsState = .Centre
	
	init(anImages: [NSImage], aKeyCodes: [Int]) {
		if countElements(anImages) < 2 {
			fatalError("Incorect  number of images")
		}
		images[0] = anImages[0]
		images[1] = anImages[1]
		if countElements(aKeyCodes) < 2 {
			fatalError("Incorect  number of images")
		}
		keyCodes[0] = aKeyCodes[0]
		keyCodes[1] = aKeyCodes[1]
		
		super.init()
	}

	required init(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setState(newState: ButtonsState) {
		state = newState
		self.setNeedsDisplayInRect(self.bounds)
	}
	
}