//
//  OKConversationAssetCache.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKConversationAssetCache {
    
    fileprivate var messageAttributedStringCache = NSCache<OKMessage, NSAttributedString>()
    fileprivate var messageBubbleImageCache = NSCache<OKMessage, UIImage>()
    fileprivate var messageLabelImageCache = NSCache<OKMessage, NSMutableDictionary>()
    fileprivate var timestampAttributedStringCache = NSCache<OKMessage, NSAttributedString>()
    
    //MARK: - Lifecycle
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Message Attributed String
    
    func cachedMessageAttributedString(message: OKMessage) -> NSAttributedString? {
        return messageAttributedStringCache.object(forKey: message)
    }
    
    func setCachedMessageAttributedString(_ messageAttributedString: NSAttributedString, message: OKMessage) {
        messageAttributedStringCache.setObject(messageAttributedString, forKey: message)
    }
    
    //MARK: - Message Bubble Image
    
    func cachedMessageBubbleImage(for message: OKMessage) -> UIImage? {
        return messageBubbleImageCache.object(forKey: message)
    }
    
    func setCachedMessageBubbleImage(_ messageBubbleImage: UIImage, message: OKMessage) {
        messageBubbleImageCache.setObject(messageBubbleImage, forKey: message)
    }
    
    //MARK: - Message Label Image
    
    func cachedMessageLabelImage(for size: CGSize, message: OKMessage) -> UIImage? {
        return messageLabelImageCache.object(forKey: message)?[NSValue(cgSize: size)] as? UIImage
    }
    
    func setCachedMessageLabelImage(_ messageLabelImage: UIImage, forSize: CGSize, message: OKMessage) {
        if let currentCache = messageLabelImageCache.object(forKey: message) {
            currentCache[NSValue(cgSize: forSize)] = messageLabelImage
            messageLabelImageCache.setObject(currentCache, forKey: message)
            
        } else {
            let currentCache = NSMutableDictionary()
            currentCache[NSValue(cgSize: forSize)] = messageLabelImage
            messageLabelImageCache.setObject(currentCache, forKey: message)
        }
    }
    
    //MARK: - Timestamp Attributed String
    
    func cachedTimestampAttributedString(message: OKMessage) -> NSAttributedString? {
        return timestampAttributedStringCache.object(forKey: message)
    }
    
    func setCachedTimestampAttributedString(_ timestampAttributedString: NSAttributedString, message: OKMessage) {
        timestampAttributedStringCache.setObject(timestampAttributedString, forKey: message)
    }
    
    //MARK: - Notifications
    
    @objc fileprivate func didReceiveMemoryWarning() {
        clearCache()
    }
    
    //MARK: Cache Maintenance
    
    func clearCache() {
        messageAttributedStringCache.removeAllObjects()
        messageBubbleImageCache.removeAllObjects()
        messageLabelImageCache.removeAllObjects()
        timestampAttributedStringCache.removeAllObjects()
    }
    
}
