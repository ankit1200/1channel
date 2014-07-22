//
//  SeasonTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/2/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {

    var seasons:NSArray = NSArray()
    var seriesId = String()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.parseJSON(self.createUrl())
    }
    
    
//    #pragma mark - json parser
    
    func getJSON(urlToRequest: String) ->NSData {
        
        return NSData(contentsOfURL: NSURL(string: urlToRequest))
    }
    
    func parseJSON(inputURL: String) {
        
        
        // retrieve data from user defaults
        let data = NSUserDefaults.standardUserDefaults().valueForKey("series/\(self.seriesId)/seasons") as NSData
        
        var error: NSError?
        var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        seasons = results["seasons"] as NSArray
    }
    
    func createUrl() -> String {
        return "https://www.kimonolabs.com/api/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(self.seriesId)"
    }
    
    
//     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEpisodes" {
            let etvc = segue.destinationViewController as EpisodesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let tempDict = seasons.objectAtIndex(indexPath.row) as NSDictionary
            let tempSeason = tempDict["season"] as String
            let lowercaseSeason = tempSeason.lowercaseString
            let inputSeason = lowercaseSeason.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let inputSeriesId = seriesId.stringByReplacingOccurrencesOfString("watch", withString: "tv", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            // variables being passed
            etvc.season = inputSeason
            etvc.seriesId = inputSeriesId
            etvc.title = tempSeason
        }
    }

//    #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seasons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if seasons.count != 0 {
            let seasonDict = seasons[indexPath.row] as NSDictionary
            let label = seasonDict["season"] as String
            cell.textLabel.text = label
        }
        return cell
    }
}

