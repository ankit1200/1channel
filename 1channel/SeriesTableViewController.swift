//
//  SeriesTableViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/9/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeriesTableViewController: UITableViewController {

    var series = NSDictionary()
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        readSeriesPlist()
    }
    
    
    //MARK: plist parser
    func readSeriesPlist() {
        let path = NSBundle.mainBundle().pathForResource("seriesList", ofType: "plist")
        series = NSDictionary(contentsOfFile: path)
    }
    
    
    //     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons" {
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            // variables being passed
            stvc.seriesId = (series.allValues as NSArray)[indexPath.row] as String
            stvc.seriesName = (series.allKeys as NSArray)[indexPath.row] as String
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.series.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if series.count != 0 {
            let keys = series.allKeys as NSArray
            let label = keys[indexPath.row] as String
            cell.textLabel.text = label
        }
        return cell
    }
}