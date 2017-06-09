//
//  OKTimestampCell.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKTimestampCell: UICollectionViewCell {
    
    static let reuseID = "kTimestampCellReuseIdentifier"
    
    fileprivate let timestampLabel = UILabel()
    
    fileprivate(set) var message: OKMessage?
    fileprivate(set) weak var assetFactory: OKConversationAssetFactory?
    fileprivate(set) weak var sizingFactory: OKConversationSizingFactory?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTimestampLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    
    func configure(with message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) {
        self.message = message
        self.assetFactory = assetFactory
        self.sizingFactory = sizingFactory
        
        timestampLabel.attributedText = assetFactory.timestampAttributedString(with: message)
        
        setNeedsLayout()	
    }
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCell()
    }
    
    //MARK: - Layout Helpers
    
    fileprivate func layoutCell() {
        guard let sizingFactory = sizingFactory else {
            fatalError("OKTimestampCell did not call configure(with:assetFactory:sizingFactory:) before layout")
        }
        
        let topVerticalPadding = sizingFactory.timestampTopVerticalPadding
        let bottomVerticalPadding = sizingFactory.timestampBottomVerticalPadding
        
        timestampLabel.frame = CGRect(x: 0,
                                      y: topVerticalPadding,
                                      width: contentView.bounds.width,
                                      height: contentView.bounds.height - topVerticalPadding - bottomVerticalPadding)
    }
    
    //MARK: - Caching
    
    func cache(for size: CGSize, message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) {
        let attributedString = assetFactory.timestampAttributedString(with: message)
        _ = sizingFactory.timestampLabelSize(for: size, message: message, attributedString: attributedString)
    }

    //MARK: - Sizing
    
    func sizeThatFits(_ size: CGSize, message: OKMessage, assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory) -> CGSize {
        let attributedString = assetFactory.timestampAttributedString(with: message)
        let labelSize = sizingFactory.timestampLabelSize(for: size, message: message, attributedString: attributedString)
        let verticalPadding = sizingFactory.timestampTopVerticalPadding + sizingFactory.timestampBottomVerticalPadding
        
        return CGSize(width: size.width, height: labelSize.height + verticalPadding)
    }
    
    //MARK: - Setup
    
    fileprivate func setupTimestampLabel() {
        contentView.addSubview(timestampLabel)
    }
    
}
