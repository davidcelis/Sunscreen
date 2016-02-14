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

    func getSunData(latitude: Double, longitude: Double, success: (SunData) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0")

        let task = session.dataTaskWithURL(url!) { data, response, error in
            if (error != nil) {
                NSLog("sunrise-sunset API error: \(error)")
            }

            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let sunData = self.parseSunsetAndSunriseJSON(data!) {
                        success(sunData)
                    }
                default:
                    NSLog("sunrise-sunset API returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                }
            }
        }

        task.resume()
    }

    private func parseSunsetAndSunriseJSON(data: NSData) -> SunData? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict

        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("Could not parse JSON: \(error)")
            return nil
        }

        let results = json["results"] as! JSONDict
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"

        let sunData = SunData(
            civilTwilightBegin: formatter.dateFromString(results["civil_twilight_begin"] as! String)!,
            sunrise: formatter.dateFromString(results["sunrise"] as! String)!,
            noon: formatter.dateFromString(results["solar_noon"] as! String)!,
            sunset: formatter.dateFromString(results["sunset"] as! String)!,
            civilTwilightEnd: formatter.dateFromString(results["civil_twilight_end"] as! String)!
        )

        return sunData
    }
}

struct SunData {
    var civilTwilightBegin: NSDate
    var sunrise: NSDate
    var noon: NSDate
    var sunset: NSDate
    var civilTwilightEnd: NSDate
}