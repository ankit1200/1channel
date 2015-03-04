//
//  CollectionViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 9/28/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    var filteredSeriesList = Array<Episode>()
    var seriesList = Array<Episode>()
    let episode = Episode()
    var filteredMovieList = Array<Movie>()
    var movieList = Array<Movie>()
    let movie = Movie()
    var selectedIndex = 0
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var movieRefresh: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var dismissKeyboardButton: UIButton!
    
    override func viewDidLoad() {
        if segmentControl.selectedSegmentIndex == 0 {
            getSupportedSeries()
        } else if segmentControl.selectedSegmentIndex == 1 {
            getMovies()
        }
    }

    //MARK: parse methods
    func getSupportedSeries() {
        seriesList = []
        let query = PFQuery(className: "Series")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let series = Episode()
                    var seriesName = (object as PFObject)["name"] as String
                    series.parseQueryName = seriesName
                    seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    series.seriesName = seriesName
                    series.seriesId = (object as PFObject)["seriesID"] as String
                    
                    if (object as PFObject)["image"] != nil {
                        series.imageUrl = (object as PFObject)["image"] as String
                    } else {
                        series.imageUrl = ""
                    }
                    
                    self.seriesList.append(series)
                }
                self.collectionView.reloadData()
            } else {
                println(error)
            }
        }
    }
    
    func getMovies() {
        movieList = []
        let query = PFQuery(className: "Movies")
        query.limit = 1000
        query.orderByDescending("dateReleased")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let movie = Movie()
                    var movieName = (object as PFObject)["name"] as String
                    movieName = movieName.stringByReplacingOccurrencesOfString("movie_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movieName = movieName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movie.name = movieName
                    movie.id = (object as PFObject)["movieId"] as String
                    movie.imageUrl = (object as PFObject)["image"] as String
                    movie.links = (object as PFObject)["links"] as NSArray
                    self.movieList.append(movie)
                }
                self.collectionView.reloadData()
            } else {
                println(error)
            }
        }
    }
    

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return (filteredSeriesList.count == 0 ) ? seriesList.count : filteredSeriesList.count
        } else {
            return (filteredMovieList.count == 0) ? movieList.count : filteredMovieList.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("seriesCell", forIndexPath: indexPath) as SeriesCollectionViewCell
            
            // make sure all the series have been loaded from backend
            if seriesList.count != 0 {
                let episode = (filteredSeriesList.count == 0 ) ? seriesList[indexPath.row] : filteredSeriesList[indexPath.row]
                
                let imageUrl = episode.imageUrl
                if imageUrl == "" {
                    cell.image.image = UIImage(named: "noposter.jpg")
                } else {
                    var url = NSURL(string: imageUrl)
                    var data = NSData(contentsOfURL : url!)
                    cell.image.image = UIImage(data : data!)
                }
            }
            
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as MovieCollectionViewCell
            
            // make sure all the movies have been loaded from backend
            if movieList.count != 0 {
                let movie = (filteredMovieList.count == 0) ? movieList[indexPath.row] : filteredMovieList[indexPath.row]
                
                let imageUrl = movie.imageUrl
                if imageUrl == "" {
                    cell.image.image = UIImage(named: "noposter.jpg")
                } else {
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var url = NSURL(string: imageUrl)
                        var data = NSData(contentsOfURL : url!)
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.image.image = UIImage(data : data!)
                        })
                    })
                }
            
            }
            return cell
        }
    }

    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
    }
    
    
    // MARK: Segment Value Changed
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getSupportedSeries()
        } else if sender.selectedSegmentIndex == 1 {
            getMovies()
        }
    }
    
    
    // MARK: Search Bar Methods
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if segmentControl.selectedSegmentIndex == 0 {
            filteredSeriesList = seriesList.filter({(episode: Episode) -> Bool in
                let stringMatchName = episode.seriesName.lowercaseString.rangeOfString(searchText.lowercaseString)
                return stringMatchName != nil
            })
        } else if segmentControl.selectedSegmentIndex == 1 {
            filteredMovieList = movieList.filter({(movie: Movie) -> Bool in
                let stringMatchName = movie.name.lowercaseString.rangeOfString(searchText.lowercaseString)
                return stringMatchName != nil})
        }
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        dismissKeyboardButton.hidden = false
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        searchBar.resignFirstResponder()
        dismissKeyboardButton.hidden = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: Refresh Movies
    
    @IBAction func refreshMovies(sender: AnyObject) {
        var alertView = UIAlertView(title: "Movies Updating", message: "The Movies are being updated!", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        let manager = DataManager()
        // update movies whenever app opens
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            manager.downloadMovieData()
            dispatch_async(dispatch_get_main_queue(), {
                // Instantiate an alert view object
                let alertView = UIAlertView(title: "Movies Updated", message: "The Movies have been updated!", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            })
            
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons"{
            // destination view controller
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems() as Array<NSIndexPath>)[0]
            
            // variables being passed
            stvc.episode = (filteredSeriesList.count == 0 ) ? seriesList[indexPath.row] : filteredSeriesList[indexPath.row]
            
            // analytics
            let dimensions = [
                "seriesName": episode.seriesName,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchSeries", dimensions:dimensions)
        } else if segue.identifier == "showSources" {
            // destination view controller
            let ltvc = segue.destinationViewController as LinksTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems() as Array<NSIndexPath>)[0]
            
            // variables being passed
            ltvc.movie = (filteredMovieList.count == 0) ? movieList[indexPath.row] : filteredMovieList[indexPath.row]
            ltvc.isMovie = true
            
            // analytics
            let dimensions = [
                "movieName": movieList[indexPath.row].name,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchMovie", dimensions:dimensions)
        }
    }
}
