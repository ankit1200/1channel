//
//  LinksTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class LinksTableViewController : UITableViewController {
    
    var links = NSArray()
    var season = String()
    var seriesId = String()
    var episode = String()
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
        links = results["episode_links"] as NSArray
    }
    
    func createUrl() -> String {
        return "https://www.kimonolabs.com/api/4nb0gypm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(season)-\(episode)"
    }
    
    
    //    #pragma mark - prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let dvc = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // set variables
            dvc.link = (links[indexPath.row] as NSDictionary)["link"] as String
        }
    }
    
    
    //    #pragma mark - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if links.count != 0 {
            let linksDict = links[indexPath.row] as NSDictionary
            let label = linksDict["source"] as String
            cell.textLabel.text = label
        }
        return cell
    }
}
