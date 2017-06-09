//
//  OKConversationAssetFactory.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKConversationAssetFactory {
    
    fileprivate let assetCache: OKConversationAssetCache?
    fileprivate let dateFormatter = DateFormatter()
    
    //MARK: - Lifecycle
    
    init(assetCache: OKConversationAssetCache? = OKConversationAssetCache()) {
        self.assetCache = kIsOptimized ? assetCache : nil
    }
    
    //MARK: - Message Assets
    
    func bubbleImage(for message: OKMessage) -> UIImage {
        if let bubbleImage = assetCache?.cachedMessageBubbleImage(for: message) {
            return bubbleImage
            
        } else {
            let bubbleColor = message.isIncoming ? UIColor.lightGray : UIColor.black
            var bubbleImage = message.isTailEnabled ? #imageLiteral(resourceName: "MessageBubble") : #imageLiteral(resourceName: "MessageBubbleNoTail")
            
            if kIsOptimized {
                bubbleImage = bubbleImage.image(maskColor: bubbleColor.cgColor)
                
            } else {
                bubbleImage = bubbleImage.withRenderingMode(.alwaysTemplate)
            }
            
            if message.isIncoming && kIsOptimized, let cgImage = bubbleImage.cgImage {
                bubbleImage = UIImage(cgImage: cgImage, scale: bubbleImage.scale, orientation: .upMirrored)
            }
            
            let center = CGPoint(x: bubbleImage.size.width / 2, y: bubbleImage.size.height / 2)
            let capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x)
            
            bubbleImage = bubbleImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            assetCache?.setCachedMessageBubbleImage(bubbleImage, message: message)
            
            return bubbleImage
        }
    }
    
    func messageAttributedString(with message: OKMessage) -> NSAttributedString {
        if let attributedString = assetCache?.cachedMessageAttributedString(message: message) {
            return attributedString
            
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attributes = [NSForegroundColorAttributeName : message.isIncoming ? UIColor.black : UIColor.white,
                              NSFontAttributeName : UIFont.systemFont(ofSize: 16),
                              NSParagraphStyleAttributeName : paragraphStyle]
            
            let attributedString = NSAttributedString(string: message.text, attributes: attributes)
            assetCache?.setCachedMessageAttributedString(attributedString, message: message)
            
            return attributedString
        }
    }
    
    func messageLabelImage(for labelSize: CGSize, message: OKMessage) -> UIImage {
        if let messageLabelImage = assetCache?.cachedMessageLabelImage(for: labelSize, message: message) {
            return messageLabelImage
            
        } else {
            let attributedString = messageAttributedString(with: message)
            let messageLabelImage = attributedString.image(with: labelSize)
            assetCache?.setCachedMessageLabelImage(messageLabelImage, forSize: labelSize, message: message)
            
            return messageLabelImage
        }
    }
    
    //MARK: - Timestamp Assets
    
    func timestampAttributedString(with message: OKMessage) -> NSAttributedString {
        if let attributedString = assetCache?.cachedTimestampAttributedString(message: message) {
            return attributedString
            
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes = [NSForegroundColorAttributeName : UIColor.white,
                              NSFontAttributeName : UIFont.systemFont(ofSize: 12),
                              NSParagraphStyleAttributeName : paragraphStyle]
            
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            let attributedString = NSAttributedString(string: dateFormatter.string(from: message.timestamp), attributes: attributes)
            assetCache?.setCachedTimestampAttributedString(attributedString, message: message)
            
            return attributedString
        }
    }
    
}
