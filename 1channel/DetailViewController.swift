//
//  DetailViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/7/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import Foundation

extension String {
    func contains(other: String) -> Bool{
        var start = startIndex
        
        do{
            var subString = self[Range(start: start++, end: endIndex)]
            if subString.hasPrefix(other){
                return true
            }
            
        } while start != endIndex
        
        return false
    }
}

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView : UIWebView!
    
    var linkAndSource:(link: String, source: String)? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.webView.delegate = self
    }
    
    //MARK: Web View Methods

    func loadAddressURL() {
        
        let request = NSURLRequest(URL: (NSURL(string: linkAndSource!.link))!)
        webView!.scalesPageToFit = true
        webView!.loadRequest(request)
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.URL.absoluteString
        let source = getSourceName(linkAndSource!.source)
        
        if (urlString!.lowercaseString.rangeOfString("primewire") != nil) ||
            (urlString!.lowercaseString.rangeOfString(source) != nil) ||
            (urlString!.lowercaseString.rangeOfString(".mp4") != nil)
        {
            println("passed: \(urlString)")
            return true
        }
        println("failed: \(urlString)")
        return false
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.linkAndSource {
            if let loadLink = self.webView {
               loadAddressURL()
            }
        }
    }
    
    
    //MARK: helper methods
    func getSourceName(source: String) -> String {
        var sourceString = ""
        
        for char in source {
            if char == "." {
                return sourceString
            } else {
                sourceString = sourceString + [char]
            }
        }
        return source
    }
}

