# UIView汇总

一、UIView的一些能力：
- 绘图和动画：
  - 视图使用UIKit或Core Graphics在其矩形区域绘制内容。
  - 您可以将一些视图属性动画为新值。

- 布局和子视图管理
  - 视图可以包含零个或多个子视图。
  - 视图可以调整子视图的大小和位置。
  - 使用Auto Layout来定义调整视图大小和重新定位的规则，以响应视图层次结构中的更改。

- 事件处理
  - 视图是UIResponder的子类，可以响应触摸和其他类型的事件。
  - 视图可以安装手势识别器来处理常见的手势。

二、视图嵌套

默认情况下，当子视图的可见区域扩展到其父视图的边界之外时，子视图的内容不会发生剪切。使用clipsToBounds属性更改该行为。

`addSubview(_:)` 叠加子视图

`insertSubview(_:aboveSubview:)`和`insertSubview(_:belowSubview:)`方法来指定子视图的相对z轴次序


三、视图绘制周期

- 绘制时机：第一次显示时；或由于布局改变而使其全部或部分变得可见时
- 对于使用UIKit或Core Graphics包含自定义内容的视图，系统调用视图的`draw(_:)`方法,这个方法将内容绘制到当前图形上下文（当前图形上下文中是在调用这个方法之前由系统自动设置的）
- 当视图的实际内容发生变化时，通知系统视图需要重绘是您的责任。你可以通过调用视图的`setNeedsDisplay()`或`setNeedsDisplay(_:)`方法来实现。这些方法让系统知道它应该在**下一个绘图周期中更新视图**。因为它要等到下一个绘图周期才更新视图，所以您可以在多个视图上同时调用这些方法来更新它们。

>Note
>
>如果你使用OpenGL ES来画画，你应该使用GLKView类而不是UIView子类化。有关如何使用OpenGL ES绘图的更多信息，请参阅[OpenGL ES Programming Guide.](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008793)

四、Animations

以下UIView类的属性是可动画的:

- frame
- bounds
- center
- transform
- alpha
- backgroundColor

**UIViewPropertyAnimator**

五、子类化

子类化需要您做更多的工作来实现视图并调优其性能。

下面的列表包括了可以考虑在UIView子类中重写的方法:
- Initialization：
  - init(frame:) - 建议您实现此方法。除了这个方法之外，您还可以实现定制的初始化方法。
  - init(coder:) - 如果你从storyboards或nib文件加载视图，并且你的视图需要自定义初始化，那么就实现这个方法。
  - layerClass 只有当你想让你的视图使用不同的核心动画层作为后台存储时，才使用此属性。例如，如果您的视图使用平铺来显示一个大的可滚动区域，您可能希望将属性设置为CATiledLayer类。
    ```swift
    class var layerClass: AnyClass {get}
    
    override class var layerClass : AnyClass {
        return CATiledLayer.self
    }
    //这个方法只在创建视图的早期调用一次，以便创建相应的层对象。
    ```
    

