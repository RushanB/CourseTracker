//
//  Models.swift
//  CourseTracker
//
//  Created by atfelix on 2017-06-15.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import RealmSwift

enum DayOfWeek: String {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

enum TextbookRequirement: String {
    case required
    case recommended
    case alternate
    case optional
    case referenced
}

final class RealmString: Object {
    dynamic var string: String?
}

final class RealmInt: Object {
    dynamic var int = 0
}

final class GeoLocation: Object {
    dynamic var id = ""
    dynamic var longitude: Double = 0.0
    dynamic var latitude: Double = 0.0

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Time: Object {
    dynamic var id: String?
    dynamic var dayOfWeek: String!
    dynamic var date: NSDate?
    dynamic var startTime: Int = 0
    dynamic var endTime: Int = 0
    dynamic var duration: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Address: Object {
    dynamic var id = ""
    dynamic var street = ""
    dynamic var city = ""
    dynamic var province = ""
    dynamic var country = ""
    dynamic var postalCode = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Building: Object {
    dynamic var id = ""
    dynamic var code = ""
    dynamic var name = ""
    dynamic var shortName = ""
    dynamic var campus = ""
    dynamic var address: Address?
    dynamic var geoLocation: GeoLocation?

    let polygon = List<GeoLocation>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Event: Object {
    dynamic var id: String?
    dynamic var title: String?
    dynamic var location: String?
    dynamic var time: Time?
    dynamic var building: Building?

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class ParkingLocation: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var building: Building?
    dynamic var campus = ""
    dynamic var parkingDescription = ""
    dynamic var geoLocation: GeoLocation?
    dynamic var address: String?
}

final class TextbookMeetingSection: Object {
    dynamic var code = ""
    let instructors = List<RealmString>()
}

final class TextbookCourse: Object {
    dynamic var id = ""
    dynamic var code = ""
    dynamic var requirement = ""
    let textbookMeetingSections = List<TextbookMeetingSection>()
}

final class Textbook: Object {
    dynamic var id = ""
    dynamic var isbn = ""
    dynamic var title = ""
    dynamic var edition = -1
    dynamic var author = ""
    dynamic var imageURL = ""
    dynamic var price = 0.0
    dynamic var url = ""
    let courses = List<TextbookCourse>()
}

final class CourseMeetingSection: Object {
    dynamic var code = ""
    dynamic var size = 0
    dynamic var enrolment = 0
    let times = List<Time>()
    let instructors = List<RealmString>()
}

final class Course: Object {
    dynamic var id = ""
    dynamic var code = ""
    dynamic var name = ""
    dynamic var courseDescription = ""
    dynamic var division = ""
    dynamic var department = ""
    dynamic var prerequistes = ""
    dynamic var exclusions = ""
    dynamic var level = 0
    dynamic var campus = ""
    dynamic var term = ""
    let breadths = List<RealmInt>()
    let courseMeetingSections = List<CourseMeetingSection>()
}