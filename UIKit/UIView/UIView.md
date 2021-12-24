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
  - `draw(_:)` - 如果视图绘制自定义内容，请实现此方法。如果您的视图没有进行任何自定义绘图，请避免重写此方法。
  
  ```swift
  func draw(_ rect: CGRect)

  参数 rect:
  需要更新的视图边界的部分。第一次绘制视图时，这个矩形通常是视图的整个可见边界。
  然而，在随后的绘图操作中，矩形可能只指定视图的一部分。

  这个方法的默认实现什么也不做。
  使用Core Graphics和UIKit等技术来绘制视图内容的子类应该覆盖这个方法并在那里实现它们的绘制代码。
  如果视图以其他方式设置其内容，则不需要重写此方法。例如，如果你的视图只是显示一个背景颜色，
  或者你的视图直接使用底层对象设置它的内容，你就不需要重写这个方法。
  
  当这个方法被调用时，UIKit已经为你的视图配置了适当的绘图环境，你可以简单地调用任何你需要渲染你的内容的绘图方法和函数。
  具体来说，UIKit创建并配置一个用于绘图的图形上下文，并调整该上下文的转换，使其原点与视图边界矩形的原点匹配。
  您可以使用`UIGraphicsGetCurrentContext()`函数获得对图形上下文的引用，但不要建立对图形上下文的强引用，因为它可以在调用`draw(_:)`方法之间更改。

  同样,如果使用OpenGL ES和GLKView类绘制,GLKit会在配置底层OpenGL ES上下文之前调用该方法(or the glkView(_:drawIn:) method of your GLKView delegate), so you can simply issue whatever OpenGL ES commands you need to render your content. For more information about how to draw using OpenGL ES, see OpenGL ES Programming Guide.

  您应该将任何绘图限制在rect参数中指定的矩形内。
  另外，如果视图的isOpaque属性设置为true，你的draw(_:)方法必须完全用不透明的内容填充指定的矩形。
  
  如果你直接子类化UIView，这个方法的实现不需要调用super。但是，如果你在子类化一个不同的视图类，你应该在实现的某个点调用super。
  
  当视图首次显示或发生使视图可见部分失效的事件时，将调用此方法。你不应该直接调用这个方法。要使视图的一部分无效，并因此导致该部分被重绘，请调用setNeedsDisplay()或setNeedsDisplay(_:)方法。

    ```

  - `draw(_:for:)` - Implement this method only if you want to draw your view’s content differently during printing.只有当您希望在打印过程中以不同的方式绘制视图内容时，才需要实现此方法。
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

- **addConstraint(_: )** 
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
[详解 UIView 的 Tint Color 属性] - TintColor/文件夹

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

当设置为false时，用于视图的touch, press, keyboard, and focus事件将被忽略并从事件队列中删除。当设置为true时，事件将正常地传递给视图。此属性的默认值为true。
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
如果视图还没有被添加到窗口中，则此属性为nil。

#### func addSubview(UIView)
这个方法建立了对视图的强引用，并将它的下一个响应器设置为接收方，即它的新父视图。
视图只能有一个父视图。如果视图已经有一个父视图，而那个视图不是接收视图，这个方法会在接收视图成为它的新父视图之前移除之前的父视图。

#### func bringSubviewToFront(UIView)
移动指定的子视图，使其显示在同级视图的顶部。也就是subviews数组的末尾。


#### func sendSubviewToBack(UIView)
移动指定的子视图，使其显示在同级视图的后面。也就是移动到subviews数组的开始处。

#### func removeFromSuperview()
解除视图与父视图和窗口的链接，并从responder链中移除它。
永远不要在视图的draw(_:)方法中调用这个方法。


#### func insertSubview(UIView, at: Int)
子视图属性数组中要插入视图的索引。子视图索引从0开始，并且不能大于子视图的数量。
这个方法建立了对视图的强引用，并将它的下一个响应器设置为接收方，即它的新父视图。
视图只能有一个父视图。如果视图已经有一个父视图，而那个视图不是接收视图，这个方法会在接收视图成为它的新父视图之前移除之前的父视图

#### func insertSubview(UIView, aboveSubview: UIView)
在视图层次结构中，将一个视图插入到另一个视图之上。

