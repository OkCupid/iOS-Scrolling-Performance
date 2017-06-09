//
//  OKMessageCell.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKMessageCell: UICollectionViewCell {
    
    static let reuseID = "kMessageCellReuseIdentifier"
    
    fileprivate let avatarButton = UIButton()
    fileprivate let bubbleImageView = UIImageView()
    fileprivate let messageLabel = UILabel()
    fileprivate let messageLabelImageView = UIImageView()
    
    fileprivate(set) var message: OKMessage?
    fileprivate(set) weak var assetFactory: OKConversationAssetFactory?
    fileprivate(set) weak var sizingFactory: OKConversationSizingFactory?
    
    var isMessageImageView = false {
        didSet {
            if isMessageImageView != oldValue {
                toggleVisibleMessageView()
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAvatarView()
        setupBubbleImageView()
        setupMessageViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    
    func configure(with message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) {
        self.message = message
        self.assetFactory = assetFactory
        self.sizingFactory = sizingFactory
        
        isMessageImageView = kIsOptimized
        
        configureAvatarImageView(with: message)
        configureBubbleImageView(with: message)
        configureMessageLabel(with: message, assetFactory: assetFactory)
        
        setNeedsLayout()
    }
    
    //MARK: - Configure Helpers
    
    fileprivate func configureAvatarImageView(with message: OKMessage) {
        avatarButton.isHidden = !message.isAvatarEnabled
        
        if !avatarButton.isHidden {
            avatarButton.setImage(message.avatarImage, for: .normal)
        }
    }
    
    fileprivate func configureBubbleImageView(with message: OKMessage) {
        if !kIsOptimized {
            bubbleImageView.transform = message.isIncoming ? CGAffineTransform(scaleX: -1, y: 1) : .identity
            bubbleImageView.tintColor = message.isIncoming ? .lightGray : .black
        }
    }
    
    fileprivate func configureMessageLabel(with message: OKMessage, assetFactory: OKConversationAssetFactory) {
        messageLabel.attributedText = assetFactory.messageAttributedString(with: message)
    }
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCell()
    }
    
    //MARK: - Layout Helpers
    
    fileprivate func layoutCell() {
        guard let message = message, let assetFactory = assetFactory, let sizingFactory = sizingFactory else {
            fatalError("OKMessageCell did not call configure(with:assetFactory:sizingFactory:) before layout")
        }
        
        let bounds = contentView.bounds
        
        let attributedString = assetFactory.messageAttributedString(with: message)

        let avatarSize = sizingFactory.avatarSize
        let labelSize = sizingFactory.messageLabelSize(for: bounds.size, message: message, attributedString: attributedString)
        let bubbleSize = sizingFactory.bubbleImageSize(for: labelSize)
        let bubbleLabelVerticalPadding = sizingFactory.bubbleLabelVerticalPadding
        let bubbleLabelHorizontalPadding = sizingFactory.bubbleLabelHorizontalPadding
        let bubbleTailWidth = sizingFactory.bubbleTailWidth
        let outerPadding = sizingFactory.messageOuterPadding
        
        if message.isIncoming {
            avatarButton.frame = CGRect(x: outerPadding,
                                        y: bounds.maxY - avatarSize.height,
                                        width: avatarSize.width,
                                        height: avatarSize.height)
            
            bubbleImageView.frame = CGRect(x: avatarButton.frame.maxX + outerPadding,
                                           y: 0,
                                           width: bubbleSize.width,
                                           height: bubbleSize.height)
            
            messageView().frame = CGRect(x: bubbleImageView.frame.origin.x + bubbleTailWidth + bubbleLabelHorizontalPadding,
                                         y: bubbleLabelVerticalPadding,
                                         width: labelSize.width,
                                         height: labelSize.height)
            
        } else {
            avatarButton.frame = CGRect(x: bounds.maxX - outerPadding - avatarSize.width,
                                        y: bounds.maxY - avatarSize.height,
                                        width: avatarSize.width,
                                        height: avatarSize.height)
            
            bubbleImageView.frame = CGRect(x: avatarButton.frame.origin.x - outerPadding - bubbleSize.width,
                                           y: 0,
                                           width: bubbleSize.width,
                                           height: bubbleSize.height)
            
            messageView().frame = CGRect(x: bubbleImageView.frame.origin.x + bubbleLabelHorizontalPadding,
                                         y: bubbleLabelVerticalPadding,
                                         width: labelSize.width,
                                         height: labelSize.height)
        }
        
        avatarButton.layer.cornerRadius = avatarButton.frame.height / 2
        bubbleImageView.image = assetFactory.bubbleImage(for: message)
        messageLabelImageView.image = kIsOptimized ? assetFactory.messageLabelImage(for: labelSize, message: message) : nil
    }
    
    fileprivate func messageView() -> UIView {
        return isMessageImageView ? messageLabelImageView : messageLabel
    }
    
    fileprivate func toggleVisibleMessageView() {
        messageLabel.frame = .zero
        messageLabelImageView.frame = .zero
        
        messageLabel.alpha = isMessageImageView ? 0 : 1
        messageLabelImageView.alpha = isMessageImageView ? 1 : 0
        
        setNeedsLayout()
    }
    
    //MARK: - Caching
    
    func cache(for size: CGSize, message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) {
        let attributedString = assetFactory.messageAttributedString(with: message)
        let labelSize = sizingFactory.messageLabelSize(for: size, message: message, attributedString: attributedString)
        
        _ = assetFactory.messageLabelImage(for: labelSize, message: message)
        _ = assetFactory.bubbleImage(for: message)
    }
    
    //MARK: - Sizing
    
    func sizeThatFits(_ size: CGSize, message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) -> CGSize {
        let attributedString = assetFactory.messageAttributedString(with: message)
        let labelSize = sizingFactory.messageLabelSize(for: size, message: message, attributedString: attributedString)
        let bubbleSize = sizingFactory.bubbleImageSize(for: labelSize)
        
        let avatarHeight = message.isAvatarEnabled ? sizingFactory.avatarSize.height : 0
        
        return CGSize(width: size.width, height: max(bubbleSize.height, avatarHeight))
    }
    
    //MARK: - Setup
    
    fileprivate func setupAvatarView() {
        avatarButton.imageView?.contentMode = .scaleAspectFill
        avatarButton.layer.masksToBounds = true
        contentView.addSubview(avatarButton)
    }
    
    fileprivate func setupBubbleImageView() {
        bubbleImageView.alpha = 0.9
        contentView.addSubview(bubbleImageView)
    }
    
    fileprivate func setupMessageViews() {
        messageLabel.numberOfLines = 0
        contentView.addSubview(messageLabel)
        contentView.addSubview(messageLabelImageView)
    }
    
}
