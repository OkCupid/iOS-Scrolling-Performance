//
//  UIImage+Util.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

extension UIImage {
    
    func image(maskColor: CGColor) -> UIImage {
        
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -(imageRect.size.height))
        context.clip(to: imageRect, mask: cgImage)
        context.setFillColor(maskColor)
        context.fill(imageRect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        UIGraphicsEndImageContext()
        
        return image;
    }
    
}

extension UIImage: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}
