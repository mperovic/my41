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
	@EnvironmentObject var calculator: Calculator
	
	@State var showSettings = false

	var mySound: SystemSoundID = 0
	let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: "keyPressSound", ofType: "wav")!)
	
	let lcdDisplay = DisplayView()
	
	init() {
		AudioServicesCreateSystemSoundID(url as CFURL, &mySound)
		
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
	}
	
	var body: some View {
		GeometryReader { geometry in
			let yRatio = geometry.size.height / 800.0
			let width = geometry.size.width - 20

			VStack {
				Spacer()
				
				HStack {
					Button(action: {
						showSettings.toggle()
					}) {
						Image(systemName: "slider.horizontal.3")
							.font(.system(size: 20, weight: .bold))
							.padding(.leading, 5)
							.foregroundColor(.shiftColor)
					}.sheet(isPresented: $showSettings) {
						SettingsView(showSettings: $showSettings)
							.environmentObject(calculator)
					}
					.padding(.leading, 3)
					Spacer()
					Text("my41CX")
						.font(.custom("Helvetica", size: 22.0 * yRatio))
						.fontWeight(.bold)
						.padding(.trailing, 10)
						.foregroundColor(.shiftColor)
				}
				
				ZStack {
					EmptyView()
						.background(Color(white: 148/255))
						.cornerRadius(3.0)

					lcdDisplay
						.environmentObject(calculator)
						.padding([.trailing, .leading], 16)
						.padding([.top, .bottom], 8)
						.background(Color(white: 148/255))
				}
				.frame(width: width, height: 52)
				
				KeyGroupView(keys: keys.modeKeys, isModeGroup: true)
					.frame(width: width, height: 35)
					.padding(.bottom, 8)

				VStack {
					Spacer()
					KeyGroupView(keys: keys.keys1)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys2)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys3)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys4, isEnterGroup: true)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys5)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys6)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys7)
						.padding([.leading, .trailing], 10)
					KeyGroupView(keys: keys.keys8)
						.padding([.leading, .trailing], 10)
				}
				.padding([.leading, .trailing], 10)
				.overlay(
					Rectangle()
						.stroke(Color.shiftColor, lineWidth: 1.0)
						.frame(width: width, height: geometry.size.height - 135)
				)
				
				Spacer()
			}
			.background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
		}
	}
	
	func displayOff() {
		lcdDisplay.displayOff()
	}
	
	func displayToggle() {
		lcdDisplay.displayToggle()
	}
}

struct my41View_Previews: PreviewProvider {
	static var previews: some View {
		My41View()
			.environmentObject(Keys())
			.environmentObject(Calculator())
	}
}
