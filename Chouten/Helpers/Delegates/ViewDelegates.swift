//
//  ViewDelegates.swift
//  Chouten
//
//  Created by Resty on 05.02.25.
//

// FIXME: Fix Delegate for AppView
/*
 Not Really Working
protocol AppViewDelegate: AnyObject {
    func setTopBlur(offset: CGFloat)
}
 */

// MARK: HomeView Delegate
protocol HomeViewDelegate: AnyObject {
    func getScrollOffset()
}

// MARK: DiscoverView Delegate not needed for now

// MARK: RepoView Delegate
protocol RepoViewDelegate: AnyObject {
    func getScrollOffset()
}
