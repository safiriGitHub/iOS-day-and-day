
布局边距在视图的内容和视图边界之外的任何内容之间提供了一个视觉缓冲区。布局边距由视图的每个边(顶部、底部、前边和尾部)的插入值组成。这些插入值在视图边界矩形的边缘和视图内的内容之间创建一个空间。图1显示了两个具有不同布局边距集的视图。除了它们在你的内容周围添加的空白，边距没有可见的表示。

要设置遵循布局边距的约束，可以在Xcode中启用约束到边距选项，如图2所示。(如果你不启用该选项，Xcode会创建相对于视图边界矩形的约束。)如果父视图的边距后来发生了变化，与这些边距关联的元素的位置也会相应更新。

即使您没有使用约束来定位内容，您仍然可以手动定位相对于视图布局边距的内容。每个视图的directionalLayoutMargins属性包含用于视图边距的边缘插入值。当计算项目在视图中的位置时，请考虑这些边距值。

Change the Default Layout Margins

UIKit为每个视图提供默认的布局边距，但你可以将默认值更改为更适合你的视图的值。要更改视图的边距值，请更新视图的directionalLayoutMargins属性。(您也可以在设计时使用Size检查器来设置该属性的值。在Layout Margins部分，选择Language Directional选项，并输入每个视图边缘的边距值，如图3所示。)

对于视图控制器的根视图，UIKit强制一组最小的布局边距，以确保内容正确显示。当directionalLayoutMargins属性中的值小于最小值时，UIKit会使用最小值代替。你可以从视图控制器的systemMinimumLayoutMargins属性中获得最小边距值。为了防止UIKit应用最小边距，设置视图控制器的viewRespectsSystemMinimumLayoutMargins属性为false。

视图的实际边距是使用视图的配置和它的directionalLayoutMargins属性的值计算的。视图的边距受insetsLayoutMarginsFromSafeArea的设置影响，并保留superviewlayoutmargins属性，该属性可以增加默认边距值，以确保内容的适当间距。


- directionalLayoutMargins 
  `var directionalLayoutMargins: NSDirectionalEdgeInsets { get set }`

在视图中布局内容时使用的默认间距。
使用此属性指定视图及其子视图的边缘之间所需的空间量(以点为单位)。The leading and trailing margins将根据当前的布局方向适当地应用于左或右边距。例如，在从右到左的布局中，leading margin应用于视图的右边缘。对于大多数视图，默认的布局边距是每边8个点。您可以根据设计的需要更改这些值。
对于视图控制器的根视图，此属性的默认值反映了系统最小边距和safe area insets。对于视图层次结构中的其他子视图，默认的布局边距通常是每边8个点，但如果视图不是完全在安全区域内，或者如果preservesSuperviewLayoutMargins属性为true，值可能会更大。
自动布局使用你的页边距作为放置内容的提示。例如，如果你使用格式字符串" |-[subview]-| "指定一组水平约束，子视图的leading and trailing edges 将由相应的布局边距从父视图的边缘插入。当视图的边缘接近父视图的边缘，并且preservesSuperviewLayoutMargins属性为true时，实际的布局边距可能会增加，以防止内容与父视图的边距重叠。

- systemMinimumLayoutMargins
  `var systemMinimumLayoutMargins: NSDirectionalEdgeInsets { get }`
  视图控制器根视图的最小布局边距。

  此属性包含视图控制器根视图的系统期望的最小布局边距。不要重写此属性。要停止考虑根视图的系统最小布局边距，设置viewRespectsSystemMinimumLayoutMargins属性为false。此属性不影响与根视图的子视图关联的边距。
  如果你为视图控制器的根视图的directionalLayoutMargins属性指定一个自定义值，根视图的实际边距将被设置为自定义值或该属性定义的最小值(取较大的值)。例如，如果一个系统的最小边际值是20点，而您在视图上为相同的边际值指定了10点，则视图将使用值20作为边际值。

  - viewRespectsSystemMinimumLayoutMargins
    
    一个布尔值，指示视图控制器的视图是否使用系统定义的最小布局边距。

    `var viewRespectsSystemMinimumLayoutMargins: Bool { get set }`

    当此属性的值为true时，根视图的布局边距保证不小于systemMinimumLayoutMargins属性中的值。此属性的默认值为true。
    
    将此属性更改为false会导致视图仅从其directionalLayoutMargins属性获取其边距。将该属性中的边距设置为0允许您完全消除视图的边距。


- insetsLayoutMarginsFromSafeArea

一个布尔值，指示视图的布局边距是否自动更新以反映安全区域。

`var insetsLayoutMarginsFromSafeArea: Bool { get set }`

当此属性的值为true时，安全区域之外的任何边距将被自动修改为属于安全区域边界。此属性的默认值为true。将该值更改为false允许您的边距保持在原来的位置，即使它们不在安全区域内。
如果你不想让safeAreaInsets影响你的视图布局，则可以将insetsLayoutMarginsFromSafeArea设置为NO，所有的视图布局将会忽略safeAreaInsets这个属性了。要注意的是，insetsLayoutMarginsFromSafeArea仅用于使用代码实现AutoLayout（如果你是使用Xib或者SB布局你的视图，那么对该属性的设置是无效的，至少我没有发现怎么可以让布局产生变化），即使该属性为NO，视图的safeAreaInsets还是一样有值，而且安全区域变更方法safeAreaInsetsDidChange一样被调用。

- preservesSuperviewLayoutMargins

一个布尔值，指示当前视图是否也尊重其父视图的边距。

`var preservesSuperviewLayoutMargins: Bool { get set }`

当此属性的值为true时，父视图的边距在布局内容时也会被考虑。这个边距会影响视图和父视图之间的距离小于相应边距的布局。例如，您可能有一个内容视图，其框架精确地匹配其父视图的边界。当任何父视图的边距在内容视图和它自己的边距所代表的区域内时，UIKit调整内容视图的布局以尊重父视图的边距。调整的数量是确保内容也在父视图的边距内所需的最小数量。
此属性的默认值为false。

