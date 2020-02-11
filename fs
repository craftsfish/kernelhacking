不同的namespace维护了独立的目录树？是的，clone namespace的时候会把整个tree复制一遍
clone namespace的时候shared mount会怎么处理？根据Documentation/filesystems/sharedsubtree.txt，应该会把所有的namespace的shared mount串起来
mount --bind A/a B/b => 增加一个独立mount条目，A的src挂在到B/b，根目录是A/a，所以这个时候在A/a下面的mount不会反映到B/b下面

task->fsuid：task用于文件系统访问的uid?有没有task->uid?
