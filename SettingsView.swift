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
					.foregroundColor(.blue)
			)
			.shadow(color: Color.gray.opacity(0.4),
					radius: 3, x: 1, y: 2)
			.padding(5)
	}
}

struct SettingsView: View {
	@EnvironmentObject var calculator: Calculator

	@State private var selectedCalculator = "HP 41C"
	@State private var sound = true
	@State private var syncTime = true
	
	@State var expansionModules = [
		MODsView(port: .port1),
		MODsView(port: .port2),
		MODsView(port: .port3),
		MODsView(port: .port4)
	]
	@State var selectedModule: MOD?
	
	@Binding var showSettings: Bool
	@State var showAlert = false
	@State var showList = false

	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				HStack {
					Text("Calculator")
					Spacer(minLength: 40)
					Picker("Calculator", selection: $selectedCalculator) {
						Text(HPCalculator.hp41c.rawValue).tag(HPCalculator.hp41c.rawValue)
						Text(HPCalculator.hp41cv.rawValue).tag(HPCalculator.hp41cv.rawValue)
						Text(HPCalculator.hp41cx.rawValue).tag(HPCalculator.hp41cx.rawValue)
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
						expansionModules[0]
							.onPress {
								selectedModule = expansionModules[0].module
								showList = true
							}
							.sheet(isPresented: $showList) {
								MODList(selectedModule: $selectedModule) {
									showList = false
								}
							}
							.modifier(MODsViewStyle())
						expansionModules[1]
							.onPress {
								selectedModule = expansionModules[1].module
								showList = true
							}
							.sheet(isPresented: $showList) {
								MODList(selectedModule: $selectedModule) {
									showList = false
								}

							}
							.modifier(MODsViewStyle())
					}
					HStack {
						expansionModules[2]
							.onPress {
								selectedModule = expansionModules[2].module
								showList = true
							}
							.sheet(isPresented: $showList) {
								MODList(selectedModule: $selectedModule) {
									showList = false
								}

							}
							.modifier(MODsViewStyle())
						expansionModules[3]
							.onPress {
								selectedModule = expansionModules[3].module
								showList = true
							}
							.sheet(isPresented: $showList) {
								MODList(selectedModule: $selectedModule) {
									showList = false
								}
							}
							.modifier(MODsViewStyle())
					}
				}
				.padding(.top, 10)
				.padding(.bottom, 15)
				.frame(height: geometry.size.height * 0.355)
				
				HStack {
					Spacer()
					Button(action: {
						showAlert.toggle()
					}) {
						Text("Reset Calculator")
					}
					.alert(isPresented: $showAlert) {
						Alert(
							title: Text("Reset Calculator"),
							message: Text("This operation will clear all programs and memory registers"),
							primaryButton: .default(Text("Continue")) {
								calculator.resetCalculator(restoringMemory: false)
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
					})
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
		if let fPath = self.expansionModules[0].filePath {
			// We have something in Port1
			let moduleName = (fPath as NSString).lastPathComponent
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
		
		if let fPath = self.expansionModules[1].filePath {
			// We have something in Port2
			let moduleName = (fPath as NSString).lastPathComponent
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
		
		if let fPath = self.expansionModules[2].filePath {
			// We have something in Port3
			let moduleName = (fPath as NSString).lastPathComponent
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
		
		if let fPath = self.expansionModules[3].filePath {
			// We have something in Port4
			let moduleName = (fPath as NSString).lastPathComponent
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
		
		showSettings = false
		
		if needsRestart {
			calculator.resetCalculator(restoringMemory: true)
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView(showSettings: .constant(true))
    }
}
