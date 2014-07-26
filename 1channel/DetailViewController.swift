//
//  DetailViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/7/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate {

    var masterPopoverController: UIPopoverController? = nil
    var link = String()
    @IBOutlet var webView : UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadAddressURL()
    }

    // #pragma mark - Split view

    func splitViewController(splitController: UISplitViewController, willHideViewController viewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController popoverController: UIPopoverController) {
        
        barButtonItem.title = "select" // NSLocalizedString(@"Master", @"Master")
        self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        self.masterPopoverController = popoverController
    }

    func splitViewController(splitController: UISplitViewController, willShowViewController viewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.masterPopoverController = nil
    }

    func loadAddressURL() {
        
        let request = NSURLRequest(URL: (NSURL(string: link)))
        webView!.loadRequest(request)
    }
}