#### func insertSubview(UIView, belowSubview: UIView)
在视图层次结构中，将视图插入到另一个视图之下。

#### func exchangeSubview(at: Int, withSubviewAt: Int)
在指定的索引处交换子视图。
每个索引表示子视图属性中对应视图在数组中的位置。子视图索引从0开始，并且不能大于子视图的数量。这个方法不会改变任何一个视图的父视图，只是交换它们在子视图数组中的位置。

#### func isDescendant(of: UIView) -> Bool
如果receiver是view的直接子视图或远程子视图，或者view是receiver本身，则为True;否则错误。

### 观察与视图相关的变化

func didAddSubview(UIView)
Tells the view that a subview was added.
这个方法的默认实现什么也不做。当添加子视图时，子类可以覆盖它来执行额外的操作。当使用任何相关的视图方法添加子视图时，将调用此方法。


func willRemoveSubview(UIView)
Tells the view that a subview is about to be removed.
告诉视图一个子视图将要被删除。
这个方法的默认实现什么也不做。当子视图被删除时，子类可以覆盖它来执行额外的操作。当子视图的父视图改变或子视图从视图层次结构中完全删除时，调用此方法。

func willMove(toSuperview: UIView?)
Tells the view that its superview is about to change to the specified superview.
告诉视图，它的父视图即将更改为指定的父视图。
这个方法的默认实现什么也不做。子类可以在父视图改变时覆盖它来执行额外的操作。

func didMoveToSuperview()
Tells the view that its superview changed.
这个方法的默认实现什么也不做。子类可以在父视图改变时覆盖它来执行额外的操作。

func willMove(toWindow: UIWindow?)
Tells the view that its window object is about to change.
告诉视图它的窗口对象即将改变。

func didMoveToWindow()
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
**重要提示**
NSLayoutAnchor添加约束注意事项
1.要给添加约束的view要设置`translatesAutoresizingMaskIntoConstraints`为`false` 否则约束不生效 自定义view的时候也要给子view设置此属性，总之你要给哪个view设置Layout就要给哪个view设置此属性为false
[translatesAutoresizingMaskIntoConstraints详解](UIView属性详解/NSLayoutAnchor/translatesAutoresizingMaskIntoConstraints%20详解%20-%20简书.pdf)
2.active要设置为true 这个是控制约束是否真正添加的开关 设置为false的时候 约束失效


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
如果一个自定义视图对于给定的维度没有内在大小，那么它可以对该维度使`noIntrinsicmetric`。

#### func invalidateIntrinsicContentSize()
Invalidates the view’s intrinsic content size.
使视图的内在内容大小无效。
当自定义视图中发生更改，使其内在内容大小无效时调用此方法。这允许基于约束的布局系统在下一个布局过程中考虑新的内在内容大小。

>解释1：
`intrinsicContentSize`，也就是控件的内置大小。比如UILabel，UIButton等控件，他们都有自己的内置大小。控件的内置大小往往是由控件本身的内容所决定的，比如一个UILabel的文字很长，那么该UILabel的内置大小自然会很长。控件的内置大小可以通过UIView的`intrinsicContentSize`属性来获取内置大小，也可以通过`func invalidateIntrinsicContentSize()`方法来在下次UI规划事件中重新计算`intrinsicContentSize`。如果直接创建一个原始的UIView对象，显然它的内置大小为0。

>解释2：
`intrinsicContentSize`：固有大小。顾名思义，在AutoLayout中，它作为UIView的属性（不是语法上的属性），意思就是说我知道自己的大小，如果你没有为我指定大小，我就按照这个大小来。 比如：大家都知道在使用AutoLayout的时候，UILabel是不用指定尺寸大小的，只需指定位置即可，就是因为，只要确定了文字内容，字体等信息，它自己就能计算出大小来。

>在代码中，UILabel，UIImageView，UIButton等控件都重写了UIView 中的 `-(CGSize)intrinsicContentSize:` 方法。 并且在需要改变这个值的时候调用：`func invalidateIntrinsicContentSize()` 方法，通知系统这个值改变了。
所以当我们在编写继承自UIView的自定义组件时，也想要有Intrinsic Content Size的时候，就可以通过这种方法来轻松实现。



