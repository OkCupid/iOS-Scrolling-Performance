//
//  OKConversationMessageClient.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

let kAvatarImageKey = "kAvatarImageKey"
let kIsAvatarEnabledKey = "kIsAvatarEnabledKey"
let kIsIncomingKey = "kIsIncomingKey"
let kIsTailEnabledKey = "kIsTailEnabledKey"
let kIsTimestampEnabledKey = "kIsTimestampEnabledKey"
let kMessageTextKey = "kMessageTextKey"
let kMessageTimestampKey = "kMessageTimestampKey"

final class OKConversationMessageClient {
    
    fileprivate let alphabet = "abcdefghijklmnopqrstuvwxyz"
    fileprivate let mixedCharacters = "abc🚀defghi✨jklmnopqr🌎💥stuvwxyz🌙"
    fileprivate let emojis = "💥✨🌎🌍🌏🔭🌙💫🚀🛰🤖🐵👨‍🚀🌕🇺🇸👽👾🖖"
    
    //MARK: - Create Conversation
    
    func createConversation(sideChangeCount: Int) -> [AnyObject] {
        
        var objects = [AnyObject]()
        
        let string = emojis
        
        var characterArray = string.characters.map({ String($0) })
        
        let characterArrayMaxIndex = characterArray.count - 1
        
        var isIncomingMessage = true
        var isTimestampMessage = true
        
        var currentIndex = 0
        
        for sideChangeIndex in 0..<sideChangeCount {
            
            isIncomingMessage = sideChangeIndex % 2 == 0
            
            let minMessagesInARow = 1
            let messagesInARow = Int(arc4random_uniform(4)) + minMessagesInARow
            
            for messageInARowIndex in 0..<messagesInARow {
                
                let isLastMessage = messageInARowIndex == messagesInARow - 1
                isTimestampMessage = messageInARowIndex == 0
                
                let isFirstMessageInConvo = messageInARowIndex == 0 && sideChangeIndex == 0
                
                let minCharacterLength = 1
                let characterLength = Int(arc4random_uniform(20)) + minCharacterLength
                
                let minRangeIndex = currentIndex
                let maxRangeIndex = min(minRangeIndex + characterLength, characterArrayMaxIndex)
                
                currentIndex = maxRangeIndex == characterArrayMaxIndex ? 0 : maxRangeIndex + 1
                
                let avatarImage = isIncomingMessage ? #imageLiteral(resourceName: "IncomingUser") : #imageLiteral(resourceName: "OutgoingUser")
                let isAvatarEnabled = isLastMessage
                let isTailEnabled = isLastMessage
                let isTimestampEnabled = isFirstMessageInConvo || (isTimestampMessage && arc4random_uniform(3) % 2 == 0)
                let messageText = characterArray[minRangeIndex...maxRangeIndex].joined()
                let messageTimestamp = Date(timeInterval: TimeInterval(-3600 * (sideChangeCount - sideChangeIndex) - Int(arc4random_uniform(3600))), since: Date())
                
                let json: [String : Any] = [kAvatarImageKey: avatarImage,
                                            kIsAvatarEnabledKey : isAvatarEnabled,
                                            kIsIncomingKey : isIncomingMessage,
                                            kIsTailEnabledKey : isTailEnabled,
                                            kIsTimestampEnabledKey : isTimestampEnabled,
                                            kMessageTextKey : messageText,
                                            kMessageTimestampKey : messageTimestamp]
                
                if let message = OKMessage(json: json) {
                    objects.append(message)
                }
            }
        }
        
        return objects
    }
    
}