- Drawing and printing:
  - draw(_:) - 如果视图绘制自定义内容，请实现此方法。如果您的视图没有进行任何自定义绘图，请避免重写此方法。
  
  ```swift
  func draw(_ rect: CGRect)

  参数 rect:
  需要更新的视图边界的部分。第一次绘制视图时，这个矩形通常是视图的整个可见边界。然而，在随后的绘图操作中，矩形可能只指定视图的一部分。

  这个方法的默认实现什么也不做。
  使用Core Graphics和UIKit等技术来绘制视图内容的子类应该覆盖这个方法并在那里实现它们的绘制代码。如果视图以其他方式设置其内容，则不需要重写此方法。例如，如果你的视图只是显示一个背景颜色，或者你的视图直接使用底层对象设置它的内容，你就不需要重写这个方法。
  
  当这个方法被调用时，UIKit已经为你的视图配置了适当的绘图环境，你可以简单地调用任何你需要渲染你的内容的绘图方法和函数。具体来说，UIKit创建并配置一个用于绘图的图形上下文，并调整该上下文的转换，使其原点与视图边界矩形的原点匹配。您可以使用`UIGraphicsGetCurrentContext()`函数获得对图形上下文的引用，但不要建立对图形上下文的强引用，因为它可以在调用`draw(_:)`方法之间更改。

  同样,如果使用OpenGL ES和GLKView类绘制,GLKit会在配置底层OpenGL ES上下文之前调用该方法(or the glkView(_:drawIn:) method of your GLKView delegate), so you can simply issue whatever OpenGL ES commands you need to render your content. For more information about how to draw using OpenGL ES, see OpenGL ES Programming Guide.

  您应该将任何绘图限制在rect参数中指定的矩形内。另外，如果视图的isOpaque属性设置为true，你的draw(_:)方法必须完全用不透明的内容填充指定的矩形。
    如果你直接子类化UIView，这个方法的实现不需要调用super。但是，如果你在子类化一个不同的视图类，你应该在实现的某个点调用super。
    当视图首次显示或发生使视图可见部分失效的事件时，将调用此方法。你不应该直接调用这个方法。要使视图的一部分无效，并因此导致该部分被重绘，请调用setNeedsDisplay()或setNeedsDisplay(_:)方法。

    ```

  - draw(_:for:) - Implement this method only if you want to draw your view’s content differently during printing.只有当您希望在打印过程中以不同的方式绘制视图内容时，才需要实现此方法。
    ```swift
    func draw(_ rect: CGRect, 
      for formatter: UIViewPrintFormatter)

    如果希望视图的打印内容与显示内容的显示方式不同，则可以实现此方法。如果将视图打印格式化器添加到打印作业中，但未实现此方法，则调用视图的draw(_:)方法来提供打印的内容。
    有关如何为打印内容实现自定义绘图例程的更多信息，请参见iOS的绘图和打印指南。
    ```
  
- Layout and Constraints:
  
  - requiresConstraintBasedLayout 如果视图类需要约束才能正常工作，请使用此属性。
  - updateConstraints() - 如果您的视图需要在子视图之间创建自定义约束，请实现此方法。
  - alignmentRect(forFrame:), frame(forAlignmentRect:) - 实现这些方法以覆盖视图与其他视图的对齐方式。
  - `didAddSubview(_:), willRemoveSubview(_:)` - 根据需要实现这些方法来跟踪添加和删除子视图。
  - `willMove(toSuperview:), didMoveToSuperview()` - 根据需要实现这些方法来跟踪视图层次结构中当前视图的移动。

- Event Handling:
    - `gestureRecognizerShouldBegin(_:)` - 如果你的视图直接处理触摸事件，并且可能想要阻止附加的手势识别器触发额外的动作，那么就实现这个方法。
   - `touchesBegan(_:with:), touchesMoved(_:with:), touchesEnded(_:with:), touchesCancelled(_:with:)` - Implement these methods if you need to handle touch events directly. (For gesture-based input, use gesture recognizers.)如果你需要直接处理触摸事件，就实现这些方法。(对于基于手势的输入，使用手势识别器。)
  
**有关避免子类化的方法:**

许多视图行为可以在不需要子类化的情况下配置。在开始覆盖方法之前，请考虑修改以下属性或行为是否可以提供您需要的行为。

- **addConstraint(_:)** 
- **autoresizingMask** - Provides automatic layout behavior when the superview’s frame changes. These behaviors can be combined with constraints.
- **contentMode** - Provides layout behavior for the view’s content, as opposed to the frame of the view. This property also affects how the content is scaled to fit the view and whether it is cached or redrawn.
- **isHidden or alpha** - 
- **backgroundColor** -
- Subviews - 
- Gesture recognizers - Rather than subclass to intercept and handle touch events yourself, you can use gesture recognizers to send an Target-Action to a target object.
- Animations - Use the built-in animation support rather than trying to animate changes yourself. The animation support provided by Core Animation is fast and easy to use.使用内置的动画支持，而不是自己尝试动画更改。Core animation提供的动画支持快速且易于使用。

- Image-based backgrounds - For views that display relatively static content, consider using a UIImageView object with gesture recognizers instead of subclassing and drawing the image yourself. Alternatively, you can also use a generic UIView object and assign your image as the content of the view’s CALayer object.对于显示相对静态内容的视图，考虑使用带有手势识别器的UIImageView对象，而不是子类化并自己绘制图像。或者，你也可以使用通用的UIView对象，并分配你的图像作为视图的CALayer对象的内容。


