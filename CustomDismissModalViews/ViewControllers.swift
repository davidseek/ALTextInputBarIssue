//  Created by David Seek on 11/21/16.
//  Copyright © 2016 David Seek. All rights reserved.

import UIKit

class VC1: UIViewController, UIViewControllerTransitioningDelegate {
    
    let interactor = Interactor()
    
    @IBAction func present(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC2") as! VC2
        vc.transitioningDelegate = self
        vc.interactor = interactor
        
        // self.present(vc, animated: true, completion: nil)
        // if presented modally like this, the input view is missing completely
        
        presentVCRightToLeft(self, vc)
        // presented like that the view is present, but if input view receives hit, it's hidden under keyboard
        // once keyboard receives action, the input view jumps up
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

class VC2: UIViewController {
    
    let textInputBar = ALTextInputBar()
    let keyboardObserver = ALKeyboardObservingView()
    
    let scrollView = UIScrollView()

    override var inputAccessoryView: UIView? {
        get {
            return keyboardObserver
        }
    }

    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    var interactor:Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiatePanGestureRecognizer(self, #selector(gesture))
        
        configureScrollView()
        configureInputBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismissVCLeftToRight(self)
    }
    
    func gesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        dismissVCOnPanGesture(self, sender, interactor!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        textInputBar.frame.size.width = view.bounds.size.width
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height * 2))
        contentView.backgroundColor = UIColor.black
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        scrollView.backgroundColor = UIColor(white: 0.6, alpha: 1)
    }
    
    func configureInputBar() {
        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        leftButton.setImage(UIImage(named: "leftIcon"), for: UIControlState())
        rightButton.setImage(UIImage(named: "rightIcon"), for: UIControlState())
        
        keyboardObserver.isUserInteractionEnabled = false
        
        textInputBar.showTextViewBorder = true
        textInputBar.leftView = leftButton
        textInputBar.rightView = rightButton
        textInputBar.frame = CGRect(x: 0, y: view.frame.size.height - textInputBar.defaultHeight, width: view.frame.size.width, height: textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.keyboardObserver = keyboardObserver
        
        view.addSubview(textInputBar)
    }
    
    func keyboardFrameChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
}
