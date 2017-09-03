//
//  ViewController.swift
//  Animator
//
//  Created by What on 09/08/2017.
//  Copyright © 2017 What. All rights reserved.
//

import UIKit

class LifeCyclePresentationController: UIPresentationController {
    
    override func presentationTransitionWillBegin() {
        presentingViewController.viewWillDisappear(true)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentingViewController.viewDidDisappear(true)
        } else {
            presentingViewController.viewDidAppear(true)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.viewWillAppear(true)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentingViewController.viewDidAppear(true)
        } else {
            presentingViewController.viewDidDisappear(true)
        }
    }
}

class PresentationController: LifeCyclePresentationController {
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        
        let coverView = UIView(frame: containerView!.bounds)
        containerView?.insertSubview(coverView, belowSubview: presentedViewController.view)
        
        coverView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(
                    PresentationController.tapped(_:)
                )
            )
        )
    }
    
    @objc private func tapped(_ sender: UIPanGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

enum PresentationStatus { case present, dismiss }

class Animator: NSObject,
    UIViewControllerTransitioningDelegate,
    UIViewControllerAnimatedTransitioning {
    
    init(frame: CGRect) {
        self.frame = frame
    }
    
    let frame: CGRect
    
    private var status: PresentationStatus = .present
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        status = .present
        return self
    }
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        status = .dismiss
        return self
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController)
        -> UIPresentationController?
    {
        return PresentationController(
            presentedViewController: presented,
            presenting: presenting)
    }
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        switch status {
        case .present:
      
            let fromView = transitionContext.viewController(forKey: .from)?.view
            let toView = transitionContext.view(forKey: .to)
            toView.flatMap(containerView.addSubview)
            toView?.frame = frame
            
            toView?.layer.anchorPoint = CGPoint(x: 1, y: 0)
            toView?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            toView?.alpha = 0
            
            UIView.animate(
                withDuration: 3000,
                delay: 0,
                options: .init(rawValue: 7 << 16),
                animations: {
                    toView?.transform = .identity
                    fromView?.alpha = 0.5
                    toView?.alpha  = 1
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .dismiss:
            
            let toView = transitionContext.viewController(forKey: .to)?.view
            let fromView = transitionContext.view(forKey: .from)
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: [.init(rawValue: 7 << 16)],
                animations: {
                    fromView?.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
                    toView?.alpha = 1.0
                    fromView?.alpha = 0
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var v: UIView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "PresentedViewController")
        
        present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(#function)
    }
}

class PresentedViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = animator
    }
    
    lazy var animator = Animator(frame: CGRect(x: 200, y: 50, width: 100, height: 200))

}
