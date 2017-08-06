//
//  ViewController.swift
//  Mindvalley Test
//
//  Created by Mobile World on 7/27/17.
//  Copyright © 2017 Coca Denisa. All rights reserved.
//


import UIKit
import Alamofire
import AlamofireImage
import Toast_Swift
import CellAnimator

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var checkedRows=Set<NSIndexPath>()
    
    var data: Array<Dictionary<String,Any>> = [];
    var imageArray: Array<UIImage> = []
    var chkImageArray:Array<Bool> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        startConnection()
    }
    func startConnection(){
        let urlString = "http://pastebin.com/raw/wgkJgazE"
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                print(usableData) //JSONSerialization
                do {
                                        // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Array<Dictionary< String, Any>>
                    
                                        // Access specific key with value of type String
                    print(json)
                    self.data += json
                    self.tableView.reloadData()
                    self.loadImages();
                } catch {
                                        // Something went wrong
                    
                }

            }
            else if error != nil {
                print(error as Any)
            }
        }
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID:NSString = "cell";
        let cell=tableView.dequeueReusableCell(withIdentifier: cellID as String, for: indexPath)
        
        let label:UILabel = cell.viewWithTag(101) as! UILabel;
        label.text = "ID: "+(data[indexPath.row]["id"] as! String)
        let labe2:UILabel = cell.viewWithTag(102) as! UILabel;
        labe2.text = "Created At: "+(data[indexPath.row]["created_at"] as! String)
        let labe3:UILabel = cell.viewWithTag(103) as! UILabel;
        let likes:Int = data[indexPath.row]["likes"] as! Int
        labe3.text = "Likes " + String(describing: likes)
        
        let image:UIImageView = cell.viewWithTag(100) as! UIImageView
        image.image = imageArray[indexPath.row]
        
        let indicator:UIActivityIndicatorView = cell.viewWithTag(110) as! UIActivityIndicatorView
        indicator.isHidden = chkImageArray[indexPath.row]
        indicator.startAnimating()
        return cell;
    }
    func loadImages(){
        for i in 0..<self.data.count{
            imageArray.append(getImageWithColor(color: UIColor.white, size: CGSize.init(width: 100, height: 100)))
            chkImageArray.append(false)
            let urldict:Dictionary<String,String> = self.data[i]["urls"] as! Dictionary
            let url = URL(string: urldict["raw"]!)
            
            Alamofire.request(url!).responseImage { response in
                if let image = response.result.value {
                    DispatchQueue.main.async {
                        self.imageArray[i] = image
                        let indexPath = IndexPath(item: i, section: 0)
                        self.chkImageArray[i] = true;
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)                        
                    }
                }
            }
            
        }
    }
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        for i in ( 0 ..< items.count ){
//            checkList[i] = true;
//        }
//        checkList[indexPath.row] = false;
//        tableView.reloadData();
//        Globals.candle_time = self.items[indexPath.row];
        self.view.hideToastActivity()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.data.count - 1
        if indexPath.row == lastElement {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            self.view.makeToastActivity(.center)
        }
        CellAnimator.animateCell(cell: cell, withTransform: CellAnimator.TransformCurl, andDuration: 1)
    }
}

