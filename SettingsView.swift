//
//  SettingsView.swift
//  my41
//
//  Created by Miroslav Perovic on 28.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODsViewStyle: ViewModifier {
	func body(content: Content) -> some View {
		return content
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(lineWidth: 2)
					.foregroundColor(.white)
			)
			.shadow(
				color: Color.gray.opacity(0.4),
				radius: 3, x: 1, y: 2
			)
			.padding(5)
	}
}

struct SettingsView: View {
	@EnvironmentObject var calculator: Calculator
	@ObservedObject var settingsState = SettingsState()

	@State private var selectedCalculator = UserDefaults.standard.string(forKey: hpCalculatorType) ?? HPCalculator.hp41cx.rawValue
	@State private var sound = true
	@State private var syncTime = true
	@State private var module: MOD?
	
	@Binding var showSettings: Bool
	@State private var showAlert = false
	@State private var showList1 = false
	@State private var showList2 = false
	@State private var showList3 = false
	@State private var showList4 = false
	
	private let mods = MODs.getModFiles()
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				HStack {
					Text("Calculator")
					Spacer(minLength: 40)
					Picker("Calculator", selection: $selectedCalculator) {
						ForEach(HPCalculator.allCases, id: \.self) {
							Text($0.rawValue).tag($0.rawValue)
						}
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
						MODsView(port: .port1, settingsState: settingsState)
							.onPress {port in
								showList1 = true
							}
							.sheet(isPresented: $showList1) {
								MODList(settingsState: settingsState, showList: $showList1, port: .port1)
							}
							.modifier(MODsViewStyle())
						MODsView(port: .port2, settingsState: settingsState)
							.onPress {port in
								showList2 = true
							}
							.sheet(isPresented: $showList2) {
								MODList(settingsState: settingsState, showList: $showList2, port: .port2)
							}
							.modifier(MODsViewStyle())
					}
					HStack {
						MODsView(port: .port3, settingsState: settingsState)
							.onPress {port in
								showList3 = true
							}
							.sheet(isPresented: $showList3) {
								MODList(settingsState: settingsState, showList: $showList3, port: .port3)
							}
							.modifier(MODsViewStyle())
						MODsView(port: .port4, settingsState: settingsState)
							.onPress {port in
								showList4 = true
							}
							.sheet(isPresented: $showList4) {
								MODList(settingsState: settingsState, showList: $showList4, port: .port4)
							}
							.modifier(MODsViewStyle())
					}
				}
				.padding(.top, 10)
				.padding(.bottom, 15)
				.frame(height: geometry.size.height * 0.455)
				
				HStack {
					Spacer()
					Button(action: {
						showAlert.toggle()
					}) {
						Text("Reset Calculator")
					}
					.foregroundColor(.white)
					.alert(isPresented: $showAlert) {
						Alert(
							title: Text("Reset Calculator"),
							message: Text("This operation will clear all programs and memory registers"),
							primaryButton: .default(Text("Continue")) {
								calculator.resetCalculator(restoringMemory: false)
								
								showSettings = false
							},
							secondaryButton: .cancel(Text("Cancel"))
						)
					}
					Spacer()
				}
				
				Spacer()
				
				HStack {
					Spacer()
					
					Button(action: {
						applyChanges()
					}, label: {
						Text("Apply")
							.fontWeight(.semibold)
					})
					.foregroundColor(.white)
				}
				
			}
			.padding(.all)
		}
    }
	
	private func applyChanges() {
		var needsRestart = false
		
		let defaults = UserDefaults.standard
		
		// Sound settings
		if sound {
			SOUND = true
		} else {
			SOUND = false
		}
		defaults.set(SOUND, forKey: "sound")
		
		// Calculator timer
		if syncTime {
			SYNCHRONYZE = true
		} else {
			SYNCHRONYZE = false
		}
		defaults.set(SYNCHRONYZE, forKey: "synchronyzeTime")
		
		// Calculator type
		let calculatorType = defaults.string(forKey: hpCalculatorType)
		if calculatorType != selectedCalculator {
			defaults.set(selectedCalculator, forKey: hpCalculatorType)
			needsRestart = true
		}
		
		// Modules
		if let module1 = settingsState.module1 {
			// We have something in Port1
			let moduleName = mods.key(from: module1)
			if let dModuleName = defaults.string(forKey: HPPort.port1.rawValue) {
				// And we had something in Port1 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort.port1.rawValue)
					needsRestart = true
				}
			} else {
				// Port1 was empty
				defaults.set(moduleName, forKey: HPPort.port1.rawValue)
				needsRestart = true
			}
		} else {
			// Port1 is empty now
			if let _ = defaults.string(forKey: HPPort.port1.rawValue) {
				// But we had something in Port1
				defaults.removeObject(forKey: HPPort.port1.rawValue)
			}
		}
		
		if let module2 = settingsState.module2 {
			// We have something in Port2
			let moduleName = mods.key(from: module2)
			if let dModuleName = defaults.string(forKey: HPPort.port2.rawValue) {
				// And we had something in Port2 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort.port2.rawValue)
					needsRestart = true
				}
			} else {
				// Port2 was empty
				defaults.set(moduleName, forKey: HPPort.port2.rawValue)
				needsRestart = true
			}
		} else {
			// Port2 is empty now
			if let _ = defaults.string(forKey: HPPort.port2.rawValue) {
				// But we had something in Port2
				defaults.removeObject(forKey: HPPort.port2.rawValue)
			}
		}
		
		if let module3 = settingsState.module3 {
			// We have something in Port3
			let moduleName = mods.key(from: module3)
			if let dModuleName = defaults.string(forKey: HPPort.port3.rawValue) {
				// And we had something in Port3 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort.port3.rawValue)
					needsRestart = true
				}
			} else {
				// Port3 was empty
				defaults.set(moduleName, forKey: HPPort.port3.rawValue)
				needsRestart = true
			}
		} else {
			// Port3 is empty now
			if let _ = defaults.string(forKey: HPPort.port3.rawValue) {
				// But we had something in Port3
				defaults.removeObject(forKey: HPPort.port3.rawValue)
			}
		}
		
		if let module3 = settingsState.module3 {
			// We have something in Port4
			let moduleName = mods.key(from: module3)
			if let dModuleName = defaults.string(forKey: HPPort.port4.rawValue) {
				// And we had something in Port4 at the begining
				if moduleName != dModuleName {
					// This is different module
					defaults.set(moduleName, forKey: HPPort.port4.rawValue)
					needsRestart = true
				}
			} else {
				// Port4 was empty
				defaults.set(moduleName, forKey: HPPort.port4.rawValue)
				needsRestart = true
			}
		} else {
			// Port4 is empty now
			if let _ = defaults.string(forKey: HPPort.port4.rawValue) {
				// But we had something in Port4
				defaults.removeObject(forKey: HPPort.port4.rawValue)
			}
		}
		defaults.synchronize()
		
		if needsRestart {
			calculator.resetCalculator(restoringMemory: true)
		}
		
		showSettings = false
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView(showSettings: .constant(true))
    }
}
