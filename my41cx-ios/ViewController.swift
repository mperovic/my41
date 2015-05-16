//
//  ViewController.swift
//  my41cx-ios
//
//  Created by Miroslav Perovic on 1/10/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import UIKit

class iOSViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	typealias theEvent = UIEvent
	
	@IBOutlet weak var displayBackgroundView: UIView!
	
	@IBOutlet weak var buttonOn: Key!
	@IBOutlet weak var buttonUSER: Key!
	@IBOutlet weak var buttonPRGM: Key!
	@IBOutlet weak var buttonALPHA: Key!
	
	@IBOutlet weak var labelSigmaMinus: UILabel!
	@IBOutlet weak var buttonSigmaPlus: Key!
	@IBOutlet weak var labelYX: UILabel!
	@IBOutlet weak var buttonOneX: Key!
	@IBOutlet weak var labelXSquare: UILabel!
	@IBOutlet weak var buttonSquareRoot: Key!
	@IBOutlet weak var labelTenX: UILabel!
	@IBOutlet weak var buttonLog: Key!
	@IBOutlet weak var labelEX: UILabel!
	@IBOutlet weak var buttonLn: Key!
	@IBOutlet weak var labelCLSigma: UILabel!
	@IBOutlet weak var buttonXexY: Key!
	@IBOutlet weak var labelPercent: UILabel!
	@IBOutlet weak var buttonRArrrow: Key!
	@IBOutlet weak var labelSin: UILabel!
	@IBOutlet weak var buttonSin: Key!
	@IBOutlet weak var labelCos: UILabel!
	@IBOutlet weak var buttonCos: Key!
	@IBOutlet weak var labelTan: UILabel!
	@IBOutlet weak var buttonTan: Key!
	@IBOutlet weak var buttonShift: Key!
	@IBOutlet weak var labelASN: UILabel!
	@IBOutlet weak var buttonXEQ: Key!
	@IBOutlet weak var labelLBL: UILabel!
	@IBOutlet weak var buttonSTO: Key!
	@IBOutlet weak var labelGTO: UILabel!
	@IBOutlet weak var buttonRCL: Key!
	@IBOutlet weak var labelBST: UILabel!
	@IBOutlet weak var buttonSST: Key!
	@IBOutlet weak var labelCATALOG: UILabel!
	@IBOutlet weak var buttonENTER: Key!
	@IBOutlet weak var labelISG: UILabel!
	@IBOutlet weak var buttonCHS: Key!
	@IBOutlet weak var labelRTN: UILabel!
	@IBOutlet weak var buttonEEX: Key!
	@IBOutlet weak var labelCLXA: UILabel!
	@IBOutlet weak var buttonBack: Key!
	@IBOutlet weak var labelXEQY: UILabel!
	@IBOutlet weak var buttonMinus: Key!
	@IBOutlet weak var labelSF: UILabel!
	@IBOutlet weak var button7: Key!
	@IBOutlet weak var labelCF: UILabel!
	@IBOutlet weak var button8: Key!
	@IBOutlet weak var labelFS: UILabel!
	@IBOutlet weak var button9: Key!
	@IBOutlet weak var labelXLessThanY: UILabel!
	@IBOutlet weak var buttonPlus: Key!
	@IBOutlet weak var labelBEEP: UILabel!
	@IBOutlet weak var button4: Key!
	@IBOutlet weak var labelPR: UILabel!
	@IBOutlet weak var button5: Key!
	@IBOutlet weak var labelRP: UILabel!
	@IBOutlet weak var button6: Key!
	@IBOutlet weak var labelXGreaterThanY: UILabel!
	@IBOutlet weak var buttonMultiply: Key!
	@IBOutlet weak var labelFIX: UILabel!
	@IBOutlet weak var button1: Key!
	@IBOutlet weak var labelSCI: UILabel!
	@IBOutlet weak var button2: Key!
	@IBOutlet weak var labelENG: UILabel!
	@IBOutlet weak var button3: Key!
	@IBOutlet weak var labelXEQ0: UILabel!
	@IBOutlet weak var buttonDivide: Key!
	@IBOutlet weak var labelPI: UILabel!
	@IBOutlet weak var button0: Key!
	@IBOutlet weak var labelLASTX: UILabel!
	@IBOutlet weak var buttonPoint: Key!
	@IBOutlet weak var labelVIEW: UILabel!
	@IBOutlet weak var buttonRS: Key!
	
	@IBOutlet weak var my41CX: UIButton!
	
	var yRatio: CGFloat = 1.0
	var popoverController: UIPopoverController? = nil

	override func viewWillAppear(animated: Bool) {
		var aView = self.view as! CalculatorView
		aView.viewController = self
		
//		self.view.layer.cornerRadius = 6.0
		self.view.backgroundColor = UIColor(red: 0.221, green: 0.221, blue: 0.221, alpha: 1.0)
		
		displayBackgroundView.backgroundColor = UIColor.lightGrayColor()
		displayBackgroundView.layer.cornerRadius = 3.0
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let defaults = NSUserDefaults.standardUserDefaults()
		if defaults.boolForKey("firstRun") == false {
			defaults.setBool(true, forKey: "firstRun")
			defaults.setBool(false, forKey: "sound")
			SOUND = false
			defaults.synchronize()
		}
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		self.yRatio = self.view.bounds.size.height / 800.0
		
		my41CX.titleLabel?.font = UIFont(name: "Helvetica", size: 22.0 * yRatio)

		// Do any additional setup after loading the view, typically from a nib.
		let upperButtonsFont = UIFont(name: "Helvetica", size: 12.0)
		
		// ON
		var onString = mutableAttributedStringFromString("ON", color: UIColor.whiteColor())
		if let actualFont = upperButtonsFont {
			var onString = mutableAttributedStringFromString("ON", color: UIColor.whiteColor())
			let onAttributes = [
				NSFontAttributeName : actualFont,
			]
			onString.addAttributes(onAttributes, range: NSMakeRange(0, 2))
			buttonOn.upperText = onString
		}

		// USER
		var userString = mutableAttributedStringFromString("USER", color: UIColor.whiteColor())
		if let actualFont = upperButtonsFont {
			let userAttributes = [
				NSFontAttributeName : actualFont,
			]
			userString.addAttributes(userAttributes, range: NSMakeRange(0, 4))
			buttonUSER.upperText = userString
		}
		
		// PRGM
		var prgmString = mutableAttributedStringFromString("PRGM", color: UIColor.whiteColor())
		if let actualFont = upperButtonsFont {
			let prgmAttributes = [
				NSFontAttributeName : actualFont,
			]
			prgmString.addAttributes(prgmAttributes, range: NSMakeRange(0, 4))
			buttonPRGM.upperText = prgmString
		}
		
		// ALPHA
		var alphaString = mutableAttributedStringFromString("ALPHA", color: UIColor.whiteColor())
		if let actualFont = upperButtonsFont {
			let alphaAttributes = [
				NSFontAttributeName : actualFont,
			]
			alphaString.addAttributes(alphaAttributes, range: NSMakeRange(0, 5))
			buttonALPHA.upperText = alphaString
		}
		
		// Label Σ-
		let Helvetica13Font = UIFont(name: "Helvetica", size: 15.0 * yRatio)
		if let actualFont = Helvetica13Font {
			var sigmaMinusString = mutableAttributedStringFromString("Σ-", color: nil)
			let sigmaMinusAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			sigmaMinusString.addAttributes(sigmaMinusAttributes, range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedText = sigmaMinusString
		}
		
		// Button Σ+
		var sigmaPlusString = mutableAttributedStringFromString("Σ+", color: UIColor.whiteColor())
		let sigmaPlusAttributes = [
			NSBaselineOffsetAttributeName: 1
		]
		sigmaPlusString.addAttributes(sigmaPlusAttributes, range: NSMakeRange(1, 1))
		buttonSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		let TimesNewRoman10Font = UIFont(name: "Times New Roman", size: 12.0 * yRatio)
		if let actualFont = TimesNewRoman10Font {
			var yxString = mutableAttributedStringFromString("yx", color: nil)
			let yxAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			yxString.addAttributes(yxAttributes, range: NSMakeRange(1, 1))
			labelYX.attributedText = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman10Font {
			var oneXString = mutableAttributedStringFromString("1/x", color: UIColor.whiteColor())
			let oneXAttributes = [
				NSFontAttributeName : actualFont,
			]
			oneXString.addAttributes(oneXAttributes, range: NSMakeRange(2, 1))
			buttonOneX.upperText = oneXString
		}
		
		// Label x^2
		let TimesNewRoman12Font = UIFont(name: "Times New Roman", size: 14.0 * yRatio)
		if let actualFont = TimesNewRoman12Font {
			var xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: nil)
			let xSquareAttributes = [
				NSFontAttributeName : actualFont,
			]
			xSquareString.addAttributes(xSquareAttributes, range: NSMakeRange(0, 2))
			labelXSquare.attributedText = xSquareString
		}
		
		// Button √x
		if let actualFont = TimesNewRoman10Font {
			var rootXString = mutableAttributedStringFromString("√x", color: UIColor.whiteColor())
			let rootXAttributes2 = [
				NSFontAttributeName : actualFont,
			]
			rootXString.addAttributes(rootXAttributes2, range: NSMakeRange(1, 1))
			buttonSquareRoot.upperText = rootXString
			
			// Label 10^x
			if let actualFont = TimesNewRoman10Font {
				var tenXString = mutableAttributedStringFromString("10x", color: nil)
				let tenXAttributes = [
					NSFontAttributeName : actualFont,
					NSBaselineOffsetAttributeName: 4
				]
				tenXString.addAttributes(tenXAttributes, range: NSMakeRange(2, 1))
				labelTenX.attributedText = tenXString
			}
			
			// Button LOG
			buttonLog.upperText = mutableAttributedStringFromString("LOG", color: UIColor.whiteColor())
		}
		
		// Label e^x
		let Helvetica12Font = UIFont(name: "Helvetica", size: 14.0 * yRatio)
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
				labelEX.attributedText = eXString
			}
		}
		
		// Button LN
		buttonLn.upperText = mutableAttributedStringFromString("LN", color: UIColor.whiteColor())
		
		// Label CLΣ
		labelCLSigma.attributedText = mutableAttributedStringFromString("CLΣ", color: nil)
		
		// Button x≷y
		let TimesNewRoman14Font = UIFont(name: "Times New Roman", size: 16.0 * yRatio)
		if let actualFont = TimesNewRoman14Font {
			var XexYString = mutableAttributedStringFromString("x≷y", color: UIColor.whiteColor())
			let XexYAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			XexYString.addAttributes(XexYAttributes, range: NSMakeRange(0, 3))
			buttonXexY.upperText = XexYString
		}
		
		// Label %
		labelPercent.attributedText = mutableAttributedStringFromString("%", color: nil)
		
		// Button R↓
		buttonRArrrow.upperText = mutableAttributedStringFromString("R↓", color: UIColor.whiteColor())
		
		// Label SIN-1
		let TimesNewRoman09Font = UIFont(name: "Times New Roman", size: 11.0 * yRatio)
		if let actualFont = TimesNewRoman09Font {
			var sin1String = mutableAttributedStringFromString("SIN-1", color: nil)
			let sinAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			sin1String.addAttributes(sinAttributes, range: NSMakeRange(3, 2))
			labelSin.attributedText = sin1String
		}
		
		// Button SIN
		buttonSin.upperText = mutableAttributedStringFromString("SIN", color: UIColor.whiteColor())
		
		// Label COS-1
		if let actualFont = TimesNewRoman09Font {
			var cos1String = mutableAttributedStringFromString("COS-1", color: nil)
			let cosAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			cos1String.addAttributes(cosAttributes, range: NSMakeRange(3, 2))
			labelCos.attributedText = cos1String
		}
		
		// Button COS
		buttonCos.upperText = mutableAttributedStringFromString("COS", color: UIColor.whiteColor())
		
		// Label TAN-1
		if let actualFont = TimesNewRoman09Font {
			var tan1String = mutableAttributedStringFromString("TAN-1", color: nil)
			let tanAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 4
			]
			tan1String.addAttributes(tanAttributes, range: NSMakeRange(3, 2))
			labelTan.attributedText = tan1String
		}
		
		// Button TAN
		buttonTan.upperText = mutableAttributedStringFromString("TAN", color: UIColor.whiteColor())
		
		// Label ASN
		labelASN.attributedText = mutableAttributedStringFromString("ASN", color: nil)
		
		// Button XEQ
		buttonXEQ.upperText = mutableAttributedStringFromString("XEQ", color: UIColor.whiteColor())
		
		// Label LBL
		labelLBL.attributedText = mutableAttributedStringFromString("LBL", color: nil)
		
		// Button STO
		buttonSTO.upperText = mutableAttributedStringFromString("STO", color: UIColor.whiteColor())
		
		// Label GTO
		labelGTO.attributedText = mutableAttributedStringFromString("GTO", color: nil)
		
		// Button RCL
		buttonRCL.upperText = mutableAttributedStringFromString("RCL", color: UIColor.whiteColor())
		
		// Label BST
		labelBST.attributedText = mutableAttributedStringFromString("BST", color: nil)
		
		// Button SST
		buttonSST.upperText = mutableAttributedStringFromString("SST", color: UIColor.whiteColor())
		
		// Label CATALOG
		labelCATALOG.attributedText = mutableAttributedStringFromString("CATALOG", color: nil)
		
		// Button ENTER
		buttonENTER.upperText = mutableAttributedStringFromString("ENTER ↑", color: UIColor.whiteColor())
		
		// Label ISG
		labelISG.attributedText = mutableAttributedStringFromString("ISG", color: nil)
		
		// Button CHS
		buttonCHS.upperText = mutableAttributedStringFromString("CHS", color: UIColor.whiteColor())
		
		// Label RTN
		labelRTN.attributedText = mutableAttributedStringFromString("RTN", color: nil)
		
		// Button EEX
		buttonEEX.upperText = mutableAttributedStringFromString("EEX", color: UIColor.whiteColor())
		
		// Label CL X/A
		let TimesNewRoman11Font = UIFont(name: "Times New Roman", size: 13.0 * yRatio)
		if let actualFont = TimesNewRoman11Font {
			var clxaString = mutableAttributedStringFromString("CL X/A", color: nil)
			let clxaAttributes = [
				NSFontAttributeName : actualFont
			]
			clxaString.addAttributes(clxaAttributes, range: NSMakeRange(3, 1))
			labelCLXA.attributedText = clxaString
		}
		
		// Button Back
		let Helvetica11Font = UIFont(name: "Helvetica", size: 13.0 * yRatio)
		if let actualFont = Helvetica11Font {
			var backString = mutableAttributedStringFromString("←", color: UIColor.whiteColor())
			let backAttributes = [
				NSFontAttributeName : actualFont
			]
			backString.addAttributes(backAttributes, range: NSMakeRange(0, 1))
			buttonBack.upperText = backString
		}
		
		// Label x=y ?
		if let actualFont = TimesNewRoman14Font {
			var xeqyString = mutableAttributedStringFromString("x=y ?", color: nil)
			let xeqyAttributes = [
				NSFontAttributeName : actualFont
			]
			xeqyString.addAttributes(xeqyAttributes, range: NSMakeRange(0, 3))
			labelXEQY.attributedText = xeqyString
		}
		
		// Button Minus
		let Helvetica09Font = UIFont(name: "Helvetica", size: 11.0 * yRatio)
		if let actualFont = Helvetica09Font {
			var minusString = mutableAttributedStringFromString("━", color: UIColor.whiteColor())
			let minusAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			minusString.addAttributes(minusAttributes, range: NSMakeRange(0, 1))
			buttonMinus.upperText = minusString
		}
		
		// Label SF
		labelSF.attributedText = mutableAttributedStringFromString("SF", color: nil)
		
		// Button 7
		if let actualFont = Helvetica13Font {
			var sevenString = mutableAttributedStringFromString("7", color: UIColor.whiteColor())
			let sevenAttributes = [
				NSFontAttributeName : actualFont
			]
			sevenString.addAttributes(sevenAttributes, range: NSMakeRange(0, 1))
			button7.upperText = sevenString
		}
		
		// Label CF
		labelCF.attributedText = mutableAttributedStringFromString("CF", color: nil)
		
		// Button 8
		if let actualFont = Helvetica13Font {
			var eightString = mutableAttributedStringFromString("8", color: UIColor.whiteColor())
			let eightAttributes = [
				NSFontAttributeName : actualFont
			]
			eightString.addAttributes(eightAttributes, range: NSMakeRange(0, 1))
			button8.upperText = eightString
		}
		
		// Label FS?
		labelFS.attributedText = mutableAttributedStringFromString("FS?", color: nil)
		
		// Button 9
		if let actualFont = Helvetica13Font {
			var nineString = mutableAttributedStringFromString("9", color: UIColor.whiteColor())
			let nineAttributes = [
				NSFontAttributeName : actualFont
			]
			nineString.addAttributes(nineAttributes, range: NSMakeRange(0, 1))
			button9.upperText = nineString
		}
		
		// Label x≤y ?
		let TimesNewRoman13Font = UIFont(name: "Times New Roman", size: 15.0 * yRatio)
		if let actualFont = TimesNewRoman13Font {
			var xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: nil)
			let xlessthanyAttributes = [
				NSFontAttributeName : actualFont
			]
			xlessthanyString.addAttributes(xlessthanyAttributes, range: NSMakeRange(0, 3))
			labelXLessThanY.attributedText = xlessthanyString
		}
		
		// Button Plus
		if let actualFont = Helvetica09Font {
			var plusString = mutableAttributedStringFromString("╋", color: UIColor.whiteColor())
			let plusAttributes = [
				NSFontAttributeName : actualFont
			]
			plusString.addAttributes(plusAttributes, range: NSMakeRange(0, 1))
			buttonPlus.upperText = plusString
		}
		
		// Label BEEP
		labelBEEP.attributedText = mutableAttributedStringFromString("BEEP", color: nil)
		
		// Button 4
		if let actualFont = Helvetica13Font {
			var fourString = mutableAttributedStringFromString("4", color: UIColor.whiteColor())
			let fourAttributes = [
				NSFontAttributeName : actualFont
			]
			fourString.addAttributes(fourAttributes, range: NSMakeRange(0, 1))
			button4.upperText = fourString
		}
		
		// Label P→R
		labelPR.attributedText = mutableAttributedStringFromString("P→R", color: nil)
		
		// Button 5
		if let actualFont = Helvetica13Font {
			var fiveString = mutableAttributedStringFromString("5", color: UIColor.whiteColor())
			let fiveAttributes = [
				NSFontAttributeName : actualFont
			]
			fiveString.addAttributes(fiveAttributes, range: NSMakeRange(0, 1))
			button5.upperText = fiveString
		}
		
		// Label R→P
		labelRP.attributedText = mutableAttributedStringFromString("R→P", color: nil)
		
		// Button 6
		if let actualFont = Helvetica13Font {
			var sixString = mutableAttributedStringFromString("6", color: UIColor.whiteColor())
			let sixAttributes = [
				NSFontAttributeName : actualFont
			]
			sixString.addAttributes(sixAttributes, range: NSMakeRange(0, 1))
			button6.upperText = sixString
		}
		
		// Label x≥y ?
		if let actualFont = TimesNewRoman13Font {
			var xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: nil)
			let xgreaterthanyAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			xgreaterthanyString.addAttributes(xgreaterthanyAttributes, range: NSMakeRange(0, 3))
			labelXGreaterThanY.attributedText = xgreaterthanyString
		}
		
		// Button Multiply
		let Helvetica15Font = UIFont(name: "Helvetica", size: 17.0 * yRatio)
		if let actualFont = Helvetica15Font {
			var multiplyString = mutableAttributedStringFromString("×", color: UIColor.whiteColor())
			let multiplyAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			multiplyString.addAttributes(multiplyAttributes, range: NSMakeRange(0, 1))
			buttonMultiply.upperText = multiplyString
		}
		
		// Label FIX
		labelFIX.attributedText = mutableAttributedStringFromString("FIX", color: nil)
		
		// Button 1
		if let actualFont = Helvetica13Font {
			var oneString = mutableAttributedStringFromString("1", color: UIColor.whiteColor())
			let oneAttributes = [
				NSFontAttributeName : actualFont
			]
			oneString.addAttributes(oneAttributes, range: NSMakeRange(0, 1))
			button1.upperText = oneString
		}
		
		// Label SCI
		labelSCI.attributedText = mutableAttributedStringFromString("SCI", color: nil)
		
		// Button 2
		if let actualFont = Helvetica13Font {
			var twoString = mutableAttributedStringFromString("2", color: UIColor.whiteColor())
			let twoAttributes = [
				NSFontAttributeName : actualFont
			]
			twoString.addAttributes(twoAttributes, range: NSMakeRange(0, 1))
			button2.upperText = twoString
		}
		
		// Label ENG
		labelENG.attributedText = mutableAttributedStringFromString("ENG", color: nil)
		
		// Button 3
		if let actualFont = Helvetica13Font {
			var thtreeString = mutableAttributedStringFromString("3", color: UIColor.whiteColor())
			let thtreeAttributes = [
				NSFontAttributeName : actualFont
			]
			thtreeString.addAttributes(thtreeAttributes, range: NSMakeRange(0, 1))
			button3.upperText = thtreeString
		}
		
		// Label x=0 ?
		if let actualFont = TimesNewRoman13Font {
			var xeq0String = mutableAttributedStringFromString("x=0 ?", color: nil)
			let xeq0Attributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: -1
			]
			xeq0String.addAttributes(xeq0Attributes, range: NSMakeRange(0, 5))
			labelXEQ0.attributedText = xeq0String
		}
		
		// Button Divide
		if let actualFont = Helvetica15Font {
			var divideString = mutableAttributedStringFromString("÷", color: UIColor.whiteColor())
			let divideAttributes = [
				NSFontAttributeName : actualFont,
				NSBaselineOffsetAttributeName: 1
			]
			divideString.addAttributes(divideAttributes, range: NSMakeRange(0, 1))
			buttonDivide.upperText = divideString
		}
		
		// Label PI
		let TimesNewRoman15Font = UIFont(name: "Times New Roman", size: 17.0 * yRatio)
		if let actualFont = TimesNewRoman15Font {
			var piString = mutableAttributedStringFromString("π", color: nil)
			let piAttributes = [
				NSFontAttributeName : actualFont
			]
			piString.addAttributes(piAttributes, range: NSMakeRange(0, 1))
			labelPI.attributedText = piString
		}
		
		// Button 0
		if let actualFont = Helvetica13Font {
			var zeroString = mutableAttributedStringFromString("0", color: UIColor.whiteColor())
			let zeroAttributes = [
				NSFontAttributeName : actualFont
			]
			zeroString.addAttributes(zeroAttributes, range: NSMakeRange(0, 1))
			button0.upperText = zeroString
		}
		
		// Label LAST X
		if let actualFont = TimesNewRoman13Font {
			var lastxString = mutableAttributedStringFromString("LAST X", color: nil)
			let lastxAttributes = [
				NSFontAttributeName : actualFont
			]
			lastxString.addAttributes(lastxAttributes, range: NSMakeRange(5, 1))
			labelLASTX.attributedText = lastxString
		}
		
		// Button •
		if let actualFont = Helvetica13Font {
			var pointString = mutableAttributedStringFromString("•", color: UIColor.whiteColor())
			let pointAttributes = [
				NSFontAttributeName : actualFont
			]
			pointString.addAttributes(pointAttributes, range: NSMakeRange(0, 1))
			buttonPoint.upperText = pointString
		}
		
		// Label VIEW
		labelVIEW.attributedText = mutableAttributedStringFromString("VIEW", color: nil)
		
		// Button R/S
		if let actualFont = Helvetica12Font {
			var rsString = mutableAttributedStringFromString("R/S", color: UIColor.whiteColor())
			let rsAttributes = [
				NSFontAttributeName : actualFont
			]
			rsString.addAttributes(rsAttributes, range: NSMakeRange(0, 3))
			buttonRS.upperText = rsString
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	func mutableAttributedStringFromString(aString: String, color: UIColor?) -> NSMutableAttributedString {
		let Helvetica11Font = UIFont(name: "Helvetica", size: 13.0 * yRatio)
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
	
	@IBAction func unwindSettingsViewController(unwindSegue:UIStoryboardSegue) {
		
	}
	
	@IBAction func displaySettings(sender: UIButton) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		var settingsViewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
		settingsViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
		settingsViewController.popoverPresentationController?.sourceView = my41CX
		settingsViewController.popoverPresentationController?.sourceRect = my41CX.bounds
		
		var settingsPopover: UIPopoverPresentationController = settingsViewController.popoverPresentationController!
		settingsPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
		settingsPopover.delegate = self
		
		presentViewController(
			settingsViewController,
			animated: true,
			completion: nil);
	}
	
	// #pragma mark - UIAdaptivePresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) ->UIModalPresentationStyle {
		return UIModalPresentationStyle.None
	}
	
	func presentationController(controller:UIPresentationController!, viewControllerForAdaptivePresentationStyle style:UIModalPresentationStyle) -> UIViewController! {
		let navController = UINavigationController(
			rootViewController: controller.presentedViewController
		)
		
		return navController
	}
}