#### func contentCompressionResistancePriority(for: NSLayoutConstraint.Axis) -> UILayoutPriority
返回视图拒绝被设置为小于其固有大小的优先级。
`func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority`
**axis**
The axis of the view that might be reduced.
**返回值**：视图在指定轴上抵抗从其固有尺寸被压缩的优先级。
子类不应该重写这个方法。相反，自定义视图应该在创建时为其内容设置默认值，通常为`UILayoutPriorityDefaultLow`或`UILayoutPriorityDefaultHigh`。

#### func setContentCompressionResistancePriority(UILayoutPriority, for: NSLayoutConstraint.Axis)
设置使视图不被设置为小于其固有大小的优先级。
`func setContentCompressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis)`

自定义视图应该在创建时根据它们的内容为这两个方向设置默认值，通常为UILayoutPriorityDefaultLow或UILayoutPriorityDefaultHigh。在创建用户界面时，当总体布局设计需要不同于界面中使用的视图的自然优先级时，布局设计者可以为特定视图修改这些优先级。
子类不应该重写这个方法。

#### func contentHuggingPriority(for: NSLayoutConstraint.Axis) -> UILayoutPriority
返回视图拒绝被设置为大于其固有大小的优先级。

#### func setContentHuggingPriority(UILayoutPriority, for: NSLayoutConstraint.Axis)
设置使视图不被设置为大于其固有大小的优先级。

自定义视图应该在创建时根据它们的内容为这两个方向设置默认值，通常为UILayoutPriorityDefaultLow或UILayoutPriorityDefaultHigh。在创建用户界面时，当总体布局设计需要不同于界面中使用的视图的自然优先级时，布局设计者可以为特定视图修改这些优先级。
子类不应该重写这个方法。

**重要文章：**
[详解intrinsicContentSize 及 约束优先级／content Hugging／content Compression Resistance](UIView属性详解/intrinsicContentSize及约束优先级/只有20%的iOS程序员能看懂：详解intrinsicContentSize%20及%20约束优先级／content%20Hugging／content%20Compression%20Resistance_hard_m.pdf)

### Aligning Views in Auto Layout

#### func alignmentRect(forFrame: CGRect) -> CGRect
Returns the view’s alignment rectangle for a given frame.
`func alignmentRect(forFrame frame: CGRect) -> CGRect`
**frame**
需要其相应对齐矩形的框架。
讨论
基于约束的布局系统使用对齐矩形(alignment rect)来对齐视图，而不是它们的frame。这允许自定义视图根据其内容的位置对齐，同时仍然有一个frame，其中包含他们需要围绕其内容绘制的任何装饰，如阴影或反射。
次方法的默认实现是返回由视图的alignmentRectInsets修改的视图frame。大多数自定义视图都可以使用alignmentRectInsets来指定其内容在frame中的位置。需要任意转换的自定义视图可以override `alignmentRect(forFrame:)`和`frame(forAlignmentRect:)`来描述其内容的位置。这两种方法必须始终是相反的。

#### func frame(forAlignmentRect: CGRect) -> CGRect
Returns the view’s frame for a given alignment rectangle.

#### var alignmentRectInsets: UIEdgeInsets
The insets from the view’s frame that define its alignment rectangle.
这个属性的默认值是一个零值的UIEdgeInsets结构。自定义视图在其内容周围绘制装饰时应该使用此属性(返回与内容边缘对齐的插入:return insets that align with the edges of the content,)，不包括装饰。这允许基于约束的布局系统根据内容(而不仅仅是frame)对齐视图。
如果自定义视图的内容位置不能用一组简单的insets来表示，那么它应该覆盖`alignmentRect(forFrame:)`和`frame(forAlignmentRect:)`来描述它们在对齐矩形和frame之间的自定义转换。

[详细讲解自动布局/对齐矩形（1）](自动布局/对齐矩形(alignment%20rect)/iOS%20利用%20Autolayout%20实现%20view%20间隔自动调整%20-%20掘金.pdf)
[详细讲解自动布局/对齐矩形（2）](自动布局/系统理解%20iOS%20自动布局%20|%20楚权的世界.pdf)

