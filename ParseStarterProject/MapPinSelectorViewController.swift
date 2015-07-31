//
//  MapPinSelectorViewController.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import MapKit

class MapPinSelectorViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let initialLocation = CLLocation(latitude: 52.3740300, longitude: 4.8896900)
    let searchRadius: CLLocationDistance = 2000
    var mapString:String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "BackToMainMap")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        showMapStringDialog()
        
        println("Hey")
    }
    
    func showMapStringDialog(){
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Search",
           message: "Which City Do You Belong To?",
           preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler( {(textField: UITextField!) in
            
            textField.placeholder = "City Name ..."
        
        })
        
        let action = UIAlertAction(title: "Search", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                
                let theTextFields = textFields as! [UITextField]
                let enteredText = theTextFields[0].text
                
                self!.mapString = enteredText
                
                self!.searchInMap(enteredText)
        
                println(enteredText)
            }
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.dismissViewControllerAnimated(true, completion: nil)
        })
                
        alertController?.addAction(actionCancel)
        alertController?.addAction(action)
        
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func searchInMap(place: String) {
        
        // 1
        let request = MKLocalSearchRequest()

        request.naturalLanguageQuery = place
        
        // 2
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: initialLocation.coordinate, span: span)
        
        // 3
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler {
            (response: MKLocalSearchResponse!, error: NSError!) in
            
            for item in response.mapItems as! [MKMapItem] {
                
                println("\(item.name) - \(item.placemark.location.coordinate.latitude) \(item.placemark.location.coordinate.longitude)")
                
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(item.placemark.location.coordinate, self.searchRadius * 10.0, self.searchRadius * 10.0), animated: true)
                
                self.addPinToMapView(item.name, latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude)
                break
            }
            
            dispatch_after(5000, dispatch_get_main_queue(), { () -> Void in
                self.verifyUserLocation()
            })
        }
    }
    
    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        mapString = title
        self.latitude = latitude
        self.longitude = longitude
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MyAnnotation(coordinate: location, title: title)
        
        mapView.addAnnotation(annotation)
    }
    
    func verifyUserLocation(){
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Search Verification Result",
            message: "Do you live in place called '\(mapString)'?",
            preferredStyle: .Alert)
        
        let actionNo = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.showMapStringDialog()
        })
        
        let actionYes = UIAlertAction(title: "Yes, Save", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            
            println("SAVING: \(self!.latitude) - \(self!.longitude)")
            
            self!.addYourURL()

        })
        
        alertController?.addAction(actionNo)
        alertController?.addAction(actionYes)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func addYourURL(){
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Save Form",
            message: "Add any link you like to in your new location?",
            preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler( {(textField: UITextField!) in
            
            textField.placeholder = "http://someGreatSite.net/"
            
        })
        
        let action = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                
                let theTextFields = textFields as! [UITextField]
                let enteredText = theTextFields[0].text
                
                ParseAPI.SaveStudentLocation("\(self!.latitude)", longitude: "\(self!.longitude)", _mediaURL: enteredText, mapString: self!.mapString, view: self!)
                
                println(enteredText)
            }
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alertController?.addAction(actionCancel)
        alertController?.addAction(action)
        presentViewController(alertController!, animated: true, completion: nil)
    }

    func notifySaved(){
        println("notifyUser")
        var alert = UIAlertController(title: "Success", message: "Your data has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default : ok")
                self.dismissViewControllerAnimated(true, completion: nil)
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func notifyUser(msg:String){
        println("notifyUser")
        var alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default : ok")
                self.dismissViewControllerAnimated(true, completion: nil)
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startNetworkPoint(){
        println("NewMAP: startNetworkPoint")
    }
    
    func BackToMainMap(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
