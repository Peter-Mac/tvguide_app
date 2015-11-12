//
//  ViewController.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 29/07/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    @IBOutlet weak var selectChannel: UIBarButtonItem!
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet var programsTableView : UITableView!
    
    @IBOutlet weak var preferencesButtonItem: UIBarButtonItem!
    
    var selectedRegion: String!
    var selectedChannel: String!
    var selectedTime: String?
    
    var defaultChannel: Channel = Channel()
    var defaultRegion: Region = Region()
    var channel_id: Int!
    var region_id: Int!
    var imageCache = [String:UIImage]()
    var regions = [Region]()
    var channels = [Channel]()
    var programs = [Program]()
    
    let kCellIdentifier: String = "ProgramCell"

    var delegate: APIControllerProtocol?
    var api : APIController!
    
    @IBAction func updatePrograms(sender: AnyObject) {
        self.doProgramSearch()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.loadDefaults()
        self.verifyDefaults()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        programsTableView.delegate = self
        programsTableView.dataSource = self
        api = APIController(delegate: self)

        //indicate network activity because the next thing to happen is to
        //retrieve all channels from an API call
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //Read the default region's details
        api.getRegions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! ProgramCell
        
        let program = self.programs[indexPath.row]
        
        var dateFormatter = NSDateFormatter()
        var auLocale = NSLocale(localeIdentifier: "en_AU")
        dateFormatter.locale = auLocale
        
        var startDate: NSDate
        var stopDate: NSDate
        var startDisplay: String = ""
        var stopDisplay:String = ""
        let start: String = program.start
        let stop: String = program.stop
        
        // Get the title string for display in the subtitle
        let title = program.title
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
        
        //Remove extraneous values (a T splitting date from time and a trailing Z
        var startTime: String = start.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        startTime = startTime.stringByReplacingOccurrencesOfString("Z", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if var startDate = dateFormatter.dateFromString(startTime) {
            dateFormatter.dateFormat = "HH:mm"
            startDisplay = dateFormatter.stringFromDate(startDate)
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
        var stopTime = stop.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        stopTime = stopTime.stringByReplacingOccurrencesOfString("Z", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if var stopDate = dateFormatter.dateFromString(stopTime) {
            dateFormatter.dateFormat = "HH:mm"
            stopDisplay = dateFormatter.stringFromDate(stopDate)
        }
        
        cell.programName.text = title
        cell.programTime.text = startDisplay + " - " + stopDisplay + " "

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the row data for the selected row
        let program = self.programs[indexPath.row]
        
        // Get the title of the program for this row
        let title: String = program.title
        
        // Get the description of the track on this row
       let desc: String = program.description
            
       var alert = UIAlertController(title: title, message: desc, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.programs = Program.programsWithJSON(results)
            self.programsTableView!.reloadData()
    
            if self.programs.count == 0 {
                var message: String
                if self.selectedChannel == nil {
                    message = "Please select a default channel by using the preferences button."
                } else {
                    message = "No program data is available for this channel on the selected date."
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                var alert = UIAlertController(title: "Information", message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    func didReceiveRegionsResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.regions = Region.regionsWithJSON(results)
            var targetRegion = Region()
            if self.selectedRegion != nil {
                for(index,region) in enumerate(self.regions) {
                    if region.name == self.selectedRegion {
                        targetRegion = region
                    }
                }
            }

            //find the channels for the default region
            if targetRegion.id != 0 {
                self.defaultRegion = targetRegion
            }
            else{
                self.defaultRegion = self.regions[0]
            }
            
            self.api.getChannelsforRegion(self.defaultRegion.id)
            
        })
    }
    
    func didReceiveChannelsResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.channels = Channel.channelsWithJSON(results)
            var targetChannel = Channel()
            if self.selectedChannel != nil {
                for(index,channel) in enumerate(self.channels) {
                    if channel.name == self.selectedChannel {
                        targetChannel = channel
                        self.channel_id = channel.id
                        //update the title of the select channel button
                        self.selectChannel.title = channel.name
                    }
                }
            }
            //we have just got our list of channels back. 
            //now compare to see if we have a default channel set
            //and load its data from the db
            self.doProgramSearch()
        })
    }
    
    func didReceiveChannelResults(channel: Channel) {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.selectChannel.title = channel.name
        })
    }
    
    func didReceiveError(error :NSError) {
        let message = error.localizedDescription + "\nPlease try again shortly."
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        var alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "Channels" {
            if let svc = segue.destinationViewController as? ChannelsViewController {
                svc.channel_id = self.channel_id
                svc.region_id = self.defaultRegion.id
            }
        }
        
        if segue.identifier == "Preferences" {
            if let svc = segue.destinationViewController as? PreferencesViewController {
                svc.selectedRegion = self.selectedRegion
                svc.selectedChannel = self.selectedChannel
                svc.channel_id = self.channel_id
                svc.region_id = self.defaultRegion.id
            }
        }
    }

    //cancelChannelViewController is required as a dummy responder for the
    //cancellation of the view ot the ChannelsViewController
    @IBAction func cancelChannelViewController(segue:UIStoryboardSegue) {

    }
    
    @IBAction func saveChannelDetail(segue:UIStoryboardSegue) {
        
        if let svc = segue.sourceViewController as? ChannelsViewController,
            channel = svc.selectedChannel {
                self.channel_id = channel.id
                self.selectedChannel = channel.name
                
                //update the title of the select channel button
                self.selectChannel.title = channel.name
                self.doProgramSearch()
        }
    }
    
    //cancelPreferencesViewController is required as a dummy responder for the
    //cancellation of the view ot the PreferencesViewController
    @IBAction func cancelPreferencesViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func savePreferencesDetail(segue:UIStoryboardSegue) {
        
        if let svc = segue.sourceViewController as? PreferencesViewController{
            
            var defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(svc.selectedRegion, forKey: "Region")
            defaults.setObject(svc.selectedChannel, forKey: "Channel")
            defaults.setObject(svc.channel_id, forKey: "ChannelId")
            defaults.setObject(svc.selectedTime, forKey: "Time")
            
            self.loadDefaults()
    
            self.doProgramSearch()
        }
    }
    
    func loadDefaults() {
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("Region") != nil) {
            self.selectedRegion = defaults.stringForKey("Region")
        }
        
        if (defaults.objectForKey("Channel") != nil) {
            self.selectedChannel = defaults.stringForKey("Channel")
        }
        
        if (defaults.objectForKey("ChannelId") != nil) {
            self.channel_id = defaults.integerForKey("ChannelId")
        }
        
        if (defaults.objectForKey("Time") != nil) {
            self.selectedTime = defaults.stringForKey("Time")
        }
    }
    
    func verifyDefaults() {
        if self.selectedRegion == nil  {
            self.selectedRegion = NSBundle.mainBundle().objectForInfoDictionaryKey("DefaultRegion") as! String
        }
        
        if self.selectedChannel == nil  {
            self.selectedChannel = NSBundle.mainBundle().objectForInfoDictionaryKey("DefaultChannel") as! String
        }
    }
    
    func doProgramSearch() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var searchString: String = ""
        
        var chosenDate = self.selectedDate.date
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.stringFromDate(chosenDate) as String

        if self.channel_id == nil {
            var message: String
            message = "Please select a channel using the Select Channel button below."
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var alert = UIAlertController(title: "Information", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }else {
            
            searchString = "start=" + startDate
            
            searchString += "&channel_id=" + String(self.channel_id)

            searchString += "&region_id=" + String(self.defaultRegion.id)
            if self.selectedTime != nil {
                if self.selectedTime!.lowercaseString != "all" {
                    searchString += "&mode=" + self.selectedTime!.lowercaseString
                }
            }
            
            self.programs = [Program]()
            self.programsTableView!.reloadData()
            
            self.api.searchProgramsFor(searchString)
            self.displayTitle()
        }
    }
    
    //Displays title across top of search results view
    func displayTitle() {
        
        var dateFormatter = NSDateFormatter()
        var auLocale = NSLocale(localeIdentifier: "en_AU")
        dateFormatter.locale = auLocale
        dateFormatter.dateFormat = "cccc, MMMM dd"
        var selectedDate = self.selectedDate.date
        let startDate = dateFormatter.stringFromDate(selectedDate) as String

        self.title = self.selectedChannel + " " + startDate
        self.selectChannel.title = self.selectedChannel
    }
}

