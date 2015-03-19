//
//  Keyboard.swift
//  my41
//
//  Created by Miroslav Perovic on 2/7/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class iOSKeyboard : NSObject {
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

class KeyGroup: UIView {
	@IBOutlet weak var keyboard: iOSKeyboard!
	
	var audioPlayer:AVAudioPlayer? = nil

	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		CGContextSaveGState(context)
		CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
		CGContextDrawPath(context, kCGPathFill)
		
		CGContextRestoreGState(context)
		
		super.drawRect(rect)
	}
	
	func key(key: Key, pressed: Bool) {
		let code: Int = key.keyCode! as Int
		keyboard.keyWithCode(code, pressed: pressed)
		
		if pressed {
			playSound()
		}
	}

	func playSound() {
		var error: NSError?
		let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("keyPressSound", ofType: "wav")!)
		
		self.audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
		self.audioPlayer?.prepareToPlay()
		self.audioPlayer?.play()
	}
}