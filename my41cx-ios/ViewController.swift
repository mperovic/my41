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
	
	@IBOutlet weak var buttonOn: CalculatorKey!
	@IBOutlet weak var buttonUSER: CalculatorKey!
	@IBOutlet weak var buttonPRGM: CalculatorKey!
	@IBOutlet weak var buttonALPHA: CalculatorKey!
	
	@IBOutlet weak var labelSigmaMinus: UILabel!
	@IBOutlet weak var buttonSigmaPlus: CalculatorKey!
	@IBOutlet weak var labelYX: UILabel!
	@IBOutlet weak var buttonOneX: CalculatorKey!
	@IBOutlet weak var labelXSquare: UILabel!
	@IBOutlet weak var buttonSquareRoot: CalculatorKey!
	@IBOutlet weak var labelTenX: UILabel!
	@IBOutlet weak var buttonLog: CalculatorKey!
	@IBOutlet weak var labelEX: UILabel!
	@IBOutlet weak var buttonLn: CalculatorKey!
	@IBOutlet weak var labelCLSigma: UILabel!
	@IBOutlet weak var buttonXexY: CalculatorKey!
	@IBOutlet weak var labelPercent: UILabel!
	@IBOutlet weak var buttonRArrrow: CalculatorKey!
	@IBOutlet weak var labelSin: UILabel!
	@IBOutlet weak var buttonSin: CalculatorKey!
	@IBOutlet weak var labelCos: UILabel!
	@IBOutlet weak var buttonCos: CalculatorKey!
	@IBOutlet weak var labelTan: UILabel!
	@IBOutlet weak var buttonTan: CalculatorKey!
	@IBOutlet weak var buttonShift: CalculatorKey!
	@IBOutlet weak var labelASN: UILabel!
	@IBOutlet weak var buttonXEQ: CalculatorKey!
	@IBOutlet weak var labelLBL: UILabel!
	@IBOutlet weak var buttonSTO: CalculatorKey!
	@IBOutlet weak var labelGTO: UILabel!
	@IBOutlet weak var buttonRCL: CalculatorKey!
	@IBOutlet weak var labelBST: UILabel!
	@IBOutlet weak var buttonSST: CalculatorKey!
	@IBOutlet weak var labelCATALOG: UILabel!
	@IBOutlet weak var buttonENTER: CalculatorKey!
	@IBOutlet weak var labelISG: UILabel!
	@IBOutlet weak var buttonCHS: CalculatorKey!
	@IBOutlet weak var labelRTN: UILabel!
	@IBOutlet weak var buttonEEX: CalculatorKey!
	@IBOutlet weak var labelCLXA: UILabel!
	@IBOutlet weak var buttonBack: CalculatorKey!
	@IBOutlet weak var labelXEQY: UILabel!
	@IBOutlet weak var buttonMinus: CalculatorKey!
	@IBOutlet weak var labelSF: UILabel!
	@IBOutlet weak var button7: CalculatorKey!
	@IBOutlet weak var labelCF: UILabel!
	@IBOutlet weak var button8: CalculatorKey!
	@IBOutlet weak var labelFS: UILabel!
	@IBOutlet weak var button9: CalculatorKey!
	@IBOutlet weak var labelXLessThanY: UILabel!
	@IBOutlet weak var buttonPlus: CalculatorKey!
	@IBOutlet weak var labelBEEP: UILabel!
	@IBOutlet weak var button4: CalculatorKey!
	@IBOutlet weak var labelPR: UILabel!
	@IBOutlet weak var button5: CalculatorKey!
	@IBOutlet weak var labelRP: UILabel!
	@IBOutlet weak var button6: CalculatorKey!
	@IBOutlet weak var labelXGreaterThanY: UILabel!
	@IBOutlet weak var buttonMultiply: CalculatorKey!
	@IBOutlet weak var labelFIX: UILabel!
	@IBOutlet weak var button1: CalculatorKey!
	@IBOutlet weak var labelSCI: UILabel!
	@IBOutlet weak var button2: CalculatorKey!
	@IBOutlet weak var labelENG: UILabel!
	@IBOutlet weak var button3: CalculatorKey!
	@IBOutlet weak var labelXEQ0: UILabel!
	@IBOutlet weak var buttonDivide: CalculatorKey!
	@IBOutlet weak var labelPI: UILabel!
	@IBOutlet weak var button0: CalculatorKey!
	@IBOutlet weak var labelLASTX: UILabel!
	@IBOutlet weak var buttonPoint: CalculatorKey!
	@IBOutlet weak var labelVIEW: UILabel!
	@IBOutlet weak var buttonRS: CalculatorKey!
	
	@IBOutlet weak var my41CX: UIButton!
	
	var yRatio: CGFloat = 1.0

	override func viewWillAppear(_ animated: Bool) {
		let aView = self.view as! CalculatorView
		aView.viewController = self
		
//		self.view.layer.cornerRadius = 6.0
		self.view.backgroundColor = UIColor(red: 0.221, green: 0.221, blue: 0.221, alpha: 1.0)
		
		displayBackgroundView.backgroundColor = UIColor.lightGray
		displayBackgroundView.layer.cornerRadius = 3.0
	}
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		
//		coder.encodeObject(cpu, forKey: "cpu")
//		coder.encodeObject(bus, forKey: "bus")
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		
//		cpu = coder.decodeObjectForKey("cpu") as! CPU
//		bus = coder.decodeObjectForKey("bus") as! Bus
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let defaults = UserDefaults.standard
		if defaults.bool(forKey: "firstRun") == false {
			defaults.set(true, forKey: "firstRun")
			defaults.set(false, forKey: "sound")
			SOUND = false
			defaults.synchronize()
		} else {
			SOUND = defaults.bool(forKey: "sound")
			SYNCHRONYZE = defaults.bool(forKey: "synchronyzeTime")
		}
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		self.yRatio = self.view.bounds.size.height / 800.0
		
		my41CX.titleLabel?.font = UIFont(name: "Helvetica", size: 22.0 * yRatio)

		// Do any additional setup after loading the view, typically from a nib.
		let upperButtonsFont = UIFont(name: "Helvetica", size: 12.0)
		
		// ON
		if let actualFont = upperButtonsFont {
			let onString = mutableAttributedStringFromString("ON", color: .white)
			let onAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			onString.addAttributes(convertToNSAttributedStringKeyDictionary(onAttributes), range: NSMakeRange(0, 2))
			buttonOn.upperText = onString
		}

		// USER
		let userString = mutableAttributedStringFromString("USER", color: .white)
		if let actualFont = upperButtonsFont {
			let userAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			userString.addAttributes(convertToNSAttributedStringKeyDictionary(userAttributes), range: NSMakeRange(0, 4))
			buttonUSER.upperText = userString
		}
		
		// PRGM
		let prgmString = mutableAttributedStringFromString("PRGM", color: .white)
		if let actualFont = upperButtonsFont {
			let prgmAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			prgmString.addAttributes(convertToNSAttributedStringKeyDictionary(prgmAttributes), range: NSMakeRange(0, 4))
			buttonPRGM.upperText = prgmString
		}
		
		// ALPHA
		let alphaString = mutableAttributedStringFromString("ALPHA", color: .white)
		if let actualFont = upperButtonsFont {
			let alphaAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			alphaString.addAttributes(convertToNSAttributedStringKeyDictionary(alphaAttributes), range: NSMakeRange(0, 5))
			buttonALPHA.upperText = alphaString
		}
		
		// Label Σ-
		let Helvetica15Font = UIFont(name: "Helvetica", size: 15.0 * yRatio)
		if let actualFont = Helvetica15Font {
			let sigmaMinusString = mutableAttributedStringFromString("Σ-", color: nil)
			let sigmaMinusAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
				] as [String : Any]
			sigmaMinusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaMinusAttributes), range: NSMakeRange(1, 1))
			labelSigmaMinus.attributedText = sigmaMinusString
		}
		
		// Button Σ+
		let sigmaPlusString = mutableAttributedStringFromString("Σ+", color: .white)
		let sigmaPlusAttributes = [
			convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
		]
		sigmaPlusString.addAttributes(convertToNSAttributedStringKeyDictionary(sigmaPlusAttributes), range: NSMakeRange(1, 1))
		buttonSigmaPlus.upperText = sigmaPlusString
		
		// Label yx
		let TimesNewRoman12Font = UIFont(name: "Times New Roman", size: 12.0 * yRatio)
		if let actualFont = TimesNewRoman12Font {
			let yxString = mutableAttributedStringFromString("yx", color: nil)
			let yxAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
				] as [String : Any]
			yxString.addAttributes(convertToNSAttributedStringKeyDictionary(yxAttributes), range: NSMakeRange(1, 1))
			labelYX.attributedText = yxString
		}
		
		// Button 1/x
		if let actualFont = TimesNewRoman12Font {
			let oneXString = mutableAttributedStringFromString("1/x", color: .white)
			let oneXAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			oneXString.addAttributes(convertToNSAttributedStringKeyDictionary(oneXAttributes), range: NSMakeRange(2, 1))
			buttonOneX.upperText = oneXString
		}
		
		// Label x^2
		let TimesNewRoman14Font = UIFont(name: "Times New Roman", size: 14.0 * yRatio)
		if let actualFont = TimesNewRoman14Font {
			let xSquareString = mutableAttributedStringFromString("x\u{00B2}", color: nil)
			let xSquareAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			xSquareString.addAttributes(convertToNSAttributedStringKeyDictionary(xSquareAttributes), range: NSMakeRange(0, 2))
			labelXSquare.attributedText = xSquareString
		}
		
		// Button √x
		if let actualFont = TimesNewRoman12Font {
			let rootXString = mutableAttributedStringFromString("√x", color: .white)
			let rootXAttributes2 = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
			]
			rootXString.addAttributes(convertToNSAttributedStringKeyDictionary(rootXAttributes2), range: NSMakeRange(1, 1))
			buttonSquareRoot.upperText = rootXString
			
			// Label 10^x
			if let actualFont = TimesNewRoman12Font {
				let tenXString = mutableAttributedStringFromString("10x", color: nil)
				let tenXAttributes = [
					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
					convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
					] as [String : Any]
				tenXString.addAttributes(convertToNSAttributedStringKeyDictionary(tenXAttributes), range: NSMakeRange(2, 1))
				labelTenX.attributedText = tenXString
			}
			
			// Button LOG
			buttonLog.upperText = mutableAttributedStringFromString("LOG", color: .white)
		}
		
		// Label e^x
		let Helvetica14Font = UIFont(name: "Helvetica", size: 14.0 * yRatio)
		if let actualFont = TimesNewRoman12Font {
			let eXString = mutableAttributedStringFromString("ex", color: nil)
			let eXAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
				] as [String : Any]
			
			if let actualFont2 = Helvetica14Font {
				eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes), range: NSMakeRange(1, 1))
				let eXAttributes2 = [
					convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont2
				]
				eXString.addAttributes(convertToNSAttributedStringKeyDictionary(eXAttributes2), range: NSMakeRange(0, 1))
				labelEX.attributedText = eXString
			}
		}
		
		// Button LN
		buttonLn.upperText = mutableAttributedStringFromString("LN", color: .white)
		
		// Label CLΣ
		labelCLSigma.attributedText = mutableAttributedStringFromString("CLΣ", color: nil)
		
		// Button x≷y
		let TimesNewRoman16Font = UIFont(name: "Times New Roman", size: 16.0 * yRatio)
		if let actualFont = TimesNewRoman16Font {
			let XexYString = mutableAttributedStringFromString("x≷y", color: .white)
			let XexYAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
				] as [String : Any]
			XexYString.addAttributes(convertToNSAttributedStringKeyDictionary(XexYAttributes), range: NSMakeRange(0, 3))
			buttonXexY.upperText = XexYString
		}
		
		// Label %
		labelPercent.attributedText = mutableAttributedStringFromString("%", color: nil)
		
		// Button R↓
		buttonRArrrow.upperText = mutableAttributedStringFromString("R↓", color: .white)
		
		// Label SIN-1
		let TimesNewRoman11Font = UIFont(name: "Times New Roman", size: 11.0 * yRatio)
		if let actualFont = TimesNewRoman11Font {
			let sin1String = mutableAttributedStringFromString("SIN-1", color: nil)
			let sinAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
				] as [String : Any]
			sin1String.addAttributes(convertToNSAttributedStringKeyDictionary(sinAttributes), range: NSMakeRange(3, 2))
			labelSin.attributedText = sin1String
		}
		
		// Button SIN
		buttonSin.upperText = mutableAttributedStringFromString("SIN", color: .white)
		
		// Label COS-1
		if let actualFont = TimesNewRoman11Font {
			let cos1String = mutableAttributedStringFromString("COS-1", color: nil)
			let cosAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
				] as [String : Any]
			cos1String.addAttributes(convertToNSAttributedStringKeyDictionary(cosAttributes), range: NSMakeRange(3, 2))
			labelCos.attributedText = cos1String
		}
		
		// Button COS
		buttonCos.upperText = mutableAttributedStringFromString("COS", color: .white)
		
		// Label TAN-1
		if let actualFont = TimesNewRoman11Font {
			let tan1String = mutableAttributedStringFromString("TAN-1", color: nil)
			let tanAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 4
				] as [String : Any]
			tan1String.addAttributes(convertToNSAttributedStringKeyDictionary(tanAttributes), range: NSMakeRange(3, 2))
			labelTan.attributedText = tan1String
		}
		
		// Button TAN
		buttonTan.upperText = mutableAttributedStringFromString("TAN", color: .white)
		
		// Label ASN
		labelASN.attributedText = mutableAttributedStringFromString("ASN", color: nil)
		
		// Button XEQ
		buttonXEQ.upperText = mutableAttributedStringFromString("XEQ", color: .white)
		
		// Label LBL
		labelLBL.attributedText = mutableAttributedStringFromString("LBL", color: nil)
		
		// Button STO
		buttonSTO.upperText = mutableAttributedStringFromString("STO", color: .white)
		
		// Label GTO
		labelGTO.attributedText = mutableAttributedStringFromString("GTO", color: nil)
		
		// Button RCL
		buttonRCL.upperText = mutableAttributedStringFromString("RCL", color: .white)
		
		// Label BST
		labelBST.attributedText = mutableAttributedStringFromString("BST", color: nil)
		
		// Button SST
		buttonSST.upperText = mutableAttributedStringFromString("SST", color: .white)
		
		// Label CATALOG
		labelCATALOG.attributedText = mutableAttributedStringFromString("CATALOG", color: nil)
		
		// Button ENTER
		buttonENTER.upperText = mutableAttributedStringFromString("ENTER ↑", color: .white)
		
		// Label ISG
		labelISG.attributedText = mutableAttributedStringFromString("ISG", color: nil)
		
		// Button CHS
		buttonCHS.upperText = mutableAttributedStringFromString("CHS", color: .white)
		
		// Label RTN
		labelRTN.attributedText = mutableAttributedStringFromString("RTN", color: nil)
		
		// Button EEX
		buttonEEX.upperText = mutableAttributedStringFromString("EEX", color: .white)
		
		// Label CL X/A
		let TimesNewRoman13Font = UIFont(name: "Times New Roman", size: 13.0 * yRatio)
		if let actualFont = TimesNewRoman13Font {
			let clxaString = mutableAttributedStringFromString("CL X/A", color: nil)
			let clxaAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			clxaString.addAttributes(convertToNSAttributedStringKeyDictionary(clxaAttributes), range: NSMakeRange(3, 1))
			labelCLXA.attributedText = clxaString
		}
		
		// Button Back
		let Helvetica11Font = UIFont(name: "Helvetica", size: 13.0 * yRatio)
		if let actualFont = Helvetica11Font {
			let backString = mutableAttributedStringFromString("←", color: .white)
			let backAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			backString.addAttributes(convertToNSAttributedStringKeyDictionary(backAttributes), range: NSMakeRange(0, 1))
			buttonBack.upperText = backString
		}
		
		// Label x=y ?
		if let actualFont = TimesNewRoman16Font {
			let xeqyString = mutableAttributedStringFromString("x=y ?", color: nil)
			let xeqyAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			xeqyString.addAttributes(convertToNSAttributedStringKeyDictionary(xeqyAttributes), range: NSMakeRange(0, 3))
			labelXEQY.attributedText = xeqyString
		}
		
		// Button Minus
		let Helvetica09Font = UIFont(name: "Helvetica", size: 11.0 * yRatio)
		if let actualFont = Helvetica09Font {
			let minusString = mutableAttributedStringFromString("━", color: .white)
			let minusAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
				] as [String : Any]
			minusString.addAttributes(convertToNSAttributedStringKeyDictionary(minusAttributes), range: NSMakeRange(0, 1))
			buttonMinus.upperText = minusString
		}
		
		// Label SF
		labelSF.attributedText = mutableAttributedStringFromString("SF", color: nil)
		
		// Button 7
		if let actualFont = Helvetica15Font {
			let sevenString = mutableAttributedStringFromString("7", color: .white)
			let sevenAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			sevenString.addAttributes(convertToNSAttributedStringKeyDictionary(sevenAttributes), range: NSMakeRange(0, 1))
			button7.upperText = sevenString
		}
		
		// Label CF
		labelCF.attributedText = mutableAttributedStringFromString("CF", color: nil)
		
		// Button 8
		if let actualFont = Helvetica15Font {
			let eightString = mutableAttributedStringFromString("8", color: .white)
			let eightAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			eightString.addAttributes(convertToNSAttributedStringKeyDictionary(eightAttributes), range: NSMakeRange(0, 1))
			button8.upperText = eightString
		}
		
		// Label FS?
		labelFS.attributedText = mutableAttributedStringFromString("FS?", color: nil)
		
		// Button 9
		if let actualFont = Helvetica15Font {
			let nineString = mutableAttributedStringFromString("9", color: .white)
			let nineAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			nineString.addAttributes(convertToNSAttributedStringKeyDictionary(nineAttributes), range: NSMakeRange(0, 1))
			button9.upperText = nineString
		}
		
		// Label x≤y ?
		let TimesNewRoman15Font = UIFont(name: "Times New Roman", size: 15.0 * yRatio)
		if let actualFont = TimesNewRoman15Font {
			let xlessthanyString = mutableAttributedStringFromString("x≤y ?", color: nil)
			let xlessthanyAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			xlessthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xlessthanyAttributes), range: NSMakeRange(0, 3))
			labelXLessThanY.attributedText = xlessthanyString
		}
		
		// Button Plus
		if let actualFont = Helvetica09Font {
			let plusString = mutableAttributedStringFromString("╋", color: .white)
			let plusAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			plusString.addAttributes(convertToNSAttributedStringKeyDictionary(plusAttributes), range: NSMakeRange(0, 1))
			buttonPlus.upperText = plusString
		}
		
		// Label BEEP
		labelBEEP.attributedText = mutableAttributedStringFromString("BEEP", color: nil)
		
		// Button 4
		if let actualFont = Helvetica15Font {
			let fourString = mutableAttributedStringFromString("4", color: .white)
			let fourAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			fourString.addAttributes(convertToNSAttributedStringKeyDictionary(fourAttributes), range: NSMakeRange(0, 1))
			button4.upperText = fourString
		}
		
		// Label P→R
		labelPR.attributedText = mutableAttributedStringFromString("P→R", color: nil)
		
		// Button 5
		if let actualFont = Helvetica15Font {
			let fiveString = mutableAttributedStringFromString("5", color: .white)
			let fiveAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			fiveString.addAttributes(convertToNSAttributedStringKeyDictionary(fiveAttributes), range: NSMakeRange(0, 1))
			button5.upperText = fiveString
		}
		
		// Label R→P
		labelRP.attributedText = mutableAttributedStringFromString("R→P", color: nil)
		
		// Button 6
		if let actualFont = Helvetica15Font {
			let sixString = mutableAttributedStringFromString("6", color: .white)
			let sixAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			sixString.addAttributes(convertToNSAttributedStringKeyDictionary(sixAttributes), range: NSMakeRange(0, 1))
			button6.upperText = sixString
		}
		
		// Label x≥y ?
		if let actualFont = TimesNewRoman15Font {
			let xgreaterthanyString = mutableAttributedStringFromString("x>y ?", color: nil)
			let xgreaterthanyAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
				] as [String : Any]
			xgreaterthanyString.addAttributes(convertToNSAttributedStringKeyDictionary(xgreaterthanyAttributes), range: NSMakeRange(0, 3))
			labelXGreaterThanY.attributedText = xgreaterthanyString
		}
		
		// Button Multiply
		let Helvetica17Font = UIFont(name: "Helvetica", size: 17.0 * yRatio)
		if let actualFont = Helvetica17Font {
			let multiplyString = mutableAttributedStringFromString("×", color: .white)
			let multiplyAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
				] as [String : Any]
			multiplyString.addAttributes(convertToNSAttributedStringKeyDictionary(multiplyAttributes), range: NSMakeRange(0, 1))
			buttonMultiply.upperText = multiplyString
		}
		
		// Label FIX
		labelFIX.attributedText = mutableAttributedStringFromString("FIX", color: nil)
		
		// Button 1
		if let actualFont = Helvetica17Font {
			let oneString = mutableAttributedStringFromString("1", color: .white)
			let oneAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			oneString.addAttributes(convertToNSAttributedStringKeyDictionary(oneAttributes), range: NSMakeRange(0, 1))
			button1.upperText = oneString
		}
		
		// Label SCI
		labelSCI.attributedText = mutableAttributedStringFromString("SCI", color: nil)
		
		// Button 2
		if let actualFont = Helvetica17Font {
			let twoString = mutableAttributedStringFromString("2", color: .white)
			let twoAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			twoString.addAttributes(convertToNSAttributedStringKeyDictionary(twoAttributes), range: NSMakeRange(0, 1))
			button2.upperText = twoString
		}
		
		// Label ENG
		labelENG.attributedText = mutableAttributedStringFromString("ENG", color: nil)
		
		// Button 3
		if let actualFont = Helvetica17Font {
			let thtreeString = mutableAttributedStringFromString("3", color: .white)
			let thtreeAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			thtreeString.addAttributes(convertToNSAttributedStringKeyDictionary(thtreeAttributes), range: NSMakeRange(0, 1))
			button3.upperText = thtreeString
		}
		
		// Label x=0 ?
		if let actualFont = TimesNewRoman15Font {
			let xeq0String = mutableAttributedStringFromString("x=0 ?", color: nil)
			let xeq0Attributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): -1
				] as [String : Any]
			xeq0String.addAttributes(convertToNSAttributedStringKeyDictionary(xeq0Attributes), range: NSMakeRange(0, 5))
			labelXEQ0.attributedText = xeq0String
		}
		
		// Button Divide
		if let actualFont = Helvetica17Font {
			let divideString = mutableAttributedStringFromString("÷", color: .white)
			let divideAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
				convertFromNSAttributedStringKey(NSAttributedString.Key.baselineOffset): 1
				] as [String : Any]
			divideString.addAttributes(convertToNSAttributedStringKeyDictionary(divideAttributes), range: NSMakeRange(0, 1))
			buttonDivide.upperText = divideString
		}
		
		// Label PI
		let TimesNewRoman17Font = UIFont(name: "Times New Roman", size: 17.0 * yRatio)
		if let actualFont = TimesNewRoman17Font {
			let piString = mutableAttributedStringFromString("π", color: nil)
			let piAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			piString.addAttributes(convertToNSAttributedStringKeyDictionary(piAttributes), range: NSMakeRange(0, 1))
			labelPI.attributedText = piString
		}
		
		// Button 0
		if let actualFont = Helvetica17Font {
			let zeroString = mutableAttributedStringFromString("0", color: .white)
			let zeroAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			zeroString.addAttributes(convertToNSAttributedStringKeyDictionary(zeroAttributes), range: NSMakeRange(0, 1))
			button0.upperText = zeroString
		}
		
		// Label LAST X
		if let actualFont = TimesNewRoman15Font {
			let lastxString = mutableAttributedStringFromString("LAST X", color: nil)
			let lastxAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			lastxString.addAttributes(convertToNSAttributedStringKeyDictionary(lastxAttributes), range: NSMakeRange(5, 1))
			labelLASTX.attributedText = lastxString
		}
		
		// Button •
		if let actualFont = Helvetica17Font {
			let pointString = mutableAttributedStringFromString("•", color: .white)
			let pointAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			pointString.addAttributes(convertToNSAttributedStringKeyDictionary(pointAttributes), range: NSMakeRange(0, 1))
			buttonPoint.upperText = pointString
		}
		
		// Label VIEW
		labelVIEW.attributedText = mutableAttributedStringFromString("VIEW", color: nil)
		
		// Button R/S
		if let actualFont = Helvetica14Font {
			let rsString = mutableAttributedStringFromString("R/S", color: .white)
			let rsAttributes = [
				convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
			]
			rsString.addAttributes(convertToNSAttributedStringKeyDictionary(rsAttributes), range: NSMakeRange(0, 3))
			buttonRS.upperText = rsString
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func mutableAttributedStringFromString(_ aString: String, color: UIColor?) -> NSMutableAttributedString {
		let Helvetica11Font = UIFont(name: "Helvetica", size: 13.0 * yRatio)
		if let actualFont = Helvetica11Font {
			if let aColor = color {
				return NSMutableAttributedString(
					string: aString,
					attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont,
						convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): aColor
					])
				)
			} else {
				return NSMutableAttributedString(string: aString,
					attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : actualFont
					])
				)
			}
		} else {
			return NSMutableAttributedString()
		}
	}
	
	@IBAction func unwindSettingsViewController(_ unwindSegue:UIStoryboardSegue) {
		
	}
	
	@IBAction func displaySettings(_ sender: UIButton) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
		settingsViewController.modalPresentationStyle = UIModalPresentationStyle.popover
		settingsViewController.popoverPresentationController?.sourceView = my41CX
		settingsViewController.popoverPresentationController?.sourceRect = my41CX.bounds
		
		let settingsPopover: UIPopoverPresentationController = settingsViewController.popoverPresentationController!
		settingsPopover.permittedArrowDirections = UIPopoverArrowDirection.any
		settingsPopover.delegate = self
		
		present(
			settingsViewController,
			animated: true,
			completion: nil);
	}
	
	// #pragma mark - UIAdaptivePresentationControllerDelegate
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
	func presentationController(_ controller:UIPresentationController, viewControllerForAdaptivePresentationStyle style:UIModalPresentationStyle) -> UIViewController? {
		let navController = UINavigationController(
			rootViewController: controller.presentedViewController
		)
		
		return navController
	}
}

