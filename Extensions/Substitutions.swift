//
//  Extensions.swift
//  SurveyManager
//
//  Created by Bruce Collie on 12/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation

extension String {
    
    public func stringByApplyingSubsitutions(substitutions: [String : String]) -> String {
        var ret : String = self
        for variable : String in substitutions.keys {
            ret = ret.stringByReplacingOccurrencesOfString(variable, withString: substitutions[variable]!, options: nil, range: nil)
        }
        return ret
    }
    
}