#### var forFirstBaselineLayout: UIView
Returns a view used to satisfy first baseline constraints.
对于具有多行文本的视图，第一个基线是最上面一行的基线。
当你对视图的NSLayoutConstraint.Attribute.firstBaseline属性做一个约束时，Auto Layout会使用这个方法返回的视图的基线。如果该视图没有基线，自动布局将使用视图的上边缘。
重写此属性以返回基于文本的子视图(例如，UILabel或非滚动的UITextView)。返回的视图必须是接收方的子视图。默认实现返回forLastBaselineLayout包含的值。
请注意
如果相同的子视图适用于第一个和最后一个基线，你只需要重写forLastBaselineLayout getter方法。


#### var forLastBaselineLayout: UIView
Returns a view used to satisfy last baseline constraints.
对于具有多行文本的视图，最后的基线是最下面一行的基线。
当你对视图的NSLayoutConstraint.Attribute.lastBaseline属性进行约束时，Auto Layout会使用这个方法返回的视图基线。如果该视图没有基线，自动布局将使用视图的底部边缘。
重写此属性以返回基于文本的子视图(例如，UILabel或非滚动的UITextView)。返回的视图必须是接收方的子视图。默认实现返回接收视图。

AutoLayout中的baseline对齐:
通常是对有文本显示功能的两个或者多个视图进行约束，NSLayoutAttributeLastBaseline 文本的最后一行、NSLayoutAttributeFirstBaseline文本的第一行，在UIView中有viewForFirstBaselineLayout、viewForLastBaselineLayout两个只读属性，在自定义的视图中，重写它们的getter方法返回某一子视图，然后就可以对这个自定义的视图使用baseline约束了。

### Triggering Auto Layout 触发自动布局

#### func needsUpdateConstraints() -> Bool
A Boolean value that determines whether the view’s constraints need updating.
一个布尔值，用于确定视图的约束是否需要更新。
基于约束的布局系统使用这个方法的返回值来确定是否需要在视图上调用`updateConstraints()`作为常规布局传递的一部分。

#### func setNeedsUpdateConstraints()
Controls whether the view’s constraints need updating.
当自定义视图的属性发生影响约束的变化时，可以调用此方法来指示约束需要在将来的某个时间点更新。然后，系统将调用updateConstraints()作为其常规布局传递的一部分。将此作为批量处理约束更改的优化工具。在需要更新约束之前一次性更新约束，可以确保在布局过程中对视图进行多次更改时，不必重新计算约束。

#### func updateConstraints()
Updates constraints for the view.
**讨论**
重写此方法以优化对约束的更改。
**请注意**
在有影响的更改发生后立即更新约束几乎总是更简洁和更容易。例如，如果您想要更改一个约束以响应按钮点击，可以直接在按钮的action方法中进行更改。
只有在适当的约束更改太慢或视图产生大量冗余更改时，才应该重写此方法。
要安排更改，请在视图上调用setNeedsUpdateConstraints()。然后，在布局发生之前，系统调用updateConstraints()的实现。这让您可以在自定义视图的属性没有改变时，验证内容的所有必要约束是否已经到位。
您的实现必须尽可能高效。不要取消你所有的约束，然后重新激活你需要的。相反，应用程序必须有某种方式来跟踪约束，并在每次更新过程中验证它们。只更改需要更改的项。在每次更新过程中，必须确保对应用程序的当前状态有适当的约束。
不要在你的实现中调用setNeedsUpdateConstraints()。调用setNeedsUpdateConstraints()计划另一个更新传递，创建一个反馈循环。
**重要的**
调用[super updateConstraints]作为实现的最后一步。

#### func updateConstraintsIfNeeded()
Updates the constraints for the receiving view and its subviews.
更新接收视图及其子视图的约束。

每当一个视图的新布局通过被触发时，系统调用这个方法来确保视图及其子视图的任何约束都被来自当前视图层次结构及其约束的信息更新。该方法由系统自动调用，但如果您需要检查最新的约束，则可以手动调用该方法。
子类不应该重写这个方法。

[Auto Layout 中的 setNeedsUpdateConstraints 和 layoutIfNeeded - 掘金](自动布局/自动布局流程/Auto%20Layout%20中的%20setNeedsUpdateConstraints%20和%20layoutIfNeeded%20-%20掘金.pdf)

