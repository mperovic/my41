//
//  Key.swift
//  my41
//
//  Created by Miroslav Perovic on 2/7/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import UIKit

class Key: UIButton {
	@IBOutlet weak var keygroup: KeyGroup!

	var lowerText: String?
	var upperText: NSMutableAttributedString?
	var shiftButton: String?
	var switchButton: String?

	var keyCode: NSNumber?
	var pressed: Bool = false

	let roundedRadius: CGFloat = 3.0
	let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.layer.cornerRadius = roundedRadius
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.blackColor().CGColor
		self.layer.masksToBounds = true
		
		self.setNeedsDisplay()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.layer.cornerRadius = roundedRadius
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.blackColor().CGColor
		self.layer.masksToBounds = true
		
		self.setNeedsDisplay()
	}
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
	{
		super.touchesBegan(touches, withEvent: event)
		
		downKey()
		highlighted = true
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
	{
		super.touchesEnded(touches, withEvent: event)
		
		upKey()
		highlighted = false
	}
	
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		let xRatio = self.bounds.size.height / 51.0
		let yRatio = self.bounds.size.height / 42.0

		CGContextSaveGState(context)
		let backgroundGradient = CAGradientLayer()
		backgroundGradient.masksToBounds = true
		backgroundGradient.cornerRadius = self.layer.cornerRadius
		backgroundGradient.frame = self.bounds
		if switchButton == "Y" {
			backgroundGradient.colors = [
				UIColor(white: 0.30, alpha: 1.0).CGColor,
				UIColor(white: 0.42, alpha: 1.0).CGColor,
				UIColor(white: 0.50, alpha: 1.0).CGColor
			]
			backgroundGradient.locations = [
				0.0,
				0.5,
				1.0
			]
		} else if shiftButton == "Y" {
			backgroundGradient.colors = [
				UIColor(red: 0.7490, green: 0.4901, blue: 0.1765, alpha: 1.0).CGColor,
				UIColor(red: 0.7176, green: 0.4549, blue: 0.1765, alpha: 1.0).CGColor,
				UIColor(red: 0.6745, green: 0.4235, blue: 0.0549, alpha: 1.0).CGColor,
				UIColor(red: 0.6078, green: 0.3961, blue: 0.08235, alpha: 1.0).CGColor,
				UIColor(red: 0.5804, green: 0.3961, blue: 0.1294, alpha: 1.0).CGColor,
				UIColor(red: 0.4784, green: 0.2745, blue: 0.0471, alpha: 1.0).CGColor
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
				UIColor(white: 0.50, alpha: 1.0).CGColor,
				UIColor(white: 0.42, alpha: 1.0).CGColor,
				UIColor(white: 0.30, alpha: 1.0).CGColor,
				UIColor(white: 0.27, alpha: 1.0).CGColor,
				UIColor(white: 0.20, alpha: 1.0).CGColor,
				UIColor(white: 0.17, alpha: 1.0).CGColor
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
			if self.layer.sublayers.count > 0 {
				self.layer.sublayers.removeAtIndex(0)
			}
		}
		self.layer.insertSublayer(backgroundGradient, atIndex: 0)
		
		// Draw darker overlay if button is pressed
		if highlighted {
			UIColor(white: 0.0, alpha: 0.35).setFill()
			let darkOverlay = UIBezierPath(roundedRect: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)), cornerRadius: roundedRadius)
			darkOverlay.fill()
		}
		
		// Text Drawing
		if lowerText != nil {
			let lowerTextLayer = CATextLayer()
			lowerTextLayer.frame = CGRectMake(1.0, (rect.height / 2.0), rect.width - 2.0, rect.height / 2.0)
			lowerTextLayer.alignmentMode = kCAAlignmentCenter
			
			lowerTextLayer.font = "Helvetica"
			if countElements(lowerText!) > 1 {
				lowerTextLayer.fontSize = 13.0 * yRatio
			} else {
				lowerTextLayer.fontSize = 15.0 * yRatio
			}
			lowerTextLayer.foregroundColor = UIColor(red: 0.341, green: 0.643, blue: 0.78, alpha: 1.0).CGColor
			lowerTextLayer.string = lowerText!
			self.layer.addSublayer(lowerTextLayer)
		}
		
		if upperText != nil {
			let upperTextLayer = CATextLayer()
			upperTextLayer.alignmentMode = kCAAlignmentCenter
			if upperText?.string == "ON" || upperText?.string == "USER" || upperText?.string == "PRGM" || upperText?.string == "ALPHA" {
				upperTextLayer.frame = CGRectMake(1.0, 2.0, rect.width - 2.0, rect.height - 4.0)
			} else if upperText?.string == "╋" || upperText?.string == "━" {
				upperTextLayer.frame = CGRectMake(1.0, 2.0, rect.width - 2.0, (rect.height / 2.0) - 2.0)
			} else if upperText?.string == "÷" || upperText?.string == "×" {
				upperTextLayer.frame = CGRectMake(1.0, 0.0, rect.width - 2.0, (rect.height / 2.0))
			} else {
				upperTextLayer.frame = CGRectMake(1.0, 1.0, rect.width - 2.0, (rect.height / 2.0))
			}
			upperTextLayer.string = upperText!
			self.layer.addSublayer(upperTextLayer)
		}
		CGContextRestoreGState(context)
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
