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
	@IBOutlet weak var buttonCellSigmaMinus: ButtonCell!
	@IBOutlet weak var labelYX: NSTextField!
	@IBOutlet weak var buttonCellOneX: ButtonCell!
	@IBOutlet weak var labelXSquare: NSTextField!
	@IBOutlet weak var buttonCellSquareRoot: ButtonCell!
	@IBOutlet weak var labelTenX: NSTextField!
	@IBOutlet weak var buttonCellLog: ButtonCell!
	@IBOutlet weak var labelEX: NSTextField!
	@IBOutlet weak var buttonCellLn: ButtonCell!
	@IBOutlet weak var labelCLSigma: NSTextField!
	@IBOutlet weak var buttonCellXexY: ButtonCell!
	@IBOutlet weak var labelPercent: NSTextField!
	@IBOutlet weak var buttonCellRArrrow: ButtonCell!
	@IBOutlet weak var labelSin: NSTextField!
	@IBOutlet weak var buttonCellSin: ButtonCell!
	@IBOutlet weak var labelCos: NSTextField!
	@IBOutlet weak var buttonCellCos: ButtonCell!
	@IBOutlet weak var labelTan: NSTextField!
	@IBOutlet weak var buttonCellTan: ButtonCell!
	@IBOutlet weak var buttonCellShift: ButtonCell!
	@IBOutlet weak var labelASN: NSTextField!
	@IBOutlet weak var buttonCellXEQ: ButtonCell!
	@IBOutlet weak var labelLBL: NSTextField!
	@IBOutlet weak var buttonCellSTO: ButtonCell!
	@IBOutlet weak var labelGTO: NSTextField!
	@IBOutlet weak var buttonCellRCL: ButtonCell!
	@IBOutlet weak var labelBST: NSTextField!
	@IBOutlet weak var buttonCellSST: ButtonCell!
	@IBOutlet weak var labelCATALOG: NSTextField!
	@IBOutlet weak var buttonCellENTER: ButtonCell!
	@IBOutlet weak var labelISG: NSTextField!
	@IBOutlet weak var buttonCellCHS: ButtonCell!
	@IBOutlet weak var labelRTN: NSTextField!
	@IBOutlet weak var buttonCellEEX: ButtonCell!
	@IBOutlet weak var labelCLXA: NSTextField!
	@IBOutlet weak var buttonCellBack: ButtonCell!
	@IBOutlet weak var labelXEQY: NSTextField!
	@IBOutlet weak var buttonCellMinus: ButtonCell!
	@IBOutlet weak var labelXLessThanY: NSTextField!
	@IBOutlet weak var buttonCellPlus: ButtonCell!
	@IBOutlet weak var labelXGreaterThanY: NSTextField!
	@IBOutlet weak var buttonCellMultiply: ButtonCell!
	@IBOutlet weak var labelXEQ0: NSTextField!
	@IBOutlet weak var buttonCellDivide: ButtonCell!
	
	@IBOutlet weak var labelSF: NSTextField!
	@IBOutlet weak var buttonCell7: ButtonCell!
	@IBOutlet weak var labelCF: NSTextField!
	@IBOutlet weak var buttonCell8: ButtonCell!
	@IBOutlet weak var labelFS: NSTextField!
	@IBOutlet weak var buttonCell9: ButtonCell!
	@IBOutlet weak var labelBEEP: NSTextField!
	@IBOutlet weak var buttonCell4: ButtonCell!
	@IBOutlet weak var labelPR: NSTextField!
	@IBOutlet weak var buttonCell5: ButtonCell!
	@IBOutlet weak var labelRP: NSTextField!
	@IBOutlet weak var buttonCell6: ButtonCell!
	@IBOutlet weak var labelFIX: NSTextField!
	@IBOutlet weak var buttonCell1: ButtonCell!
	@IBOutlet weak var labelSCI: NSTextField!
	@IBOutlet weak var buttonCell2: ButtonCell!
	@IBOutlet weak var labelENG: NSTextField!
	@IBOutlet weak var buttonCell3: ButtonCell!
	@IBOutlet weak var labelPI: NSTextField!
	@IBOutlet weak var buttonCell0: ButtonCell!
	@IBOutlet weak var labelLASTX: NSTextField!
	@IBOutlet weak var buttonCellPoint: ButtonCell!
	@IBOutlet weak var labelVIEW: NSTextField!
	@IBOutlet weak var buttonCellRS: ButtonCell!
	
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
		var sigmaMinusString = mutableAttributedStringFromString("Σ-", color: nil)
		let sigmaMinusAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0),
			NSBaselineOffsetAttributeName: 1
		]
		sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
		labelSigmaMinus.attributedStringValue = sigmaMinusString
		
		// Button Σ+
		var sigmaPlusString = mutableAttributedStringFromString("Σ+", color: NSColor.whiteColor())
		let sigmaPlusAttributes = [
			NSBaselineOffsetAttributeName: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonCellSigmaMinus.upperText = sigmaPlusString
		
		// Label yx
		var yxString = mutableAttributedStringFromString("yx", color: nil)
		let yxAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 10.0),
			NSBaselineOffsetAttributeName: 4
		]
		yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
		labelYX.attributedStringValue = yxString
		
		// Button 1/x
		var oneXString = mutableAttributedStringFromString("1/x", color: NSColor.whiteColor())
		let oneXAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 10.0),
		]
		oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
		buttonCellOneX.upperText = oneXString
		
		// Label x^2
		var xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: nil)
		let xSquareAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 12.0),
		]
		xSquareString.addAttributes(xSquareAttributes, range: NSMakeRange(0, 2))
		labelXSquare.attributedStringValue = xSquareString
		
		// Button √x
		var rootXString = mutableAttributedStringFromString("√x\u{0304}", color: NSColor.whiteColor())
		let rootXAttributes1 = [
			NSBaselineOffsetAttributeName: 1
		]
		rootXString.addAttributes(rootXAttributes1, range: NSMakeRange(2, 1))
		let rootXAttributes2 = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 10.0),
		]
		rootXString.addAttributes(rootXAttributes2, range: NSMakeRange(1, 1))
		buttonCellSquareRoot.upperText = rootXString
		
		// Label 10^x
		var tenXString = mutableAttributedStringFromString("10x", color: nil)
		let tenXAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 10.0),
			NSBaselineOffsetAttributeName: 4
		]
		tenXString.addAttributes(tenXAttributes, range: NSMakeRange(2, 1))
		labelTenX.attributedStringValue = tenXString
		
		// Button LOG
		buttonCellLog.upperText = mutableAttributedStringFromString("LOG", color: NSColor.whiteColor())
		
		// Label e^x
		var eXString = mutableAttributedStringFromString("ex", color: nil)
		let eXAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 10.0),
			NSBaselineOffsetAttributeName: 4
		]
		eXString.addAttributes(eXAttributes, range: NSMakeRange(1, 1))
		let eXAttributes2 = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 12.0)
		]
		eXString.addAttributes(eXAttributes2, range: NSMakeRange(0, 1))
		labelEX.attributedStringValue = eXString
		
		// Button LN
		buttonCellLn.upperText = mutableAttributedStringFromString("LN", color: NSColor.whiteColor())
		
		// Label CLΣ
		labelCLSigma.attributedStringValue = mutableAttributedStringFromString("CLΣ", color: nil)
		
		// Button x≷y
		var XexYString = mutableAttributedStringFromString("x≷y", color: NSColor.whiteColor())
		let XexYAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 14.0),
			NSBaselineOffsetAttributeName: 1
		]
		XexYString.addAttributes(XexYAttributes, range: NSMakeRange(0, 3))
		buttonCellXexY.upperText = XexYString
		
		// Label %
		labelPercent.attributedStringValue = mutableAttributedStringFromString("%", color: nil)
		
		// Button R↓
		buttonCellRArrrow.upperText = mutableAttributedStringFromString("R↓", color: NSColor.whiteColor())
		
		// Label SIN-1
		var sin1String = mutableAttributedStringFromString("SIN-1", color: nil)
		let sinAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 9.0),
			NSBaselineOffsetAttributeName: 4
		]
		sin1String.addAttributes(sinAttributes, range: NSMakeRange(3, 2))
		labelSin.attributedStringValue = sin1String
		
		// Button SIN
		buttonCellSin.upperText = mutableAttributedStringFromString("SIN", color: NSColor.whiteColor())
		
		// Label COS-1
		var cos1String = mutableAttributedStringFromString("COS-1", color: nil)
		let cosAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 9.0),
			NSBaselineOffsetAttributeName: 4
		]
		cos1String.addAttributes(cosAttributes, range: NSMakeRange(3, 2))
		labelCos.attributedStringValue = cos1String
		
		// Button COS
		buttonCellCos.upperText = mutableAttributedStringFromString("COS", color: NSColor.whiteColor())
		
		// Label TAN-1
		var tan1String = mutableAttributedStringFromString("TAN-1", color: nil)
		let tanAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 9.0),
			NSBaselineOffsetAttributeName: 4
		]
		tan1String.addAttributes(tanAttributes, range: NSMakeRange(3, 2))
		labelTan.attributedStringValue = tan1String
		
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
		var clxaString = mutableAttributedStringFromString("CL X/A", color: nil)
		let clxaAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 11.0),
		]
		clxaString.addAttributes(clxaAttributes, range: NSMakeRange(3, 1))
		labelCLXA.attributedStringValue = clxaString
		
		// Button Back
		var backString = mutableAttributedStringFromString("←", color: NSColor.whiteColor())
		let backAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 11.0)
		]
		backString.addAttributes(backAttributes, range: NSMakeRange(0, 1))
		buttonCellBack.upperText = backString
		
		// Label x=y ?
		var xeqyString = mutableAttributedStringFromString("x=y ?", color: nil)
		let xeqyAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 14.0),
		]
		xeqyString.addAttributes(xeqyAttributes, range: NSMakeRange(0, 3))
		labelXEQY.attributedStringValue = xeqyString
		
		// Button Minus
		var minusString = mutableAttributedStringFromString("━", color: NSColor.whiteColor())
		let minusAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 9.0),
			NSBaselineOffsetAttributeName: -1
		]
		minusString.addAttributes(minusAttributes, range: NSMakeRange(0, 1))
		buttonCellMinus.upperText = minusString
		
		// Label x≤y ?
		var xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: nil)
		let xlessthanyAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 13.0)
		]
		xlessthanyString.addAttributes(xlessthanyAttributes, range: NSMakeRange(0, 3))
		labelXLessThanY.attributedStringValue = xlessthanyString
		
		// Button Plus
		var plusString = mutableAttributedStringFromString("╋", color: NSColor.whiteColor())
		let plusAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 9.0)
		]
		plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
		buttonCellPlus.upperText = plusString
		
		// Label x≥y ?
		var xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: nil)
		let xgreaterthanyAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 13.0),
			NSBaselineOffsetAttributeName: -1
		]
		xgreaterthanyString.addAttributes(xgreaterthanyAttributes, range: NSMakeRange(0, 3))
		labelXGreaterThanY.attributedStringValue = xgreaterthanyString
		
		// Button Multiply
		var multiplyString = mutableAttributedStringFromString("×", color: NSColor.whiteColor())
		let multiplyAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 15.0),
			NSBaselineOffsetAttributeName: 1
		]
		multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
		buttonCellMultiply.upperText = multiplyString
		
		// Label x=0 ?
		var xeq0String = mutableAttributedStringFromString("x=0 ?", color: nil)
		let xeq0Attributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 13.0),
			NSBaselineOffsetAttributeName: -1
		]
		xeq0String.addAttributes(xeq0Attributes, range: NSMakeRange(0, 5))
		labelXEQ0.attributedStringValue = xeq0String
		
		// Button Divide
		var divideString = mutableAttributedStringFromString("÷", color: NSColor.whiteColor())
		let divideAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 15.0),
			NSBaselineOffsetAttributeName: 1
		]
		divideString.addAttributes(divideAttributes, range: NSMakeRange(0, 1))
		buttonCellDivide.upperText = divideString
		
		
		// Label SF
		labelSF.attributedStringValue = mutableAttributedStringFromString("SF", color: nil)
		
		// Button 7
		var sevenString = mutableAttributedStringFromString("7", color: NSColor.whiteColor())
		let sevenAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		sevenString.addAttributes(sevenAttributes, range: NSMakeRange(0, 1))
		buttonCell7.upperText = sevenString
		
		// Label CF
		labelCF.attributedStringValue = mutableAttributedStringFromString("CF", color: nil)
		
		// Button 8
		var eightString = mutableAttributedStringFromString("8", color: NSColor.whiteColor())
		let eightAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		eightString.addAttributes(eightAttributes, range: NSMakeRange(0, 1))
		buttonCell8.upperText = eightString
		
		// Label FS?
		labelCF.attributedStringValue = mutableAttributedStringFromString("FS?", color: nil)
		
		// Button 8
		var nineString = mutableAttributedStringFromString("9", color: NSColor.whiteColor())
		let nineAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		nineString.addAttributes(nineAttributes, range: NSMakeRange(0, 1))
		buttonCell9.upperText = nineString
		
		// Label BEEP
		labelBEEP.attributedStringValue = mutableAttributedStringFromString("BEEP", color: nil)
		
		// Button 4
		var fourString = mutableAttributedStringFromString("4", color: NSColor.whiteColor())
		let fourAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		fourString.addAttributes(fourAttributes, range: NSMakeRange(0, 1))
		buttonCell4.upperText = fourString
		
		// Label P→R
		labelPR.attributedStringValue = mutableAttributedStringFromString("P→R", color: nil)
		
		// Button 5
		var fiveString = mutableAttributedStringFromString("5", color: NSColor.whiteColor())
		let fiveAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		fiveString.addAttributes(fiveAttributes, range: NSMakeRange(0, 1))
		buttonCell5.upperText = fiveString
		
		// Label R→P
		labelRP.attributedStringValue = mutableAttributedStringFromString("R→P", color: nil)
		
		// Button 6
		var sixString = mutableAttributedStringFromString("6", color: NSColor.whiteColor())
		let sixAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		sixString.addAttributes(sixAttributes, range: NSMakeRange(0, 1))
		buttonCell6.upperText = sixString
		
		// Label FIX
		labelFIX.attributedStringValue = mutableAttributedStringFromString("FIX", color: nil)
		
		// Button 1
		var oneString = mutableAttributedStringFromString("1", color: NSColor.whiteColor())
		let oneAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		oneString.addAttributes(oneAttributes, range: NSMakeRange(0, 1))
		buttonCell1.upperText = oneString
		
		// Label SCI
		labelSCI.attributedStringValue = mutableAttributedStringFromString("SCI", color: nil)
		
		// Button 2
		var twoString = mutableAttributedStringFromString("2", color: NSColor.whiteColor())
		let twoAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		twoString.addAttributes(twoAttributes, range: NSMakeRange(0, 1))
		buttonCell2.upperText = twoString
		
		// Label ENG
		labelENG.attributedStringValue = mutableAttributedStringFromString("ENG", color: nil)
		
		// Button 3
		var thtreeString = mutableAttributedStringFromString("3", color: NSColor.whiteColor())
		let thtreeAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		thtreeString.addAttributes(thtreeAttributes, range: NSMakeRange(0, 1))
		buttonCell3.upperText = thtreeString
		
		// Label PI
		var piString = mutableAttributedStringFromString("π", color: nil)
		let piAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 15.0)
		]
		piString.addAttributes(piAttributes, range: NSMakeRange(0, 1))
		labelPI.attributedStringValue = piString
		
		// Button 0
		var zeroString = mutableAttributedStringFromString("0", color: NSColor.whiteColor())
		let zeroAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		zeroString.addAttributes(zeroAttributes, range: NSMakeRange(0, 1))
		buttonCell0.upperText = zeroString
		
		// Label LAST X
		var lastxString = mutableAttributedStringFromString("LAST X", color: nil)
		let lastxAttributes = [
			NSFontAttributeName : NSFont(name: "Times New Roman", size: 13.0)
		]
		lastxString.addAttributes(lastxAttributes, range: NSMakeRange(5, 1))
		labelLASTX.attributedStringValue = lastxString
		
		// Button •
		var pointString = mutableAttributedStringFromString("•", color: NSColor.whiteColor())
		let pointAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0)
		]
		pointString.addAttributes(pointAttributes, range: NSMakeRange(0, 1))
		buttonCellPoint.upperText = pointString
		
		// Label VIEW
		labelVIEW.attributedStringValue = mutableAttributedStringFromString("VIEW", color: nil)
		
		// Button R/S
		var rsString = mutableAttributedStringFromString("R/S", color: NSColor.whiteColor())
		let rsAttributes = [
			NSFontAttributeName : NSFont(name: "Helvetica", size: 12.0)
		]
		rsString.addAttributes(rsAttributes, range: NSMakeRange(0, 3))
		buttonCellRS.upperText = rsString
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
		if let aColor = color {
			return NSMutableAttributedString(
				string: aString,
				attributes: [NSFontAttributeName : NSFont(name: "Helvetica", size: 11.0),
					NSForegroundColorAttributeName: aColor
				]
			)
		} else {
			return NSMutableAttributedString(string: aString,
				attributes: [NSFontAttributeName : NSFont(name: "Helvetica", size: 11.0)
				]
			)
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
//		bezierPath.lineToPoint(NSMakePoint(261, 415))
		bezierPath.lineToPoint(NSMakePoint(5, 410))
//		bezierPath.lineToPoint(NSMakePoint(5, 0))
		bezierPath.curveToPoint(NSMakePoint(5, 0), controlPoint1: NSMakePoint(0, 205), controlPoint2: NSMakePoint(5, 0))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()

	}
}

class CalculatorView: NSView {
	override func awakeFromNib() {
		var rect: NSRect = self.bounds
		rect.origin.x = 0.0
		rect.origin.y = 0.0
		self.setNeedsDisplayInRect(rect)
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
}