[关于ios：setNeedsLayout与setNeedsUpdateConstraints和layoutIfNeeded vs updateConstraintsIfNeeded | 码农家园](自动布局/自动布局流程/关于ios：setNeedsLayout与setNeedsUpdateConstraints和layoutIfNeeded%20vs%20updateConstraintsIfNeeded%20|%20码农家园.pdf)

[iOS中AutoLayer自动布局流程及相关方法 - whj的个人空间 - OSCHINA - 中文开源技术交流社区](自动布局/自动布局流程/iOS中AutoLayer自动布局流程及相关方法%20-%20whj的个人空间%20-%20OSCHINA%20-%20中文开源技术交流社区.pdf)

### Adjusting the User Interface

#### var overrideUserInterfaceStyle: UIUserInterfaceStyle
视图及其所有子视图所采用的用户界面样式。
`var overrideUserInterfaceStyle: UIUserInterfaceStyle { get set }`
使用此属性可强制视图始终采用亮或暗的界面样式。这个属性的默认值是`UIUserInterfaceStyle.unspecified`，它导致视图从父视图或视图控制器继承接口样式。
如果你指定了一个不同的值，新的样式会应用到同一个视图控制器所拥有的视图和所有子视图。(如果视图层次结构包含嵌入子视图控制器的根视图，则子视图控制器及其视图不会继承接口样式。)
如果视图是一个UIWindow对象，新的样式会应用到窗口中的所有东西，包括根视图控制器和所有呈现的内容。
[iOS13简单适配 - 包含UIUserInterfaceStyle讲解及其适配](UIView属性详解/杂项/iOS13简单适配%20-%20简书.pdf)

#### var semanticContentAttribute: UISemanticContentAttribute
视图内容的语义描述，用于确定在从左到右和从右到左的布局之间切换时视图是否应该翻转。
当在从左到右和从右到左的布局之间切换时，一些视图不应该翻转。例如，视图是回放控件的一部分，或者表示不改变的物理方向(上、下、左、右)。与其考虑视图是否应该改变其方向，不如选择最适合描述视图的语义内容属性。
当创建包含子视图的视图时，您可以使用userInterfaceLayoutDirection(for:)类方法来确定是否应该翻转子视图，并以适当的顺序布局视图。
有关可能的值的列表，请参见UISemanticContentAttribute。
```
public enum UISemanticContentAttribute : Int {

    case unspecified = 0 

    case playback = 1

    case spatial = 2

    case forceLeftToRight = 3

    case forceRightToLeft = 4
}
```
**unspecified**:视图的默认值。视图在从左到右和从右到左的布局之间切换时会翻转。
**playback**:A view representing the playback controls, such as Play, Rewind, or Fast Forward buttons or playhead scrubbers. These views are not flipped when switching between left-to-right and right-to-left layouts.
**spatial**:一种表示方向控制的视图，例如用于文本对齐的段控制，或用于游戏的方向键控制。在从左到右和从右到左的布局之间切换时，这些视图不会被翻转。
**forceLeftToRight**:始终使用从左到右的布局显示的视图。
**forceRightToLeft**:A view that is always displayed using a right-to-left layout.


#### var effectiveUserInterfaceLayoutDirection: UIUserInterfaceLayoutDirection
适合于安排视图的直接内容的用户界面布局方向。
在安排或绘制视图的直接内容时，应该始终查看此属性的值。此外，请注意，不能假设值通过视图的子树传播。
```
public enum UIUserInterfaceLayoutDirection : Int {
    case leftToRight = 0

    case rightToLeft = 1
}
```

#### class func userInterfaceLayoutDirection(for: UISemanticContentAttribute) -> UIUserInterfaceLayoutDirection
Returns the user interface direction for the given semantic content attribute.
通过调用userInterfaceLayoutDirectionForSemanticContentAttribute:方法获取UIView实例的布局方向

#### class func userInterfaceLayoutDirection(for: UISemanticContentAttribute, relativeTo: UIUserInterfaceLayoutDirection) -> UIUserInterfaceLayoutDirection
Returns the layout direction implied by the specified semantic content attribute, relative to the specified layout direction.

