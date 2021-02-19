//
//  CalculatorWindow.swift
//  my41
//
//  Created by Miroslav Perovic on 8/28/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

typealias DisplayFont = [DisplaySegmentMap]
typealias DisplaySegmentPaths = [NSBezierPath]

class CalculatorWindowController: NSWindowController {
	
}

class CalculatorWindow : NSWindow {
	//This point is used in dragging to mark the initial click location
	var initialLocation: NSPoint?

	override init(
		contentRect: NSRect,
		styleMask style: NSWindow.StyleMask,
		backing backingStoreType: NSWindow.BackingStoreType,
		defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
	}
	
	override var acceptsFirstResponder: Bool { return true }

	override func awakeFromNib() {
		let appDelegate =  CalculatorApplication.shared.delegate as! AppDelegate
		appDelegate.window = self
		
		self.isExcludedFromWindowsMenu = false
		self.backgroundColor = NSColor.clear
		self.isOpaque = false
		self.hasShadow = true
	}
	
	override var canBecomeMain: Bool {
		get {
			return true
		}
	}
	
	override var canBecomeKey: Bool {
		get {
			return true
		}
	}
	
	override func mouseDown(with theEvent: NSEvent) {
		initialLocation = theEvent.locationInWindow
	}
	
	override func mouseDragged(with theEvent: NSEvent) {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		if appDelegate.buttonPressed {
			return
		}

		if let iLocation = initialLocation {
			let screenVisibleFrame = NSScreen.main()?.visibleFrame
			let windowFrame = self.frame
			var newOrigin = windowFrame.origin
			
			// Get the mouse location in window coordinates.
			let currentLocation = theEvent.locationInWindow
			
			// Update the origin with the difference between the new mouse location and the old mouse location.
			newOrigin.x += (currentLocation.x - iLocation.x)
			newOrigin.y += (currentLocation.y - iLocation.y)
			
			// Don't let window get dragged up under the menu bar
			if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame!.origin.y + screenVisibleFrame!.size.height)) {
				newOrigin.y = screenVisibleFrame!.origin.y + (screenVisibleFrame!.size.height - windowFrame.size.height)
			}
			
			// Move the window to the new location
			self.setFrameOrigin(newOrigin)
		}
	}
	
	override func mouseUp(with theEvent: NSEvent) {
		initialLocation = nil
	}
}

class Display : NSView, Peripheral {
	let numDisplayCells = 12
	let numAnnunciators = 12
	let numDisplaySegments = 17
	let numFontChars = 128
	
	var on: Bool = true
	var updateCountdown: Int = 0
	var registers = DisplayRegisters()
	var displayFont = DisplayFont()
	var segmentPaths = DisplaySegmentPaths()
	var annunciatorFont: NSFont?
	var annunciatorFontScale: CGFloat = 1.2
	var annunciatorFontSize: CGFloat = 9.0
	var annunciatorBottomMargin: CGFloat = 4.0
	var annunciatorPositions: [NSPoint] = [NSPoint](repeating: NSMakePoint(0.0, 0.0), count: 12)
	var foregroundColor: NSColor?
	
	var contrast: Digit {
		set {
			self.contrast = newValue & 0xf
			
			scheduleUpdate()
		}
		
		get {
			return self.contrast
		}
	}
	
//	override init() {
//		
//		super.init()
//	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func awakeFromNib() {
		calculatorController.display = self
		self.foregroundColor = NSColorList(name: "HP41").color(withKey: "displayForegroundColor")
		self.displayFont = self.loadFont("hpfont")
//		self.segmentPaths = self.loadSegmentPaths("hpchar")
		self.segmentPaths = bezierPaths()
		self.annunciatorFont = NSFont(name: "Menlo", size:self.annunciatorFontScale * self.annunciatorFontSize)
		self.annunciatorPositions = self.calculateAnnunciatorPositions(font: self.annunciatorFont!, inRect: self.bounds)
		self.on = true
		self.updateCountdown = 2
		bus.installPeripheral(self, inSlot: 0xFD)
		bus.display = self
		
		for idx in 0..<self.numDisplayCells {
			self.registers.A[idx] = 0xA
			self.registers.B[idx] = 0x3
			self.registers.C[idx] = 0x2
			self.registers.E = 0xfff
		}
		