## 主题

### 创建view

`init(frame: CGRect)`
`init?(coder: NSCoder)`

### view外观

`var backgroundColor: UIColor?`

`var isHidden: Bool`

`var alpha: CGFloat`

`var isOpaque: Bool`
一个布尔值，用于确定视图是否不透明。

`var tintColor: UIColor!`
`var tintAdjustmentMode: UIView.TintAdjustmentMode`
[详解 UIView 的 Tint Color 属性](TintColor/)

`var clipsToBounds: Bool`
一个布尔值，决定子视图是否被限制在视图的范围内。

`var clearsContextBeforeDrawing: Bool`
一个布尔值，确定在绘制之前是否应该自动清除视图的边界。
决定在视图重画之前是否先清理视图以前的内容，默认值为YES,如果你把这个属性设为NO，那么你要保证能在 drawRect：方法中正确的绘画。如果你的代码已经做了大量优化，那么设为NO可以提高性能，尤其是在滚动时可能只需要重新绘画视图的一部分


`var mask: UIView?`
An optional view whose alpha channel is used to mask a view’s content.
一个可选视图，其alpha通道用于屏蔽视图的内容。


`class var layerClass: AnyClass`
Returns the class used to create the layer for instances of this class.
`var layer: CALayer`
The view’s Core Animation layer used for rendering.


### 配置事件相关行为

#### isUserInteractionEnabled

`var isUserInteractionEnabled: Bool { get set }`

当设置为false时，用于视图的ouch, press, keyboard, and focus事件将被忽略并从事件队列中删除。当设置为true时，事件将正常地传递给视图。此属性的默认值为true。
在动画期间，动画中涉及的所有视图的用户交互都被暂时禁用，不管这个属性中的值是多少。在配置动画时，可以通过指定allowUserInteraction选项禁用此行为。

一些UIKit子类覆盖这个属性并返回一个不同的默认值。请参阅该类的文档，以确定它是否返回不同的值。

#### var isMultipleTouchEnabled: Bool
`var isMultipleTouchEnabled: Bool { get set }`
A Boolean value that indicates whether the view receives more than one touch at a time.
当设置为true时，视图接收与多点触摸序列相关的所有触摸，并在视图的边界内开始。当设置为false时，视图只接收在视图边界内开始的多点触摸序列中的第一个触摸事件。此属性的默认值为false。

此属性不影响附加到视图的手势识别器。手势识别器接收视图中发生的所有触摸。

当此属性为false时，同一窗口中的其他视图仍然可以接收触摸事件。如果你想让这个视图专门处理多点触摸事件，设置这个属性和isExclusiveTouch属性的值为true。

这个属性不能阻止视图被要求处理多个触摸。例如，两个子视图都可以将它们的触摸转发给一个共同的父视图，比如一个窗口或视图控制器的根视图。这个属性决定了有多少最初针对视图的触摸被交付给该视图。

#### var isExclusiveTouch: Bool

A Boolean value that indicates whether the receiver handles touch events exclusively.
将此属性设置为true会导致接收方阻止将触摸事件传递给同一窗口中的其他视图。此属性的默认值为false。

### Configuring the Bounds and Frame Rectangles

#### var frame: CGRect

这个矩形定义了视图在父视图坐标系中的大小和位置。在布局操作中使用这个矩形来设置视图的大小和位置。设置此属性将更改center属性指定的点，并相应地更改边界矩形的大小。框架矩形的坐标总是用点指定的。
警告
如果transform属性不是恒等变换，则该属性的值是未定义的，因此应该被忽略。
更改框架矩形会自动重新显示视图，而不需要调用它的`draw(_:)`方法。如果你想让UIKit在框架矩形改变时调用`draw(_:)`方法，设置`contentMode`属性为`UIView.ContentMode.redraw`。
对该属性的更改可以是动画的。但是，如果transform属性包含非恒等转换，则frame属性的值是未定义的，不应该被修改。在这种情况下，使用center属性重新定位视图，并使用bounds属性调整大小。

