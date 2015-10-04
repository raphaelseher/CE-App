//Event App with data from veranstaltungen.kaernten.at
//Copyright (C) 2015  Raphael Seher
//
//This program is free software; you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation; either version 2 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//  
//You should have received a copy of the GNU General Public License along
//with this program; if not, write to the Free Software Foundation, Inc.,
//51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    //set the selectedImage of tabBarItems
    var tabBarController : UITabBarController
    var tabBar : UITabBar
    var tabBarItem1 : UITabBarItem
    var tabBarItem2 : UITabBarItem
    var tabBarItem3 : UITabBarItem
    
    tabBarController = self.window!.rootViewController as! UITabBarController
    tabBar = tabBarController.tabBar

    tabBarItem1 = tabBar.items![0] 
    tabBarItem2 = tabBar.items![1] 
    tabBarItem3 = tabBar.items![2] 
    
    tabBarItem1.selectedImage = UIImage(named: "home_filled")
    tabBarItem2.selectedImage = UIImage(named: "search_filled")
    tabBarItem3.selectedImage = UIImage(named: "map_filled")
    
    UITabBar.appearance().tintColor = UIColor(red:0.11, green:0.38, blue:0.48, alpha:1.0)
    
    //init analytics
    self.initAnalytics()
    
    return true
  }
  
  func initAnalytics() {
    // Configure tracker from GoogleService-Info.plist.
    var configureError:NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Error configuring Google services: \(configureError)")
    
    // Optional: configure GAI options.
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true  // report uncaught exceptions
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

