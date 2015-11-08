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
        // Populate Arrays
        DataManager.sharedInstance.getSupportedSeries({
            self.seriesList = DataManager.sharedInstance.seriesList
            self.collectionView.reloadData()
        })
        DataManager.sharedInstance.getMovies({self.movieList = DataManager.sharedInstance.movieList})
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("seriesCell", forIndexPath: indexPath) as! SeriesCollectionViewCell
            
            // make sure all the series have been loaded from backend
            if seriesList.count != 0 {
                let episode = (filteredSeriesList.count == 0 ) ? seriesList[indexPath.row] : filteredSeriesList[indexPath.row]
                cell.image.image = episode.image
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCollectionViewCell
            
            // make sure all the movies have been loaded from backend
            if movieList.count != 0 {
                let movie = (filteredMovieList.count == 0) ? movieList[indexPath.row] : filteredMovieList[indexPath.row]
                
                let imageUrl = movie.imageUrl
                if movie.image != UIImage(named: "noposter.jpg") {
                    cell.image.image = movie.image
                } else {
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        let url = NSURL(string: imageUrl)
                        let data = NSData(contentsOfURL : url!)
                        var image: UIImage?
                        if data != nil {
                            image = UIImage(data : data!)
                        } else {
                            image = UIImage(named: "noposter.jpg")!
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.image.image = image
                            if self.filteredMovieList.count == 0 {
                                self.movieList[indexPath.row].image = image
                            } else {
                                self.filteredMovieList[indexPath.row].image = image
                            }
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
            seriesList = DataManager.sharedInstance.seriesList
        } else if sender.selectedSegmentIndex == 1 {
            movieList = DataManager.sharedInstance.movieList
        }
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(NSIndexSet(index: 0))
        }, completion: nil)
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
        let alertView = UIAlertView(title: "Movies Updating", message: "The movies are being updated! Movies list will refresh upon completion!", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        // update movies whenever app opens
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            DataManager.sharedInstance.downloadMovieLinks({DataManager.sharedInstance.getMovies({self.movieList = DataManager.sharedInstance.movieList})})
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                    }, completion: nil)
            })
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons"{
            // destination view controller
            let stvc = segue.destinationViewController as! SeasonsTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems()!)[0]
            
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
            let ltvc = segue.destinationViewController as! LinksTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems()!)[0]
            
            // variables being passed
            let movieToPass = (filteredMovieList.count == 0) ? movieList[indexPath.row] : filteredMovieList[indexPath.row]
            ltvc.movie = movieToPass
            ltvc.isMovie = true
            ltvc.title = movieToPass.name
            // analytics
            let dimensions = [
                "movieName": movieToPass.name,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchMovie", dimensions:dimensions)
        }
    }
}
