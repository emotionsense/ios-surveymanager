//
//  SurveyNetworking.swift
//  SurveyManager
//
//  Created by Bruce Collie on 30/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    Static class that presents a set of useful methods
    for dealing with Survey objects over a network.
*/
public class SurveyNetworking {
    
    /**
        The base URL to which all API requests are made.
    
        :returns: The base API URL - this value is
                  constant in the current version of the
                  library.
    */
    public class func baseURL() -> NSURL {
        return NSURL(string: "http://pizza.cl.cam.ac.uk/easym/v1/php/")!
    }
    
    /**
        Attempts to load a string of JSON data from the
        specified URL. If the request is successful, the
        callback success is called with the retrieved JSON
        as its argument. On failure, the failure callback
        is called with the generated NSError as an argument.
    
        :param: url The URL to load the JSON from.
        :param: success A callback function that is called
                        when the request completes successfully
                        with a JSON string.
        :param: failure A callback function that is called when
                        the request results in an error.
    */
    public class func loadJSONFromURL(url: NSURL, success: (String -> Void), failure: (NSError -> Void) ) -> Void {
        var URLSession = NSURLSession.sharedSession()
        var downloadTask = URLSession.dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if let actualError = error {
                    failure(actualError)
                } else {
                    success(NSString(data: data, encoding: NSUTF8StringEncoding)! as String)
                }
            })
        downloadTask.resume()
    }
    
    /**
        Attempts to load a Survey object from the specified
        URL. If the request is successful, the callback 
        success is called with the retrieved Survey as its
        argument. On failure, the failure callback is called
        with the generated NSError as an argument.
    
        :param: url The URL to load the Survey from.
        :param: success A callback function that is called
                        when the request completes successfully
                        with a Survey object.
        :param: failure A callback function that is called when
                        the request results in an error.
    */
    public class func loadSurveyFromURL(url: NSURL, success: (Survey -> Void), failure: (NSError -> Void) ) -> Void {
        
        var successCallback = {
            (json: String) -> Void in
            var trySurvey = Survey.surveyFromJSONString(json)
            if let survey = trySurvey {
                success(survey)
            }
        }
        
        loadJSONFromURL(url, success: successCallback, failure: failure)
    }
            
}