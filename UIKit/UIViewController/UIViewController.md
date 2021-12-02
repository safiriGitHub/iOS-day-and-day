
# 一、生命周期

ViewController.swift
```swift
import UIKit

class ViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("init")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init")
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        print("loadView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showVC)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushVC)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }
    
    deinit {
        print("deinit")
    }
    
    
    // other
   
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
    }
    
}

extension ViewController {
    @objc func showVC() {
        let vc = SecondVC()
        //3.1
        vc.modalPresentationStyle = .fullScreen
        //3.2
        vc.modalPresentationStyle = .automatic
//        vc.modalPresentationStyle = .pageSheet
//        vc.modalPresentationStyle = .popover
        showDetailViewController(vc, sender: nil)
    }
}
```
SecondVC.swift
```swift
class SecondVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popVC)))
    }
    
    @objc func dismissVC() {
        dismiss(animated: true) {
            print("SecondVC dismiss success")
        }
    }
    @objc func popVC() {
        navigationController?.popViewController(animated: true)
    }
}
```

## 解释

1. 运行结果 即生命周期流程为:
```
init
loadView
viewDidLoad
viewWillAppear
viewDidLayoutSubviews
viewDidAppear
```
2. 按home键 调用 `viewDidLayoutSubviews` 四次, 为何？

```
init
loadView
viewDidLoad
viewWillAppear
viewDidLayoutSubviews
viewDidAppear
viewDidLayoutSubviews
viewDidLayoutSubviews
viewDidLayoutSubviews
viewDidLayoutSubviews

```
3. 点击view,调用`showDetailViewController`方法进入第二个页面

- 3.1 全屏进入新页面
  
  `vc.modalPresentationStyle = .fullScreen`
  
  ```
    viewWillDisappear
    viewDidDisappear
  ```
  SecondVC 点击返回
   ```
    viewWillAppear
    viewDidAppear
    SecondVC dismiss success
   ```
- 3.2 非全屏进入新页面

  `vc.modalPresentationStyle = .automatic`

  `vc.modalPresentationStyle = .pageSheet`

  `vc.modalPresentationStyle = .popover`

  不会调用 `viewWillDisappear` `viewDidDisappear` 
  
  SecondVC 点击返回  不会调用 `viewWillAppear` `viewDidAppear` 
  ```
  SecondVC dismiss success
  ```

4. 点击view,调用`pushViewController`方法进入第二个页面
   SecondVC调用`popViewController`
   与3.1相同

>1: 为什么viewDidUnload 被弃用？

CALayer调用drawRect时，持有并创建bitmap图像类，UIView(96Bytes)、CALayer(48Bytes)占用内存很小

在 iOS6中，当系统发出 MemoryWarning 时候，系统会自动回收 bitmap 类，但是不回收 UIView 和 CALayer 类，这样既能回收大部分内存，又能在需要 bitmap 类的时候，通过调用 UIView 的 drawRect：方法重建。

苹果对上面的内存回收做了一个优化：
CALayer 包括具体的 bitmap 内存的私有成员变量类型为 CABackStore，当收到 MemoryWarning 时候， CABackStore类型的内存区会被标记成 volatile 类型，volatile 表示，这块内存可能再次被元变量使用。

这样，有了上面的优化之后，当收到 MemoryWarning 的时候，虽然所有的 CALayer 所包含的 bitmap 内存都被标记成 volatile 了，但是只要这块内存没有被复用，当需要重建 bitmap 内存时候，它就可以直接被复用，而避免了再次调用 UIView 的 drawRect： 方法。
> https://www.jianshu.com/p/0a9f966b54b2
 
>2: viewDidLayoutSubviews 方法

被调用以通知视图控制器其视图刚刚布置了其子视图。

详细说明:
当视图控制器的视图bounds发生变化时，视图会调整其子视图的位置，然后系统会调用此方法。 但是，调用此方法并不表示已调整视图子视图的各个布局。 每个子视图负责调整自己的布局。

