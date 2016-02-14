//
//  SunriseSunsetAPI.swift
//  SunPaper
//
//  Created by David Celis on 2/13/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Foundation

class SunriseSunsetAPI {
    let baseURL = "http://api.sunrise-sunset.org/json"

    func getSunsetAndSunriseTimes(latitude: Double, longitude: Double) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0")

        let task = session.dataTaskWithURL(url!) { data, response, error in
            if (error != nil) {
                NSLog("sunrise-sunset API error: \(error)")
            }

            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    let results = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    NSLog("Got results for coordinates \(latitude), \(longitude): \(results)")
                default:
                    NSLog("sunrise-sunset API returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                }
            }
        }

        task.resume()
    }
}