//
//  KeyboardShortcuts.swift
//  my41
//
//  Created by Miroslav Perovic on 11/26/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

final class KeyboardShortcutsViewController: NSViewController {
	@IBOutlet weak var labelSigmaMinus: NSTextField!
	@IBOutlet weak var buttonCellSigmaPlus: ButtonCell!
	@IBOutlet weak var buttonSigmaPlus: Key!
	@IBOutlet weak var labelYX: NSTextField!
	@IBOutlet weak var buttonCellOneX: ButtonCell!
	@IBOutlet weak var buttonOneX: Key!
	@IBOutlet weak var labelXSquare: NSTextField!
	@IBOutlet weak var buttonCellSquareRoot: ButtonCell!
	@IBOutlet weak var buttonSquareRoot: Key!
	@IBOutlet weak var labelTenX: NSTextField!
	@IBOutlet weak var buttonCellLog: ButtonCell!
	@IBOutlet weak var buttonLog: Key!
	@IBOutlet weak var labelEX: NSTextField!
	@IBOutlet weak var buttonCellLn: ButtonCell!
	@IBOutlet weak var buttonLn: Key!
	@IBOutlet weak var labelCLSigma: NSTextField!
	@IBOutlet weak var buttonCellXexY: ButtonCell!
	@IBOutlet weak var buttonXexY: Key!
	@IBOutlet weak var labelPercent: NSTextField!
	@IBOutlet weak var buttonCellRArrrow: ButtonCell!
	@IBOutlet weak var buttonRArrrow: Key!
	@IBOutlet weak var labelSin: NSTextField!
	@IBOutlet weak var buttonCellSin: ButtonCell!
	@IBOutlet weak var buttonSin: Key!
	@IBOutlet weak var labelCos: NSTextField!
	@IBOutlet weak var buttonCellCos: ButtonCell!
	@IBOutlet weak var buttonCos: Key!
	@IBOutlet weak var labelTan: NSTextField!
	@IBOutlet weak var buttonCellTan: ButtonCell!
	@IBOutlet weak var buttonTan: Key!
	@IBOutlet weak var labelShift: NSTextField!
	@IBOutlet weak var buttonCellShift: ButtonCell!
	@IBOutlet weak var buttonShift: Key!
	@IBOutlet weak var labelASN: NSTextField!
	@IBOutlet weak var buttonCellXEQ: ButtonCell!
	@IBOutlet weak var buttonXEQ: Key!
	@IBOutlet weak var labelLBL: NSTextField!
	@IBOutlet weak var buttonCellSTO: ButtonCell!
	@IBOutlet weak var buttonSTO: Key!
	@IBOutlet weak var labelGTO: NSTextField!
	@IBOutlet weak var buttonCellRCL: ButtonCell!
	@IBOutlet weak var buttonRCL: Key!
	@IBOutlet weak var labelBST: NSTextField!
	@IBOutlet weak var buttonCellSST: ButtonCell!
	@IBOutlet weak var buttonSST: Key!
	@IBOutlet weak var labelCATALOG: NSTextField!
	@IBOutlet weak var buttonCellENTER: ButtonCell!
	@IBOutlet weak var buttonENTER: Key!
	@IBOutlet weak var labelISG: NSTextField!
	@IBOutlet weak var buttonCellCHS: ButtonCell!
	@IBOutlet weak var buttonCHS: Key!
	@IBOutlet weak var labelRTN: NSTextField!
	@IBOutlet weak var buttonCellEEX: ButtonCell!
	@IBOutlet weak var buttonEEX: Key!
	@IBOutlet weak var labelCLXA: NSTextField!
	@IBOutlet weak var buttonCellBack: ButtonCell!
	@IBOutlet weak var buttonBack: Key!
	
	@IBOutlet weak var labelXEQY: NSTextField!
	@IBOutlet weak var buttonCellMinus: ButtonCell!
	@IBOutlet weak var buttonMinus: Key!
	@IBOutlet weak var labelXLessThanY: NSTextField!
	@IBOutlet weak var buttonCellPlus: ButtonCell!
	@IBOutlet weak var buttonPlus: Key!
	@IBOutlet weak var labelXGreaterThanY: NSTextField!
	@IBOutlet weak var buttonCellMultiply: ButtonCell!
	@IBOutlet weak var buttonMultiply: Key!
	@IBOutlet weak var labelXEQ0: NSTextField!
	@IBOutlet weak var buttonCellDivide: ButtonCell!
	@IBOutlet weak var buttonDivide: Key!
	
