//
//  SeasonTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/2/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {

    var seasons:[String] = []
    var seriesId = String()
    var seriesName = String()

    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getSeasonsForSeries()
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // background thread
            let manager = DataManager()
            manager.downloadSeriesData(self.seriesName, seriesId: self.seriesId)
        })
    }
    
    
//MARK: Query From Parse
    
    func getSeasonsForSeries() {
    
        let query = PFQuery(className: seriesName)
        query.selectKeys(["season"])
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !error {
                self.getSeasonsFromQuery(objects)
            }
        }
    }
    
    
//     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEpisodes" {
            let etvc = segue.destinationViewController as EpisodesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let season = seasons[indexPath.row]
            
            // variables being passed
            etvc.season = season
            etvc.seriesId = seriesId
            etvc.seriesName = seriesName
            etvc.title = season
        }
    }
    

//MARK: Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seasons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if seasons.count != 0 {
            cell.textLabel.text = seasons[indexPath.row]
        }
        return cell
    }
    
    
//MARK: Helper Methods
    
    func getSeasonsFromQuery(objects: [AnyObject]!) {
        
        for object in objects {
            
            let season = (object as PFObject)["season"] as String
            self.seasons.append(season)
            self.seasons = NSSet(array: self.seasons).allObjects as Array<String>
            self.seasons = self.seasons.reverse()
        }
        self.tableView.reloadData()
    }    
}

