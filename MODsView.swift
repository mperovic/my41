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
	
	@State var showAlert = false
	@State var filePath: String?
	@State var oldFilePath: String?

	var body: some View {
		GeometryReader { geometry in
			Button(action: {
				showAlert = filePath != nil
			}, label: {
				Text("Button")
			})
			.frame(width: geometry.size.width, height: geometry.size.height)
			.cornerRadius(5.0)
		}.actionSheet(isPresented: $showAlert, content: {
			let emptyPortButton = ActionSheet.Button.default(Text("Empty port")) {
				filePath = nil
			}
			let replaceModuleButton = ActionSheet.Button.default(Text("Replace module")) {
				oldFilePath = filePath
				filePath = nil
				selectModule()
			}
			let cancelButton = ActionSheet.Button.cancel(Text("Cancel")) {
				if let path = oldFilePath {
					filePath = path
					oldFilePath = nil
				}
			}
			return ActionSheet(
				title: Text("Reset Calculator"),
				message: Text("What do you want to do with the module"),
				buttons: [emptyPortButton, replaceModuleButton, cancelButton]
			)
		})
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
    static var previews: some View {
		MODsView(port: .port1)
    }
}
