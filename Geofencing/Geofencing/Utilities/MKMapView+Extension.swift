//
//  MKMapView+Extension.swift
//  Geofencing
//
//  Created by Himalaya Rajput on 07/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func zoomToUserLocation() -> Bool {
        guard let coordinate = userLocation.location?.coordinate else { return false }
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        setRegion(region, animated: true)
        return true
    }
}
