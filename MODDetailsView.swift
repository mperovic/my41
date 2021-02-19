//
//  MODDetailsView.swift
//  my41
//
//  Created by Miroslav Perovic on 28.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct MODDetailsView: View {
	var module: MOD
	var short: Bool
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(module.moduleHeader.title)
				.fontWeight(.bold)
				.lineLimit(nil)
			if !short {
				Text("version: \(module.moduleHeader.version)")
				Text("author: \(module.moduleHeader.author)")
			}
		}
	}
}

struct MODDetailsView_Previews: PreviewProvider {
	static var mod = MODs.getModFiles()[MODs.getModFiles().keys.first!]!
    static var previews: some View {
		MODDetailsView(module: mod, short: false)
    }
}
