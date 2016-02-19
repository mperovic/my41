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
		self.view.layer?.backgroundColor = NSColor(calibratedRed: 0.221, green: 0.221, blue: 0.221, alpha: 1.0).CGColor
		self.view.wantsLayer = true

		displayBackgroundView.layer = CALayer()
		displayBackgroundView.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
		displayBackgroundView.layer?.cornerRadius = 3.0
		displayBackgroundView.wantsLayer = true
		
		// ON
		buttonCellOn.upperText = mutableAttributedStringFromString("ON", color: NSColor.whiteColor())
		
		// USER
		buttonCellUSER.upperText = mutableAttributedStringFromString("USER", color: NSColor.whiteColor())
		
		// PRGM
		buttonCellPRGM.upperText = mutableAttributedStringFromString("PRGM", color: NSColor.whiteColor())
		
		// ALPHA
		buttonCellALPHA.upperText = mutableAttributedStringFromString("ALPHA", color: NSColor.whiteColor())

		// Label Σ-
		let Helvetica13Font = NSFont(name: "Helvetica", size: 13.0)
		if let actualFont = Helvetica13Font {
			let sigmaMinusString = mutableAttributedStringFromString("Σ-", color: nil)
			let sigmaMinusAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedStringValue = sigmaMinusString
		}
		
		// Button Σ+
		let sigmaPlusString = mutableAttributedStringFromString("Σ+", color: NSColor.whiteColor())
		let sigmaPlusAttributes = [
			NSBaselineOffsetAttributeName: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonCellSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		let TimesNewRoman10Font = NSFont(name: "Times New Roman", size: 10.0)
		if let actualFont = TimesNewRoman10Font {
			let yxString = mutableAttributedStringFromString("yx", color: nil)
			let yxAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
			labelYX.attributedStringValue = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman10Font {
			let oneXString = mutableAttributedStringFromString("1/x", color: NSColor.whiteColor())
			let oneXAttributes = [
				NSFontAttributeName : actualFont,
			]
			oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
			buttonCellOneX.upperText = oneXString
		}
		
		// Label x^2
		let TimesNewRoman12Font = NSFont(name: "Times New Roman", size: 12.0)
		if let actualFont = TimesNewRoman12Font {
			let xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: nil)
			let xSquareAttributes = [
				NSFontAttributeName : actualFont,
			]
			xSquareString.addAttributes(xSquareAttributes, range: NSMakeRange(0, 2))
			labelXSquare.attributedStringValue = xSquareString
		}
		
		// Button √x
		if let actualFont = TimesNewRoman10Font {
			let rootXString = mutableAttributedStringFromString("√x\u{0304}", color: NSColor.whiteColor())
			let rootXAttributes1 = [
				NSBaselineOffsetAttributeName: 1
			]
			rootXString.addAttributes(rootXAttributes1, range: NSMakeRange(2, 1))
			let rootXAttributes2 = [
				NSFontAttributeName : actualFont,
			]
			rootXString.addAttributes(rootXAttributes2, range: NSMakeRange(1, 1))
			buttonCellSquareRoot.upperText = rootXString
		}
		
		// Label 10^x
		if let actualFont = TimesNewRoman10Font {
			let tenXString = mutableAttributedStringFromString("10x", color: nil)
			let tenXAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			tenXString.addAttributes(tenXAttributes, range: NSMakeRange(2, 1))
			labelTenX.attributedStringValue = tenXString
		}
		
		// Button LOG
		buttonCellLog.upperText = mutableAttributedStringFromString("LOG", color: NSColor.whiteColor())
		
		// Label e^x
		let Helvetica12Font = NSFont(name: "Helvetica", size: 12.0)
		if let actualFont = TimesNewRoman10Font {
			let eXString = mutableAttributedStringFromString("ex", color: nil)
			let eXAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			
			if let actualFont2 = Helvetica12Font {
				eXString.addAttributes(eXAttributes, range: NSMakeRange(1, 1))
				let eXAttributes2 = [
					NSFontAttributeName : actualFont2
				]
				eXString.addAttributes(eXAttributes2, range: NSMakeRange(0, 1))
				labelEX.attributedStringValue = eXString
			}
		}
		
		// Button LN
		buttonCellLn.upperText = mutableAttributedStringFromString("LN", color: NSColor.whiteColor())
		
		// Label CLΣ
		labelCLSigma.attributedStringValue = mutableAttributedStringFromString("CLΣ", color: nil)
		
		// Button x≷y
		let TimesNewRoman14Font = NSFont(name: "Times New Roman", size: 14.0)
		if let actualFont = TimesNewRoman14Font {
			let XexYString = mutableAttributedStringFromString("x≷y", color: NSColor.whiteColor())
			let XexYAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			XexYString.addAttributes(XexYAttributes, range: NSMakeRange(0, 3))
			buttonCellXexY.upperText = XexYString
		}
		
		// Label %
		labelPercent.attributedStringValue = mutableAttributedStringFromString("%", color: nil)
		
		// Button R↓
		buttonCellRArrrow.upperText = mutableAttributedStringFromString("R↓", color: NSColor.whiteColor())
		
		// Label SIN-1
		let TimesNewRoman09Font = NSFont(name: "Times New Roman", size: 9.0)
		if let actualFont = TimesNewRoman09Font {
			let sin1String = mutableAttributedStringFromString("SIN-1", color: nil)
			let sinAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			sin1String.addAttributes(sinAttributes, range: NSMakeRange(3, 2))
			labelSin.attributedStringValue = sin1String
		}
		
		// Button SIN
		buttonCellSin.upperText = mutableAttributedStringFromString("SIN", color: NSColor.whiteColor())
		
		// Label COS-1
		if let actualFont = TimesNewRoman09Font {
			let cos1String = mutableAttributedStringFromString("COS-1", color: nil)
			let cosAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			cos1String.addAttributes(cosAttributes, range: NSMakeRange(3, 2))
			labelCos.attributedStringValue = cos1String
		}
		
		// Button COS
		buttonCellCos.upperText = mutableAttributedStringFromString("COS", color: NSColor.whiteColor())
		
		// Label TAN-1
		if let actualFont = TimesNewRoman09Font {
			let tan1String = mutableAttributedStringFromString("TAN-1", color: nil)
			let tanAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			tan1String.addAttributes(tanAttributes, range: NSMakeRange(3, 2))
			labelTan.attributedStringValue = tan1String
		}
		
		// Button TAN
		buttonCellTan.upperText = mutableAttributedStringFromString("TAN", color: NSColor.whiteColor())
		
		// Label ASN
		labelASN.attributedStringValue = mutableAttributedStringFromString("ASN", color: nil)
		
		// Button XEQ
		buttonCellXEQ.upperText = mutableAttributedStringFromString("XEQ", color: NSColor.whiteColor())
		
		// Label LBL
		labelLBL.attributedStringValue = mutableAttributedStringFromString("LBL", color: nil)
		
		// Button STO
		buttonCellSTO.upperText = mutableAttributedStringFromString("STO", color: NSColor.whiteColor())
		
		// Label GTO
		labelGTO.attributedStringValue = mutableAttributedStringFromString("GTO", color: nil)
		
		// Button RCL
		buttonCellRCL.upperText = mutableAttributedStringFromString("RCL", color: NSColor.whiteColor())
		
		// Label BST
		labelBST.attributedStringValue = mutableAttributedStringFromString("BST", color: nil)
		
		// Button SST
		buttonCellSST.upperText = mutableAttributedStringFromString("SST", color: NSColor.whiteColor())
		
		// Label CATALOG
		labelCATALOG.attributedStringValue = mutableAttributedStringFromString("CATALOG", color: nil)
		
		// Button ENTER
		buttonCellENTER.upperText = mutableAttributedStringFromString("ENTER ↑", color: NSColor.whiteColor())
		
		// Label ISG
		labelISG.attributedStringValue = mutableAttributedStringFromString("ISG", color: nil)
		
		// Button CHS
		buttonCellCHS.upperText = mutableAttributedStringFromString("CHS", color: NSColor.whiteColor())
		
		// Label RTN
		labelRTN.attributedStringValue = mutableAttributedStringFromString("RTN", color: nil)
		
		// Button EEX
		buttonCellEEX.upperText = mutableAttributedStringFromString("EEX", color: NSColor.whiteColor())
		
		// Label CL X/A
		let TimesNewRoman11Font = NSFont(name: "Times New Roman", size: 11.0)
		if let actualFont = TimesNewRoman11Font {
			let clxaString = mutableAttributedStringFromString("CL X/A", color: nil)
			let clxaAttributes = [
				NSFontAttributeName : actualFont
			]
			clxaString.addAttributes(clxaAttributes, range: NSMakeRange(3, 1))
			labelCLXA.attributedStringValue = clxaString
		}
		
		// Button Back
		let Helvetica11Font = NSFont(name: "Helvetica", size: 11.0)
		if let actualFont = Helvetica11Font {
			let backString = mutableAttributedStringFromString("←", color: NSColor.whiteColor())
			let backAttributes = [
				NSFontAttributeName : actualFont
			]
			backString.addAttributes(backAttributes, range: NSMakeRange(0, 1))
			buttonCellBack.upperText = backString
		}
		
		// Label x=y ?
		if let actualFont = TimesNewRoman14Font {
			let xeqyString = mutableAttributedStringFromString("x=y ?", color: nil)
			let xeqyAttributes = [
				NSFontAttributeName : actualFont
			]
			xeqyString.addAttributes(xeqyAttributes, range: NSMakeRange(0, 3))
			labelXEQY.attributedStringValue = xeqyString
		}
		
		// Button Minus
		let Helvetica09Font = NSFont(name: "Helvetica", size: 9.0)
		if let actualFont = Helvetica09Font {
			let minusString = mutableAttributedStringFromString("━", color: NSColor.whiteColor())
			let minusAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			minusString.addAttributes(minusAttributes, range: NSMakeRange(0, 1))
			buttonCellMinus.upperText = minusString
		}
		
		// Label x≤y ?
		let TimesNewRoman13Font = NSFont(name: "Times New Roman", size: 13.0)
		if let actualFont = TimesNewRoman13Font {
			let xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: nil)
			let xlessthanyAttributes = [
				NSFontAttributeName : actualFont
			]
			xlessthanyString.addAttributes(xlessthanyAttributes, range: NSMakeRange(0, 3))
			labelXLessThanY.attributedStringValue = xlessthanyString
		}
		
		// Button Plus
		if let actualFont = Helvetica09Font {
			let plusString = mutableAttributedStringFromString("╋", color: NSColor.whiteColor())
			let plusAttributes = [
				NSFontAttributeName : actualFont
			]
			plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
			buttonCellPlus.upperText = plusString
		}
		
		// Label x≥y ?
		if let actualFont = TimesNewRoman13Font {
			let xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: nil)
			let xgreaterthanyAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			xgreaterthanyString.addAttributes(xgreaterthanyAttributes, range: NSMakeRange(0, 3))
			labelXGreaterThanY.attributedStringValue = xgreaterthanyString
		}
		
		// Button Multiply
		let Helvetica15Font = NSFont(name: "Helvetica", size: 15.0)
		if let actualFont = Helvetica15Font {
			let multiplyString = mutableAttributedStringFromString("×", color: NSColor.whiteColor())
			let multiplyAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
			buttonCellMultiply.upperText = multiplyString
		}
		
		// Label x=0 ?
		if let actualFont = TimesNewRoman13Font {
			let xeq0String = mutableAttributedStringFromString("x=0 ?", color: nil)
			let xeq0Attributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			xeq0String.addAttributes(xeq0Attributes, range: NSMakeRange(0, 5))
			labelXEQ0.attributedStringValue = xeq0String
		}
		
		// Button Divide
		if let actualFont = Helvetica15Font {
			let divideString = mutableAttributedStringFromString("÷", color: NSColor.whiteColor())
			let divideAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			divideString.addAttributes(divideAttributes, range: NSMakeRange(0, 1))
			buttonCellDivide.upperText = divideString
		}

		// Label SF
		labelSF.attributedStringValue = mutableAttributedStringFromString("SF", color: nil)
		
		// Button 7
		if let actualFont = Helvetica13Font {
			let sevenString = mutableAttributedStringFromString("7", color: NSColor.whiteColor())
			let sevenAttributes = [
				NSFontAttributeName : actualFont
			]
			sevenString.addAttributes(sevenAttributes, range: NSMakeRange(0, 1))
			buttonCell7.upperText = sevenString
		}
		
		// Label CF
		labelCF.attributedStringValue = mutableAttributedStringFromString("CF", color: nil)
		
		// Button 8
		if let actualFont = Helvetica13Font {
			let eightString = mutableAttributedStringFromString("8", color: NSColor.whiteColor())
			let eightAttributes = [
				NSFontAttributeName : actualFont
			]
			eightString.addAttributes(eightAttributes, range: NSMakeRange(0, 1))
			buttonCell8.upperText = eightString
		}
		
		// Label FS?
		labelFS.attributedStringValue = mutableAttributedStringFromString("FS?", color: nil)
		
		// Button 9
		if let actualFont = Helvetica13Font {
			let nineString = mutableAttributedStringFromString("9", color: NSColor.whiteColor())
			let nineAttributes = [
				NSFontAttributeName : actualFont
			]
			nineString.addAttributes(nineAttributes, range: NSMakeRange(0, 1))
			buttonCell9.upperText = nineString
		}
		
		// Label BEEP
		labelBEEP.attributedStringValue = mutableAttributedStringFromString("BEEP", color: nil)
		
		// Button 4
		if let actualFont = Helvetica13Font {
			let fourString = mutableAttributedStringFromString("4", color: NSColor.whiteColor())
			let fourAttributes = [
				NSFontAttributeName : actualFont
			]
			fourString.addAttributes(fourAttributes, range: NSMakeRange(0, 1))
			buttonCell4.upperText = fourString
		}
		
		// Label P→R
		labelPR.attributedStringValue = mutableAttributedStringFromString("P→R", color: nil)
		
		// Button 5
		if let actualFont = Helvetica13Font {
			let fiveString = mutableAttributedStringFromString("5", color: NSColor.whiteColor())
			let fiveAttributes = [
				NSFontAttributeName : actualFont
			]
			fiveString.addAttributes(fiveAttributes, range: NSMakeRange(0, 1))
			buttonCell5.upperText = fiveString
		}
		
		// Label R→P
		labelRP.attributedStringValue = mutableAttributedStringFromString("R→P", color: nil)
		
		// Button 6
		if let actualFont = Helvetica13Font {
			let sixString = mutableAttributedStringFromString("6", color: NSColor.whiteColor())
			let sixAttributes = [
				NSFontAttributeName : actualFont
			]
			sixString.addAttributes(sixAttributes, range: NSMakeRange(0, 1))
			buttonCell6.upperText = sixString
		}
		
		// Label FIX
		labelFIX.attributedStringValue = mutableAttributedStringFromString("FIX", color: nil)
		
		// Button 1
		if let actualFont = Helvetica13Font {
			let oneString = mutableAttributedStringFromString("1", color: NSColor.whiteColor())
			let oneAttributes = [
				NSFontAttributeName : actualFont
			]
			oneString.addAttributes(oneAttributes, range: NSMakeRange(0, 1))
			buttonCell1.upperText = oneString
		}
		
		// Label SCI
		labelSCI.attributedStringValue = mutableAttributedStringFromString("SCI", color: nil)
		
		// Button 2
		if let actualFont = Helvetica13Font {
			let twoString = mutableAttributedStringFromString("2", color: NSColor.whiteColor())
			let twoAttributes = [
				NSFontAttributeName : actualFont
			]
			twoString.addAttributes(twoAttributes, range: NSMakeRange(0, 1))
			buttonCell2.upperText = twoString
		}
		
		// Label ENG
		labelENG.attributedStringValue = mutableAttributedStringFromString("ENG", color: nil)
		
		// Button 3
		if let actualFont = Helvetica13Font {
			let thtreeString = mutableAttributedStringFromString("3", color: NSColor.whiteColor())
			let thtreeAttributes = [
				NSFontAttributeName : actualFont
			]
			thtreeString.addAttributes(thtreeAttributes, range: NSMakeRange(0, 1))
			buttonCell3.upperText = thtreeString
		}
		
		// Label PI
		let TimesNewRoman15Font = NSFont(name: "Times New Roman", size: 15.0)
		if let actualFont = TimesNewRoman15Font {
			let piString = mutableAttributedStringFromString("π", color: nil)
			let piAttributes = [
				NSFontAttributeName : actualFont
			]
			piString.addAttributes(piAttributes, range: NSMakeRange(0, 1))
			labelPI.attributedStringValue = piString
		}
		
		// Button 0
		if let actualFont = Helvetica13Font {
			let zeroString = mutableAttributedStringFromString("0", color: NSColor.whiteColor())
			let zeroAttributes = [
				NSFontAttributeName : actualFont
			]
			zeroString.addAttributes(zeroAttributes, range: NSMakeRange(0, 1))
			buttonCell0.upperText = zeroString
		}
		
		// Label LAST X
		if let actualFont = TimesNewRoman13Font {
			let lastxString = mutableAttributedStringFromString("LAST X", color: nil)
			let lastxAttributes = [
				NSFontAttributeName : actualFont
			]
			lastxString.addAttributes(lastxAttributes, range: NSMakeRange(5, 1))
			labelLASTX.attributedStringValue = lastxString
		}
		
		// Button •
		if let actualFont = Helvetica13Font {
			let pointString = mutableAttributedStringFromString("•", color: NSColor.whiteColor())
			let pointAttributes = [
				NSFontAttributeName : actualFont
			]
			pointString.addAttributes(pointAttributes, range: NSMakeRange(0, 1))
			buttonCellPoint.upperText = pointString
		}
		
		// Label VIEW
		labelVIEW.attributedStringValue = mutableAttributedStringFromString("VIEW", color: nil)
		
		// Button R/S
		if let actualFont = Helvetica12Font {
			let rsString = mutableAttributedStringFromString("R/S", color: NSColor.whiteColor())
			let rsAttributes = [
				NSFontAttributeName : actualFont
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
			case CalculatorType.HP41C:
				calculatorLabel.stringValue = "my41C"
			case CalculatorType.HP41CV:
				calculatorLabel.stringValue = "my41CV"
			case CalculatorType.HP41CX:
				calculatorLabel.stringValue = "my41CX"
			}
		}
	}

	override var representedObject: AnyObject? {
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
					attributes: [NSFontAttributeName : actualFont,
						NSForegroundColorAttributeName: aColor
					]
				)
			} else {
				return NSMutableAttributedString(string: aString,
					attributes: [NSFontAttributeName : actualFont
					]
				)
			}
		} else {
			return NSMutableAttributedString()
		}
	}
	
	override var acceptsFirstResponder: Bool { return true }

	@IBAction func keyPressed(sender: AnyObject) {
		let key = sender as! Key
		let keyCode = key.keyCode! as Int
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

class KeyboardView : NSView {
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let color = NSColor(calibratedRed: 0.604, green: 0.467, blue: 0.337, alpha: 1)
		
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.moveToPoint(NSMakePoint(5, 0))
		bezierPath.lineToPoint(NSMakePoint(self.bounds.width - 5.0, 0))
		bezierPath.curveToPoint(NSMakePoint(self.bounds.width - 5.0, self.bounds.height), controlPoint1: NSMakePoint(self.bounds.width, self.bounds.height / 2.0), controlPoint2: NSMakePoint(self.bounds.width - 5.0, self.bounds.height))
		bezierPath.lineToPoint(NSMakePoint(5, self.bounds.height))
		bezierPath.curveToPoint(NSMakePoint(5, 0), controlPoint1: NSMakePoint(0, self.bounds.height / 2.0), controlPoint2: NSMakePoint(5, 0))
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
		self.setNeedsDisplayInRect(rect)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayOff", name: "displayOff", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayToggle", name: "displayToggle", object: nil)
	}
	
	override var acceptsFirstResponder: Bool { return true }
	
	override func keyDown(theEvent: NSEvent) {
		if pressedKey == nil {
			if let theButton = getKey(theEvent) {
				pressedKey = theButton
				theButton.downKey()
				theButton.highlight(true)
			}
		}
	}
	
	override func keyUp(theEvent: NSEvent) {
		if let theButton = pressedKey {
			theButton.upKey()
			theButton.highlight(false)
			pressedKey = nil
		}
	}
	
	func displayOff() {
		lcdDisplay.displayOff()
	}
	
	func displayToggle() {
		lcdDisplay.displayToggle()
	}
	
	func getKey(theEvent: NSEvent) -> Key? {
		let char = theEvent.charactersIgnoringModifiers
		let hasCommand = (theEvent.modifierFlags.intersect(.CommandKeyMask)).rawValue != 0
		let hasAlt = (theEvent.modifierFlags.intersect(.AlternateKeyMask)).rawValue != 0
		
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
