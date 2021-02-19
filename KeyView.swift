//
//  KeyView.swift
//  my41
//
//  Created by Miroslav Perovic on 5.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI
import UIKit

struct CalcKey: Hashable {
	var shiftText: NSAttributedString
	var upperText: NSAttributedString
	var lowerText: NSAttributedString?
	var shiftButton: Bool = false
	var enter: Bool = false
	var keyCode: Int
	
	func execute(pressed: Bool) {
		cpu.keyWithCode(Bits8(keyCode), pressed: pressed)
	}
}

struct KeyView: View {
	var key: CalcKey
	var width: CGFloat
	var height: CGFloat

	@State private var pressed = false

	private let shiftButtonBackground = Gradient(stops: [
		.init(color: Color(red: 0.7490, green: 0.4901, blue: 0.1765), location: 0.00),
		.init(color: Color(red: 0.7176, green: 0.4549, blue: 0.1765), location: 0.10),
		.init(color: Color(red: 0.6745, green: 0.4235, blue: 0.0549), location: 0.49),
		.init(color: Color(red: 0.6078, green: 0.3961, blue: 0.08235), location: 0.49),
		.init(color: Color(red: 0.5804, green: 0.3961, blue: 0.1294), location: 0.90),
		.init(color: Color(red: 0.4784, green: 0.2745, blue: 0.0471), location: 1.00)
	])
	
	private let buttonBackground = Gradient(stops: [
		.init(color: Color(white: 0.50), location: 0.00),
		.init(color: Color(white: 0.42), location: 0.12),
		.init(color: Color(white: 0.30), location: 0.49),
		.init(color: Color(white: 0.27), location: 0.49),
		.init(color: Color(white: 0.20), location: 0.98),
		.init(color: Color(white: 0.17), location: 1.00)
	])
	
	var body: some View {
		GeometryReader { geometry in
			VStack (spacing: 0) {
				AttributedText(key.shiftText)
					.frame(width: geometry.size.width, height: geometry.size.height / 3)
					.padding(.bottom, 5)
				
				Button(action: {

				}, label: {
					VStack (alignment: .center, spacing: 0) {
						AttributedText(key.upperText)
						if let text = key.lowerText {
							AttributedText(text)
								.padding(.top, 5)
						}
					}
					.frame(width: width, height: height)
					.background(LinearGradient(
									gradient: key.shiftButton ? shiftButtonBackground : buttonBackground,
									startPoint: .top,
									endPoint: .bottom)
					)
					.overlay(
						RoundedRectangle(cornerRadius: 3.0)
							.stroke(Color.black, lineWidth: 1.0)
					)
				})
				.onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
					pressed = pressing
					key.execute(pressed: pressed)
				}, perform: {})
				.opacity(pressed ? 0.75 : 1.0)
				.scaleEffect(pressed ? 0.9 : 1.0)
			}
		}
	}
}

struct KeyView_Previews: PreviewProvider {
	static var keys = Keys()
	static let width: CGFloat = 375 / 5
	
    static var previews: some View {
		GeometryReader { geometry in
			let width = (geometry.size.width - 40) / 5
			KeyView(key: keys.modeKeys[0], width: width, height: 20)
				.frame(width: width, height: 20)
		}
		GeometryReader { geometry in
			let width = (geometry.size.width - 40) / 5
			KeyView(key: keys.keys8[2], width: width, height: width * 0.7813)
				.frame(width: width, height: width * 0.7813)
		}
		GeometryReader { geometry in
			let width = (geometry.size.width - 40) / 5
			KeyView(key: keys.keys3[0], width: width, height: width * 0.7813)
				.frame(width: width, height: width * 0.7813)
		}
	}
}
