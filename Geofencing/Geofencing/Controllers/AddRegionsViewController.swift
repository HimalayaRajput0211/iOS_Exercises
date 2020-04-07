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
    private var neededZoomIntoLocation: Bool = true
    private var selectedCoordinate: CLLocationCoordinate2D?
    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            mapView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet private weak var noteTextField: UITextField!
    @IBOutlet private weak var radiusTextField: UITextField!
    @IBOutlet private weak var entryView: UIView!
    @IBOutlet private weak var exitView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    
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
        if neededZoomIntoLocation {
            mapView.zoomToUserLocation()
            neededZoomIntoLocation = false
        } else {
            showAlert(title: "Alert", message: "Already zoomed in..")
        }
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
       customizeSaveButton()
    }
    
    @IBAction func addRegion(_ sender: UIButton) {
        if  let noteText = noteTextField.text, !noteText.isEmpty, let radiusText = radiusTextField.text, !radiusText.isEmpty {
            guard let newCoordinate = selectedCoordinate else { return }
            let coordinate = newCoordinate
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
    }
    
    private func customizeSaveButton() {
        if isMonitoringEntry || isMonitoringExit {
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.isEnabled = true
        } else {
            saveButton.setTitleColor(.gray, for: .normal)
            saveButton.isEnabled = false
        }
    }
    
    private func setkeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if var height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            if #available(iOS 11.0, *) {
                height -= view.safeAreaInsets.bottom
            }
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide() {
        let contentInsets: UIEdgeInsets = .zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    private func centreOnLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        neededZoomIntoLocation = true
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        let touchLocation = recognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        selectedCoordinate = locationCoordinate
        addAnnotation()
    }
    
    func addAnnotation() {
        guard let coordinate = selectedCoordinate else { return }
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

extension AddRegionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTextField {
            radiusTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
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

