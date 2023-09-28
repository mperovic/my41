//
//  Keys.swift
//  my41
//
//  Created by Miroslav Perovic on 6.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

final class Keys: ObservableObject {
	@Published var modeKeys: [CalcKey] = [
		CalcKey(shiftText: getModeAttributedString(from: ""), upperText: getModeAttributedString(from: "ON"), keyCode: 128),
		CalcKey(shiftText: getModeAttributedString(from: ""), upperText: getModeAttributedString(from: "USER"), keyCode: 100),
		CalcKey(shiftText: getModeAttributedString(from: ""), upperText: getModeAttributedString(from: "PRGM"), keyCode: 84),
		CalcKey(shiftText: getModeAttributedString(from: ""), upperText: getModeAttributedString(from: "ALPHA"), keyCode: 68)
	]
	@Published var keys1: [CalcKey] = [
		CalcKey(shiftText: sigmaMinus, upperText: sigmaPlus, lowerText: getLowerAttributedString(from: "A"), keyCode: 0),
		CalcKey(shiftText: yx, upperText: oneX, lowerText: getLowerAttributedString(from: "B"), keyCode: 1),
		CalcKey(shiftText: xSquare, upperText: rootX, lowerText: getLowerAttributedString(from: "C"), keyCode: 2),
		CalcKey(shiftText: tenX, upperText: log,lowerText: getLowerAttributedString(from: "D"), keyCode: 3),
		CalcKey(shiftText: eX, upperText: ln, lowerText: getLowerAttributedString(from: "E"), keyCode: 4)
	]
	@Published var keys2: [CalcKey] = [
		CalcKey(shiftText: clSigma, upperText: xexy, lowerText: getLowerAttributedString(from: "F"), keyCode: 16),
		CalcKey(shiftText: percent, upperText: rArrow,lowerText: getLowerAttributedString(from: "G"), keyCode: 17),
		CalcKey(shiftText: sin1, upperText: sin, lowerText: getLowerAttributedString(from: "H"), keyCode: 18),
		CalcKey(shiftText: cos1, upperText: cos, lowerText: getLowerAttributedString(from: "I"), keyCode: 19),
		CalcKey(shiftText: tan1, upperText: tan, lowerText: getLowerAttributedString(from: "J"), keyCode: 20)
	]
	@Published var keys3: [CalcKey] = [
		CalcKey(shiftText: getModeAttributedString(from: ""), upperText: getModeAttributedString(from: ""), lowerText: nil, shiftButton: true, keyCode: 32),
		CalcKey(shiftText: asn, upperText: xeq, lowerText: getLowerAttributedString(from: "K"), keyCode: 33),
		CalcKey(shiftText: lbl, upperText: sto, lowerText: getLowerAttributedString(from: "L"), keyCode: 34),
		CalcKey(shiftText: gto, upperText: rcl, lowerText: getLowerAttributedString(from: "M"), keyCode: 35),
		CalcKey(shiftText: bst, upperText: sst, lowerText: getModeAttributedString(from: ""), keyCode: 36)
	]
	@Published var keys4: [CalcKey] = [
		CalcKey(shiftText: catalog, upperText: enter, lowerText: getLowerAttributedString(from: "N"), enter: true, keyCode: 48),
		CalcKey(shiftText: isg, upperText: chs, lowerText: getLowerAttributedString(from: "O"), keyCode: 50),
		CalcKey(shiftText: rtn, upperText: eex, lowerText: getLowerAttributedString(from: "P"), keyCode: 51),
		CalcKey(shiftText: clxa, upperText: back, lowerText: getLowerAttributedString(from: ""), keyCode: 52)
	]
	@Published var keys5: [CalcKey] = [
		CalcKey(shiftText: xeqy, upperText: minus, lowerText: getLowerAttributedString(from: "Q"), keyCode: 64),
		CalcKey(shiftText: sf, upperText: seven, lowerText: getLowerAttributedString(from: "R"), keyCode: 65),
		CalcKey(shiftText: cf, upperText: eight, lowerText: getLowerAttributedString(from: "S"), keyCode: 66),
		CalcKey(shiftText: fsQuestionMark, upperText: nine, lowerText: getLowerAttributedString(from: "T"), keyCode: 67)
	]
	@Published var keys6: [CalcKey] = [
		CalcKey(shiftText: xlessthany, upperText: plus, lowerText: getLowerAttributedString(from: "U"), keyCode: 80),
		CalcKey(shiftText: beep, upperText: four, lowerText: getLowerAttributedString(from: "V"), keyCode: 81),
		CalcKey(shiftText: ptor, upperText: five, lowerText: getLowerAttributedString(from: "W"), keyCode: 82),
		CalcKey(shiftText: rtop, upperText: six, lowerText: getLowerAttributedString(from: "X"), keyCode: 83)
	]
	@Published var keys7: [CalcKey] = [
		CalcKey(shiftText: xgreaterthany, upperText: multiply, lowerText: getLowerAttributedString(from: "Y"), keyCode: 96),
		CalcKey(shiftText: fix, upperText: one, lowerText: getLowerAttributedString(from: "Z"), keyCode: 97),
		CalcKey(shiftText: sci, upperText: two, lowerText: getLowerAttributedString(from: "="), keyCode: 98),
		CalcKey(shiftText: eng, upperText: three, lowerText: getLowerAttributedString(from: "?"), keyCode: 99)
	]
	@Published var keys8: [CalcKey] = [
		CalcKey(shiftText: xeqzero, upperText: divide, lowerText: getLowerAttributedString(from: ":"), keyCode: 112),
		CalcKey(shiftText: pi, upperText: zero, lowerText: getLowerAttributedString(from: "SPACE"), keyCode: 113),
		CalcKey(shiftText: lastX, upperText: dot, lowerText: getLowerAttributedString(from: "\u{0313}"), keyCode: 114),
		CalcKey(shiftText: view, upperText: rs, lowerText: getLowerAttributedString(from: ""), keyCode: 115)
	]

#if os(iOS)
    static private let yRatio = UIScreen.main.bounds.size.height / 800.0
#elseif os(macOS)
    static private let yRatio = NSScreen.main?.frame.size.height ?? 800 / 800
#endif

