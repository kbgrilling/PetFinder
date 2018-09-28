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
	
	var searchResults = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//lowers the table view below the search bar so the first cell is seen
		tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0	)
	}


}

extension PetSearchViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		searchResults = []
		for i in 0...2 {
			searchResults.append("the search return order \(i) \(searchBar.text!)")
			
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
		return searchResults.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "SearchResultCell"
		
		var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")
		
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
			
		}
		
		cell.textLabel!.text = searchResults[indexPath.row]
		return cell
		
	}
	
	
}
