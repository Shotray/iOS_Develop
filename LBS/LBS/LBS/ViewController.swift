//
//  ViewController.swift
//  LBS
//
//  Created by Shotray on 2021/11/28.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController{

    @IBOutlet weak var mapUI: MKMapView!
    private let locationManager : CLLocationManager = CLLocationManager()
    let trans = Transform()
    var lock = NSLock()
    var locations = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        //map configuration
        mapUI.delegate = self
        mapUI.mapType = MKMapType.standard
        mapUI.showsUserLocation = true
        mapUI.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        
        //locationManager configurations
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 1
        //不知道为什么不能用
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        
        getAuthorization()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func enterBackground(notification: NSNotification){
        print("back")
        locationManager.distanceFilter = 2
    }
    
    @objc func enterForeground(notification: NSNotification){
        print("fore")
        if locationManager.distanceFilter == 2 && (locations.count >= 2){
            let ployline = MKPolyline(coordinates: locations, count: locations.count)
            mapUI.addOverlay(ployline)
            let location = locations[locations.endIndex - 1]
            locations.removeAll()
            locations.append(location)
        }
        locationManager.distanceFilter = 1
    }
    

    func getAuthorization(){
        switch locationManager.authorizationStatus{
        case .restricted,.denied:
            self.locationManager.stopUpdatingLocation()
            popup()
        case .authorizedWhenInUse,.authorizedAlways:
            self.locationManager.startUpdatingLocation()
        case .notDetermined:
            self.locationManager.stopUpdatingLocation()
        default:
            break
        }
    }
    
    func popup(){
        let alert = UIAlertController(title: "系统提示", message: "没有定位权限", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        getAuthorization()
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.fillColor = UIColor.blue
        render.strokeColor = UIColor.green
        render.lineWidth = 5
        return render
    }
}

extension ViewController : CLLocationManagerDelegate{
    
    func foreOverlay(_ location: CLLocationCoordinate2D){
        locations.append(location)
        let ployline = MKPolyline(coordinates: locations, count: locations.count)
        mapUI.addOverlay(ployline)
        locations.remove(at: 0)
    }
    
    func backOverlay(_ location: CLLocationCoordinate2D){
        locations.append(location)
        if locations.count > 20 {
            let ployline = MKPolyline(coordinates: locations, count: locations.count)
            mapUI.addOverlay(ployline)
            locations.removeAll()
            locations.append(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lock.lock()
        print(self.locations.count)
        print(locations)
        guard let newLocation = locations.last else{ return }
        let location = trans.transformFromWGSToGCJ(wgsLoc: newLocation.coordinate)
        if self.locations.count == 0{
            self.locations.append(location)
        }
        else{
            if locationManager.distanceFilter == 1{
                foreOverlay(location)
            }
            else{
                backOverlay(location)
            }
        }
        lock.unlock()
    }
}
