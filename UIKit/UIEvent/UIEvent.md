### UIEvent简介

应用程序可以接收许多不同类型的事件，包括触摸事件、动作事件、远程控制事件和新闻事件。触摸事件是最常见的，它被传递到最初发生触摸的视图中。运动事件是由UIKit触发的，与Core Motion框架报告的运动事件是分开的。远程控制事件允许响应器对象接收来自外部配件或耳机的命令，这样它就可以管理音频和视频——例如，播放视频或跳到下一个音频轨道。按下事件表示与游戏控制器、AppleTV遥控器或其他有物理按钮的设备的交互。可以使用类型和子类型属性确定事件的类型。
触摸事件对象包含触摸(即屏幕上的手指)，它们与事件有某种关系。一个触摸事件对象可以包含一个或多个触摸，每个触摸都由一个UITouch对象表示。当一个触摸事件发生时，系统将它路由到适当的响应器并调用适当的方法，例如touchesBegan(_:with:)。然后响应者使用触摸来确定一个适当的行动过程。
在多点触摸序列中，UIKit在向你的应用程序传递更新的触摸数据时重用相同的UIEvent对象。你不应该保留一个事件对象或从一个事件对象返回的任何对象。如果你需要在你用来处理数据的responder方法之外保留数据，从UITouch或UIEvent对象复制数据到你的本地数据结构。
关于如何在UIKit应用程序中处理事件的更多信息，请参见UIKit应用程序的事件处理指南。

UIEvent是代表iOS系统中的一个事件,一个事件包含一个或多个的UITouch；

UIEvent类型: `open var type: UIEvent.EventType { get }`

``` swift 
extension UIEvent {

    
    public enum EventType : Int {

        
        case touches = 0 //触摸事件类型 

        case motion = 1 //摇晃事件类型 

        case remoteControl = 2 //遥控事件类型

        @available(iOS 9.0, *)
        case presses = 3 //物理按钮事件类型

        @available(iOS 13.4, *)
        case scroll = 10

        @available(iOS 13.4, *)
        case hover = 11

        @available(iOS 13.4, *)
        case transform = 14
    }

    //子事件类型
    public enum EventSubtype : Int {

        
        // available in iPhone OS 3.0
        case none = 0

        
        // for UIEventTypeMotion, available in iPhone OS 3.0
        case motionShake = 1 //摇晃 

        
        // for UIEventTypeRemoteControl, available in iOS 4.0
        case remoteControlPlay = 100 //播放

        case remoteControlPause = 101 //暂停

        case remoteControlStop = 102 //停止

        case remoteControlTogglePlayPause = 103 //播放和暂停之间切换【操作：播放或暂停状态下，按耳机线控中间按钮一下】
        case remoteControlNextTrack = 104 //下一曲【操作：按耳机线控中间按钮两下】

        case remoteControlPreviousTrack = 105 //上一曲【操作：按耳机线控中间按钮三下】

        case remoteControlBeginSeekingBackward = 106 //快退开始【操作：按耳机线控中间按钮三下不要松开】

        case remoteControlEndSeekingBackward = 107 //快退结束【操作：按耳机线控中间按钮三下到了快退的位置松开】

        case remoteControlBeginSeekingForward = 108 //快进开始【操作：按耳机线控中间按钮两下不要松开】

        case remoteControlEndSeekingForward = 109 //快进结束【操作：按耳机线控中间按钮两下到了快进的位置松开】
    }

    
    /// Set of buttons pressed for the current event 为当前事件按下的一组按钮
    /// Raw format of: 1 << (buttonNumber - 1)
    /// UIEventButtonMaskPrimary = 1 << 0
    @available(iOS 13.4, *)
    public struct ButtonMask : OptionSet {

        public init(rawValue: Int)

        
        public static var primary: UIEvent.ButtonMask { get }

        public static var secondary: UIEvent.ButtonMask { get }
    }
}

extension UIEvent.ButtonMask {

    
    /// Convenience initializer for a button mask where `buttonNumber` is a one-based index of the button on the input device 
    /// 按钮掩码的方便初始化器，其中' buttonNumber '是输入设备上按钮的基于一的索引
    /// .button(1) == .primary
    /// .button(2) == .secondary
    @available(iOS 13.4, *)
    public static func button(_ buttonNumber: Int) -> UIEvent.ButtonMask
}

@available(iOS 2.0, *)
open class UIEvent : NSObject {

    
    @available(iOS 3.0, *)
    open var type: UIEvent.EventType { get } //事件类型

    @available(iOS 3.0, *)
    open var subtype: UIEvent.EventSubtype { get } //子事件类型

    
    open var timestamp: TimeInterval { get } //事件发生时间

    
    @available(iOS 13.4, *)
    open var modifierFlags: UIKeyModifierFlags { get }

    @available(iOS 13.4, *)
    open var buttonMask: UIEvent.ButtonMask { get }

    //返回与接收器相关联的所有触摸对象。
    open var allTouches: Set<UITouch>? { get }

    //返回属于一个给定窗口的接收器的事件响应的触摸对象。
    open func touches(for window: UIWindow) -> Set<UITouch>?

    //返回属于一个给定视图的触摸对象，用于表示由接收器所表示的事件。
    open func touches(for view: UIView) -> Set<UITouch>?

    //返回触摸对象被传递到特殊手势识别
    @available(iOS 3.2, *)
    open func touches(for gesture: UIGestureRecognizer) -> Set<UITouch>?

    
    // An array of auxiliary UITouch’s for the touch events that did not get delivered for a given main touch. This also includes an auxiliary version of the main touch itself.
    // 一个辅助UITouch的数组，用于没有被交付给给定的主触摸的触摸事件。这也包括主触摸本身的辅助版本。
    //会将丢失的触摸放到一个新的 UIEvent 数组中，你可以用 coalescedTouchesForTouch(_:) 方法来访问
    @available(iOS 9.0, *)
    open func coalescedTouches(for touch: UITouch) -> [UITouch]?

    
    // An array of auxiliary UITouch’s for touch events that are predicted to occur for a given main touch. These predictions may not exactly match the real behavior of the touch as it moves, so they should be interpreted as an estimate.
    // 一组辅助的UITouch的触摸事件，预计会发生在一个给定的主触摸。这些预测可能与触摸移动时的真实行为并不完全吻合，所以它们应该被解释为一种估计。
    //辅助UITouch的触摸，预测发生了一系列主要的触摸事件。这些预测可能不完全匹配的触摸的真正的行为，因为它的移动，所以他们应该被解释为一个估计。
    @available(iOS 9.0, *)
    open func predictedTouches(for touch: UITouch) -> [UITouch]?
}

```