#### var bounds: CGRect

默认边界原点为(0,0)，大小与frame属性中的矩形大小相同。改变这个矩形的大小部分会使视图相对于其中心点增长或收缩。改变大小也会改变frame属性中矩形的大小以匹配。边界矩形的坐标总是用点指定的。
改变边界矩形会自动重新显示视图，而不需要调用它的`draw(_:)`方法。如果你想让UIKit调用`draw(_:)`方法，设置`contentMode`属性为`UIView.ContentMode.redraw`。
对该属性的更改可以是动画的。

#### var center: CGPoint
中心点是在父视图坐标系统中的点中指定的。设置此属性会适当地更新frame属性中矩形的原点。
当你想要改变视图的位置时，使用这个属性，而不是frame属性。中心点总是有效的，即使缩放或旋转因子应用到视图的变换。对该属性的更改可以是动画的。

#### var transform: CGAffineTransform

使用此属性在父视图的坐标系统中缩放或旋转视图的框架矩形。(要改变视图的位置，请修改center属性。)该属性的默认值是CGAffineTransformIdentity。
转换发生在相对于视图锚点的位置。默认情况下，锚点等于框架矩形的中心点。要更改锚点，请修改视图基础CALayer对象的anchorPoint属性。
对该属性的更改可以是动画的。
在ios8.0及更高版本中，transform属性不会影响Auto Layout。自动布局基于未转换的框架计算视图的对齐矩形。
当这个属性的值不是恒等变换时，frame属性中的值是未定义的，应该被忽略。

#### var transform3D: CATransform3D

### Managing the View Hierarchy
#### var superview: UIView?
The receiver’s superview, or nil if it has none.

#### var subviews: [UIView]
The receiver’s immediate subviews.
可以使用此属性检索与自定义视图层次结构关联的子视图。**数组中的子视图的顺序反映了它们在屏幕上的可见顺序，索引为0的视图是最后面的视图。**
对于在UIKit和其他系统框架中声明的复杂视图，视图的任何子视图通常都被认为是私有的，随时都可能发生变化。因此，您不应该试图检索或修改这些系统提供的视图类型的子视图。如果您这样做，您的代码可能会在未来的系统更新期间崩溃。

#### var window: UIWindow?
The receiver’s window object, or nil if it has none.
This property is nil if the view has not yet been added to a window.

#### func addSubview(UIView)
Adds a view to the end of the receiver’s list of subviews.

#### func bringSubviewToFront(UIView)
Moves the specified subview so that it appears on top of its siblings.
这个方法将指定的视图移动到子视图属性中视图数组的末尾。

#### func sendSubviewToBack(UIView)
Moves the specified subview so that it appears behind its siblings.
这个方法将指定的视图移动到子视图属性中视图数组的起始。

#### func removeFromSuperview()
Unlinks the view from its superview and its window, and removes it from the responder chain.

#### func insertSubview(UIView, at: Int)
Inserts a subview at the specified index.

#### func insertSubview(UIView, aboveSubview: UIView)
Inserts a view above another view in the view hierarchy.

#### func insertSubview(UIView, belowSubview: UIView)
Inserts a view below another view in the view hierarchy.

#### func exchangeSubview(at: Int, withSubviewAt: Int)
Exchanges the subviews at the specified indices.

#### func isDescendant(of: UIView) -> Bool
Returns a Boolean value indicating whether the receiver is a subview of a given view or identical to that view.

### Observing View-Related Changes
#### func didAddSubview(UIView)
Tells the view that a subview was added.

#### func willRemoveSubview(UIView)
Tells the view that a subview is about to be removed.

#### func willMove(toSuperview: UIView?)
Tells the view that its superview is about to change to the specified superview.

#### func didMoveToSuperview()
Tells the view that its superview changed.

#### func willMove(toWindow: UIWindow?)
Tells the view that its window object is about to change.

#### func didMoveToWindow()
Tells the view that its window object changed.


### Configuring Content Margins

#### Positioning Content Within Layout Margins

[详细见目录Layout Margins](UIView属性详解/Layout%20Margins/)

