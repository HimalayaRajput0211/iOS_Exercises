//
//  ViewController.swift
//  InteractiveAnimation
//
//  Created by Himalaya Rajput on 04/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    private enum State {
        case collapsed
        case expanded
    }
    
    private var commentViewController: CommentViewController!
    private var viewHeight: CGFloat = UIScreen.main.bounds.height * 0.75
    private var handletouchAreaHeight: CGFloat = 65.0
    private var isCardVisible = false
    private var nextState: State {
        return isCardVisible ? .collapsed : .expanded
    }
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress: CGFloat = 0.0
    private var animationDuration: TimeInterval = 1.0
    private let cardViewCornerRadius: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.effect = nil
        setupCardView()
    }
    
    private func setupCardView() {
        commentViewController = CommentViewController(nibName: CommentViewController.nibName, bundle: nil)
        self.addChild(commentViewController)
        self.view.addSubview(commentViewController.view)
        commentViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - handletouchAreaHeight, width: self.view.bounds.width, height: viewHeight)
        commentViewController.view.clipsToBounds = true
        commentViewController.expandedTitleLabel.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        commentViewController.handleTouchView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        commentViewController.handleTouchView.addGestureRecognizer(panGesture)
    }
    
    
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        startAnimation(forState: nextState, withDuration: animationDuration)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startTransition(forState: nextState, withDuration: animationDuration)
        case .changed:
            let translation = recognizer.translation(in: self.commentViewController.view)
            var fractionComplete =  translation.y / viewHeight
            fractionComplete = isCardVisible ? fractionComplete : -fractionComplete
            updateTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueTransition()
        default: break
        }
    }
    
    private func startTransition(forState state: State,withDuration duration: TimeInterval) {
        if runningAnimators.isEmpty {
            startAnimation(forState: state, withDuration: duration)
        }
        for animator in runningAnimators {
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        }
    }
    
    private func updateTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimators {
            animator.fractionComplete = fractionCompleted + animationProgress
        }
    }
    
    private func continueTransition() {
        for animator in runningAnimators {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func startAnimation(forState state: State, withDuration duration: TimeInterval) {
        guard runningAnimators.isEmpty else {return}
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.commentViewController.view.frame.origin.y = self.view.frame.height - self.viewHeight
            case .collapsed:
                self.commentViewController.view.frame.origin.y = self.view.frame.height - self.handletouchAreaHeight
            }
        }
        frameAnimator.startAnimation()
        frameAnimator.addCompletion { _ in
            self.isCardVisible = !self.isCardVisible
            self.runningAnimators.removeAll()
        }
        runningAnimators.append(frameAnimator)
        
        let blurAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            switch state {
            case .expanded:
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .collapsed:
                self.visualEffectView.effect = nil
            }
        }
        blurAnimator.startAnimation()
        runningAnimators.append(blurAnimator)
        
        let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.commentViewController.view.layer.cornerRadius = self.cardViewCornerRadius
            case .collapsed:
                self.commentViewController.view.layer.cornerRadius = 0.0
            }
        }
        cornerRadiusAnimator.startAnimation()
        runningAnimators.append(cornerRadiusAnimator)
        
        switch state {
        case .expanded: self.commentViewController.collapsedTitleLabel.alpha = 0
        case .collapsed: self.commentViewController.expandedTitleLabel.alpha = 0
        }
        
        let labelAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            switch state {
            case .expanded:
                self.commentViewController.expandedTitleLabel.alpha = 1
            case .collapsed:
                self.commentViewController.collapsedTitleLabel.alpha = 1
            }
        }
        labelAnimator.scrubsLinearly = false
        labelAnimator.startAnimation()
        runningAnimators.append(labelAnimator)
    }
    
}

