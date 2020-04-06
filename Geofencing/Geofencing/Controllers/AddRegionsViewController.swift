//
//  AddRegionViewController.swift
//  Geofencing
//
//  Created by Himalaya Rajput on 01/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol AddRegionsViewControllerDelegate: AnyObject {
    func addNewRegion(_ region: Region)
}

class AddRegionsViewController: UIViewController {
    
    static let identifier = "addRegions"
    private let locationManager = CLLocationManager()
    weak var delegate: AddRegionsViewControllerDelegate?
    private var isMonitoringExit: Bool = false
    private var isMonitoringEntry: Bool = true
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var noteTextField: UITextField!
    @IBOutlet private weak var radiusTextField: UITextField!
    @IBOutlet private weak var entryView: UIView!
    @IBOutlet private weak var exitView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryView.backgroundColor = .darkGray
        hideKeybordOnTap()
        customizeLocationManager()
        setkeyBoardObservers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func zoomOnCurrentLocation(_ sender: UIBarButtonItem) {
        mapView.zoomToUserLocation()
    }
    
    @IBAction func selectMonitoringTypes(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            entryView.backgroundColor = (entryView.backgroundColor == .darkGray) ? .lightGray : .darkGray
            isMonitoringEntry = !isMonitoringEntry
        case 1:
            exitView.backgroundColor = (exitView.backgroundColor == .darkGray) ? .lightGray : .darkGray
            isMonitoringExit = !isMonitoringExit
        default: break
        }
    }
    
    @IBAction func addRegion(_ sender: UIButton) {
        if  let noteText = noteTextField.text, !noteText.isEmpty , let radiusText = radiusTextField.text ,!radiusText.isEmpty{
            let coordinate = mapView.centerCoordinate
            var radius = Double(radiusText) ?? 0
            radius = min(radius, locationManager.maximumRegionMonitoringDistance)
            let identifier = UUID().uuidString
            let note = noteText
            let region = Region(coordinate: coordinate, radius: radius, identifier: identifier, note: note, isMonitoringExit: isMonitoringExit, isMonitoringEntry: isMonitoringEntry)
            delegate?.addNewRegion(region)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func customizeLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setkeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if let infoDict = notification.userInfo {
            if let keyboardFrame = infoDict["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            }
        }
    }
    
    @objc func keyboardWillHide() {
        let contentInsets: UIEdgeInsets = .zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
}
extension AddRegionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
        guard let userLocation = locations.first else {return}
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
}
extension AddRegionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension MKMapView {
  func zoomToUserLocation() {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let region = MKCoordinateRegion(center: center, span: span)
    setRegion(region, animated: true)
  }
}
extension AddRegionsViewController {
    func hideKeybordOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



