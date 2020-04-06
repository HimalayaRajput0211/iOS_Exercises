//
//  Region.swift
//  Geofencing
//
//  Created by Himalaya Rajput on 02/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import MapKit

struct PersistenceKeys {
    static let regionsData = "regions_data"
}

class Region: NSObject, Codable, MKAnnotation {
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, radius, identifier, note, isMonitoringEntry, isMonitoringExit
    }
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var isMonitoringExit: Bool
    var isMonitoringEntry: Bool
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, isMonitoringExit: Bool, isMonitoringEntry: Bool) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.isMonitoringExit = isMonitoringExit
        self.isMonitoringEntry = isMonitoringEntry
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        note = try values.decode(String.self, forKey: .note)
        isMonitoringEntry = try values.decode(Bool.self, forKey: .isMonitoringEntry)
        isMonitoringExit = try values.decode(Bool.self, forKey: .isMonitoringExit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
        try container.encode(isMonitoringEntry, forKey: .isMonitoringEntry)
        try container.encode(isMonitoringExit, forKey: .isMonitoringExit)
    }
    
    static func allRegions() -> [Region] {
        guard let regionsData = UserDefaults.standard.data(forKey: PersistenceKeys.regionsData) else { return [] }
        let decoder = JSONDecoder()
        if let regions = try? decoder.decode([Region].self, from: regionsData) {
            return regions
        }
        return []
    }
    
}
