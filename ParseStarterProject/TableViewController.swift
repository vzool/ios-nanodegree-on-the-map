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
    
    var signOutBarButtonView:UIBarButtonItem!
    var pinBarButton:UIBarButtonItem!
    var refreshBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signOutBarButtonView = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.Plain, target: self, action: "signOutAction")
        
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshAction")
        
        pinBarButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "saveAction")
        
        navigationItem.rightBarButtonItems = [
            refreshBarButton,
            pinBarButton
        ]
        
        navigationItem.leftBarButtonItem = signOutBarButtonView
        
        navigationItem.title = "On The Map"
    }
    
    func signOutAction(){
        println("signOutAction")
        
        var alert = UIAlertController(title: "Warning", message: "You about to Sign Out, are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            switch action.style{
                
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                UdacityAPI.Logout(self, flag: ControlFlag.TableViewController)
                println("default : ok")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func refreshAction(){
        println("refreshAction")
        
        ParseAPI.GetStudentLocations(self, flag: ControlFlag.TableViewController)
    }
    
    func saveAction(){
        println("saveAction")
        performSegueWithIdentifier("select_pin_on_map", sender: self)
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
    
    func showIndicator(state:Bool){
        
        pinBarButton.enabled = !state
        refreshBarButton.enabled = !state
        signOutBarButtonView.enabled = !state
    }
    
    func startNetworkPoint(){
        showIndicator(true)
    }
    
    func finishNetworkPoint(){
        showIndicator(false)
    }
    
    func notifyUser(msg:String){
        println("notifyUser")
        var alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                self.showIndicator(false)
                println("default : ok")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func notifySaved(){
        println("notifyUser")
        var alert = UIAlertController(title: "Success", message: "Your data has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default : ok")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func LogoutSuccessNetworkPoint(){
        performSegueWithIdentifier("show_login", sender: self)
    }
    
    func loadStudentLocations(){
        tableElementView.reloadData()
    }
}
