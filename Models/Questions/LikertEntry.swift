//
//  LikertEntry.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    A LikertEntry question is one where the user can provide
    a rating on a sliding scale (e.g. how stressed have you been
    recently? not at all <-> completely). This rating is converted
    to a score value and answer (e.g. not very, 1) for result 
    collation.
*/
public class LikertEntry : BaseQuestion {
    
    /**
        Maintains the state of the sliding scale used in this
        question.
    */
    public var scale : LikertScale
    
    ///The question being asked (e.g. how do you feel?)
    public var title : String
    
    /**
        The stacked property controls how the entry is displayed
        in the context of a question that may have multiple
        LikertEntries being displayed. If stacked is true, then
        the entry's title should be displayed above it, and if
        stacked is false, it should be displayed inline. This
        property is a guide for UI libraries.
    */
    public var stacked : Bool
    
    /**
        Extracts LikertEntry specific data from a SwiftyJSON
        object. Extends the equivalent method in BaseQuestion.
    
        :param: dict The SwiftyJSON object of question data.
    */
    override init(dict: JSONValue) {
        
        var minValue = dict["scale_min_value"].integer!
        var maxValue = dict["scale_max_value"].integer!
        var initValue = dict["scale_init_value"].integer!
                
        if let tryStacked = dict["display_stacked"].bool {
            stacked = tryStacked
        } else {
            stacked = false
        }
        
        var untypedDescriptions = dict["scale_descriptions"].array!
        var descriptions : Array<String> = []
        for desc : JSONValue in untypedDescriptions {
            descriptions.append(desc.string!)
        }
        
        scale = LikertScale(min: minValue, max: maxValue, start: initValue, descs: descriptions)
        title = dict["title"].string!
        
        super.init(dict: dict)
    }
    
    /**
        Initialises a LikertEntry instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    required public init(coder: NSCoder) {
        self.scale = coder.decodeObjectForKey("scale") as! LikertScale
        self.title = coder.decodeObjectForKey("title")as! String
        self.stacked = coder.decodeBoolForKey("stacked")
        super.init(coder: coder)
    }
    
    /**
        Serialises a LikertEntry instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    override public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.scale, forKey: "scale")
        coder.encodeObject(self.title, forKey: "title")
        coder.encodeBool(self.stacked, forKey: "stacked")
        super.encodeWithCoder(coder)
    }
    
    /**
        Serialises completed question data to JSON. Extends
        the data already serialised by the parent class with
        the LikertEntry specific data. Can crash the
        app if the state of the question is set incorrectly,
        which should be fixed in future versions of the
        library.
        
        :returns: A SwiftyJSON object of this question's
                  completed data, and nil if there is an error
                  in this object's data (or the parent's).
    */
    public override func toJSON() -> JSONValue? {
        var returnDict : [String : JSONValue] = [
            "question_id" : JSONValue.JString(questionID),
            "question_type" : JSONValue.JString(questionType().rawValue)
        ]
        
        return JSONValue.JObject(returnDict)
    }
    
    /**
        Overrides from BaseQuestion.
    
        :returns: QuestionType.LikertEntry
    */
    override public func questionType() -> BaseQuestion.QuestionType {
        return QuestionType.LikertEntry
    }
    
}
