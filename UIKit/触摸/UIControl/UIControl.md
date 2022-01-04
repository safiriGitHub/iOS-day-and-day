
- 跟踪触摸事件

```
    open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool

    open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool

    open func endTracking(_ touch: UITouch?, with event: UIEvent?) // touch is sometimes nil if cancelTracking calls through to this.

    open func cancelTracking(with event: UIEvent?) // event may be nil if cancelled for non-event reasons, e.g. removed from window

```

`UIControl`的是针对单点触摸，而`UIResponse`可能是多点触摸
由于`UIControl`本身是视图，所以它实际上也继承了`UIResponse`的这四个方法。如果测试一下，我们会发现在针对控件的触摸事件发生时，这两组方法都会被调用，而且互不干涉

- isTracking

`open var isTracking: Bool { get }`

为了判断当前对象是否正在追踪触摸操作，`UIControl`定义了一个`tracking`属性。该值如果为YES，则表明正在追踪。这对于我们是更加方便了，不需要自己再去额外定义一个变量来做处理。

- isTouchInside
  
  `open var isTouchInside: Bool { get }` // valid during tracking only

在测试中，我们可以发现当我们的触摸点沿着屏幕移出控件区域名，还是会继续追踪触摸操作，`cancelTrackingWithEvent:`消息并未被发送。

为了判断当前触摸点是否在控件区域类，可以使用`touchInside`属性，这是个只读属性。
不过实测的结果是，在控件区域周边一定范围内，该值还是会被标记为YES，即用于判定`touchInside`为YES的区域会比控件区域要大。


2.2 观察或修改分发到target对象的行为消息 



代码部分备份
```
// ImageControl.m
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
	// 将事件传递到对象本身来处理
    [super sendAction:@selector(handleAction:) to:self forEvent:event];
}
- (void)handleAction:(id)sender {
    NSLog(@"handle Action");
}
// ViewController.m
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    ImageControl *control = [[ImageControl alloc] initWithFrame:(CGRect){50.0f, 100.0f, 200.0f, 300.0f} title:@"This is a demo" image:[UIImage imageNamed:@"demo"]];
    // ...
    [control addTarget:self action:@selector(tapImageControl:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)tapImageControl:(id)sender {
    NSLog(@"sender = %@", sender);
}

```