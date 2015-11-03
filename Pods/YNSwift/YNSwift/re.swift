//
//  re.swift
//  YNSwift
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

public class re {
    public class func sub(regex: String, _ repl: String, _ str: String) -> String {
        let regex = try? NSRegularExpression(pattern: regex, options: [])
        return regex?.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: repl) ?? str
    }
    
    public class func match(regex: String, _ str: String) -> Bool {
        return str.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch) != nil
    }
}
