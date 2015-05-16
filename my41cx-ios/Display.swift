//
//  Display.swift
//  my41
//
//  Created by Miroslav Perovic on 1/10/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import UIKit

typealias DisplayFont = [DisplaySegmentMap]
typealias DisplaySegmentPaths = [UIBezierPath]

class Display: UIView, Peripheral {
	let numDisplayCells = 12
	let numAnnunciators = 12
	let numDisplaySegments = 17
	let numFontChars = 128

	var updateCountdown: Int = 0
	var on: Bool = true
	var registers = DisplayRegisters()
	var displayFont = DisplayFont()
	var segmentPaths = DisplaySegmentPaths()
	var annunciatorFont: UIFont?
	var annunciatorFontScale: CGFloat = 1.0
	let annunciatorFontSize: CGFloat = 10.0
	let annunciatorBottomMargin: CGFloat = 0.0
	var annunciatorPositions: [CGPoint] = [CGPoint](count: 12, repeatedValue: CGPointMake(0.0, 0.0))
	
	var contrast: Digit {
		set {
			self.contrast = newValue & 0xf
			
			scheduleUpdate()
		}
		
		get {
			return self.contrast
		}
	}
	
	override func awakeFromNib() {
		self.backgroundColor = UIColor.clearColor()
		calculatorController.display = self
		self.displayFont = self.loadFont("hpfont")
		self.segmentPaths = DisplaySegmentPaths()
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
		let filename: String = NSBundle.mainBundle().pathForResource(CTULookupRsrcName, ofType: CTULookupRsrcType)!
		let mString: NSMutableString = NSMutableString(contentsOfFile: filename, encoding: NSUnicodeStringEncoding, error: nil)!
		CTULookup = String(mString)
		CTULookupLength = count(CTULookup!)
	}

