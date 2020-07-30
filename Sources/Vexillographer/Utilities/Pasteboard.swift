//
//  Pasteboard.swift
//  Vexil: Vexillographer
//
//  Created by Rob Amos on 30/7/20.
//

#if os(iOS)

import UIKit

extension String {
    func copyToPasteboard () {
        UIPasteboard.general.string = self
    }
}

#elseif os(macOS)

import Cocoa

extension String {
    func copyToPasteboard () {
        NSPasteboard.general.setString(self, forType: .string)
    }
}

#endif
