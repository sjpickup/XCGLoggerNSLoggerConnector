//
//  XCGLoggerSupport.swift
//  adds support for NSLogger in XCGLogger
//
//  add the line below to the init code in appDelegate
//  log.addLogDestination(XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier"))
//
//  New custom image level, accepts UIImage
//  Label is default set to "image", can be used to indicate e.g. source ("facebook", "imgur")
//  -- log.image(image)
//  -- log.image(image, label: "facebook")
//
//  All report levels support now UIImage
//  -- log.info(image)
//
//  New custom text report level to group functional reports
//  log.customLabel("Userdata: \(db.user)", label: "Database")
//
//  Created by Markus on 11/17/15.
//  Copyright © 2015 Markus Winkler. All rights reserved.
//

import XCGLogger
import NSLogger

public class XCGNSLoggerLogDestination: XCGBaseLogDestination {

    // Report levels are different in NSLogger (0 = most important, 4 = least important)
    // XCGLogger level needs to be converted to use the bonjour app filtering in a meaningful way
    private func convertLogLevel(level:XCGLogger.LogLevel) -> Int32 {
        switch(level) {
        case .Severe:
            return 0
        case .Error:
            return 1
        case .Warning:
            return 2
        case .Info:
            return 3
        case .Debug:
            return 4
        case .Verbose:
            return 5
        case .None:
            return 3
        }
    }

    public override func output(logDetails: XCGLogDetails, text: String) {

        switch(logDetails.logLevel) {
        case .None:
            return
        default:
            break
        }

        var arr = logDetails.fileName.componentsSeparatedByString("/")
        var fileName = logDetails.fileName
        if let last = arr.popLast() {
            fileName = last
        }

        LogMessage_va(logDetails.logLevel.description, convertLogLevel(logDetails.logLevel), "[\(fileName):\(logDetails.lineNumber)] -> \(logDetails.functionName) : \(logDetails.logMessage)",getVaList([]))
    }
}

public extension XCGLogger {

    // declared here again for performance reasons
    private func convertLogLevel(level:LogLevel) -> Int32 {
        switch(level) {
        case .Severe:
            return 0
        case .Error:
            return 1
        case .Warning:
            return 2
        case .Info:
            return 3
        case .Debug:
            return 4
        case .Verbose:
            return 5
        case .None:
            return 3
        }
    }

    private func sendImageToNSLogger(image: UIImage?, level: LogLevel, label: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        // check if image is valid, otherwise display error
        if let image: UIImage = image {
            LogImageData(label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), UIImagePNGRepresentation(image))
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Invalid Image: \(image)"})
        }
    }

    public func customLabel(@autoclosure closure: () -> UIImage?, label: String = "image", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        // check if image is valid, otherwise display error
        var arr = fileName.componentsSeparatedByString("/")
        var fileName2 = fileName
        if let last = arr.popLast() {
            fileName2 = last
        }
        let level = LogLevel.None
        if let image: UIImage = closure() {
            LogImageData(label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), UIImagePNGRepresentation(image))
            LogMessage_va(label, convertLogLevel(level), "[\(fileName2):\(lineNumber)] -> \(functionName) : \(image)",getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Invalid Image: \(closure())"})
        }
    }

    public func customLabel(@autoclosure closure: () -> String?, label: String = "string", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.None
        var arr = fileName.componentsSeparatedByString("/")
        var fileName2 = fileName
        if let last = arr.popLast() {
            fileName2 = last
        }

        if let message = closure() {
            LogMessage_va(label, convertLogLevel(level), "[\(fileName2):\(lineNumber)] -> \(functionName) : \(message)",getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "[\(label)] \(message)"})
        }
        else
        {
            LogMessage_va(label, convertLogLevel(level), "[\(fileName2):\(lineNumber)] -> \(functionName) : nil",getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "[\(label)] nil"})
        }
    }

    public func verbose(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Verbose
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func debug(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Debug
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func info(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Info
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func warning(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Warning
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func error(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Error
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func severe(@autoclosure closure: () -> UIImage?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        let level = LogLevel.Severe
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

}