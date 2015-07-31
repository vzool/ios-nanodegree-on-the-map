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
    
    internal static let APPLICATION_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    internal static let API_KEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static internal func GetStudentLocations(view:UIViewController, flag: ControlFlag){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if flag == ControlFlag.MapViewController{
                (view as? MapViewController)!.startNetworkPoint()
            }
            
            else if flag == ControlFlag.TableViewController{
                (view as? TableViewController)!.startNetworkPoint()
            }
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                
                dispatch_async(dispatch_get_main_queue()) {
                    if flag == ControlFlag.MapViewController{
                        (view as? MapViewController)!.notifyUser(error.description)
                    }
                        
                    else if flag == ControlFlag.TableViewController{
                        (view as? TableViewController)!.notifyUser(error.description)
                    }
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
                    
                    if flag == ControlFlag.MapViewController{
                        (view as? MapViewController)!.loadStudentLocations()
                    }
                        
                    else if flag == ControlFlag.TableViewController{
                        (view as? TableViewController)!.loadStudentLocations()
                    }
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if flag == ControlFlag.MapViewController{
                    (view as? MapViewController)!.finishNetworkPoint()
                }
                    
                else if flag == ControlFlag.TableViewController{
                    (view as? TableViewController)!.finishNetworkPoint()
                }
                
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
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
            }
        }
        task.resume()
    }
    
    static internal func SaveStudentLocation(latitude:String, longitude:String,  _mediaURL:String,  mapString:String, view: UIViewController){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityAPI.AccountKey)\", \"firstName\": \"\(UdacityAPI.FirstName)\", \"lastName\": \"\(UdacityAPI.LastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(_mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapPinSelectorViewController)!.notifyUser(error.description)
                }
                
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
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
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
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