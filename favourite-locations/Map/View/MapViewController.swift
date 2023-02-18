//
//  MapViewController.swift
//  favourite-locations
//
//  Created by Irek Khabibullin on 8/18/22.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewProtocol: AnyObject {
    func replaceAnnotations(with newAnnotations: [MKPointAnnotation])
}

class MapViewController: UIViewController {
    
    var presenter: MapPresenterProtocol!
    var completion: ((Double, Double) -> Void)?
    var selectedPin: MKPointAnnotation?
    
    let mapView: MKMapView = {
        let view = MKMapView()
        view.showsUserLocation = true
        return view
    }()
    
    var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    let segmentedBar: UISegmentedControl = {
        let bar = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        bar.backgroundColor = .white
        bar.addTarget(self, action: #selector(changeMapType(_:)), for: .valueChanged)
        bar.selectedSegmentIndex = 0
        if #available(iOS 13.0, *) {
            bar.selectedSegmentTintColor = UIColor(named: "mint-light")
        } else {
            bar.tintColor = UIColor(named: "mint-light")
        }
        return bar
    }()
    
    let trackingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "location"), for: .normal)
        button.addTarget(self, action: #selector(locateButtonTapped), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Locations"
        label.textColor = .black
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 18.0)
        return label
    }()

    let cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Cancel"
        button.tintColor = UIColor(named: "mint-dark")
        button.action = #selector(cancelButtonTapped)
        return button
    }()
    
    let saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Save"
        button.tintColor = UIColor(named: "mint-dark")
        button.action = #selector(saveButtonTapped)
        return button
    }()
    
    let pinAmbiguityLabel: UITextView = {
        let view = UITextView()
        view.text = "Cannot save coordinates. Please, put pin."
        view.contentMode = .scaleToFill
        view.backgroundColor = .clear
        view.textColor = .white
        view.textAlignment = .center
        view.alpha = 0.0
        view.layer.cornerRadius = 15
        view.layer.backgroundColor = UIColor.red.cgColor
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isScrollEnabled = false
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureTabBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        view = mapView
        
        mapView.delegate = self
        locationManager.delegate = self
        
        cancelButton.target = self
        saveButton.target = self
        
        mapView.addSubview(trackingButton)
        mapView.addSubview(segmentedBar)
        mapView.addSubview(pinAmbiguityLabel)
        
        configureNavigationBar()
        setConstraints()
	}
    
    func setConstraints() {
        trackingButton.snp.makeConstraints {
            $0.verticalEdges.equalTo(segmentedBar.snp.verticalEdges)
            $0.leading.equalTo(segmentedBar.snp.trailing).offset(10)
        }
        segmentedBar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(mapView.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.width.equalToSuperview().multipliedBy(0.67)
        }
        pinAmbiguityLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.safeAreaLayoutGuide.snp.top).inset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
        }
    }
    
    func configureNavigationBar() {
        navigationItem.titleView = titleLabel
        
        navigationController?.navigationBar.backgroundColor = UIColor(named: "mint-light")
        navigationController?.navigationBar.layer.shadowColor = UIColor(named: "mint-light")?.cgColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "mint-light")
            appearance.shadowColor = .clear
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
        }
    }
    
    func configureTabBar() {
        tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "map"), tag: 1)
        tabBarItem.imageInsets = UIEdgeInsets.init(top: 5, left: 0, bottom: -5, right: 0)
    }
    
    @objc func locateButtonTapped() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 400, longitudinalMeters: 400)
            mapView.setRegion(region, animated: true)
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func tapInitiated(_ gestureRecognizer: UIGestureRecognizer) {
        if let previous = selectedPin {
            mapView.removeAnnotation(previous)
        }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        selectedPin = pin
        pinAmbiguityLabel.alpha = 0.0
    }
    
    @objc func cancelButtonTapped() {
        mapView.removeAnnotations(mapView.annotations)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped() {
        guard let coordinates = selectedPin?.coordinate else {
            pinAmbiguityLabel.alpha = 0.7
            UIView.animate(withDuration: 4) {
                self.pinAmbiguityLabel.alpha = 0.0
            }
            return
        }
        let latitude = Double(coordinates.latitude)
        let longitude = Double(coordinates.longitude)
        completion?(latitude, longitude)
        mapView.removeAnnotations(mapView.annotations)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func changeMapType(_ segmentedControl: UISegmentedControl) {
        let type = UInt(segmentedControl.selectedSegmentIndex)
        mapView.mapType = MKMapType(rawValue: type) ?? MKMapType.standard
    }
}

extension MapViewController: CLLocationManagerDelegate {
	
	func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
		let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
			latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		mapView.setRegion(coordinateRegion, animated: true)
	}
}

extension MapViewController: MapViewProtocol {
    func setupEditMode() {
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
        titleLabel.text = "Please, locate pin"
        if let previous = selectedPin {
            mapView.removeAnnotation(previous)
            selectedPin = nil
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapInitiated))
        mapView.addGestureRecognizer(gesture)
        
    }
    
    func setupPresentationMode() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        titleLabel.text = "Locations"
        if let previous = selectedPin {
            mapView.removeAnnotation(previous)
            selectedPin = nil
        }
    }
    
    func replaceAnnotations(with newAnnotations: [MKPointAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(newAnnotations)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        if let view = view {
            view.annotation = annotation
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        }
        view?.image = UIImage(named: "pin")
        return view
    }
}
