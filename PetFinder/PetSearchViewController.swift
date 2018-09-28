//
//  ViewController.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 9/28/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

import UIKit

class PetSearchViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableview: UITableView!
	
	var didSearch = false
	var searchResults = [String]()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//lowers the table view below the search bar so the first cell is seen
		tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0	)
	}


}

extension PetSearchViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		didSearch = true
		searchResults = []
		for _ in 0...2 {
			searchResults.append("\(searchBar.text!) Name")
			
		}
		tableview.reloadData()
		searchBar.resignFirstResponder()
	}
	
	
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

extension PetSearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !didSearch {
			return 1
		} else {
			return searchResults.count
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
		let imageView = cell.viewWithTag(1000) as! UIImageView
		let nameLabel = cell.viewWithTag(1001) as! UILabel
		let descriptionLabel = cell.viewWithTag(1002) as! UILabel
		
		if !didSearch {
			//imageView.image = UIImage(named: "NOICON")
			nameLabel.text = " "
			descriptionLabel.text = "Use the search bar above to find your new friend!"
			cell.accessoryType = .none
			
		} else {
			cell.accessoryType = .detailButton
			imageView.image = UIImage(named: "NOICON")
			nameLabel.text = searchResults[indexPath.row]
			descriptionLabel.text = "This will be the animal description"
		}
		
		
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if searchResults.count == 0 {
			return nil
		} else {
			return indexPath
		}
		
	}
	
	
}
