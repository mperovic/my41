//
//  Key.swift
//  my41
//
//  Created by Miroslav Perovic on 2/7/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import UIKit

class CalculatorKey: UIButton {
	@IBOutlet weak var keygroup: KeyGroup!

	@objc var lowerText: String?
	@objc var upperText: NSMutableAttributedString?
	@objc var shiftButton: String?
	var switchButton: String?

	@objc var keyCode: NSNumber?
	var pressed: Bool = false

	let roundedRadius: CGFloat = 3.0
//	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.layer.cornerRadius = roundedRadius
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.black.cgColor
		self.layer.masksToBounds = true
		
		self.setNeedsDisplay()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.layer.cornerRadius = roundedRadius
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.black.cgColor
		self.layer.masksToBounds = true
		
		self.setNeedsDisplay()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		downKey()
		isHighlighted = true
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		upKey()
		isHighlighted = false
	}
	
	override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
//		let xRatio = self.bounds.size.height / 51.0
		let yRatio = self.bounds.size.height / 42.0

		context?.saveGState()
		let backgroundGradient = CAGradientLayer()
		backgroundGradient.masksToBounds = true
		backgroundGradient.cornerRadius = self.layer.cornerRadius
		backgroundGradient.frame = self.bounds
		if switchButton == "Y" {
			backgroundGradient.colors = [
				UIColor(white: 0.30, alpha: 1.0).cgColor,
				UIColor(white: 0.42, alpha: 1.0).cgColor,
				UIColor(white: 0.50, alpha: 1.0).cgColor
			]
			backgroundGradient.locations = [
				0.0,
				0.5,
				1.0
			]
		} else if shiftButton == "Y" {
			backgroundGradient.colors = [
				UIColor(red: 0.7490, green: 0.4901, blue: 0.1765, alpha: 1.0).cgColor,
				UIColor(red: 0.7176, green: 0.4549, blue: 0.1765, alpha: 1.0).cgColor,
				UIColor(red: 0.6745, green: 0.4235, blue: 0.0549, alpha: 1.0).cgColor,
				UIColor(red: 0.6078, green: 0.3961, blue: 0.08235, alpha: 1.0).cgColor,
				UIColor(red: 0.5804, green: 0.3961, blue: 0.1294, alpha: 1.0).cgColor,
				UIColor(red: 0.4784, green: 0.2745, blue: 0.0471, alpha: 1.0).cgColor
			]
			backgroundGradient.locations = [
				0.0,
				0.1,
				0.49,
				0.49,
				0.9,
				1.0
			]
		} else {
			backgroundGradient.colors = [
				UIColor(white: 0.50, alpha: 1.0).cgColor,
				UIColor(white: 0.42, alpha: 1.0).cgColor,
				UIColor(white: 0.30, alpha: 1.0).cgColor,
				UIColor(white: 0.27, alpha: 1.0).cgColor,
				UIColor(white: 0.20, alpha: 1.0).cgColor,
				UIColor(white: 0.17, alpha: 1.0).cgColor
			]
			backgroundGradient.locations = [
				0.0,
				0.12,
				0.49,
				0.49,
				0.98,
				1.0
			]
		}
		if self.layer.sublayers != nil {
			if let sublayers = self.layer.sublayers?.count, sublayers > 0 {
				self.layer.sublayers?.remove(at: 0)
			}
		}
		self.layer.insertSublayer(backgroundGradient, at: 0)
		
		// Draw darker overlay if button is pressed
		if isHighlighted {
			UIColor(white: 0.0, alpha: 0.35).setFill()
			let darkOverlay = UIBezierPath(roundedRect: rect.inset(by: UIEdgeInsets.init(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)), cornerRadius: roundedRadius)
			darkOverlay.fill()
		}
		
		// Text Drawing
		if let lower = lowerText {
			let lowerTextLayer = CATextLayer()
			lowerTextLayer.frame = CGRect(x: 1.0, y: (rect.height / 2.0), width: rect.width - 2.0, height: rect.height / 2.0)
			lowerTextLayer.alignmentMode = CATextLayerAlignmentMode.center

			let fontName: CFString = "Helvetica" as CFString
			lowerTextLayer.font = fontName
			if lower.count > 1 {
				lowerTextLayer.fontSize = 13.0 * yRatio
			} else {
				lowerTextLayer.fontSize = 15.0 * yRatio
			}
			lowerTextLayer.foregroundColor = UIColor(red: 0.341, green: 0.643, blue: 0.78, alpha: 1.0).cgColor
			lowerTextLayer.string = lower
			self.layer.addSublayer(lowerTextLayer)
		}
		
		if let upper = upperText {
			let upperTextLayer = CATextLayer()
			upperTextLayer.alignmentMode = CATextLayerAlignmentMode.center
			if upper.string == "ON" || upperText?.string == "USER" || upperText?.string == "PRGM" || upperText?.string == "ALPHA" {
				upperTextLayer.frame = CGRect(x: 1.0, y: 2.0, width: rect.width - 2.0, height: rect.height - 4.0)
			} else if upper.string == "╋" || upperText?.string == "━" {
				upperTextLayer.frame = CGRect(x: 1.0, y: 2.0, width: rect.width - 2.0, height: (rect.height / 2.0) - 2.0)
			} else if upper.string == "÷" || upperText?.string == "×" {
				upperTextLayer.frame = CGRect(x: 1.0, y: 0.0, width: rect.width - 2.0, height: (rect.height / 2.0))
			} else {
				upperTextLayer.frame = CGRect(x: 1.0, y: 1.0, width: rect.width - 2.0, height: (rect.height / 2.0))
			}
			upperTextLayer.string = upper
			self.layer.addSublayer(upperTextLayer)
		}
		context?.restoreGState()
	}

	func downKey() {
		pressed = true
		notifyKeyGroup()
	}
	
	func upKey() {
		pressed = false
		notifyKeyGroup()
	}
	
	func notifyKeyGroup() {
		if keygroup != nil {
			keygroup.key(self, pressed: pressed)
		}
	}
}
