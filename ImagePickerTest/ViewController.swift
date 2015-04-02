//
//  ViewController.swift
//  ImagePickerTest
//
//  Created by lostin1 on 2015. 3. 19..
//  Copyright (c) 2015년 lostin. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,NSURLConnectionDataDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tapShot: UIBarButtonItem!
    var picker:UIImagePickerController? = UIImagePickerController()
    var popOver:UIPopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker?.delegate = self
        popOver?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapShotPhoto(sender: AnyObject) {
        var alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler:{(alert:UIAlertAction!) in
            self.openCamera()
        })
        
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default, handler:{(alert:UIAlertAction!) in
            self.openGallary()
        })
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{(alert:UIAlertAction!) in
            return
        })
        
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
    
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            popOver = UIPopoverController(contentViewController: alert)
            popOver!.presentPopoverFromBarButtonItem(tapShot, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else {
            self.openGallary()
        }
    }
    func openGallary() {
        picker!.sourceType =  UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else {
            popOver = UIPopoverController(contentViewController: picker!)
            popOver!.presentPopoverFromBarButtonItem(tapShot, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.uploadImage(imageView.image!)
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("picker cancel")
    }
    
    func uploadImage(image:UIImage) {

        
        //업로드할 URL객체를 생성한다.
        let uploadURL:NSURL = NSURL(string: "http://localhost:3000")!
        
        //request 오브젝트를 생성하고 옵션을 설정한다.
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: uploadURL)
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        //request.HTTPShouldHandleCookies = false
        request.timeoutInterval = 30.0
        request.HTTPMethod = "POST"
        
        let boundary:String = "content_boundaries"
        //HTTP헤더의 Content-type을 설정한다.
        let contentType:String = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let senderID = "fromID"
        let receiverID = "toID"
        let params = ["sender":senderID,"receiver":receiverID]
        
        var bodyData:NSMutableData = NSMutableData()
        let boundaryBegin:String = "--\(boundary)\r\n"
        
        for param:String in params.keys {
            let formID:String = "Content-Disposition: form-data; name=\"\(param)\"\r\n\r\n"
            let idData:String = "\(params[param]!)\r\n"
            bodyData.appendData(boundaryBegin.dataUsingEncoding(NSUTF8StringEncoding)!)
            bodyData.appendData(formID.dataUsingEncoding(NSUTF8StringEncoding)!)
            bodyData.appendData(idData.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        // 이미지 데이터 추가
        let imageData:NSData = UIImageJPEGRepresentation(image, 1.0)
        
        if imageData.length > 0 {
            let fileName = "tempImage.jpg"
            let formFileInfo:String = "Content-Disposition: form-data; name=\"imageName\"; filename=\"\(fileName)\"\r\n"
            let crNewLine:String = "\r\n"
            bodyData.appendData(boundaryBegin.dataUsingEncoding(NSUTF8StringEncoding)!)
            bodyData.appendData(formFileInfo.dataUsingEncoding(NSUTF8StringEncoding)!)
            bodyData.appendData(imageData)
            bodyData.appendData(crNewLine.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        let boundaryEnd:String = "--\(boundary)--\r\n"
        bodyData.appendData(boundaryEnd.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = bodyData
        let postLength = "\(bodyData.length)"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        let connection:NSURLConnection = NSURLConnection(request: request, delegate: self)!
        connection.start()
    }
    // MARK - NSURLConnectionDataDelegate
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        //업로드 프로그래시브바 컨트롤이 들어갈곳
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        let alert:UIAlertView = UIAlertView(title: "알림", message: "업로드가 종료되었습니다", delegate: nil, cancelButtonTitle: "확인")
        alert.show()
    }
}

