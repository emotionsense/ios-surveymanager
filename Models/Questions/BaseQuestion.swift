//
//  BaseQuestion.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    An abstract (as much as possible) base class to represent a single question within
    a study. Should never be instantiated by user code.

    Contains data that is common to all questions.
*/
public class BaseQuestion : NSObject, NSCoding {
    
    ///A unique identifier for this question
    public var questionID : String
    
    ///The actual question being asked (e.g. "How do you feel?")
    public var questionText : String?
    
    ///A navigator object to compute the next question to display.
    public var navigator : Navigator? = nil
    
    /**
        A dictionary of substitutions to be made in the text of the
        question (from a previous question asking for input, e.g. a
        username).
    */
    public var textSubstitutions : [String : String] = [:]
    
    ///The time the question was first displayed to the user
    public var createTime : NSDate?
    
    ///The time the question was submitted (finished)
    public var endTime : NSDate?
    
    /**
        The recorded state of the question. Contains all needed
        information about the answer the user has provided to
        the question.
    */
    public var state : QuestionState = QuestionState.None
    
    /**
        Initialises a BaseQuestion instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder : NSCoder) {
        questionID = coder.decodeObjectForKey("questionID") as! String
        questionText = coder.decodeObjectForKey("questionText") as? String
        if let tryNav = coder.decodeObjectForKey("navigator") as? Navigator {
            navigator = tryNav
        }
        if let tryCreate = coder.decodeObjectForKey("createTime") as? NSDate {
            createTime = tryCreate
        }
        if let tryEnd = coder.decodeObjectForKey("endTime") as? NSDate {
            createTime = tryEnd
        }
        textSubstitutions = coder.decodeObjectForKey("textSubstitutions")as! [String : String]
    }
    
    /**
        Serialises a BaseQuestion instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(questionID, forKey: "questionID")
        if (questionText != nil) {
            coder.encodeObject(questionText!, forKey: "questionText")
        }
        if (navigator != nil) {
            coder.encodeObject(navigator!, forKey: "navigator")
        }
        if (createTime != nil) {
            coder.encodeObject(createTime!, forKey: "createTime")
        }
        if (endTime != nil) {
            coder.encodeObject(endTime!, forKey: "endTime")
        }
        coder.encodeObject(textSubstitutions as NSDictionary, forKey: "textSubstitutions")
    }
    
    /**
        Initialises a BaseQuestion from a SwiftyJSON object.
        All fields common to every kind of Question are extracted
        in this initialiser.
    
        :param: dict The JSON object containing the question data.
    */
    init(dict: JSONValue) {
        //TODO: consider error handling here
        questionID = dict["question_id"].string!
        questionText = dict["question_text"].string
        
        super.init()
        
        var navDict = dict["next_question"]
        if navDict {
            navigator = Navigator(dict: navDict, type: questionType())
        }
    }
    
    /**
        Serialises a completed question to JSON. The JSON returned
        by this method is extended by all subclasses to add their
        own relevant question data.
    
        :returns: A JSONValue representing the completed question
                  data if it is valid, and nil otherwise. Here, the
                  only reason for invalid data is that the creation
                  and finish times have not been recorded.
    */
    public func toJSON() -> JSONValue? {
        if let finish = endTime {
            if let create = createTime {
                var returnDict : [String : JSONValue] = [
                    "finish_time" : JSONValue.JNumber(Int(finish.timeIntervalSince1970)),
                    "create_time" : JSONValue.JNumber(Int(create.timeIntervalSince1970)),
                    "question_id" : JSONValue.JString(questionID)
                ]
                
                return JSONValue.JObject(returnDict)
            }
        }
        return nil
    }
    
    /**
        Encodes the type of the question, along with the mapping
        to the type specifier used in the JSON.
    */
    public enum QuestionType : String {
        case CategoricalSingle = "categorical_single_choice"
        case CategoricalMulti = "categorical_multi_choice"
        case InstructionSingle = "instruction_single_line"
        case InstructionMulti = "instruction_multi_line"
        case InstructionAffect = "instruction_affect_grid"
        case TextSingle = "text_single_line"
        case TextMulti = "text_multi_line"
        case TextUsername = "text_user_name"
        case Affect = "affect_grid"
        case LikertList = "likert_list"
        case LikertEntry = "likert_entry"
        case Random = "random_sample"
    }
    
    /**
        Encodes the state of a question, along with the appropriate
        type of answer data.
    */
    public enum QuestionState {
        case Categorical([String])
        case Text(String)
        case Affect(AffectGrid.GridState)
        case LikertList([String : Int])
        case LikertEntry(String, Int, Bool)
        case None
    }
    
    /**
        Gets the type of this question. Overriden on all subclasses
        of BaseQuestion, and will cause an app crash if called on
        an instance of BaseQuestion somehow (e.g. if a new
        subclass has forgotten to override it).
    
        :returns: The type of the question.
    */
    public func questionType() -> QuestionType {
        assert(false, "BaseQuestion does not have a QuestionType and should not be instantiated.")
        
        //Dummy return as this function shouldn't be called
        return QuestionType.CategoricalSingle
    }
}