	@IBOutlet weak var labelSF: NSTextField!
	@IBOutlet weak var buttonCell7: ButtonCell!
	@IBOutlet weak var button7: Key!
	@IBOutlet weak var labelCF: NSTextField!
	@IBOutlet weak var buttonCell8: ButtonCell!
	@IBOutlet weak var button8: Key!
	@IBOutlet weak var labelFS: NSTextField!
	@IBOutlet weak var buttonCell9: ButtonCell!
	@IBOutlet weak var button9: Key!
	@IBOutlet weak var labelBEEP: NSTextField!
	@IBOutlet weak var buttonCell4: ButtonCell!
	@IBOutlet weak var button4: Key!
	@IBOutlet weak var labelPR: NSTextField!
	@IBOutlet weak var buttonCell5: ButtonCell!
	@IBOutlet weak var button5: Key!
	@IBOutlet weak var labelRP: NSTextField!
	@IBOutlet weak var buttonCell6: ButtonCell!
	@IBOutlet weak var button6: Key!
	@IBOutlet weak var labelFIX: NSTextField!
	@IBOutlet weak var buttonCell1: ButtonCell!
	@IBOutlet weak var button1: Key!
	@IBOutlet weak var labelSCI: NSTextField!
	@IBOutlet weak var buttonCell2: ButtonCell!
	@IBOutlet weak var button2: Key!
	@IBOutlet weak var labelENG: NSTextField!
	@IBOutlet weak var buttonCell3: ButtonCell!
	@IBOutlet weak var button3: Key!
	@IBOutlet weak var labelPI: NSTextField!
	@IBOutlet weak var buttonCell0: ButtonCell!
	@IBOutlet weak var button0: Key!
	@IBOutlet weak var labelLASTX: NSTextField!
	@IBOutlet weak var buttonCellPoint: ButtonCell!
	@IBOutlet weak var buttonPoint: Key!
	@IBOutlet weak var labelVIEW: NSTextField!
	@IBOutlet weak var buttonCellRS: ButtonCell!
	@IBOutlet weak var buttonRS: Key!
	
