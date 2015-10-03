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

class EventAnnotation: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let coordinate: CLLocationCoordinate2D
  let event : Event
  
  init(title: String, locationName: String, event: Event, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.event = event
    self.coordinate = coordinate
    
    super.init()
  }
  
  var subtitle: String? {
    return locationName
  }
}
