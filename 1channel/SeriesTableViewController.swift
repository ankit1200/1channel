//
//  SeriesTableViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/9/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeriesTableViewController: UITableViewController {

    var seriesList = Array<Episode>()
    let episode = Episode()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        getSupportedSeries()
    }
    
    
    //MARK: parse methods
    func getSupportedSeries() {
        seriesList = []
        let query = PFQuery(className: "Series")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if !(error != nil) {
                for object in objects {
                    let series = Episode()
                    var seriesName = (object as PFObject)["name"] as String
                    
                    series.seriesName = seriesName
                    series.seriesId = (object as PFObject)["seriesID"] as String
                    self.seriesList.append(series)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons" {
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // variables being passed
            stvc.episode = seriesList[indexPath!.row]
            
            // analytics
            let dimensions = [
                "seriesName": episode.seriesName,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchSeries", dimensions:dimensions)
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seriesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if seriesList.count != 0 {
            var seriesName = seriesList[indexPath.row].seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            cell.textLabel!.text = seriesName
        }
        return cell
    }
}