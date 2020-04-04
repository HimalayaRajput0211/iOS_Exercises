//
//  ViewController.swift
//  Geofencing
//
//  Created by Himalaya Rajput on 01/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class RegionsViewController: UIViewController, AddRegionsViewControllerDelegate {
    private let locationManager = CLLocationManager()
    private var regions = [Region]()
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeLocationManager()
        customizeSegmentControl()
        loadAllRegions()
        updateRegionsCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            centreOnLocation(location)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AddRegionsViewController.identifier {
            if let vc = segue.destination as? AddRegionsViewController {
                vc.delegate = self
            }
        }
    }
    
    @IBAction func showRegions(_ sender: UISegmentedControl) {
        let overlays = mapView.overlays
        let annotations = mapView.annotations
        mapView.removeOverlays(overlays)
        mapView.removeAnnotations(annotations)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            for region in regions {
                mapView.addAnnotation(region)
                addRadiusOverlay(forRegion: region)
            }
        case 1:
            for region in regions {
                if region.isMonitoringEntry {
                    mapView.addAnnotation(region)
                    addRadiusOverlay(forRegion: region)
                }
            }
        case 2:
            for region in regions {
                if region.isMonitoringExit {
                    mapView.addAnnotation(region)
                    addRadiusOverlay(forRegion: region)
                }
            }
        default: break
        }
    }
    
    @IBAction func zoomOnCurrentLocation(_ sender: UIBarButtonItem) {
        mapView.zoomToUserLocation()
    }
    
    private func customizeSegmentControl() {
        segmentControl.layer.borderWidth = 1.0
        segmentControl.layer.borderColor = UIColor.black.cgColor
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.backgroundColor : UIColor.black
        ]
        segmentControl.setTitleTextAttributes(attributes, for: .selected)
    }
    
    private func customizeLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
    }
    
    func addNewRegion(_ region: Region) {
        add(region)
        saveRegions()
    }
    
    private func add(_ region: Region) {
        regions.append(region)
        mapView.addAnnotation(region)
        addRadiusOverlay(forRegion: region)
        updateRegionsCount()
    }
    
    private func remove(_ region: Region) {
        guard let index = regions.firstIndex(of: region) else { return }
        regions.remove(at: index)
        mapView.removeAnnotation(region)
        removeRadiusOverlay(forRegion: region)
        updateRegionsCount()
    }
    
    private func addRadiusOverlay(forRegion region: Region) {
        let circle = MKCircle(center: region.coordinate, radius: region.radius)
        mapView.addOverlay(circle)
    }
    
    private func removeRadiusOverlay(forRegion region: Region) {
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == region.coordinate.latitude && coord.longitude == region.coordinate.longitude && circleOverlay.radius == region.radius {
                mapView?.removeOverlay(circleOverlay)
            }
        }
    }
    
    private func centreOnLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center:location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateRegionsCount() {
        title = "Regions: \(regions.count)"
    }
    
    private func saveRegions() {
        print(regions.count)
        let encoder = JSONEncoder()
        do {
            let regionsData = try encoder.encode(regions)
            UserDefaults.standard.set(regionsData, forKey: PersistenceKeys.regionsData)
        } catch {
            print("error in encoding")
        }
    }
    
    private func loadAllRegions() {
        regions.removeAll()
        let allRegions = Region.allRegions()
        print(allRegions.count)
        allRegions.forEach { add($0) }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RegionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return}
        centreOnLocation(location)
    }
}

extension RegionsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        circleRenderer.fillColor = .red
        circleRenderer.strokeColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myRegions"
        guard annotation is Region else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let removeButton = UIButton(type: .custom)
            removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
            removeButton.setImage(UIImage(named: "deleteRegion")!, for: .normal)
            annotationView?.leftCalloutAccessoryView = removeButton
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let region = view.annotation as? Region {
            remove(region)
            saveRegions()
        }
    }
}

