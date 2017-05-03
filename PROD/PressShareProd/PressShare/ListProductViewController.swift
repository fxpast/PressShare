//
//  ListProductViewController
// PressShare
//
// Description : List of products
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit
import MapKit

class ListProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var IBSegment: UISegmentedControl!
    @IBOutlet weak var IBTableView: UITableView!
    
    var IBLogout: UIBarButtonItem!
    var IBAddProduct: UIButton!
    var IBSearch: UISearchBar!
    
    var timerBadge : Timer!
    
    var products = [Product]()
    var productsTmp = [Product]()
    var pendingOperations:PendingOperations!
    
    var aProduct:Product!
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var isUser = false //touch on blue user pin
    var typeListe = 0 //Map :0, MyList :1, Historical:2
    var currentLine = 0
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    var searchText = ""
    let refreshControl = UIRefreshControl()

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
        
        pendingOperations = PendingOperations()
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
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        refreshControl.addTarget(self, action: #selector(actionByRefreshCtrl(_:)), for: .valueChanged)
        IBTableView.addSubview(refreshControl)
        refreshControl.isHidden = true
        
        IBAddProduct.frame = CGRect(origin: CGPoint.init(x: IBTableView.frame.size.width-IBAddProduct.frame.size.width*2, y: IBTableView.frame.size.height), size: IBAddProduct.frame.size)
        
        view.bringSubview(toFront: view.viewWithTag(999)!)
        view.bringSubview(toFront: IBAddProduct)
        
        initData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cancelAllOperations()
        pendingOperations = nil
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    private func initData() {
        
        if searchText == "" {
            
            IBSegment.selectedSegmentIndex = typeListe
            loadSegment()
        }
        else {
            view.bringSubview(toFront: view.viewWithTag(444)!)
            view.bringSubview(toFront: IBSearch)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromtable" {
            
            if let thisProduct = aProduct {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductTableViewContr
                
                controller.aProduct = thisProduct
                controller.typeListe = typeListe
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
        
        currentLine = 0
        loadSegment()
        
    }
    
    
    private func loadSegment() {
        
        if IBSegment.selectedSegmentIndex == 0 {
            
            if searchText != "" {
                desallocSearch()
            }
            
            typeListe = 0
            
            batchChargeData()
            
        }
        else if IBSegment.selectedSegmentIndex == 1 {
            
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
        
        cancelAllOperations()
        products.removeAll()
        productsTmp.removeAll()
        IBTableView.reloadData()
        
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
    
    private func stopActivity() {
        refreshControl.endRefreshing()
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
    
    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            BlackBox.sharedInstance.checkBadge(menuBar: tabBarController!)
        }
        
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
            
            let produ = Product(dico: prod)
            
            if typeListe == 0 {
                
                if let _ = lat, let _ = lon {
                    if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                        
                        products.append(produ)
                    }
                }
                else  {
                    
                    products.append(produ)
                }
                
            }
            else if typeListe == 1  ||  typeListe == 2 {
                
                products.append(produ)
            }
            
        }
        
        BlackBox.sharedInstance.performUIUpdatesOnMain {
            self.IBTableView.reloadData()
            if self.products.count > 0 {
                let index = IndexPath.init(row: self.currentLine, section: 0)
                self.IBTableView.scrollToRow(at: index, at: .bottom , animated: false)
            }
            
            if self.products.count == 0 {
                self.stopActivity()
            }
        }
        
        
    }
    
    private func refreshData()  {
        
        cancelAllOperations()
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            IBTableView.reloadData()
            return
        }
        
        cancelAllOperations()
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
        
        let product:Product
        
        if searchText == "" {
            product =  products[indexPath.row]
            
        }
        else {
            product =  productsTmp[indexPath.row]
            
        }
        
        switch product.state {
            
        case .Filtered: break
        case .Failed: break
        case .New, .Downloaded:
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperationsForPhotoRecord(product, indexPath)
                
            }
            
        }
        
        let firstlastname = cell?.contentView.viewWithTag(99) as! UILabel
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
        
        
        let photo = cell?.contentView.viewWithTag(88) as! UIImageView
        photo.image = product.prod_image
        config.heightImage = photo.frame.size.height
        config.widthImage = photo.frame.size.width
        
        
        
        firstlastname.frame = CGRect.init(origin: CGPoint.init(x: photo.frame.size.width + 10, y: firstlastname.frame.origin.y), size: firstlastname.frame.size)
        
        
        var i = 0
        if Messages.sharedInstance.MessagesArray != nil {
            
            for mess in Messages.sharedInstance.MessagesArray {
                
                let message = Message(dico: mess)
                
                if message.product_id == product.prod_id  && message.destinataire == self.config.user_id && message.deja_lu == false {
                    i+=1
                }
                
            }
            
        }
        
        cell = chargeBadge(cell!, badgeValue: i)
        
        
        if indexPath.row == 0 {
            stopActivity()
        }
        
        currentLine = indexPath.row
        return cell!
        
    }
    
    
    private func startOperationsForPhotoRecord(_ product:Product, _ indexPath:IndexPath) {
        
        switch product.state {
        case .New:
            startDownloadForRecord(product, indexPath)
            
        case .Downloaded:
            startFiltrationForRecord(product, indexPath)
            
        default: break
        }
        
    }
    
    
    private func startDownloadForRecord(_ product:Product, _ indexPath:IndexPath) {
        
        
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImageDownloader.init(product: product)
        
        downloader.completionBlock = {
            
            if downloader.isCancelled {
                return
            }
            
            if self.searchText == "" {
                
                
                self.products[indexPath.row].state = downloader.product.state
                self.products[indexPath.row].prod_imageUrl = downloader.product.prod_imageUrl
                self.products[indexPath.row].prod_image = downloader.product.prod_image
                
            }
            else {
                
                
                self.productsTmp[indexPath.row].state = downloader.product.state
                self.productsTmp[indexPath.row].prod_imageUrl = downloader.product.prod_imageUrl
                self.productsTmp[indexPath.row].prod_image = downloader.product.prod_image
                
                
            }
            
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                if downloader.isCancelled {
                    return
                }
                
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                
                if downloader.isCancelled {
                    return
                }
                
                self.IBTableView.reloadRows(at: [indexPath], with: .fade)
                
            }
            
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
        
        
    }
    
    private func startFiltrationForRecord(_ product:Product, _ indexPath:IndexPath) {
        
        
        if let _ = pendingOperations.filtrationsInProgress[indexPath] {
            return
        }
        
        let filterer = ImageFiltration.init(product: product)
        
        filterer.completionBlock = {
            
            if filterer.isCancelled {
                return
            }
            
            
            if self.searchText == "" {
                
                
                self.products[indexPath.row].state = filterer.product.state
                self.products[indexPath.row].prod_image = filterer.product.prod_image
                
            }
            else {
                
                self.productsTmp[indexPath.row].state = filterer.product.state
                self.productsTmp[indexPath.row].prod_image = filterer.product.prod_image
                
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                if filterer.isCancelled {
                    return
                }
                
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                
                if filterer.isCancelled {
                    return
                }
                self.IBTableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        }
        
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.searchText == "" {
            
            
            return products.count
            
        }
        else {
            
            return productsTmp.count
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if self.searchText == "" {
            
            aProduct =  products[indexPath.row]
            
        }
        else {
            
            aProduct =  productsTmp[indexPath.row]
            
        }
        
        
        if aProduct.state == .Filtered || aProduct.state == .Failed {
            
            performSegue(withIdentifier: "fromtable", sender: self)
            
        }
        
        
    }
    
    //MARK: Scrollview delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        suspendAllOperations()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        loadImagesForOnscreenCells()
        resumeAllOperations()
        
    }
    
    private func suspendAllOperations() {
        
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
        
    }
    
    
    private func cancelAllOperations() {
        
        pendingOperations.downloadQueue.cancelAllOperations()
        pendingOperations.filtrationQueue.cancelAllOperations()
        
    }
    
    
    private func resumeAllOperations() {
        
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
        
        //1 Start with an array containing index paths of all the currently visible rows in the table view.
        if let pathsArray = IBTableView.indexPathsForVisibleRows {
            
            //2 Construct a set of all pending operations by combining all the downloads in progress + all the filters in progress.
            let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            
            //3 Construct a set of all index paths with operations to be cancelled. Start with all operations, and then remove the index paths of the visible rows. This will leave the set of operations involving off-screen rows.
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths as Set<IndexPath>)
            
            
            //4 Construct a set of index paths that need their operations started. Start with index paths all visible rows, and then remove the ones where operations are already pending.
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations as Set<IndexPath>)
            
            //5 Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
            for indexPath in toBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                
                let indexPath = indexPath as IndexPath
                
                var recordToProcess:Product
                
                if self.searchText == "" {
                    
                    recordToProcess = self.products[indexPath.row]
                    
                }
                else {
                    
                    recordToProcess = self.productsTmp[indexPath.row]
                    
                }
                
                startOperationsForPhotoRecord(recordToProcess, indexPath)
                
                
            }
            
        }
        
    }
    
    
}
