//
//  Keyboard.swift
//  my41
//
//  Created by Miroslav Perovic on 9/5/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class Keyboard : NSObject {
	@IBOutlet weak var functionGroup: KeyGroup!
	@IBOutlet weak var arithmeticGroup: KeyGroup!
	@IBOutlet weak var numberGroup: KeyGroup!

	@IBOutlet weak var keyOn: Key!
	@IBOutlet weak var keyUser: Key!
	@IBOutlet weak var keyPrgm: Key!
	@IBOutlet weak var keyAlpha: Key!
	
	override init() {
		super.init()
	}
	
	func keyWithCode(code: Int, pressed: Bool) {
		cpu.keyWithCode(code, pressed: pressed)
	}
}

class KeyGroup : NSView {
	@IBOutlet weak var keyboard: Keyboard!
	
	var audioPlayer:AVAudioPlayer? = nil
	
	override func drawRect(dirtyRect: NSRect) {
		NSColor.clearColor().setFill()
		NSRectFill(dirtyRect)
		
		super.drawRect(dirtyRect)
	}
	
	func key(key: Key, pressed: Bool) {
		let code: Int = key.keyCode! as Int
		keyboard.keyWithCode(code, pressed: pressed)
		
//		if pressed {
//			playSound()
//		}
	}
	
	override var acceptsFirstResponder: Bool { return true }
	
	override func keyDown(theEvent: NSEvent) {
	}
	
	override func keyUp(theEvent: NSEvent) {
	}
	
	func playSound() {
		var error: NSError?
		let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("keyPressSound", ofType: "wav")!)
		
		self.audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
		self.audioPlayer?.prepareToPlay()
		self.audioPlayer?.play()
	}
}