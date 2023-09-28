//
//  ViewController.swift
//  my41
//
//  Created by Miroslav Perovic on 7/30/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
	@IBOutlet weak var keyboard: Keyboard!
	@IBOutlet weak var buttonCellOn: ButtonCell!
	@IBOutlet weak var buttonCellUSER: ButtonCell!
	@IBOutlet weak var buttonCellPRGM: ButtonCell!
	@IBOutlet weak var buttonCellALPHA: ButtonCell!
	
	@IBOutlet weak var displayBackgroundView: NSView!
	@IBOutlet weak var keyboardContainerView: NSView!
	
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
	
	@IBOutlet weak var calculatorLabel: NSTextField!
		
	override func viewWillAppear() {
		self.becomeFirstResponder()
		
		let aView = self.view as! CalculatorView
		aView.viewController = self

		self.view.layer = CALayer()
		self.view.layer?.cornerRadius = 6.0
		self.view.layer?.backgroundColor = NSColor(calibratedRed: 0.221, green: 0.221, blue: 0.221, alpha: 1.0).cgColor
		self.view.wantsLayer = true

		displayBackgroundView.layer = CALayer()
		displayBackgroundView.layer?.backgroundColor = NSColor.lightGray.cgColor
		displayBackgroundView.layer?.cornerRadius = 3.0
		displayBackgroundView.wantsLayer = true
		
		// ON
		buttonCellOn.upperText = mutableAttributedStringFromString(aString: "ON", color: .white)
		
		// USER
		buttonCellUSER.upperText = mutableAttributedStringFromString(aString: "USER", color: .white)
		
		// PRGM
		buttonCellPRGM.upperText = mutableAttributedStringFromString(aString: "PRGM", color: .white)
		
		// ALPHA
		buttonCellALPHA.upperText = mutableAttributedStringFromString(aString: "ALPHA", color: .white)

		// Label Σ-
		let Helvetica13Font = NSFont(name: "Helvetica", size: 13.0)
		if let actualFont = Helvetica13Font {
			let sigmaMinusString = mutableAttributedStringFromString(aString: "Σ-", color: nil)
			let sigmaMinusAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedStringValue = sigmaMinusString
		}
		
		// Button Σ+
		let sigmaPlusString = mutableAttributedStringFromString(aString: "Σ+", color: .white)
		let sigmaPlusAttributes = [
			NSAttributedString.Key.baselineOffset: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonCellSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		let TimesNewRoman10Font = NSFont(name: "Times New Roman", size: 10.0)
		if let actualFont = TimesNewRoman10Font {
			let yxString = mutableAttributedStringFromString(aString: "yx", color: nil)
			let yxAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
			labelYX.attributedStringValue = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman10Font {
			let oneXString = mutableAttributedStringFromString(aString: "1/x", color: .white)
			let oneXAttributes = [
				NSAttributedString.Key.font : actualFont,
			]
			oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
			buttonCellOneX.upperText = oneXString
		}
		
		// Label x^2
		let TimesNewRoman12Font = NSFont(name: "Times New Roman", size: 12.0)
		if let actualFont = TimesNewRoman12Font {
			let xSquareString = mutableAttributedStringFromString(aString: "x\u{00B2}", color: nil)
			let xSquareAttributes = [
				NSAttributedString.Key.font : actualFont,
			]
			xSquareString.addAttributes(xSquareAttributes, range: NSMakeRange(0, 2))
			labelXSquare.attributedStringValue = xSquareString
		}
		
		// Button √x
		if let actualFont = TimesNewRoman10Font {
			let rootXString = mutableAttributedStringFromString(aString: "√x\u{0304}", color: .white)
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
		if let actualFont = TimesNewRoman10Font {
			let tenXString = mutableAttributedStringFromString(aString: "10x", color: nil)
			let tenXAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			tenXString.addAttributes(tenXAttributes, range: NSMakeRange(2, 1))
			labelTenX.attributedStringValue = tenXString
		}
		
		// Button LOG
		buttonCellLog.upperText = mutableAttributedStringFromString(aString: "LOG", color: .white)
		
		// Label e^x
		let Helvetica12Font = NSFont(name: "Helvetica", size: 12.0)
		if let actualFont = TimesNewRoman10Font {
			let eXString = mutableAttributedStringFromString(aString: "ex", color: nil)
			let eXAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			
			if let actualFont2 = Helvetica12Font {
				eXString.addAttributes(eXAttributes, range: NSMakeRange(1, 1))
				let eXAttributes2 = [
					NSAttributedString.Key.font : actualFont2
				]
				eXString.addAttributes(eXAttributes2, range: NSMakeRange(0, 1))
				labelEX.attributedStringValue = eXString
			}
		}
		
		// Button LN
		buttonCellLn.upperText = mutableAttributedStringFromString(aString: "LN", color: .white)
		
		// Label CLΣ
		labelCLSigma.attributedStringValue = mutableAttributedStringFromString(aString: "CLΣ", color: nil)
		
		// Button x≷y
		let TimesNewRoman14Font = NSFont(name: "Times New Roman", size: 14.0)
		if let actualFont = TimesNewRoman14Font {
			let XexYString = mutableAttributedStringFromString(aString: "x≷y", color: .white)
			let XexYAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			XexYString.addAttributes(XexYAttributes, range: NSMakeRange(0, 3))
			buttonCellXexY.upperText = XexYString
		}
		
		// Label %
		labelPercent.attributedStringValue = mutableAttributedStringFromString(aString: "%", color: nil)
		
		// Button R↓
		buttonCellRArrrow.upperText = mutableAttributedStringFromString(aString: "R↓", color: .white)
		
		// Label SIN-1
		let TimesNewRoman09Font = NSFont(name: "Times New Roman", size: 9.0)
		if let actualFont = TimesNewRoman09Font {
			let sin1String = mutableAttributedStringFromString(aString: "SIN-1", color: nil)
			let sinAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			sin1String.addAttributes(sinAttributes, range: NSMakeRange(3, 2))
			labelSin.attributedStringValue = sin1String
		}
		
		// Button SIN
		buttonCellSin.upperText = mutableAttributedStringFromString(aString: "SIN", color: .white)
		
		// Label COS-1
		if let actualFont = TimesNewRoman09Font {
			let cos1String = mutableAttributedStringFromString(aString: "COS-1", color: nil)
			let cosAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			cos1String.addAttributes(cosAttributes, range: NSMakeRange(3, 2))
			labelCos.attributedStringValue = cos1String
		}
		
		// Button COS
		buttonCellCos.upperText = mutableAttributedStringFromString(aString: "COS", color: .white)
		
		// Label TAN-1
		if let actualFont = TimesNewRoman09Font {
			let tan1String = mutableAttributedStringFromString(aString: "TAN-1", color: nil)
			let tanAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 4
			] as [NSAttributedString.Key : Any]
			tan1String.addAttributes(tanAttributes, range: NSMakeRange(3, 2))
			labelTan.attributedStringValue = tan1String
		}
		
		// Button TAN
		buttonCellTan.upperText = mutableAttributedStringFromString(aString: "TAN", color: .white)
		
		// Label ASN
		labelASN.attributedStringValue = mutableAttributedStringFromString(aString: "ASN", color: nil)
		
		// Button XEQ
		buttonCellXEQ.upperText = mutableAttributedStringFromString(aString: "XEQ", color: .white)
		
		// Label LBL
		labelLBL.attributedStringValue = mutableAttributedStringFromString(aString: "LBL", color: nil)
		
		// Button STO
		buttonCellSTO.upperText = mutableAttributedStringFromString(aString: "STO", color: .white)
		
		// Label GTO
		labelGTO.attributedStringValue = mutableAttributedStringFromString(aString: "GTO", color: nil)
		
		// Button RCL
		buttonCellRCL.upperText = mutableAttributedStringFromString(aString: "RCL", color: .white)
		
		// Label BST
		labelBST.attributedStringValue = mutableAttributedStringFromString(aString: "BST", color: nil)
		
		// Button SST
		buttonCellSST.upperText = mutableAttributedStringFromString(aString: "SST", color: .white)
		
		// Label CATALOG
		labelCATALOG.attributedStringValue = mutableAttributedStringFromString(aString: "CATALOG", color: nil)
		
		// Button ENTER
		buttonCellENTER.upperText = mutableAttributedStringFromString(aString: "ENTER ↑", color: .white)
		
		// Label ISG
		labelISG.attributedStringValue = mutableAttributedStringFromString(aString: "ISG", color: nil)
		
		// Button CHS
		buttonCellCHS.upperText = mutableAttributedStringFromString(aString: "CHS", color: .white)
		
		// Label RTN
		labelRTN.attributedStringValue = mutableAttributedStringFromString(aString: "RTN", color: nil)
		
		// Button EEX
		buttonCellEEX.upperText = mutableAttributedStringFromString(aString: "EEX", color: .white)
		
		// Label CL X/A
		let TimesNewRoman11Font = NSFont(name: "Times New Roman", size: 11.0)
		if let actualFont = TimesNewRoman11Font {
			let clxaString = mutableAttributedStringFromString(aString: "CL X/A", color: nil)
			let clxaAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			clxaString.addAttributes(clxaAttributes, range: NSMakeRange(3, 1))
			labelCLXA.attributedStringValue = clxaString
		}
		
		// Button Back
		let Helvetica11Font = NSFont(name: "Helvetica", size: 11.0)
		if let actualFont = Helvetica11Font {
			let backString = mutableAttributedStringFromString(aString: "←", color: .white)
			let backAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			backString.addAttributes(backAttributes, range: NSMakeRange(0, 1))
			buttonCellBack.upperText = backString
		}
		
		// Label x=y ?
		if let actualFont = TimesNewRoman14Font {
			let xeqyString = mutableAttributedStringFromString(aString: "x=y ?", color: nil)
			let xeqyAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			xeqyString.addAttributes(xeqyAttributes, range: NSMakeRange(0, 3))
			labelXEQY.attributedStringValue = xeqyString
		}
		
		// Button Minus
		let Helvetica09Font = NSFont(name: "Helvetica", size: 9.0)
		if let actualFont = Helvetica09Font {
			let minusString = mutableAttributedStringFromString(aString: "━", color: .white)
			let minusAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: -1
			] as [NSAttributedString.Key : Any]
			minusString.addAttributes(minusAttributes, range: NSMakeRange(0, 1))
			buttonCellMinus.upperText = minusString
		}
		
		// Label x≤y ?
		let TimesNewRoman13Font = NSFont(name: "Times New Roman", size: 13.0)
		if let actualFont = TimesNewRoman13Font {
			let xlessthanyString = mutableAttributedStringFromString(aString: "x≤y ?", color: nil)
			let xlessthanyAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			xlessthanyString.addAttributes(xlessthanyAttributes, range: NSMakeRange(0, 3))
			labelXLessThanY.attributedStringValue = xlessthanyString
		}
		
		// Button Plus
		if let actualFont = Helvetica09Font {
			let plusString = mutableAttributedStringFromString(aString: "╋", color: .white)
			let plusAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
			buttonCellPlus.upperText = plusString
		}
		
		// Label x≥y ?
		if let actualFont = TimesNewRoman13Font {
			let xgreaterthanyString = mutableAttributedStringFromString(aString: "x>y ?", color: nil)
			let xgreaterthanyAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: -1
			] as [NSAttributedString.Key : Any]
			xgreaterthanyString.addAttributes(xgreaterthanyAttributes, range: NSMakeRange(0, 3))
			labelXGreaterThanY.attributedStringValue = xgreaterthanyString
		}
		
		// Button Multiply
		let Helvetica15Font = NSFont(name: "Helvetica", size: 15.0)
		if let actualFont = Helvetica15Font {
			let multiplyString = mutableAttributedStringFromString(aString: "×", color: .white)
			let multiplyAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
			buttonCellMultiply.upperText = multiplyString
		}
		
		// Label x=0 ?
		if let actualFont = TimesNewRoman13Font {
			let xeq0String = mutableAttributedStringFromString(aString: "x=0 ?", color: nil)
			let xeq0Attributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: -1
			] as [NSAttributedString.Key : Any]
			xeq0String.addAttributes(xeq0Attributes, range: NSMakeRange(0, 5))
			labelXEQ0.attributedStringValue = xeq0String
		}
		
		// Button Divide
		if let actualFont = Helvetica15Font {
			let divideString = mutableAttributedStringFromString(aString: "÷", color: .white)
			let divideAttributes = [
				NSAttributedString.Key.font : actualFont,
				NSAttributedString.Key.baselineOffset: 1
			] as [NSAttributedString.Key : Any]
			divideString.addAttributes(divideAttributes, range: NSMakeRange(0, 1))
			buttonCellDivide.upperText = divideString
		}

		// Label SF
		labelSF.attributedStringValue = mutableAttributedStringFromString(aString: "SF", color: nil)
		
		// Button 7
		if let actualFont = Helvetica13Font {
			let sevenString = mutableAttributedStringFromString(aString: "7", color: .white)
			let sevenAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			sevenString.addAttributes(sevenAttributes, range: NSMakeRange(0, 1))
			buttonCell7.upperText = sevenString
		}
		
		// Label CF
		labelCF.attributedStringValue = mutableAttributedStringFromString(aString: "CF", color: nil)
		
		// Button 8
		if let actualFont = Helvetica13Font {
			let eightString = mutableAttributedStringFromString(aString: "8", color: .white)
			let eightAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			eightString.addAttributes(eightAttributes, range: NSMakeRange(0, 1))
			buttonCell8.upperText = eightString
		}
		
		// Label FS?
		labelFS.attributedStringValue = mutableAttributedStringFromString(aString: "FS?", color: nil)
		
		// Button 9
		if let actualFont = Helvetica13Font {
			let nineString = mutableAttributedStringFromString(aString: "9", color: .white)
			let nineAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			nineString.addAttributes(nineAttributes, range: NSMakeRange(0, 1))
			buttonCell9.upperText = nineString
		}
		
		// Label BEEP
		labelBEEP.attributedStringValue = mutableAttributedStringFromString(aString: "BEEP", color: nil)
		
		// Button 4
		if let actualFont = Helvetica13Font {
			let fourString = mutableAttributedStringFromString(aString: "4", color: .white)
			let fourAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			fourString.addAttributes(fourAttributes, range: NSMakeRange(0, 1))
			buttonCell4.upperText = fourString
		}
		
		// Label P→R
		labelPR.attributedStringValue = mutableAttributedStringFromString(aString: "P→R", color: nil)
		
		// Button 5
		if let actualFont = Helvetica13Font {
			let fiveString = mutableAttributedStringFromString(aString: "5", color: .white)
			let fiveAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			fiveString.addAttributes(fiveAttributes, range: NSMakeRange(0, 1))
			buttonCell5.upperText = fiveString
		}
		
		// Label R→P
		labelRP.attributedStringValue = mutableAttributedStringFromString(aString: "R→P", color: nil)
		
		// Button 6
		if let actualFont = Helvetica13Font {
			let sixString = mutableAttributedStringFromString(aString: "6", color: .white)
			let sixAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			sixString.addAttributes(sixAttributes, range: NSMakeRange(0, 1))
			buttonCell6.upperText = sixString
		}
		
		// Label FIX
		labelFIX.attributedStringValue = mutableAttributedStringFromString(aString: "FIX", color: nil)
		
		// Button 1
		if let actualFont = Helvetica13Font {
			let oneString = mutableAttributedStringFromString(aString: "1", color: .white)
			let oneAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			oneString.addAttributes(oneAttributes, range: NSMakeRange(0, 1))
			buttonCell1.upperText = oneString
		}
		
		// Label SCI
		labelSCI.attributedStringValue = mutableAttributedStringFromString(aString: "SCI", color: nil)
		
		// Button 2
		if let actualFont = Helvetica13Font {
			let twoString = mutableAttributedStringFromString(aString: "2", color: .white)
			let twoAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			twoString.addAttributes(twoAttributes, range: NSMakeRange(0, 1))
			buttonCell2.upperText = twoString
		}
		
		// Label ENG
		labelENG.attributedStringValue = mutableAttributedStringFromString(aString: "ENG", color: nil)
		
		// Button 3
		if let actualFont = Helvetica13Font {
			let thtreeString = mutableAttributedStringFromString(aString: "3", color: .white)
			let thtreeAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			thtreeString.addAttributes(thtreeAttributes, range: NSMakeRange(0, 1))
			buttonCell3.upperText = thtreeString
		}
		
		// Label PI
		let TimesNewRoman15Font = NSFont(name: "Times New Roman", size: 15.0)
		if let actualFont = TimesNewRoman15Font {
			let piString = mutableAttributedStringFromString(aString: "π", color: nil)
			let piAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			piString.addAttributes(piAttributes, range: NSMakeRange(0, 1))
			labelPI.attributedStringValue = piString
		}
		
		// Button 0
		if let actualFont = Helvetica13Font {
			let zeroString = mutableAttributedStringFromString(aString: "0", color: .white)
			let zeroAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			zeroString.addAttributes(zeroAttributes, range: NSMakeRange(0, 1))
			buttonCell0.upperText = zeroString
		}
		
		// Label LAST X
		if let actualFont = TimesNewRoman13Font {
			let lastxString = mutableAttributedStringFromString(aString: "LAST X", color: nil)
			let lastxAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			lastxString.addAttributes(lastxAttributes, range: NSMakeRange(5, 1))
			labelLASTX.attributedStringValue = lastxString
		}
		
		// Button •
		if let actualFont = Helvetica13Font {
			let pointString = mutableAttributedStringFromString(aString: "•", color: .white)
			let pointAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			pointString.addAttributes(pointAttributes, range: NSMakeRange(0, 1))
			buttonCellPoint.upperText = pointString
		}
		
		// Label VIEW
		labelVIEW.attributedStringValue = mutableAttributedStringFromString(aString: "VIEW", color: nil)
		
		// Button R/S
		if let actualFont = Helvetica12Font {
			let rsString = mutableAttributedStringFromString(aString: "R/S", color: .white)
			let rsAttributes = [
				NSAttributedString.Key.font : actualFont
			]
			rsString.addAttributes(rsAttributes, range: NSMakeRange(0, 3))
			buttonCellRS.upperText = rsString
		}
	}
	
	// →≤≥
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		                            
	}
	
	override func viewDidAppear() {
		if let cType = CalculatorController.sharedInstance.calculatorType {
			switch cType {
			case .hp41c:
				calculatorLabel.stringValue = "my41C"
			case .hp41cv:
				calculatorLabel.stringValue = "my41CV"
			case .hp41cx:
				calculatorLabel.stringValue = "my41CX"
			}
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func mutableAttributedStringFromString(aString: String, color: NSColor?) -> NSMutableAttributedString {
		let Helvetica11Font = NSFont(name: "Helvetica", size: 11.0)
		if let actualFont = Helvetica11Font {
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
	
	override var acceptsFirstResponder: Bool { return true }

	@IBAction func keyPressed(sender: AnyObject) {
		if let key = sender as? Key, let keyCode = key.keyCode as? Bits8 {
			if TRACE != 0 {
				print(keyCode)
			}

			cpu.keyWithCode(keyCode, pressed: true)
			if TRACE != 0 {
				print(keyCode)
			}
			cpu.keyWithCode(keyCode, pressed: false)
		}
	}
}

class KeyboardView : NSView {
	override func draw(_ dirtyRect: NSRect) {
		//// Color Declarations
		let color = NSColor(calibratedRed: 0.604, green: 0.467, blue: 0.337, alpha: 1)
		
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSMakePoint(5, 0))
		bezierPath.line(to: NSMakePoint(self.bounds.width - 5.0, 0))
		bezierPath.curve(to: NSMakePoint(self.bounds.width - 5.0, self.bounds.height), controlPoint1: NSMakePoint(self.bounds.width, self.bounds.height / 2.0), controlPoint2: NSMakePoint(self.bounds.width - 5.0, self.bounds.height))
		bezierPath.line(to: NSMakePoint(5, self.bounds.height))
		bezierPath.curve(to: NSMakePoint(5, 0), controlPoint1: NSMakePoint(0, self.bounds.height / 2.0), controlPoint2: NSMakePoint(5, 0))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()
	}
}

class CalculatorView: NSView {
	@IBOutlet weak var lcdDisplay: Display!
	
	var viewController: ViewController?
	var pressedKey: Key?
	
	override func awakeFromNib() {
		var rect = self.bounds
		rect.origin.x = 0.0
		rect.origin.y = 0.0
		self.setNeedsDisplay(rect)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.displayOff),
			name: NSNotification.Name(rawValue: "displayOff"),
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.displayToggle),
			name: NSNotification.Name(rawValue: "displayToggle"),
			object: nil
		)
	}
	
	override var acceptsFirstResponder: Bool { return true }
	
	override func keyDown(with theEvent: NSEvent) {
		if pressedKey == nil {
			if let theButton = getKey(theEvent: theEvent) {
				pressedKey = theButton
				theButton.downKey()
				theButton.highlight(true)
			}
		}
	}
	
	override func keyUp(with theEvent: NSEvent) {
		if let theButton = pressedKey {
			theButton.upKey()
			theButton.highlight(false)
			pressedKey = nil
		}
	}
	
	@objc func displayOff() {
		lcdDisplay.displayOff()
	}
	
	@objc func displayToggle() {
		lcdDisplay.displayToggle()
	}
	
	func getKey(theEvent: NSEvent) -> Key? {
		let char = theEvent.charactersIgnoringModifiers
		let hasCommand = (theEvent.modifierFlags.intersection(.command)).rawValue != 0
		let hasAlt = (theEvent.modifierFlags.intersection(.option)).rawValue != 0
		
		if CalculatorController.sharedInstance.alphaMode {
			if hasCommand {
				if hasAlt {
					if char == "a" || char == "A" {
						return viewController?.keyboard?.keyAlpha!
					} else if char == "p" || char == "P" {
						return viewController?.keyboard?.keyPrgm!
					} else if char == "u" || char == "U" {
						return viewController?.keyboard?.keyUser!
					} else if char == "o" || char == "O" {
						return viewController?.keyboard?.keyOn!
					}
				} else {
					if char == "r" || char == "R" {
						return viewController?.buttonRS!
					} else if char == "f" || char == "F" {
						return viewController?.buttonShift!
					} else if char == "s" || char == "S" {
						return viewController?.buttonSST!
					}
				}
			} else {
				if char == "." {
					return viewController?.buttonPoint!
				} else if char == "0" {
					return viewController?.button0!
				} else if char == "1" {
					return viewController?.button1!
				} else if char == "2" {
					return viewController?.button2!
				} else if char == "3" {
					return viewController?.button3!
				} else if char == "4" {
					return viewController?.button4!
				} else if char == "5" {
					return viewController?.button5!
				} else if char == "6" {
					return viewController?.button6!
				} else if char == "7" {
					return viewController?.button7!
				} else if char == "8" {
					return viewController?.button8!
				} else if char == "9" {
					return viewController?.button9!
				} else if char == "a" || char == "A" {
					return viewController?.buttonSigmaPlus!
				} else if char == "b" || char == "B" {
					return viewController?.buttonOneX!
				} else if char == "c" || char == "C" {
					return viewController?.buttonSquareRoot!
				} else if char == "d" || char == "D" {
					return viewController?.buttonLog!
				} else if char == "e" || char == "E" {
					return viewController?.buttonLn!
				} else if char == "f" || char == "F" {
					return viewController?.buttonXexY!
				} else if char == "g" || char == "G" {
					return viewController?.buttonRArrrow!
				} else if char == "h" || char == "H" {
					return viewController?.buttonSin!
				} else if char == "i" || char == "I" {
					return viewController?.buttonCos!
				} else if char == "j" || char == "J" {
					return viewController?.buttonTan!
				} else if char == "k" || char == "K" {
					return viewController?.buttonXEQ!
				} else if char == "l" || char == "L" {
					return viewController?.buttonSTO!
				} else if char == "m" || char == "M" {
					return viewController?.buttonRCL!
				} else if char == "n" || char == "N" {
					return viewController?.buttonENTER!
				} else if char == "o" || char == "O" {
					return viewController?.buttonCHS!
				} else if char == "p" || char == "P" {
					return viewController?.buttonEEX!
				} else if char == "\u{7f}" {
					return viewController?.buttonBack!
				} else if char == "q" || char == "Q" {
					return viewController?.buttonMinus!
				} else if char == "r" || char == "R" {
					return viewController?.button7!
				} else if char == "s" || char == "S" {
					return viewController?.button8!
				} else if char == "t" || char == "T" {
					return viewController?.button9!
				} else if char == "u" || char == "U" {
					return viewController?.buttonPlus!
				} else if char == "v" || char == "V" {
					return viewController?.button4!
				} else if char == "w" || char == "W" {
					return viewController?.button5!
				} else if char == "x" || char == "X" {
					return viewController?.button6!
				} else if char == "y" || char == "Y" {
					return viewController?.buttonMultiply!
				} else if char == "z" || char == "Z" {
					return viewController?.button1!
				} else if char == "=" {
					return viewController?.button2!
				} else if char == "?" {
					return viewController?.button3!
				} else if char == ":" {
					return viewController?.buttonDivide!
				} else if char == " " {
					return viewController?.button0!
				} else if char == "," {
					return viewController?.buttonPoint!
				}
			}
		} else {
			if hasCommand {
				if hasAlt {
					if char == "a" || char == "A" {
						return viewController?.keyboard?.keyAlpha!
					} else if char == "p" || char == "P" {
						return viewController?.keyboard?.keyPrgm!
					} else if char == "u" || char == "U" {
						return viewController?.keyboard?.keyUser!
					} else if char == "o" || char == "O" {
						return viewController?.keyboard?.keyOn!
					}
				} else {
					if char == "r" || char == "R" {
						return viewController?.buttonRS!
					} else if char == "f" || char == "F" {
						return viewController?.buttonShift!
					} else if char == "s" || char == "S" {
						return viewController?.buttonSST!
					} else if char == "x" || char == "X" {
						return viewController?.buttonXexY!
					} else if char == "a" || char == "A" {
						return viewController?.buttonRArrrow!
					} else if char == "g" || char == "G" {
						return viewController?.buttonSigmaPlus!
					} else if char == "1" {
						return viewController?.buttonOneX!
					} else if char == "l" || char == "L" {
						return viewController?.buttonLn!
					} else if char == "\u{7f}" {
						return viewController?.buttonBack!
					}
				}
			} else {
				if char == "\r" {
					return viewController?.buttonENTER!
				} else if char == "." {
					return viewController?.buttonPoint!
				} else if char == "0" {
					return viewController?.button0!
				} else if char == "1" {
					return viewController?.button1!
				} else if char == "2" {
					return viewController?.button2!
				} else if char == "3" {
					return viewController?.button3!
				} else if char == "4" {
					return viewController?.button4!
				} else if char == "5" {
					return viewController?.button5!
				} else if char == "6" {
					return viewController?.button6!
				} else if char == "7" {
					return viewController?.button7!
				} else if char == "8" {
					return viewController?.button8!
				} else if char == "9" {
					return viewController?.button9!
				} else if char == "+" {
					return viewController?.buttonPlus!
				} else if char == "-" {
					return viewController?.buttonMinus!
				} else if char == "*" {
					return viewController?.buttonMultiply!
				} else if char == "/" {
					return viewController?.buttonDivide!
				} else if char == "c" || char == "C" {
					return viewController?.buttonCHS!
				} else if char == "e" || char == "E" {
					return viewController?.buttonEEX!
				} else if char == "\u{7f}" {
					return viewController?.buttonBack!
				} else if char == "x" || char == "X" {
					return viewController?.buttonXEQ!
				} else if char == "s" || char == "S" {
					return viewController?.buttonSTO!
				} else if char == "r" || char == "R" {
					return viewController?.buttonRCL!
				} else if char == "i" || char == "I" {
					return viewController?.buttonSin!
				} else if char == "o" || char == "O" {
					return viewController?.buttonCos!
				} else if char == "t" || char == "T" {
					return viewController?.buttonTan!
				} else if char == "q" || char == "Q" {
					return viewController?.buttonSquareRoot!
				} else if char == "l" || char == "L" {
					return viewController?.buttonLog!
				}
			}
		}
		
		return nil
	}
}
