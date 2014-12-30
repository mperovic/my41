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
		let menuVC = self.splitViewItems[0].viewController as DebugMenuViewController
		let containerVC = self.splitViewItems[1].viewController as DebugContainerViewController
		menuVC.debugContainerViewController = containerVC

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

class DebugContainerViewController: NSViewController {
	var debugCPUViewController: DebugCPUViewController?
	var debugMemoryViewController: DebugMemoryViewController?
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		let segid = segue.identifier ?? "(none)"
		
		if segid == "showCPUView" {
			debugCPUViewController = segue.destinationController as? DebugCPUViewController
			debugCPUViewController?.debugContainerViewController = self
		}
		if segid == "showMemoryView" {
			debugMemoryViewController = segue.destinationController as? DebugMemoryViewController
			debugMemoryViewController?.debugContainerViewController = self
		}
	}
	
	override func viewDidLoad() {
		loadCPUViewController()
		let defaults = NSUserDefaults.standardUserDefaults()
		TRACE = defaults.integerForKey("traceActive")
		if TRACE == 0 {
			debugCPUViewController?.traceSwitch.state = NSOffState
		} else {
			debugCPUViewController?.traceSwitch.state = NSOnState
		}
	}
	
	func loadCPUViewController() {
		self.performSegueWithIdentifier("showCPUView", sender: self)
	}
	
	func loadMemoryViewController() {
		self.performSegueWithIdentifier("showMemoryView", sender: self)
	}
}


//MARK: -

class DebugerSegue: NSStoryboardSegue {
	override func perform() {
		let source = self.sourceController as NSViewController
		let destination = self.destinationController as NSViewController
		
		if source.view.subviews.count > 0 {
			let aView: AnyObject = source.view.subviews[0]
			if aView.isKindOfClass(NSView) {
				aView.removeFromSuperview()
			}
		}
		
		let dView = destination.view
		source.view.addSubview(dView)
		source.view.addConstraints(
			NSLayoutConstraint.constraintsWithVisualFormat(
				"H:|[dView]|",
				options: nil,
				metrics: nil,
				views: ["dView": dView]
			)
		)
		source.view.addConstraints(
			NSLayoutConstraint.constraintsWithVisualFormat(
				"V:|[dView]|",
				options: nil,
				metrics: nil,
				views: ["dView": dView]
			)
		)
	}
}