	static func getHelvetica(_ size: CGFloat) -> Font {
#if os(iOS)
		return Font(UIFont(name: "Helvetica", size: size * yRatio)!)
#elseif os(macOS)
        return Font(NSFont(name: "Helvetica", size: size * yRatio)!)
#endif
	}

	static func getTimesNewRoman(_ size: CGFloat) -> Font {
#if os(iOS)
		return Font(UIFont(name: "Times New Roman", size: size * yRatio)!)
#elseif os(macOS)
        return Font(NSFont(name: "Times New Roman", size: size * yRatio)!)
#endif
	}
	
	static func getModeAttributedString(from text: String) -> AttributedString {
		let onString = mutableAttributedStringFromString(text, color: .white, font: getHelvetica(12.0))
//		let onAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(12.0),
//		]
//		onString.addAttributes(convertToNSAttributedStringKeyDictionary(onAttributes as [String : Any]), range: NSMakeRange(0, text.count))
		
		return onString
	}
	
	static func getLowerAttributedString(from text: String) -> AttributedString {
        var lowerText = mutableAttributedStringFromString(text, color: .lowerColor, font: getHelvetica(text == "SPACE" ? 13.0 : 15.0))
		
		if text.count == 1 {
            lowerText.font = getHelvetica(11.0 * yRatio)
            lowerText.baselineOffset = 1.0
//			let lowerTextAttributes = [
//				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(11.0 * yRatio),
//				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
//			] as [String : Any]
//			lowerText.addAttributes(convertToNSAttributedStringKeyDictionary(lowerTextAttributes), range: NSMakeRange(0, text.count))
		}
		
		return lowerText
	}
	
	static var sigmaMinus: AttributedString {
		var sigmaMinusString = mutableAttributedStringFromString("Σ-", color: .shiftColor)
        if let range = sigmaMinusString.range(of: "-") {
            sigmaMinusString[range].font = getHelvetica(15.0)
            sigmaMinusString[range].baselineOffset = 1.0
        }
//		let sigmaMinusAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(15.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
//		] as [String : Any]
//		sigmaMinusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaMinusAttributes), range: NSMakeRange(1, 1))
		
		return sigmaMinusString
	}
	
	static var sigmaPlus: AttributedString {
		var sigmaPlusString = mutableAttributedStringFromString("Σ+", color: .white)
        if let range = sigmaPlusString.range(of: "+") {
            sigmaPlusString[range].baselineOffset = 1.0
        }
//		let sigmaPlusAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
//		]
//		sigmaPlusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaPlusAttributes), range: NSMakeRange(1, 1))

		return sigmaPlusString
	}
	
