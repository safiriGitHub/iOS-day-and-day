作者：ildream
链接：https://www.jianshu.com/p/4ca805af1570
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## 1、属性和方法

```swift
open class UIGestureRecognizer : NSObject {

    
    // Valid action method signatures:
    //     -(void)handleGesture;
    //     -(void)handleGesture:(UIGestureRecognizer*)gestureRecognizer;
    public init(target: Any?, action: Selector?) // designated initializer

    
    public convenience init()

    public convenience init?(coder: NSCoder)

    
    open func addTarget(_ target: Any, action: Selector) // add a target/action pair. you can call this multiple times to specify multiple target/actions

    open func removeTarget(_ target: Any?, action: Selector?) // remove the specified target/action pair. passing nil for target matches all targets, and the same for actions

    >> addTarget方法，允许一个手势对象可以添加多个selector方法，并且触发的时候，所有添加的selector都会被执行
    
    >> 手势的状态  **下面会详解该属性**
    open var state: UIGestureRecognizer.State { get } // the current state of the gesture recognizer

    >> 手势代理
    weak open var delegate: UIGestureRecognizerDelegate? // the gesture recognizer's delegate

    >> 手势是否有效  默认YES
    open var isEnabled: Bool // default is YES. disabled gesture recognizers will not receive touches. when changed to NO the gesture recognizer will be cancelled if it's currently recognizing a gesture

    >> 获取手势所在的view
    // a UIGestureRecognizer receives touches hit-tested to its view and any of that view's subviews
    open var view: UIView? { get } // the view the gesture is attached to. set by adding the recognizer to a UIView using the addGestureRecognizer: method

    >> 取消view上面的touch事件响应  default  YES **下面会详解该属性**
    open var cancelsTouchesInView: Bool // default is YES. causes touchesCancelled:withEvent: or pressesCancelled:withEvent: to be sent to the view for all touches or presses recognized as part of this gesture immediately before the action method is called.

    >> 延迟touch事件开始 default  NO   **下面会详解该属性**
    open var delaysTouchesBegan: Bool // default is NO.  causes all touch or press events to be delivered to the target view only after this gesture has failed recognition. set to YES to prevent views from processing any touches or presses that may be recognized as part of this gesture

    >> 延迟touch事件结束 default  YES  **下面会详解该属性**
    open var delaysTouchesEnded: Bool // default is YES. causes touchesEnded or pressesEnded events to be delivered to the target view only after this gesture has failed recognition. this ensures that a touch or press that is part of the gesture can be cancelled if the gesture is recognized

    >> 允许touch的类型数组，**下面会详解该属性**
    @available(iOS 9.0, *)
    open var allowedTouchTypes: [NSNumber] // Array of UITouchTypes as NSNumbers.

    >> 允许按压press的类型数组
    @available(iOS 9.0, *)
    open var allowedPressTypes: [NSNumber] // Array of UIPressTypes as NSNumbers.

    
    //表示手势识别器是否会同时考虑不同触摸类型的触摸。
    //如果是NO，它接收所有匹配它的allowedTouchTypes的触摸。
    //如果是，一旦它接收到一个特定类型的触摸，它将忽略其他类型的新触摸，直到它被重置为UIGestureRecognizerStatePossible。
    >> 是否只允许一种touchType 类型，**下面会详解该属性**
    @available(iOS 9.2, *)
    open var requiresExclusiveTouchType: Bool // defaults to YES

    
    // create a relationship with another gesture recognizer that will prevent this gesture's actions from being called until otherGestureRecognizer transitions to UIGestureRecognizerStateFailed
    // if otherGestureRecognizer transitions to UIGestureRecognizerStateRecognized or UIGestureRecognizerStateBegan then this recognizer will instead transition to UIGestureRecognizerStateFailed
    // example usage: a single tap may require a double tap to fail
    //创建一个与另一个手势识别器的关系，该关系将防止这个手势的动作被调用，直到otherGestureRecognizer转换到UIGestureRecognizerStateFailed
    //如果otherGestureRecognizer转换到UIGestureRecognizerStateRecognized或UIGestureRecognizerStateBegan，那么这个识别器将代替转换到UIGestureRecognizerStateFailed
    //示例用法:单个点击可能需要双点击失败
    >> 手势依赖（手势互斥）方法，**下面会详解该方法**
    open func require(toFail otherGestureRecognizer: UIGestureRecognizer)

    
    // individual UIGestureRecognizer subclasses may provide subclass-specific location information. see individual subclasses for details
    >> 获取在传入view的点击位置的信息方法
    open func location(in view: UIView?) -> CGPoint // a generic single-point location for the gesture. usually the centroid of the touches involved//手势的通用单点位置。通常涉及的触摸的质心

    >> 获取触摸点数
    open var numberOfTouches: Int { get } // number of touches involved for which locations can be queried

    >> （touchIndex 是第几个触摸点）用来获取多触摸点在view上位置信息的方法
    open func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint // the location of a particular touch

    >> 给手势加一个名字，以方便调式
    @available(iOS 11.0, *)
    open var name: String? // name for debugging to appear in logging

    
    // Values from the last event processed.
    // These values are not considered as requirements for the gesture.
    @available(iOS 13.4, *)
    open var modifierFlags: UIKeyModifierFlags { get }

    @available(iOS 13.4, *)
    open var buttonMask: UIEvent.ButtonMask { get }
}

```

