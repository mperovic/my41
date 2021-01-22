//
//  my41cx-ios_App.swift
//  my41cx-ios
//
//  Created by Miroslav Perovic on 20.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

@main
struct My41cx_ios_App: App {
	var body: some Scene {
		WindowGroup {
			My41View()
				.environmentObject(Keys())
		}
	}
}
