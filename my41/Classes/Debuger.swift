//
//  Debuger.swift
//  my41
//
//  Created by Miroslav Perovic on 9/21/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Cocoa

class DebugWindowController: NSWindowController {
	
}


// MARK: - SpitView

class DebugSplitViewController: NSSplitViewController {
	
	override func viewWillAppear() {
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.Width,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 194
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 379
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.Width,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 710
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal,
				toItem: nil,
				attribute: NSLayoutAttribute.NotAnAttribute,
				multiplier: 0,
				constant: 379
			)
		)
	}
}
