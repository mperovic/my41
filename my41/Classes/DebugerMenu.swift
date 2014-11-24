//
//  DebugerMenu.swift
//  my41
//
//  Created by Miroslav Perovic on 11/15/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class DebugMenuViewController: NSViewController {
	var registersView: SelectedDebugView?
	var memoryView: SelectedDebugView?
	var debugContainerViewController: DebugContainerViewController?
	
	@IBOutlet weak var menuView: NSView!
	
	override func viewWillAppear() {
		self.view.layer = CALayer()
		self.view.layer?.backgroundColor = NSColor(calibratedRed: 0.4824, green: 0.6667, blue: 0.2941, alpha: 1.0).CGColor
		self.view.wantsLayer = true
		
		registersView = SelectedDebugView(frame: CGRectMake(0, self.menuView.frame.size.height - 35, 184, 24))
		registersView?.text = "Registers"
		registersView?.selected = true
		self.menuView.addSubview(registersView!)
		
		memoryView = SelectedDebugView(frame: CGRectMake(0, self.menuView.frame.size.height - 59, 184, 24))
		memoryView?.text = "Memory"
		memoryView?.selected = false
		self.menuView.addSubview(memoryView!)
	}
	
	@IBAction func registersAction(sender: AnyObject) {
		registersView!.selected = true
		memoryView!.selected = false
		registersView!.setNeedsDisplayInRect(registersView!.bounds)
		memoryView!.setNeedsDisplayInRect(memoryView!.bounds)
		
		debugContainerViewController?.loadCPUViewController()
	}
	
	@IBAction func memoryAction(sender: AnyObject) {
		registersView!.selected = false
		memoryView!.selected = true
		registersView!.setNeedsDisplayInRect(registersView!.bounds)
		memoryView!.setNeedsDisplayInRect(memoryView!.bounds)
		
		debugContainerViewController?.loadMemoryViewController()
	}
}

class DebugerMenuView: NSView {
	
}

class SelectedDebugView: NSView {
	var text: NSString?
	var selected: Bool?
	
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let backColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.95)
		let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1)
		
		let font = NSFont(name: "Helvetica Bold", size: 14.0)
		
		let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
		let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.LeftTextAlignment
		
		if selected! {
			//// Rectangle Drawing
			let rectangleCornerRadius: CGFloat = 5
			let rectangleRect = NSMakeRect(0, 0, 184, 24)
			let rectangleInnerRect = NSInsetRect(rectangleRect, rectangleCornerRadius, rectangleCornerRadius)
			let rectanglePath = NSBezierPath()
			rectanglePath.moveToPoint(NSMakePoint(NSMinX(rectangleRect), NSMinY(rectangleRect)))
			rectanglePath.appendBezierPathWithArcWithCenter(
				NSMakePoint(NSMaxX(rectangleInnerRect), NSMinY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 270,
				endAngle: 360
			)
			rectanglePath.appendBezierPathWithArcWithCenter(
				NSMakePoint(NSMaxX(rectangleInnerRect), NSMaxY(rectangleInnerRect)),
				radius: rectangleCornerRadius,
				startAngle: 0,
				endAngle: 90
			)
			rectanglePath.lineToPoint(NSMakePoint(NSMinX(rectangleRect), NSMaxY(rectangleRect)))
			rectanglePath.closePath()
			backColor.setFill()
			rectanglePath.fill()
			
			if let actualFont = font {
				let textFontAttributes: NSDictionary = [
					NSFontAttributeName: actualFont,
					NSForegroundColorAttributeName: textColor,
					NSParagraphStyleAttributeName: textStyle
				]
				
				text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		} else {
			if let actualFont = font {
				let textFontAttributes: NSDictionary = [
					NSFontAttributeName: actualFont,
					NSForegroundColorAttributeName: backColor,
					NSParagraphStyleAttributeName: textStyle
				]
				
				text?.drawInRect(NSOffsetRect(textRect, 0, 1), withAttributes: textFontAttributes)
			}
		}
	}
}


//MARK: -

class DebugMenuLabelView: NSView {
	override func awakeFromNib() {
		var viewLayer: CALayer = CALayer()
		viewLayer.backgroundColor = CGColorCreateGenericRGB(0.5412, 0.7098, 0.3804, 1.0)
		self.wantsLayer = true
		self.layer = viewLayer
	}
}
