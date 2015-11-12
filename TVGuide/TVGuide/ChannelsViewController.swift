//
//  ChannelsViewController.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 31/07/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    @IBOutlet weak var channelTableView: UITableView!
    
    var channels = [Channel]()
    var channel_id: Int?
    var region_id: Int?
    var selectedChannel: Channel?
    var selectedRegion: String?
    let kCellIdentifier: String = "ChannelResultCell"
    
    var delegate: APIControllerProtocol?
    var api : APIController!
    
    var imageCache = [String:UIImage]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        
        api.getChannelsforRegion(self.region_id!)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        
        var channel: Channel = self.channels[indexPath.row]

        cell.textLabel?.text = channel.name
        cell.detailTextLabel?.text = channel.code
        cell.imageView?.image = UIImage(named: "Blank52")

        if let urlString: String  = channel.iconURL as String?,
            imgURL: NSURL = NSURL(string: urlString) {
        
                if let img = imageCache[urlString] {
                    cell.imageView?.image = img
                }
                else {
                    // The image isn't cached, download the img data
                    // We should perform this in a background thread
                    if !urlString.isEmpty {
                        let request: NSURLRequest = NSURLRequest(URL: imgURL)
                        let mainQueue = NSOperationQueue.mainQueue()
                        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                            if error == nil {
                                // Convert the downloaded data in to a UIImage object
                                let image = UIImage(data: data)
                                // Store the image in to our cache
                                self.imageCache[urlString] = image
                                // Update the cell
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                                        cellToUpdate.imageView?.image = image
                                    }
                                })
                            }
                            else {
                                println("Error: \(error.localizedDescription)")
                            }
                        })
                    }
                }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        self.selectedChannel = self.channels[indexPath.row]
        
    }
    
    func didReceiveRegionsResults(results: NSArray) {
    }
    
    func didReceiveChannelsResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.channels = Channel.channelsWithJSON(results)
            self.channelTableView!.reloadData()
            
            
            for channel: Channel in self.channels {
                if channel.id == self.channel_id {
                    self.selectedChannel = channel
                }
            }

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func didReceiveAPIResults(results: NSArray) {
    }
    
    //The didReceiveChannelResults method needs to be included to adhere to APIControllerProtocol protocol
    func didReceiveChannelResults(channel: Channel) {
        
    }
    
    func didReceiveError(error :NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}