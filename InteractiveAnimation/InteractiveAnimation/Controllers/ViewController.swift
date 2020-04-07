//
//  ViewController.swift
//  InteractiveAnimation
//
//  Created by Himalaya Rajput on 04/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private enum State {
        case collapsed
        case expanded
        var change: State {
            switch self {
            case .expanded: return .collapsed
            case .collapsed: return .expanded
            }
        }
    }
    private var commentViewController: CommentViewController!
    private var viewHeight: CGFloat = UIScreen.main.bounds.height * 0.75
    private var handletouchAreaHeight: CGFloat = 65.0
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress: CGFloat = 0.0
    private var animationDuration: TimeInterval = 0.9
    private let cardViewCornerRadius: CGFloat = 15
    private var currentState: State = .collapsed
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.effect = nil
        setupCardView()
    }
    
    private func setupCardView() {
        commentViewController = CommentViewController(nibName: CommentViewController.nibName, bundle: nil)
        self.addChild(commentViewController)
        self.view.addSubview(commentViewController.view)
        commentViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - handletouchAreaHeight, width: self.view.bounds.width, height: viewHeight + 20.0)
        commentViewController.view.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        commentViewController.handleTouchView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        commentViewController.handleTouchView.addGestureRecognizer(panGesture)
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            startAnimation(forState: currentState.change, withDuration: animationDuration)
        default: break
        }
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startTransition(forState: currentState.change, withDuration: animationDuration)
        case .changed:
            let translation = recognizer.translation(in: self.commentViewController.view)
            var fractionComplete = -translation.y / viewHeight
            if currentState == .expanded { fractionComplete *= -1 }
            if runningAnimators[0].isReversed { fractionComplete *= -1}
            updateTransition(fractionCompleted: fractionComplete)
        case .ended:
            let velocity = recognizer.velocity(in: self.commentViewController.view)
            if velocity.y == 0 {
                continueTransition()
                break
            }
            reverseAnimation(velocity.y > 0)
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
    
    private func reverseAnimation(_ shouldComplete: Bool) {
        switch currentState {
        case .expanded:
            if !shouldComplete && !runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
            if shouldComplete && runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
        case .collapsed:
            if shouldComplete && !runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
            if !shouldComplete && runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
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
        frameAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.change
            case .end:
                self.currentState = state
            default: break
            }
            self.runningAnimators.removeAll()
        }
        frameAnimator.startAnimation()
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
        
        let labelAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            switch state {
            case .expanded:
                self.commentViewController.collapsedTitleLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.6, y: 1.6).concatenating(CGAffineTransform.identity.translatedBy(x: 0, y: 15))
                self.commentViewController.expandedTitleLabel.transform = .identity
                self.commentViewController.expandedTitleLabel.alpha = 1
                self.commentViewController.collapsedTitleLabel.alpha = 0
            case .collapsed:
                self.commentViewController.collapsedTitleLabel.transform = .identity
                self.commentViewController.expandedTitleLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65).concatenating(CGAffineTransform.identity.translatedBy(x: 0, y: -15))
                self.commentViewController.collapsedTitleLabel.alpha = 1
                self.commentViewController.expandedTitleLabel.alpha = 0
            }
        }
        labelAnimator.startAnimation()
        runningAnimators.append(labelAnimator)
    }
}