	override func drawRect(rect: CGRect) {
		if count(self.segmentPaths) == 0 {
			self.annunciatorFont = UIFont(
				name: "Menlo",
				size:self.annunciatorFontScale * self.annunciatorFontSize
			)
			
			self.segmentPaths = bezierPaths()
			self.annunciatorPositions = self.calculateAnnunciatorPositions(self.annunciatorFont!, inRect: self.bounds)
		}
		if on {
			if true {
				let context = UIGraphicsGetCurrentContext()
				CGContextSaveGState(context)
				for idx in 0..<numDisplayCells {
					let segmentsOn = segmentsForCell(idx)
					for seg in 0..<numDisplaySegments {
						if (segmentsOn & (1 << UInt32(seg))) != 0 {
							let path: UIBezierPath = segmentPaths[seg]
							CGContextAddPath(context, path.CGPath)
						}
					}
					CGContextTranslateCTM(context, cellWidth(), 0.0)
				}
				CGContextDrawPath(context, kCGPathFill)
				CGContextRestoreGState(context)
			}

			let attrs: NSDictionary = NSDictionary(
				object: annunciatorFont!,
				forKey: NSFontAttributeName
			)
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
					
					let point = annunciatorPositions[idx]
					let context = UIGraphicsGetCurrentContext()
					CGContextSaveGState(context)
					CGContextScaleCTM(
						context,
						1.0 / annunciatorFontScale,
						1.0 / annunciatorFontScale
					)
					CGContextTranslateCTM(context, point.x, point.y)
					let nsString = annunciatorStrings[idx] as NSString
					nsString.drawAtPoint(
						CGPointMake(0.0, 0.0),
						withAttributes: attrs as [NSObject : AnyObject]
					)
					CGContextRestoreGState(context)
				}
			}
		}
	}
	
	func bezierPaths() -> DisplaySegmentPaths
	{
//		let xRatio = self.bounds.size.width / 240.0
//		let yRatio = self.bounds.size.height / 38.0
		let xRatio: CGFloat = 1.0
		let yRatio: CGFloat = 1.0
		var paths: DisplaySegmentPaths = DisplaySegmentPaths()

		var bezierPath0 = UIBezierPath()
		bezierPath0.moveToPoint(CGPointMake(4.617837 * xRatio, 2.000000 * yRatio))
		bezierPath0.addLineToPoint(CGPointMake(2.375577 * xRatio, 0.000000 * yRatio))
		bezierPath0.addLineToPoint(CGPointMake(15.073103 * xRatio, 0.000000 * yRatio))
		bezierPath0.addLineToPoint(CGPointMake(12.304828 * xRatio, 2.000000 * yRatio))
		bezierPath0.addLineToPoint(CGPointMake(4.617837 * xRatio, 2.000000 * yRatio))
		bezierPath0.closePath()
		bezierPath0.moveToPoint(CGPointMake(4.617837 * xRatio, 2.000000 * yRatio))
		paths.append(bezierPath0)
		
		var bezierPath1 = UIBezierPath()
		bezierPath1.moveToPoint(CGPointMake(1.026980 * xRatio, 10.703221 * yRatio))
		bezierPath1.addLineToPoint(CGPointMake(1.935450 * xRatio, 0.710054 * yRatio))
		bezierPath1.addLineToPoint(CGPointMake(3.443619 * xRatio, 6.210914 * yRatio))
		bezierPath1.addLineToPoint(CGPointMake(3.136238 * xRatio, 9.592111 * yRatio))
		bezierPath1.addLineToPoint(CGPointMake(1.026980 * xRatio, 10.703221 * yRatio))
		bezierPath1.closePath()
		bezierPath1.moveToPoint(CGPointMake(1.026980 * xRatio, 10.703221 * yRatio))
		paths.append(bezierPath1)
		
		var bezierPath2 = UIBezierPath()
		bezierPath2.moveToPoint(CGPointMake(3.931293 * xRatio, 6.098653 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(2.464718 * xRatio, 0.749508 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(4.320368 * xRatio, 2.404667 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(6.413752 * xRatio, 6.591435 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(7.149230 * xRatio, 10.489320 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(5.669303 * xRatio, 9.574674 * yRatio))
		bezierPath2.addLineToPoint(CGPointMake(3.931293 * xRatio, 6.098653 * yRatio))
		bezierPath2.closePath()
		bezierPath2.moveToPoint(CGPointMake(3.931293 * xRatio, 6.098653 * yRatio))
		paths.append(bezierPath2)
		
		var bezierPath3 = UIBezierPath()
		bezierPath3.moveToPoint(CGPointMake(6.905082 * xRatio, 6.498730 * yRatio))
		bezierPath3.addLineToPoint(CGPointMake(7.291330 * xRatio, 2.250000 * yRatio))
		bezierPath3.addLineToPoint(CGPointMake(9.299579 * xRatio, 2.250000 * yRatio))
		bezierPath3.addLineToPoint(CGPointMake(8.884876 * xRatio, 6.811726 * yRatio))
		bezierPath3.addLineToPoint(CGPointMake(7.585231 * xRatio, 10.103380 * yRatio))
		bezierPath3.addLineToPoint(CGPointMake(6.905082 * xRatio, 6.498730 * yRatio))
		bezierPath3.closePath()
		bezierPath3.moveToPoint(CGPointMake(6.905082 * xRatio, 6.498730 * yRatio))
		paths.append(bezierPath3)
		
		var bezierPath4 = UIBezierPath()
		bezierPath4.moveToPoint(CGPointMake(9.352165 * xRatio, 6.989707 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(12.565980 * xRatio, 2.428165 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(14.879394 * xRatio, 0.756790 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(12.461739 * xRatio, 6.048622 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(9.993521 * xRatio, 9.551898 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(7.963932 * xRatio, 10.505735 * yRatio))
		bezierPath4.addLineToPoint(CGPointMake(9.352165 * xRatio, 6.989707 * yRatio))
		bezierPath4.closePath()
		bezierPath4.moveToPoint(CGPointMake(9.352165 * xRatio, 6.989707 * yRatio))
		paths.append(bezierPath4)
		
		var bezierPath5 = UIBezierPath()
		bezierPath5.moveToPoint(CGPointMake(14.524980 * xRatio, 10.725222 * yRatio))
		bezierPath5.addLineToPoint(CGPointMake(12.617742 * xRatio, 9.614111 * yRatio))
		bezierPath5.addLineToPoint(CGPointMake(12.924595 * xRatio, 6.238729 * yRatio))
		bezierPath5.addLineToPoint(CGPointMake(15.431723 * xRatio, 0.751059 * yRatio))
		bezierPath5.addLineToPoint(CGPointMake(14.524980 * xRatio, 10.725222 * yRatio))
		bezierPath5.closePath()
		bezierPath5.moveToPoint(CGPointMake(14.524980 * xRatio, 10.725222 * yRatio))
		paths.append(bezierPath5)
		
		var bezierPath6 = UIBezierPath()
		bezierPath6.moveToPoint(CGPointMake(3.213154 * xRatio, 12.000000 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(1.515522 * xRatio, 11.011001 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(3.434736 * xRatio, 10.000000 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(5.406438 * xRatio, 10.000000 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(6.997042 * xRatio, 10.983047 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(5.072827 * xRatio, 12.000000 * yRatio))
		bezierPath6.addLineToPoint(CGPointMake(3.213154 * xRatio, 12.000000 * yRatio))
		bezierPath6.closePath()
		bezierPath6.moveToPoint(CGPointMake(3.213154 * xRatio, 12.000000 * yRatio))
		paths.append(bezierPath6)
		
		var bezierPath7 = UIBezierPath()
		bezierPath7.moveToPoint(CGPointMake(9.674292 * xRatio, 12.000000 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(8.033062 * xRatio, 11.025712 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(10.215584 * xRatio, 10.000000 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(12.286846 * xRatio, 10.000000 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(13.984478 * xRatio, 10.988999 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(12.065263 * xRatio, 12.000000 * yRatio))
		bezierPath7.addLineToPoint(CGPointMake(9.674292 * xRatio, 12.000000 * yRatio))
		bezierPath7.closePath()
		bezierPath7.moveToPoint(CGPointMake(9.674292 * xRatio, 12.000000 * yRatio))
		paths.append(bezierPath7)
		
		var bezierPath8 = UIBezierPath()
		bezierPath8.moveToPoint(CGPointMake(0.070283 * xRatio, 21.226881 * yRatio))
		bezierPath8.addLineToPoint(CGPointMake(0.975020 * xRatio, 11.274778 * yRatio))
		bezierPath8.addLineToPoint(CGPointMake(2.882258 * xRatio, 12.385889 * yRatio))
		bezierPath8.addLineToPoint(CGPointMake(2.594385 * xRatio, 15.552494 * yRatio))
		bezierPath8.addLineToPoint(CGPointMake(0.070283 * xRatio, 21.226881 * yRatio))
		bezierPath8.closePath()
		bezierPath8.moveToPoint(CGPointMake(0.070283 * xRatio, 21.226881 * yRatio))
		paths.append(bezierPath8)
		
		var bezierPath9 = UIBezierPath()
		bezierPath9.moveToPoint(CGPointMake(3.058874 * xRatio, 15.738516 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(5.306457 * xRatio, 12.442060 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(7.047006 * xRatio, 11.522176 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(5.594459 * xRatio, 15.569930 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(2.864343 * xRatio, 19.574100 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(0.613314 * xRatio, 21.236336 * yRatio))
		bezierPath9.addLineToPoint(CGPointMake(3.058874 * xRatio, 15.738516 * yRatio))
		bezierPath9.closePath()
		bezierPath9.moveToPoint(CGPointMake(3.058874 * xRatio, 15.738516 * yRatio))
		paths.append(bezierPath9)
		
		var bezierPath10 = UIBezierPath()
		bezierPath10.moveToPoint(CGPointMake(6.065075 * xRatio, 15.738811 * yRatio))
		bezierPath10.addLineToPoint(CGPointMake(7.435389 * xRatio, 11.920212 * yRatio))
		bezierPath10.addLineToPoint(CGPointMake(8.120102 * xRatio, 15.224238 * yRatio))
		bezierPath10.addLineToPoint(CGPointMake(7.708670 * xRatio, 19.750000 * yRatio))
		bezierPath10.addLineToPoint(CGPointMake(5.700421 * xRatio, 19.750000 * yRatio))
		bezierPath10.addLineToPoint(CGPointMake(6.065075 * xRatio, 15.738811 * yRatio))
		bezierPath10.closePath()
		bezierPath10.moveToPoint(CGPointMake(6.065075 * xRatio, 15.738811 * yRatio))
		paths.append(bezierPath10)
		
		var bezierPath11 = UIBezierPath()
		bezierPath11.moveToPoint(CGPointMake(8.609699 * xRatio, 15.122776 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(7.859829 * xRatio, 11.504337 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(9.419060 * xRatio, 12.429949 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(11.534890 * xRatio, 16.308971 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(13.018471 * xRatio, 21.263432 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(11.046081 * xRatio, 19.589474 * yRatio))
		bezierPath11.addLineToPoint(CGPointMake(8.609699 * xRatio, 15.122776 * yRatio))
		bezierPath11.closePath()
		bezierPath11.moveToPoint(CGPointMake(8.609699 * xRatio, 15.122776 * yRatio))
		paths.append(bezierPath11)
		
		var bezierPath12 = UIBezierPath()
		bezierPath12.moveToPoint(CGPointMake(12.020228 * xRatio, 16.186754 * yRatio))
		bezierPath12.addLineToPoint(CGPointMake(12.363762 * xRatio, 12.407889 * yRatio))
		bezierPath12.addLineToPoint(CGPointMake(14.473021 * xRatio, 11.296779 * yRatio))
		bezierPath12.addLineToPoint(CGPointMake(13.560777 * xRatio, 21.331455 * yRatio))
		bezierPath12.addLineToPoint(CGPointMake(12.020228 * xRatio, 16.186754 * yRatio))
		bezierPath12.closePath()
		bezierPath12.moveToPoint(CGPointMake(12.020228 * xRatio, 16.186754 * yRatio))
		paths.append(bezierPath12)
		
		var bezierPath13 = UIBezierPath()
		bezierPath13.moveToPoint(CGPointMake(0.420855 * xRatio, 22.000000 * yRatio))
		bezierPath13.addLineToPoint(CGPointMake(3.129292 * xRatio, 20.000000 * yRatio))
		bezierPath13.addLineToPoint(CGPointMake(10.757083 * xRatio, 20.000000 * yRatio))
		bezierPath13.addLineToPoint(CGPointMake(13.113644 * xRatio, 22.000000 * yRatio))
		bezierPath13.addLineToPoint(CGPointMake(0.420855 * xRatio, 22.000000 * yRatio))
		bezierPath13.closePath()
		bezierPath13.moveToPoint(CGPointMake(0.420855 * xRatio, 22.000000 * yRatio))
		paths.append(bezierPath13)
		
		var bezierPath14 = UIBezierPath()
		bezierPath14.moveToPoint(CGPointMake(19.506186 * xRatio, 11.000000 * yRatio))
		bezierPath14.addLineToPoint(CGPointMake(19.506186 * xRatio, 11.000000 * yRatio))
		bezierPath14.addCurveToPoint(CGPointMake(19.506186 * xRatio, 11.831843 * yRatio), controlPoint1: CGPointMake(18.831842 * xRatio, 12.506186 * yRatio), controlPoint2: CGPointMake(18.000000 * xRatio, 12.506186 * yRatio))
		bezierPath14.addCurveToPoint(CGPointMake(17.168158 * xRatio, 12.506186 * yRatio), controlPoint1: CGPointMake(16.493814 * xRatio, 11.831843 * yRatio), controlPoint2: CGPointMake(16.493814 * xRatio, 11.000000 * yRatio))
		bezierPath14.addLineToPoint(CGPointMake(16.493814 * xRatio, 11.000000 * yRatio))
		bezierPath14.addLineToPoint(CGPointMake(16.493814 * xRatio, 11.000000 * yRatio))
		bezierPath14.addCurveToPoint(CGPointMake(16.493814 * xRatio, 10.168157 * yRatio), controlPoint1: CGPointMake(17.168158 * xRatio, 9.493814 * yRatio), controlPoint2: CGPointMake(18.000000 * xRatio, 9.493814 * yRatio))
		bezierPath14.addCurveToPoint(CGPointMake(18.831842 * xRatio, 9.493814 * yRatio), controlPoint1: CGPointMake(19.506186 * xRatio, 10.1681573 * yRatio), controlPoint2: CGPointMake(19.506186 * xRatio, 11.000000 * yRatio))
		bezierPath14.addLineToPoint(CGPointMake(19.506186 * xRatio, 11.000000 * yRatio))
		bezierPath14.closePath()
		bezierPath14.moveToPoint(CGPointMake(19.506186 * xRatio, 11.000000 * yRatio))
		paths.append(bezierPath14)
		
		var bezierPath15 = UIBezierPath()
		bezierPath15.moveToPoint(CGPointMake(18.590910 * xRatio, 21.000000 * yRatio))
		bezierPath15.addLineToPoint(CGPointMake(18.590910 * xRatio, 21.000000 * yRatio))
		bezierPath15.addCurveToPoint(CGPointMake(18.590910 * xRatio, 21.828426 * yRatio), controlPoint1: CGPointMake(17.919336 * xRatio, 22.500000 * yRatio), controlPoint2: CGPointMake(17.090910 * xRatio, 22.500000 * yRatio))
		bezierPath15.addCurveToPoint(CGPointMake(16.262484 * xRatio, 22.500000 * yRatio), controlPoint1: CGPointMake(15.590911, 21.828426 * yRatio), controlPoint2: CGPointMake(15.590911 * xRatio, 21.000000 * yRatio))
		bezierPath15.addLineToPoint(CGPointMake(15.590911 * xRatio, 21.000000 * yRatio))
		bezierPath15.addLineToPoint(CGPointMake(15.590911 * xRatio, 21.000000 * yRatio))
		bezierPath15.addCurveToPoint(CGPointMake(15.590911 * xRatio, 20.1715747 * yRatio), controlPoint1: CGPointMake(16.262484 * xRatio, 19.500000 * yRatio), controlPoint2: CGPointMake(17.090910 * xRatio, 19.500000 * yRatio))
		bezierPath15.addCurveToPoint(CGPointMake(17.919336 * xRatio, 19.500000 * yRatio), controlPoint1: CGPointMake(18.590910 * xRatio, 20.171574 * yRatio), controlPoint2: CGPointMake(18.590910 * xRatio, 21.000000 * yRatio))
		bezierPath15.addLineToPoint(CGPointMake(18.590910 * xRatio, 21.000000 * yRatio))
		bezierPath15.closePath()
		bezierPath15.moveToPoint(CGPointMake(18.590910 * xRatio, 21.000000 * yRatio))
		paths.append(bezierPath15)
		
		var bezierPath16 = UIBezierPath()
		bezierPath16.moveToPoint(CGPointMake(18.474253 * xRatio, 22.083590 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(18.474253 * xRatio, 22.083590 * yRatio))
		bezierPath16.addCurveToPoint(CGPointMake(17.881054 * xRatio, 24.806688), controlPoint1: CGPointMake(15.208557 * xRatio, 26.546652 * yRatio), controlPoint2: CGPointMake(12.478299 * xRatio, 25.987333 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(12.478300 * xRatio, 25.987331 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(12.478301 * xRatio, 25.987333 * yRatio))
		bezierPath16.addCurveToPoint(CGPointMake(14.211855 * xRatio, 25.12723), controlPoint1: CGPointMake(15.191052 * xRatio, 23.245596 * yRatio), controlPoint2: CGPointMake(17.354506 * xRatio, 22.737331 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(15.353578 * xRatio, 21.263596 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(15.353578 * xRatio, 21.263596 * yRatio))
		bezierPath16.addCurveToPoint(CGPointMake(15.499158 * xRatio, 22.223097), controlPoint1: CGPointMake(16.395004 * xRatio, 22.882912 * yRatio), controlPoint2: CGPointMake(17.354506 * xRatio, 22.737331 * yRatio))
		bezierPath16.addCurveToPoint(CGPointMake(17.797445 * xRatio, 22.670126), controlPoint1: CGPointMake(18.197989 * xRatio, 22.436277 * yRatio), controlPoint2: CGPointMake(18.474253 * xRatio, 22.083590 * yRatio))
		bezierPath16.addLineToPoint(CGPointMake(18.474253 * xRatio, 22.083590 * yRatio))
		bezierPath16.closePath()
		bezierPath16.moveToPoint(CGPointMake(18.474253 * xRatio, 22.083590 * yRatio))
		paths.append(bezierPath16)
		
		return paths
	}
	
	
	//MARK: - Font support
/*
	func loadSegmentPaths(file: String) -> DisplaySegmentPaths {
		var paths: DisplaySegmentPaths = DisplaySegmentPaths()
		let path = NSBundle.mainBundle().pathForResource(file, ofType: "geom")
		var data = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
		var unarchiver = NSKeyedUnarchiver(forReadingWithData: data!)
		let dict = unarchiver.decodeObjectForKey("bezierPaths") as NSDictionary
		unarchiver.finishDecoding()
		for idx in 0..<numDisplaySegments {
			let key = String(idx)
			let path = dict[key]! as UIBezierPath
			paths.append(path)
		}
		
		return paths
	}
*/
	
	func saveFile()
	{
		
	}
	
	func calculateAnnunciatorPositions(font: UIFont, inRect bounds: CGRect) -> [CGPoint] {
		// Distribute the annunciators evenly across the width of the display based on the sizes of their strings.
		let xRatio = self.bounds.size.width / 240.0
		let yRatio = self.bounds.size.height / 38.0

		var positions: [CGPoint] = [CGPoint](count: numAnnunciators, repeatedValue: CGPointMake(0.0, 0.0))
		var annunciatorWidths: [CGFloat] = [CGFloat](count: numAnnunciators, repeatedValue: 0.0)
		var spaceWidth: CGFloat = 0.0
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		var d: CGFloat = 0.0
		var h: CGFloat = 0.0
		var totalWidth: CGFloat = 0.0
		let attrs: NSDictionary = NSDictionary(
			object: annunciatorFont!,
			forKey: NSFontAttributeName
		)
		for idx in 0..<numAnnunciators {
			let nsString: NSString = annunciatorStrings[idx] as NSString
			let width = nsString.sizeWithAttributes(attrs as [NSObject : AnyObject]).width
			annunciatorWidths[idx] = width
			totalWidth += width
		}
		spaceWidth = (bounds.size.width - totalWidth) / CGFloat(numAnnunciators - 1)
		d -= font.descender

		h = font.lineHeight
		y = bounds.size.height * annunciatorFontScale - annunciatorBottomMargin - (h - d)
		
		for idx in 0..<numAnnunciators {
			positions[idx] = CGPointMake(x, y)
			x += annunciatorWidths[idx] + spaceWidth
		}
		
		return positions
	}
}