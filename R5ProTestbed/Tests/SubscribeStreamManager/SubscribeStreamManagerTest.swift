//
//  SubscribeStreamManagerTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/11/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeStreamManagerTest)
class SubscribeStreamManagerTest: BaseTest {
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        setupDefaultR5VideoViewController()
        
        // url format https://{streammanagerhost}:{port}/streammanager/api/1.0/event/{scopeName}/{streamName}?action=subscribe
        let urlString = "http://" + (Testbed.getParameter("host") as! String) + ":5080/streammanager/api/1.0/event/" +
            (Testbed.getParameter("context") as! String) + "/" +
            (Testbed.getParameter("stream1") as! String) + "?action=subscribe"
        
        NSURLConnection.sendAsynchronousRequest(
            URLRequest( url: URL(string: urlString)! ),
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) in
                
                if ((error) != nil) {
                    NSLog("%@", error as! NSError);
                    return;
                }
                
                //   Convert our response to a usable NSString
                let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                
                //   The string above is in JSON format, we specifically need the serverAddress value
                var json: [String: AnyObject]
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                }catch{
                    print(error)
                    return
                }
                
                if( json["serverAddress"] == nil ){
                    NSLog("No server address returned");
                    return;
                }
                
                let ip = json["serverAddress"] as! String
                
                NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, urlString, ip);
                
                //   Setup a configuration object for our connection
                let config = R5Configuration()
                config.host = ip
                config.port = Int32(Testbed.getParameter("port") as! Int)
                config.contextName = Testbed.getParameter("context") as! String
                config.`protocol` = 1;
                config.buffer_time = Testbed.getParameter("buffer_time") as! Float
                
                //   Create a new connection using the configuration above
                let connection = R5Connection(config: config)
                
                //   UI updates must be asynchronous
                DispatchQueue.main.async(execute: {
                    //   Create our new stream that will utilize that connection
                    self.subscribeStream = R5Stream(connection: connection)
                    self.subscribeStream!.delegate = self
                    self.subscribeStream?.client = self;
                    
                    self.currentView?.attach(self.subscribeStream)
                    
                    self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
                    
                    let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                    label.textAlignment = NSTextAlignment.left
                    label.backgroundColor = UIColor.lightGray
                    label.text = "Connected to: " + ip
                    self.view.addSubview(label)
                })
            }
        )
        
    }
    
}