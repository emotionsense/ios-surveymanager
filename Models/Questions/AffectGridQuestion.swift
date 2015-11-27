
//
//  AffectGrid.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    An Affect Grid question is one where users indicate
    their response by dragging a slider on a 2-dimensional
    grid view. These questions have a set of labels (3 on
    top, one at the left and the right, and 3 on the bottom)
    that guide users. 

    This class extends BaseQuestion and all needed methods
    are overridden.
*/
public class AffectGridQuestion : BaseQuestion {
    
    /**
        Stores data about the grid used in this question - 
        currently only labels.
    */
    public var grid : AffectGrid
    
    /**
        Initialises an AffectGridQuestion object from its
        JSON representation. Extends the equivalent 
        initialiser from BaseQuestion.
    
        :params: dict A JSON object representing the
                      question to be constructed.
    */
    override init(dict: JSONValue) {
        var labels : [String] = [
            dict["top_left_label"].string!,
            dict["top_label"].string!,
            dict["top_right_label"].string!,
            dict["left_label"].string!,
            dict["right_label"].string!,
            dict["bottom_left_label"].string!,
            dict["bottom_label"].string!,
            dict["bottom_right_label"].string!
        ]
        
        grid = AffectGrid(l: labels)
        
        super.init(dict: dict)
    }
    
    /**
        Initialises an AffectGridQuestion instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        self.grid = coder.decodeObjectForKey("grid") as! AffectGrid
        super.init(coder: coder)
    }
    
    /**
        Serialises an AffectGridQuestion instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    override public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.grid, forKey: "grid")
        super.encodeWithCoder(coder)
    }
    
    /**
        Serialises completed question data to JSON. Extends
        the data already serialised by the parent class with
        the AffectGridQuestion specific data. Can crash the
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
                
                var pos = CGPointZero
                var size = CGSizeZero
                
                switch(state) {
                case .Affect(let gridstate):
                    switch(gridstate) {
                    case let .TopLeft(p, s):
                        mutableParent["answer"] = JSONValue.JString("negative_aroused")
                        pos = p
                        size = s
                    case let .TopRight(p, s):
                        mutableParent["answer"] = JSONValue.JString("positive_aroused")
                        pos = p
                        size = s
                    case let .BottomLeft(p, s):
                        mutableParent["answer"] = JSONValue.JString("negative_unaroused")
                        pos = p
                        size = s
                    case let .BottomRight(p, s):
                        mutableParent["answer"] = JSONValue.JString("positive_unaroused")
                        pos = p
                        size = s
                    }
                default:
                    assert(false, "Wrong state type for affect grid.")
                }
                
                mutableParent["x_lim"] = JSONValue.JNumber(size.width)
                mutableParent["y_lim"] = JSONValue.JNumber(size.height)
                mutableParent["x_value"] = JSONValue.JNumber(pos.x)
                mutableParent["y_value"] = JSONValue.JNumber(pos.y)
                
                return JSONValue.JObject(mutableParent)
            }
        }
        return nil
    }
    
    /**
        Overrides from BaseQuestion.
    
        :returns: QuestionType.Affect
    */
    override public func questionType() -> QuestionType {
        return QuestionType.Affect
    }
    
}
