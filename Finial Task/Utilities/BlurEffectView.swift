//
//  BlurEffectView.swift
//  Finial Task
//
//  Created by Sara Syam on 27/11/2024.
//
import UIKit
import Foundation
class BlurEffectView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit()
 {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
      blurView.addGestureRecognizer(tapGesture)

        addSubview(blurView)
    }
    @objc private func handleTap() {
        // Navigate to onboarding view controller
        let onboardingVC = onboardingViewController() // Replace with your actual onboarding view controller class
        // Set the new window's rootViewController
        window?.rootViewController = onboardingVC
        // Make the new window the key window and visible
        window?.makeKeyAndVisible()
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Allow touches to pass through the blur view
        return nil
    }
}
