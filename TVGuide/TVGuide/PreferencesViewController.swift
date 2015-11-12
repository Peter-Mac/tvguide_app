//
//  PreferencesViewController.swift
//  TVGuide
//
//  Created by Peter Mac Giollafhearga on 3/08/2015.
//  Copyright (c) 2015 Peter Mac Giollafhearga. All rights reserved.
//
import UIKit

class PreferencesViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, APIControllerProtocol{

    @IBOutlet weak var regionPickerView: UIPickerView!
    @IBOutlet weak var channelPickerView: UIPickerView!
    @IBOutlet weak var timePickerView: UIPickerView!
    
    @IBOutlet weak var regionCell: UITableViewCell!
    @IBOutlet weak var channelCell: UITableViewCell!

    @IBOutlet weak var timeCell: UITableViewCell!
    
    let kRegionIdentifier: String = "PreferencesCellRegion"
    let kChannelIdentifier: String = "PreferencesCellChannel"
    let kTimeIdentifier: String = "PreferencesCellTime"

    var delegate: APIControllerProtocol?
    var api : APIController!

    var region_id: Int?
    var channel_id: Int?

    var selectedRegion: String?
    var selectedChannel: String?
    var selectedTime: String?
    
    var regions = [Region]()
    var channels = [Channel]()
    let timePickerData = ["Morning", "Afternoon", "Evening", "All"]
    
    required init(coder aDecoder: NSCoder) {
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("Region") != nil) {
            self.selectedRegion = defaults.stringForKey("Region")
        }
        
        if (defaults.objectForKey("Channel") != nil) {
            self.selectedChannel = defaults.stringForKey("Channel")
        }
        
        if (defaults.objectForKey("Time") != nil) {
            self.selectedTime = defaults.stringForKey("Time")
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        self.api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //retrieve all regions first.
        //this has to be done before either selecting a default region
        self.api.getRegions()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        var defaultRowIndex: Int? = 0
        //Set the default region (if there is one currently selected)
        if self.selectedRegion != nil {
            for(index,region) in enumerate(self.regions) {
                if region.name == self.selectedRegion {
                    defaultRowIndex = index
                }
            }
        } else {
            if self.regions.count > 0 {
                self.selectedRegion = self.regions[0].name
            }
        }
        
        //Ensure we have regions loaded before selcting a row
        if self.regions.count > 0 {
        self.regionPickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        }
        
        //Set the default channel (if there is one currently selected)
        defaultRowIndex = 0
        if self.selectedChannel != nil {
            for(index,channel) in enumerate(self.channels) {
                if channel.name == self.selectedChannel {
                    defaultRowIndex = index
                }
            }
        } else {
            if self.channels.count > 0 {
                self.selectedChannel = channels[0].name
            }
        }
        
        //Ensure channels loaded before selecting a row
        if self.channels.count > 0 {
            self.channelPickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        }
        
        //Set the default region (if there is one currently selected)
        defaultRowIndex = 0
        if self.selectedTime != nil {
            defaultRowIndex = find(self.timePickerData,self.selectedTime!)
            if(defaultRowIndex == nil) { defaultRowIndex = 0 }
            self.timePickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section) {
        case 0: return self.regionCell   // section 0, row 0 is the first name
        case 1: return self.channelCell    // section 0, row 1 is the last name
        case 2: return self.timeCell    // section 0, row 1 is the last name
        default: fatalError("Unknown picker detected")
        }
    
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
         switch(pickerView.tag) {
         case 0: return self.regions.count
         case 1: return self.channels.count
         case 2: return self.timePickerData.count
         default: fatalError("Unknown picker detected")
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        let currentRow:Int = row
        let tag = pickerView.tag
        
        switch(pickerView.tag) {
        case 0: return self.regions[row].name
        case 1: return channels[row].name
        case 2: return self.timePickerData[row]
        default: fatalError("Unknown picker detected")
        }
    }
   
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        
        switch(pickerView.tag) {
        case 0:
            self.selectedRegion = self.regions[row].name
            self.api.getChannelsforRegion(self.regions[row].id)
            self.region_id = self.regions[row].id
        case 1:
            self.selectedChannel = self.channels[row].name
            self.channel_id = self.channels[row].id
        case 2: self.selectedTime = self.timePickerData[row]
        default: fatalError("Unknown picker detected")
        }
    
    }
    
    func didReceiveRegionsResults(results: NSArray) {
        //iterate through regions, find the default (if there is one)
        //and show the matching channels
        dispatch_async(dispatch_get_main_queue(), {
            self.regions = Region.regionsWithJSON(results)
            var targetRegion = Region()
            if self.selectedRegion != nil {
                var defaultRowIndex: Int? = 0
                for(index,region) in enumerate(self.regions) {
                    if region.name == self.selectedRegion {
                        targetRegion = region
                        self.regionPickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
                    }
                }
            }
            
            //find the channels for the default region
            if targetRegion.id != 0 {
                self.api.getChannelsforRegion(targetRegion.id)
            }
            else{
                self.api.getChannelsforRegion(self.regions[0].id)
            }
            
            self.regionPickerView.reloadAllComponents()
        })
    
    }
    
    func didReceiveAPIResults(results: NSArray) {
    
    }

    func didReceiveError(error :NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    //The didReceiveChannelResults method needs to be included to adhere to APIControllerProtocol protocol
    func didReceiveChannelResults(channel: Channel) {
        
    }
    
    func didReceiveChannelsResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.channels = Channel.channelsWithJSON(results)
            self.channelPickerView.reloadAllComponents()
            
            //reselect a default if it exists in the newly retrieved list
            //Set the default channel (if there is one currently selected)
            var defaultRowIndex: Int? = 0
            if self.selectedChannel != nil {
                for(index,channel) in enumerate(self.channels) {
                    if channel.name == self.selectedChannel {
                        defaultRowIndex = index
                    }
                }
            } else {
                self.selectedChannel = self.channels[0].name
            }
            self.channelPickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
            

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}
