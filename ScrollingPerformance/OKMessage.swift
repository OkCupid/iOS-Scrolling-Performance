//
//  OKMessage.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

enum OKMessageComponents {
    case timestamp, message
}

final class OKMessage: NSObject {
    
    let avatarImage: UIImage
    let isAvatarEnabled: Bool
    let isIncoming: Bool
    let isTailEnabled: Bool
    let isTimestampEnabled: Bool
    let text: String
    let timestamp: Date
    
    init?(json: [String : Any]) {
        guard
            let avatarImage = json[kAvatarImageKey] as? UIImage,
            let isAvatarEnabled = json[kIsAvatarEnabledKey] as? Bool,
            let isIncoming = json[kIsIncomingKey] as? Bool,
            let isTailEnabled = json[kIsTailEnabledKey] as? Bool,
            let isTimestampEnabled = json[kIsTimestampEnabledKey] as? Bool,
            let text = json[kMessageTextKey] as? String,
            let timestamp = json[kMessageTimestampKey] as? Date
            else { return nil }
        
        self.avatarImage = avatarImage
        self.isAvatarEnabled = isAvatarEnabled
        self.isIncoming = isIncoming
        self.isTailEnabled = isTailEnabled
        self.isTimestampEnabled = isTimestampEnabled
        self.text = text
        self.timestamp = timestamp
    }
    
    //MARK: - Helpers
    
    func components() -> [OKMessageComponents] {
        return isTimestampEnabled ? [.timestamp, .message] : [.message]
    }
    
}
