// ViewController.swift

import UIKit
import MapKit

class ViewController: UIViewController {
  
  @IBOutlet private var mapView: MKMapView!
  
  private var artworks: [Artwork] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    mapView.centerToLocation(initialLocation)
    
    let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
    let region = MKCoordinateRegion(center: oahuCenter.coordinate, latitudinalMeters: 50000, longitudinalMeters: 60000)
    
    mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
    
    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    mapView.setCameraZoomRange(zoomRange, animated: true)
    
    mapView.delegate = self
    
    loadInitialData()
    mapView.addAnnotations(artworks)
  }
  
  private func loadInitialData() {
    // 1
    guard
      let fileName = Bundle.main.url(forResource: "PublicArt", withExtension: "geojson"),
      let artworkData = try? Data(contentsOf: fileName)
      else {
        return
    }

    do {
      // 2
      let features = try MKGeoJSONDecoder().decode(artworkData).compactMap { $0 as? MKGeoJSONFeature }
      // 3
      let validWorks = features.compactMap(Artwork.init)
      // 4
      artworks.append(contentsOf: validWorks)
      
    } catch {
      // 5
      print("Unexpected error: \(error).")
    }
  }
}

extension ViewController: MKMapViewDelegate {
  // 1
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // 2
    guard let annotation = annotation as? Artwork else {
      return nil
    }
    
    // 3
    let identifier = "artwork"
    
    var view: MKMarkerAnnotationView
    
    // 4
    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
      
      dequeuedView.annotation = annotation
      view = dequeuedView
      
    } else {
      // 5
      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    
    return view
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    guard let artwork = view.annotation as? Artwork else {
      
      return
    }

    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    
    artwork.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}

private extension MKMapView {
  
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    
    setRegion(coordinateRegion, animated: true)
  }
}

