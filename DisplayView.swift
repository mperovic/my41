//
//  DisplayView.swift
//  my41
//
//  Created by Miroslav Perovic on 5.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    var body: some View {
		GeometryReader { geometry in
			
			EmptyView()
				.background(Color.gray)
		}
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
