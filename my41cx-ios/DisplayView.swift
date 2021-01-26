//
//  DisplayView.swift
//  my41cx-ios
//
//  Created by Miroslav Perovic on 26.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI
import UIKit

struct DisplayView: UIViewRepresentable {
	@EnvironmentObject var calculator: Calculator
	
	let lcdDisplay = Display()

	func makeUIView(context: Context) -> UIView {
		lcdDisplay.calculator = calculator
		lcdDisplay
			.awakeFromNib()
		
		return lcdDisplay
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		
	}
	
	func displayOff() {
		lcdDisplay.displayOff()
	}
	
	func displayToggle() {
		lcdDisplay.displayToggle()
	}
}