	static var yx: AttributedString {
		var yxString = mutableAttributedStringFromString("yx", color: .shiftColor)
        if let range = yxString.range(of: "x") {
            yxString[range].font = getTimesNewRoman(12.0)
            yxString[range].baselineOffset = 4.0
        }
//		let yxAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		yxString.addAttributes(convertToNSAttributedStringKeyDictionary(yxAttributes), range: NSMakeRange(1, 1))
		
		return yxString
	}
	
	static var oneX: AttributedString  {
		var oneXString = mutableAttributedStringFromString("1/x", color: .white)
        if let range = oneXString.range(of: "x") {
            oneXString[range].font = getTimesNewRoman(12.0)
        }
//		let oneXAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
//		]
//		oneXString.addAttributes(convertToNSAttributedStringKeyDictionary(oneXAttributes), range: NSMakeRange(2, 1))

		return oneXString
	}
	
	static var xSquare: AttributedString {
		var xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: .shiftColor)
        let range = xSquareString.range(of: "x\u{00B2}")!
        xSquareString[range].font = getTimesNewRoman(14.0)
//		let xSquareAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(14.0),
//		]
//		xSquareString.addAttributes(convertToNSAttributedStringKeyDictionary(xSquareAttributes), range: NSMakeRange(0, 2))
		
