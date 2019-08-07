//
//  PlacesFinderViewController.swift
//  Quero Conhecer
//
//  Created by Gabriel Chirico Mahtuk de Melo Sanzone on 15/07/19.
//  Copyright © 2019 Gabriel Chirico Mahtuk de Melo Sanzone. All rights reserved.
//

import UIKit
import MapKit

class PlacesFinderViewController: UIViewController {
    
    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_ :)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location , completionHandler: { (placemark, error) in
                self.load(show: false)
                //guard let placemark =  placemarks?.first else {return}
                //print(Place.getFormattedAddress(with: placemark))
                if error == nil {
                    if !self.savePlace(with: placemark?.first) {
                        //Erro
                        self.showMessage(type: .error("Não foi encontrado nenhum local com este nome"))
                    }
                } else {
                    self.showMessage(type: .error("Erro Desconhecido"))
                }
            })
        }
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        //faz o teclado fechar
        tfCity.resignFirstResponder()
        let city = tfCity.text!
        //Aparece a tela de loading
        load(show: true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(city) { (placemarks, error) in
            self.load(show: false)
            //guard let placemark =  placemarks?.first else {return}
            //print(Place.getFormattedAddress(with: placemark))
            if error == nil {
                if !self.savePlace(with: placemarks?.first) {
                    //Erro
                    self.showMessage(type: .error("Não foi encontrado nenhum local com este nome"))
                }
            } else {
                self.showMessage(type: .error("Erro Desconhecido"))
            }
        }
        
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Sem nome - Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        
        return true
    }
    
    func showMessage(type: PlaceFinderMessageType) {
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title   = "Local Encontrado"
            message = "Deseja Adiconar o \(name)?"
            hasConfirmation = true
        case .error(let errorMessage):
            title = "Erro"
            message = errorMessage

        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if hasConfirmation {
            let confirmaAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                print("ok!!!!!")
            }
            alert.addAction(confirmaAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func load(show:Bool) {
        viLoading.isHidden = !show
        if show {
            aiLoading.startAnimating()
        } else {
            aiLoading.stopAnimating()
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
