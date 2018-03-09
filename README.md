jieba_fast
========
使用`cpython`重写了jieba分词库中计算DAG和HMM中的vitrebi函数，速度得到大幅提升。
使用`import jieba_fast as jieba` 可以无缝衔接源代码。

特点
========
* 对两种分词模式进行的加速：精确模式，搜索引擎模式
* 利用`cython`重新实现了viterbi算法，使默认带HMM的切词模式速度大幅提升
* 利用`cython`重新实现了生成DAG以及从DAG计算最优路径的算法，速度大幅提升
* 基本只是替换了核心函数，对源代码的侵入型很小
* MIT 授权协议




安装说明
=======

代码目前对 Python 2/3 兼容，对*unix兼容良好，windows本地编译测试通过，但不保证。

* 全自动安装：`pip install jieba_fast`
* 半自动安装：先下载 http://pypi.python.org/pypi/jieba_fast/ ，解压后运行 `python setup.py install`

关于windows的编译过程中可能会有一些坑，可以尝试我编译好的版本，将编译好的放在了windows/下，分别对应的是python2.7与python3.5。
如果你想安装python2版本的jiaba_fast，将python2下的所有目录与文件拷至对应python的lib/site-packages下就ok。

算法
========

* 基于前缀词典实现高效的词图扫描，生成句子中汉字所有可能成词情况所构成的有向无环图 (DAG)
* 采用了动态规划查找最大概率路径, 找出基于词频的最大切分组合
* 对于未登录词，采用了基于汉字成词能力的 HMM 模型，使用了 Viterbi 算法




主要功能
=======

详情见 https://github.com/fxsjy/jieba


代码示例

```python
# encoding=utf-8
import jieba_fast as jieba

text = u'在输出层后再增加CRF层，加强了文本间信息的相关性，针对序列标注问题，每个句子的每个词都有一个标注结果，对句子中第i个词进行高维特征的抽取，通过学习特征到标注结果的映射，可以得到特征到任>      意标签的概率，通过这些概率，得到最优序列结果'

print("-".join(jieba.lcut(text, HMM=True))
print('-'.join(jieba.lcut(text, HMM=False)))

```

输出:

```python
在-输出-层后-再-增加-CRF-层-，-加强-了-文本-间-信息-的-相关性-，-针对-序列-标注-问题-，-每个-句子-的-每个-词-都-有-一个-标注-结果-，-对-句子-中-第-i-个-词-进行-高维-特征-的-抽取-，-通过-学习-特征-到-标注-结果-的-映射-，-可以-得到-特征-到-任意-标签-的-概率-，-通过-这些-概率-，-得到-最优-序列-结果
```

```python
在-输出-层-后-再-增加-CRF-层-，-加强-了-文本-间-信息-的-相关性-，-针对-序列-标注-问题-，-每个-句子-的-每个-词-都-有-一个-标注-结果-，-对-句子-中-第-i-个-词-进行-高维-特征-的-抽取-，-通过-学习-特征-到-标注-结果-的-映射-，-可以-得到-特征-到-任意-标签-的-概率-，-通过-这些-概率-，-得到-最优-序列-结果
```




性能测试
=======
测试机器 mbp17， i7， 16G

测试过程：
先按行读取文本《围城》到一个数组里，然后循环对《围城》每行文字作为一个句子进行分词。然后循环对围城这本书分词50次。分词算法分别采用【开启HMM的精确模式】、【关闭HMM的精确模式】、【开启HMM的搜索引擎模式】、【开启HMM的搜索引擎模式】
具体测试数据如下：


|            | 开启HMM的精确模式 | 关闭HMM的精确模式 | 开启HMM的搜索引擎模式 | 关闭HMM的搜索引擎模式 |
| ---------- | ---------- | ---------- | ------------ | ------------ |
| jieba      | 65.1s      | 39.9s      | 67.5s        | 40.5s        |
| jieba_fast | 24.5s      | 18.2s      | 25.3s        | 20.4s        |

可以看出在开启HMM模式下时间缩减了60%左右，关闭HMM时时间缩减了50%左右。



 一致性测试
======

为了保证jieba_fast和jieba分词结果相同，做了如下测试。

对《围城》，《红楼梦》分词结果进行比较，其分词结果完全一致

```python
---- Test of 围城 ----
nums of jieba      results:  164821
nums of jieba_fast results:  164821
Are they exactly the same?  True
----Test of 红楼梦 ----
nums of jieba      results:  597151
nums of jieba_fast results:  597151
Are they exactly the same?  True
```



鸣谢
======

"结巴"中文分词作者: [SunJunyi](https://github.com/fxsjy)

源码见 source/
