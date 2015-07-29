//
//  ParseAPI.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/24/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

class ParseAPI{
    
    static internal var ObjectID:String!
    static internal var MediaURL:String!
    
    static internal func GetStudentLocations(view:UIViewController){
        
        dispatch_async(dispatch_get_main_queue()) {
            (view as? MapViewController)!.startNetworkPoint()
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapViewController)!.notifyUser(error.description)
                }
                
                return
            }
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            // Parse JSON
            var parsingError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let results = json["results"] as? NSArray{
                
                AppDelegate.StudentLocations = StudentInformation(dict: json)
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapViewController)!.loadStudentLocations()
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                (view as? MapViewController)!.finishNetworkPoint()
            }
        }
        task.resume()
    }
    
    static internal func QueryForStudentLocation(view: UIViewController){
        
        dispatch_async(dispatch_get_main_queue()) {
            (view as? MapViewController)!.startNetworkPoint()
        }
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(UdacityAPI.AccountKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapViewController)!.notifyUser(error.description)
                }
                
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            // Parse JSON
            var parsingError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let results = json["results"] as? NSArray{
                
                if results.count == 0 {
                    
                    ParseAPI.SaveStudentLocation(view)
                    
                }else{
                    
                    if let result = results[0] as? NSDictionary{
                        if let objectId = result["objectId"] as? String{
                            ParseAPI.ObjectID = objectId
                            println(objectId)
                        }
                        
                        if let mediaURL = result["mediaURL"] as? String{
                            ParseAPI.MediaURL = mediaURL
                            println(mediaURL)
                        }
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        (view as? MapViewController)!.youAlreadyExists()
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
    static internal func SaveStudentLocation(view: UIViewController){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let gps = split(UdacityAPI.Location) { $0 == ","}
        
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityAPI.AccountKey)\", \"firstName\": \"\(UdacityAPI.FirstName)\", \"lastName\": \"\(UdacityAPI.LastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(gps[0]), \"longitude\": \(gps[1])}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapViewController)!.notifyUser(error.description)
                }
                
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            dispatch_async(dispatch_get_main_queue()) {
                (view as? MapViewController)!.finishSaveStudentLocationNetworkPoint()
            }
            
        }
        task.resume()
    }
    
    static internal func UpdateStudentLocation(latitude:String, longitude:String,  _mediaURL:String,  mapString:String, view: UIViewController){
        
        dispatch_async(dispatch_get_main_queue()) {
            (view as? MapPinSelectorViewController)!.startNetworkPoint()
        }
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(ParseAPI.ObjectID)"
        println("Update: \(urlString)")
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var lat:String!
        var lon:String!
        var mediaUrl:String!
        
        lat = latitude
        lon = longitude
        
        if _mediaURL.isEmpty{
            mediaUrl = ParseAPI.MediaURL
        }else{
            mediaUrl = _mediaURL
        }
        
        let json = "{\"uniqueKey\": \"\(UdacityAPI.AccountKey)\", \"firstName\": \"\(UdacityAPI.FirstName)\", \"lastName\": \"\(UdacityAPI.LastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(lat), \"longitude\": \(lon)}"
        
        request.HTTPBody = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        println(json)
        

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                
                println(error.description)
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapPinSelectorViewController)!.notifyUser(error.description)
                }
                
                return
            }
            
            // Parse JSON
            var parsingError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let error = json["error"] as? String{
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapPinSelectorViewController)!.notifyUser(error)
                }
                
            }else{
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapPinSelectorViewController)!.notifySaved()
                }
            }
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
        }
        task.resume()
    }
    
}