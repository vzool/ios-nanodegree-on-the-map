//
//  StudentLocationList.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/25/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

struct StudentInformation{
    
    var data:[StudentLocation]!
    
    init(dict : NSDictionary){
        
        if let results = dict["results"] as? NSArray{
            
            data = Array(count: results.count, repeatedValue: StudentLocation())
            
            for(var i = 0; i < results.count; i++){
                
                data[i].uniqueKey = results[i]["uniqueKey"] as? String
                data[i].firstName = results[i]["firstName"] as? String
                data[i].lastName = results[i]["lastName"] as? String
                data[i].mapString = results[i]["mapString"] as? String
                data[i].mediaURL = results[i]["mediaURL"] as? String
                
                if let lat = results[i]["latitude"] as? Double{
                    data[i].latitude = lat
                }
                
                if let lon = results[i]["longitude"] as? Double{
                    data[i].longitude = lon
                }
            }
        }
    }
}