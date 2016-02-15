//
//  SunCalculator.swift
//  SunPaper
//
//  Created by David Celis on 2/15/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Foundation

class SunCalculator {
    static let J1970 = Double(2440588)
    static let J2000 = Double(2451545)
    static let deg2rad = M_PI / 180
    static let M0 = 357.5291 * deg2rad
    static let M1 = 0.98560028 * deg2rad
    static let J0 = 0.0009
    static let J1 = 0.0053
    static let J2 = -0.0069
    static let C1 = 1.9148 * deg2rad
    static let C2 = 0.0200 * deg2rad
    static let C3 = 0.0003 * deg2rad
    static let P = 102.9372 * deg2rad
    static let e = 23.45 * deg2rad
    static let th0 = 280.1600 * deg2rad
    static let th1 = 360.9856235 * deg2rad
    static let h0 = -0.83 * deg2rad // Angle of sunset
    static let d0 = 0.53 * deg2rad  // Diameter of the sun
    static let h1 = -6 * deg2rad    // Angle of Civil Twilight
    static let h2 = -12 * deg2rad   // Angle of Nautical Twilight
    static let h3 = -18 * deg2rad   // Angle of Astronomical Twilight
    static let secondsInDay = Double(60 * 60 * 24)

    static func calculateTimes(date: NSDate, latitude: Double, longitude: Double) -> [String:NSDate] {
        let now = date.timeIntervalSince1970
        let lw = -longitude * deg2rad
        let phi = latitude * deg2rad
        let J = dateToJulianDate(now);

        let n = getJulianCycle(J, lw: lw)
        let Js = getApproxSolarTransit(0, lw: lw, n: n)
        let M = getSolarMeanAnomaly(Js)
        let C = getEquationOfCenter(M)
        let Lsun = getEclipticLongitude(M, C: C)
        let d = getSunDeclination(Lsun)
        let Jtransit = getSolarTransit(Js, M: M, Lsun: Lsun)
        let w0 = getHourAngle(h0, phi: phi, d: d)
        let w1 = getHourAngle(h0 + d0, phi: phi, d: d)
        let Jset = getSunsetJulianDate(w0, M: M, Lsun: Lsun, lw: lw, n: n)
        let Jsetstart = getSunsetJulianDate(w1, M: M, Lsun: Lsun, lw: lw, n: n)
        let Jrise = getSunriseJulianDate(Jtransit, Jset: Jset)
        let Jriseend = getSunriseJulianDate(Jtransit, Jset: Jsetstart)
        let w2 = getHourAngle(h1, phi: phi, d: d)
        let Jnau = getSunsetJulianDate(w2, M: M, Lsun: Lsun, lw: lw, n: n)
        let Jciv2 = getSunriseJulianDate(Jtransit, Jset: Jnau)

        return [
            "dawn": julianDateToDate(Jciv2),
            "sunrise_start": julianDateToDate(Jrise),
            "sunrise_end": julianDateToDate(Jriseend),
            "solar_noon":  julianDateToDate(Jtransit),
            "sunset_start": julianDateToDate(Jsetstart),
            "sunset_end": julianDateToDate(Jset),
            "dusk": julianDateToDate(Jnau)
        ]
    }

    static func getSunPosition(date: Double, latitude: Double, longitude: Double) -> [String:Double] {
        return privateGetSunPosition(dateToJulianDate(date), lw: -longitude * deg2rad, phi: latitude * deg2rad)
    }

    private static func dateToJulianDate(date: Double) -> Double {
        return (date / secondsInDay) - 0.5 + J1970
    }

    private static func julianDateToDate(julianDate: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: (julianDate + 0.5 - J1970) * secondsInDay)
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

    private static func privateGetSunPosition(J: Double, lw: Double, phi: Double) -> [String:Double] {
        let M = getSolarMeanAnomaly(J)
        let C = getEquationOfCenter(M)
        let Lsun = getEclipticLongitude(M, C: C)
        let d = getSunDeclination(Lsun)
        let a = getRightAscension(Lsun)
        let th = getSiderealTime(J, lw: lw)

        return [
            "azimuth": getAzimuth(th, a: a, phi: phi, d: d),
            "altitude": getAltitude(th, a: a, phi: phi, d: d)
        ]
    }
}
