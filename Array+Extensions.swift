//
//  Array+Extensions.swift
//  my41
//
//  Created by Miroslav Perovic on 2.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
	mutating func remove(_ object: Element) {
		guard let index = firstIndex(of: object) else { return }

		remove(at: index)
	}
	
}
