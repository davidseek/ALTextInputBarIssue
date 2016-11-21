//
//  ALKeyboardObservingView.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public let ALKeyboardFrameDidChangeNotification = "ALKeyboardFrameDidChangeNotification"

open class ALKeyboardObservingView: UIView {

    fileprivate weak var observedView: UIView?
    fileprivate var defaultHeight: CGFloat = 44
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: defaultHeight)
    }


    
    open override func willMove(toSuperview newSuperview: UIView?) {
        
        removeKeyboardObserver()
        if let _newSuperview = newSuperview {
            addKeyboardObserver(_newSuperview)
        }
        
        super.willMove(toSuperview: newSuperview)
    }


    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == superview && keyPath == keyboardHandlingKeyPath() {
            keyboardDidChangeFrame(superview!.frame)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open func updateHeight(_ height: CGFloat) {
        if UIDevice.floatVersion() < 8.0 {
            frame.size.height = height
            
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        for constraint in constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    fileprivate func keyboardHandlingKeyPath() -> String {
        if UIDevice.floatVersion() >= 8.0 {
            return "center"
        } else {
            return "frame"
        }
    }
    
    fileprivate func addKeyboardObserver(_ newSuperview: UIView) {
        observedView = newSuperview
        newSuperview.addObserver(self, forKeyPath: keyboardHandlingKeyPath(), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    fileprivate func removeKeyboardObserver() {
        if observedView != nil {
            observedView!.removeObserver(self, forKeyPath: keyboardHandlingKeyPath())
            observedView = nil
        }
    }
    
    fileprivate func keyboardDidChangeFrame(_ frame: CGRect) {
        let userInfo: [AnyHashable : Any] = [UIKeyboardFrameEndUserInfoKey: NSValue(cgRect:frame)]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil, userInfo: userInfo)
    }
    
    deinit {
        removeKeyboardObserver()
    }
}
