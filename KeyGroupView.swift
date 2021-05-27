//
//  KeyGroupView.swift
//  my41
//
//  Created by Miroslav Perovic on 5.1.21..
//  Copyright © 2021 iPera. All rights reserved.
//

import SwiftUI

struct KeyGroupView: View {
	var keys: [CalcKey]
	var isModeGroup: Bool = false
	var isEnterGroup = false
	
	let spacing: CGFloat = 20
	
	var body: some View {
		GeometryReader { geometry in
			let height = isModeGroup ? 20 : getButtonWidth(for: geometry.size.width, buttons: 5) * 0.7813
			
			HStack(spacing: getSpacing(for: geometry.size.width)) {
				KeyView(key: keys[0], width: isEnterGroup ? getEnterWidth(for: geometry.size.width) : getWidth(for: geometry.size.width, larger: keys.count == 4), height: height)
					.frame(width: isEnterGroup ? getEnterWidth(for: geometry.size.width) : getWidth(for: geometry.size.width, larger: keys.count == 4), height: height)
				KeyView(key: keys[1], width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
					.frame(width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
				if isModeGroup { Spacer() }
				KeyView(key: keys[2], width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
					.frame(width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
				KeyView(key: keys[3], width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
					.frame(width: getWidth(for: geometry.size.width, larger: isEnterGroup ? false : keys.count == 4), height: height)
				if keys.count == 5 { KeyView(key: keys[4], width: getWidth(for: geometry.size.width, larger: false), height: height)
					.frame(width: getWidth(for: geometry.size.width, larger: false), height: height)
				}
			}
		}
    }
	
	func getButtonWidth(for groupWidth: CGFloat, buttons: Int) -> CGFloat {
		if buttons == 5 {
			return (groupWidth - 4 * spacing) / CGFloat(5)
		} else {
			return getButtonWidth(for: groupWidth, buttons: 5) * 1.16
		}
	}
	
	func getEnterWidth(for groupWidth: CGFloat) -> CGFloat {
		getButtonWidth(for: groupWidth, buttons: 5) * 2 + spacing
	}
	
	func getModeWidth(for groupWidth: CGFloat) -> CGFloat {
		getButtonWidth(for: groupWidth, buttons: 5) + spacing / 2
	}
	
	func getWidth(for groupWidth: CGFloat, larger: Bool) -> CGFloat {
		if isModeGroup {
			return getModeWidth(for: groupWidth)
		} else {
			return getButtonWidth(for: groupWidth, buttons: 5) * (larger ? 1.16 : 1.0)
		}
	}
	
	func getSpacing(for groupWidth: CGFloat) -> CGFloat {
		if isModeGroup {
			return 0
		} else if keys.count == 4 && !isEnterGroup {
			return (groupWidth - getButtonWidth(for: groupWidth, buttons: 4) * 4) / CGFloat(3)
		} else {
			return spacing
		}
	}
}

struct KeyGroupView_Previews: PreviewProvider {
	static var keys = Keys()

    static var previews: some View {
		KeyGroupView(keys: keys.modeKeys, isModeGroup: true)
		KeyGroupView(keys: keys.keys1)
		KeyGroupView(keys: keys.keys4, isEnterGroup: true)
		KeyGroupView(keys: keys.keys6)
    }
}