### 1.1 requiresExclusiveTouchType
是不是有很多人和我之前一样，把它理解成了设置为NO，就可以同时响应几种手势点击了呢？
这个属性的意思：是否同时只接受一种触摸类型，而不是是否同时只接受一种手势。默认是YES。设置成NO，它会同时响应 allowedTouchTypes 这个数组里的所有触摸类型。这个数组里面装的touchType类型如下：

```swift
public enum TouchType : Int {

        >>  手指直接接触屏幕
        case direct = 0 // A direct touch from a finger (on a screen)

        >>  不是手指直接接触屏幕（例如：苹果TV遥控设置屏幕上的按钮）
        case indirect = 1 // An indirect touch (not a screen)

        >> 触控笔接触屏幕
        @available(iOS 9.1, *)
        case pencil = 2 // Add pencil name variant

        @available(iOS 9.1, *)
        public static var stylus: UITouch.TouchType { get } // A touch from a stylus (deprecated name, use pencil)

        @available(iOS 13.4, *)
        case indirectPointer = 3 // A touch representing a button-based, indirect input device describing the input sequence from button press to button release
        // 一种表示基于按钮的间接输入设备的触摸，描述从按钮按下到按钮释放的输入序列
    }
```
如果把`requiresExclusiveTouchType`设置为NO，假设view上添加了tapGesture手势，你同时用手点击和用触控笔点击该view，这个tapGesture手势的方法都会响应。

### 1.2 cancelsTouchesInView、delaysTouchesBegan、delaysTouchesEnd

首先要知道的是

    1.这3个属性是作用于GestureRecognizers(手势识别)与触摸事件之间联系的属性。实际应用中好像很少会把它们放到一起，大多都只是运用手势识别，所以这3个属性应该很少会用到。

    2.对于触摸事件，window只会有一个控件来接收touch。这个控件是首先接触到touch的并且重写了触摸事件方法（一个即可）的控件

    3.手势识别和触摸事件是两个独立的事，只是可以通过这3个属性互相影响，不要混淆。

    4.在默认情况下（即这3个属性都处于默认值的情况下），如果触摸window，首先由window上最先符合条件的控件(该控件记为hit-test view)接收到该touch并触发触摸事件touchesBegan。同时如果某个控件的手势识别器接收到了该touch，就会进行识别。手势识别成功之后发送触摸事件touchesCancelled给hit-testview，hit-test view不再响应touch。

    - cancelsTouchesInView:
    默认为YES,这种情况下当手势识别器识别到touch之后，会发送touchesCancelled给hit-testview以取消hit-test view对touch的响应，这个时候只有手势识别器响应touch。

    当设置成NO时，手势识别器识别到touch之后不会发送touchesCancelled给hit-test，这个时候手势识别器和hit-test view均响应touch。

    - delaysTouchesBegan:

    默认是NO，这种情况下当发生一个touch时，手势识别器先捕捉到到touch，然后发给hit-testview，两者各自做出响应。如果设置为YES，手势识别器在识别的过程中（注意是识别过程），不会将touch发给hit-test view，即hit-testview不会有任何触摸事件。只有在识别失败之后才会将touch发给hit-testview，这种情况下hit-test view的响应会延迟约0.15ms。

    - delaysTouchesEnded:

    默认为YES。这种情况下发生一个touch时，在手势识别成功后,发送给touchesCancelled消息给hit-testview，手势识别失败时，会延迟大概0.15ms,期间没有接收到别的touch才会发送touchesEnded。如果设置为NO，则不会延迟，即会立即发送touchesEnded以结束当前触摸。


