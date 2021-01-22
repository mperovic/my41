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
	
	@IBOutlet weak var keyOn: CalculatorKey!
	@IBOutlet weak var keyUser: CalculatorKey!
	@IBOutlet weak var keyPrgm: CalculatorKey!
	@IBOutlet weak var keyAlpha: CalculatorKey!

	override init() {
		super.init()
	}
	
	func keyWithCode(_ code: Bits8, pressed: Bool) {
		cpu.keyWithCode(code, pressed: pressed)
	}
}

class KeyGroup: UIView {
	@IBOutlet weak var keyboard: iOSKeyboard!
	
	var mySound: SystemSoundID = 0
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: "keyPressSound", ofType: "wav")!)
		AudioServicesCreateSystemSoundID(url as CFURL, &self.mySound)
	}

	override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		context?.saveGState()
		context?.setFillColor(UIColor.clear.cgColor)
		context?.drawPath(using: CGPathDrawingMode.fill)
		
		context?.restoreGState()
		
		super.draw(rect)
	}
	
	func key(_ key: CalculatorKey, pressed: Bool) {
		keyboard.keyWithCode(Bits8(truncating: key.keyCode!), pressed: pressed)
		
		if pressed && SOUND {
			DispatchQueue.global(qos: .utility).async {
				AudioServicesPlaySystemSound(self.mySound)
			}
		}
	}
}
