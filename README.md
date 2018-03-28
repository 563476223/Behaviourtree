# Behaviourtree

>> 可参看饥荒行为树，本例子就是从该游戏中抽离

###行为树介绍

>> 在处理AI上行为树比较常见，相比常规的状态机，优点显而易见，第一：拓展性高，第二：整个结构非常清晰

举个例子（摘自网上）
>> 做个猫的AI,行为如下：1、看到mouse会去catch（mouseinsight） 2、看到dog会runaway（doginsight） 3、二者都看不到的时候standstill 4、二者都看到的时候会runaway

先用状态机做出AI：
![image](Behaviourtree/image/1.png)
