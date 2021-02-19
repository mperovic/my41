//
//  AlphaKeyboard.swift
//  my41
//
//  Created by Miroslav Perovic on 11/27/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

final class AlphaKeyboardViewController: NSViewController {
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
		
		// Label Σ-
		labelSigmaMinus.attributedStringValue = mutableAttributedStringFromString("a", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button Σ+
		buttonCellSigmaPlus.upperText = mutableAttributedStringFromString("A", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label yx
		labelYX.attributedStringValue = mutableAttributedStringFromString("b", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 1/x
		buttonCellOneX.upperText = mutableAttributedStringFromString("B", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label x^2
		labelXSquare.attributedStringValue = mutableAttributedStringFromString("c", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button √x
		buttonCellSquareRoot.upperText = mutableAttributedStringFromString("C", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label 10^x
		labelTenX.attributedStringValue = mutableAttributedStringFromString("d", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button LOG
		buttonCellLog.upperText = mutableAttributedStringFromString("D", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label e^x
		labelEX.attributedStringValue = mutableAttributedStringFromString("e", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button LN
		buttonCellLn.upperText = mutableAttributedStringFromString("E", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label CLΣ
		labelCLSigma.attributedStringValue = mutableAttributedStringFromString("Σ", color: nil, fontName: "Helvetica", fontSize: 11.0)
		
		// Button x≷y
		buttonCellXexY.upperText = mutableAttributedStringFromString("F", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label %
		labelPercent.attributedStringValue = mutableAttributedStringFromString("%", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button R↓
		buttonCellRArrrow.upperText = mutableAttributedStringFromString("G", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label SIN-1
		labelSin.attributedStringValue = mutableAttributedStringFromString("≠", color: nil, fontName: "Helvetica", fontSize: 15.0)
		
		// Button SIN
		buttonCellSin.upperText = mutableAttributedStringFromString("H", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label COS-1
		labelCos.attributedStringValue = mutableAttributedStringFromString("<", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button COS
		buttonCellCos.upperText = mutableAttributedStringFromString("I", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label TAN-1
		labelTan.attributedStringValue = mutableAttributedStringFromString(">", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button TAN
		buttonCellTan.upperText = mutableAttributedStringFromString("J", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label ASN
		labelASN.attributedStringValue = mutableAttributedStringFromString("⊦", color: nil, fontName: "Helvetica", fontSize: 15.0)
		
		// Button XEQ
		buttonCellXEQ.upperText = mutableAttributedStringFromString("K", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label LBL
		labelLBL.attributedStringValue = mutableAttributedStringFromString("ASTO", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button STO
		buttonCellSTO.upperText = mutableAttributedStringFromString("L", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label GTO
		labelGTO.attributedStringValue = mutableAttributedStringFromString("ARCL", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button RCL
		buttonCellRCL.upperText = mutableAttributedStringFromString("M", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label BST
		labelBST.attributedStringValue = mutableAttributedStringFromString("BST", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button SST
		buttonCellSST.upperText = mutableAttributedStringFromString("SST", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label CATALOG
		labelCATALOG.attributedStringValue = mutableAttributedStringFromString("↑", color: nil, fontName: "Helvetica", fontSize: 11.0)
		
		// Button ENTER
		buttonCellENTER.upperText = mutableAttributedStringFromString("N", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label ISG
		labelISG.attributedStringValue = mutableAttributedStringFromString("∡", color: nil, fontName: "Helvetica", fontSize: 16.0)
		
		// Button CHS
		buttonCellCHS.upperText = mutableAttributedStringFromString("O", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label RTN
		labelRTN.attributedStringValue = mutableAttributedStringFromString("$", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button EEX
		buttonCellEEX.upperText = mutableAttributedStringFromString("P", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label CL X/A
		labelCLXA.attributedStringValue = mutableAttributedStringFromString("CLA", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button Back
		buttonCellBack.upperText = mutableAttributedStringFromString("←", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label x=y ?
		labelXEQY.attributedStringValue = mutableAttributedStringFromString("━", color: nil, fontName: "Helvetica", fontSize: 8.0)
		
		// Button Minus
		buttonCellMinus.upperText = mutableAttributedStringFromString("Q", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label x≤y ?
		labelXLessThanY.attributedStringValue = mutableAttributedStringFromString("+", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button Plus
		buttonCellPlus.upperText = mutableAttributedStringFromString("U", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label x≥y ?
		labelXGreaterThanY.attributedStringValue = mutableAttributedStringFromString("*", color: nil, fontName: "Times New Roman", fontSize: 14.0)
		
		// Button Multiply
		buttonCellMultiply.upperText = mutableAttributedStringFromString("Y", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label x=0 ?
		labelXEQ0.attributedStringValue = mutableAttributedStringFromString("/", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button Divide
		buttonCellDivide.upperText = mutableAttributedStringFromString(":", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label SF
		labelSF.attributedStringValue = mutableAttributedStringFromString("7", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 7
		buttonCell7.upperText = mutableAttributedStringFromString("R", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label CF
		labelCF.attributedStringValue = mutableAttributedStringFromString("8", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 8
		buttonCell8.upperText = mutableAttributedStringFromString("S", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label FS?
		labelFS.attributedStringValue = mutableAttributedStringFromString("9", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 9
		buttonCell9.upperText = mutableAttributedStringFromString("T", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label BEEP
		labelBEEP.attributedStringValue = mutableAttributedStringFromString("4", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 4
		buttonCell4.upperText = mutableAttributedStringFromString("V", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label P→R
		labelPR.attributedStringValue = mutableAttributedStringFromString("5", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 5
		buttonCell5.upperText = mutableAttributedStringFromString("W", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label R→P
		labelRP.attributedStringValue = mutableAttributedStringFromString("6", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 6
		buttonCell6.upperText = mutableAttributedStringFromString("X", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label FIX
		labelFIX.attributedStringValue = mutableAttributedStringFromString("1", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 1
		buttonCell1.upperText = mutableAttributedStringFromString("Z", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label SCI
		labelSCI.attributedStringValue = mutableAttributedStringFromString("3", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 2
		buttonCell2.upperText = mutableAttributedStringFromString("=", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)

		// Label ENG
		labelENG.attributedStringValue = mutableAttributedStringFromString("3", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 3
		buttonCell3.upperText = mutableAttributedStringFromString("?", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label PI
		labelPI.attributedStringValue = mutableAttributedStringFromString("0", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button 0
		buttonCell0.upperText = mutableAttributedStringFromString("SPACE", color: NSColor.white, fontName: "Helvetica", fontSize: 9.0)
		
		// Label LAST X
		labelLASTX.attributedStringValue = mutableAttributedStringFromString("•", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button •
		buttonCellPoint.upperText = mutableAttributedStringFromString(",", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
		
		// Label VIEW
		labelVIEW.attributedStringValue = mutableAttributedStringFromString("AVIEW", color: nil, fontName: "Helvetica", fontSize: 12.0)
		
		// Button R/S
		buttonCellRS.upperText = mutableAttributedStringFromString("R/S", color: NSColor.white, fontName: "Helvetica", fontSize: 12.0)
	}
	
	func mutableAttributedStringFromString(_ aString: String, color: NSColor?, fontName: String, fontSize: CGFloat) -> NSMutableAttributedString {
			let aFont = NSFont(name: fontName, size: fontSize)
			if let actualFont = aFont {
				if let aColor = color {
					return NSMutableAttributedString(
						string: aString,
						attributes: [
							NSAttributedString.Key.font : actualFont,
							NSAttributedString.Key.foregroundColor: aColor
						]
					)
				} else {
					return NSMutableAttributedString(
						string: aString,
						attributes: [
							NSAttributedString.Key.font : actualFont
						]
					)
				}
			} else {
				return NSMutableAttributedString()
			}
	}
}
