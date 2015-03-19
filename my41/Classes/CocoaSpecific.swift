//
//  CocoaSpecific.swift
//  my41
//
//  Created by Miroslav Perovic on 2/7/15.
//  Copyright (c) 2015 iPera. All rights reserved.
//

import Foundation
import Cocoa

func displayAlert(message: String) {
	var alert:NSAlert = NSAlert()
	alert.messageText = message
	alert.runModal()
}

