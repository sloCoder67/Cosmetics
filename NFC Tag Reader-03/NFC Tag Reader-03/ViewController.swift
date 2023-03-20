//
//  ViewController.swift
//  NFC Tag Reader-03
//
//  Created by User on 3/16/23.
//

import UIKit
import CoreNFC  // NFC Framework is needed to read NFC tags
// Note:  You must add "Near Field Communication Tag Reading" to the project capabilities
// Note: You must also add "Privacy - NFC Scan Usage" to the info.plist Property List and include a "String" description for the user like "this app uses NFC Scanning to retrieve product information"

// Note: NFCNDEFReaderSessionDelegate must be added to the class to read a NFC Tag's NDEF messages
class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    var clockTicks = 0
    var myTimer = Timer()
    
    var trackExpiration: Int = 0 // This variable is set to 0 until the user has been asked whether they want to track the expiration, if want to track it, this variable is set to 1, if they don't want to track it, this variable is set to 2
    @IBOutlet weak var myNFCText: UITextView!   // A text field to display Text from a NFC Tag
    @IBOutlet weak var myExpirationText: UITextView! // A text field to display expiration messages
    
    @IBOutlet weak var myScanButton: UIButton!  // A button to trigger our NFC reader session
    @IBAction func myScanButton(_ sender: Any) {
        startNDEFSession()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adding rounded corners to our button and text views
//        myScanButton.layer.cornerRadius = 25.0 // adding rounded corners to the button,set corner radius by value
        myScanButton.layer.cornerRadius = myScanButton.frame.height/4 // adding rounded corners, set corner radius by proportion
//        myNFCText.layer.cornerRadius = myNFCText.frame.height/14 // set corner radius by proportion
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myTimer.invalidate()     // stop timer
        myTimer = Timer.scheduledTimer(withTimeInterval: 0.33, repeats: false){_ in
            self.startNDEFSession()}
//        speechService.getVoicesPossible() // uncomment if you want to have all voices possible printed (for you to consider)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() //Dispose of any resources that can be recreated
    }
    
   let speechService = SpeechService() // an instance of our speech service is needed here to use it

    /* Read a NFC Tag's NDEF Text Message */
    var ndefReaderSession: NFCNDEFReaderSession?   // A delegate for the NDEF reader sesison
    var word = "None"
    func startNDEFSession(){
        /* 1. Initialize the NDEF reading session */
        self.ndefReaderSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: false) // set to true to stop searching for NFC tags as soon as 1 is detected
        
        /* 2 (optional). Display & speak a custom message to user */
        let myAlertmessage = "Hold the top of the iPhone to your product"
        self.ndefReaderSession?.alertMessage = "\(myAlertmessage)"
        speechService.say(myAlertmessage)
        speechService.addedPause = 0.5   // add 1/2 second before speaking the upcomming text
        speechService.say("Tap the bottom of the screen when you are finished")
        
        /* 3. Begin the reading session */
        self.ndefReaderSession?.begin()
    }

    /* 4A. A callback function that is called when the NDEF reader session becomes active */
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print ("NDEF reading session begun")
    }
    
    /* 4B. A callback function to handle a NDEF reader session error */
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NDEF reading session was invalidated: \(error.localizedDescription)")
        speechService.say("Session finished")
        speechService.addedPause = 0.5   // add 1/2 second before speaking the upcomming text
        speechService.say("Tap the bottom of the screen if you want to restart")
    }
    
    /* 4C. A callback function to handle reading of NDEF Text from the NFC tag */
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print ("Connecting to TAG")
        var resultArray = ["","","","","",""] // empty 6 element array of strings to hold the text that is read in (we will probably only use 2 of these elements)

        print("message content = \(messages)") // For debugging, print the contents of messages.
        // Note: messages is an array of NFCNDEFMessages in which each element holds each scan we perform before the NFC Session is invalidated (i.e. termminated)
        // So if in the we set invalidateAfterFirstRead to true in the above function, we will only have one element in this array messages[0]
        
        // Furthermore, messages[0].records is an array of NFCNDEFPayloads. This is an array because NDEF cards can contain multiple payloads.
        // Each payload contains 4 items:
        // A. an identifier, B. the datatype, C. the typeNameFormat and D. a payload (we are only concerned about payload) which is an object of type "data" so by converting data to string, we have our message
        
        let TotalNumberOfElements = messages[0].records.count
        var elementNumber = 0
        for payload in messages[0].records{
            if elementNumber < TotalNumberOfElements{
                resultArray[elementNumber] += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8) ?? "utf8 format not supported" // if the text that is read is utf8 format, assign it to our variable named readResult AND if it in not utf8 format print this error
                print("elementNumber = \(elementNumber) TotalNumberOfElements = \(TotalNumberOfElements)")
                print ("resultArray = \(resultArray[elementNumber])")
                elementNumber += 1
            }
            else{
                print ("loop/array error: elementNumber is not less than TotalNumberOfElements")
            }
        }
        
        /* 5. assign the first element in our resultArray to our text field and voice over */
        // Note: Apple requires you to use a dispatchQue to make this assignment, you can't assign the result directly to a UI elelment, like a label
        DispatchQueue.main.async{
            self.myNFCText.text = resultArray[1]    // assign the text that has been read to our text field
            self.speechService.say(resultArray[1])
            self.myExpirationText.text = ""
        }
        /* 6. assign the 2nd element in our resultArray to a integer variable */
        let expirationFlag = Int(resultArray[0])!
        if (expirationFlag > 0) {
            print ("expirationFlag = 1")
            
            // trackExpiration is set to 0 until the user has been asked whether they want to track the expiration, if want to track it, this variable is set to 1, if they don't want to track it, this variable is set to 2
            if (trackExpiration == 1){
                DispatchQueue.main.async{
                    self.myExpirationText.text = "This product expires in 89 days"    
                    self.speechService.addedPause = 1.0
                    self.speechService.say("This product expires in 89 days")
                }
            }
            if (trackExpiration == 0){
                DispatchQueue.main.async{
                    self.myExpirationText.text = "Beauty Tip: Any mascara expires 90 days after after its first opened"
                    self.speechService.addedPause = 1.0
                    self.speechService.say("Did you know that any mascara expires 90 days after its first opened?")
                    
//                    self.speechService.addedPause = 1.0
//                    self.speechService.say("Would you like to set a reminder to replace this product in 90 days?")
//
//                    self.speechService.addedPause = 4.0
//                    self.speechService.say("Okay")
//                    self.speechService.say("Got it")
                    self.speechService.addedPause = 1.0
                    self.speechService.say("I'll track the expiration of this product for you")
                    
                }
                trackExpiration = 1
            }

        }
    }
}
