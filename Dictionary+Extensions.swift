//
//  Dictionary+Extensions.swift
//  my41
//
//  Created by Miroslav Perovic on 18.2.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
	func key(from value: Value) -> Key? {
		return self.first(where: { $0.value == value })?.key
	}
}
