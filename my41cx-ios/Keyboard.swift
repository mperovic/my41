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
import AudioToolbox

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
	
	func keyWithCode(_ code: Int, pressed: Bool) {
		cpu.keyWithCode(code, pressed: pressed)
	}
}

class KeyGroup: UIView {
	@IBOutlet weak var keyboard: iOSKeyboard!
	
	var mySound: SystemSoundID = 0
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let url = URL.init(fileURLWithPath: Bundle.main.pathForResource("keyPressSound", ofType: "wav")!)
		AudioServicesCreateSystemSoundID(url, &self.mySound)
	}

	override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		context?.saveGState()
		context?.setFillColor(UIColor.clear().cgColor)
		context?.drawPath(using: CGPathDrawingMode.fill)
		
		context?.restoreGState()
		
		super.draw(rect)
	}
	
	func key(_ key: Key, pressed: Bool) {
		let code: Int = key.keyCode! as Int
		keyboard.keyWithCode(code, pressed: pressed)
		
		if pressed && SOUND {
			DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUtility).async {
				AudioServicesPlaySystemSound(self.mySound)
				return
			}
		}
	}
}
