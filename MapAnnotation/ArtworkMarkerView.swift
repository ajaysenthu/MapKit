// ArtworkMarkerView.swift

import Foundation
import MapKit

class ArtworkMarkerView: MKMarkerAnnotationView {
  
  override var annotation: MKAnnotation? {
    
    willSet {
      // 1
      guard let artwork = newValue as? Artwork else {
        return
      }
      
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      // 2
      markerTintColor = artwork.markerTintColor

      glyphImage = artwork.image
    }
  }
}