#### var directionalLayoutMargins: NSDirectionalEdgeInsets
[详细见目录Layout Margins](UIView属性详解/Layout%20Margins/)

#### var layoutMargins: UIEdgeInsets

在视图中布局内容时使用的默认间距。

`var layoutMargins: UIEdgeInsets { get set }`

在ios11及后续版本中，使用`directionalLayoutMargins`属性来指定布局边距，而不是这个属性。`directionalLayoutMargins`属性中的 leading and trailing与此属性中的 left and right同步。例如，在使用从左到右语言的系统中，将leading设置为20个点会导致该属性的left设置为20个点。
对于视图控制器的根视图，此属性的默认值反映了系统最小边距和安全区插入。对于视图层次结构中的其他子视图，默认的布局边距通常是每边8个点，但如果视图不是完全在安全区域内，或者如果`preservesSuperviewLayoutMargins`属性为true，值可能会更大。
这个属性指定视图边缘和任何子视图之间所需的空间量(以点为单位)。自动布局使用你的页边距作为放置内容的提示。例如，如果你使用格式字符串" |-[subview]-| "指定一组水平约束，子视图的左右边缘将被相应的布局边距从父视图的边缘插入。当视图的边缘接近父视图的边缘，并且preservesSuperviewLayoutMargins属性为true时，实际的布局边距可能会增加，以防止内容与父视图的边距重叠。

#### preservesSuperviewLayoutMargins

一个布尔值，指示当前视图是否也尊重其父视图的边距。

`var preservesSuperviewLayoutMargins: Bool { get set }`

当此属性的值为true时，父视图的边距在布局内容时也会被考虑。这个边距会影响视图和父视图之间的距离小于相应边距的布局。例如，您可能有一个内容视图，其框架精确地匹配其父视图的边界。当任何父视图的边距在内容视图和它自己的边距所代表的区域内时，UIKit调整内容视图的布局以尊重父视图的边距。调整的数量是确保内容也在父视图的边距内所需的最小数量。
此属性的默认值为false。
[具体讲解](UIView属性详解/Layout%20Margins/3-LayoutMargin%20&%20preservesSuperviewLayoutMargins%20学习笔记%20-%20简书.pdf)

#### func layoutMarginsDidChange()

这个方法的默认实现什么也不做。子类可以重写这个方法，并在视图的layoutmargin属性的值发生变化时使用它进行响应。例如，如果您的视图子类手动处理布局或在绘图期间使用布局边距，您可以重写此方法。在这两种情况下，您都可以使用此方法来启动绘图或布局更新。

### Getting the Safe Area

#### Positioning Content Relative to the Safe Area
#### var safeAreaInsets: UIEdgeInsets
#### var safeAreaLayoutGuide: UILayoutGuide
[具体讲解](UIView属性详解/Safe%20Area/2-随手记在iPhone%20X上的适配实践总结%20-%20CocoaChina_一站式开发者成长社区.pdf)

#### func safeAreaInsetsDidChange()
Called when the safe area of the view changes.

#### var insetsLayoutMarginsFromSafeArea: Bool

A Boolean value indicating whether the view's layout margins are updated automatically to reflect the safe area.
一个布尔值，指示视图的布局边距是否自动更新以反映安全区域。
当此属性的值为true时，安全区域之外的任何边距将被自动修改为属于安全区域边界。此属性的默认值为true。将该值更改为false允许您的边距保持在原来的位置，即使它们不在安全区域内。

一个布尔值，指示是否自动更新视图的布局边距以反映安全区域,默认为true.
单看这个属性,就知道其与layoutMargins、safeAreaInsets属性有关,事实也确实如此.
iOS中layoutMargins 默认为 UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
当insetsLayoutMarginsFromSafeArea == true时:
layoutMargins = layoutMargins + safeAreaInsets;

### Managing the View’s Constraints
Adjust the size and position of the view using Auto Layout constraints.

#### var constraints: [NSLayoutConstraint]
The constraints held by the view.

