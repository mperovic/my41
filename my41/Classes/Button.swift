//
//  Button.swift
//  my41
//
//  Created by Miroslav Perovic on 9/6/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class Key: NSButton {
	@IBOutlet weak var keygroup: KeyGroup!
	var keyCode: NSNumber?
	var pressed: Bool = false
	
	override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
		return true
	}
	
	override func mouseDown(with theEvent: NSEvent) {
		if theEvent.modifierFlags.intersection(.control) == [] {
			downKey()
		}
		highlight(true)
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		appDelegate.buttonPressed = true
	}
	
	override func mouseUp(with theEvent: NSEvent) {
		if theEvent.modifierFlags.intersection(.control) == [] {
			upKey()
		}
		highlight(false)
		
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		appDelegate.buttonPressed = false
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
			keygroup.key(key: self, pressed: pressed)
		}
	}
}

class ButtonCell: NSButtonCell {
	@objc var lowerText: String?
	@objc var upperText: NSMutableAttributedString?
	@objc var shiftButton: String?
	var switchButton: String?
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
		let ctx = NSGraphicsContext.current()!
		ctx.saveGraphicsState()
		
		let roundedRadius: CGFloat = 3.0
		
		// Outer stroke (drawn as gradient)
		let outerClip: NSBezierPath = NSBezierPath(roundedRect: frame,
			xRadius: roundedRadius,
			yRadius: roundedRadius)
		outerClip.setClip()
		
		let outerGradient = NSGradient(colorsAndLocations:
			(NSColor(deviceWhite: 0.20, alpha: 1.0), 0.0),
			(NSColor(deviceWhite: 0.21, alpha: 1.0), 1.0)
		)
		outerGradient?.draw(in: outerClip.bounds, angle: 90.0)
		ctx.restoreGraphicsState()
		
		// Background gradient
		ctx.saveGraphicsState()
		let backgroundPath: NSBezierPath = NSBezierPath(roundedRect: NSInsetRect(frame, 2.0, 2.0),
			xRadius: roundedRadius,
			yRadius: roundedRadius)
		backgroundPath.setClip()
		
		var backgroundGradient: NSGradient?
		if switchButton == "Y" {
			backgroundGradient = NSGradient(colorsAndLocations:
				(NSColor(deviceWhite: 0.30, alpha: 1.0), 0.0),
				(NSColor(deviceWhite: 0.42, alpha: 1.0), 0.5),
				(NSColor(deviceWhite: 0.50, alpha: 1.0), 1.0)
			)
		} else {
			if shiftButton == "Y" {
				backgroundGradient = NSGradient(colorsAndLocations:
					(NSColor(calibratedRed: 0.4784, green: 0.2745, blue: 0.0471, alpha: 1.0), 0.0),
					(NSColor(calibratedRed: 0.5804, green: 0.3961, blue: 0.1294, alpha: 1.0), 0.1),
					(NSColor(calibratedRed: 0.6078, green: 0.3961, blue: 0.08235, alpha: 1.0), 0.49),
					(NSColor(calibratedRed: 0.6745, green: 0.4235, blue: 0.0549, alpha: 1.0), 0.49),
					(NSColor(calibratedRed: 0.7176, green: 0.4549, blue: 0.1765, alpha: 1.0), 0.9),
					(NSColor(calibratedRed: 0.749, green: 0.4901, blue: 0.1765, alpha: 1.0), 1.0)
				)
			} else {
				backgroundGradient = NSGradient(colorsAndLocations:
					(NSColor(deviceWhite: 0.17, alpha: 1.0), 0.0),
					(NSColor(deviceWhite: 0.20, alpha: 1.0), 0.12),
					(NSColor(deviceWhite: 0.27, alpha: 1.0), 0.49),
					(NSColor(deviceWhite: 0.30, alpha: 1.0), 0.49),
					(NSColor(deviceWhite: 0.42, alpha: 1.0), 0.98),
					(NSColor(deviceWhite: 0.50, alpha: 1.0), 1.0)
				)
			}
		}
		backgroundGradient?.draw(in: backgroundPath.bounds, angle: 270.0)
		ctx.restoreGraphicsState()
		
		// Dark stroke
//		ctx.saveGraphicsState()
//		NSColor(deviceWhite: 0.12, alpha: 1.0).setStroke()
//		NSBezierPath(roundedRect: NSInsetRect(frame, 1.5, 1.5),
//			xRadius: roundedRadius,
//			yRadius: roundedRadius)
//		ctx.restoreGraphicsState()
//		
//		// Inner light stroke
//		ctx.saveGraphicsState()
//		NSColor(deviceWhite: 1.0, alpha: 0.05).setStroke()
//		NSBezierPath(roundedRect: NSInsetRect(frame, 2.5, 2.5),
//			xRadius: roundedRadius,
//			yRadius: roundedRadius)
//		ctx.restoreGraphicsState()
		