**例子**
```swift

class Test3VC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
        pan.cancelsTouchesInView = true
        // delaysTouchesBegan 默认false
        // delaysTouchesEnded 默认true
        /**手指滑动屏幕 打印：
         touchesBegan 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesCancelled 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了

         解释：
          栗子中，pan.cancelsTouchesInView = true时，为什么会打印"touchesMoved调用了"呢？
          这就涉及到第二个属性delaysTouchesBegan默认为false,这是因为手势识别是有一个过程的，
          拖拽手势需要一个很小的手指移动的过程才能被识别为拖拽手势，
          而在一个手势触发之前，是会一并发消息给事件传递链的，所以才会有最开始的几个touchMoved方法被调用，
          当识别出拖拽手势以后，就会终止touch事件的传递。
          
          故当pan.cancelsTouchsInView = false 时，touchesMoved和panHandler依次被打印出来，touch事件继续响应。
         */
        
    
        
        //2
        pan.cancelsTouchesInView = false
        // delaysTouchesBegan 默认false
        // delaysTouchesEnded 默认true
        /* 手指滑动屏幕 打印：
         touchesBegan 调用了
         touchesMoved 调用了
         touchesMoved 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesMoved 调用了
         panHandler 调用了
         panHandler 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesMoved 调用了
         panHandler 调用了
         touchesEnded 调用了
         */

        //3
        pan.cancelsTouchesInView = true
        // pan.delaysTouchesBegan = true
        // delaysTouchesEnded 默认true
        /*
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         panHandler 调用了
         
         当delaysTouchesBegan 设置为true时，
         手势识别成功之前都不会调用touches相关方法，因为手势识别成功了，所以控制台只打印了"panHandler 调用了"的信息。
         如果手势识别失败了，就会打印touchesMoved方法里的信息。
         
         */

        view.addGestureRecognizer(pan)
       
    }
    
    @objc func panHandler(sender: UIPanGestureRecognizer) {
        print("panHandler 调用了")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan 调用了")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved 调用了")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled 调用了")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded 调用了")
    }
}

```

### 1.3 open func require(toFail otherGestureRecognizer: UIGestureRecognizer)

用法：`[A requireGestureRecognizerToFail：B]` 
当A、B两个手势同时满足响应手势方法的条件时，B优先响应，A不响应。如果B不满足条件，A满足响应手势方法的条件，则A响应。其实这就是一个设置响应手势优先级的方法。
如果一个view上添加了多个手势对象的，默认这些手势是互斥的，一个手势触发了就会默认屏蔽其他手势动作。比如，单击和双击手势并存时，如果不做处理，它就只能发送出单击的消息。为了能够优先识别双击手势，我们就可以用requireGestureRecognizerToFail：这个方法设置优先响应双击手势。

### 1.4 locationInView

如果传入nil则指定为window

比如我们可以设定允许判定手势的rect

```
//设置点击的范围
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//获取当前的触摸点
  CGPoint curp = [touch locationInView:self.imageView];
  if (curp.x <= self.imageView.bounds.size.width*0.5) {
      return NO;
  }else{
      return YES;
  }
}
```


## 2 UIGestureRecognizerDelegate代理方法

```swift
public protocol UIGestureRecognizerDelegate : NSObjectProtocol {

    
    // called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
    >> 开始进行手势识别时调用的方法，返回NO，则手势识别失败
    @available(iOS 3.2, *)
    optional func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool

    
    // called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
    // return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
    //
    // note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
    >> 是否支持同时多个手势触发
    >> 返回YES，则可以多个手势一起触发方法，返回NO则为互斥
    @available(iOS 3.2, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool

    
    // called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
    // return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
    //
    // note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
    >>下面这个两个方法也是用来控制手势的互斥执行的
    >>这个方法返回YES，第二个手势的优先级高于第一个手势
    @available(iOS 7.0, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool

    >> 这个方法返回YES，第一个手势的优先级高于第二个手势
    @available(iOS 7.0, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool

    
    // called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
    >> 手指触摸屏幕后回调的方法，返回NO则手势识别失败
    @available(iOS 3.2, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool

    
    // called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
    @available(iOS 9.0, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool

    
    // called once before either -gestureRecognizer:shouldReceiveTouch: or -gestureRecognizer:shouldReceivePress:
    // return NO to prevent the gesture recognizer from seeing this event
    @available(iOS 13.4, *)
    optional func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool
}

```

## 3 UIGestureRecognizer 子类

查看链接文章
UITapGestureRecognizer
UIPinchGestureRecognizer
UIRotationGestureRecognizer
UISwipeGestureRecognizer
UILongPressGestureRecognizer
UIPanGestureRecognzer
UIScreenEdgePanGestureRecognzer


## UIGestureRecognizer 和 UITouch 事件的关系

硬件事件 --> IOKit.framework 生成IOHIDEvent 事件
        --> SpringBoard接收 按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event
        --> mach port 转发给需要的App进程

苹果使用 RunLoop注册了一个 Source1
        --> 接收到 mach port 转发事件
        --> 触发回调函数 __IOHIDEventSystemClientQueueCallback
        --> 调用_UIApplicationHandleEventQueue 进行应用内部的分发

--> _UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。
    通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。

[iOS触摸事件全家桶](iOS触摸事件全家桶%20-%20简书.webarchive)