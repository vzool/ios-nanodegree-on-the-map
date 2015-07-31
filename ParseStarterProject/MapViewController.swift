//
//  MapViewController.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/24/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var signOutBarButtonView:UIBarButtonItem!
    var pinBarButton:UIBarButtonItem!
    var refreshBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signOutBarButtonView = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.Plain, target: self, action: "signOut")
        
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "RefreshAction")
        
        pinBarButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "SaveAction")
        
        navigationItem.rightBarButtonItems = [
            refreshBarButton,
            pinBarButton
        ]
        
        navigationItem.leftBarButtonItem = signOutBarButtonView
        
        navigationItem.title = "On The Map"
        
        showIndicator(true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        ParseAPI.GetStudentLocations(self, flag: ControlFlag.MapViewController)
    }
    
    func signOut(){
        
        println("signOut")
        
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
                UdacityAPI.Logout(self, flag: ControlFlag.MapViewController)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        
        }else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    func loadStudentLocations(){
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let locations =  AppDelegate.StudentLocations
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for(var i = 0; i < locations.data.count; i++){
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            let data = locations.data[i]
            
            let lat = CLLocationDegrees(data.latitude)
            let long = CLLocationDegrees(data.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(data.firstName) \(data.lastName)"
            annotation.subtitle = data.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
    }
    
    func showIndicator(state:Bool){
        
        pinBarButton.enabled = !state
        refreshBarButton.enabled = !state
        signOutBarButtonView.enabled = !state
        indicator.hidden = !state
        
        if state{
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    
    func startNetworkPoint(){
        showIndicator(true)
    }
    
    func finishNetworkPoint(){
        showIndicator(false)
    }
    
    func SaveAction(){
        
        performSegueWithIdentifier("select_pin_on_map", sender: self)
    }
    
    func finishSaveStudentLocationNetworkPoint(){
        ParseAPI.GetStudentLocations(self, flag: ControlFlag.MapViewController)
    }
    
    func RefreshAction(){
        
        mapView.removeAnnotations(mapView.annotations)
        
        ParseAPI.GetStudentLocations(self, flag: ControlFlag.MapViewController)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}

