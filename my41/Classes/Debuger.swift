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
		let menuVC = self.splitViewItems[0].viewController as! DebugMenuViewController
		let containerVC = self.splitViewItems[1].viewController as! DebugContainerViewController
		menuVC.debugContainerViewController = containerVC

		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutConstraint.Attribute.width,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: nil,
				attribute: NSLayoutConstraint.Attribute.notAnAttribute,
				multiplier: 0,
				constant: 194
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[0].viewController.view,
				attribute: NSLayoutConstraint.Attribute.height,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: nil,
				attribute: NSLayoutConstraint.Attribute.notAnAttribute,
				multiplier: 0,
				constant: 379
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutConstraint.Attribute.width,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: nil,
				attribute: NSLayoutConstraint.Attribute.notAnAttribute,
				multiplier: 0,
				constant: 710
			)
		)
		self.view.addConstraint(
			NSLayoutConstraint(
				item: self.splitViewItems[1].viewController.view,
				attribute: NSLayoutConstraint.Attribute.height,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: nil,
				attribute: NSLayoutConstraint.Attribute.notAnAttribute,
				multiplier: 0,
				constant: 379
			)
		)
	}
}

class DebugContainerViewController: NSViewController {
	var debugCPUViewController: DebugCPUViewController?
	var debugMemoryViewController: DebugMemoryViewController?

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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
		let defaults = UserDefaults.standard
		TRACE = defaults.integer(forKey: "traceActive")
		if TRACE == 0 {
			debugCPUViewController?.traceSwitch.state = NSControl.StateValue.off
		} else {
			debugCPUViewController?.traceSwitch.state = NSControl.StateValue.on
		}
	}
	
	func loadCPUViewController() {
		self.performSegue(withIdentifier: "showCPUView", sender: self)
	}
	
	func loadMemoryViewController() {
		self.performSegue(withIdentifier: "showMemoryView", sender: self)
	}
}


//MARK: -

class DebugerSegue: NSStoryboardSegue {
	override func perform() {
		let source = self.sourceController as! NSViewController
		let destination = self.destinationController as! NSViewController
		
		if source.view.subviews.count > 0 {
			let aView: AnyObject = source.view.subviews[0]
			if aView is NSView {
				aView.removeFromSuperview()
			}
		}
		
		let dView = destination.view
		source.view.addSubview(dView)
		source.view.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[dView]|",
				options: [],
				metrics: nil,
				views: ["dView": dView]
			)
		)
		source.view.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[dView]|",
				options: [],
				metrics: nil,
				views: ["dView": dView]
			)
		)
	}
}
