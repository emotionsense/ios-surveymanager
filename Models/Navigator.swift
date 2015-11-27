//
//  Navigator.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    Implements conditional navigation away from a question in a survey.
    
    Each question in a survey has a navigator associated with it that is
    responsible for calculating the next question ID to show (that may be
    conditional on the result of the question).
*/
public class Navigator : NSObject, NSCoding {
    
    //TODO: document the structure of navDict better
    /**
        A dictionary representing the possible paths that can be taken
        from this question.
    */
    var navDict : JSONValue
    
    ///The type of the question that is using this Navigator.
    var questionType : BaseQuestion.QuestionType
    
    /**
        Constructs a Navigator from a navigation dictionary and a
        question type.
    
        :param: dict A SwiftyJSON object representing the possible paths
                     that can be taken from the question.
        :param: type The type of question. Used to work out how to
                     conditionally navigate.
    */
    init(dict: JSONValue, type: BaseQuestion.QuestionType) {
        navDict = dict
        questionType = type
    }
    
    /**
        Initialises a Navigator instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        //TODO: explicit unwrap is bad
        navDict = SurveyJSON.decodeJSON(coder.decodeObjectForKey("navDict") as! String)!
        questionType = BaseQuestion.QuestionType(rawValue: coder.decodeObjectForKey("questionType") as! String)!
    }
    
    /**
        Serializes a Navigator object.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(SurveyJSON.encodeJSON(navDict), forKey: "navDict")
        coder.encodeObject(questionType.rawValue, forKey: "questionType")
    }
    
    /**
        Decides, based on the state of a question, what the next
        question to be displayed in the survey should be. 
    
        Uses assert statements internally to check that the state
        type matches the question type used. In practice, these assertions
        being violated means that there is something seriously wrong with
        the navigation stack in the app. However, if a mismatch is found,
        then the app will crash. This should be fixed in a future version
        of the library.
    
        :param: state The state of the current question. Used along with
                      the navigation dictionary to compute the next question
                      to show.
    
        :returns: The question ID of the next question to show.
    */
    public func nextQuestion(state: BaseQuestion.QuestionState) -> String {
        
        //TODO: explicit unwrap is bad
        //TODO: need to document the structure of navdict better
        //TODO: clean structure here up a bit - it's a mess at the moment
        //TODO: don't use assert statements
        var defaultNext = navDict["default"].string!
        
        switch(state) {
            case let .Categorical(picked):
                
                assert( questionType == BaseQuestion.QuestionType.CategoricalSingle ||
                        questionType == BaseQuestion.QuestionType.CategoricalMulti, "Mismatched state and question types.")
                if let routes = navDict["conditions"].array {
                    for route : JSONValue in routes {
                        var valid = true
                        var condition = route["if_answer"].array!
                        
                        //Ensure that the picked choices and the route are identical before confirming navigation
                        for answer : JSONValue in condition {
                            if !(contains(picked, answer.string!)) {
                                valid = false
                            }
                        }
                        for choice : String in picked {
                            if !(contains(condition, JSONValue(choice))) {
                                valid = false
                            }
                        }
                        if valid {
                            return route["go_to"].string!
                        }
                    
                    }
                    return defaultNext
                } else {
                    return defaultNext
                }
            
            case let .Affect(gridState):
                assert(questionType == BaseQuestion.QuestionType.Affect, "Mismatched state and question types.")
                
                if let routes = navDict["conditions"].array {
                    for route : JSONValue in routes {
                        switch(gridState) {
                            case .TopLeft:
                                if route["if_answer"].string! == "negative_aroused" {
                                    return route["go_to"].string!
                                }
                            case .TopRight:
                                if route["if_answer"].string! == "positive_aroused" {
                                    return route["go_to"].string!
                                }
                            case .BottomLeft:
                                if route["if_answer"].string! == "negative_unaroused" {
                                    return route["go_to"].string!
                                }
                            case .BottomRight:
                                if route["if_answer"].string! == "positive_unaroused" {
                                    return route["go_to"].string!
                                }
                            default:
                                return defaultNext
                        }
                    }
                } else {
                    return defaultNext
                }
            
            case let .Text(answer):
                assert( questionType == BaseQuestion.QuestionType.TextSingle ||
                        questionType == BaseQuestion.QuestionType.TextMulti ||
                        questionType == BaseQuestion.QuestionType.TextUsername, "Mismatched state and question types.")
                //Currently there's nothing in the docs about conditional navigation on text questions, but it also doesn't say that it's explicitly not supported. It would be possible to implement conditional navigation, but we'll leave it for now.
                return defaultNext
            
            case let .LikertList(dict):
                assert(questionType == BaseQuestion.QuestionType.LikertList, "Mismatched state and question types.")
                
                if let routes = navDict["conditions"].array {
                    for route : JSONValue in routes {
                        var entries = route["likert_entries"].array!
                        var answers = route["if_answer"].array!
                        var valid = true
                        for var i = 0; i < entries.count; i++ {
                            if dict[entries[i].string!] != answers[i].integer! {
                                valid = false
                            }
                        }
                        if valid {
                            return route["go_to"].string!
                        }
                    }
                } else {
                    return defaultNext
                }
            
            case .None:
                return defaultNext
            default:
                return defaultNext
        }
        
        return defaultNext
        
    }
    
}
