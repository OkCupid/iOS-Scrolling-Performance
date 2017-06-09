//
//  NSMutableDictionary+Util.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import Foundation

extension NSMutableDictionary: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}
