import MapKit

struct Location: Codable {
    let latitude, longitude: Double?
}

extension Location: Hashable { }

extension Location {
    var placeMark: MKPlacemark? {
        guard let lat = latitude,
              let lon = longitude else {
            return nil
        }
        return MKPlacemark(coordinate: CLLocationCoordinate2DMake(lat, lon))
    }
    
    func getDirections(_ name: String?) {
        guard let placemark = placeMark else { return }
        let mkLocation = MKMapItem(placemark: placemark)
        #if os(tvOS)
        return
        #else
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mkLocation.name = name
        mkLocation.openInMaps(launchOptions: launchOptions)
        #endif
    }
}
