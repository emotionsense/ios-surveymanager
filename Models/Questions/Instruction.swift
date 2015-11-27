//
//  Instruction.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    An Instruction question is one that expects no input
    from the user - it exists only to instruct the user on
    how to use the survey. 

    Extends BaseQuestion, and so all needed methods have been
    overridden.
*/
public class Instruction : BaseQuestion {
    
    /**
        Instruction questions can display a custom button text
        to the user (instead of just 'submit') - this field 
        sets the text of the button.
    */
    public var buttonText : String
    
    /// The instruction text displayed to the user.
    public var instruction : String
    
    /**
        There are several types of instruction in EasyM - the
        instruction text can be either one or multiple lines
        (although in the current version of the UI, no 
        special distinction is made between these). Additionally,
        an Affect Grid can be shown as an instruction (not yet
        implemented).
    */
    public var instructionType : InstructionType
    
    /**
        Initialises an Instruction instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    required public init(coder: NSCoder) {
        self.buttonText = coder.decodeObjectForKey("buttonText") as! String
        self.instruction = coder.decodeObjectForKey("instruction")as! String
        self.instructionType = InstructionType(rawValue: coder.decodeObjectForKey("instructionType")as! String)!
        super.init(coder: coder)
    }
    
    /**
        Serialises an Instruction instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public override func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.buttonText, forKey: "buttonText")
        coder.encodeObject(self.instruction, forKey: "instruction")
        coder.encodeObject(self.instructionType.rawValue, forKey: "instructionType")
        super.encodeWithCoder(coder)
    }
    
    /**
        Extracts Instruction specific data from a SwiftyJSON
        object. Extends the equivalent method in BaseQuestion.
    
        :param: dict The SwiftyJSON objetc of question data.
    */
    override init(dict: JSONValue) {
        buttonText = dict["button_text"].string!
        instruction = dict["instruction"].string!
        
        var instructionTypeString = dict["question_type"].string!
        switch instructionTypeString {
            case "instruction_single_line":
                instructionType = InstructionType.Single
            case "instruction_affect_grid":
                instructionType = InstructionType.Affect
            default:
                instructionType = InstructionType.Multi
        }
        
        super.init(dict: dict)
    }
    
    /**
        Instruction questions never have an answer, and so
        converting one to JSON will always result in nil (as
        nil is used to mark question with no answer in the
        response collation code).
    
        :returns: nil of JSONValue.
    */
    public override func toJSON() -> JSONValue? {
        return nil
    }
    
    /**
        Overrides from BaseQuestion.
    
        :returns: The correct question type - either
                  InstructionSingle, InstructionMulti or
                  InstructionAffect.
    */
    override public func questionType() -> QuestionType {
        switch(instructionType) {
        case .Single:
            return .InstructionSingle
        case .Multi:
            return .InstructionMulti
        case .Affect:
            return .InstructionAffect
        }
    }
    
    /**
        Defines the instruction type enum as described above.
    */
    public enum InstructionType : String {
        case Single = "Single"
        case Multi = "Multi"
        case Affect = "Affect"
    }
    
}