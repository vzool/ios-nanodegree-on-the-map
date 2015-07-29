//
//  TableViewController.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/25/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableElementView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableElementView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.StudentLocations.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL") as! UITableViewCell
        
        let data = AppDelegate.StudentLocations.data[indexPath.row]
        
        let first = data.firstName
        let last = data.lastName
        let mediaURL = data.mediaURL
        
        cell.textLabel?.text = "\(first) \(last)"
        cell.detailTextLabel?.text = "\(mediaURL)"
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = AppDelegate.StudentLocations.data[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: data.mediaURL)!)
    }
   
}
