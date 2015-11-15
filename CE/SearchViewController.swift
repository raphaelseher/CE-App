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
import CoreLocation
import MBProgressHUD

class SearchViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UITableViewDelegate {
  
  let manager = CLLocationManager()
  let dayMonthYearDateFormatter : NSDateFormatter = NSDateFormatter()
  let timeFormatter : NSDateFormatter = NSDateFormatter()
  
  @IBOutlet weak var searchViewLayoutTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var pickerViewTopAlignmentConstraint: NSLayoutConstraint!
  @IBOutlet weak var datePickerTopAlignmentConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var datePickerView: UIView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var categoryPickerView: UIView!
  @IBOutlet weak var categoryPicker: UIPickerView!
  @IBOutlet weak var nearYouSwitch: UISwitch!
  @IBOutlet weak var eventTableView: UITableView!
  @IBOutlet weak var searchButtonImageView: UIImageView!
  @IBOutlet weak var nothingFoundLabel: UILabel!
  
  @IBOutlet weak var startDateTextField: UITextField! { didSet { startDateTextField.delegate = self } }
  @IBOutlet weak var endDateTextField: UITextField! { didSet { endDateTextField.delegate = self } }
  @IBOutlet weak var categorieTextField: UITextField! { didSet { categorieTextField.delegate = self } }
  @IBOutlet weak var nearYouDistance: UITextField! { didSet { nearYouDistance.delegate = self } }
  
  var arrowDownImage : UIImage? = UIImage(named:"arrow-down")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

  var activeTextField: UITextField!
  var tapOutsideDatepickerRecognizer = UITapGestureRecognizer()
  var tapOutsideCategoriepickerRecognizer = UITapGestureRecognizer()
  var tapBackgroundRecognizer = UITapGestureRecognizer()
  
  var isDatePickerOpen : Bool = false
  var isCategoriePickerOpen : Bool = false
  var isSearchViewOpen : Bool = true
  
  var categories : [AnyObject]! = []
  var choosenCategorie : Categories = Categories()
  
  var eventsToDisplay : [AnyObject] = []
  
  var userLocation : CLLocation = CLLocation()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dayMonthYearDateFormatter.dateFormat = "dd.MM.YYYY"
    timeFormatter.dateFormat = "HH:mm"
    
    //add image to searchButtonImageView
    self.searchButtonImageView.image = arrowDownImage
    self.searchButtonImageView.tintColor = UIColor(red:0.11, green:0.38, blue:0.48, alpha:1.0)
    
    //init location manager
    self.manager.delegate = self
    self.manager.desiredAccuracy = kCLLocationAccuracyBest
    self.manager.distanceFilter = 500
    
    //init tableview
    let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
    self.eventTableView.registerNib(nib, forCellReuseIdentifier: "EventTableViewCell")
    self.eventTableView.rowHeight = 320
    
    //init gesture recognizers
    self.tapOutsideDatepickerRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapOutsideDatepicker"))
    self.tapOutsideCategoriepickerRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapOutsideCategoriepicker"))
    self.tapBackgroundRecognizer = UITapGestureRecognizer(target: self, action:Selector("closeNumpad"))
    
    self.startDateTextField.text = dayMonthYearDateFormatter.stringFromDate(NSDate())
    self.endDateTextField.text = dayMonthYearDateFormatter.stringFromDate(NSDate())
    
    //init categories
    EventApi.sharedInstance().categories { (categ) -> Void in
      self.categories = categ
      
      //"Alle Kategorien" added
      let allCategory = Categories()
      allCategory.name = "Alle Kategorien"
      allCategory.id = nil
      self.categories.insert(allCategory, atIndex: 0)
      
      //update choosen categorie
      self.choosenCategorie = allCategory
      self.categoryPicker.reloadAllComponents()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    //analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "SearchActivity")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Location
  @IBAction func switchChanged(sender: UISwitch) {
    if(sender.on) {
      if CLLocationManager.locationServicesEnabled() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
          manager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
          self.nearYouSwitch.enabled = true
          manager.startUpdatingLocation()
        } else {
          self.nearYouSwitch.enabled = false
        }
      }
    } else {
      manager.stopUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      manager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("LocationUpdate")
    print(locations)
    self.userLocation = locations.last as CLLocation!
  }
  
  // MARK: - Search Button
  @IBAction func searchButtonTouch(sender: AnyObject) {
    
    //analytics
    GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("UX", action: "Button click", label: "Search", value: nil).build() as [NSObject : AnyObject])
    
    if self.isSearchViewOpen {
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      closeSearchView()
    } else {
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      openSearchView()
      return
    }
    
    var lat : Double = 0
    var lon : Double = 0
    var distance : Int32 = 0
    
    //close pickers when open
    if isCategoriePickerOpen {
      self.updateCategorieTextField()
      self.closeCategoryPicker()
    } else if isDatePickerOpen {
      self.updateDateTextField()
      self.closeDatePicker()
    }
    
    if self.nearYouDistance.isFirstResponder() {
      self.closeNumpad()
    }
    
