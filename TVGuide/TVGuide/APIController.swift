//
//  APIController.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 30/07/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSArray)
    func didReceiveRegionsResults(results: NSArray)
    func didReceiveChannelResults(result: Channel)
    func didReceiveChannelsResults(results : NSArray)
    func didReceiveError(error :NSError)
}

class APIController {

    var delegate: APIControllerProtocol
    
    var baseURL:String
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
            baseURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Base API URL") as! String
    }

    func getRegions() {
        let urlPath = baseURL + "/regions.json"
        let url = NSURL(string: urlPath)
        
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 30
        session.configuration.timeoutIntervalForResource = 60
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                self.delegate.didReceiveError(error)
            }
            var err: NSError?
            //if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String: AnyObject],
            
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                    //if let results: NSArray = jsonResult as? NSArray {
                    self.delegate.didReceiveRegionsResults(jsonResult)
                //}
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
        
        
    }

    func getChannel(id : Int) {
        
        let urlPath = baseURL + "/channels.json?id=" + String(id)
        let url = NSURL(string: urlPath)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                self.delegate.didReceiveError(error)
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let dictionary: Dictionary<String, AnyObject> = jsonResult as? Dictionary<String, AnyObject>{
                    let aChannel = Channel(JSONDictionary: dictionary )
                    self.delegate.didReceiveChannelResults(aChannel)
                }
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
        
    }

    func getChannelsforRegion(regionId : Int) {
    
        let urlPath = baseURL + "/channels.json?region_id=" + String(regionId)
        let url = NSURL(string: urlPath)
        
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 30
        session.configuration.timeoutIntervalForResource = 60
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                self.delegate.didReceiveError(error)
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray{
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                //if let results = jsonResult as? NSArray {
                    self.delegate.didReceiveChannelsResults(jsonResult)
                //}
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
    }
    
    func getChannels() {
        
        let urlPath = baseURL + "/channels.json"
        let url = NSURL(string: urlPath)
        
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 30
        session.configuration.timeoutIntervalForResource = 60
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                self.delegate.didReceiveError(error)
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let results: NSArray = jsonResult["channels"] as? NSArray {
                    self.delegate.didReceiveChannelsResults(results)
                }
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
        
    }
    func searchProgramsFor(searchTerm: String) {
        
        //Build up request string ensuring any spaces are replaced with plus signs
        let programSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = programSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = baseURL + "/programs.json?\(escapedSearchTerm)"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                    self.delegate.didReceiveError(error)
                }
                var err: NSError?
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    if let results: NSArray = jsonResult["programs"] as? NSArray {
                       self.delegate.didReceiveAPIResults(results)
                    }
                }
            })
            
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            task.resume()
        }
    }


}