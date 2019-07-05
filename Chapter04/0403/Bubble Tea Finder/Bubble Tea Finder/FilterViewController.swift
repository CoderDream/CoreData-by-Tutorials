/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController,
                            didSelectPredicate predicate: NSPredicate?,
                            sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
  
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!
  
  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!
  
  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!
  
  // MARK: - Properties
  var coreDataStack: CoreDataStack!
  
  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?
  
  lazy var cheapVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
  }()
  
  lazy var moderateVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
  }()
  
  lazy var expensiveVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
  }()
  
  lazy var offeringDealPredicte: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
  }()
  lazy var walkingDistancePredicte: NSPredicate = {
    return NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
  }()
  lazy var hasUserTipsPredicte: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
  }()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateCheapVenueCountLabel()
    populateModerateVenueCountLabel()
    populateExpensiveVenueCountLabel()
    populateDealsVenueCountLabel()
  }
}

// MARK: - IBActions
extension FilterViewController {
  
  @IBAction func search(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
}

// MARK - UITableViewDelegate
extension FilterViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
   
    switch cell {
    // Price section
    case cheapVenueCell:
      selectedPredicate = cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = expensiveVenuePredicate
      
    // Most Popular section
    case offeringDealCell:
      selectedPredicate = offeringDealPredicte
    case walkingDistanceCell:
      selectedPredicate = walkingDistancePredicte
    case userTipsCell:
      selectedPredicate = hasUserTipsPredicte
    default:
      break
    }
    cell.accessoryType = .checkmark
  }
}

// MARK: - Helper methods
extension FilterViewController {
  func populateCheapVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = cheapVenuePredicate
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "place" : "places"
      firstPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
  
  func populateModerateVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = moderateVenuePredicate
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "place" : "places"
      secondPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
  
  func populateExpensiveVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = expensiveVenuePredicate
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "place" : "places"
      thirdPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
  
  func populateDealsVenueCountLabel() {
    // 1
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
    fetchRequest.resultType = .dictionaryResultType
    
    // 2
    let sumExpressionDesc = NSExpressionDescription()
    sumExpressionDesc.name = "sumDeals"
    
    // 3
    let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
    sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp])
    sumExpressionDesc.expressionResultType = .integer32AttributeType
    
    // 4
    fetchRequest.propertiesToFetch = [sumExpressionDesc]
    
    // 5
    do {
      let results = try coreDataStack.managedContext.fetch(fetchRequest)
      let resultDict = results.first!
      let numDeals = resultDict["sumDeals"] as! Int
      let pluralized = numDeals == 1 ? "deal" : "deals"
      numDealsLabel.text = "\(numDeals)\(pluralized)"
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
}
