//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(visionOS)

import UIKit

extension String {
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
}

#elseif os(macOS)

import Cocoa

extension String {
    func copyToPasteboard() {
        NSPasteboard.general.setString(self, forType: .string)
    }
}

#endif
