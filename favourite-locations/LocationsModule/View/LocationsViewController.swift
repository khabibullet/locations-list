//
//  PlacesViewController.swift
//  favourite-locations
//
//  Created by Irek Khabibullin on 8/18/22.
//

import UIKit
import CoreData
import SnapKit

protocol LocationsViewProtocol {
    
}

class LocationsViewController: UIViewController, LocationsViewProtocol {
	
    weak var presenter: LocationsPresenterProtocol!
    
	let locationsTable = UITableView()
    let searchController = UISearchController()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.tintColor = UIColor(named: "mint-dark")
        return spinner
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Locations"
        label.textColor = UIColor(named: "mint-dark")
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
		view.addSubview(locationsTable)
        
        registerTable()
        configureSearchBar()
        configureNavigationBar()
        configureTabBar()
        configureTabBar()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
        
        locationsTable.frame = view.safeAreaLayoutGuide.layoutFrame
	}
    
    func registerTable() {
        locationsTable.register(LocationTableCell.self, forCellReuseIdentifier: LocationTableCell.id)
        locationsTable.delegate = self
        locationsTable.dataSource = self
        locationsTable.separatorStyle = .none
    }
    
    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.textField?.backgroundColor = .white
    }
    
    func configureNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        let image = UIImage(named: "add")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = item
        navigationItem.titleView = titleLabel
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(named: "mint-light")
    }
    
    func configureTabBar() {
        tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "list"), tag: 0)
        tabBarItem.imageInsets = UIEdgeInsets.init(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.backgroundColor = UIColor(named: "mint-light")
        tabBarController?.tabBar.unselectedItemTintColor = UIColor(named: "mint-light-2")
    }
    
    @objc func didTapAddButton() {
//        let inputVC = LocationAddViewController()
//        inputVC.delegate = self
//        self.present(inputVC, animated: true, completion: nil)
        print("add button tapped")
    }
    
    func updateTableContents() {
        locationsTable.reloadData()
    }
}

extension LocationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension LocationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfLocationsWithPrefix()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = locationsTable.dequeueReusableCell(withIdentifier: LocationTableCell.id, for: indexPath) as? LocationTableCell else {
            return LocationTableCell()
        }
        
        let location = presenter.getLocationWithPrefixOnIndex(id: indexPath.row)
        cell.title.text = location.name
        let northOrSouth = location.latitude > 0 ? "N" : "S"
        let eastOrWest = location.longitude > 0 ? "E" : "W"
        cell.coordinates.text = String(format: "%.2f°%@, %.2f°%@", abs(location.latitude), northOrSouth, abs(location.longitude), eastOrWest)
        if let comment = location.comment {
            cell.comment.text = comment
        }
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        navigationDelegate?.centerLocation(places[indexPath.row].location, regionRadius: 1000)
//        tabBarController?.selectedIndex = 1
//    }
//
//    func setDefaultLocation() {
//        navigationDelegate?.centerLocation(places[0].location, regionRadius: 1000)
//        tabBarController?.selectedIndex = 1
//    }
}
