//
//  YGMapViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/25/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class YGMapViewController: YGViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var places = Array<YGPlace>()
    var btnCreatePlace: UIButton!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(YGMapViewController.placeCreated(_:)),
                                       name: Constants.kPlaceCreatedNotification,
                                       object: nil)
    }
    
    override func loadView(){
        print("loadView")
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.brownColor()
        
        self.mapView = MKMapView(frame: frame)
        self.mapView.delegate = self
        view.addSubview(self.mapView)
        
        let padding = CGFloat(Constants.padding)
        let height = CGFloat(44)
        
        self.btnCreatePlace = UIButton(frame: CGRect(x: padding, y: -height, width: frame.size.width-2*padding, height: height))
        self.btnCreatePlace.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        self.btnCreatePlace.setTitle("Create Place", forState: .Normal)
        self.btnCreatePlace.addTarget(
            self,
            action: #selector(YGMapViewController.createPlace),
            forControlEvents: .TouchUpInside
        )
        self.btnCreatePlace.layer.borderColor = UIColor.whiteColor().CGColor
        self.btnCreatePlace.layer.borderWidth = 2.0
        self.btnCreatePlace.layer.cornerRadius = self.btnCreatePlace.frame.size.height*0.5
        
//        self.btnCreatePlace.alpha = 0 //initially hidden
        view.addSubview(self.btnCreatePlace)
        
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showCreateButton()
    }
    
    func placeCreated(notification: NSNotification){
        if let place = notification.userInfo!["place"] as? YGPlace {
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.addAnnotation(place)
                
                let ctr = CLLocationCoordinate2DMake(place.lat, place.lng)
                
                // check distance
                let coord = CLLocation(latitude: place.lat, longitude: place.lng)
                let mapCenter = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
                
                let delta = mapCenter.distanceFromLocation(coord)
                if (delta < 750){ //don't move map, not far away enoug yet
                    return
                }
                
                self.mapView.setCenterCoordinate(ctr, animated: true)
            })
        }
    }
    
    func showCreateButton(){
    
        UIView.animateWithDuration(1.25,
                                   delay: 0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    var frame = self.btnCreatePlace.frame
                                    frame.origin.y = 20
                                    self.btnCreatePlace.frame = frame
            }, completion: nil)
    }
    
    func createPlace(){
        print("CreatePlace: ")
        
        let createPlaceVc = YGCreatePlaceViewController()
        self.presentViewController(createPlaceVc, animated: true, completion: nil)
    
    }
    
    func searchPlaces(lat: CLLocationDegrees, lng: CLLocationDegrees){
        //Make API request to our backend
        let params = [
            "lat": lat,
            "lng": lng
        ]
        
        APIManager.getRequest("/api/place", params: params, completion: { response in
            print("\(response)")
         
            if let results = response["results"] as? Array<Dictionary<String, AnyObject>>{
                self.mapView.removeAnnotations(self.places)
                self.places.removeAll()
                
                for placeInfo in results {
                    let place = YGPlace()
                    place.populate(placeInfo)
                    self.places.append(place)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(self.places)
                
                })
            }
            
        })
    }
    
    //MARK: - MapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinId = "pinId"
        
        if let pin = mapView.dequeueReusableAnnotationViewWithIdentifier(pinId) as? MKPinAnnotationView {
            pin.annotation = annotation
            return pin
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        pin.animatesDrop = true
        pin.canShowCallout = true
        
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated: \(mapView.centerCoordinate.latitude), \(mapView.centerCoordinate.longitude)")
        
        // First time, always run:
        if(self.currentLocation == nil){
            self.searchPlaces(mapView.centerCoordinate.latitude, lng: mapView.centerCoordinate.longitude)
            return
        }
        
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let delta = mapCenter.distanceFromLocation(self.currentLocation!)
        
        if(delta < 750){ //not far enough, ignore
            return
        }
        
        print("DELTA == \(delta)")
        self.currentLocation = mapCenter
        self.searchPlaces(mapView.centerCoordinate.latitude, lng: mapView.centerCoordinate.longitude)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let place = view.annotation as! YGPlace
        print("calloutAccessoryControlTapped: \(place.name)")
        
        let chatVc = YGChatViewController()
        chatVc.place = place
        self.navigationController?.pushViewController(chatVc, animated: true)
        
    }

    // MARK: LocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if (status == .AuthorizedWhenInUse){
            self.locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("didUpdateLocations: \(locations)")
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locations[0]
        
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.currentLocation!.coordinate.latitude, self.currentLocation!.coordinate.longitude)
        
        let dist = CLLocationDistance(500)
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, dist, dist)
        self.mapView.setRegion(region, animated: true)
        
//        MAKE API REQUEST TO OUR BACKEND:
        self.searchPlaces(self.currentLocation!.coordinate.latitude, lng: self.currentLocation!.coordinate.longitude)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