#### func addConstraint(NSLayoutConstraint)
Adds a constraint on the layout of the receiving view or its subviews.
约束必须只涉及在接收视图范围内的视图。具体来说，所涉及的任何视图必须要么是接收视图本身，要么是接收视图的子视图。添加到视图的约束被认为是由该视图持有的。求约束时使用的坐标系统是持有约束的视图的坐标系统。
当开发iOS 8.0或更高版本时，将约束的isActive属性设置为true，而不是直接调用addConstraint(_:)方法。isActive属性会自动从正确的视图中添加和删除约束。

#### func addConstraints([NSLayoutConstraint])
Adds multiple constraints on the layout of the receiving view or its subviews.
所有约束必须只涉及在接收视图范围内的视图。具体来说，所涉及的任何视图必须要么是接收视图本身，要么是接收视图的子视图。添加到视图的约束被认为是由该视图持有的。求每个约束时使用的坐标系统是包含该约束的视图的坐标系统。
当开发iOS 8.0或更高版本时，使用NSLayoutConstraint类的activate(_:)方法而不是直接调用addConstraints(_:)方法。activate(_:)方法会自动将约束添加到正确的视图中。

#### func removeConstraint(NSLayoutConstraint)
Removes the specified constraint from the view.
当开发iOS 8.0或更高版本时，将约束的isActive属性设置为false，而不是直接调用removeConstraint(_:)方法。isActive属性会自动从正确的视图中添加和删除约束。

#### func removeConstraints([NSLayoutConstraint])
Removes the specified constraints from the view.
当开发iOS 8.0或更高版本时，使用NSLayoutConstraint类的deactivate(_:)方法而不是直接调用removeConstraints(_:)方法。deactivate(_:)方法自动从正确的视图中移除约束。

### Creating Constraints Using Layout Anchors
Attach Auto Layout constraints to one of the view's anchors.
var bottomAnchor: NSLayoutYAxisAnchor
A layout anchor representing the bottom edge of the view’s frame.
var centerXAnchor: NSLayoutXAxisAnchor
A layout anchor representing the horizontal center of the view’s frame.
var centerYAnchor: NSLayoutYAxisAnchor
A layout anchor representing the vertical center of the view’s frame.
var firstBaselineAnchor: NSLayoutYAxisAnchor
A layout anchor representing the baseline for the topmost line of text in the view.
var heightAnchor: NSLayoutDimension
A layout anchor representing the height of the view’s frame.
var lastBaselineAnchor: NSLayoutYAxisAnchor
A layout anchor representing the baseline for the bottommost line of text in the view.
var leadingAnchor: NSLayoutXAxisAnchor
A layout anchor representing the leading edge of the view’s frame.
var leftAnchor: NSLayoutXAxisAnchor
A layout anchor representing the left edge of the view’s frame.
var rightAnchor: NSLayoutXAxisAnchor
A layout anchor representing the right edge of the view’s frame.
var topAnchor: NSLayoutYAxisAnchor
A layout anchor representing the top edge of the view’s frame.
var trailingAnchor: NSLayoutXAxisAnchor
A layout anchor representing the trailing edge of the view’s frame.
var widthAnchor: NSLayoutDimension
A layout anchor representing the width of the view’s frame.

[详细解释](UIView属性详解/NSLayoutAnchor/NSLayoutAnchor详解%20-%20简书.pdf)

### Working with Layout Guides
#### func addLayoutGuide(UILayoutGuide)
Adds the specified layout guide to the view.
这个方法将指定的布局指南添加到视图的layoutGuides数组的末尾。它还将视图分配给指南的owningView属性。每个指南只能有一个所属视图。
在将指南添加到视图之后，它可以参与该视图层次结构的Auto Layout约束。

#### var layoutGuides: [UILayoutGuide]
The array of layout guide objects owned by this view.

#### var layoutMarginsGuide: UILayoutGuide
A layout guide representing the view’s margins.
使用这个布局指南的锚来创建视图边距的约束。

#### var readableContentGuide: UILayoutGuide
A layout guide representing an area with a readable width within the view.
一种布局指南，表示视图中具有可读宽度的区域。

该布局指南定义了一个易于阅读的区域，用户无需移动头部来跟踪线条。可读内容区遵循以下规则:
可读的内容指南永远不会超出视图的布局边距指南。
可读的内容指南在布局边距指南中垂直居中。
可读内容指南的宽度等于或小于为当前动态文本大小定义的可读宽度。
使用可读的内容指南来布局一列文本。如果要布局多个列，可以使用参考线的宽度来确定列的最佳宽度。

