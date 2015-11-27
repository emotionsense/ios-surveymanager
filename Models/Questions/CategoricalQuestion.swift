//
//  CategoricalQuestion.swift
//  SurveyManager
//
//  Created by Bruce Collie on 24/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    A Categorical question is one where users choose from several 
    distinct options. In EasyM, users can either choose only one
    of the presented options, or as many as they like (but not
    none).

    This class extends BaseQuestion and so all needed methods are
    overridden.
*/
public class CategoricalQuestion : BaseQuestion {
    
    ///If true, the user can select multiple answers.
    public var multipleSelectionEnabled : Bool
    
    //TODO: refactor to a scoredanswer?
    
    ///An array of all the answers the users can choose from
    public var choices : [String] = []
    
    ///An array of the scores given to each answer
    public var scores : [Int]? = nil
    
    /**
        Initialises a CategoricalQuestion instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        multipleSelectionEnabled = coder.decodeBoolForKey("multipleSelectionEnabled")
        choices = coder.decodeObjectForKey("choices") as! [String]
        scores = coder.decodeObjectForKey("scores") as? [Int]
        super.init(coder: coder)
    }
    
    /**
        Serialises a CategoricalQuestion instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public override func encodeWithCoder(coder: NSCoder) {
        coder.encodeBool(multipleSelectionEnabled, forKey: "multipleSelectionEnabled")
        coder.encodeObject(choices as NSArray, forKey: "choices")
        if(scores != nil) {
            coder.encodeObject(scores! as NSArray, forKey: "scores")
        }
        super.encodeWithCoder(coder)
    }
    
    /**
        Extracts CategoricalQuestion specific data from a SwiftyJSON
        object. Extends the equivalent method in BaseQuestion.
    
        :param: dict The SwiftyJSON objetc of question data.
    */
    override init(dict: JSONValue) {
        //Set whether or not we can select multiple options on this question
        var categoricalType = dict["question_type"].string!
        switch(categoricalType) {
        case "categorical_multi_choice":
            multipleSelectionEnabled = true
        default:
            multipleSelectionEnabled = false
        }
        
        //These should be ordered in the same way as in the JSON
        var JSONChoices = dict["choices"].array!
        for value : JSONValue in JSONChoices {
            choices.append(value.string!)
        }
        var JSONScores = dict["feedback_scores"].array
        if let actualJSONScores = JSONScores {
            var dummyScores : Array<Int> = []
            for value : JSONValue in actualJSONScores {
                dummyScores.append(value.integer!)
            }
            scores = dummyScores
        }
        
        super.init(dict: dict)
    }
    
    /**
        Serialises completed question data to JSON. Extends
        the data already serialised by the parent class with
        the CategoricalQuestion specific data. Can crash the
        app if the state of the question is set incorrectly,
        which should be fixed in future versions of the
        library.
    
        :returns: A SwiftyJSON object of this question's
                  completed data, and nil if there is an error
                  in this object's data (or the parent's).
    */
    public override func toJSON() -> JSONValue? {
        if let json = super.toJSON() {
            if let parent : [String : JSONValue] = json.object {
                var mutableParent = parent
                
                mutableParent["question_type"] = JSONValue.JString(questionType().rawValue)
                
                var answerArray : [JSONValue] = []
                switch(state) {
                case .Categorical(let choiceArray):
                    for choice : String in choiceArray {
                        answerArray.append(JSONValue.JString(choice))
                    }
                default:
                    //TODO: assert is bad
                    assert(false, "Wrong question state in categorical question.")
                }
                mutableParent["answer"] = JSONValue.JArray(answerArray)
                
                return JSONValue.JObject(mutableParent)
            }
        }
        return nil
    }
    
    /**
        Overrides from BaseQuestion.
    
        :returns: The correct question type - either
                  CategoricalSingle or CategoricalMulti.
    */
    override public func questionType() -> QuestionType {
        if multipleSelectionEnabled {
            return QuestionType.CategoricalMulti
        } else {
            return QuestionType.CategoricalSingle
        }
    }
    
}