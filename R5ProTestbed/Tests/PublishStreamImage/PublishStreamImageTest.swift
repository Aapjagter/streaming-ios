//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishStreamImageTest)
class PublishStreamImageTest: BaseTest {

    var uiv : UIImageView? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection!)
        // show preview and debug info
        
        self.currentView!.attach(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PublishStreamImageTest.handleSingleTap(_:)))

        self.view.addGestureRecognizer(tap)

        
        uiv = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height-200, width: 300, height: 200))
        uiv!.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(uiv!);
        
    }

    func handleSingleTap(_ recognizer : UITapGestureRecognizer) {

        
        uiv!.image = self.publishStream?.getImage();
   
    }


}
