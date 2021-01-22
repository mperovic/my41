//
//  my41View.swift
//  my41
//
//  Created by Miroslav Perovic on 5.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI
import AVFoundation
import AudioToolbox

struct My41View: View {
	@EnvironmentObject var keys: Keys
	
	var mySound: SystemSoundID = 0
	let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: "keyPressSound", ofType: "wav")!)
	
	let upperButtonsFont = UIFont(name: "Helvetica", size: 12.0)
	
	init() {
		AudioServicesCreateSystemSoundID(url as CFURL, &self.mySound)
	}
	
	var body: some View {
		GeometryReader { geometry in
			let yRatio = geometry.size.height / 800.0
			let width = geometry.size.width - 20
			let spacing: CGFloat = 10
			let buttonWidth: CGFloat = { (width - 4 * spacing) / CGFloat(5) }()

			VStack {
				Spacer()
				
				HStack {
					Spacer()
					Text("my41")
						.font(.custom("Helvetica", size: 22.0 * yRatio))
						.fontWeight(.bold)
						.padding(.top, 10)
						.padding(.trailing, 20)
						.foregroundColor(.shiftColor)
				}
				
				let aspectRatio: CGFloat = 36/342
				DisplayView()
					.frame(width: width, height: width * aspectRatio)
				
				KeyGroupView(keys: keys.modeKeys, height: 20 * yRatio, isModeGroup: true)
					.frame(width: width, height: 30)
					.padding(.bottom, 10)

				VStack {
					Spacer()
					KeyGroupView(keys: keys.keys1, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys2, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys3, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys4, height: buttonWidth * 0.551282 * yRatio, isEnterGroup: true)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys5, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys6, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys7, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys8, height: buttonWidth * 0.551282 * yRatio)
						.padding([.leading, .trailing], 10)
				}
				.padding([.leading, .trailing], 10)
				.overlay(
					Rectangle()
						.stroke(Color.shiftColor, lineWidth: 1.0)
						.frame(width: width)
				)
				
				Spacer()
			}
			.background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
		}
	}
}

struct my41View_Previews: PreviewProvider {
	static var previews: some View {
		My41View().environmentObject(Keys())
	}
}