class KeyboardView : UIView {
	override func draw(_ rect: CGRect) {
		//// Color Declarations
		let color = UIColor(red: 0.604, green: 0.467, blue: 0.337, alpha: 1.0)
		
		//// Bezier Drawing
		let bezierPath = UIBezierPath()
		bezierPath.move(to: CGPoint(x: 5.0, y: 0.0))
		bezierPath.addLine(to: CGPoint(x: self.bounds.width - 5.0, y: 0.0))
		bezierPath.addCurve(to: CGPoint(x: self.bounds.width - 5.0, y: self.bounds.height), controlPoint1: CGPoint(x: self.bounds.width, y: self.bounds.height / 2.0), controlPoint2: CGPoint(x: self.bounds.width - 5.0, y: self.bounds.height))
		bezierPath.addLine(to: CGPoint(x: 5.0, y: self.bounds.height))
		bezierPath.addCurve(to: CGPoint(x: 5.0, y: 0.0), controlPoint1: CGPoint(x: 0.0, y: self.bounds.height / 2.0), controlPoint2: CGPoint(x: 5.0, y: 0.0))
		color.setStroke()
		bezierPath.lineWidth = 2
		bezierPath.stroke()
	}
}

class CalculatorView: UIView {
	@IBOutlet weak var lcdDisplay: Display!
	
	var viewController: iOSViewController?
	var pressedKey: CalculatorKey?
	
	override func awakeFromNib() {
		var rect = self.bounds
		rect.origin.x = 0.0
		rect.origin.y = 0.0
		self.setNeedsDisplay(rect)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(CalculatorView.displayOff),
			name: NSNotification.Name(rawValue: "displayOff"),
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(CalculatorView.displayToggle),
			name: NSNotification.Name(rawValue: "displayToggle"),
			object: nil
		)
	}
	
	@objc func displayOff() {
		lcdDisplay.displayOff()
	}
	
	@objc func displayToggle() {
		lcdDisplay.displayToggle()
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
