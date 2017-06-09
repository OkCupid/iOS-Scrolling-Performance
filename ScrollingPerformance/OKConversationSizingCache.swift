//
//  OKConversationSizingCache.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKConversationSizingCache {
    
    fileprivate var messageLabelSizeCache = NSCache<OKMessage, NSMutableDictionary>()
    fileprivate var timestampLabelSizeCache = NSCache<OKMessage, NSMutableDictionary>()
    
    //MARK: - Lifecycle
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Message Label Size
    
    func cachedMessageLabelSize(availableWidth: CGFloat, message: OKMessage) -> CGSize? {
        return messageLabelSizeCache.object(forKey: message)?[availableWidth] as? CGSize
    }
    
    func setCachedMessageLabelSize(_ messageLabelSize: CGSize, availableWidth: CGFloat, message: OKMessage) {
        if let currentCache = messageLabelSizeCache.object(forKey: message) {
            currentCache[availableWidth] = messageLabelSize
            messageLabelSizeCache.setObject(currentCache, forKey: message)
            
        } else {
            let currentCache = NSMutableDictionary()
            currentCache[availableWidth] = messageLabelSize
            messageLabelSizeCache.setObject(currentCache, forKey: message)
        }
    }
    
    //MARK: - Timestamp Label Size
    
    func cachedTimestampLabelSize(for size: CGSize, message: OKMessage) -> CGSize? {
        return timestampLabelSizeCache.object(forKey: message)?[size.width] as? CGSize
    }
    
    func setCachedTimestampLabelSize(_ timestampLabelSize: CGSize, for size: CGSize, message: OKMessage) {
        if let currentCache = timestampLabelSizeCache.object(forKey: message) {
            currentCache[size.width] = timestampLabelSize
            timestampLabelSizeCache.setObject(currentCache, forKey: message)
            
        } else {
            let currentCache = NSMutableDictionary()
            currentCache[size.width] = timestampLabelSize
            timestampLabelSizeCache.setObject(currentCache, forKey: message)
        }
    }
    
    //MARK: - Notifications
    
    @objc fileprivate func didReceiveMemoryWarning() {
        clearCache()
    }
    
    //MARK: Cache Maintenance
    
    func clearCache() {
        messageLabelSizeCache.removeAllObjects()
        timestampLabelSizeCache.removeAllObjects()
    }
    
}
