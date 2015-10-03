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

class InfoViewController: UIViewController {
  
  let twitterUrl = "https://twitter.com/RaphaelSeher"
  let githubUrl = "https://github.com/raphaelseher"
  let githubProjectUrl = "https://github.com/raphaelseher/CE-App"
  let veranstaltungenKaerntenUrl = "http://veranstaltungen.kaernten.at"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    //analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "InfoActivity")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func veranstaltungenKaerntenButtonAction(sender: AnyObject) {
    openUrl(veranstaltungenKaerntenUrl)
  }
  
  @IBAction func githubProjectButtonAction(sender: AnyObject) {
    openUrl(githubProjectUrl)
  }
  
  @IBAction func githubButtonAction(sender: AnyObject) {
    openUrl(githubUrl)
  }
  
  @IBAction func twitterButtonAction(sender: AnyObject) {
    openUrl(twitterUrl)
  }
  
  func openUrl(urlString : String) {
    UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
