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
    var episode = Episode()

    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getSeasonsForSeries()
    }
    
    
//MARK: Query From Parse
    
    func getSeasonsForSeries() {
    
        let query = PFQuery(className: episode.seriesName)
        query.selectKeys(["season"])
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                self.getSeasonsFromQuery(objects)
            }
        }
    }
    
    
//MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEpisodes" {
            let etvc = segue.destinationViewController as EpisodesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            episode.season = seasons[indexPath.row]
            
            // variables being passed
            etvc.episode = episode
            etvc.title = episode.season
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
        }
        self.seasons = NSSet(array: self.seasons).allObjects as Array<String>
        self.seasons = sorted(self.seasons)
        self.tableView.reloadData()
    }    
}

