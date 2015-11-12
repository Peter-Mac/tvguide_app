//
//  Channel.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 31/07/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import Foundation

class Channel : NSObject {
    var id: Int = 0
    var code: String = ""
    var name: String = ""
    var iconURL: String? = ""
    var imageURL: String? = ""
    override init() {
        super.init()
        self.id = 0
        self.code = ""
        self.name = ""
    }
    
    init(id: Int, code: String, name: String, iconURL: String?=nil) {
        super.init()
        self.id = id
        self.code = code
        self.name = name
        if let unwrappedURL = iconURL {
            self.iconURL = unwrappedURL
        }
    }
    
    init(JSONDictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        self.id = JSONDictionary["id"] as! Int
        self.code = JSONDictionary["code"] as! String
        self.name = JSONDictionary["name"] as! String
        self.iconURL = JSONDictionary["imageURL"] as? String
        
    }
    
    static func channelsWithJSON(results: NSArray) -> [Channel] {
        var channels = [Channel]()
        
        // Store the results in our table data array
        if results.count>0 {
            
            for result in results {
                
                var id = result["id"] as? Int
                var code = result["code"] as? String
                var name = result["name"] as? String
                var iconURL = result["imageURL"] as? String
              
                var newChannel: Channel
                
                if iconURL != nil {
                    newChannel = Channel(id: id!, code: code!, name: name!, iconURL: iconURL)
                } else {
                    newChannel = Channel(id: id!, code: code!, name: name!)
                }
                channels.append(newChannel)
            }
        }

        return channels
    }

    static func channelWithJSON(result: NSArray) -> Channel {
        var channel = Channel()
        
        // Store the results in our table data array
        if result.count==1 {
            
            var id = result[0]["id"] as? Int
            var code = result[0]["code"] as? String
            var name = result[0]["name"] as? String
            var iconURL = result[0]["imageURL"] as? String
            
            if iconURL != nil {
                channel = Channel(id: id!, code: code!, name: name!, iconURL: iconURL)
            } else {
                channel = Channel(id: id!, code: code!, name: name!)
            }
            
        
        }
        
        return channel
    }
    
}
