//
//  MapViewController.swift
//  Quero Conhecer
//
//  Created by Gabriel Chirico Mahtuk de Melo Sanzone on 06/08/19.
//  Copyright © 2019 Gabriel Chirico Mahtuk de Melo Sanzone. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController {
    
    enum MapMessageType {
        case routeError
        case authorizationWarning
        
    }
    
    //MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    var poi: [MKAnnotation] = []
    // (lazy) é usado para apenas estanciar a variavel qnd ela for usada
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    //MARK: showRoute
    @IBAction func showRoute(_ sender: Any) {
    }
    //MARK: showSearchBar
    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        viInfo.isHidden = true
        mapView.delegate = self
        locationManager.delegate = self
        mapView.mapType = .mutedStandard
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
        for place in places {
            addToMap(place)
        }
        
        configureLocationButton()
        
        showPlaces()
        requestUserLocationAuthorization()
    }
    
    func configureLocationButton(){
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways,.authorizedWhenInUse:
                mapView.addSubview(btUserLocation)
            case .denied:
                showMessage(type: .authorizationWarning)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
    
            }
        } else {
            //nao da
        }
    }
    
    //MARK: showMessage
    func showMessage(type: MapMessageType) {
//        let title: String, message: String
//        var hasConfirmation: Bool = false
//
//        switch type {
//        case .confirmation(let name):
//            title   = "Local Encontrado"
//            message = "Deseja Adiconar o \(name)?"
//            hasConfirmation = true
//        case .error(let errorMessage):
//            title = "Erro"
//            message = errorMessage
//
//        }
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//        if hasConfirmation {
//            let confirmaAction = UIAlertAction(title: "Ok", style: .default) { (action) in
//                self.delegate?.addPlace(self.place)
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(confirmaAction)
//        }
//        present(alert, animated: true, completion: nil)
    }
    
    //MARK: addToMap
    func addToMap(_ place: Place){
        //Point padrão do iOS
        //let annotation = MKPointAnnotation()
        //annotation.coordinate = place.coordinate
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        //annotation.subtitle = place.address
        annotation.address = place.address
        mapView.addAnnotation(annotation)
    }
    //MARK: showPlaces
    func showPlaces(){
        mapView.showAnnotations(mapView.annotations, animated: true)
    }


}
//MARK: extension MapViewController
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation){
            return nil
        }
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? #imageLiteral(resourceName: "placeGlyph") : #imageLiteral(resourceName: "poiGlyph")
        annotationView?.displayPriority = .defaultLow
        
        return annotationView
    }
}

//MARK: extension MapViewController
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.loading.stopAnimating()
                    return
                }
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                for item in response.mapItems {
                    //Cria uma Annotation
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    //Adiciona o titulo e subtitulo
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    self.poi.append(annotation)
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
            }
            self.loading.stopAnimating()
        }
    }
}

//MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
}
