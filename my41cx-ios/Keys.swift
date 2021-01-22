//
//  Keys.swift
//  my41
//
//  Created by Miroslav Perovic on 6.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

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
		CalcKey(shiftText: beep, upperText: four, lowerText: getLowerAttributedString(from: "W"), keyCode: 81),
		CalcKey(shiftText: ptor, upperText: five, lowerText: getLowerAttributedString(from: "V"), keyCode: 82),
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

	static private let yRatio = UIScreen.main.bounds.size.height / 800.0
	
	static func getHelvetica(_ size: CGFloat) -> UIFont {
		return UIFont(name: "Helvetica", size: size * yRatio)!
	}

	static func getTimesNewRoman(_ size: CGFloat) -> UIFont {
		return UIFont(name: "Times New Roman", size: size * yRatio)!
	}
	
	static func getModeAttributedString(from text: String) -> NSAttributedString {
		let onString = mutableAttributedStringFromString(text, color: .white)
		let onAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(12.0),
		]
		onString.addAttributes(convertToNSAttributedStringKeyDictionary(onAttributes as [String : Any]), range: NSMakeRange(0, text.count))
		
		return onString
	}
	
	static func getLowerAttributedString(from text: String) -> NSAttributedString {
		let lowerText = mutableAttributedStringFromString(text, color: UIColor(Color.lowerColor), font: getHelvetica(text == "SPACE" ? 13.0 : 15.0))
		
		if text.count == 1 {
			let lowerTextAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(11.0 * yRatio),
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
			] as [String : Any]
			lowerText.addAttributes(convertToNSAttributedStringKeyDictionary(lowerTextAttributes), range: NSMakeRange(0, text.count))
		}
		
		return lowerText
	}
	
	static var sigmaMinus: NSAttributedString {
		let sigmaMinusString = mutableAttributedStringFromString("Σ-", color: UIColor(Color.shiftColor))
		let sigmaMinusAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(15.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
		] as [String : Any]
		sigmaMinusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaMinusAttributes), range: NSMakeRange(1, 1))
		
		return sigmaMinusString
	}
	
	static var sigmaPlus: NSAttributedString {
		let sigmaPlusString = mutableAttributedStringFromString("Σ+", color: .white)
		let sigmaPlusAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
		]
		sigmaPlusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaPlusAttributes), range: NSMakeRange(1, 1))

		return sigmaPlusString
	}
	
	static var yx: NSAttributedString {
		let yxString = mutableAttributedStringFromString("yx", color: UIColor(Color.shiftColor))
		let yxAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		yxString.addAttributes(convertToNSAttributedStringKeyDictionary(yxAttributes), range: NSMakeRange(1, 1))
		
		return yxString
	}
	
	static var oneX: NSAttributedString  {
		let oneXString = mutableAttributedStringFromString("1/x", color: .white)
		let oneXAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
		]
		oneXString.addAttributes(convertToNSAttributedStringKeyDictionary(oneXAttributes), range: NSMakeRange(2, 1))

		return oneXString
	}
	
	static var xSquare: NSAttributedString {
		let xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: UIColor(Color.shiftColor))
		let xSquareAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(14.0),
		]
		xSquareString.addAttributes(convertToNSAttributedStringKeyDictionary(xSquareAttributes), range: NSMakeRange(0, 2))
		
		return xSquareString
	}

	static var rootX: NSAttributedString {
		let rootXString = mutableAttributedStringFromString("√x", color: .white)
		let rootXAttributes2 = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
		]
		rootXString.addAttributes(convertToNSAttributedStringKeyDictionary(rootXAttributes2), range: NSMakeRange(1, 1))
		
		return rootXString
	}
	
	static var tenX: NSAttributedString {
		let tenXString = mutableAttributedStringFromString("10x", color: UIColor(Color.shiftColor))
		let tenXAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		tenXString.addAttributes(convertToNSAttributedStringKeyDictionary(tenXAttributes), range: NSMakeRange(2, 1))
		
		return tenXString
	}
	
	static var log: NSAttributedString { mutableAttributedStringFromString("LOG", color: .white) }
	
	static var eX: NSAttributedString {
		let eXString = mutableAttributedStringFromString("ex", color: UIColor(Color.shiftColor))
		let eXAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(12.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		
		eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes), range: NSMakeRange(1, 1))
		let eXAttributes2 = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getHelvetica(14.0)
		]
		eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes2), range: NSMakeRange(0, 1))

		return eXString
	}
	
	static var ln: NSAttributedString { mutableAttributedStringFromString("LN", color: .white) }
	
	static var clSigma: NSAttributedString { mutableAttributedStringFromString("CLΣ", color: UIColor(.shiftColor)) }
	
	static var xexy: NSAttributedString {
		let xexYString = mutableAttributedStringFromString("x≷y", color: .white)
		let xexYAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(16.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
		] as [String : Any]
		xexYString.addAttributes(convertToNSAttributedStringKeyDictionary(xexYAttributes), range: NSMakeRange(0, 3))

		return xexYString
	}
	
	static var percent: NSAttributedString { mutableAttributedStringFromString("%", color: UIColor(.shiftColor)) }
	
	static var rArrow: NSAttributedString { mutableAttributedStringFromString("R↓", color: .white) }
	
	static var sin1: NSAttributedString {
		let sin1String = mutableAttributedStringFromString("SIN-1", color: UIColor(.shiftColor))
		let sinAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		sin1String.addAttributes(convertToNSAttributedStringKeyDictionary(sinAttributes), range: NSMakeRange(3, 2))

		return sin1String
	}
	
	static var sin: NSAttributedString { mutableAttributedStringFromString("SIN", color: .white) }
	
	static var cos1: NSAttributedString {
		let cos1String = mutableAttributedStringFromString("COS-1", color: UIColor(.shiftColor))
		let cosAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		cos1String.addAttributes(convertToNSAttributedStringKeyDictionary(cosAttributes), range: NSMakeRange(3, 2))

		return cos1String
	}
	
	static var cos: NSAttributedString { mutableAttributedStringFromString("COS", color: .white) }
	
	static var tan1: NSAttributedString {
		let tan1String = mutableAttributedStringFromString("TAN-1", color: UIColor(.shiftColor))
		let tanAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(11.0),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
		] as [String : Any]
		tan1String.addAttributes(convertToNSAttributedStringKeyDictionary(tanAttributes), range: NSMakeRange(3, 2))
		
		return tan1String
	}
	
	static var tan: NSAttributedString { mutableAttributedStringFromString("TAN", color: .white) }
	
	static var asn: NSAttributedString { mutableAttributedStringFromString("ASN", color: UIColor(.shiftColor)) }
	
	static var xeq: NSAttributedString { mutableAttributedStringFromString("XEQ", color: .white) }
	
	static var lbl: NSAttributedString { mutableAttributedStringFromString("LBL", color: UIColor(.shiftColor)) }
	
	static var sto: NSAttributedString { mutableAttributedStringFromString("STO", color: .white) }
	
	static var gto: NSAttributedString { mutableAttributedStringFromString("GTO", color: UIColor(.shiftColor)) }
	
	static var rcl: NSAttributedString { mutableAttributedStringFromString("RCL", color: .white) }
	
	static var bst: NSAttributedString { mutableAttributedStringFromString("BST", color: UIColor(.shiftColor)) }
	
	static var sst: NSAttributedString { mutableAttributedStringFromString("SST", color: .white) }
	
	static var catalog: NSAttributedString { mutableAttributedStringFromString("CATALOG", color: UIColor(.shiftColor)) }
	
	static var enter: NSAttributedString { mutableAttributedStringFromString("ENTER ↑", color: .white) }
	
	static var isg: NSAttributedString { mutableAttributedStringFromString("ISG", color: UIColor(.shiftColor)) }
	
	static var chs: NSAttributedString { mutableAttributedStringFromString("CHS", color: .white) }
	
	static var rtn: NSAttributedString { mutableAttributedStringFromString("RTN", color: UIColor(.shiftColor)) }
	
	static var eex: NSAttributedString { mutableAttributedStringFromString("EEX", color: .white) }
	
	static var clxa: NSAttributedString {
		let clxaString = mutableAttributedStringFromString("CL X/A", color: UIColor(.shiftColor))
		let clxaAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(13.0)
		]
		clxaString.addAttributes(convertToNSAttributedStringKeyDictionary(clxaAttributes), range: NSMakeRange(3, 1))

		return clxaString
	}
	
	static var back: NSAttributedString { mutableAttributedStringFromString("←", color: .white) }
	
	static var xeqy: NSAttributedString {
		let xeqyString = mutableAttributedStringFromString("x=y ?", color: UIColor(.shiftColor))
		let xeqyAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(16.0)
		]
		xeqyString.addAttributes(convertToNSAttributedStringKeyDictionary(xeqyAttributes), range: NSMakeRange(0, 3))

		return xeqyString
	}
	
	static var minus: NSAttributedString  { mutableAttributedStringFromString("━", color: .white, font: getHelvetica(11.0)) }

	static var sf: NSAttributedString { mutableAttributedStringFromString("SF", color: UIColor(.shiftColor)) }
	
	static var seven: NSAttributedString { mutableAttributedStringFromString("7", color: .white) }

	static var cf: NSAttributedString { mutableAttributedStringFromString("CF", color: UIColor(.shiftColor)) }
	
	static var eight: NSAttributedString { mutableAttributedStringFromString("8", color: .white) }

	static var fsQuestionMark: NSAttributedString { mutableAttributedStringFromString("FS?", color: UIColor(.shiftColor)) }
	
	static var nine: NSAttributedString { mutableAttributedStringFromString("9", color: .white) }

	static var xlessthany: NSAttributedString {
		let xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: UIColor(.shiftColor))
		let xlessthanyAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15)
		]
		xlessthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xlessthanyAttributes), range: NSMakeRange(0, 3))
		
		return xlessthanyString
	}
	
	static var plus: NSAttributedString  { mutableAttributedStringFromString("╋", color: .white, font: getHelvetica(9)) }

	static var beep: NSAttributedString { mutableAttributedStringFromString("BEEP", color: UIColor(.shiftColor)) }
	
	static var four: NSAttributedString { mutableAttributedStringFromString("4", color: .white) }

	static var ptor: NSAttributedString { mutableAttributedStringFromString("P→R", color: UIColor(.shiftColor)) }
	
	static var five: NSAttributedString { mutableAttributedStringFromString("5", color: .white) }

	static var rtop: NSAttributedString { mutableAttributedStringFromString("R→P", color: UIColor(.shiftColor)) }
	
	static var six: NSAttributedString { mutableAttributedStringFromString("6", color: .white) }

	static var xgreaterthany: NSAttributedString {
		let xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: UIColor(.shiftColor))
		let xgreaterthanyAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
		] as [String : Any]
		xgreaterthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xgreaterthanyAttributes), range: NSMakeRange(0, 3))
		
		return xgreaterthanyString
	}

	static var multiply: NSAttributedString  { mutableAttributedStringFromString("×", color: .white, font: getHelvetica(17)) }

	static var fix: NSAttributedString { mutableAttributedStringFromString("FIX", color: UIColor(.shiftColor)) }

	static var one: NSAttributedString { mutableAttributedStringFromString("1", color: .white) }

	static var sci: NSAttributedString { mutableAttributedStringFromString("SCI", color: UIColor(.shiftColor)) }

	static var two: NSAttributedString { mutableAttributedStringFromString("2", color: .white) }

	static var eng: NSAttributedString { mutableAttributedStringFromString("ENG", color: UIColor(.shiftColor)) }

	static var three: NSAttributedString { mutableAttributedStringFromString("3", color: .white) }

	static var xeqzero: NSAttributedString {
		let xeq0String = mutableAttributedStringFromString("x=0 ?", color: UIColor(.shiftColor))
		let xeq0Attributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15),
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
		] as [String : Any]
		xeq0String.addAttributes(convertToNSAttributedStringKeyDictionary(xeq0Attributes), range: NSMakeRange(0, 5))
		
		return xeq0String
	}
	
	static var divide: NSAttributedString  { mutableAttributedStringFromString("÷", color: .white, font: getHelvetica(17)) }

	static var pi: NSAttributedString { mutableAttributedStringFromString("π", color: UIColor(.shiftColor), font: getTimesNewRoman(17 * yRatio)) }
	
	static var zero: NSAttributedString { mutableAttributedStringFromString("0", color: .white) }

	static var lastX: NSAttributedString {
		let lastxString = mutableAttributedStringFromString("LAST X", color: UIColor(.shiftColor))
		let lastxAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.font) : getTimesNewRoman(15)
		]
		lastxString.addAttributes(convertToNSAttributedStringKeyDictionary(lastxAttributes), range: NSMakeRange(5, 1))
		
		return lastxString
	}

	static var dot: NSAttributedString { mutableAttributedStringFromString("•", color: .white, font: getHelvetica(17)) }

	static var view: NSAttributedString { mutableAttributedStringFromString("VIEW", color: UIColor(.shiftColor)) }
	
	static var rs: NSAttributedString { mutableAttributedStringFromString("R/S", color: .white, font: getHelvetica(14)) }



	static func mutableAttributedStringFromString(_ aString: String, color: UIColor?, font: UIFont = getHelvetica(13)) -> NSMutableAttributedString {
		let textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = NSTextAlignment.center

		if let aColor = color {
			return NSMutableAttributedString(
				string: aString,
				attributes: convertToOptionalNSAttributedStringKeyDictionary([
					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font,
					convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): aColor,
					convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
				])
			)
		} else {
			return NSMutableAttributedString(
				string: aString,
				attributes: convertToOptionalNSAttributedStringKeyDictionary([
					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font,
					convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
				])
			)
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
