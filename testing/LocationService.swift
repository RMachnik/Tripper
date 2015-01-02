//
//  LocationService.swift
//  testing
//
//  Created by RMachnik on 27.12.2014.
//  Copyright (c) 2014 David Owens. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationService : NSObject, CLLocationManagerDelegate{
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    
    func getCurrentLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let location = self.locationManager.location

        println("Waiting for current location")
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        //--- CLGeocode to get address of current location ---//
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil)
            {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0
            {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            }
            else
            {
                println("Problem with the data received from geocoder")
            }
        })
         println("Updating current location!")
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark?)
    {
        if let containsPlacemark = placemark
        {
            //stop updating location to save battery life
            println("Successfull update of location!")
            locationManager.stopUpdatingLocation()
            
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
        }
        
    }
    
    func getGeocodedLocation(address: String,mapView: MKMapView){
        geocoder.geocodeAddressString(address, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil{
                println("There was an error in geocoding \(error)")
            }
            if let placemark = placemarks?[0] as? CLPlacemark {
                var mkPlacemark  = MKPlacemark(placemark: placemark)
                var coordinates = mkPlacemark.location.coordinate
                println(coordinates.latitude)
                println(coordinates.longitude)
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: placemark.location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
                mapView.addAnnotation(mkPlacemark)
            }
        })

    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println("Error while updating location " + error.localizedDescription)
    }
    
}
