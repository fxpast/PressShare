//
//  ListProductViewController
// PressShare
//
// Description : List of products
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo: Le raffraichissement de la liste est fonction de la zone affichée sur la carte.




import CoreData
import Foundation
import UIKit
import MapKit

class ListProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var users = [User]()
    var products = [Product]()
    var productsTmp = [Product]()
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var aindex:Int!
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var flgUser=false //touch on blue user pin
    var flgOpen=false
    var flgFirst=false
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    var countProduct = 0
    var searchText = ""
    
    var frameTableView:CGRect!
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if config.level <= 0 {
            IBAddProduct.isEnabled = false
            buttonEdit.isEnabled = false
        }
        
        users = fetchAllUser()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        if  IBTableView == nil {

            IBTableView = UITableView()
            IBTableView.frame = frameTableView
            IBTableView.dataSource = self
            IBTableView.delegate = self
            IBTableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")            
            view.addSubview(IBTableView)
            
        }
        else {
            flgOpen = false
        }
        
        
        navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        IBSearch.placeholder = translate.product
        
        navigationController?.tabBarItem.title = translate.list
        if let _ = lat, let _ = lon {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
            
        }
        else if flgUser == false {
            IBLogout.image = #imageLiteral(resourceName: "eteindre")
            IBLogout.title = ""
            
        }
        else {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if flgFirst == false {
            frameTableView = IBTableView.frame
            flgFirst = true
        }
        
        if config.mess_badge > 0 {
            tabBarController?.tabBar.items![1].badgeValue = "\(config.mess_badge!)"
        }
        else {
            tabBarController?.tabBar.items![1].badgeValue = nil
        }
        
        if config.product_maj == true || config.product_add == true {
            refreshData()
            config.product_maj = false
            config.product_add = false
        }
        
        if flgOpen == false {
            flgOpen = true
            IBActivity.startAnimating()
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        self.chargeData()
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                        }
                        
                    }
                }
                
                self.customOpeation.start()
                
            }
            
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
  
        IBTableView.dataSource = nil
        IBTableView.delegate = nil
        IBTableView.removeFromSuperview()
        IBTableView = nil
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromtable" {
            
            if (aindex != 999) {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductViewController
                
                controller.aProduct = products[aindex]
                controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(restoreImageArchive(prod_image: (controller.aProduct!.prod_image)), 1)!
                
            }
            
        }
        
        
    }
    
    
    @IBAction func actionEpingle(_ sender: AnyObject) {
        
        aindex = 999
        performSegue(withIdentifier: "fromtable", sender: self)
    }
    
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
        
        if let _ = lat, let _ = lon {
            //Cancel list product
        }
        else if flgUser == false {
            //logout
            if users.count > 0 {
                for aUser in users {
                    if aUser.user_pseudo == config.user_pseudo {
                        aUser.user_logout = true
                        
                        // Save the context.
                        do {
                            try sharedContext.save()
                        } catch _ {}
                        
                        break
                    }
                }
                
                users = fetchAllUser()
                
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionEdit(_ sender: AnyObject)  {
        
        IBTableView.isEditing = !IBTableView.isEditing
        
    }
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        productsTmp.removeAll()
        countProduct = 0
        self.searchText = searchText
        IBActivity.startAnimating()
        
        myQueue.cancelAllOperations()
        
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if searchText == "" {
                        
                        self.countProduct = self.products.count
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            searchBar.endEditing(true)
                            self.IBActivity.stopAnimating()
                            self.IBTableView.reloadData()
                        }
                        
                    }
                    else {
                        self.searchData(searchText)
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBActivity.stopAnimating()
                        }
                    }
                    
                }
            }
            
            self.customOpeation.start()
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: Data Product
    
    private func saveImageArchive(prod_image:String) -> String {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_image)!.path
        let fileListPath = url.appendingPathComponent("listProdImage")!.path
        
        var prodImage = ""
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data) != nil {
            prodImage = prod_image
        }
        else {
            
            let imageURL = URL(string: "http://pressshare.fxpast.com/images/\(prod_image).jpg")
            
            do {
                NSKeyedArchiver.archiveRootObject(try Data(contentsOf: imageURL!), toFile: filePath)
                prodImage = prod_image
                
                if (NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as? [String]) != nil {
                    var arrayImage =  NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as! [String]
                    
                    let dateText = arrayImage[0].replacingOccurrences(of: "+0000", with: "")
                    let aDate = Date().dateFromString(dateText, format: "yyyy-MM-dd HH:mm:ss")
                    let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: aDate)
                    let resultCompare = Date().compare(futureDate!)
                    
                    if resultCompare == ComparisonResult.orderedDescending {
                        
                        for index in 1...arrayImage.count-1 {
                            do {
                                try FileManager.default.removeItem(atPath: arrayImage[index])
                            } catch  {
                                print("error ", arrayImage[index])
                            }
                        }
                        
                        do {
                            try FileManager.default.removeItem(atPath: fileListPath)
                        } catch  {
                            print("error ", fileListPath)
                        }
                        
                        var arrayImage = [String]()
                        arrayImage.append("\(Date())")
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    else {
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    
                }
                else {
                    var arrayImage = [String]()
                    arrayImage.append("\(Date())")
                    arrayImage.append(filePath)
                    NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                }
                
                
            }
            catch {
                prodImage = ""
                
            }
            
        }
        
        return prodImage
        
    }
    
    
    private func restoreImageArchive(prod_image:String) -> UIImage {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_image)!.path
        
        if let imagData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
            return UIImage(data:imagData)!
        }
        else {
            return #imageLiteral(resourceName: "noimage")
        }
        
    }
    
    
    private func chargeData() {
        
        guard let theProducts = Products.sharedInstance.productsArray else {
            return
        }
        
        var minimumLon = Double()
        var maximumLon = Double()
        var minimumLat = Double()
        var maximumLat = Double()
        
        if let _ = lat, let _ = lon {
            //Constants
            let SearchBBoxHalfWidth = 1.0
            let SearchBBoxHalfHeight = 1.0
            let SearchLatRange = (-90.0, 90.0)
            let SearchLonRange = (-180.0, 180.0)
            
             minimumLon = max(Double(lon!) - SearchBBoxHalfWidth, SearchLonRange.0)
             minimumLat = max(Double(lat!) - SearchBBoxHalfHeight, SearchLatRange.0)
             maximumLon = min(Double(lon!) + SearchBBoxHalfWidth, SearchLonRange.1)
             maximumLat = min(Double(lat!) + SearchBBoxHalfHeight, SearchLatRange.1)
            
        }
        
        for prod in theProducts {
            
            if customOpeation.isCancelled {
                break
            }
            
            var produ = Product(dico: prod)
            if let _ = lat, let _ = lon {
                if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon && produ.prod_hidden == false) {
                    produ.prod_image = saveImageArchive(prod_image: produ.prod_image)
                    products.append(produ)
                    
                }
            }
            else {
                
                if produ.prod_by_user == config.user_id || produ.prod_oth_user == config.user_id   {
                    produ.prod_image = saveImageArchive(prod_image: produ.prod_image)
                    products.append(produ)
                    
                }
                
            }
            
            countProduct = products.count
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.IBTableView.reloadData()
            }
            
        }
        
    }
    
    
    private func refreshData()  {
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            IBTableView.reloadData()
            return
        }
        
        IBActivity.startAnimating()
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id) {(success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let message = Message(dico: mess)
                        
                        if message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                            i+=1
                        }
                        
                    }
                    
                    if i > 0 {
                        self.config.mess_badge = i
                        self.tabBarController?.tabBar.items![1].badgeValue = "\(i)"
                        
                    }
                    
                    self.IBActivity.stopAnimating()
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
        IBActivity.startAnimating()
        
        if config.product_maj == true {
            MDBProduct.sharedInstance.getProduct(products[aindex].prod_id, completionHandlerProduct: { (success, productArray, errorString) in
                
                if success {
                    
                    for prod in productArray! {
                        
                        var produ = Product(dico: prod)
                        produ.prod_image = self.saveImageArchive(prod_image: produ.prod_image)
                        self.products[self.aindex].prod_id = produ.prod_id
                        self.products[self.aindex].prod_by_cat = produ.prod_by_cat
                        self.products[self.aindex].prod_by_user = produ.prod_by_user
                        self.products[self.aindex].prod_comment = produ.prod_comment
                        self.products[self.aindex].prod_date = produ.prod_date
                        self.products[self.aindex].prod_etat = produ.prod_etat
                        self.products[self.aindex].prod_hidden = produ.prod_hidden
                        self.products[self.aindex].prod_image = produ.prod_image
                        self.products[self.aindex].prod_latitude = produ.prod_latitude
                        self.products[self.aindex].prod_longitude = produ.prod_longitude
                        self.products[self.aindex].prod_mapString = produ.prod_mapString
                        self.products[self.aindex].prod_nom = produ.prod_nom
                        self.products[self.aindex].prod_prix = produ.prod_prix
                        self.products[self.aindex].prod_tempsDispo = produ.prod_tempsDispo
                        self.products[self.aindex].prodImageOld = produ.prodImageOld
                        
                        break
                        
                    }
                    
                    
                    
                    
                    self.countProduct = self.products.count
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                        self.IBActivity.stopAnimating()
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
                
            })
        }
        else {
            
            products.removeAll()
            
            
            IBTableView.reloadData()
            
            MDBProduct.sharedInstance.getAllProducts(config.user_id) { (success, productArray, errorString) in
                
                if success {
                    
                    Products.sharedInstance.productsArray = productArray
                    self.chargeData()
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    
    private func searchData(_ str:String) {
        
        
        for prod in products {
            
            if customOpeation.isCancelled {
                break
            }
            
            let nom = prod.prod_nom.lowercased()
            
            if nom.contains(str.lowercased()) {
                productsTmp.append(prod)
                countProduct += 1
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.IBTableView.reloadData()
            }
            
        }
        
        
        
    }
    
    
    
    //MARK: coreData function
    
    fileprivate func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        // Create the Fetch Request
        
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(request) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    //MARK: Table View Controller data source
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let product =  products[indexPath.row]
        
        guard config.user_id == product.prod_by_user else {
            displayAlert(translate.error, mess: translate.deletionFor)
            return
        }
        MDBProduct.sharedInstance.setDeleteProduct(product) { (success, errorString) in
            
            if success {
                
                let prod1 =  self.products[indexPath.row]
                var i = 0
                
                for produ in Products.sharedInstance.productsArray {
                    i+=1
                    let prod2 = Product(dico: produ)
                    if (prod2.prod_id == prod1.prod_id) {
                        self.products.remove(at: indexPath.row)
                        
                        Products.sharedInstance.productsArray.remove(at: i-1)
                        break
                    }
                }
                
                self.countProduct = self.products.count
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    if self.products.count == 0 {
                        self.buttonEdit.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
    }
    
    
    private func chargeBadge(_ cell:UITableViewCell, badgeValue:Int) -> UITableViewCell  {
        
        
        if cell.contentView.subviews.count > 2 {
            
            for view in (cell.contentView.subviews) {
                
                if view.tag == 77 {
                    view.removeFromSuperview() //badge
                }
                else if view.tag == 88 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x - 10, y: 0) , size: view.frame.size) //image
                }
                else if view.tag == 99 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x - 10, y: 0) , size: view.frame.size) //product name
                }
            }
            
        }
        
        if badgeValue > 0 {
            let badge = BadgeLabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
            badge.setup()
            badge.badgeValue = "\(badgeValue)"
            badge.tag = 77
            cell.contentView.addSubview(badge)
            
            for view in (cell.contentView.subviews) {
                
                if view.tag == 88 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x + 10.0, y: 0) , size: view.frame.size) //image
                }
                else if view.tag == 99 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x + 10.0, y: 0) , size: view.frame.size) //product name
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        var product:Product
        
        if searchText == "" {
            product =  products[(indexPath as NSIndexPath).row]
        }
        else {
            product =  productsTmp[(indexPath as NSIndexPath).row]
        }
        
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(product.prod_nom) (user:\(product.prod_by_user))"
            }
            else if view.tag == 88 {
                let photo = view as! UIImageView
                if product.prod_image == "" {
                    photo.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                    photo.image = restoreImageArchive(prod_image: product.prod_image)
                }
                
            }
            
        }
        
        var i = 0
        for mess in Messages.sharedInstance.MessagesArray {
            
            let message = Message(dico: mess)
            
            if message.product_id == product.prod_id  && message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                i+=1
            }
            
        }
        
        cell = chargeBadge(cell!, badgeValue: i)
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText == "" {
            return products.count
            
        }
        else {
            return countProduct
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "fromtable", sender: self)
        
        
    }
    
    
}
