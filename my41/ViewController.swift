//
//  ViewController.swift
//  i41CV
//
//  Created by Miroslav Perovic on 7/30/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
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
	
	override func viewWillAppear() {
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
			var sigmaMinusString = mutableAttributedStringFromString("Σ-", color: nil)
			let sigmaMinusAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedStringValue = sigmaMinusString
		}
		
		// Button Σ+
		var sigmaPlusString = mutableAttributedStringFromString("Σ+", color: NSColor.whiteColor())
		let sigmaPlusAttributes = [
			NSBaselineOffsetAttributeName: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonCellSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		let TimesNewRoman10Font = NSFont(name: "Times New Roman", size: 10.0)
		if let actualFont = TimesNewRoman10Font {
			var yxString = mutableAttributedStringFromString("yx", color: nil)
			let yxAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
			labelYX.attributedStringValue = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman10Font {
			var oneXString = mutableAttributedStringFromString("1/x", color: NSColor.whiteColor())
			let oneXAttributes = [
				NSFontAttributeName : actualFont,
			]
			oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
			buttonCellOneX.upperText = oneXString
		}
		
		// Label x^2
		let TimesNewRoman12Font = NSFont(name: "Times New Roman", size: 12.0)
		if let actualFont = TimesNewRoman12Font {
			var xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: nil)
			let xSquareAttributes = [
				NSFontAttributeName : actualFont,
			]
			xSquareString.addAttributes(xSquareAttributes, range: NSMakeRange(0, 2))
			labelXSquare.attributedStringValue = xSquareString
		}
		
		// Button √x
		if let actualFont = TimesNewRoman10Font {
			var rootXString = mutableAttributedStringFromString("√x\u{0304}", color: NSColor.whiteColor())
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
			var tenXString = mutableAttributedStringFromString("10x", color: nil)
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
			var eXString = mutableAttributedStringFromString("ex", color: nil)
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
			var XexYString = mutableAttributedStringFromString("x≷y", color: NSColor.whiteColor())
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
			var sin1String = mutableAttributedStringFromString("SIN-1", color: nil)
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
			var cos1String = mutableAttributedStringFromString("COS-1", color: nil)
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
			var tan1String = mutableAttributedStringFromString("TAN-1", color: nil)
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
		
		// Button RCL
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
			var clxaString = mutableAttributedStringFromString("CL X/A", color: nil)
			let clxaAttributes = [
				NSFontAttributeName : actualFont
			]
			clxaString.addAttributes(clxaAttributes, range: NSMakeRange(3, 1))
			labelCLXA.attributedStringValue = clxaString
		}
		
		// Button Back
		let Helvetica11Font = NSFont(name: "Helvetica", size: 11.0)
		if let actualFont = Helvetica11Font {
			var backString = mutableAttributedStringFromString("←", color: NSColor.whiteColor())
			let backAttributes = [
				NSFontAttributeName : actualFont
			]
			backString.addAttributes(backAttributes, range: NSMakeRange(0, 1))
			buttonCellBack.upperText = backString
		}
		
		// Label x=y ?
		if let actualFont = TimesNewRoman14Font {
			var xeqyString = mutableAttributedStringFromString("x=y ?", color: nil)
			let xeqyAttributes = [
				NSFontAttributeName : actualFont
			]
			xeqyString.addAttributes(xeqyAttributes, range: NSMakeRange(0, 3))
			labelXEQY.attributedStringValue = xeqyString
		}
		
		// Button Minus
		let Helvetica09Font = NSFont(name: "Helvetica", size: 9.0)
		if let actualFont = Helvetica09Font {
			var minusString = mutableAttributedStringFromString("━", color: NSColor.whiteColor())
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
			var xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: nil)
			let xlessthanyAttributes = [
				NSFontAttributeName : actualFont
			]
			xlessthanyString.addAttributes(xlessthanyAttributes, range: NSMakeRange(0, 3))
			labelXLessThanY.attributedStringValue = xlessthanyString
		}
		
		// Button Plus
		if let actualFont = Helvetica09Font {
			var plusString = mutableAttributedStringFromString("╋", color: NSColor.whiteColor())
			let plusAttributes = [
				NSFontAttributeName : actualFont
			]
			plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
			buttonCellPlus.upperText = plusString
		}
		
		// Label x≥y ?
		if let actualFont = TimesNewRoman13Font {
			var xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: nil)
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
			var multiplyString = mutableAttributedStringFromString("×", color: NSColor.whiteColor())
			let multiplyAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
			buttonCellMultiply.upperText = multiplyString
		}
		
		// Label x=0 ?
		if let actualFont = TimesNewRoman13Font {
			var xeq0String = mutableAttributedStringFromString("x=0 ?", color: nil)
			let xeq0Attributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			xeq0String.addAttributes(xeq0Attributes, range: NSMakeRange(0, 5))
			labelXEQ0.attributedStringValue = xeq0String
		}
		
		// Button Divide
		if let actualFont = Helvetica15Font {
			var divideString = mutableAttributedStringFromString("÷", color: NSColor.whiteColor())
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
			var sevenString = mutableAttributedStringFromString("7", color: NSColor.whiteColor())
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
			var eightString = mutableAttributedStringFromString("8", color: NSColor.whiteColor())
			let eightAttributes = [
				NSFontAttributeName : actualFont
			]
			eightString.addAttributes(eightAttributes, range: NSMakeRange(0, 1))
			buttonCell8.upperText = eightString
		}
		
		// Label FS?
		labelFS.attributedStringValue = mutableAttributedStringFromString("FS?", color: nil)
		
		// Button 8
		if let actualFont = Helvetica13Font {
			var nineString = mutableAttributedStringFromString("9", color: NSColor.whiteColor())
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
			var fourString = mutableAttributedStringFromString("4", color: NSColor.whiteColor())
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
			var fiveString = mutableAttributedStringFromString("5", color: NSColor.whiteColor())
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
			var sixString = mutableAttributedStringFromString("6", color: NSColor.whiteColor())
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
			var oneString = mutableAttributedStringFromString("1", color: NSColor.whiteColor())
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
			var twoString = mutableAttributedStringFromString("2", color: NSColor.whiteColor())
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
			var thtreeString = mutableAttributedStringFromString("3", color: NSColor.whiteColor())
			let thtreeAttributes = [
				NSFontAttributeName : actualFont
			]
			thtreeString.addAttributes(thtreeAttributes, range: NSMakeRange(0, 1))
			buttonCell3.upperText = thtreeString
		}
		
		// Label PI
		let TimesNewRoman15Font = NSFont(name: "Times New Roman", size: 15.0)
		if let actualFont = TimesNewRoman15Font {
			var piString = mutableAttributedStringFromString("π", color: nil)
			let piAttributes = [
				NSFontAttributeName : actualFont
			]
			piString.addAttributes(piAttributes, range: NSMakeRange(0, 1))
			labelPI.attributedStringValue = piString
		}
		
		// Button 0
		if let actualFont = Helvetica13Font {
			var zeroString = mutableAttributedStringFromString("0", color: NSColor.whiteColor())
			let zeroAttributes = [
				NSFontAttributeName : actualFont
			]
			zeroString.addAttributes(zeroAttributes, range: NSMakeRange(0, 1))
			buttonCell0.upperText = zeroString
		}
		
		// Label LAST X
		if let actualFont = TimesNewRoman13Font {
			var lastxString = mutableAttributedStringFromString("LAST X", color: nil)
			let lastxAttributes = [
				NSFontAttributeName : actualFont
			]
			lastxString.addAttributes(lastxAttributes, range: NSMakeRange(5, 1))
			labelLASTX.attributedStringValue = lastxString
		}
		
		// Button •
		if let actualFont = Helvetica13Font {
			var pointString = mutableAttributedStringFromString("•", color: NSColor.whiteColor())
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
			var rsString = mutableAttributedStringFromString("R/S", color: NSColor.whiteColor())
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
}

