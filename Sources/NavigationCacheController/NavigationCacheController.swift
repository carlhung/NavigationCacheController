//
//  NavigationCacheController.swift
//  
//
//  Created by Carl Hung on 19/11/2020.
//

import UIKit

open class NavigationCacheController: UINavigationController {
    
    @Pool
    private var currentVCStack: [UIViewController] = []

    open override
    var viewControllers: [UIViewController] {
        get {
            self.currentVCStack
        }
        set {
            self.currentVCStack = newValue
        }
    }
    
    public init(isNavigationControllerOn: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.switchToNVCmode(mode: isNavigationControllerOn)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open func switchToNVCmode(mode: Bool) {
        if mode, let navigationController = navigationController {
            self.view.addSubview(navigationController.view)
        } else {
            self.navigationController?.view.removeFromSuperview()
        }
    }

    open override
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard self.navigationController?.view.superview == nil else { return }
        // if it can't draw the last one, it means empty. so, it can push.
        // if it can't get from the pool, it won't be in the array list. because, eveytime add a new element to the array stack, it also adds to the pool. so, add a new one to pool and the array stack.
//        guard let vcAtTheLast = self.currentVCStack.last, let vcFromPool = self._currentVCStack.getElmentFromPool(targetType: type(of: viewController)) else {
        guard let vcAtTheLast = self.currentVCStack.last, let vcFromPool = self._currentVCStack.getElmentFromPool(targetType: type(of: viewController)) else {
            self.createNewViewControllerAndPush(vc: viewController, animated: animated)
            return
        }

        // if the viewController is the last one, no needs to push.
        guard type(of: vcAtTheLast).typeName != type(of: viewController).typeName else {
            return
        }
        
        guard let index = self.currentVCStack.lastIndex(of: vcFromPool) else {
            // if vc was found in the pool but can't find the index from the array(`projectedValue`), push the vc from the pool to the front.
            self.createNewViewControllerAndPush(vc: vcFromPool, animated: animated)
            return
        }
        
        /// `pair` saves the index and the vc of this index.
        let pair: (index: Int, vc: UIViewController) = (index, vcFromPool)
        let newVCStack = Array(self.currentVCStack[0...pair.index])
        self.popToViewController(pair.vc, animated: animated)
        self.currentVCStack = newVCStack
    }
    
    private func createNewViewControllerAndPush(vc: UIViewController, animated: Bool) {
        super.pushViewController(vc, animated: animated)
        self._currentVCStack.add(vc)
    }
}
