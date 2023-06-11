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

/// A wrapper type used in snapshots to support diagnostics
///
/// - Note: It does incur the penalty of keeping boxed and unboxed copies of flag values in
/// memory. The alternative to that is the diagnostics setup needing to walk the flag
/// hierarchy so we can get access to the generic type. This will be improved in the future.
///
//struct LocatedFlagValue {
//
//    /// The name of the source that the value was located in.
//    /// Optional means no source included it, ie its a default value
//    let source: String?
//
//    /// The raw type-erased value
//    let value: Any
//
//    /// The boxed value. This will be nil if diagnostics was not enabled.
//    let boxed: BoxedFlagValue?
//
//
//    // MARK: - Initialisation
//
//    /// Memberwise initialisation of a LocatedFlagValue
//    ///
//    /// - Parameters:
//    ///   - source:     The name of the source that the value was located in.
//    ///   - value:      The raw type-erased value
//    ///   - boxed:      The boxed value. This will be nil if diagnostics was not enabled.
//    private init(source: String?, value: Any, boxed: BoxedFlagValue?) {
//        self.source = source
//        self.value = value
//        self.boxed = boxed
//    }
//
//    /// Initialises a new `LocatedFlagValue`` by type-erasing the provided Value
//    ///
//    /// If diagnostics are enabled the `BoxedFlagValue` will be captured alongside the type-erased value
//    ///
//    init(source: String?, value: some FlagValue, diagnosticsEnabled: Bool) {
//        self.init(
//            source: source,
//            value: value,
//            boxed: diagnosticsEnabled ? value.boxedFlagValue : nil
//        )
//    }
//
//}
//
//
//// MARK: - LookupResult Conversion
//
//extension LocatedFlagValue {
//
//    /// Initialises a new `LocatedFlagValue`` by type-erasing the provided `LookupResult`
//    ///
//    /// If diagnostics are enabled the `BoxedFlagValue` will be captured alongside the type-erased value
//    ///
//    init(lookupResult: LookupResult<some FlagValue>, diagnosticsEnabled: Bool) {
//        self.init(
//            source: lookupResult.source,
//            value: lookupResult.value,
//            diagnosticsEnabled: diagnosticsEnabled
//        )
//    }
//
//    /// Returns the specialised `LookupResult` for the receiving `LocatedFlagValue`
//    func toLookupResult<Value>() -> LookupResult<Value>? {
//        guard let value = value as? Value else {
//            return nil
//        }
//        return LookupResult(source: source, value: value)
//    }
//
//}