		// Draw darker overlay if button is pressed
		if isHighlighted {
			ctx.saveGraphicsState()
			NSBezierPath(roundedRect: NSInsetRect(frame, 2.0, 2.0),
				xRadius: roundedRadius,
				yRadius: roundedRadius).setClip()
			NSColor(calibratedWhite: 0.0, alpha: 0.35).setFill()
			NSRectFillUsingOperation(frame, .sourceOver)
			ctx.restoreGraphicsState()
		}
		
		// Text Drawing
		if lowerText != nil {
			var lowerTextRect: NSRect
			if lowerText == "N" {
				lowerTextRect = NSMakeRect(1.0, 17.0, 86.0, 12.0)
			} else if lowerText == "R" || lowerText == "S" || lowerText == "T" {
				lowerTextRect = NSMakeRect(1.0, 17.0, 40.0, 12.0)
			} else if lowerText == "V" || lowerText == "W" || lowerText == "X" {
				lowerTextRect = NSMakeRect(1.0, 17.0, 40.0, 12.0)
			} else if lowerText == "Z" || lowerText == "=" || lowerText == "?" {
				lowerTextRect = NSMakeRect(1.0, 17.0, 40.0, 12.0)
			} else if lowerText == "," {
				lowerTextRect = NSMakeRect(1.0, 14.0, 40.0, 15.0)
			} else if lowerText == "SPACE" {
				lowerTextRect = NSMakeRect(1.0, 18.0, 40.0, 12.0)
			} else {
				lowerTextRect = NSMakeRect(1.0, 17.0, 36.0, 12.0)
			}
			let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
			textStyle.alignment = .center
			
			var font: NSFont
			if (lowerText!).characters.count > 1 {
				font = NSFont(name: "Helvetica", size: 9.0)!
			} else {
				font = NSFont(name: "Helvetica", size: 11.0)!
			}
			let lowerTextFontAttributes: Dictionary = [
				NSAttributedString.Key.font: font,
				NSAttributedString.Key.foregroundColor: NSColor(calibratedRed: 0.341, green: 0.643, blue: 0.78, alpha: 1.0),
				NSAttributedString.Key.paragraphStyle: textStyle
			]
			lowerText?.draw(in: NSOffsetRect(lowerTextRect, 0, -1), withAttributes: lowerTextFontAttributes)
		}
		
		if upperText != nil {
			let paragrapStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
			paragrapStyle.alignment = .center
			upperText!.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragrapStyle, range: NSMakeRange(0, upperText!.length))
			
			var upperTextRect: NSRect
			if upperText?.string == "ENTER ↑" || upperText?.string == "N" {
				upperTextRect = NSMakeRect(1.0, 3.0, 86.0, 15.0)
			} else if upperText?.string == "÷" || upperText?.string == "×" {
				upperTextRect = NSMakeRect(1.0, 0.0, 36.0, 15.0)
			} else if upperText?.string == "╋" || upperText?.string == "━" {
				upperTextRect = NSMakeRect(1.0, 5.0, 36.0, 15.0)
			} else if upperText?.string == "7" || upperText?.string == "8" || upperText?.string == "9" {
				upperTextRect = NSMakeRect(1.0, 1.0, 40.0, 15.0)
			} else if upperText?.string == "4" || upperText?.string == "5" || upperText?.string == "6" {
				upperTextRect = NSMakeRect(1.0, 1.0, 40.0, 15.0)
			} else if upperText?.string == "1" || upperText?.string == "2" || upperText?.string == "3" {
				upperTextRect = NSMakeRect(1.0, 1.0, 40.0, 15.0)
			} else if upperText?.string == "0" || upperText?.string == "•" || upperText?.string == "," {
				upperTextRect = NSMakeRect(1.0, 2.0, 40.0, 14.0)
			} else if upperText?.string == "SPACE" || upperText?.string == "R/S" {
				upperTextRect = NSMakeRect(1.0, 3.0, 40.0, 14.0)
			} else if upperText?.string == "ON" || upperText?.string == "USER" || upperText?.string == "PRGM" || upperText?.string == "ALPHA" {
				upperTextRect = NSMakeRect(3.0, 4.0, 48.0, 14.0)
			} else {
				upperTextRect = NSMakeRect(1.0, 3.0, 40.0, 15.0)
			}
			upperText!.draw(in: NSOffsetRect(upperTextRect, 0, -1))
		}
	}
}
