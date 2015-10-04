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
import GoogleMobileAds

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GADInterstitialDelegate  {
  
  static let bannerAppId : String = "ca-app-pub-8688727410266855/4174175323"
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bannerView: GADBannerView!
  
  let manager = CLLocationManager()
  var userLocation : CLLocation = CLLocation()
  
  var eventsToDisplay : [AnyObject] = []
  var savedEvent : Event = Event()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.mapView.delegate = self
    
    initLocationManager()
    checkLocationPermission()
  }
  
  override func viewWillAppear(animated: Bool) {
    //analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "MapActivity")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func initLocationManager() {
    self.manager.delegate = self
    self.manager.desiredAccuracy = kCLLocationAccuracyBest
    self.manager.distanceFilter = 500
  }
  
  func checkLocationPermission() {
    if CLLocationManager.locationServicesEnabled() {
      if CLLocationManager.authorizationStatus() == .NotDetermined {
        manager.requestWhenInUseAuthorization()
      } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
        manager.startUpdatingLocation()
      }
    }
  }
  
  func downloadEvents() {
    let lat : Double = userLocation.coordinate.latitude
    let lon : Double = userLocation.coordinate.longitude
    let distance : Int32 = 1000
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    EventApi.sharedInstance().eventsFromPage(0, andPageSize: 100, withLat: lat, andLon: lon, andDistance: distance) { (events, links) -> Void in
      self.eventsToDisplay += events
      
      self.addAnnotationsToMap()
      MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
  }
  
  func zoomToUser() {
    let mapCenter = self.userLocation.coordinate
    let mapCamera = MKMapCamera(lookingAtCenterCoordinate: mapCenter, fromEyeCoordinate: mapCenter, eyeAltitude: 50000)
    mapView.setCamera(mapCamera, animated: true)
  }
  
  // MARK: - Location Manager
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      manager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    manager.stopUpdatingLocation()
    print("LocationUpdate")
    print(locations)
    self.userLocation = locations.last as CLLocation!
    self.zoomToUser()
    self.downloadEvents()
  }
  
  // MARK: - Map Methods
  
  func addAnnotationsToMap() {
    for event: Event in eventsToDisplay as! [Event] {
      let annotation = EventAnnotation(title: event.name,
        locationName: event.location.name,
        event: event,
        coordinate: CLLocationCoordinate2DMake(event.location.geo.longitude, event.location.geo.latitude))
      self.mapView.addAnnotation(annotation)
    }
  }
  
  // MARK: - Map Delegate
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if (annotation is MKUserLocation) {
      return nil
    }
    
    let reuseId = "pinAnnotation"
    
    var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
    if anView == nil {
      anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      anView!.canShowCallout = true
      anView!.calloutOffset = CGPoint(x: -1.0, y: -3.0)
      anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
      anView!.image = UIImage(named: "marker")!
    }
    else {
      //we are re-using a view, update its annotation reference...
      anView!.annotation = annotation
    }
    
    return anView
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let eventAnnotation = view.annotation as! EventAnnotation
    self.savedEvent = eventAnnotation.event
    performSegueWithIdentifier("showEventDetail", sender: self)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showEventDetail" {
      if let destination = segue.destinationViewController as? EventDetailViewController {
        destination.event = self.savedEvent
      }
    }
  }
  
}
