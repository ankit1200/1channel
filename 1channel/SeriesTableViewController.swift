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
        getSupportedSeries()
    }
    
    
    //MARK: parse methods
    func getSupportedSeries() {
        
        let query = PFQuery(className: "Series")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if !error {
                for object in objects {
                    
                    let series = Episode()
                    var seriesName = (object as PFObject)["name"] as String
                    
                    series.seriesName = seriesName
                    series.seriesId = (object as PFObject)["seriesID"] as String
                    self.seriesList += series
                }
                self.tableView.reloadData()
//                self.updateDatabase()
            }
        }
    }
    
    func updateDatabase() {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        
            // background thread
            let manager = DataManager()
            for series in self.seriesList {
                manager.downloadSeriesData(series.seriesName, seriesId: series.seriesId)
            }
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons" {
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // variables being passed
            stvc.episode = seriesList[indexPath.row]
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
            println(seriesList[indexPath.row].seriesName)
        var seriesName = seriesList[indexPath.row].seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            cell.textLabel.text = seriesName
        }
        return cell
    }
}