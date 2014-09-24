//
//  LinksTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class LinksTableViewController : UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var links:[(link: String, source: String)] = []
    var episode = Episode()
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getLinksForEpisode()
        
        let controllers = self.splitViewController!.viewControllers
        self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
    }
    
    
    //#MARK: Query From Parse
    
    func getLinksForEpisode() {
        
        let query = PFQuery(className: episode.seriesName)
        query.selectKeys(["links"])
        query.whereKey("season", equalTo: episode.season)
        query.whereKey("episodeNumber", equalTo: episode.episodeNumber)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.getLinksFromQuery(objects)
            }
        }
    }
    
    
    //MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            let dvc = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // set variables
            dvc.linkAndSource = links[indexPath!.row]

            
            // analytics
            let dimensions = [
                "seriesName": episode.seriesName,
                "season": episode.season,
                "episodeNum": episode.episodeNumber,
                "source": links[indexPath!.row].source
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchEpisode", dimensions:dimensions)
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if links.count != 0 {
            cell.textLabel!.text = links[indexPath.row].source
        }
        return cell
    }
    
    //MARK: Helper Methods
    
    func getLinksFromQuery(objects: [AnyObject]!) {
        
        let linksFromQuery = (objects[0] as PFObject)["links"] as NSArray
        
        for link in linksFromQuery {
            let link = link as Dictionary<String, String>
            self.links.append(link: link["link"]!, source: link["source"]!)
        }
        
        self.tableView.reloadData()
    }
}
