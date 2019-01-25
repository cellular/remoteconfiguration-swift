//: Playground - noun: a place where people can play

import Foundation
import RemoteConfiguration

let url = URL(string: "https://cellular.config.de/config.json")!
let manager = Manager(url: url, currentVersion: "1.0")
