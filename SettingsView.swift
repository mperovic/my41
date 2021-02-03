//
//  SettingsView.swift
//  my41
//
//  Created by Miroslav Perovic on 28.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
	@State private var calculator = "HP 41C"
	@State private var sound = true
	@State private var syncTime = true
	
	@State var expansionModule1: MODsView?
	@State var expansionModule2: MODsView?
	@State var expansionModule3: MODsView?
	@State var expansionModule4: MODsView?

    var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				HStack {
					Text("Calculator")
					Spacer(minLength: 40)
					Picker("Calculator", selection: $calculator) {
						Text("HP 41C").tag("HP 41C")
						Text("HP 41CV").tag("HP 41CV")
						Text("HP 41CX").tag("HP 41CX")
					}
					.pickerStyle(SegmentedPickerStyle())
				}
				Toggle(isOn: $sound){
					Text("Sound")
				}
				Toggle(isOn: $syncTime){
					Text("Synchronyze time with device")
				}
				
				Text("MODs")
					.padding(.top, 20)
				VStack {
					HStack {
						MODsView(port: .port1)
						MODsView(port: .port2)
					}
					HStack {
						MODsView(port: .port3)
						MODsView(port: .port4)
					}
				}
				.padding(.top, 10)
				.padding(.bottom, 15)
				.frame(height: geometry.size.height * 0.355)
				
				HStack {
					Spacer()
					Button(action: {
						
					}, label: {
						Text("Reset Calculator")
					})
					Spacer()
				}
				
				Spacer()
				
				HStack {
					Spacer()
					
					Button(action: {
						
					}, label: {
						Text("Apply")
				})
				}
				
			}
			.padding(.all)
		}
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView()
    }
}
