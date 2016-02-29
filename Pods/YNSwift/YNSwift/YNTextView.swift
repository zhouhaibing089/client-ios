//
//  YNTextView.swift
//  YNSwift
//
//  Created by Yoncise on 1/21/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

public class YNTextView: UITextView, UITextViewDelegate {
    
    var edited = false
    public var hint: String? {
        didSet {
            if !self.edited {
                self.text = self.hint
            }
        }
    }
    var hintColor = UIColor.grayColor()
    var color: UIColor?
    public var onChange: ((String) -> Void)?
    public var onDidBeginEditing: ((YNTextView) -> Void)?
    public var onDidEndEditing: ((YNTextView) -> Void)?
    var heightConstraint: NSLayoutConstraint?
    
    public var maxHeight: CGFloat?
    public var minHeight: CGFloat?
    
    override public var text: String! {
        get {
            if edited {
                return super.text
            } else {
                // 用户直接点击输入法联想出来的字的时候, 不会调用 textView:shouldChangeTextInRange:replacementText
                // 这里手动处理
                let text = super.text.stringByReplacingOccurrencesOfString(self.hint!, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let trimmed = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if trimmed != "" {
                    self.edited = true
                    self.textColor = self.color
                    self.text = trimmed
                    return trimmed
                }
                return ""
            }
        }
        set {
            if newValue == "" {
                self.edited = false
                self.text = self.hint
                self.textColor = self.hintColor
            } else {
                super.text = newValue
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        
        self.delegate = self
        self.hint = super.text
        self.color = self.textColor
        self.textColor = self.hintColor
        
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                self.heightConstraint = constraint
            }
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let intrinsicHeight = self.contentSize.height
        var constant = intrinsicHeight
        if let minHeight = self.minHeight {
            constant = max(minHeight, intrinsicHeight)
        }
        if let maxHeight = self.maxHeight {
            constant = min(maxHeight, constant)
            if intrinsicHeight < maxHeight {
                self.setContentOffset(CGPointMake(0, 0), animated: true)
            }
        }
        self.heightConstraint?.constant = constant
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        self.onDidBeginEditing?(self)
        if !self.edited {
            self.text = "\(self.hint!) " // hint 后面增加一个空格改变 selection, 从而触发 textViewDidChangeSelection
        }
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        self.onDidEndEditing?(self)
    }
    
    public func textViewDidChangeSelection(textView: UITextView) {
        if !self.edited && (self.selectedRange.location != 0 || self.selectedRange.length != 0) {
            self.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    public func textViewDidChange(textView: UITextView) {
        self.onChange?(textView.text)
        if textView.text == "" {
            self.edited = false
            self.text = self.hint
            self.textColor = self.hintColor
        }
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if !self.edited && text != "" {
            self.edited = true
            super.text = ""
            self.textColor = self.color
        }
        return true
    }
}
