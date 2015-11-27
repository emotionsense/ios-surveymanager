//
//  Survey.swift
//  SurveyManager
//
//  Created by Bruce Collie on 24/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

//TODO: rewrite to use failable initialisers

/**
    Represents a single Survey in EasyM. This class is at the
    core of the survey management in the application, and 
    contains a lot of useful functionality.
*/
public class Survey : NSObject, NSCoding, TextReplacer {
    
    /**
        All surveys have an identifier associated with
        them - if this is not present then the survey is
        not valid.
    */
    public var surveyID : String = ""
    
    /**
        Any valid survey must have an entry point (i.e. a
        question that is presented first whatever happens.
        Without this the survey is not valid.
    */
    public var firstQuestion : BaseQuestion? = nil
    
    //TODO: should probably be [String : BaseQuestion]
    /**
        Surveys have a list of questions associated with
        them. This is of type [BaseQuestion] to allow
        for any overriding question type to appear in a
        survey.
    */
    public var questions : [BaseQuestion] = []
    
    /**
        Throughout a survey, text input questions may
        prompt users for free form text input. This input
        can be associated with a variable name, and the
        mapping stored in this dictionary.
    */
    public var storedVariables : [String : String] = [:]
    
    //TODO: better name
    /**
        EasyM's concept of "quick responses" means that
        surveys have a time by which they should end to
        trigger some behaviour in the controlling app.
        This property manages this ending time.
    */
    public var endBy : NSDate?
    
    /**
        In order to construct a response, the ending time
        of the survey has to be recorded.
    */
    public var endTime : NSDate?
    
    /**
        Empty initialiser due to implementation of the
        Survey class before failable initialisers were
        added to Swift. This will probably be removed
        in a future version of the library.
    */
    public override init() {
        
    }
    
    /**
        Initialises a Survey instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        surveyID = coder.decodeObjectForKey("surveyID") as! String
        firstQuestion = coder.decodeObjectForKey("firstQuestion") as? BaseQuestion
        questions = coder.decodeObjectForKey("questions") as! [BaseQuestion]
        storedVariables = coder.decodeObjectForKey("storedVariables") as! [String : String]
        endBy = coder.decodeObjectForKey("endBy") as? NSDate
    }
    
    /**
        Serializes a Survey object.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(surveyID, forKey: "surveyID")
        if(firstQuestion != nil) {
            coder.encodeObject(firstQuestion!, forKey: "firstQuestion")
        }
        coder.encodeObject(questions as NSArray, forKey: "questions")
        coder.encodeObject(storedVariables as NSDictionary, forKey: "storedVariables")
        if (endBy != nil) {
            coder.encodeObject(endBy!, forKey: "endBy")
        }
    }
    
    /**
        Factory method to construct a Survey object from a JSON
        representation. This will be replaced by a more idiomatic
        failable initializer in a future version of this library.
    
        :param: dict The JSON representation of the survey to be
                     constructed.
    
        :returns: A valid Survey object if the JSON can be properly
                  converted, and nil if there are any errors.
    */
    public class func surveyFromJSONValue(dict: JSONValue) -> Survey? {
        
        var ret = Survey()
        
        //If we don't have a survey ID then the whole survey is invalid and we can return nil
        if let trySurveyID = dict["survey_id"].string {
            ret.surveyID = trySurveyID
        } else {
            return nil
        }
        
        //In parsing out the questions, any badly formed JSON will simply not be added to the list of questions
        if let questionArray = dict["questions"].array {
            
            for questionDict : JSONValue in questionArray {
                if let questionType = questionDict["question_type"].string {
                    var question : BaseQuestion? = nil
                    switch questionType {
                        
                        //Switch based on the question type set in the JSON, then add an appropriate question type to the survey's list depending on the result.
                    case "categorical_multi_choice",
                    "categorical_single_choice":
                        question = CategoricalQuestion(dict: questionDict)
                        
                    case "instruction_single_line",
                    "instruction_multi_line",
                    "instruction_affect_grid":
                        question = Instruction(dict: questionDict)
                        
                    case "text_multi_line",
                    "text_single_line",
                    "text_user_name":
                        question = TextQuestion(dict: questionDict)
                        (question as! TextQuestion).textReplacer = ret
                        
                    case "affect_grid":
                        question = AffectGridQuestion(dict: questionDict)
                        
                    case "likert_list",
                    "random_sample":
                        question = LikertList(dict: questionDict)
                        
                    default:
                        continue
                    }
                    
                    if let actualQuestion = question {
                        ret.questions.append(actualQuestion)
                    }
                }
            }
        }
        
        //If we don't have an ID for the first question then the survey must also be invalid
        if let firstQuestionID = dict["first_question_id"].string {
            //We can also have a first question ID but no corresponding question object - in this case the survey will again be invalid
            if let tryFirstQuestion = ret.getQuestionByID(firstQuestionID) {
                ret.firstQuestion = tryFirstQuestion
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        return ret
    }
    
    /**
        Static factory method to create a survey. If the 
        passed JSON is valid then the returned survey will 
        be usable, otherwise nil is returned (as documented
        above).
        
        :param: json A String of JSON data to construct a
                     survey from.
    
        :returns: A valid survey object if the JSON can be
                  converted, and nil otherwise.
    */
    public class func surveyFromJSONString(json: String) -> Survey? {
        var dict = SurveyJSON.decodeJSON(json)!
        return surveyFromJSONValue(dict)
    }
    
    /**
        Gets the question with a given ID in this survey.
    
        :param: id The question ID to retrieve.
    
        :returns: A BaseQuestion if the ID exists in this
                  survey, and nil otherwise.
    */
    public func getQuestionByID(id: String) -> BaseQuestion? {
        for question in questions {
            if(question.questionID == id) {
                return question
            }
        }
        return nil
    }
    
}