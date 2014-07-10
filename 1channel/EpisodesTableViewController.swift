//
//  EpisodesTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class EpisodesTableViewController : UITableViewController {
    
    var seasonEpisodes = NSArray()
    var season = String()
    var seriesId = String()
    @IBOutlet var tableViewTitle : UINavigationItem
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.parseJSON(self.createUrl())
    }
    
    
    //    #pragma mark - json parser
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest))
    }
    
    func parseJSON(inputURL: String) {
        var error: NSError?
        var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(self.getJSON(inputURL), options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        seasonEpisodes = results["episodes"] as NSArray
    }
    
    func createUrl() -> String {
        return "https://www.kimonolabs.com/api/2lcduwri?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(season)"
    }
    
    
    //     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSources" {
            let ltvc = segue.destinationViewController as LinksTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let episodesDict = seasonEpisodes.objectAtIndex(indexPath.row) as NSDictionary
            let episodeNum = episodesDict["episodeNumber"] as String
            let episodeName = episodesDict["episodeName"] as String
            let lowercaseEpisode = episodeNum.lowercaseString
            let inputEpisode = lowercaseEpisode.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            // variables to pass down
            ltvc.season = self.season
            ltvc.seriesId = self.seriesId
            ltvc.episode = inputEpisode
            ltvc.title = "\(episodeNum) - \(episodeName)"
        }
    }
    
    
    //    #pragma mark - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasonEpisodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if seasonEpisodes.count != 0 {
            let episodesDict = seasonEpisodes[indexPath.row] as NSDictionary
            let episodeNum = episodesDict["episodeNumber"] as String
            let episodeName = episodesDict["episodeName"] as String
            cell.textLabel.text = episodeName
            cell.detailTextLabel.text = episodeNum
        }
        return cell
    }
}