class KeyboardView : NSView {
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let color = NSColor(calibratedRed: 0.604, green: 0.467, blue: 0.337, alpha: 1)
		
		//// Bezier Drawing
		var bezierPath = NSBezierPath()
		bezierPath.moveToPoint(NSMakePoint(5, 0))
		bezierPath.lineToPoint(NSMakePoint(261, 0))
		bezierPath.curveToPoint(NSMakePoint(261, 410), controlPoint1: NSMakePoint(266, 205), controlPoint2: NSMakePoint(261, 410))
		bezierPath.lineToPoint(NSMakePoint(5, 410))
		bezierPath.curveToPoint(NSMakePoint(5, 0), controlPoint1: NSMakePoint(0, 205), controlPoint2: NSMakePoint(5, 0))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()
	}
}

class CalculatorView: NSView {
	@IBOutlet weak var display: Display!
	
	override func awakeFromNib() {
		var rect: NSRect = self.bounds
		rect.origin.x = 0.0
		rect.origin.y = 0.0
		self.setNeedsDisplayInRect(rect)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayOff", name: "displayOff", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayToggle", name: "displayToggle", object: nil)
	}
	override func drawRect(dirtyRect: NSRect) {
		//// Color Declarations
		let color = NSColor(calibratedRed: 0.604, green: 0.467, blue: 0.337, alpha: 1)
		
		//// Bezier Drawing
		var bezierPath = NSBezierPath()
		bezierPath.moveToPoint(NSMakePoint(30, 148))
		bezierPath.curveToPoint(NSMakePoint(297, 148), controlPoint1: NSMakePoint(300.48, 148), controlPoint2: NSMakePoint(297, 148))
		bezierPath.lineToPoint(NSMakePoint(297, 562))
		bezierPath.lineToPoint(NSMakePoint(30, 562))
		bezierPath.lineToPoint(NSMakePoint(30, 148))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()
	}
	
	func displayOff() {
		display.displayOff()
	}
	
	func displayToggle() {
		display.displayToggle()
	}
}