		return xSquareString
	}

	static var rootX: AttributedString {
		var rootXString = mutableAttributedStringFromString("√x", color: .white)
        let range = rootXString.range(of: "x")!
        rootXString[range].font = getTimesNewRoman(14.0)

//		let rootXAttributes2 = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
//		]
//		rootXString.addAttributes(convertToNSAttributedStringKeyDictionary(rootXAttributes2), range: NSMakeRange(1, 1))
		
		return rootXString
	}
	
	static var tenX: AttributedString {
		var tenXString = mutableAttributedStringFromString("10x", color: .shiftColor)
        let range = tenXString.range(of: "x")!
        tenXString[range].font = getTimesNewRoman(12.0)
        tenXString[range].baselineOffset = 4.0
//		let tenXAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		tenXString.addAttributes(convertToNSAttributedStringKeyDictionary(tenXAttributes), range: NSMakeRange(2, 1))
		
		return tenXString
	}
	
	static var log: AttributedString { mutableAttributedStringFromString("LOG", color: .white) }
	
	static var eX: AttributedString {
		var eXString = mutableAttributedStringFromString("ex", color: .shiftColor)
        let rangeX = eXString.range(of: "x")!
        eXString[rangeX].font = getTimesNewRoman(12.0)
        eXString[rangeX].baselineOffset = 4.0

        if let rangeE = eXString.range(of: "e") {
            eXString[rangeE].font = getHelvetica(14.0)
        }
//		let eXAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		
//		eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes), range: NSMakeRange(1, 1))
//		let eXAttributes2 = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(14.0)
//		]
//		eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes2), range: NSMakeRange(0, 1))

		return eXString
	}
	
	static var ln: AttributedString { mutableAttributedStringFromString("LN", color: .white) }
	
	static var clSigma: AttributedString { mutableAttributedStringFromString("CLΣ", color: .shiftColor) }
	
	static var xexy: AttributedString {
		var xexYString = mutableAttributedStringFromString("x≷y", color: .white)
        if let range = xexYString.range(of: "x≷y") {
            xexYString[range].font = getTimesNewRoman(16.0)
            xexYString[range].baselineOffset = 1.0
        }
//		let xexYAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(16.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
//		] as [String : Any]
//		xexYString.addAttributes(convertToNSAttributedStringKeyDictionary(xexYAttributes), range: NSMakeRange(0, 3))

		return xexYString
	}
	
	static var percent: AttributedString { mutableAttributedStringFromString("%", color: .shiftColor) }
	
	static var rArrow: AttributedString { mutableAttributedStringFromString("R↓", color: .white) }
	
	static var sin1: AttributedString {
		var sin1String = mutableAttributedStringFromString("SIN-1", color: .shiftColor)
        if let range = sin1String.range(of: "-1") {
            sin1String[range].font = getTimesNewRoman(11.0)
            sin1String[range].baselineOffset = 4.0
        }
//		let sinAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		sin1String.addAttributes(convertToNSAttributedStringKeyDictionary(sinAttributes), range: NSMakeRange(3, 2))

		return sin1String
	}
	
	static var sin: AttributedString { mutableAttributedStringFromString("SIN", color: .white) }
	
	static var cos1: AttributedString {
		var cos1String = mutableAttributedStringFromString("COS-1", color: .shiftColor)
        if let range = cos1String.range(of: "-1") {
            cos1String[range].font = getTimesNewRoman(11.0)
            cos1String[range].baselineOffset = 4.0
        }
//		let cosAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		cos1String.addAttributes(convertToNSAttributedStringKeyDictionary(cosAttributes), range: NSMakeRange(3, 2))

		return cos1String
	}
	
	static var cos: AttributedString { mutableAttributedStringFromString("COS", color: .white) }
	
	static var tan1: AttributedString {
		var tan1String = mutableAttributedStringFromString("TAN-1", color: .shiftColor)
        if let range = tan1String.range(of: "-1") {
            tan1String[range].font = getTimesNewRoman(11.0)
            tan1String[range].baselineOffset = 4.0
        }
//		let tanAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
//		] as [String : Any]
//		tan1String.addAttributes(convertToNSAttributedStringKeyDictionary(tanAttributes), range: NSMakeRange(3, 2))
		
		return tan1String
	}
	
	static var tan: AttributedString { mutableAttributedStringFromString("TAN", color: .white) }
	
	static var asn: AttributedString { mutableAttributedStringFromString("ASN", color: .shiftColor) }
	
	static var xeq: AttributedString { mutableAttributedStringFromString("XEQ", color: .white) }
	
	static var lbl: AttributedString { mutableAttributedStringFromString("LBL", color: .shiftColor) }
	
	static var sto: AttributedString { mutableAttributedStringFromString("STO", color: .white) }
	
	static var gto: AttributedString { mutableAttributedStringFromString("GTO", color: .shiftColor) }
	
	static var rcl: AttributedString { mutableAttributedStringFromString("RCL", color: .white) }
	
	static var bst: AttributedString { mutableAttributedStringFromString("BST", color: .shiftColor) }
	
	static var sst: AttributedString { mutableAttributedStringFromString("SST", color: .white) }
	
	static var catalog: AttributedString { mutableAttributedStringFromString("CATALOG", color: .shiftColor) }
	
	static var enter: AttributedString { mutableAttributedStringFromString("ENTER ↑", color: .white) }
	
	static var isg: AttributedString { mutableAttributedStringFromString("ISG", color: .shiftColor) }
	
	static var chs: AttributedString { mutableAttributedStringFromString("CHS", color: .white) }
	
	static var rtn: AttributedString { mutableAttributedStringFromString("RTN", color: .shiftColor) }
	
	static var eex: AttributedString { mutableAttributedStringFromString("EEX", color: .white) }
	
	static var clxa: AttributedString {
		var clxaString = mutableAttributedStringFromString("CL X/A", color: .shiftColor)
        if let range = clxaString.range(of: "X") {
            clxaString[range].font = getTimesNewRoman(13.0)
        }
//		let clxaAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(13.0)
//		]
//		clxaString.addAttributes(convertToNSAttributedStringKeyDictionary(clxaAttributes), range: NSMakeRange(3, 1))

		return clxaString
	}
	
	static var back: AttributedString { mutableAttributedStringFromString("←", color: .white) }
	
	static var xeqy: AttributedString {
		var xeqyString = mutableAttributedStringFromString("x=y ?", color: .shiftColor)
        if let range = xeqyString.range(of: "x=y") {
            xeqyString[range].font = getTimesNewRoman(16.0)
        }
//		let xeqyAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(16.0)
//		]
//		xeqyString.addAttributes(convertToNSAttributedStringKeyDictionary(xeqyAttributes), range: NSMakeRange(0, 3))

		return xeqyString
	}
	
	static var minus: AttributedString  { mutableAttributedStringFromString("━", color: .white, font: getHelvetica(11.0)) }

	static var sf: AttributedString { mutableAttributedStringFromString("SF", color: .shiftColor) }
	
	static var seven: AttributedString { mutableAttributedStringFromString("7", color: .white) }

	static var cf: AttributedString { mutableAttributedStringFromString("CF", color: .shiftColor) }
	
	static var eight: AttributedString { mutableAttributedStringFromString("8", color: .white) }

	static var fsQuestionMark: AttributedString { mutableAttributedStringFromString("FS?", color: .shiftColor) }
	
	static var nine: AttributedString { mutableAttributedStringFromString("9", color: .white) }

	static var xlessthany: AttributedString {
		var xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: .shiftColor)
        if let range = xlessthanyString.range(of: "x≤y") {
            xlessthanyString[range].font = getTimesNewRoman(15.0)
        }
