
```swift
import Foundation

extension UITouch {

    
    public enum Phase : Int {

        
        case began = 0

        case moved = 1

        case stationary = 2

        case ended = 3

        case cancelled = 4

        @available(iOS 13.4, *)
        case regionEntered = 5

        @available(iOS 13.4, *)
        case regionMoved = 6

        @available(iOS 13.4, *)
        case regionExited = 7
    }

    
    @available(iOS 9.0, *)
    public enum TouchType : Int {

        
        case direct = 0 // A direct touch from a finger (on a screen)

        case indirect = 1 // An indirect touch (not a screen)

        @available(iOS 9.1, *)
        case pencil = 2 // Add pencil name variant

        @available(iOS 9.1, *)
        public static var stylus: UITouch.TouchType { get } // A touch from a stylus (deprecated name, use pencil)

        @available(iOS 13.4, *)
        case indirectPointer = 3 // A touch representing a button-based, indirect input device describing the input sequence from button press to button release
    }

    
    @available(iOS 9.1, *)
    public struct Properties : OptionSet {

        public init(rawValue: Int)

        
        public static var force: UITouch.Properties { get }

        public static var azimuth: UITouch.Properties { get }

        public static var altitude: UITouch.Properties { get }

        public static var location: UITouch.Properties { get } // For predicted Touches
    }
}
public enum UIForceTouchCapability : Int {

    case unknown = 0

    case unavailable = 1

    case available = 2
}

@available(iOS 2.0, *)
open class UITouch : NSObject {

    //记录了触摸事件产生或变化时的时间，单位是秒
    open var timestamp: TimeInterval { get }

    //当前触摸事件所处的状态
    open var phase: UITouch.Phase { get }

    //短时间内点按屏幕的次数，可以根据tapCount判断单击、双击或更多的点击
    open var tapCount: Int { get } // touch down within a certain point within a certain amount of time

    @available(iOS 9.0, *)
    open var type: UITouch.TouchType { get }

    
    // majorRadius and majorRadiusTolerance are in points
    // The majorRadius will be accurate +/- the majorRadiusTolerance
    //获取手指与屏幕的接触半径 IOS8以后可用 只读
    @available(iOS 8.0, *)
    open var majorRadius: CGFloat { get }
    //获取手指与屏幕的接触半径的误差 IOS8以后可用 只读
    @available(iOS 8.0, *)
    open var majorRadiusTolerance: CGFloat { get }

    //触摸产生时所处的窗口
    open var window: UIWindow? { get }

    //触摸产生时所处的视图
    open var view: UIView? { get }

    //获取触摸手势
    @available(iOS 3.2, *)
    open var gestureRecognizers: [UIGestureRecognizer]? { get }

    // 取得在指定视图的位置
    // 返回值表示触摸在view上的位置
    // 这里返回的位置是针对view的坐标系的（以view的左上角为原点(0,0)）
    // 调用时传入的view参数为nil的话，返回的是触摸点在UIWindow的位置
    open func location(in view: UIView?) -> CGPoint
    
    //该方法记录了前一个触摸点的位置
    open func previousLocation(in view: UIView?) -> CGPoint

    
    // Use these methods to gain additional precision that may be available from touches.使用这些方法可能从触摸可以获得额外的精度。
    // Do not use precise locations for hit testing. A touch may hit test inside a view, yet have a precise location that lies just outside.
    // 不要使用精确的位置进行hit testing。因为一个触摸可能命中测试view内部，但使用精确位置的话可能会命中view外部
    @available(iOS 9.1, *)
    open func preciseLocation(in view: UIView?) -> CGPoint

    @available(iOS 9.1, *)
    open func precisePreviousLocation(in view: UIView?) -> CGPoint

    //获取触摸压力值，一般的压力感应值为1.0 IOS9 只读
    // Force of the touch, where 1.0 represents the force of an average touch
    @available(iOS 9.0, *)
    open var force: CGFloat { get }

    // 获取最大触摸压力值
    // Maximum possible force with this input mechanism
    @available(iOS 9.0, *)
    open var maximumPossibleForce: CGFloat { get }

    
    // Azimuth angle. Valid only for stylus touch types. Zero radians points along the positive X axis.
    // Passing a nil for the view parameter will return the azimuth relative to the touch's window.
    @available(iOS 9.1, *)
    open func azimuthAngle(in view: UIView?) -> CGFloat

    // A unit vector that points in the direction of the azimuth angle. Valid only for stylus touch types.
    // Passing nil for the view parameter will return a unit vector relative to the touch's window.
    @available(iOS 9.1, *)
    open func azimuthUnitVector(in view: UIView?) -> CGVector

    
    // Altitude angle. Valid only for stylus touch types.
    // Zero radians indicates that the stylus is parallel to the screen surface,
    // while M_PI/2 radians indicates that it is normal to the screen surface.
    @available(iOS 9.1, *)
    open var altitudeAngle: CGFloat { get }

    
    // An index which allows you to correlate updates with the original touch.
    // Is only guaranteed non-nil if this UITouch expects or is an update.
    @available(iOS 9.1, *)
    open var estimationUpdateIndex: NSNumber? { get }

    // A set of properties that has estimated values
    // Only denoting properties that are currently estimated
    @available(iOS 9.1, *)
    open var estimatedProperties: UITouch.Properties { get }

    // A set of properties that expect to have incoming updates in the future.
    // If no updates are expected for an estimated property the current value is our final estimate.
    // This happens e.g. for azimuth/altitude values when entering from the edges
    @available(iOS 9.1, *)
    open var estimatedPropertiesExpectingUpdates: UITouch.Properties { get }
}


```

一个手指一次触摸屏幕，就对应生成一个UITouch对象。多个手指同时触摸，生成多个UITouch对象。

多个手指先后触摸，系统会根据触摸的位置判断是否更新同一个UITouch对象。
若两个手指一前一后触摸同一个位置（即双击），那么第一次触摸时生成一个UITouch对象，
第二次触摸更新这个UITouch对象（UITouch对象的 tap count 属性值从1变成2）；
若两个手指一前一后触摸的位置不同，将会生成两个UITouch对象，两者之间没有联系。

每个UITouch对象记录了触摸的一些信息，包括触摸时间、位置、阶段、所处的视图、窗口等信息。

手指离开屏幕一段时间后，确定该UITouch对象不会再被更新将被释放。

作者：Lotheve
链接：https://www.jianshu.com/p/c294d1bd963d
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