class KeyboardView : UIView {
	override func drawRect(rect: CGRect) {
		//// Color Declarations
		let color = UIColor(red: 0.604, green: 0.467, blue: 0.337, alpha: 1.0)
		
		//// Bezier Drawing
		var bezierPath = UIBezierPath()
		bezierPath.moveToPoint(CGPoint(x: 5.0, y: 0.0))
		bezierPath.addLineToPoint(CGPoint(x: self.bounds.width - 5.0, y: 0.0))
		bezierPath.addCurveToPoint(CGPoint(x: self.bounds.width - 5.0, y: self.bounds.height), controlPoint1: CGPoint(x: self.bounds.width, y: self.bounds.height / 2.0), controlPoint2: CGPoint(x: self.bounds.width - 5.0, y: self.bounds.height))
		bezierPath.addLineToPoint(CGPoint(x: 5.0, y: self.bounds.height))
		bezierPath.addCurveToPoint(CGPoint(x: 5.0, y: 0.0), controlPoint1: CGPoint(x: 0.0, y: self.bounds.height / 2.0), controlPoint2: CGPoint(x: 5.0, y: 0.0))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()
	}
}

class CalculatorView: UIView {
	@IBOutlet weak var lcdDisplay: Display!
	
	var viewController: iOSViewController?
	var pressedKey: Key?
	
	override func awakeFromNib() {
		var rect = self.bounds
		rect.origin.x = 0.0
		rect.origin.y = 0.0
		self.setNeedsDisplayInRect(rect)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayOff", name: "displayOff", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayToggle", name: "displayToggle", object: nil)
	}
	
	func displayOff() {
		lcdDisplay.displayOff()
	}
	
	func displayToggle() {
		lcdDisplay.displayToggle()
	}
}