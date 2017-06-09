//
//  NSAttributedString+Util.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func image(with size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIGraphicsGetCurrentContext()
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

extension NSAttributedString: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}
