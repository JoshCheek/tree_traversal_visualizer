Tree Traversal Visualizer
=========================

> Good lord, the internet is horrible at explaining things! I legit might make
> a post about prefix vs infix vs postfix tree traversal, just because of how bad
> all [these](https://www.google.com/search?safe=off&biw=1440&bih=816&tbm=isch&sa=1&ei=iIVmW5jTAsjV5gKMkJPYBQ&q=preorder+traversal+tree&oq=preorder+traversal+tree&gs_l=img.3..0i8i30l5j0i24.3013.4124..4320...0.0...81.487.8......1....1..gws-wiz-img.......0i8i7i30.XRchNSkZJs4)
> images are -.-
>
> -- [@josh_cheek](https://twitter.com/josh_cheek/status/1025973617979473920)

Done.


Preorder
--------

```ruby
def traverse(tree, &block)
  block.call tree.data # preorder
  traverse tree.left, list, &block
  traverse tree.right, list, &block
end
```

![preorder tree traversal animation](images/preorder-tree-traversal.gif)


Inorder
-------

```ruby
def traverse(tree, &block)
  traverse tree.left, list, &block
  block.call tree.data # inorder
  traverse tree.right, list, &block
end
```

![preorder tree traversal animation](images/inorder-tree-traversal.gif)


Postorder
---------

```ruby
def traverse(tree, &block)
  traverse tree.left, list, &block
  traverse tree.right, list, &block
  block.call tree.data # postorder
end
```

![preorder tree traversal animation](images/postorder-tree-traversal.gif)


To run the code
---------------

You'll need [Ryan Davis](https://twitter.com/the_zenspider)'s
[Graphics](https://github.com/zenspider/graphics) library.

[Here](http://rayhightower.com/blog/2017/02/15/animated-graphics-in-ruby/)
are some nice installation instructions by
[Ray Hightower](https://twitter.com/RayHightower).


License
-------

[![wtfpl](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-1.png)](http://www.wtfpl.net/about/)

Just do what the fuck you want to.
