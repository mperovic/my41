//
//  Text+Extensions.swift
//  my41
//
//  Created by Miroslav Perovic on 5.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

extension Text {
	init(attributedString: NSAttributedString) {
		self.init(attributedString.string)
	}
}
