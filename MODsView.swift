//
//  MODsView.swift
//  my41
//
//  Created by Miroslav Perovic on 30.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODsView: View {
	var mods = MODs.getModFiles()
	
	var port: HPPort {
		didSet {
			filePath = port.getFilePath()
		}
	}

	var filePath: String?
	var onPress = {}

	@State var module: MOD?

	@ViewBuilder
	var body: some View {
		if module == nil {
			GeometryReader { geometry in
				Button(action: {
					onPress()
				}, label: {
					Image(systemName: "pencil")
						.font(.system(size: 32))
				})
				.frame(width: geometry.size.width, height: geometry.size.height)
				.cornerRadius(5.0)
				.background(Color.white)
			}
		} else {
			VStack {
				MODDetailsView(module: module!)
				HStack {
					Button(action: {
						
					}, label: {
						Image(systemName: "pencil")
							.font(.system(size: 26))
					})
					.padding(.leading, 20)
					Spacer()
					Button(action: {
						
					}, label: {
						Image(systemName: "trash")
							.font(.system(size: 26))
					})
					.padding(.trailing, 20)
				}
			}
		}
	}
	
	func onPress(_ callback: @escaping () -> ()) -> some View {
		MODsView(port: port, onPress: callback)
	}
	
	private func selectModule() {
//		let alertController = UIAlertController(
//			title: "Port \(port)",
//			message: "Choose module",
//			preferredStyle: .alert
//		)
//
//		reloadModFiles()
//		for (_, element) in modFiles.enumerated() {
//			let modAction = UIAlertAction(title: (element as NSString).lastPathComponent, style: .default) { (result : UIAlertAction) -> Void in
//				self.filePath = element
//				self.oldFilePath = nil
//			}
//			alertController.addAction(modAction)
//		}
//		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
//			if let oldFilePath = self.oldFilePath {
//				self.filePath = oldFilePath
//				self.oldFilePath = nil
//			}
//		}
//		alertController.addAction(cancelAction)
//		settingsViewController?.present(alertController, animated: true, completion: nil)
	}
}

struct MODsView_Previews: PreviewProvider {
	@State static var selectedModule = MODs.getModFiles().first!
    static var previews: some View {
		MODsView(port: .port1)
		MODsView(port: .port1, module: selectedModule)
    }
}
