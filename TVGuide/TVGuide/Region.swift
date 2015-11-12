//
//  Region.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 9/08/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import Foundation

class Region : NSObject {
    var id: Int = 0
    var name: String = ""
    
    override init() {
        super.init()
        self.id = 0
        self.name = ""
    }
    
    init(id: Int, name: String) {
        super.init()
        self.id = id
        self.name = name
    }
    
    static func regionsWithJSON(results: NSArray) -> [Region] {
        // Create an empty array of Albums to append to from this list
        var regions = [Region]()
        
        // Store the results in our table data array
        if results.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in results {
                
                var id = result["id"] as? Int
                var name = result["name"] as? String
                
                var newRegion = Region(id: id!, name: name!)
                regions.append(newRegion)
            }
        }
        return regions
    }

}
