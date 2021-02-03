//
//  PreferencesMenu.swift
//  my41
//
//  Created by Miroslav Perovic on 11/16/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesMenuViewController: NSViewController {
	var calculatorView: SelectedPreferencesView?
	var modsView: SelectedPreferencesView?
	
	var preferencesContainerViewController: PreferencesContainerViewController?
	
	@IBOutlet weak var menuView: NSView!
	
	override func viewWillAppear() {
	}
	
	override func viewDidLayout() {
		if calculatorView != nil {
			calculatorView?.removeFromSuperview()
		}
		calculatorView = SelectedPreferencesView(
			frame: CGRect(
				x: 0.0,
				y: self.menuView.frame.height - 38.0,
				width: 184.0,
				height: 24.0
			)
		)
		calculatorView?.text = "Calculator"
		calculatorView?.selected = true
		self.menuView.addSubview(calculatorView!)
		
		if modsView != nil {
			modsView?.removeFromSuperview()
		}
		modsView = SelectedPreferencesView(
			frame: CGRect(
				x: 0.0,
				y: self.menuView.frame.height - 65.0,
				width: 184.0,
				height: 24.0
			)
		)
		modsView?.text = "MODs"
		modsView?.selected = false
		self.menuView.addSubview(modsView!)
	}
	
	
	// MARK: Actions
	@IBAction func selectCalculatorAction(sender: AnyObject) {
		calculatorView?.selected = true
		modsView?.selected = false
		calculatorView!.setNeedsDisplay(calculatorView!.bounds)
		modsView!.setNeedsDisplay(modsView!.bounds)
		
		preferencesContainerViewController?.loadPreferencesCalculatorViewController()
	}
	
	@IBAction func selectModAction(sender: AnyObject) {
		calculatorView?.selected = false
		modsView?.selected = true
		calculatorView!.setNeedsDisplay(calculatorView!.bounds)
		modsView!.setNeedsDisplay(modsView!.bounds)
		
		preferencesContainerViewController?.loadPreferencesModsViewController()
	}
}

class PreferencesMenuView: NSView {
	override func awakeFromNib() {
		let viewLayer: CALayer = CALayer()
		viewLayer.backgroundColor = CGColor(red: 0.9843, green: 0.9804, blue: 0.9725, alpha: 1.0)
		self.wantsLayer = true
		self.layer = viewLayer
	}
}

//MARK: -

class PreferencesMenuLabelView: NSView {
	override func awakeFromNib() {
		let viewLayer: CALayer = CALayer()
		viewLayer.backgroundColor = CGColor(red: 0.8843, green: 0.8804, blue: 0.8725, alpha: 1.0)
		self.wantsLayer = true
		self.layer = viewLayer
	}
}

class SelectedPreferencesView: NSView {
	var text: NSString?
	var selected: Bool?
	
	override func draw(_ dirtyRect: NSRect) {
		//// Color Declarations
		let backColor = NSColor(calibratedRed: 0.1569, green: 0.6157, blue: 0.8902, alpha: 0.95)
		let textColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
		
		let font = NSFont(name: "Helvetica Bold", size: 14.0)
		
		let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
		let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = .left
		
		if selected! {
			//// Rectangle Drawing
			let rectangleCornerRadius: CGFloat = 5
			let rectangleRect = NSMakeRect(0, 0, 184, 24)
			let rectangleInnerRect = NSInsetRect(rectangleRect, rectangleCornerRadius, rectangleCornerRadius)
			let rectanglePath = NSBezierPath()
			rectanglePath.move(to: NSMakePoint(NSMinX(rectangleRect), NSMinY(rectangleRect)))
			rectanglePath.appendArc(
				withCenter: NSMakePoint(NSMaxX(rectangleInnerRect), NSMinY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 270,
				endAngle: 360
			)
			rectanglePath.appendArc(
				withCenter: NSMakePoint(NSMaxX(rectangleInnerRect), NSMaxY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 0,
				endAngle: 90
			)
			rectanglePath.line(to: NSMakePoint(NSMinX(rectangleRect), NSMaxY(rectangleRect)))
			rectanglePath.close()
			backColor.setFill()
			rectanglePath.fill()
			
			if let actualFont = font {
				let textFontAttributes = [
					NSAttributedString.Key.font: actualFont,
					NSAttributedString.Key.foregroundColor: textColor,
					NSAttributedString.Key.paragraphStyle: textStyle
				]
				
				text?.draw(in: NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		} else {
			if let actualFont = font {
				let textFontAttributes = [
					NSAttributedString.Key.font: actualFont,
					NSAttributedString.Key.foregroundColor: backColor,
					NSAttributedString.Key.paragraphStyle: textStyle
				]
				
				text?.draw(in: NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		}
	}
}
