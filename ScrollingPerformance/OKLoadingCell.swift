//
//  OKLoadingCell.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKLoadingCell: UICollectionViewCell {
    
    static let reuseID = "kLoadingCellReuseIdentifier"
    
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "UFO"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    fileprivate var rotationAnimation: CABasicAnimation?
    
    fileprivate(set) weak var sizingFactory: OKConversationSizingFactory?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    
    func configure(with sizingFactory: OKConversationSizingFactory) {
        self.sizingFactory = sizingFactory
        
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
            fatalError("OKLoadingCell did not call configure(with:) before layout")
        }
        
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: sizingFactory.loadingCellImageLength,
                                 height: sizingFactory.loadingCellImageLength)
        
        imageView.center = contentView.center
    }
    
    //MARK: - Animation
    
    func startAnimating() {
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        guard let rotationAnimation = rotationAnimation else {
            return
        }
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = .pi * 2.0
        rotationAnimation.duration = 1.25
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        
        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnimating() {
        layer.removeAllAnimations()
        rotationAnimation = nil
    }
    
}
