//
//  SpeechService.swift
//  NFC Tag Reader-03
//
//  Created by User on 3/18/23.
//

import UIKit
import Foundation
import AVFoundation // AV Foundation Framework is needed for speech synthesis

class SpeechService{
    
    /* Synthesize text to voice */
    let mySynthesizer = AVSpeechSynthesizer()   // create a sythesizer to convert text to voice
    
    //creating a variable "addedPause" for preUtteranceDelay outside of the function below so it value can be easily changed in the view controller using dot notaation
    var addedPause:TimeInterval = 0.0

    func say(_ whatoSay: String){
        
//        guard UIAccessibility.isVoiceOverRunning else {return} // if voice over is not turned on (which most vision imparied people have it on), just return from this function
        
        let myUtterance = AVSpeechUtterance(string: "\(whatoSay)")  // create an utterance
//        myUtterance.voice = AVSpeechSynthesisVoice(language: "en-US") // default voice
        
        myUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Nicky_en-US_compact") // favorite female voice
        
//        myUtterance.voice = AVSpeechSynthesisVoice(identifier: // favorite male voice "com.apple.ttsbundle.siri_Aaron_en-US_compact")
        
        myUtterance.rate = 0.5 // modify the speed of the speach, 0.5 seems to be a good value (range is 0.0 to 1.0)

        myUtterance.preUtteranceDelay = addedPause  // delay before this thing is said
        
        mySynthesizer.speak(myUtterance)    // dispatch the utterance to the synthesizer
        addedPause = 0.0 // set our pause back to the default of 0 added
    }
    
    func getVoicesPossible(){
        AVSpeechSynthesisVoice.speechVoices().forEach({print($0)}) // print all possible voices so you can see your options
    }


    
}
