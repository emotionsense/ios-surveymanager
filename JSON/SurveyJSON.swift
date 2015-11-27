//
//  SurveyJSON.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    Handles the encoding and decoding of JSON in an app that uses surveys.

    Uses NSJSONSerialization internally to convert from Strings to NSDictionary
    instances, and SwiftyJSON for managing type-safe JSON data within the app. 
*/
public class SurveyJSON {
    
    /**
        Decodes a String of JSON data into a SwiftyJSON object.
    
        :param: json The JSON string to be decoded.
    
        :returns: An Optional<JSONValue> that is nil if the passed string cannot be converted
                  to a valid JSON object. Otherwise the optional contains a JSONValue that
                  corresponds to the passed string.
    */
    public class func decodeJSON(json: String) -> JSONValue? {
        var data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error : NSError? = nil
        var dict : AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error)
        if let actualError = error {
            println("An error occured parsing JSON: \(actualError)")
            return nil
        }
        return JSONValue(dict)
    }
    
    /**
        Encodes a SwiftyJSON value as a String of valid JSON data.
    
        :param: dict The JSON object to be encoded.
    
        :returns: A String of JSON data. Due to SwiftyJSON's internal representations, this
                  may be INVALID_JSON_DATA. Calling code should correctly handle this case.
    */
    public class func encodeJSON(dict: JSONValue) -> String {
        return dict.description
    }
    
    /**
        Reads a bundled JSON file into a String.
        
        Currently behaves badly if passed a filename that does not exist - will crash on an
        explicit Optional unwrap, so care should be taken when using this method.
    
        :param: name The name of the resource file without any extension (e.g. "app_tour").
    
        :returns: A String containing the contents of the file (if the file exists).
    */
    public class func getJSONFileWithName(name: String) -> String {
        var filePath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
        // FIXME: Explicit optional unwrapping is bad.
        var jsonString = NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding, error: NSErrorPointer()) as! String
        return jsonString
    }
    
    /**
        Takes a completed Survey object along with some user identification data, and constructs
        a response to be sent back to the study's servers.
    
        :param: survey The completed Survey object to be used. All completed questions in the survey
                       will have their response state included in the JSON.
        :param: email The email of the user filling out the survey.
        :param: uuid The device UUID that has just completed the survey.
    
        :returns: A SwiftyJSON object containing the completed survey response, ready to be decoded
                  and sent to the study server.
    */
    public class func generateJSONResponse(survey: Survey, email: String?, uuid: String? = nil) -> JSONValue {
        var responseDict : [String : JSONValue] = [
            "operating_system" : JSONValue.JString("ios"),
            "survey_id" : JSONValue.JString(survey.surveyID)
        ]
        
        if let email = email {
            responseDict["account_name"] = JSONValue.JString(email)
        }
        
        if let uuid = uuid {
            responseDict["uuid"] = JSONValue.JString(uuid)
        }
        
        if let finish = survey.endTime {
            responseDict["finish_time"] = JSONValue.JNumber(Int(finish.timeIntervalSince1970))
        }
        
        var answers : [JSONValue] = []
        for question : BaseQuestion in survey.questions {
            if let tryQuestion = question.toJSON() {
                answers.append(tryQuestion)
            }
        }
        responseDict["answers"] = JSONValue.JArray(answers)
        
        return JSONValue.JObject(responseDict)
    }
    
}