		//-- initialize the display character to unicode lookup table:
		// The table simply contains one unicode character for each X-41 hardware character
		// index (0x00..0x7f). The file can be tweaked for whatever translation is desired.
		// Character groups (approximated):
		// 0x00..0x1f: A-Z uppercase characters
		// 0x20..0x3f: ASCII-like symbols and numbers
		// 0x40..0x4f: a-e + "hangman"
		// 0x50..0x5f: some greek characters + "hangman"
		// 0x60..0x7f: a-z lowercase characters
		let filename: String = Bundle.main.path(forResource: CTULookupRsrcName, ofType: CTULookupRsrcType)!
		let mString: NSMutableString = try! NSMutableString(contentsOfFile: filename, encoding: String.Encoding.unicode.rawValue)
		CTULookup = String(mString)
		CTULookupLength = (CTULookup!).characters.count
	}

	override var isFlipped:Bool{
		return true
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if on {
			let cellTranslation = NSAffineTransform()
			cellTranslation.translateX(by: cellWidth(), yBy: 0.0)
			foregroundColor?.set()
			if true {
				NSGraphicsContext.saveGraphicsState()
				for idx in 0..<numDisplayCells {
					let segmentsOn = segmentsForCell(idx)
					for seg in 0..<numDisplaySegments {
						if (segmentsOn & (1 << UInt32(seg))) != 0 {
							segmentPaths[seg].fill()
						}
					}
					cellTranslation.concat()
				}
				NSGraphicsContext.restoreGraphicsState()
			}
			
			self.lockFocus()
			let attrs = [
				NSAttributedString.Key.font: annunciatorFont!
			]
			calculatorController.prgmMode = false
			calculatorController.alphaMode = false
			for idx in 0..<numAnnunciators {
				if annunciatorOn(idx) {
					if idx == 10 {
						calculatorController.prgmMode = true
					}
					if idx == 11 {
						calculatorController.alphaMode = true
					}
					
					let transformation = NSAffineTransform()
					let point = annunciatorPositions[idx]
					transformation.translateX(by: point.x, yBy: point.y)
					transformation.scale(by: 1.0 / annunciatorFontScale)
					NSGraphicsContext.saveGraphicsState()
					transformation.concat()
					let nsString = annunciatorStrings[idx] as NSString
					nsString.draw(
						at: NSMakePoint(0.0, 0.0),
						withAttributes: attrs
					)
					NSGraphicsContext.restoreGraphicsState()
				}
			}
			self.unlockFocus()
		}
	}
	
	func bezierPaths() -> DisplaySegmentPaths
	{
		var paths: DisplaySegmentPaths = DisplaySegmentPaths()

		//1
		/*
		Key: 0
		Bounds: {{2.3755772113800049, 0}, {12.6975257396698, 2}}
		Control point bounds: {{2.3755772113800049, 0}, {12.6975257396698, 2}}
		4.617837 2.000000 moveto
		2.375577 0.000000 lineto
		15.073103 0.000000 lineto
		12.304828 2.000000 lineto
		4.617837 2.000000 lineto
		closepath
		4.617837 2.000000 moveto
		*/
		let bezierPath0 = NSBezierPath()
		bezierPath0.move(to: NSMakePoint(4.617837, 2.000000))
		bezierPath0.line(to: NSMakePoint(2.375577, 0.000000))
		bezierPath0.line(to: NSMakePoint(15.073103, 0.000000))
		bezierPath0.line(to: NSMakePoint(12.304828, 2.000000))
		bezierPath0.line(to: NSMakePoint(4.617837, 2.000000))
		bezierPath0.close()
		bezierPath0.move(to: NSMakePoint(4.617837, 2.000000))
		paths.append(bezierPath0)
		
		// 2
		/*
		Bounds: {{1.0269801616668701, 0.71005439758300781}, {2.4166390895843506, 9.9931669235229492}}
		Control point bounds: {{1.0269801616668701, 0.71005439758300781}, {2.4166390895843506, 9.9931669235229492}}
		1.026980 10.703221 moveto
		1.935450 0.710054 lineto
		3.443619 6.210914 lineto
		3.136238 9.592111 lineto
		1.026980 10.703221 lineto
		closepath
		1.026980 10.703221 moveto
		*/
		let bezierPath1 = NSBezierPath()
		bezierPath1.move(to: NSMakePoint(1.026980, 10.703221))
		bezierPath1.line(to: NSMakePoint(1.935450, 0.710054))
		bezierPath1.line(to: NSMakePoint(3.443619, 6.210914))
		bezierPath1.line(to: NSMakePoint(3.136238, 9.592111))
		bezierPath1.line(to: NSMakePoint(1.026980, 10.703221))
		bezierPath1.close()
		bezierPath1.move(to: NSMakePoint(1.026980, 10.703221))
		paths.append(bezierPath1)
		
		// 3
		/*
		Bounds: {{2.4647183418273926, 0.74950754642486572}, {4.684511661529541, 9.7398122549057007}}
		Control point bounds: {{2.4647183418273926, 0.74950754642486572}, {4.684511661529541, 9.7398122549057007}}
		3.931293 6.098653 moveto
		2.464718 0.749508 lineto
		4.320368 2.404667 lineto
		6.413752 6.591435 lineto
		7.149230 10.489320 lineto
		5.669303 9.574674 lineto
		3.931293 6.098653 lineto
		closepath
		3.931293 6.098653 moveto
		*/
		let bezierPath2 = NSBezierPath()
		bezierPath2.move(to: NSMakePoint(3.931293, 6.098653))
		bezierPath2.line(to: NSMakePoint(2.464718, 0.749508))
		bezierPath2.line(to: NSMakePoint(4.320368, 2.404667))
		bezierPath2.line(to: NSMakePoint(6.413752, 6.591435))
		bezierPath2.line(to: NSMakePoint(7.149230, 10.489320))
		bezierPath2.line(to: NSMakePoint(5.669303, 9.574674))
		bezierPath2.line(to: NSMakePoint(3.931293, 6.098653))
		bezierPath2.close()
		bezierPath2.move(to: NSMakePoint(3.931293, 6.098653))
		paths.append(bezierPath2)
		
		// 4
		/*
		Bounds: {{6.9050822257995605, 2.25}, {2.3944964408874512, 7.8533802032470703}}
		Control point bounds: {{6.9050822257995605, 2.25}, {2.3944964408874512, 7.8533802032470703}}
		6.905082 6.498730 moveto
		7.291330 2.250000 lineto
		9.299579 2.250000 lineto
		8.884876 6.811726 lineto
		7.585231 10.103380 lineto
		6.905082 6.498730 lineto
		closepath
		6.905082 6.498730 moveto
		*/
		let bezierPath3 = NSBezierPath()
		bezierPath3.move(to: NSMakePoint(6.905082, 6.498730))
		bezierPath3.line(to: NSMakePoint(7.291330, 2.250000))
		bezierPath3.line(to: NSMakePoint(9.299579, 2.250000))
		bezierPath3.line(to: NSMakePoint(8.884876, 6.811726))
		bezierPath3.line(to: NSMakePoint(7.585231, 10.103380))
		bezierPath3.line(to: NSMakePoint(6.905082, 6.498730))
		bezierPath3.close()
		bezierPath3.move(to: NSMakePoint(6.905082, 6.498730))
		paths.append(bezierPath3)
		
		// 5
		/*
		Bounds: {{7.9639315605163574, 0.75679004192352295}, {6.9154620170593262, 9.7489453554153442}}
		Control point bounds: {{7.9639315605163574, 0.75679004192352295}, {6.9154620170593262, 9.7489453554153442}}
		9.352165 6.989707 moveto
		12.565980 2.428165 lineto
		14.879394 0.756790 lineto
		12.461739 6.048622 lineto
		9.993521 9.551898 lineto
		7.963932 10.505735 lineto
		9.352165 6.989707 lineto
		closepath
		9.352165 6.989707 moveto
		*/
		let bezierPath4 = NSBezierPath()
		bezierPath4.move(to: NSMakePoint(9.352165, 6.989707))
		bezierPath4.line(to: NSMakePoint(12.565980, 2.428165))
		bezierPath4.line(to: NSMakePoint(14.879394, 0.756790))
		bezierPath4.line(to: NSMakePoint(12.461739, 6.048622))
		bezierPath4.line(to: NSMakePoint(9.993521, 9.551898))
		bezierPath4.line(to: NSMakePoint(7.963932, 10.505735))
		bezierPath4.line(to: NSMakePoint(9.352165, 6.989707))
		bezierPath4.close()
		bezierPath4.move(to: NSMakePoint(9.352165, 6.989707))
		paths.append(bezierPath4)
		
		// 6
		/*
		Bounds: {{12.617741584777832, 0.75105857849121094}, {2.8139810562133789, 9.9741630554199219}}
		Control point bounds: {{12.617741584777832, 0.75105857849121094}, {2.8139810562133789, 9.9741630554199219}}
		14.524980 10.725222 moveto
		12.617742 9.614111 lineto
		12.924595 6.238729 lineto
		15.431723 0.751059 lineto
		14.524980 10.725222 lineto
		closepath
		14.524980 10.725222 moveto
		*/
		let bezierPath5 = NSBezierPath()
		bezierPath5.move(to: NSMakePoint(14.524980, 10.725222))
		bezierPath5.line(to: NSMakePoint(12.617742, 9.614111))
		bezierPath5.line(to: NSMakePoint(12.924595, 6.238729))
		bezierPath5.line(to: NSMakePoint(15.431723, 0.751059))
		bezierPath5.line(to: NSMakePoint(14.524980, 10.725222))
		bezierPath5.close()
		bezierPath5.move(to: NSMakePoint(14.524980, 10.725222))
		paths.append(bezierPath5)
		
		// 7
		/*
		Bounds: {{1.5155218839645386, 10}, {5.4815198183059692, 2}}
		Control point bounds: {{1.5155218839645386, 10}, {5.4815198183059692, 2}}
		3.213154 12.000000 moveto
		1.515522 11.011001 lineto
		3.434736 10.000000 lineto
		5.406438 10.000000 lineto
		6.997042 10.983047 lineto
		5.072827 12.000000 lineto
		3.213154 12.000000 lineto
		closepath
		3.213154 12.000000 moveto
		*/
		let bezierPath6 = NSBezierPath()
		bezierPath6.move(to: NSMakePoint(3.213154, 12.000000))
		bezierPath6.line(to: NSMakePoint(1.515522, 11.011001))
		bezierPath6.line(to: NSMakePoint(3.434736, 10.000000))
		bezierPath6.line(to: NSMakePoint(5.406438, 10.000000))
		bezierPath6.line(to: NSMakePoint(6.997042, 10.983047))
		bezierPath6.line(to: NSMakePoint(5.072827, 12.000000))
		bezierPath6.line(to: NSMakePoint(3.213154, 12.000000))
		bezierPath6.close()
		bezierPath6.move(to: NSMakePoint(3.213154, 12.000000))
		paths.append(bezierPath6)
		
		// 8
		/*
		Bounds: {{8.0330619812011719, 10}, {5.951416015625, 2}}
		Control point bounds: {{8.0330619812011719, 10}, {5.951416015625, 2}}
		9.674292 12.000000 moveto
		8.033062 11.025712 lineto
		10.215584 10.000000 lineto
		12.286846 10.000000 lineto
		13.984478 10.988999 lineto
		12.065263 12.000000 lineto
		9.674292 12.000000 lineto
		closepath
		9.674292 12.000000 moveto
		*/
		let bezierPath7 = NSBezierPath()
		bezierPath7.move(to: NSMakePoint(9.674292, 12.000000))
		bezierPath7.line(to: NSMakePoint(8.033062, 11.025712))
		bezierPath7.line(to: NSMakePoint(10.215584, 10.000000))
		bezierPath7.line(to: NSMakePoint(12.286846, 10.000000))
		bezierPath7.line(to: NSMakePoint(13.984478, 10.988999))
		bezierPath7.line(to: NSMakePoint(12.065263, 12.000000))
		bezierPath7.line(to: NSMakePoint(9.674292, 12.000000))
		bezierPath7.close()
		bezierPath7.move(to: NSMakePoint(9.674292, 12.000000))
		paths.append(bezierPath7)
		
		// 9
		/*
		Bounds: {{0.070283412933349609, 11.274778366088867}, {2.8119742870330811, 9.9521026611328125}}
		Control point bounds: {{0.070283412933349609, 11.274778366088867}, {2.8119742870330811, 9.9521026611328125}}
		0.070283 21.226881 moveto
		0.975020 11.274778 lineto
		2.882258 12.385889 lineto
		2.594385 15.552494 lineto
		0.070283 21.226881 lineto
		closepath
		0.070283 21.226881 moveto
		*/
		let bezierPath8 = NSBezierPath()
		bezierPath8.move(to: NSMakePoint(0.070283, 21.226881))
		bezierPath8.line(to: NSMakePoint(0.975020, 11.274778))
		bezierPath8.line(to: NSMakePoint(2.882258, 12.385889))
		bezierPath8.line(to: NSMakePoint(2.594385, 15.552494))
		bezierPath8.line(to: NSMakePoint(0.070283, 21.226881))
		bezierPath8.close()
		bezierPath8.move(to: NSMakePoint(0.070283, 21.226881))
		paths.append(bezierPath8)
		
		// 10
		/*
		Bounds: {{0.61331439018249512, 11.522175788879395}, {6.4336917400360107, 9.7141599655151367}}
		Control point bounds: {{0.61331439018249512, 11.522175788879395}, {6.4336917400360107, 9.7141599655151367}}
		3.058874 15.738516 moveto
		5.306457 12.442060 lineto
		7.047006 11.522176 lineto
		5.594459 15.569930 lineto
		2.864343 19.574100 lineto
		0.613314 21.236336 lineto
		3.058874 15.738516 lineto
		closepath
		3.058874 15.738516 moveto
		*/
		let bezierPath9 = NSBezierPath()
		bezierPath9.move(to: NSMakePoint(3.058874, 15.738516))
		bezierPath9.line(to: NSMakePoint(5.306457, 12.442060))
		bezierPath9.line(to: NSMakePoint(7.047006, 11.522176))
		bezierPath9.line(to: NSMakePoint(5.594459, 15.569930))
		bezierPath9.line(to: NSMakePoint(2.864343, 19.574100))
		bezierPath9.line(to: NSMakePoint(0.613314, 21.236336))
		bezierPath9.line(to: NSMakePoint(3.058874, 15.738516))
		bezierPath9.close()
		bezierPath9.move(to: NSMakePoint(3.058874, 15.738516))
		paths.append(bezierPath9)
		
		// 11
		/*
		Bounds: {{5.7004213333129883, 11.920211791992188}, {2.4196805953979492, 7.8297882080078125}}
		Control point bounds: {{5.7004213333129883, 11.920211791992188}, {2.4196805953979492, 7.8297882080078125}}
		6.065075 15.738811 moveto
		7.435389 11.920212 lineto
		8.120102 15.224238 lineto
		7.708670 19.750000 lineto
		5.700421 19.750000 lineto
		6.065075 15.738811 lineto
		closepath
		6.065075 15.738811 moveto
		*/
		let bezierPath10 = NSBezierPath()
		bezierPath10.move(to: NSMakePoint(6.065075, 15.738811))
		bezierPath10.line(to: NSMakePoint(7.435389, 11.920212))
		bezierPath10.line(to: NSMakePoint(8.120102, 15.224238))
		bezierPath10.line(to: NSMakePoint(7.708670, 19.750000))
		bezierPath10.line(to: NSMakePoint(5.700421, 19.750000))
		bezierPath10.line(to: NSMakePoint(6.065075, 15.738811))
		bezierPath10.close()
		bezierPath10.move(to: NSMakePoint(6.065075, 15.738811))
		paths.append(bezierPath10)
		
		// 12
		/*
		Bounds: {{7.8598289489746094, 11.504337310791016}, {5.1586418151855469, 9.75909423828125}}
		Control point bounds: {{7.8598289489746094, 11.504337310791016}, {5.1586418151855469, 9.75909423828125}}
		8.609699 15.122776 moveto
		7.859829 11.504337 lineto
		9.419060 12.429949 lineto
		11.534890 16.308971 lineto
		13.018471 21.263432 lineto
		11.046081 19.589474 lineto
		8.609699 15.122776 lineto
		closepath
		8.609699 15.122776 moveto
		*/
		let bezierPath11 = NSBezierPath()
		bezierPath11.move(to: NSMakePoint(8.609699, 15.122776))
		bezierPath11.line(to: NSMakePoint(7.859829, 11.504337))
		bezierPath11.line(to: NSMakePoint(9.419060, 12.429949))
		bezierPath11.line(to: NSMakePoint(11.534890, 16.308971))
		bezierPath11.line(to: NSMakePoint(13.018471, 21.263432))
		bezierPath11.line(to: NSMakePoint(11.046081, 19.589474))
		bezierPath11.line(to: NSMakePoint(8.609699, 15.122776))
		bezierPath11.close()
		bezierPath11.move(to: NSMakePoint(8.609699, 15.122776))
		paths.append(bezierPath11)
		
		// 13
		/*
		Bounds: {{12.020228385925293, 11.296778678894043}, {2.4527921676635742, 10.034676551818848}}
		Control point bounds: {{12.020228385925293, 11.296778678894043}, {2.4527921676635742, 10.034676551818848}}
		12.020228 16.186754 moveto
		12.363762 12.407889 lineto
		14.473021 11.296779 lineto
		13.560777 21.331455 lineto
		12.020228 16.186754 lineto
		closepath
		12.020228 16.186754 moveto
		*/
		let bezierPath12 = NSBezierPath()
		bezierPath12.move(to: NSMakePoint(12.020228, 16.186754))
		bezierPath12.line(to: NSMakePoint(12.363762, 12.407889))
		bezierPath12.line(to: NSMakePoint(14.473021, 11.296779))
		bezierPath12.line(to: NSMakePoint(13.560777, 21.331455))
		bezierPath12.line(to: NSMakePoint(12.020228, 16.186754))
		bezierPath12.close()
		bezierPath12.move(to: NSMakePoint(12.020228, 16.186754))
		paths.append(bezierPath12)
		
		// 14
		/*
		Bounds: {{0.42085522413253784, 20}, {12.692788422107697, 2}}
		Control point bounds: {{0.42085522413253784, 20}, {12.692788422107697, 2}}
		0.420855 22.000000 moveto
		3.129292 20.000000 lineto
		10.757083 20.000000 lineto
		13.113644 22.000000 lineto
		0.420855 22.000000 lineto
		closepath
		0.420855 22.000000 moveto
		*/
		let bezierPath13 = NSBezierPath()
		bezierPath13.move(to: NSMakePoint(0.420855, 22.000000))
		bezierPath13.line(to: NSMakePoint(3.129292, 20.000000))
		bezierPath13.line(to: NSMakePoint(10.757083, 20.000000))
		bezierPath13.line(to: NSMakePoint(13.113644, 22.000000))
		bezierPath13.line(to: NSMakePoint(0.420855, 22.000000))
		bezierPath13.close()
		bezierPath13.move(to: NSMakePoint(0.420855, 22.000000))
		paths.append(bezierPath13)
		
		// 15
		/*
		Bounds: {{16.493814468383789, 9.4938144683837891}, {3.0123710632324219, 3.0123710632324219}}
		Control point bounds: {{16.493814468383789, 9.4938144683837891}, {3.0123710632324219, 3.0123710632324219}}
		19.506186 11.000000 moveto
		19.506186 11.000000 lineto
		19.506186 11.831843 18.831842 12.506186 18.000000 12.506186 curveto
		17.168158 12.506186 16.493814 11.831843 16.493814 11.000000 curveto
		16.493814 11.000000 lineto
		16.493814 11.000000 lineto
		16.493814 10.168157 17.168158 9.493814 18.000000 9.493814 curveto
		18.831842 9.493814 19.506186 10.168157 19.506186 11.000000 curveto
		19.506186 11.000000 lineto
		closepath
		19.506186 11.000000 moveto
		*/
		let bezierPath14 = NSBezierPath()
		bezierPath14.move(to: NSMakePoint(19.506186, 11.000000))
		bezierPath14.line(to: NSMakePoint(19.506186, 11.000000))
		bezierPath14.curve(to: NSMakePoint(19.506186, 11.831843), controlPoint1: NSMakePoint(18.831842, 12.506186), controlPoint2: NSMakePoint(18.000000, 12.506186))
		bezierPath14.curve(to: NSMakePoint(17.168158, 12.506186), controlPoint1: NSMakePoint(16.493814, 11.831843), controlPoint2: NSMakePoint(16.493814, 11.000000))
		bezierPath14.line(to: NSMakePoint(16.493814, 11.000000))
		bezierPath14.line(to: NSMakePoint(16.493814, 11.000000))
		bezierPath14.curve(to: NSMakePoint(16.493814, 10.168157), controlPoint1: NSMakePoint(17.168158, 9.493814), controlPoint2: NSMakePoint(18.000000, 9.493814))
		bezierPath14.curve(to: NSMakePoint(18.831842, 9.493814), controlPoint1: NSMakePoint(19.506186, 10.1681573), controlPoint2: NSMakePoint(19.506186, 11.000000))
		bezierPath14.line(to: NSMakePoint(19.506186, 11.000000))
		bezierPath14.close()
		bezierPath14.move(to: NSMakePoint(19.506186, 11.000000))
		paths.append(bezierPath14)
		
		// 16
		/*
		Bounds: {{15.590910911560059, 19.5}, {2.9999990463256836, 3}}
		Control point bounds: {{15.590910911560059, 19.5}, {2.9999990463256836, 3}}
		18.590910 21.000000 moveto
		18.590910 21.000000 lineto
		18.590910 21.828426 17.919336 22.500000 17.090910 22.500000 curveto
		16.262484 22.500000 15.590911 21.828426 15.590911 21.000000 curveto
		15.590911 21.000000 lineto
		15.590911 21.000000 lineto
		15.590911 20.171574 16.262484 19.500000 17.090910 19.500000 curveto
		17.919336 19.500000 18.590910 20.171574 18.590910 21.000000 curveto
		18.590910 21.000000 lineto
		closepath
		18.590910 21.000000 moveto
		*/
		let bezierPath15 = NSBezierPath()
		bezierPath15.move(to: NSMakePoint(18.590910, 21.000000))
		bezierPath15.line(to: NSMakePoint(18.590910, 21.000000))
		bezierPath15.curve(to: NSMakePoint(18.590910, 21.828426), controlPoint1: NSMakePoint(17.919336, 22.500000), controlPoint2: NSMakePoint(17.090910, 22.500000))
		bezierPath15.curve(to: NSMakePoint(16.262484, 22.500000), controlPoint1: NSMakePoint(15.590911, 21.828426), controlPoint2: NSMakePoint(15.590911, 21.000000))
		bezierPath15.line(to: NSMakePoint(15.590911, 21.000000))
		bezierPath15.line(to: NSMakePoint(15.590911, 21.000000))
		bezierPath15.curve(to: NSMakePoint(15.590911, 20.1715747), controlPoint1: NSMakePoint(16.262484, 19.500000), controlPoint2: NSMakePoint(17.090910, 19.500000))
		bezierPath15.curve(to: NSMakePoint(17.919336, 19.500000), controlPoint1: NSMakePoint(18.590910, 20.171574), controlPoint2: NSMakePoint(18.590910, 21.000000))
		bezierPath15.line(to: NSMakePoint(18.590910, 21.000000))
		bezierPath15.close()
		bezierPath15.move(to: NSMakePoint(18.590910, 21.000000))
		paths.append(bezierPath15)
		
		// 17
		/*
		Bounds: {{12.478299140930176, 21.263595581054688}, {5.9959535598754883, 4.8282829296589576}}
		Control point bounds: {{12.478299140930176, 21.263595581054688}, {5.9959535598754883, 5.2830562591552734}}
		18.474253 22.083590 moveto
		18.474253 22.083590 lineto
		17.881054 24.806688 15.208557 26.546652 12.478299 25.987333 curveto
		12.478300 25.987331 lineto
		12.478301 25.987333 lineto
		14.211855 25.127237 15.191052 23.245596 14.900759 21.332298 curveto
		15.353578 21.263596 lineto
		15.353578 21.263596 lineto
		15.499158 22.223097 16.395004 22.882912 17.354506 22.737331 curveto
		17.797445 22.670126 18.197989 22.436277 18.474253 22.083590 curveto
		18.474253 22.083590 lineto
		closepath
		18.474253 22.083590 moveto
		*/
		let bezierPath16 = NSBezierPath()
		bezierPath16.move(to: NSMakePoint(18.474253, 22.083590))
		bezierPath16.line(to: NSMakePoint(18.474253, 22.083590))
		bezierPath16.curve(to: NSMakePoint(17.881054, 24.806688), controlPoint1: NSMakePoint(15.208557, 26.546652), controlPoint2: NSMakePoint(12.478299, 25.987333))
		bezierPath16.line(to: NSMakePoint(12.478300, 25.987331))
		bezierPath16.line(to: NSMakePoint(12.478301, 25.987333))
		bezierPath16.curve(to: NSMakePoint(14.211855, 25.12723), controlPoint1: NSMakePoint(15.191052, 23.245596), controlPoint2: NSMakePoint(17.354506, 22.737331))
		bezierPath16.line(to: NSMakePoint(15.353578, 21.263596))
		bezierPath16.line(to: NSMakePoint(15.353578, 21.263596))
		bezierPath16.curve(to: NSMakePoint(15.499158, 22.223097), controlPoint1: NSMakePoint(16.395004, 22.882912), controlPoint2: NSMakePoint(17.354506, 22.737331))
		bezierPath16.curve(to: NSMakePoint(17.797445, 22.670126), controlPoint1: NSMakePoint(18.197989, 22.436277), controlPoint2: NSMakePoint(18.474253, 22.083590))
		bezierPath16.line(to: NSMakePoint(18.474253, 22.083590))
		bezierPath16.close()
		bezierPath16.move(to: NSMakePoint(18.474253, 22.083590))
		paths.append(bezierPath16)
		
		return paths
	}
	
	override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
		return true
	}
	
	
	//MARK: - Font support
	
	func loadSegmentPaths(file: String) -> DisplaySegmentPaths {
		var paths: DisplaySegmentPaths = DisplaySegmentPaths()
		let path = Bundle.main.path(forResource: file, ofType: "geom")
		var data: NSData?
		do {
			data = try NSData(contentsOfFile: path!, options: .mappedIfSafe)
		} catch _ {
			data = nil
		}
		let unarchiver = NSKeyedUnarchiver(forReadingWith: data! as Data)
		let dict = unarchiver.decodeObject(forKey: "bezierPaths") as! NSDictionary
		unarchiver.finishDecoding()
		for idx in 0..<numDisplaySegments {
			let key = String(idx)
			let path = dict[key]! as! NSBezierPath
			paths.append(path)
		}
		
		return paths
	}
	
	func calculateAnnunciatorPositions(font: NSFont, inRect bounds: NSRect) -> [NSPoint] {
		// Distribute the annunciators evenly across the width of the display based on the sizes of their strings.
		var positions: [NSPoint] = [NSPoint](repeating: NSMakePoint(0.0, 0.0), count: numAnnunciators)
		var annunciatorWidths: [CGFloat] = [CGFloat](repeating: 0.0, count: numAnnunciators)
		var spaceWidth: CGFloat = 0.0
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		var d: CGFloat = 0.0
		var h: CGFloat = 0.0
		var totalWidth: CGFloat = 0.0
		
		let attrs = [
			NSAttributedString.Key.font: annunciatorFont!
		]
		for idx in 0..<numAnnunciators {
			let nsString: NSString = annunciatorStrings[idx] as NSString
			let width = nsString.size(withAttributes: attrs).width
			annunciatorWidths[idx] = width
			totalWidth += width
		}
		spaceWidth = (bounds.size.width - totalWidth) / CGFloat(numAnnunciators - 1)
		d -= font.descender
		
		h = NSLayoutManager().defaultLineHeight(for: font)
		y = bounds.size.height - annunciatorBottomMargin - (h - d) / annunciatorFontScale
		
		for idx in 0..<numAnnunciators {
			positions[idx] = NSMakePoint(x, y)
			x += annunciatorWidths[idx] + spaceWidth
		}
		
		return positions
	}
}
