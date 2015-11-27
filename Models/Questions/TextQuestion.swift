//
//  TextQuestion.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    A TextQuestion is one where the user is prompted to enter
    some amount of free-form text. This text can then be
    stored into a specified variable and reused throughout
    the rest of the survey (for example, prompting the user for
    their name).
*/
public class TextQuestion : BaseQuestion {
    
    /**
        Text entry questions can be single or multiple line.
        For reference, the standard UI implementation uses a
        UITextField for single line and a UITextView for 
        multiple.
    */
    var isMultipleLine : Bool
    
    /**
        The question's textReplacer is responsible for managing
        variable substitutions throughout the lifetime of the
        containing survey. If nil, no text substitutions will be
        performed.
    */
    var textReplacer : TextReplacer? = nil
    
    /** 
        The variable name that answers are stored in for
        the purposes of performing substitutions.
    */
    var storeVariable : String? = nil
    
    /**
        Initialises a TextQuestion instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    required public init(coder: NSCoder) {
        isMultipleLine = coder.decodeBoolForKey("isMultipleLine")
        textReplacer = coder.decodeObjectForKey("textReplacer") as? TextReplacer
        storeVariable = coder.decodeObjectForKey("storeVariable") as? String
        super.init(coder: coder)
    }
    
    /**
        Serialises a TextQuestion instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    override public func encodeWithCoder(coder: NSCoder) {
        coder.encodeBool(self.isMultipleLine, forKey: "isMultipleLine")
        if (textReplacer != nil) {
            coder.encodeObject(textReplacer!, forKey: "textReplacer")
        }
        if (storeVariable != nil) {
            coder.encodeObject(storeVariable!, forKey: "storeVariable")
        }
        super.encodeWithCoder(coder)
    }
    
    /**
        Extracts TextQuestion specific data from a SwiftyJSON
        object. Extends the equivalent method in BaseQuestion.
        
        :param: dict The SwiftyJSON object of question data.
    */
    override init(dict: JSONValue) {
        var entryType = dict["question_type"].string!
        switch entryType {
            case "text_multi_line":
                isMultipleLine = true
            default:
                isMultipleLine = false
        }
        
        if let variable = dict["store_result"].string {
            storeVariable = variable
        }
        
        super.init(dict: dict)
    }
    
    /**
        Overrides from BaseQuestion.
        
        :returns: The correct question type - either
                  TextMulti or TextSingle.
    */
    override public func questionType() -> QuestionType {
        if isMultipleLine {
            return .TextMulti
        } else {
            return .TextSingle
        }
    }
    
}