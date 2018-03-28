# Behaviourtree

>> 可参看饥荒行为树，本例子就是从该游戏中抽离

#### 行为树介绍

>> 在处理AI上行为树比较常见，相比常规的状态机，优点显而易见，第一：拓展性高，第二：整个结构非常清晰

#### 举个例子（摘自网上）
>> 做个猫的AI,行为如下：1、看到mouse会去catch（mouseinsight） 2、看到dog会runaway（doginsight） 3、二者都看不到的时候standstill 4、二者都看到的时候会runaway

先用状态机做出AI：

![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/1.png)

然后选用行为树：

![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/2.png)


>>对比可以看出，行为树明显结构清晰，方便拓展，状态机的状态之间跳转随着状态的增加会越复杂，如果需要再加状态：比如 在runaway的时候播放固定的声音，在catch的时候首先需要chase目标mouse 然后到达位置的时候在combat，看行为树的实现：


![状态机](https://github.com/563476223/Behaviourtree/blob/master/image/3.png)