#### func removeLayoutGuide(UILayoutGuide)
Removes the specified layout guide from the view.


### Measuring in Auto Layout
自动布局中的测量
#### func systemLayoutSizeFitting(CGSize) -> CGSize
Returns the optimal size of the view based on its current constraints.
根据当前约束返回视图的最佳大小。
`func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize`
**targetSize**
你想要的尺寸。要获得一个尽可能小的视图，指定常量`layoutFittingCompressedSize`。要获得尽可能大的视图，请指定常量`layoutFittingExpandedSize`。
该方法返回视图的size值，该值最优地满足视图的当前约束，并尽可能接近targetSize参数中的值。这个方法实际上不会改变视图的大小。

```
    [self addSubview:self.evaluateTitleLbl];

    [_evaluateTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_evaluateTitle.mas_left);
        make.top.equalTo(_evaluateTitle.mas_bottom).offset(12);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
CGfloat height =  [self.evaluateTitleLbl systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

这里的height 就是获取布局后的 label 实际高度。
```

#### func systemLayoutSizeFitting(CGSize, withHorizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
Returns the optimal size of the view based on its constraints and the specified fitting priorities.
根据视图的约束和指定的合适优先级返回视图的最佳大小。
**targetSize**
你想要的尺寸。要获得一个尽可能小的视图，指定常量`layoutFittingCompressedSize`。要获得尽可能大的视图，请指定常量`layoutFittingExpandedSize`。
**horizontalFittingPriority**
水平约束的优先级。指定`fittingSizeLevel`以获得尽可能接近targetSize宽度值的宽度。
**verticalFittingPriority**
垂直约束的优先级。指定`fittingSizeLevel`以获得一个高度，尽可能接近targetSize的高度值。
当您希望在确定视图的最佳尺寸时对视图的约束进行优先级排序时，请使用此方法。这个方法实际上不会改变视图的大小。

#### var intrinsicContentSize: CGSize
The natural size for the receiving view, considering only properties of the view itself.
`var intrinsicContentSize: CGSize { get }`
接收视图的自然大小，仅考虑视图本身的属性。
自定义视图通常具有布局系统不知道的内容。设置此属性允许自定义视图根据其内容向布局系统传达其希望的大小。这种内在大小必须独立于内容框架，例如,因为无法根据高度的变化动态地将宽度的变化传达给布局系统。
如果一个自定义视图对于给定的维度没有内在大小，那么它可以对该维度使用`noIntrinsicmetric`。

#### func invalidateIntrinsicContentSize()
Invalidates the view’s intrinsic content size.
使视图的内在内容大小无效。
当自定义视图中发生更改，使其内在内容大小无效时调用此方法。这允许基于约束的布局系统在下一个布局过程中考虑新的内在内容大小。

#### func contentCompressionResistancePriority(for: NSLayoutConstraint.Axis) -> UILayoutPriority
Returns the priority with which a view resists being made smaller than its intrinsic size.
返回视图拒绝被设置为小于其固有大小的优先级。
`func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority`

返回值：视图在指定轴上抵抗从其固有尺寸被压缩的优先级。
基于约束的布局系统在为视图确定最佳布局时使用这些优先级，这些视图遇到的约束要求它们小于其内在大小。
子类不应该重写这个方法。相反，自定义视图应该在创建时为其内容设置默认值，通常为UILayoutPriorityDefaultLow或UILayoutPriorityDefaultHigh。

#### func setContentCompressionResistancePriority(UILayoutPriority, for: NSLayoutConstraint.Axis)
Sets the priority with which a view resists being made smaller than its intrinsic size.

#### func contentHuggingPriority(for: NSLayoutConstraint.Axis) -> UILayoutPriority
Returns the priority with which a view resists being made larger than its intrinsic size.

#### func setContentHuggingPriority(UILayoutPriority, for: NSLayoutConstraint.Axis)
Sets the priority with which a view resists being made larger than its intrinsic size.