    if self.nearYouSwitch.on {
      lat = self.userLocation.coordinate.latitude
      lon = self.userLocation.coordinate.longitude
      distance = (self.nearYouDistance.text as NSString!).intValue
    }
    
    //do search
    EventApi.sharedInstance().eventsFromPage(0, andPageSize: 10, withCategorie: self.choosenCategorie.id, fromDate: nil, toDate: nil, withLat: lat, andLon: lon, andDistance: distance) { (events, links) -> Void in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.eventsToDisplay = events
      self.eventTableView.reloadData()
      
      if events.count == 0 {
        self.nothingFoundLabel.hidden = false
      } else {
        self.nothingFoundLabel.hidden = true
      }
    }
  }
  
  // MARK: - Update TextFields
  func updateDateTextField() {
    self.activeTextField.text = dayMonthYearDateFormatter.stringFromDate(self.datePicker.date)
    self.activeTextField = nil
  }
  
  func updateCategorieTextField() {
    self.categorieTextField.text = self.choosenCategorie.name
  }
  
  // MARK: - Gesture Recognizer Selector
  
  func tapOutsideDatepicker() {
    self.updateDateTextField()
    self.closeDatePicker()
  }
  
  func tapOutsideCategoriepicker() {
    self.updateCategorieTextField()
    self.closeCategoryPicker()
  }
  
  func closeNumpad() {
    self.nearYouDistance.resignFirstResponder()
    self.view.removeGestureRecognizer(tapBackgroundRecognizer)
  }
  
  // MARK: - Picker Source & Delegate
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.categories.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.categories[row].name
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.choosenCategorie = self.categories[row] as! Categories
  }
  
  // MARK: - UITextField Delegates
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    //close pickers when open
    if isCategoriePickerOpen {
      self.updateCategorieTextField()
      self.closeCategoryPicker()
      return false;
    } else if isDatePickerOpen {
      self.updateDateTextField()
      self.closeDatePicker()
      return false;
    }
    
    if self.nearYouDistance.isFirstResponder() {
      self.closeNumpad()
      return false;
    }
    
    if textField.tag == 1 {
      self.openCategoryPicker()
    } else if textField.tag == 2{
      self.openDatePicker()
      self.activeTextField = textField
    } else {
      self.view.addGestureRecognizer(tapBackgroundRecognizer)
      return true;
    }
    return false;
  }
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return false;
  }
  
  // MARK: - Animations
  func openSearchView() {
    if !isSearchViewOpen {
      
      self.view.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.searchViewLayoutTopConstraint.constant += self.searchView.frame.size.height - 20
        self.searchButton.backgroundColor = UIColor(red:0.11, green:0.38, blue:0.48, alpha:1.0)
        self.view.layoutIfNeeded()
        }, completion: {
          void in
          self.isSearchViewOpen = true
      })
    }
  }
  
  func closeSearchView() {
    if isSearchViewOpen {
      
      self.view.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.searchViewLayoutTopConstraint.constant -= self.searchView.frame.size.height - 20
        self.searchButton.backgroundColor = UIColor(red:0.16, green:0.58, blue:0.73, alpha:1.0)
        self.view.layoutIfNeeded()
        }, completion: {
          void in
          self.isSearchViewOpen = false
      })
    }
  }
  
  func openDatePicker() {
    if !isDatePickerOpen {
      isDatePickerOpen = true
      self.view.addGestureRecognizer(tapOutsideDatepickerRecognizer)
      
      self.datePickerView.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.datePickerTopAlignmentConstraint.constant += self.datePickerView.frame.size.height
        self.datePickerView.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  func closeDatePicker() {
    if isDatePickerOpen {
      isDatePickerOpen = false
      self.view.removeGestureRecognizer(tapOutsideDatepickerRecognizer)
      
      self.datePickerView.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.datePickerTopAlignmentConstraint.constant -= self.datePickerView.frame.size.height
        self.datePickerView.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  func openCategoryPicker() {
    if !isCategoriePickerOpen && categories.count > 0 {
      isCategoriePickerOpen = true
      self.view.addGestureRecognizer(tapOutsideCategoriepickerRecognizer)
      
      self.categoryPickerView.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.pickerViewTopAlignmentConstraint.constant += self.categoryPickerView.frame.size.height
        self.categoryPickerView.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  func closeCategoryPicker() {
    if isCategoriePickerOpen {
      isCategoriePickerOpen = false
      self.view.removeGestureRecognizer(tapOutsideCategoriepickerRecognizer)

      self.categoryPickerView.layoutIfNeeded()
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.pickerViewTopAlignmentConstraint.constant -= self.categoryPickerView.frame.size.height
        self.categoryPickerView.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.eventsToDisplay.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell:EventTableViewCell = self.eventTableView.dequeueReusableCellWithIdentifier("EventTableViewCell") as! EventTableViewCell
    
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
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showEventDetail", sender: self)
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showEventDetail" {
      if let destination = segue.destinationViewController as? EventDetailViewController {
        if let blogIndex = self.eventTableView.indexPathForSelectedRow?.row {
          destination.event = self.eventsToDisplay[blogIndex] as! Event
        }
      }
    }
  }
}
