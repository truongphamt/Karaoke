//
//  TableViewController.swift
//  Karaoke
//
//  Created by Anh Phung on 2/26/19.
//  Copyright © 2019 TPham. All rights reserved.
//

import UIKit
import CoreData

class TableViewCell : UITableViewCell{
    
    @IBOutlet weak var Number: UILabel!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Artists: UILabel!
}

class TableViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var data : [Song]!
    var filteredData : [Song]!
    var sectionIndex = [String]()
    let numberOfRowsInSection = 500
    var isSearching: Bool { get {return filteredData.count != data.count}}

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        
        //0=0, 1=2, 2=4, 3=6, 5=9
        let index = "1,,,501,,,1001,,,1501,,,2001,,,2501,,,3001,,,3501,,,4001,,,4501,,,5001,,,5501,,,6001"
        sectionIndex = index.components(separatedBy: ",")
        
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        
        do {
            // Execute the fetch request, and cast the results to an array of LogItem objects
            if let fetchResults = try managedObjectContext?.fetch(fetchRequest) as? [Song] {
                data = fetchResults
                filteredData = fetchResults
            }
        } catch {}
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return isSearching ? 1 : sectionIndex.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return filteredData.count
        }
        
        if (section % 3 != 0) {
            return 0
        }
        
        let realSection = (section) / 3
        var rows = data.count-(realSection*numberOfRowsInSection)
        if (rows > numberOfRowsInSection) {
            rows = numberOfRowsInSection
        }
        
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! TableViewCell
        let realSection = indexPath.section == 0 ? 0 : (indexPath.section) / 3
        let song = isSearching ? filteredData[indexPath.row] : data[indexPath.row + (realSection * numberOfRowsInSection)]
        
        cell.Number?.text = song.number
        cell.Title?.text = song.title
        cell.Artists?.text = song.artists
        
        return cell
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? data : data.filter({(song: Song) -> Bool in
            // If dataItem matches the searchText, return true to include it
            let titleMatched = song.title!.range(of: searchText, options: .caseInsensitive) != nil
            let artistMatched = song.artists!.range(of: searchText, options: .caseInsensitive) != nil
            
            return titleMatched || artistMatched
        })
        
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndex
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
