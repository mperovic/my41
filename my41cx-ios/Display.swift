//
//  Display.swift
//  my41
//
//  Created by Miroslav Perovic on 1/10/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

typealias DisplayFont = [DisplaySegmentMap]
typealias DisplaySegmentPaths = [UIBezierPath]

class Display: UIView, Peripheral {
	var calculator: Calculator?

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
	var annunciatorPositions: [CGPoint] = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: 12)

	private var _contrast = Digit()
	var contrast: Digit {
		set {
			_contrast = newValue & 0xf
			
			scheduleUpdate()
		}
		
		get {
			return _contrast
		}
	}
	
	override func awakeFromNib() {
		backgroundColor = .clear
		calculator?.display = self
		displayFont = loadFont("hpfont")
		segmentPaths = DisplaySegmentPaths()
		on = true
		updateCountdown = 2
		bus.installPeripheral(self, inSlot: 0xFD)
		bus.display = self
		
		for idx in 0..<numDisplayCells {
			registers.A[idx] = 0xA
			registers.B[idx] = 0x3
			registers.C[idx] = 0x2
			registers.E = 0xfff
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
		do {
			let filename: String = Bundle.main.path(forResource: CTULookupRsrcName, ofType: CTULookupRsrcType)!
			let CTULookup = try NSMutableString(contentsOfFile: filename, encoding: String.Encoding.unicode.rawValue) as String
			CTULookupLength = CTULookup.count
		} catch _ {
			
		}
	}

	override func draw(_ rect: CGRect) {
		if self.segmentPaths.count == 0 {
			self.annunciatorFont = UIFont(
				name: "Menlo",
				size: annunciatorFontScale * annunciatorFontSize
			)
			
			segmentPaths = bezierPaths()
			annunciatorPositions = calculateAnnunciatorPositions(annunciatorFont!, inRect: bounds)
		}
		if on {
			if true {
				let context = UIGraphicsGetCurrentContext()
				context?.saveGState()
				for idx in 0..<numDisplayCells {
					let segmentsOn = segmentsForCell(idx)
					for seg in 0..<numDisplaySegments {
						if (segmentsOn & (1 << UInt32(seg))) != 0 {
							let path: UIBezierPath = segmentPaths[seg]
							context?.addPath(path.cgPath)
						}
					}
					context?.translateBy(x: cellWidth(), y: 0.0)
				}
				context?.drawPath(using: CGPathDrawingMode.fill)
				context?.restoreGState()
			}

			let attrs = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font): annunciatorFont!
			]
			calculator?.prgmMode = false
			calculator?.alphaMode = false
			for idx in 0..<numAnnunciators {
				if annunciatorOn(idx) {
					if idx == 10 {
						calculator?.prgmMode = true
					}
					if idx == 11 {
						calculator?.alphaMode = true
					}
					
					let point = annunciatorPositions[idx]
					let context = UIGraphicsGetCurrentContext()
					context?.saveGState()
					context?.scaleBy(x: 1.0 / annunciatorFontScale,
						y: 1.0 / annunciatorFontScale
					)
					context?.translateBy(x: point.x, y: point.y)
					let nsString = annunciatorStrings[idx] as NSString
					nsString.draw(
						at: CGPoint(x: 0.0, y: 0.0),
						withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)
					)
					context?.restoreGState()
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

		let bezierPath0 = UIBezierPath()
		bezierPath0.move(to: CGPoint(x: 4.617837 * xRatio, y: 2.000000 * yRatio))
		bezierPath0.addLine(to: CGPoint(x: 2.375577 * xRatio, y: 0.000000 * yRatio))
		bezierPath0.addLine(to: CGPoint(x: 15.073103 * xRatio, y: 0.000000 * yRatio))
		bezierPath0.addLine(to: CGPoint(x: 12.304828 * xRatio, y: 2.000000 * yRatio))
		bezierPath0.addLine(to: CGPoint(x: 4.617837 * xRatio, y: 2.000000 * yRatio))
		bezierPath0.close()
		bezierPath0.move(to: CGPoint(x: 4.617837 * xRatio, y: 2.000000 * yRatio))
		paths.append(bezierPath0)
		
		let bezierPath1 = UIBezierPath()
		bezierPath1.move(to: CGPoint(x: 1.026980 * xRatio, y: 10.703221 * yRatio))
		bezierPath1.addLine(to: CGPoint(x: 1.935450 * xRatio, y: 0.710054 * yRatio))
		bezierPath1.addLine(to: CGPoint(x: 3.443619 * xRatio, y: 6.210914 * yRatio))
		bezierPath1.addLine(to: CGPoint(x: 3.136238 * xRatio, y: 9.592111 * yRatio))
		bezierPath1.addLine(to: CGPoint(x: 1.026980 * xRatio, y: 10.703221 * yRatio))
		bezierPath1.close()
		bezierPath1.move(to: CGPoint(x: 1.026980 * xRatio, y: 10.703221 * yRatio))
		paths.append(bezierPath1)
		
		let bezierPath2 = UIBezierPath()
		bezierPath2.move(to: CGPoint(x: 3.931293 * xRatio, y: 6.098653 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 2.464718 * xRatio, y: 0.749508 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 4.320368 * xRatio, y: 2.404667 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 6.413752 * xRatio, y: 6.591435 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 7.149230 * xRatio, y: 10.489320 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 5.669303 * xRatio, y: 9.574674 * yRatio))
		bezierPath2.addLine(to: CGPoint(x: 3.931293 * xRatio, y: 6.098653 * yRatio))
		bezierPath2.close()
		bezierPath2.move(to: CGPoint(x: 3.931293 * xRatio, y: 6.098653 * yRatio))
		paths.append(bezierPath2)
		
		let bezierPath3 = UIBezierPath()
		bezierPath3.move(to: CGPoint(x: 6.905082 * xRatio, y: 6.498730 * yRatio))
		bezierPath3.addLine(to: CGPoint(x: 7.291330 * xRatio, y: 2.250000 * yRatio))
		bezierPath3.addLine(to: CGPoint(x: 9.299579 * xRatio, y: 2.250000 * yRatio))
		bezierPath3.addLine(to: CGPoint(x: 8.884876 * xRatio, y: 6.811726 * yRatio))
		bezierPath3.addLine(to: CGPoint(x: 7.585231 * xRatio, y: 10.103380 * yRatio))
		bezierPath3.addLine(to: CGPoint(x: 6.905082 * xRatio, y: 6.498730 * yRatio))
		bezierPath3.close()
		bezierPath3.move(to: CGPoint(x: 6.905082 * xRatio, y: 6.498730 * yRatio))
		paths.append(bezierPath3)
		
		let bezierPath4 = UIBezierPath()
		bezierPath4.move(to: CGPoint(x: 9.352165 * xRatio, y: 6.989707 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 12.565980 * xRatio, y: 2.428165 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 14.879394 * xRatio, y: 0.756790 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 12.461739 * xRatio, y: 6.048622 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 9.993521 * xRatio, y: 9.551898 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 7.963932 * xRatio, y: 10.505735 * yRatio))
		bezierPath4.addLine(to: CGPoint(x: 9.352165 * xRatio, y: 6.989707 * yRatio))
		bezierPath4.close()
		bezierPath4.move(to: CGPoint(x: 9.352165 * xRatio, y: 6.989707 * yRatio))
		paths.append(bezierPath4)
		
		let bezierPath5 = UIBezierPath()
		bezierPath5.move(to: CGPoint(x: 14.524980 * xRatio, y: 10.725222 * yRatio))
		bezierPath5.addLine(to: CGPoint(x: 12.617742 * xRatio, y: 9.614111 * yRatio))
		bezierPath5.addLine(to: CGPoint(x: 12.924595 * xRatio, y: 6.238729 * yRatio))
		bezierPath5.addLine(to: CGPoint(x: 15.431723 * xRatio, y: 0.751059 * yRatio))
		bezierPath5.addLine(to: CGPoint(x: 14.524980 * xRatio, y: 10.725222 * yRatio))
		bezierPath5.close()
		bezierPath5.move(to: CGPoint(x: 14.524980 * xRatio, y: 10.725222 * yRatio))
		paths.append(bezierPath5)
		
		let bezierPath6 = UIBezierPath()
		bezierPath6.move(to: CGPoint(x: 3.213154 * xRatio, y: 12.000000 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 1.515522 * xRatio, y: 11.011001 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 3.434736 * xRatio, y: 10.000000 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 5.406438 * xRatio, y: 10.000000 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 6.997042 * xRatio, y: 10.983047 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 5.072827 * xRatio, y: 12.000000 * yRatio))
		bezierPath6.addLine(to: CGPoint(x: 3.213154 * xRatio, y: 12.000000 * yRatio))
		bezierPath6.close()
		bezierPath6.move(to: CGPoint(x: 3.213154 * xRatio, y: 12.000000 * yRatio))
		paths.append(bezierPath6)
		
		let bezierPath7 = UIBezierPath()
		bezierPath7.move(to: CGPoint(x: 9.674292 * xRatio, y: 12.000000 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 8.033062 * xRatio, y: 11.025712 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 10.215584 * xRatio, y: 10.000000 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 12.286846 * xRatio, y: 10.000000 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 13.984478 * xRatio, y: 10.988999 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 12.065263 * xRatio, y: 12.000000 * yRatio))
		bezierPath7.addLine(to: CGPoint(x: 9.674292 * xRatio, y: 12.000000 * yRatio))
		bezierPath7.close()
		bezierPath7.move(to: CGPoint(x: 9.674292 * xRatio, y: 12.000000 * yRatio))
		paths.append(bezierPath7)
		
		let bezierPath8 = UIBezierPath()
		bezierPath8.move(to: CGPoint(x: 0.070283 * xRatio, y: 21.226881 * yRatio))
		bezierPath8.addLine(to: CGPoint(x: 0.975020 * xRatio, y: 11.274778 * yRatio))
		bezierPath8.addLine(to: CGPoint(x: 2.882258 * xRatio, y: 12.385889 * yRatio))
		bezierPath8.addLine(to: CGPoint(x: 2.594385 * xRatio, y: 15.552494 * yRatio))
		bezierPath8.addLine(to: CGPoint(x: 0.070283 * xRatio, y: 21.226881 * yRatio))
		bezierPath8.close()
		bezierPath8.move(to: CGPoint(x: 0.070283 * xRatio, y: 21.226881 * yRatio))
		paths.append(bezierPath8)
		
		let bezierPath9 = UIBezierPath()
		bezierPath9.move(to: CGPoint(x: 3.058874 * xRatio, y: 15.738516 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 5.306457 * xRatio, y: 12.442060 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 7.047006 * xRatio, y: 11.522176 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 5.594459 * xRatio, y: 15.569930 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 2.864343 * xRatio, y: 19.574100 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 0.613314 * xRatio, y: 21.236336 * yRatio))
		bezierPath9.addLine(to: CGPoint(x: 3.058874 * xRatio, y: 15.738516 * yRatio))
		bezierPath9.close()
		bezierPath9.move(to: CGPoint(x: 3.058874 * xRatio, y: 15.738516 * yRatio))
		paths.append(bezierPath9)
		
		let bezierPath10 = UIBezierPath()
		bezierPath10.move(to: CGPoint(x: 6.065075 * xRatio, y: 15.738811 * yRatio))
		bezierPath10.addLine(to: CGPoint(x: 7.435389 * xRatio, y: 11.920212 * yRatio))
		bezierPath10.addLine(to: CGPoint(x: 8.120102 * xRatio, y: 15.224238 * yRatio))
		bezierPath10.addLine(to: CGPoint(x: 7.708670 * xRatio, y: 19.750000 * yRatio))
		bezierPath10.addLine(to: CGPoint(x: 5.700421 * xRatio, y: 19.750000 * yRatio))
		bezierPath10.addLine(to: CGPoint(x: 6.065075 * xRatio, y: 15.738811 * yRatio))
		bezierPath10.close()
		bezierPath10.move(to: CGPoint(x: 6.065075 * xRatio, y: 15.738811 * yRatio))
		paths.append(bezierPath10)
		
		let bezierPath11 = UIBezierPath()
		bezierPath11.move(to: CGPoint(x: 8.609699 * xRatio, y: 15.122776 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 7.859829 * xRatio, y: 11.504337 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 9.419060 * xRatio, y: 12.429949 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 11.534890 * xRatio, y: 16.308971 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 13.018471 * xRatio, y: 21.263432 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 11.046081 * xRatio, y: 19.589474 * yRatio))
		bezierPath11.addLine(to: CGPoint(x: 8.609699 * xRatio, y: 15.122776 * yRatio))
		bezierPath11.close()
		bezierPath11.move(to: CGPoint(x: 8.609699 * xRatio, y: 15.122776 * yRatio))
		paths.append(bezierPath11)
		
		let bezierPath12 = UIBezierPath()
		bezierPath12.move(to: CGPoint(x: 12.020228 * xRatio, y: 16.186754 * yRatio))
		bezierPath12.addLine(to: CGPoint(x: 12.363762 * xRatio, y: 12.407889 * yRatio))
		bezierPath12.addLine(to: CGPoint(x: 14.473021 * xRatio, y: 11.296779 * yRatio))
		bezierPath12.addLine(to: CGPoint(x: 13.560777 * xRatio, y: 21.331455 * yRatio))
		bezierPath12.addLine(to: CGPoint(x: 12.020228 * xRatio, y: 16.186754 * yRatio))
		bezierPath12.close()
		bezierPath12.move(to: CGPoint(x: 12.020228 * xRatio, y: 16.186754 * yRatio))
		paths.append(bezierPath12)
		
		let bezierPath13 = UIBezierPath()
		bezierPath13.move(to: CGPoint(x: 0.420855 * xRatio, y: 22.000000 * yRatio))
		bezierPath13.addLine(to: CGPoint(x: 3.129292 * xRatio, y: 20.000000 * yRatio))
		bezierPath13.addLine(to: CGPoint(x: 10.757083 * xRatio, y: 20.000000 * yRatio))
		bezierPath13.addLine(to: CGPoint(x: 13.113644 * xRatio, y: 22.000000 * yRatio))
		bezierPath13.addLine(to: CGPoint(x: 0.420855 * xRatio, y: 22.000000 * yRatio))
		bezierPath13.close()
		bezierPath13.move(to: CGPoint(x: 0.420855 * xRatio, y: 22.000000 * yRatio))
		paths.append(bezierPath13)
		
		let bezierPath14 = UIBezierPath()
		bezierPath14.move(to: CGPoint(x: 19.506186 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addLine(to: CGPoint(x: 19.506186 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addCurve(to: CGPoint(x: 19.506186 * xRatio, y: 11.831843 * yRatio), controlPoint1: CGPoint(x: 18.831842 * xRatio, y: 12.506186 * yRatio), controlPoint2: CGPoint(x: 18.000000 * xRatio, y: 12.506186 * yRatio))
		bezierPath14.addCurve(to: CGPoint(x: 17.168158 * xRatio, y: 12.506186 * yRatio), controlPoint1: CGPoint(x: 16.493814 * xRatio, y: 11.831843 * yRatio), controlPoint2: CGPoint(x: 16.493814 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addLine(to: CGPoint(x: 16.493814 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addLine(to: CGPoint(x: 16.493814 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addCurve(to: CGPoint(x: 16.493814 * xRatio, y: 10.168157 * yRatio), controlPoint1: CGPoint(x: 17.168158 * xRatio, y: 9.493814 * yRatio), controlPoint2: CGPoint(x: 18.000000 * xRatio, y: 9.493814 * yRatio))
		bezierPath14.addCurve(to: CGPoint(x: 18.831842 * xRatio, y: 9.493814 * yRatio), controlPoint1: CGPoint(x: 19.506186 * xRatio, y: 10.1681573 * yRatio), controlPoint2: CGPoint(x: 19.506186 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.addLine(to: CGPoint(x: 19.506186 * xRatio, y: 11.000000 * yRatio))
		bezierPath14.close()
		bezierPath14.move(to: CGPoint(x: 19.506186 * xRatio, y: 11.000000 * yRatio))
		paths.append(bezierPath14)
		
		let bezierPath15 = UIBezierPath()
		bezierPath15.move(to: CGPoint(x: 18.590910 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addLine(to: CGPoint(x: 18.590910 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addCurve(to: CGPoint(x: 18.590910 * xRatio, y: 21.828426 * yRatio), controlPoint1: CGPoint(x: 17.919336 * xRatio, y: 22.500000 * yRatio), controlPoint2: CGPoint(x: 17.090910 * xRatio, y: 22.500000 * yRatio))
		bezierPath15.addCurve(to: CGPoint(x: 16.262484 * xRatio, y: 22.500000 * yRatio), controlPoint1: CGPoint(x: 15.590911, y: 21.828426 * yRatio), controlPoint2: CGPoint(x: 15.590911 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addLine(to: CGPoint(x: 15.590911 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addLine(to: CGPoint(x: 15.590911 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addCurve(to: CGPoint(x: 15.590911 * xRatio, y: 20.1715747 * yRatio), controlPoint1: CGPoint(x: 16.262484 * xRatio, y: 19.500000 * yRatio), controlPoint2: CGPoint(x: 17.090910 * xRatio, y: 19.500000 * yRatio))
		bezierPath15.addCurve(to: CGPoint(x: 17.919336 * xRatio, y: 19.500000 * yRatio), controlPoint1: CGPoint(x: 18.590910 * xRatio, y: 20.171574 * yRatio), controlPoint2: CGPoint(x: 18.590910 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.addLine(to: CGPoint(x: 18.590910 * xRatio, y: 21.000000 * yRatio))
		bezierPath15.close()
		bezierPath15.move(to: CGPoint(x: 18.590910 * xRatio, y: 21.000000 * yRatio))
		paths.append(bezierPath15)
		
		let bezierPath16 = UIBezierPath()
		bezierPath16.move(to: CGPoint(x: 18.474253 * xRatio, y: 22.083590 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 18.474253 * xRatio, y: 22.083590 * yRatio))
		bezierPath16.addCurve(to: CGPoint(x: 17.881054 * xRatio, y: 24.806688), controlPoint1: CGPoint(x: 15.208557 * xRatio, y: 26.546652 * yRatio), controlPoint2: CGPoint(x: 12.478299 * xRatio, y: 25.987333 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 12.478300 * xRatio, y: 25.987331 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 12.478301 * xRatio, y: 25.987333 * yRatio))
		bezierPath16.addCurve(to: CGPoint(x: 14.211855 * xRatio, y: 25.12723), controlPoint1: CGPoint(x: 15.191052 * xRatio, y: 23.245596 * yRatio), controlPoint2: CGPoint(x: 17.354506 * xRatio, y: 22.737331 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 15.353578 * xRatio, y: 21.263596 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 15.353578 * xRatio, y: 21.263596 * yRatio))
		bezierPath16.addCurve(to: CGPoint(x: 15.499158 * xRatio, y: 22.223097), controlPoint1: CGPoint(x: 16.395004 * xRatio, y: 22.882912 * yRatio), controlPoint2: CGPoint(x: 17.354506 * xRatio, y: 22.737331 * yRatio))
		bezierPath16.addCurve(to: CGPoint(x: 17.797445 * xRatio, y: 22.670126), controlPoint1: CGPoint(x: 18.197989 * xRatio, y: 22.436277 * yRatio), controlPoint2: CGPoint(x: 18.474253 * xRatio, y: 22.083590 * yRatio))
		bezierPath16.addLine(to: CGPoint(x: 18.474253 * xRatio, y: 22.083590 * yRatio))
		bezierPath16.close()
		bezierPath16.move(to: CGPoint(x: 18.474253 * xRatio, y: 22.083590 * yRatio))
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
	
	func calculateAnnunciatorPositions(_ font: UIFont, inRect bounds: CGRect) -> [CGPoint] {
		// Distribute the annunciators evenly across the width of the display based on the sizes of their strings.
//		let xRatio = self.bounds.size.width / 240.0
//		let yRatio = self.bounds.size.height / 38.0

		var positions: [CGPoint] = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: numAnnunciators)
		var annunciatorWidths: [CGFloat] = [CGFloat](repeating: 0.0, count: numAnnunciators)
		var spaceWidth: CGFloat = 0.0
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		var d: CGFloat = 0.0
		var h: CGFloat = 0.0
		var totalWidth: CGFloat = 0.0
		let attrs = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font): annunciatorFont!
		]
		for idx in 0..<numAnnunciators {
			let nsString: NSString = annunciatorStrings[idx] as NSString
			let width = nsString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)).width
			annunciatorWidths[idx] = width
			totalWidth += width
		}
		spaceWidth = (bounds.size.width - totalWidth) / CGFloat(numAnnunciators - 1)
		d -= font.descender

		h = font.lineHeight
		y = bounds.size.height * annunciatorFontScale - annunciatorBottomMargin - (h - d)
		
		for idx in 0..<numAnnunciators {
			positions[idx] = CGPoint(x: x, y: y)
			x += annunciatorWidths[idx] + spaceWidth
		}
		
		return positions
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