//		let xlessthanyAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15)
//		]
//		xlessthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xlessthanyAttributes), range: NSMakeRange(0, 3))
		
		return xlessthanyString
	}
	
	static var plus: AttributedString  { mutableAttributedStringFromString("╋", color: .white, font: getHelvetica(9)) }

	static var beep: AttributedString { mutableAttributedStringFromString("BEEP", color: .shiftColor) }
	
	static var four: AttributedString { mutableAttributedStringFromString("4", color: .white) }

	static var ptor: AttributedString { mutableAttributedStringFromString("P→R", color: .shiftColor) }
	
	static var five: AttributedString { mutableAttributedStringFromString("5", color: .white) }

	static var rtop: AttributedString { mutableAttributedStringFromString("R→P", color: .shiftColor) }
	
	static var six: AttributedString { mutableAttributedStringFromString("6", color: .white) }

	static var xgreaterthany: AttributedString {
		var xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: .shiftColor)
        if let range = xgreaterthanyString.range(of: "x>y") {
            xgreaterthanyString[range].font = getTimesNewRoman(15.0)
            xgreaterthanyString[range].baselineOffset = -1.0
        }
//		let xgreaterthanyAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
//		] as [String : Any]
//		xgreaterthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xgreaterthanyAttributes), range: NSMakeRange(0, 3))
		
		return xgreaterthanyString
	}

	static var multiply: AttributedString  { mutableAttributedStringFromString("×", color: .white, font: getHelvetica(17)) }

	static var fix: AttributedString { mutableAttributedStringFromString("FIX", color: .shiftColor) }

	static var one: AttributedString { mutableAttributedStringFromString("1", color: .white) }

	static var sci: AttributedString { mutableAttributedStringFromString("SCI", color: .shiftColor) }

	static var two: AttributedString { mutableAttributedStringFromString("2", color: .white) }

	static var eng: AttributedString { mutableAttributedStringFromString("ENG", color: .shiftColor) }

	static var three: AttributedString { mutableAttributedStringFromString("3", color: .white) }

	static var xeqzero: AttributedString {
		var xeq0String = mutableAttributedStringFromString("x=0 ?", color: .shiftColor)
        if let range = xeq0String.range(of: "x=0 ?") {
            xeq0String[range].font = getTimesNewRoman(15.0)
            xeq0String[range].baselineOffset = -1.0
        }
//		let xeq0Attributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15),
//			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
//		] as [String : Any]
//		xeq0String.addAttributes(convertToNSAttributedStringKeyDictionary(xeq0Attributes), range: NSMakeRange(0, 5))
		
		return xeq0String
	}
	
	static var divide: AttributedString  { mutableAttributedStringFromString("÷", color: .white, font: getHelvetica(17)) }

	static var pi: AttributedString { mutableAttributedStringFromString("π", color: .shiftColor, font: getTimesNewRoman(17 * yRatio)) }
	
	static var zero: AttributedString { mutableAttributedStringFromString("0", color: .white) }

	static var lastX: AttributedString {
		var lastxString = mutableAttributedStringFromString("LAST X", color: .shiftColor)
        if let range = lastxString.range(of: "X") {
            lastxString[range].font = getTimesNewRoman(15.0)
        }
//		let lastxAttributes = [
//			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15)
//		]
//		lastxString.addAttributes(convertToNSAttributedStringKeyDictionary(lastxAttributes), range: NSMakeRange(5, 1))
		
		return lastxString
	}

	static var dot: AttributedString { mutableAttributedStringFromString("•", color: .white, font: getHelvetica(17)) }

	static var view: AttributedString { mutableAttributedStringFromString("VIEW", color: .shiftColor) }
	
	static var rs: AttributedString { mutableAttributedStringFromString("R/S", color: .white, font: getHelvetica(14)) }

	static func mutableAttributedStringFromString(_ attrString: String, color: Color?, font: Font = getHelvetica(13)) -> AttributedString {
		let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.center

		if let aColor = color {
            var aString = AttributedString(attrString)
            aString.font = font
            aString.foregroundColor = aColor
            aString.mergeAttributes(.init([.paragraphStyle: textStyle]))
            
            return aString
//			return NSMutableAttributedString(
//				string: attrString,
//				attributes: convertToOptionalNSAttributedStringKeyDictionary([
//					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font,
//					convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): aColor,
//					convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
//				])
//			)
		} else {
            var aString = AttributedString(attrString)
            aString.font = font
            aString.mergeAttributes(.init([.paragraphStyle: textStyle]))

            return aString
//			return NSMutableAttributedString(
//				string: attrString,
//				attributes: convertToOptionalNSAttributedStringKeyDictionary([
//					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font,
//					convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
//				])
//			)
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
