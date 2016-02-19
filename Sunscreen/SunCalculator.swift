//
//  SunCalculator.swift
//  Sunscreen
//
//  Created by David Celis on 2/15/16.
//  Copyright © 2016 David Celis. All rights reserved.
//
//  Note: This class contains several lines of commented out code. For the purposes of this app,
//  I use the beginning of Civil Twilight instead of the beginning of actual the Sunrise, and I
//  use the end of Civil Twilight instead of the end of the actual Sunset. I have left the
//  original values commented out in case I wish to make the distinction between civil twilight,
//  sunrise, and sunset at some point in the future.

import Foundation

class SunCalculator {
    static let J1970 = Double(2440588),
    J2000 = Double(2451545),
    deg2rad = M_PI / 180,
    rad2deg = 180 / M_PI,
    M0 = 357.5291 * deg2rad,
    M1 = 0.98560028 * deg2rad,
    J0 = 0.0009,
    J1 = 0.0053,
    J2 = -0.0069,
    C1 = 1.9148 * deg2rad,
    C2 = 0.0200 * deg2rad,
    C3 = 0.0003 * deg2rad,
    P = 102.9372 * deg2rad,
    e = 23.45 * deg2rad,
    th0 = 280.1600 * deg2rad,
    th1 = 360.9856235 * deg2rad,
    h0 = -0.83 * deg2rad, // Angle of sunset
    d0 = 0.53 * deg2rad,  // Diameter of the sun
    h1 = -6 * deg2rad,    // Angle of Civil Twilight
    h2 = -12 * deg2rad,   // Angle of Nautical Twilight
    h3 = -18 * deg2rad,   // Angle of Astronomical Twilight
    secondsInDay = Double(60 * 60 * 24)

    static func calculateTimes(date: NSDate, latitude: Double, longitude: Double) -> SunData {
        let now = date.timeIntervalSince1970,
        lw = -longitude * deg2rad,
        phi = latitude * deg2rad,
        J = dateToJulianDate(now)

        let n = getJulianCycle(J, lw: lw),
        Js = getApproxSolarTransit(0, lw: lw, n: n),
        M = getSolarMeanAnomaly(Js),
        C = getEquationOfCenter(M),
        Lsun = getEclipticLongitude(M, C: C),
        d = getSunDeclination(Lsun),
        Jtransit = getSolarTransit(Js, M: M, Lsun: Lsun),
        // w0 = getHourAngle(h0, phi: phi, d: d),
        w1 = getHourAngle(h0 + d0, phi: phi, d: d),
        w2 = getHourAngle(h1, phi: phi, d: d),
        // Jset = getSunsetJulianDate(w0, M: M, Lsun: Lsun, lw: lw, n: n),
        Jsetstart = getSunsetJulianDate(w1, M: M, Lsun: Lsun, lw: lw, n: n),
        // Jrise = getSunriseJulianDate(Jtransit, Jset: Jset),
        Jriseend = getSunriseJulianDate(Jtransit, Jset: Jsetstart),
        Jnau = getSunsetJulianDate(w2, M: M, Lsun: Lsun, lw: lw, n: n),
        Jciv2 = getSunriseJulianDate(Jtransit, Jset: Jnau)

        let sunriseStart = julianDateToDate(Jciv2),
            // sunriseStart = julianDateToDate(Jrise),
            sunriseEnd = julianDateToDate(Jriseend),
            solarNoon = julianDateToDate(Jtransit),
            sunsetStart = julianDateToDate(Jsetstart),
            // sunsetEnd = julianDateToDate(Jset),
            sunsetEnd = julianDateToDate(Jnau)

        var period: String?

        if altitudeOfSunAtTime(date, latitude: latitude, longitude: longitude) < -6 {
            period = "night"
        }

        switch date.compare(solarNoon!) {
        case .OrderedAscending, .OrderedSame:
            // We're before solar noon, so it's either sunrise or morning. If "sunriseEnd" is nil,
            // we can return "sunrise". If it's not, we need to compare ourselves to sunriseEnd to
            // see if we're in "sunrise" or "morning".
            if sunriseEnd != nil {
                switch date.compare(sunriseEnd!) {
                case .OrderedSame, .OrderedAscending:
                    period = "sunrise"
                case .OrderedDescending:
                    period = "morning"
                }
            } else {
                period = "sunrise"
            }
        case .OrderedDescending:
            // We're after solar noon, so it's either afternoon or sunset. If "sunsetStart" is nil,
            // we can return "sunset". If it's not, we need to compare ourselves to sunsetStart to
            // see if we're in "afternoon" or "sunset".
            if sunsetStart != nil {
                switch date.compare(sunsetStart!) {
                case .OrderedAscending, .OrderedSame:
                    period = "afternoon"
                case .OrderedDescending:
                    period = "sunset"
                }
            } else {
                period = "sunset"
            }
        }

        return SunData(
            currentPeriod: period!,
            sunriseStart: sunriseStart,
            sunriseEnd: sunriseEnd,
            solarNoon: solarNoon!,
            sunsetStart: sunsetStart,
            sunsetEnd: sunsetEnd
        )
    }

