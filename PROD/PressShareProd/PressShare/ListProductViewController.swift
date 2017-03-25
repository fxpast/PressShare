//
//  ListProductViewController
// PressShare
//
// Description : List of products
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo: Liste  : optimiser le chargement des photos : https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift


import Foundation
import UIKit
import MapKit

class ListProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var IBSegment: UISegmentedControl!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    
    var IBLogout: UIBarButtonItem!
    var IBAddProduct: UIButton!
    var IBSearch: UISearchBar!
    
    var products = [Product]()
    var productsTmp = [Product]()
    var aProduct:Product!
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var isUser = false //touch on blue user pin
    var typeListe = 0 //Map :0, MyList :1, Historical:2
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    var searchText = ""
    let refreshControl = UIRefreshControl()
    
    var frameTableView: CGRect!
    var rowHeightTableView: CGFloat!
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        IBAddProduct = UIButton()
        IBAddProduct.setImage(#imageLiteral(resourceName: "addButton"), for: UIControlState())
        IBAddProduct.addTarget(self, action: #selector(actionEpingle(_:)), for: UIControlEvents.touchUpInside)
        IBAddProduct.tag = 999
        IBAddProduct.sizeToFit()
        view.addSubview(IBAddProduct)
        
        if config.level <= 0 {
            IBAddProduct.isEnabled = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        config.isReturnToTab = false
        
        navigationController?.tabBarItem.title = translate.message("list")
        if let _ = lat, let _ = lon {
            IBLogout = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(actionLogout(_:)))
            IBAddProduct.isEnabled = false
            typeListe = 0
        }
        else if isUser == false {
            IBLogout = UIBarButtonItem.init(image: #imageLiteral(resourceName: "eteindre"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionLogout(_:)))
        }
        else {
            IBLogout = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(actionLogout(_:)))
            IBAddProduct.isEnabled = false
            
        }
        
        navigationItem.leftBarButtonItem = IBLogout
        
        IBSegment.setTitle(translate.message("list"), forSegmentAt: 0)
        IBSegment.setTitle(translate.message("mylist"), forSegmentAt: 1)
        IBSegment.setTitle(translate.message("historical"), forSegmentAt: 2)
        
        if typeListe == 0 {
            navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        }
        else if typeListe == 1 {
            navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        }
        else if typeListe == 2 {
            navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        if  IBTableView == nil {
            
            runActivity()
            
            myQueue.cancelAllOperations()
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBTableView = UITableView()
                            self.IBTableView.frame = self.frameTableView
                            self.IBTableView.rowHeight = self.rowHeightTableView
                            self.IBTableView.backgroundColor = UIColor.init(red: 1.00247 , green: 0.883336, blue: 0.698204, alpha: 1)
                            self.IBTableView.dataSource = self
                            self.IBTableView.delegate = self
                            self.IBTableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
                            self.IBTableView.contentMode = .scaleAspectFit
                            
                            self.view.addSubview(self.IBTableView)
                            
                            self.refreshControl.addTarget(self, action: #selector(self.actionByRefreshCtrl(_:)), for: .valueChanged)
                            self.IBTableView.addSubview(self.refreshControl)
                            self.refreshControl.isHidden = true
                            
                            
                            self.view.bringSubview(toFront: self.view.viewWithTag(999)!)
                            self.view.bringSubview(toFront: self.IBAddProduct)
                            
                            self.initData()
                            
                        }
                        
                    }
                }
                
                self.customOpeation.start()
                
            }
            
        }
        else {
       
            refreshControl.addTarget(self, action: #selector(actionByRefreshCtrl(_:)), for: .valueChanged)
            IBTableView.addSubview(refreshControl)
            refreshControl.isHidden = true
            
            IBAddProduct.frame = CGRect(origin: CGPoint.init(x: IBTableView.frame.size.width-IBAddProduct.frame.size.width*2, y: IBTableView.frame.size.height), size: IBAddProduct.frame.size)
            
            view.bringSubview(toFront: view.viewWithTag(999)!)
            view.bringSubview(toFront: IBAddProduct)
            
            initData()
            
        }
        
        
        if config.mess_badge > 0 {
            
            tabBarController?.tabBar.items![1].badgeValue = "\(config.mess_badge!)"
            UIApplication.shared.applicationIconBadgeNumber = config.mess_badge
        }
        else {
            tabBarController?.tabBar.items![1].badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        IBTableView.dataSource = nil
        IBTableView.delegate = nil
        IBTableView.removeFromSuperview()
        IBTableView = nil
 
    }
    
    
    private func initData() {
        
        if config.product_maj == true || config.product_add == true {
            refreshData()
            config.product_maj = false
            config.product_add = false
        }
        else if searchText == "" {
         
            IBSegment.selectedSegmentIndex = typeListe
            actionSegment(self)
        }
        else {
            view.bringSubview(toFront: view.viewWithTag(444)!)
            view.bringSubview(toFront: IBSearch)
        }
     
        frameTableView = IBTableView.frame
        rowHeightTableView = IBTableView.rowHeight
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromtable" {
            
            if let thisProduct = aProduct {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductTableViewContr
                
                controller.aProduct = thisProduct
                controller.typeListe = typeListe
                controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: (controller.aProduct!.prod_imageUrl)), 1)!
                
            }
            
        }
        
    }
    
    @IBAction func actionButtonSearch(_ sender: Any) {
        
        if IBSearch == nil {
            
            IBSearch = UISearchBar.init(frame: CGRect.init(origin: IBTableView.frame.origin, size: CGSize.init(width: IBTableView.frame.size.width, height: 40)))
            IBSearch.delegate = self
            IBSearch.tag = 444
            view.addSubview(IBSearch)
            IBSearch.placeholder = translate.message("product")
            IBSearch.becomeFirstResponder()
            
       
        }
        else {
           desallocSearch()
        }
        
        
    }
    
    @IBAction func actionEpingle(_ sender: AnyObject) {
        
        aProduct = nil
        performSegue(withIdentifier: "fromtable", sender: self)
    }
    

    
    private func desallocSearch() {
        
        searchText = ""
        IBSearch.removeFromSuperview()
        IBSearch.delegate = nil
        IBSearch = nil
    }
    
    @IBAction func actionSegment(_ sender: Any) {
        
        if IBSegment.selectedSegmentIndex == 0 {
            
            runActivity()
            
            if searchText != "" {
                desallocSearch()
            }
            
            typeListe = 0
            
            batchChargeData()
            
        }
        else if IBSegment.selectedSegmentIndex == 1 {
            
            runActivity()
            
            if searchText != "" {
                desallocSearch()
            }
            
            typeListe = 1
        
            if let _ = Products.sharedInstance.productsUserArray {
                batchChargeData()
            }
            else {
                refreshData()
            }
        
            
        }
        else if IBSegment.selectedSegmentIndex == 2 {
            
            runActivity()
            
            if searchText != "" {
                desallocSearch()
            }
            
            typeListe = 2
            
            if let _ = Products.sharedInstance.productsTraderArray {
                batchChargeData()
            }
            else {
                refreshData()
            }
        }
        
    }
    
   
    
    private func batchChargeData() {
        
        
        products.removeAll()
        IBTableView.reloadData()
        runActivity()
        
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    self.chargeData()
                }
            }
            
            self.customOpeation.start()
            
        }
        
    }
    
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("userDico")!.path
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch  {
            print("error ", filePath)
        }
        

        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func runActivity() {
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        view.bringSubview(toFront: self.view.viewWithTag(55)!)
        view.bringSubview(toFront: IBActivity)

    }
    
    private func stopActivity() {
        
        IBActivity.stopAnimating()
        refreshControl.endRefreshing()
        IBActivity.isHidden = true
        refreshControl.isHidden = true
        
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("carte_liste", self)
        
    }
    
    
    @IBAction func actionByRefreshCtrl(_ sender: AnyObject) {
        
        refreshControl.isHidden = false
        refreshControl.beginRefreshing()
        refreshData()
        
    }
    
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        IBTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        runActivity()
        
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
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            searchBar.endEditing(true)
                        }
                        
                    }
                    else {
                        self.searchData(searchText)
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.stopActivity()
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
    
    
    private func chargeData() {
        
        var minimumLon = Double()
        var maximumLon = Double()
        var minimumLat = Double()
        var maximumLat = Double()
        
        if let _ = lat, let _ = lon {
            
            //Setting search Area
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, config.distanceProduct, config.distanceProduct)
            
            minimumLon = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta
            maximumLon = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta
            minimumLat = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta
            maximumLat = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta
            
        }
        
        
        var theProducts = [[String:AnyObject]]()
      
        
        if typeListe == 0 {
            theProducts = Products.sharedInstance.productsArray
           
        }
        else if typeListe == 1 {
            theProducts = Products.sharedInstance.productsUserArray
           
        }
        else if typeListe == 2 {
            theProducts = Products.sharedInstance.productsTraderArray
            
        }
        
        BlackBox.sharedInstance.performUIUpdatesOnMain {
            self.navigationItem.title = "\(self.config.user_pseudo!) (\(self.config.user_id!))"
        }
        
        for prod in theProducts {
            
            if customOpeation.isCancelled {
                break
            }
            
            var produ = Product(dico: prod)
            
            
            if typeListe == 0 {
                
                if let _ = lat, let _ = lon {
                    if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                        produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                        products.append(produ)
                        
                    }
                }
                else  {
                    produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                    products.append(produ)
                    
                }
                
            }
            else if typeListe == 1  ||  typeListe == 2 {
                produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                products.append(produ)
                
            }
            
        }
        
        BlackBox.sharedInstance.performUIUpdatesOnMain {
            self.IBTableView.reloadData()
            if self.products.count == 0 {
                self.stopActivity()
            }
        }
        
        
    }
    
    private func refreshData()  {
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            IBTableView.reloadData()
            return
        }
        
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
                        UIApplication.shared.applicationIconBadgeNumber = i
                        
                    }
                    else {
                        
                        self.tabBarController?.tabBar.items![1].badgeValue = nil
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                   
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.stopActivity()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
        if config.product_maj == true {
            
            MDBProduct.sharedInstance.getProduct(aProduct.prod_id, completionHandlerProduct: { (success, productArray, errorString) in
                
                if success {
                    
                    for prod in productArray! {
                        
                        var produ = Product(dico: prod)
                        produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                        self.aProduct.prod_id = produ.prod_id
                        self.aProduct.prod_by_cat = produ.prod_by_cat
                        self.aProduct.prod_by_user = produ.prod_by_user
                        self.aProduct.prod_comment = produ.prod_comment
                        self.aProduct.prod_date = produ.prod_date
                        self.aProduct.prod_etat = produ.prod_etat
                        self.aProduct.prod_hidden = produ.prod_hidden
                        self.aProduct.prod_imageUrl = produ.prod_imageUrl
                        self.aProduct.prod_latitude = produ.prod_latitude
                        self.aProduct.prod_longitude = produ.prod_longitude
                        self.aProduct.prod_mapString = produ.prod_mapString
                        self.aProduct.prod_nom = produ.prod_nom
                        self.aProduct.prod_prix = produ.prod_prix
                        self.aProduct.prod_echange = produ.prod_echange
                        self.aProduct.prod_tempsDispo = produ.prod_tempsDispo
                        self.aProduct.prodImageOld = produ.prodImageOld
                        
                        break
                        
                    }
                    
                    for i in 0...self.products.count-1 {
                        let prod = self.products[i]
                        if prod.prod_id == self.aProduct.prod_id {
                            self.products[i] = self.aProduct
                            break
                        }
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                        
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.stopActivity()
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
                
            })
            
        }
        else {
            
            products.removeAll()
            IBTableView.reloadData()
            
            if typeListe == 1 {
                
                //Menu MaListe
                MDBProduct.sharedInstance.getProductsByUser(config.user_id) { (success, productArray, errorString) in
                    
                    if success {
                        
                        Products.sharedInstance.productsUserArray = productArray
                        self.chargeData()
                        
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.stopActivity()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                }
                
                
            }
            else if typeListe == 0 {
                //Menu Carte
               
                MDBProduct.sharedInstance.getProductsByCoord(config.user_id, minLon: config.minLongitude, maxLon: config.maxLongitude , minLat: config.minLatitude, maxLat: config.maxLatitude) { (success, productArray, errorString) in
                    
                    if success {
                        
                        Products.sharedInstance.productsArray = productArray
                        self.chargeData()
                        
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                }
                
                
            }
            else if typeListe == 2 {
                
                //Menu Historique
                MDBProduct.sharedInstance.getProductsByTrader(config.user_id) { (success, productArray, errorString) in
                    
                    if success {
                        
                        Products.sharedInstance.productsTraderArray = productArray
                        self.chargeData()
                
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.stopActivity()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                }
                
                
            }
            
            
        }
        
        
    }
    
    private func searchData(_ str:String) {
        
        productsTmp.removeAll()
        
        for prod in products {
            
            if customOpeation.isCancelled {
                break
            }
            
            let nom = prod.prod_nom.lowercased()
            
            if nom.contains(str.lowercased()) {
                productsTmp.append(prod)
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.IBTableView.reloadData()
            }
            
        }
        
    }
    
    
    //MARK: Table View Controller data source
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let product =  products[indexPath.row]
      
        guard config.user_id == product.prod_by_user && product.prod_closed == false && product.prod_hidden == false else {
            displayAlert(translate.message("error"), mess: translate.message("deletionFor"))
            return
        }
        
        MDBProduct.sharedInstance.setDeleteProduct(product) { (success, errorString) in
            
            if success {
                
                let prod1 =  self.products[indexPath.row]
                var i = 0
                
                if self.typeListe == 1 {
                    
                    for produ in Products.sharedInstance.productsUserArray {
                        i+=1
                        let prod2 = Product(dico: produ)
                        if (prod2.prod_id == prod1.prod_id) {
                            self.products.remove(at: indexPath.row)
                            
                            Products.sharedInstance.productsUserArray.remove(at: i-1)
                            break
                        }
                    }
                    
                }
                else if self.typeListe == 2 {
                    for produ in Products.sharedInstance.productsTraderArray {
                        i+=1
                        let prod2 = Product(dico: produ)
                        if (prod2.prod_id == prod1.prod_id) {
                            self.products.remove(at: indexPath.row)
                            
                            Products.sharedInstance.productsTraderArray.remove(at: i-1)
                            break
                        }
                    }
                    
                }
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
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
            badge.badgeValue = ""
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
            product =  products[indexPath.row]
        }
        else {
            product =  productsTmp[indexPath.row]
        }
        
        var firstlastname = UILabel()
        var photo = UIImageView()
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                firstlastname = view as! UILabel
                firstlastname.text =  "\(product.prod_nom) (user:\(product.prod_by_user))"
             
                if product.prod_closed == true  {
                    firstlastname.textColor = UIColor.gray
                }
                else if product.prod_closed == false && product.prod_hidden == false {
                    firstlastname.textColor = UIColor.black
                }
                else if product.prod_closed == false && product.prod_hidden == true {
                    firstlastname.textColor = UIColor.blue
                }
            }
            else if view.tag == 88 {
                photo = view as! UIImageView
                
                if product.prod_imageUrl == "" {
                     photo.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                     photo.image = BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: product.prod_imageUrl)
                }
            }
            
        }
        
        firstlastname.frame = CGRect.init(origin: CGPoint.init(x: photo.frame.size.width + 10, y: firstlastname.frame.origin.y), size: firstlastname.frame.size)
        
        
        
        var i = 0
        for mess in Messages.sharedInstance.MessagesArray {
            
            let message = Message(dico: mess)
            
            if message.product_id == product.prod_id  && message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                i+=1
            }
            
        }
        
        cell = chargeBadge(cell!, badgeValue: i)
        
     
        if indexPath.row == 0 {
            stopActivity()
        }
        
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchText == "" {
            return products.count
            
        }
        else {
            return productsTmp.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchText == "" {
            aProduct =  products[indexPath.row]
        }
        else {
            aProduct =  productsTmp[indexPath.row]
        }
        
        performSegue(withIdentifier: "fromtable", sender: self)
        
        
    }
    
    
}
