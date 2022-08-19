//
//  MapViewController.swift
//  no-storyboard-launch
//
//  Created by Alebelly Nemesis on 8/18/22.
//

import UIKit
import MapKit
import CoreLocation

protocol NavigationDelegate {
	func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance)
}

class MapViewController: UIViewController, NavigationDelegate, MKMapViewDelegate {

	let mapView = MKMapView()
	var locationManager = CLLocationManager()
	let trackingButton = UIButton(type: UIButton.ButtonType.system) as UIButton
	let mapAppearanceSwitch = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
	var userPointAnnotation = MKPointAnnotation()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		configureSegmentedBar(mapAppearanceSwitch)
		configureTrackingButton(trackingButton)
		addPointAnnotationPins()
		mapView.showsUserLocation = true
		mapView.delegate = self
		view.addSubview(mapView)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		mapView.frame = view.bounds
		view.backgroundColor = .white
		
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	override init(nibName: String?, bundle: Bundle?) {
		super.init(nibName: nibName, bundle: bundle)
		
		tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "mappin.and.ellipse"), tag: 1)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}

extension MapViewController: CLLocationManagerDelegate{

	func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
		let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
			latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		mapView.setRegion(coordinateRegion, animated: true)
	}
}

extension MapViewController {
	
	func configureTrackingButton(_ button: UIButton) {
		mapView.addSubview(button)
		
		button.setImage(UIImage(systemName: "location.fill"), for: .normal)
		button.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for: .touchUpInside)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.centerYAnchor.constraint(equalTo: mapAppearanceSwitch.centerYAnchor),
			button.leadingAnchor.constraint(equalTo: mapAppearanceSwitch.trailingAnchor, constant: 20)
		])
	}
	
	@objc func centerMapOnUserButtonClicked () {
		let userLocation = locationManager.location
		let latitude = userLocation?.coordinate.latitude
		let longitude = userLocation?.coordinate.longitude
		
		userPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
		centerLocation(userLocation!, regionRadius: 1000)
	}
	
	func configureSegmentedBar (_ segmentedBar: UISegmentedControl) {
		mapView.addSubview(segmentedBar)
		
		segmentedBar.backgroundColor = .systemGray2
		segmentedBar.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			segmentedBar.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
			segmentedBar.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
		
		segmentedBar.addTarget(self, action: #selector(changeMapType(_:)), for: .valueChanged)
	}

	@objc func changeMapType(_ segmentedControl: UISegmentedControl) {
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			mapView.mapType = MKMapType.standard
		case 1:
			mapView.mapType = MKMapType.satellite
		case 2:
			mapView.mapType = MKMapType.hybrid
		default:
			break
		}
	}
	
	func addPointAnnotationPins () {
		places.forEach({ mapView.addAnnotation($0.annotation) })
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
		switch annotation.title {
		case "42 Paris":
			annotationView.markerTintColor = .blue
		case "21 Moscow":
			annotationView.markerTintColor = .red
		case "21 Kazan":
			annotationView.markerTintColor = .green
		case "21 Novosibirsk":
			annotationView.markerTintColor = .purple
		default:
			annotationView.markerTintColor = .green
		}
		return annotationView
	}
}
