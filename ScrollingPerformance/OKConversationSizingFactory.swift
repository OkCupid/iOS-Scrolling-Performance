//
//  OKConversationSizingFactory.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKConversationSizingFactory {
    
    fileprivate let sizingCache: OKConversationSizingCache?
    fileprivate let measuringLabel = UILabel()
    
    // Message Cell
    let avatarSize = CGSize(width: 45, height: 45)
    let avatarToBubblePadding: CGFloat = 8
    let bubbleTailWidth: CGFloat = 6
    let bubbleLabelHorizontalPadding: CGFloat = 16
    let bubbleTrailingPadding: CGFloat = 90
    let bubbleLabelVerticalPadding: CGFloat = 12
    let messageOuterPadding: CGFloat = 8
    let messageSpacing = 1 / UIScreen.main.scale
    
    // Timestamp Cell
    let timestampTopVerticalPadding: CGFloat = 12
    let timestampBottomVerticalPadding: CGFloat = 6
    
    // Loading Cell
    let loadingCellHeight: CGFloat = 70
    let loadingCellImageLength: CGFloat = 35
    
    //MARK: - Lifecycle
    
    init(sizingCache: OKConversationSizingCache? = OKConversationSizingCache()) {
        self.sizingCache = kIsOptimized ? sizingCache : nil
    }
    
    //MARK: - Message Sizes
    
    func bubbleImageSize(for labelSize: CGSize) -> CGSize {
        var bubbleSize = labelSize
        bubbleSize.width += bubbleTailWidth + bubbleLabelHorizontalPadding * 2
        bubbleSize.height += bubbleLabelVerticalPadding * 2
        
        return bubbleSize
    }
    
    func messageLabelSize(for size: CGSize, message: OKMessage, attributedString: NSAttributedString) -> CGSize {
        let availableWidth = availableMessageLabelWidth(for: size)
        
        if let messageLabelSize = sizingCache?.cachedMessageLabelSize(availableWidth: availableWidth, message: message) {
            return messageLabelSize
            
        } else {
            measuringLabel.attributedText = attributedString
            measuringLabel.preferredMaxLayoutWidth = availableWidth
            measuringLabel.numberOfLines = 0
            
            let messageLabelSize = measuringLabel.sizeThatFits(CGSize(width: availableWidth, height: .infinity))
            sizingCache?.setCachedMessageLabelSize(messageLabelSize, availableWidth: availableWidth, message: message)
            
            return messageLabelSize
        }
    }
    
    //MARK: - Message Sizes Helpers
    
    fileprivate func availableMessageLabelWidth(for size: CGSize) -> CGFloat {
        return size.width - messageOuterPadding - avatarSize.width - avatarToBubblePadding - bubbleTailWidth - bubbleLabelHorizontalPadding * 2 - bubbleTrailingPadding - messageOuterPadding
    }
    
    //MARK: - Timestamp Sizes
    
    func timestampLabelSize(for size: CGSize, message: OKMessage, attributedString: NSAttributedString) -> CGSize {
        if let timestampLabelSize = sizingCache?.cachedTimestampLabelSize(for: size, message: message) {
            return timestampLabelSize
            
        } else {
            measuringLabel.attributedText = attributedString
            measuringLabel.preferredMaxLayoutWidth = size.width
            measuringLabel.numberOfLines = 1
            
            let timestampLabelSize = measuringLabel.sizeThatFits(size)
            sizingCache?.setCachedTimestampLabelSize(timestampLabelSize, for: size, message: message)
            
            return timestampLabelSize
        }
    }
    
}