在视图布局其子视图后，视图控制器可以覆盖此方法以进行更改。 此方法的默认实现不执行任何操作。

个人经验:
不应该在此方法中添加子视图, 或者添加(不是重构)约束, 因为此方法可能被系统多次调用.

在任何调用了`setNeedsLayout`或`setNeedsDisplayInRect`的视图上，每个运行循环都会调用
`viewDidLayoutSubviews`一次-这包括每当将子视图添加到视图，滚动，调整大小等时.

# UIView的生命周期

在viewcontroller.view上添加view
```swift
let testView = TestView(frame: CGRect(x: 20, y: 60, width: 100, height: 100))
testView.backgroundColor = .green
view.addSubview(testView)
```
TestView.swift

```swift
import UIKit

class TestView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init frame: \(frame)")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init coder")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        print("willMove toSuperview: \(String(describing: newSuperview?.description))")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("didMoveToSuperview")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        print("willMove toWindow: \(String(describing: newWindow?.description))")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        print("didMoveToWindow")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        print("setNeedsLayout")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print("layoutIfNeeded")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        print("draw \(rect)")
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        print("setNeedsDisplay")
    }
    
    override func setNeedsDisplay(_ rect: CGRect) {
        super.setNeedsDisplay(rect)
        print("setNeedsDisplay rect:\(rect)")
    }
}

```

1.包括 UIViewController 的生命周期：

```
init
loadView
viewDidLoad
setNeedsDisplay
setNeedsDisplay
init frame: (20.0, 60.0, 100.0, 100.0)
setNeedsDisplay
willMove toSuperview: Optional("<UIView: 0x1047123d0; frame = (0 0; 414 736); autoresize = W+H; gestureRecognizers = <NSArray: 0x2833001e0>; layer = <CALayer: 0x283d589a0>>")
didMoveToSuperview
viewWillAppear
willMove toWindow: Optional("<UIWindow: 0x105004af0; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x283314f60>; layer = <UIWindowLayer: 0x283d51e00>>")
didMoveToWindow
setNeedsLayout
viewDidLayoutSubviews
layoutSubviews
layoutSubviews
draw (0.0, 0.0, 100.0, 100.0)
viewDidAppear

```

其中 UIView 的生命周期：

```
setNeedsDisplay
setNeedsDisplay
init frame: (20.0, 60.0, 100.0, 100.0)
setNeedsDisplay
willMove toSuperview: Optional("<UIView: 0x1047123d0; frame = (0 0; 414 736); autoresize = W+H; gestureRecognizers = <NSArray: 0x2833001e0>; layer = <CALayer: 0x283d589a0>>")
didMoveToSuperview
willMove toWindow: Optional("<UIWindow: 0x105004af0; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x283314f60>; layer = <UIWindowLayer: 0x283d51e00>>")
didMoveToWindow
setNeedsLayout
layoutSubviews
layoutSubviews
draw (0.0, 0.0, 100.0, 100.0)
```
此时进入后台后再进入前台，打印

```
setNeedsDisplay
setNeedsLayout
viewDidLayoutSubviews
viewDidLayoutSubviews
layoutSubviews
draw (0.0, 0.0, 100.0, 100.0)
setNeedsDisplay
setNeedsLayout
viewDidLayoutSubviews
viewDidLayoutSubviews
layoutSubviews
draw (0.0, 0.0, 100.0, 100.0)
打印了两遍。。。为何？
```

push进入新页面，打印
```
viewWillDisappear
willMove toWindow: nil
didMoveToWindow
willMove toWindow: Optional("<UIWindow: 0x104509200; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x280cae640>; layer = <UIWindowLayer: 0x2802faf60>>")
didMoveToWindow
willMove toWindow: nil
didMoveToWindow
viewDidDisappear

```

pop返回，打印
```
viewWillAppear
willMove toWindow: Optional("<UIWindow: 0x104509200; frame = (0 0; 414 736); gestureRecognizers = <NSArray: 0x280cae640>; layer = <UIWindowLayer: 0x2802faf60>>")
didMoveToWindow
viewDidAppear

```
