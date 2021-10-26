Positioning Content Relative to the Safe Area
定位视图，使其不受其他内容的阻碍。

安全区域帮助您将视图放置在整个界面的可见部分中。uikit定义的视图控制器可能会在你的内容顶部放置特殊视图。例如，导航控制器将导航条显示在底层视图控制器内容的顶部。即使这样的视图是部分透明的，它们仍然会遮挡它们下面的内容。

使用安全区域作为布局内容的辅助。每个视图都有自己的布局指南(可从safeAreaLayoutGuide属性访问)，您可以使用它为视图中的项创建约束。如果你没有使用Auto Layout来定位你的视图，你可以从视图的safeAreaInsets属性获取原始的插入值。
图1显示了Calendar应用程序的两个不同视图以及与每个视图相关联的安全区域。
![Figure 1 The safe area of an interface](https://docs-assets.developer.apple.com/published/dbcc36bfb3/e5aca39a-f9a2-4ab8-9f45-08fd95fb845c.png)

 
扩展安全区以包括自定义视图
你的容器视图控制器可以在嵌入的子视图控制器的视图上显示它自己的内容视图。在这种情况下，更新子视图控制器的安全区，以排除容器视图控制器的内容视图所覆盖的区域。UIKit容器视图控制器已经调整了子视图控制器的安全区域来考虑内容视图。例如，导航控制器扩展了其子视图控制器的安全区域，以考虑导航栏。

要扩展嵌入式子视图控制器的安全区域，请修改它的`additionalSafeAreaInsets`属性。假设您定义了一个容器视图控制器，它沿着屏幕的底部和右侧边缘显示定制视图，如图2所示。因为子视图控制器的内容在自定义视图的下面，你必须扩展子视图控制器的安全区域的底部和右侧的插入来考虑那些视图。

![Figure 2 Extending the safe area of a child view controller](https://docs-assets.developer.apple.com/published/29ea4c9db6/419597f1-8b60-47bb-a8af-2d2f6809f2dc.png)

清单1显示了容器视图控制器的`viewDidAppear(_:)`方法，它扩展了其子视图控制器的安全区域，以解释自定义视图，请在此方法中进行修改，因为只有将视图添加到视图层次结构中，视图的安全区插入才会准确。

Listing 1 Adjusting the safe area of a child view controller
```
override func viewDidAppear(_ animated: Bool) {
   var newSafeArea = UIEdgeInsets()
   // Adjust the safe area to accommodate 
   //  the width of the side view.
   if let sideViewWidth = sideView?.bounds.size.width {
      newSafeArea.right += sideViewWidth
   }
   // Adjust the safe area to accommodate 
   //  the height of the bottom view.
   if let bottomViewHeight = bottomView?.bounds.size.height {
      newSafeArea.bottom += bottomViewHeight
   }
   // Adjust the safe area insets of the 
   //  embedded child view controller.
   let child = self.childViewControllers[0]
   child.additionalSafeAreaInsets = newSafeArea
}
```