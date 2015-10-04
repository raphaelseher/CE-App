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
import MapKit

class EventDetailViewController: UIViewController, MKMapViewDelegate, UIWebViewDelegate {

  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var eventCategorieLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var eventDescriptionWebView: UIWebView!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet weak var startTimeLabel: UILabel!
  @IBOutlet weak var endTimeLabel: UILabel!
  @IBOutlet weak var eventLocationNameLabel: UILabel!
  @IBOutlet weak var eventLocationStreetAddressLabel: UILabel!
  @IBOutlet weak var eventLocationPlaceLabel: UILabel!
  @IBOutlet weak var toLabel: UILabel!
  @IBOutlet weak var fromLabel: UILabel!
  @IBOutlet weak var eventDescriptionWebViewHeightConstraint: NSLayoutConstraint!
  
  var event : Event = Event()
  var venue : MKAnnotation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)

    initEventDetail()
  }
  
  override func viewWillAppear(animated: Bool) {
    //analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "EventsDetailActivity")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func initEventDetail() {
    self.eventImageView.setImageWithURL(NSURL(string: event.image.contentUrl))
    self.eventTitleLabel.text = event.name
    
    self.initDateTime()
    self.initLocation()
    self.initCategories()
    self.initMapView()
    self.initDescription()
  }
  
  func initDateTime() {
    let dayMonthYearDateFormatter : NSDateFormatter = NSDateFormatter()
    let timeFormatter : NSDateFormatter = NSDateFormatter()
    dayMonthYearDateFormatter.dateFormat = "dd.MM.YYYY"
    timeFormatter.dateFormat = "HH:mm"
    
    if event.startDate != nil {
      self.startDateLabel.text = dayMonthYearDateFormatter.stringFromDate(event.startDate)
      self.startTimeLabel.text = timeFormatter.stringFromDate(event.startDate)
    }
    
    if event.endDate != nil {
      self.endDateLabel.text = dayMonthYearDateFormatter.stringFromDate(event.endDate)
      self.endTimeLabel.text = timeFormatter.stringFromDate(event.endDate)
    } else {
      self.fromLabel.text = "am"
      self.toLabel.text = ""
      self.endTimeLabel.text = ""
      self.endDateLabel.text = ""
    }
  }
  
  func initLocation() {
    self.eventLocationNameLabel.text = event.location.name

    if event.location.address != nil {
      self.eventLocationStreetAddressLabel.text = event.location.address.streetAddress
      
      if event.location.address.addressLocality == nil {
        self.eventLocationPlaceLabel.text = event.location.address.postalCode
      } else {
        self.eventLocationPlaceLabel.text = "\(event.location.address.addressLocality), \(event.location.address.postalCode)"
      }
    } else {
      self.eventLocationStreetAddressLabel.text = ""
      self.eventLocationPlaceLabel.text = ""
    }
  }
  
  func initCategories() {
    //categories
    var categoriesAsArray : [String] = []
    for category in event.categories {
      categoriesAsArray.append(category.name)
    }
    self.eventCategorieLabel.text = categoriesAsArray.joinWithSeparator(",")
  }
  
  func initDescription() {
    //description
    var htmlString = "<style>html {font-family: 'Helvetica', 'Arial', sans-serif; font-size:12pt;} body {margin: 0; padding: 0;} </style>"
    htmlString += event.eventDescription
    self.eventDescriptionWebView.loadHTMLString(htmlString, baseURL: nil)
    
    self.eventDescriptionWebView.delegate = self;
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    //resize the webView
    self.eventDescriptionWebViewHeightConstraint.constant = webView.scrollView.contentSize.height
    self.view.layoutIfNeeded()
  }
  
  func initMapView() {
    //map
    if event.location.geo != nil {
      let mapViewPin = MKPointAnnotation()
      mapViewPin.coordinate = CLLocationCoordinate2D(latitude: event.location.geo.longitude, longitude: event.location.geo.latitude)
      mapViewPin.title = event.location.name
      
      if event.location.address != nil {
        mapViewPin.subtitle = event.location.address.streetAddress
      }
      
      self.mapView.addAnnotation(mapViewPin)
      self.mapView.selectAnnotation(mapViewPin, animated: true)
      
      let span = MKCoordinateSpanMake(0.5, 0.5)
      let region = MKCoordinateRegion(center: mapViewPin.coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
    } else {
      //do smt
    }
  }
  
  // MARK:- Sharing
  @IBAction func actionButtonAction(sender: AnyObject) {
    var sharingItems = [AnyObject]()
    let sharingText = self.event.name
    let sharingImage = self.eventImageView.image
    let sharingURL = NSURL(string: self.event.url)
    var sharingStartdate = self.event.startDate
    
    if let text = sharingText {
      sharingItems.append(text)
    }
    if let image = sharingImage {
      sharingItems.append(image)
    }
    if let url = sharingURL {
      sharingItems.append(url)
    }

    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
    self.presentViewController(activityViewController, animated: true, completion: nil)
  }
  
  // MARK:- Map Delegate
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if (annotation is MKUserLocation) {
      return nil
    }
    
    self.venue = annotation
    let reuseId = "pinAnnotation"
    
    var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
    if anView == nil {
      anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      anView!.canShowCallout = true
      anView!.image = UIImage(named: "marker")
      anView!.calloutOffset = CGPoint(x: -1.0, y: -3.0)
      
      let navigationButton = UIButton(type: UIButtonType.Custom)
      navigationButton.frame.size.width = 52
      navigationButton.frame.size.height = 52
      navigationButton.backgroundColor = UIColor.blueColor()
      navigationButton.setImage(UIImage(named: "car"), forState: .Normal)
      navigationButton.addTarget(self, action: "startNavigation:", forControlEvents: UIControlEvents.TouchUpInside)
      
      anView!.leftCalloutAccessoryView = navigationButton
    }
    else {  
      //we are re-using a view, update its annotation reference...
      anView!.annotation = annotation
    }
    
    return anView
  }
  
  func startNavigation(sender:UIButton!) {
    let placemark = MKPlacemark(coordinate: venue.coordinate, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = self.venue.title!
    mapItem.openInMapsWithLaunchOptions(nil)
  }
}

