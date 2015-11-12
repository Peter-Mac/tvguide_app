//
//  Program.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 30/07/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import Foundation

struct Program {
    let id: Int
    let start: String
    let stop: String
    let title: String
    let subtitle: String
    let description: String
    let channel_id: Int
    
    init(id: Int, start: String, stop: String, title: String, subtitle: String, description: String, channel_id: Int) {
        self.id = id
        self.start = start
        self.stop = stop
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.channel_id = channel_id
    }

    static func programsWithJSON(results: NSArray) -> [Program] {
        // Create an empty array of Albums to append to from this list
        var programs = [Program]()
        
        // Store the results in our table data array
        if results.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in results {
                
                var id = result["id"] as? Int
                var title = result["title"] as? String
                var start = result["start"] as? String
                var stop = result["stop"] as? String
                var subtitle = result["subtitle"] as? String
                if subtitle == nil {
                    subtitle = "N/A"
                }
                
                var description = result["desc"] as? String
                if description == nil {
                    description = "No description available"
                }
                
                var channel_id = result["channel_id"] as? Int
                
                
                var newProgram = Program(id: id!, start: start!, stop: stop!, title: title!, subtitle: subtitle!, description: description!, channel_id: channel_id!)
                programs.append(newProgram)
            }
        }
        return programs
    }
}
