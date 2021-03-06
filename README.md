# Behaviourtree

> 可参看饥荒行为树，本例子就是从该游戏中抽离

#### 行为树介绍

> 在处理AI上行为树比较常见，相比常规的状态机，优点显而易见，第一：拓展性高，第二：整个结构非常清晰,第三：复用性高

#### 举个例子（摘自网上）
> 做个猫的AI,行为如下：1、看到mouse会去catch（mouseinsight） 2、看到dog会runaway（doginsight） 3、二者都看不到的时候standstill 4、二者都看到的时候会runaway

先用状态机做出AI：

![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/1.png)

然后选用行为树：

![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/2.png)


>对比可以看出，行为树明显结构清晰，方便拓展，状态机的状态之间跳转随着状态的增加会越复杂，如果需要再加状态：比如 在runaway的时候播放固定的声音，在catch的时候首先需要chase目标mouse 然后到达位置的时候在combat，看行为树的实现：


![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/3.png)


> 方框：逻辑节点 控制行为的走向，波浪线：行为节点 具体的表现。整个流程可以这样来描述：每时每刻他都从根节点开始遍历并判断“我可以做这个吗？”如果不可以，他会继续向下遍历他的子节点，子子节点，直到找到它可以做的分支，然后就如是做。所以这意味着行为树越往上的节点拥有越高的优先权。行为树最终结果是要找到一个叶节点，也就是一个具体的行为，如果找不到，就会按逻辑继续找下去

#### 下面分析下具体实现
* Brain

>  BrainManager 管理所有大脑，Brain具体的大脑，负责行为树的创建，特定行为的书写。

* 序列（Sequence）节点

> 顺序迭代子节点，如果子节点failed或者running状态那么返回子节点状态，直到全部成功迭代完成返回success

* ParallelNode

> 并行执行子节点，一帧执行完成，其中某一个执行返回false 则Parallel节点返回false，全部成功则算成功

* ParallelNodeAny

> 并行执行子节点，一帧执行完成，只需任何一个完成即可返回success

* Selector Node

> 顺序迭代子节点，选择子节点中处于running或者success状态的子节点，如果不存在则返回failed，简而言之 就是选择一个可执行的子节点运行

* Loop Node

> 循环节点，该逻辑节点的所有子节点循环N次，如果循环过程中子节点running或者failed返回该状态，循环完成需重置子节点，全部执行完成返回success






