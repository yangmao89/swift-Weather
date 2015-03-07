//
//  ViewController.swift
//  swift Weather
//
//  Created by liuduanchn on 15/2/28.
//  Copyright (c) 2015年 jhpost. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationMananger :CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationMananger.delegate  = self
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        if(ios8()){
            locationMananger.requestAlwaysAuthorization()
        }
        locationMananger.startUpdatingLocation()
    }
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion >= "8.1"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location :CLLocation = locations[locations.count - 1] as CLLocation
        if(location.horizontalAccuracy > 0 ){
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
        }
        self.updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
        locationMananger.stopUpdatingLocation()
        
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees,longitude: CLLocationDegrees){
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude,"lon":longitude,"cnt":0]
        manager.GET(url, parameters: params, success: { (operation:AFHTTPRequestOperation!, responseObiect: AnyObject!) in
            println("JSON:" + responseObiect.description!)
            self.updateUISucess(responseObiect as NSDictionary)
            },failure: { (operation:AFHTTPRequestOperation!,error:NSError!) in
                println("Error:"+error.localizedDescription)})
        
    }

    func updateUISucess(jsonResult:NSDictionary!){
        if let tempResult = jsonResult["main"]?["temp"]? as? Double{
            var temper: Double
            if(jsonResult["sys"]?["country"]? as String == "US"){
                temper = round(((tempResult-273.15)*1.8) + 32 )
            }
            else
            {
                temper = round(tempResult - 273.15)
            }
            self.temperature.text =  "\(temper)°"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
            var name = jsonResult["name"]? as String
            self.location.text = "\(name)"
            self.temperature.font = UIFont.boldSystemFontOfSize(25)
            
            var condition = jsonResult["weather"]?[0]!["id"] as Int
            var sunrise = jsonResult["sys"]?["sunrise"] as Double
            var sunset = jsonResult["sys"]?["sunset"] as Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            // println(nowAsLong)
            
            if (now < sunrise || now > sunset) {
                nightTime = true
            }
            self.updateWeatherIcon(condition, nightTime: nightTime)
        }
        else
        {
            
        }
    }
    
    // Converts a Weather Condition into one of our icons.
    // Refer to: http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        // Thunderstorm
        if (condition < 300) {
            self.icon.image = UIImage(named: "Cloud-Lightning")
        }
            // Drizzle
        else if (condition < 500) {
            self.icon.image = UIImage(named: "Cloud-Drizzle")
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.icon.image = UIImage(named: "Cloud-Rain")
        }
            // Snow
        else if (condition < 700) {
            self.icon.image = UIImage(named: "Cloud-Snow-Alt")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            self.icon.image = UIImage(named: "Cloud-Fog")
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.icon.image = UIImage(named: "Cloud-Wind")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.icon.image = UIImage(named: "Moon")
            }
            else {
                self.icon.image = UIImage(named: "Sun")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.icon.image = UIImage(named: "Cloud-Moon")
            }
            else{
                self.icon.image = UIImage(named: "Cloud-Sun")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.icon.image = UIImage(named: "Cloud")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.icon.image = UIImage(named: "Cloud-Wind")
        }
            // Cold
        else if (condition == 903) {
            self.icon.image = UIImage(named: "Thermometer-25")
        }
            // Hot
        else if (condition == 904) {
            self.icon.image = UIImage(named: "Thermometer-75")
        }
        else {
            // Weather condition not available
            self.icon.image = UIImage(named: "Cloud-Download")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error)
    }
}

