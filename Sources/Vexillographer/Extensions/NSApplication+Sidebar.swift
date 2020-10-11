//
//  NSApplication+Sidebar.swift
//  Vexil: Vexilographer
//

#if os(macOS)

import AppKit

extension NSApplication {
    
    func toggleKeyWindowSidebar() {
        self.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
}

#endif
