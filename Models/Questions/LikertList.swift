//
//  LikertRating.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    A LikertList question is one made up of multiple
    LikertEntry questions. It is functionally just a
    small wrapper around a list of LikertEntry objects.

    Extends BaseQuestion, and so all needed methods have
    been overriden.
*/
public class LikertList : BaseQuestion {
    
    /**
        The array of LikertEntry questions that make up
        this question.
    */
    public var questions : [LikertEntry] = []
    
    /**
        Extracts LikertList specific data from a SwiftyJSON
        object. Extends the equivalent method in BaseQuestion.
    
        :param: dict The SwiftyJSON object of question data.
    */
    override init(dict: JSONValue) {
        var untypedQuestions = dict["rating_questions"].array!
        for question : JSONValue in untypedQuestions {
            questions.append(LikertEntry(dict: question))
        }
        
        super.init(dict: dict)
    }
    
    /**
        Initialises a LikertList instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        self.questions = coder.decodeObjectForKey("questions") as! [LikertEntry]
        super.init(coder: coder)
    }
    
    /**
        Serialises a LikertList instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    override public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.questions, forKey: "questions")
        super.encodeWithCoder(coder)
    }
    
    /**
        Serialises completed question data to JSON. Extends
        the data already serialised by the parent class with
        the LikertList specific data. Can crash the
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
                for question : LikertEntry in questions {
                    if let tryEntry = question.toJSON() {
                        if let tryDict = tryEntry.object {
                            var mutableEntry = tryDict
                            
                            switch(question.state) {
                                case let .LikertEntry(answer, rating, touched):
                                    mutableEntry["answer"] = JSONValue.JString(answer)
                                    mutableEntry["rating"] = JSONValue.JNumber(rating)
                                    mutableEntry["touched"] = JSONValue.JBool(touched)
                                default:
                                    assert(false, "Wrong state type for likert entry.")
                            }
                            
                            answerArray.append(JSONValue.JObject(mutableEntry))
                        }
                    }
                }
                mutableParent["answer"] = JSONValue.JArray(answerArray)
                
                return JSONValue.JObject(mutableParent)
            }
        }
        return nil
    }
    
    /**
        Overrides from BaseQuestion.
    
        :returns: QuestionType.LikertList
    */
    override public func questionType() -> QuestionType {
        //TODO: Can also be random based on dict initialisation
        return QuestionType.LikertList
    }
    
}