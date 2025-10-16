import SwiftUI
import Vexil

protocol FlagPoleItemGroup: FlagPoleItem {
    
    var items: [any FlagPoleItem] { get set }
    
}