    private static func altitudeOfSunAtTime(date: NSDate, latitude: Double, longitude: Double) -> Double {
        let J = dateToJulianDate(date.timeIntervalSince1970),
        M = getSolarMeanAnomaly(J),
        C = getEquationOfCenter(M),
        Lsun = getEclipticLongitude(M, C: C),
        d = getSunDeclination(Lsun),
        a = getRightAscension(Lsun),
        lw = -longitude * deg2rad,
        phi = latitude * deg2rad,
        th = getSiderealTime(J, lw: lw)

        return getAltitude(th, a: a, phi: phi, d: d) * rad2deg
    }

    private static func dateToJulianDate(date: Double) -> Double {
        return (date / secondsInDay) - 0.5 + J1970
    }

    private static func julianDateToDate(julianDate: Double) -> NSDate? {
        if julianDate.isNaN {
            return nil
        } else {
            return NSDate(timeIntervalSince1970: (julianDate + 0.5 - J1970) * secondsInDay)
        }
    }

    private static func getJulianCycle(J: Double, lw: Double) -> Double {
        return round(J - J2000 - J0 - lw / (2 * M_PI))
    }

    private static func getApproxSolarTransit(Ht: Double, lw: Double, n: Double) -> Double {
        return J2000 + J0 + (Ht + lw) / (2 * M_PI) + n
    }

    private static func getSolarMeanAnomaly(Js: Double) -> Double {
        return M0 + M1 * (Js - J2000)
    }

    private static func getEquationOfCenter(M: Double) -> Double {
        return C1 * sin(M) + C2 * sin(2 * M) + C3 * sin(3 * M)
    }

    private static func getEclipticLongitude(M: Double, C: Double) -> Double {
        return M + P + C + M_PI
    }

    private static func getSolarTransit(Js: Double, M: Double, Lsun: Double) -> Double {
        return Js + (J1 * sin(M)) + (J2 * sin(2 * Lsun))
    }

    private static func getSunDeclination(Lsun: Double) -> Double {
        return asin(sin(Lsun) * sin(e))
    }

    private static func getRightAscension(Lsun: Double) -> Double {
        return atan2(sin(Lsun) * cos(e), cos(Lsun))
    }

    private static func getSiderealTime(J: Double, lw: Double) -> Double {
        return th0 + th1 * (J - J2000) - lw
    }

    private static func getAzimuth(th: Double, a: Double, phi: Double, d: Double) -> Double {
        let H = th - a

        return atan2(sin(H), cos(H) * sin(phi) - tan(d) * cos(phi))
    }

    private static func getAltitude(th: Double, a: Double, phi: Double, d: Double) -> Double {
        let H = th - a

        return asin(sin(phi) * sin(d) + cos(phi) * cos(d) * cos(H))
    }

    private static func getHourAngle(h: Double, phi: Double, d: Double) -> Double {
        return acos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d)))
    }

    private static func getSunsetJulianDate(w0: Double, M: Double, Lsun: Double, lw: Double, n: Double) -> Double {
        return getSolarTransit(getApproxSolarTransit(w0, lw: lw, n: n), M: M, Lsun: Lsun);
    }

    private static func getSunriseJulianDate(Jtransit: Double, Jset: Double) -> Double {
        return Jtransit - (Jset - Jtransit);
    }
}

struct SunData {
    var currentPeriod: String

    var sunriseStart: NSDate?
    // var sunriseStart: NSDate?
    var sunriseEnd: NSDate?
    var solarNoon: NSDate
    var sunsetStart: NSDate?
    // var sunsetEnd: NSDate?
    var sunsetEnd: NSDate?
}