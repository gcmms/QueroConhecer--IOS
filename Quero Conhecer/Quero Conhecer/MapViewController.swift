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
    //MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    
    //MARK: showRoute
    @IBAction func showRoute(_ sender: Any) {
    }
    //MARK: showSearchBar
    @IBAction func showSearchBar(_ sender: Any) {
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        viInfo.isHidden = true
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
        for place in places {
            addToMap(place)
        }
        showPlaces()
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
                
            }
            
        }
    }
}
