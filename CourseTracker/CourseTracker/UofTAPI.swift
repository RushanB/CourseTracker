//
//  NetworkManager.swift
//  CourseTracker
//
//  Created by atfelix on 2017-06-15.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

enum UofTError: Error {
    case invalidJSONData
}

enum Method: String {
    case courses = "/courses"
    case buildings = "/buildings"
    case textbooks = "/textbooks"
    case athletics = "/athletics"
    case parking = "/transportation/parking"
}

struct UofTAPI {
    private static let httpScheme = "https"
    private static let baseURLString = "cobalt.qas.im"
    private static let pathStart = "/api/1.0"
    private static let maxLimit = 100
    private static let key = UNIVERSITY_OF_TORONTO_API_KEY
    private static let realm = try! Realm()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func makeRequestURL(method: Method, skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        var components = URLComponents()
        components.scheme = UofTAPI.httpScheme
        components.host = UofTAPI.baseURLString
        components.path = UofTAPI.pathStart + method.rawValue
        components.queryItems = [URLQueryItem(name: "skip", value: "\(skip)"),
                                 URLQueryItem(name: "limit", value: "\(limit)"),
                                 URLQueryItem(name: "key", value: "\(UofTAPI.key)")]
        return components.url
    }

    static func makeCoursesRequestURL(skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        return makeRequestURL(method: .courses, skip: skip, limit: limit)
    }

    static func makeBuildingsRequestURL(skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        return makeRequestURL(method: .buildings, skip: skip, limit: limit)
    }

    static func makeTextbooksRequestURL(skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        return makeRequestURL(method: .textbooks, skip: skip, limit: limit)
    }

    static func makeAthleticsRequestURL(skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        return makeRequestURL(method: .athletics, skip: skip, limit: limit)
    }

    static func makeParkingRequestURL(skip: Int, limit: Int = UofTAPI.maxLimit) -> URL? {
        return makeRequestURL(method: .parking, skip: skip, limit: limit)
    }

    static func makeAthleticsRequest(skip: Int, limit: Int = UofTAPI.maxLimit) {

        let url = makeAthleticsRequestURL(skip: skip, limit: limit)
        Alamofire.request((url?.absoluteString)!).responseJSON { response in
            print(response.request!)
            print(response.response!)
            print(response.data!)
            print(response.result)
            print("================")

            if let JSON = response.result.value as? [[String:Any]], JSON.count > 0 {
                for event in JSON {
                    addOrUpdateEvent(fromJSON: event)
                }
                makeAthleticsRequest(skip: skip + limit, limit: limit)
            }
            else {
                return
            }
        }
    }

    static func addOrUpdateEvent(fromJSON json: [String:Any]) {
        guard
            let dateString = json["date"] as? String,
            let eventsOnDate = json["events"] as? [[String:Any]] else {
                print(#file, #function, #line, "JSON does not conform to Events Prototype JSON")
                return
        }

        for eventJSON in eventsOnDate {
            guard
                let title = eventJSON["title"] as? String,
                let location = eventJSON["location"] as? String,
                let buildingID = eventJSON["building_id"] as? String else {
                    print(#file, #function, #line, "JSON does not conform to Event Prototype JSON")
                    continue
            }
            let event = Event()
            event.title = title
            event.location = location

            let time = Time()
            addOrUpdateTime(time: time, fromJSON: eventJSON, dateString: dateString)

            event.time = time

            let building = realm.objects(Building.self).filter("id == '\(buildingID)'").first
            event.building = building

            event.id = [dateString, buildingID, title, "\(time.startTime)", "\(time.endTime)"].joined(separator: "##")

            try! realm.write {
                realm.add(event, update: true)
            }
        }
    }

    static func addOrUpdateTime(time: Time, fromJSON json: [String: Any], dateString: String?) {
        guard
            let startTime = json["start_time"] as? Int,
            let endTime = json["end_time"] as? Int,
            let duration = json["duration"] as? Int else {
                print("JSON does not conform to Time Prototype JSON")
                return
        }

        time.dayOfWeek = json["day"] as? String
        time.date = dateFormatter.date(from: dateString ?? "")! as NSDate
        time.startTime = startTime
        time.endTime = endTime
        time.duration = duration
        time.id = [time.dayOfWeek ?? "NO DAY OF WEEK", "\(time.date?.description ?? "NO DATE")", "\(time.startTime)", "\(time.endTime)", "\(time.duration)"].joined(separator: " ## ")

        try! realm.write {
            realm.add(time, update: true)
        }
    }

    static func makeBuildingRequest(skip: Int, limit: Int = UofTAPI.maxLimit) {
        
        let url = makeBuildingsRequestURL(skip: skip, limit: limit)
        Alamofire.request((url?.absoluteString)!).responseJSON { response in
            print(response.request!)
            print(response.response!)
            print(response.data!)
            print(response.result)
            print("================")

            if let JSON = response.result.value as? [[String:Any]], JSON.count > 0 {
                for building in JSON {
                    addOrUpdateBuilding(fromJSON: building)
                }
                makeBuildingRequest(skip: skip + limit, limit: limit)
            }
            else {
                return
            }
        }
    }

    static func addOrUpdateBuilding(fromJSON json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let code = json["code"] as? String,
            let name = json["name"] as? String,
            let shortName = json["short_name"] as? String,
            let campus = json["campus"] as? String,
            let latitude = json["lat"] as? Double,
            let longitude = json["lng"] as? Double,
            let polygonArray = json["polygon"] as? [[Double]],
            let addressJSON = json["address"] as? [String: String] else {
                print("JSON does not conform to Building Prototype JSON")
                return
        }

        let geoLocation = GeoLocation()
        geoLocation.latitude = latitude
        geoLocation.longitude = longitude
        geoLocation.id = "\(latitude) \(longitude)"

        let building = Building()
        building.id = id
        building.code = code
        building.name = name
        building.shortName = shortName
        building.campus = campus
        building.geoLocation = geoLocation

        let address = Address()
        addOrUpdateAddress(address: address, fromJSON: addressJSON)
        building.address = address

        for location in polygonArray {
            guard location.count == 2 else {
                print("location is not 2 points")
                continue
            }
            let geoLocation = GeoLocation()
            geoLocation.latitude = location[0]
            geoLocation.longitude = location[1]
            geoLocation.id = "\(latitude) \(longitude)"
            building.polygon.append(geoLocation)
        }

        try! realm.write {
            realm.add(building, update: true)
        }
    }

    static func addOrUpdateAddress(address: Address, fromJSON json: [String:String]) {
        guard
            let street = json["street"],
            let city = json["city"],
            let province = json["province"],
            let country = json["country"],
            let postalCode = json["postal"] else {
                print("JSON does not conform to Address Prototype JSON")
                return
        }

        address.street = street
        address.city = city
        address.province = province
        address.country = country
        address.postalCode = postalCode
        address.id = [street, city, province, country, postalCode].joined(separator: ", ")

        try! realm.write {
            realm.add(address, update: true)
        }
    }
}