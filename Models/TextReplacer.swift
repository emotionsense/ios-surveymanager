//
//  TextReplacer.swift
//  SurveyManager
//
//  Created by Bruce Collie on 01/07/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation

/**
    A protocol that classes conform to if they
    support making variable substitutions in a
    corpus of text. The only requirement for a
    class to implement this protocol is for it
    to maintain a mapping of variable names to
    text contents.
*/
@objc public protocol TextReplacer {
    
    /**
        The required mapping from variable name
        to substituted text.
    */
    var storedVariables : [String : String] { get set }
    
}