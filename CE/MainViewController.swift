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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  let dayMonthYearDateFormatter : NSDateFormatter = NSDateFormatter()
  let timeFormatter : NSDateFormatter = NSDateFormatter()
  let pageSize : Int32 = 50
  
  var eventsToDisplay : [AnyObject] = []
  var link : Links = Links()
  var isLoadingMore : Bool = false
  var page : Int32 = 1
  var moreEvents : Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBarController!.tabBarItem.selectedImage = UIImage(named: "home_filled")
    
    dayMonthYearDateFormatter.dateFormat = "dd.MM.YYYY"
    timeFormatter.dateFormat = "HH:mm"
    initTableView()
    initEvents()
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
  }
  
  override func viewWillAppear(animated: Bool) {
    //analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "MainActivity")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    
  }
  
  // MARK: - Init
  func initTableView() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "EventTableViewCell")
  }
  
  func initEvents() {
    let todayString = dayMonthYearDateFormatter.stringFromDate(NSDate())
    EventApi.sharedInstance().eventsFromPage(page, andPageSize: pageSize, fromDate: todayString, toDate: todayString) { (events, links) -> Void in
      self.link = links
      
      print("Links: \(links.next), \(links.first), \(links.last)");
      
      self.eventsToDisplay = self.checkForToday(events)
      self.tableView.reloadData()
      self.page++;
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.eventsToDisplay.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell:EventTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("EventTableViewCell") as! EventTableViewCell
    
    //reset cell
    cell.eventStartDate.hidden = false
    cell.eventStartDateLabel.hidden = false
    
    let event : Event = self.eventsToDisplay[indexPath.row] as! Event
    
    cell.eventCategorieLabel.text = event.categories.first?.name
    cell.eventTitleLabel.text = event.name;
    cell.eventImageView.setImageWithURL(NSURL(string: event.image.contentUrl))
    cell.eventLocationLabel.text = event.location.name
    
    cell.eventStartDate.text = timeFormatter.stringFromDate(event.startDate)
    if let endDate = event.endDate as NSDate? {
      cell.eventEndDate.text = self.timeFormatter.stringFromDate(event.endDate)
      cell.eventStartDateLabel.text = "von"
      cell.eventEndDateLabel.text = "bis"
    } else {
      cell.eventEndDateLabel.text = "um"
      cell.eventEndDate.text = timeFormatter.stringFromDate(event.startDate)
      cell.eventStartDate.hidden = true
      cell.eventStartDateLabel.hidden = true
    }
    
    cell.layoutIfNeeded()
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.row == (self.eventsToDisplay.count - 3)) {
      if self.link.next == nil {
        print("No more events")
        return
      }
      
      if (!isLoadingMore) {
        self.isLoadingMore = true
        loadMoreEvents()
      }
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showEventDetail", sender: self)
  }
  
  // MARK: - Event Methods
  
  func loadMoreEvents() {
    let todayString = dayMonthYearDateFormatter.stringFromDate(NSDate())
    EventApi.sharedInstance().eventsFromPage(page, andPageSize: pageSize, fromDate: todayString, toDate: todayString) { (events, links) -> Void in
      self.link = links

      self.isLoadingMore = false
      self.eventsToDisplay += self.checkForToday(events)
      self.tableView.reloadData()
      self.page++
    }
  }
  
  func checkForToday(events: [AnyObject]) -> [AnyObject] {
    let todayString = dayMonthYearDateFormatter.stringFromDate(NSDate())
    var todayArray : [AnyObject] = []
    let otherEventsArray : NSMutableArray = []
    
    for event : AnyObject in events {
      let eventDate = dayMonthYearDateFormatter.stringFromDate(event.startDate)
      otherEventsArray.addObject(event);
      
      if let subEvents = event.subEvents as? [SubEvent] {
        for subEvent in subEvents {
          let subEventDate = dayMonthYearDateFormatter.stringFromDate(subEvent.startDate)
          
          if (subEventDate == todayString) {
            //create new event
            let todaysEvent = Event()
            todaysEvent.name = event.name
            todaysEvent.eventDescription = event.eventDescription ?? ""
            todaysEvent.startDate = subEvent.startDate
            todaysEvent.endDate = subEvent.endDate
            todaysEvent.url = event.url
            todaysEvent.categories = event.categories
            todaysEvent.location = subEvent.location
            todaysEvent.image = event.image
            
            todayArray.append(todaysEvent)
            otherEventsArray.removeObject(event);
          }
        }
      }
    }
    
    return todayArray + otherEventsArray
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showEventDetail" {
      if let destination = segue.destinationViewController as? EventDetailViewController {
        if let blogIndex = tableView.indexPathForSelectedRow?.row {
          destination.event = self.eventsToDisplay[blogIndex] as! Event
        }
      }
    }
  }
}