	override func viewWillAppear() {
		self.view.layer = CALayer()
		self.view.layer?.backgroundColor = NSColor(calibratedRed: 0.221, green: 0.221, blue: 0.221, alpha: 1.0).cgColor
		self.view.wantsLayer = true
		
		let Helvetica09Font = NSFont(name: "Helvetica", size:  9.0)
		let Helvetica15Font = NSFont(name: "Helvetica", size: 15.0)

		let TimesNewRoman10Font = NSFont(name: "Times New Roman", size: 10.0)
		let TimesNewRoman13Font = NSFont(name: "Times New Roman", size: 13.0)
		
		// Label Σ-
		if let actualFont = Helvetica09Font {
			let sigmaMinusString = mutableAttributedStringFromString("⌘G", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let sigmaMinusAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedStringValue = sigmaMinusString
		}
		
		// Button Σ+
		let sigmaPlusString = mutableAttributedStringFromString("Σ+", color: .white, fontName: "Helvetica", fontSize: 11.0)
		let sigmaPlusAttributes = [
			NSAttributedString.Key.baselineOffset: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonCellSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		if let actualFont = TimesNewRoman13Font {
			let yxString = mutableAttributedStringFromString("⌘1", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let yxAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
			labelYX.attributedStringValue = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman10Font {
			let oneXString = mutableAttributedStringFromString("1/x", color: .white, fontName: "Helvetica", fontSize: 11.0)
			let oneXAttributes = [
				NSAttributedString.Key.font : actualFont,
			]
			oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
			buttonCellOneX.upperText = oneXString
		}
		
		// Label x^2
		labelXSquare.attributedStringValue = mutableAttributedStringFromString("Q", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button √x
		if let actualFont = TimesNewRoman10Font {
			let rootXString = mutableAttributedStringFromString("√x\u{0304}", color: .white, fontName: "Helvetica", fontSize: 11.0)
			let rootXAttributes1 = [
				NSAttributedString.Key.baselineOffset: 1
			]
			rootXString.addAttributes(rootXAttributes1, range: NSMakeRange(2, 1))
			let rootXAttributes2 = [
				NSAttributedString.Key.font : actualFont,
			]
			rootXString.addAttributes(rootXAttributes2, range: NSMakeRange(1, 1))
			buttonCellSquareRoot.upperText = rootXString
		}
		
		// Label 10^x
		labelTenX.attributedStringValue = mutableAttributedStringFromString("L", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button LOG
		buttonCellLog.upperText = mutableAttributedStringFromString("LOG", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label e^x
		if let actualFont = TimesNewRoman13Font {
			let EXString = mutableAttributedStringFromString("⌘L", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let EXAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			EXString.addAttributes(EXAttributes, range: NSMakeRange(1, 1))
			labelEX.attributedStringValue = EXString
		}
		
		// Button LN
		buttonCellLn.upperText = mutableAttributedStringFromString("LN", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label CLΣ
		if let actualFont = TimesNewRoman13Font {
			let CLSigmaString = mutableAttributedStringFromString("⌘X", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let CLSigmaAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			CLSigmaString.addAttributes(CLSigmaAttributes, range: NSMakeRange(1, 1))
			labelCLSigma.attributedStringValue = CLSigmaString
		}
		
		// Button x≷y
		buttonCellXexY.upperText = mutableAttributedStringFromString("x≷y", color: .white, fontName: "Times New Roman", fontSize: 14.0)
		
		// Label %
		if let actualFont = TimesNewRoman13Font {
			let percentString = mutableAttributedStringFromString("⌘A", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let percentAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			percentString.addAttributes(percentAttributes, range: NSMakeRange(1, 1))
			labelPercent.attributedStringValue = percentString
		}
		
		// Button R↓
		buttonCellRArrrow.upperText = mutableAttributedStringFromString("R↓", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label SIN-1
		if let actualFont = TimesNewRoman13Font {
			let sin1String = mutableAttributedStringFromString("I", color: nil, fontName: "Times New Roman", fontSize: 13.0)
			let sinAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			sin1String.addAttributes(sinAttributes, range: NSMakeRange(0, 1))
			labelSin.attributedStringValue = sin1String
		}
		
		// Button SIN
		buttonCellSin.upperText = mutableAttributedStringFromString("SIN", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label COS-1
		if let actualFont = TimesNewRoman13Font {
			let cos1String = mutableAttributedStringFromString("O", color: nil, fontName: "Times New Roman", fontSize: 13.0)
			let cosAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			cos1String.addAttributes(cosAttributes, range: NSMakeRange(0, 1))
			labelCos.attributedStringValue = cos1String
		}
		
		// Button COS
		buttonCellCos.upperText = mutableAttributedStringFromString("COS", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label TAN-1
		if let actualFont = TimesNewRoman13Font {
			let tan1String = mutableAttributedStringFromString("T", color: nil, fontName: "Times New Roman", fontSize: 13.0)
			let tanAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			tan1String.addAttributes(tanAttributes, range: NSMakeRange(0, 1))
			labelTan.attributedStringValue = tan1String
		}
		
		// Button TAN
		buttonCellTan.upperText = mutableAttributedStringFromString("TAN", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label Shift
		labelShift.attributedStringValue = mutableAttributedStringFromString("⌘F", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Label ASN
		labelASN.attributedStringValue = mutableAttributedStringFromString("X", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button XEQ
		buttonCellXEQ.upperText = mutableAttributedStringFromString("XEQ", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label LBL
		labelLBL.attributedStringValue = mutableAttributedStringFromString("S", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button STO
		buttonCellSTO.upperText = mutableAttributedStringFromString("STO", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label GTO
		labelGTO.attributedStringValue = mutableAttributedStringFromString("R", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button RCL
		buttonCellRCL.upperText = mutableAttributedStringFromString("RCL", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label BST
		if let actualFont = TimesNewRoman13Font {
			let BSTString = mutableAttributedStringFromString("⌘S", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let BSTAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			BSTString.addAttributes(BSTAttributes, range: NSMakeRange(1, 1))
			labelBST.attributedStringValue = BSTString
		}
		
		// Button SST
		buttonCellSST.upperText = mutableAttributedStringFromString("SST", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label CATALOG
		labelCATALOG.attributedStringValue = mutableAttributedStringFromString("⏎", color: nil, fontName: "Times New Roman", fontSize: 12.0)
		
		// Button ENTER
		buttonCellENTER.upperText = mutableAttributedStringFromString("ENTER ↑", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label ISG
		labelISG.attributedStringValue = mutableAttributedStringFromString("C", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button CHS
		buttonCellCHS.upperText = mutableAttributedStringFromString("CHS", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label RTN
		labelRTN.attributedStringValue = mutableAttributedStringFromString("E", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button EEX
		buttonCellEEX.upperText = mutableAttributedStringFromString("EEX", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label CL X/A
		labelCLXA.attributedStringValue = mutableAttributedStringFromString("←", color: nil, fontName: "Helvetica", fontSize: 11.0)
		
		// Button Back
		buttonCellBack.upperText = mutableAttributedStringFromString("←", color: .white, fontName: "Helvetica", fontSize: 11.0)
		
		// Label x=y ?
		labelXEQY.attributedStringValue = mutableAttributedStringFromString("━", color: nil, fontName: "Helvetica", fontSize: 9.0)
		
		// Button Minus
		if let actualFont = Helvetica09Font {
			let minusString = mutableAttributedStringFromString("━", color: .white, fontName: "Helvetica", fontSize: 9.0)
			let minusAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: -1
			] as [NSAttributedString.Key : Any]
			minusString.addAttributes(minusAttributes, range: NSMakeRange(0, 1))
			buttonCellMinus.upperText = minusString
		}
		
		// Label x≤y ?
		labelXLessThanY.attributedStringValue = mutableAttributedStringFromString("╋", color: nil, fontName: "Helvetica", fontSize: 9.0)
		
		// Button Plus
		buttonCellPlus.upperText = mutableAttributedStringFromString("╋", color: .white, fontName: "Times New Roman", fontSize: 9.0)
		if let actualFont = Helvetica09Font {
			let plusString = mutableAttributedStringFromString("╋", color: .white, fontName: "Helvetica", fontSize: 9.0)
			let plusAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
		}
		
		// Label x≥y ?
		labelXGreaterThanY.attributedStringValue = mutableAttributedStringFromString("*", color: nil, fontName: "Times New Roman", fontSize: 14.0)
		
		// Button Multiply
		if let actualFont = Helvetica15Font {
			let multiplyString = mutableAttributedStringFromString("×", color: .white, fontName: "Helvetica", fontSize: 15.0)
			let multiplyAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
			buttonCellMultiply.upperText = multiplyString
		}
		
		// Label x=0 ?
		labelXEQ0.attributedStringValue = mutableAttributedStringFromString("/", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button Divide
		if let actualFont = Helvetica15Font {
			let divideString = mutableAttributedStringFromString("÷", color: .white, fontName: "Helvetica", fontSize: 15.0)
			let divideAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			divideString.addAttributes(divideAttributes, range: NSMakeRange(0, 1))
			buttonCellDivide.upperText = divideString
		}
		
		// Label SF
		labelSF.attributedStringValue = mutableAttributedStringFromString("7", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 7
		buttonCell7.upperText = mutableAttributedStringFromString("7", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label CF
		labelCF.attributedStringValue = mutableAttributedStringFromString("8", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 8
		buttonCell8.upperText = mutableAttributedStringFromString("8", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label FS?
		labelFS.attributedStringValue = mutableAttributedStringFromString("9", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 9
		buttonCell9.upperText = mutableAttributedStringFromString("9", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label BEEP
		labelBEEP.attributedStringValue = mutableAttributedStringFromString("4", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 4
		buttonCell4.upperText = mutableAttributedStringFromString("4", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label P→R
		labelPR.attributedStringValue = mutableAttributedStringFromString("5", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 5
		buttonCell5.upperText = mutableAttributedStringFromString("5", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label R→P
		labelRP.attributedStringValue = mutableAttributedStringFromString("6", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 6
		buttonCell6.upperText = mutableAttributedStringFromString("6", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label FIX
		labelFIX.attributedStringValue = mutableAttributedStringFromString("1", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 1
		buttonCell1.upperText = mutableAttributedStringFromString("1", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label SCI
		labelSCI.attributedStringValue = mutableAttributedStringFromString("2", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 2
		buttonCell2.upperText = mutableAttributedStringFromString("2", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label ENG
		labelENG.attributedStringValue = mutableAttributedStringFromString("3", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 3
		buttonCell3.upperText = mutableAttributedStringFromString("3", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label PI
		labelPI.attributedStringValue = mutableAttributedStringFromString("0", color: nil, fontName: "Times New Roman", fontSize: 13.0)
		
		// Button 0
		buttonCell0.upperText = mutableAttributedStringFromString("0", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label LAST X
		labelLASTX.attributedStringValue = mutableAttributedStringFromString("•", color: nil, fontName: "Times New Roman", fontSize: 15.0)
		
		// Button •
		buttonCellPoint.upperText = mutableAttributedStringFromString("•", color: .white, fontName: "Helvetica", fontSize: 13.0)
		
		// Label VIEW
		if let actualFont = TimesNewRoman13Font {
			let viewString = mutableAttributedStringFromString("⌘R", color: nil, fontName: "Helvetica", fontSize: 11.0)
			let viewAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			viewString.addAttributes(viewAttributes, range: NSMakeRange(1, 1))
			labelVIEW.attributedStringValue = viewString
		}
		
		// Button R/S
		buttonCellRS.upperText = mutableAttributedStringFromString("R/S", color: .white, fontName: "Helvetica", fontSize: 12.0)
	}
	
	func mutableAttributedStringFromString(_ aString: String, color: NSColor?, fontName: String, fontSize: CGFloat) -> NSMutableAttributedString {
			let aFont = NSFont(name: fontName, size: fontSize)
			if let actualFont = aFont {
				if let aColor = color {
					return NSMutableAttributedString(
						string: aString,
						attributes: [NSAttributedString.Key.font : actualFont,
									 NSAttributedString.Key.foregroundColor: aColor
						]
					)
				} else {
					return NSMutableAttributedString(
						string: aString,
						attributes: [NSAttributedString.Key.font : actualFont]
					)
				}
			} else {
				return NSMutableAttributedString()
			}
	}
}