相关文章：了解即可
[iOS 阿拉伯语 RTL适配](https://blog.csdn.net/a657651096/article/details/102805114)
[App的国际化和本地化（六） —— 支持从右到左的语言（一）](https://www.jianshu.com/p/89deaa97ed9a)

#### Constraining Views to the Keyboard

`var keyboardLayoutGuide: UIKeyboardLayoutGuide`
A layout guide that tracks the keyboard’s position in your app’s layout.
`@MainActor class UIKeyboardLayoutGuide : UITrackingLayoutGuide`：一个布局指南，它代表了键盘在应用布局中所占的空间。
`@MainActor class UITrackingLayoutGuide : UILayoutGuide`: 一个布局指南，自动激活和关闭布局约束，取决于其接近边缘。
`@MainActor class UILayoutGuide : NSObject`:一个可以与自动布局交互的矩形区域。

**相关第三方库**


#### Adding and Removing Interactions

`func addInteraction(UIInteraction)`
Adds an interaction to the view.

`func removeInteraction(UIInteraction)`
Removes an interaction from the view.

`var interactions: [UIInteraction]`
The array of interactions for the view.

`protocol UIInteraction`
The protocol that an interaction implements to access the view that owns it.

#### Drawing and Updating the View
`func draw(CGRect)`
Draws the receiver’s image within the passed-in rectangle.

`func setNeedsDisplay()`
Marks the receiver’s entire bounds rectangle as needing to be redrawn.

`func setNeedsDisplay(CGRect)`
Marks the specified rectangle of the receiver as needing to be redrawn.

`var contentScaleFactor: CGFloat`
The scale factor applied to the view.
讨论
比例因子决定视图中的内容如何从逻辑坐标空间(以点度量)映射到设备坐标空间(以像素度量)。该值通常为1.0或2.0。更高的比例因子表明视图中的每个点在底层层中由多个像素表示。例如，如果比例因子是2.0，而视图帧的大小是50 x 50点，那么用于显示内容的位图的大小是100 x 100像素。
此属性的默认值是与当前显示视图的屏幕相关联的比例因子。如果你的自定义视图实现了一个自定义绘制(_:)方法并与一个窗口相关联，或者如果你使用GLKView类来绘制OpenGL ES内容，你的视图将以屏幕的全分辨率绘制。对于系统视图，即使在高分辨率屏幕上，该属性的值也可能是1.0。
通常，您不需要修改此属性中的值。但是，如果您的应用程序使用OpenGL ES绘图，您可能需要更改比例因子以换取图像质量来换取渲染性能。有关如何调整OpenGL ES渲染环境的更多信息，请参见《OpenGL ES编程指南》中的“支持高分辨率显示”。

`func tintColorDidChange()`
Called by the system when the tintColor property changes.

#### Updating the View When Property Values Change 当属性值改变时更新视图

`struct UIView.Invalidating`
A property wrapper that notifies the system that a property value change has invalidated an aspect of the containing view.

The following example uses the UIView.Invalidating wrapper with the display type on the property badgeColor and the display and layout type on the property badgePosition.

```
class MyView: UIView {
    @Invalidating(.display) var badgeColor: UIColor
    
    @Invalidating(.display, .layout) var badgePosition: UIRectEdge
}
```

When you change the badge color, the property wrapper calls setNeedsDisplay(), causing the system to redraw the view. When you change the badge position, the property wrapper also calls setNeedsLayout(), causing the system to update the view’s subviews before it redraws.

`protocol UIViewInvalidating`
Implements a type of invalidation that can occur on a view that requires an update.

#### Formatting Printed View Content
打印相关 了解
`func viewPrintFormatter() -> UIViewPrintFormatter`
Returns a print formatter for the receiving view.返回视图的打印格式化

`func draw(CGRect, for: UIViewPrintFormatter)`
Implemented to draw the view’s content for printing.指定区域和打印格式绘画视图内容

#### Managing Gesture Recognizers
`func addGestureRecognizer(UIGestureRecognizer)`

`func removeGestureRecognizer(UIGestureRecognizer)`

`var gestureRecognizers: [UIGestureRecognizer]?`

`func gestureRecognizerShouldBegin(UIGestureRecognizer) -> Bool`
[iOS文档补完计划--UIGestureRecognizer](https://www.jianshu.com/p/77929a4baa43)