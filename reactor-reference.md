# Reactor3 高性能反应式编程参考手册
## Flux 和 Mono
Flux 为Reactor中核心概念，是一个发布者(Publisher)，代表一个 0..N 元素(element/item)的异步序列(sequence)，N 可能是无限的(infinite)，例如：Flux.interval(Duration.ofSeconds(1))，1秒钟发送(emit)一次，值为递增的一个数字。<br/>
Mono 是一个特殊的 Flux，一般用于表示0..1个返回结果；Flux侧重序列、流动，Mono侧重个体、结果。<br/>
在订阅(subscribe)后，Flux 中的元素会源源不断的向下游(downstream)传递，中间可以进行各种操作符(Operator)转换(transform)，最终传递到订阅者(Subscriber)中，满足下面三个条件之一，传递过程将结束：
- Flux 中元素发送完成。
- 过程中发生异常。
- 订阅者取消(cancel)。

下图为 Flux 执行过程：<br/>
![Reactor Flux](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/flux.png?raw=true)

执行特点：
- Flux 中元素不会被下游各种操作(Operator)影响，一个 Flux 可以反复使用。
- Flux 可以同时被多个订阅者订阅，订阅后元素发送相互独立，互不影响。
- **Nothing happens until you subscribe**，Flux 在被订阅者订阅前，所有行为都不会发生。
- 执行顺序和线程模型有关，默认在父线程上执行，通过publishOn()或者subscribeOn()方法可以设置线程模型(Schedulers)。
- 下游(downstream)通过request()方法可以向上游(upstream)发出背压(backpressure)请求，从而影响上游发送(emit)频率。

## Context 上下文
通过方法subscriberContext()设置Context，上游通过Mono.subscriberContext()访问Context。<br/>
通过Conetxt使得在序列的不同操作符处理、以及主子序列中进行数据共享。<br/>
Context 特点：
- 绑定到订阅者(Subscriber)，从下游(downstream)向上游(upstream)传播。
- 不可变性(immutable)，每次修改都会产生一个新的Context。
- 向上传递，上游操作符只能看到下游Context的值，不能看到上游Context的值。
- 就近生效，取最接近的下游Context的值。
- 向内传递，内层序列(inner sequence)可以访问外层序列(main sequence)的Context，反之不行。

## Schedulers 线程模型
Reactor 不强制并发模型，可由开发人员决定线程模型；如果没有特别指定，一般继续运行与前一个操作所在的线程上，最上面的运算符（源）运行在调用subscribe()方法的线程上。<br/>
如果没有特别指定，将会以单线程串行的方式运行，可以通过log()方法查看操作所在线程的名称。<br/>
两种改变线程模型的方法：
- publishOn(): 与调用位置有关，改变后续的操作符到下一个publishOn()之间的线程执行环境。
- subscribeOn(): 与位置无关，影响源头到第一个publishOn()之间的线程执行环境。

如果发现操作没有执行，请记住**nothing happens until you subscribe()**，确认是否在序列的操作链上调用了subscribe()方法。<br>

线程模型：
- 当前线程
  - Schedulers.immediate(): 在调用者线程上继续执行
- 内置线程模型
  - Schedulers.single(): 单例线程
  - Schedulers.elastic(): 弹性线程池，空闲线程在指定时间后销毁。
  - Schedulers.parallel(): 并行线程池，固定线程数，默认个数与CPU个数相同。
- 新建线程模型
  - Schedulers.newSingle(): 自定义单例线程，需要自行管理资源的创建和销毁。
  - Schedulers.newElastic(): 自定义弹性线程池，需要自行管理资源的创建和销毁。
  - Schedulers.newParallel(): 自定义并行线程池，需要自行管理资源的创建和销毁。

## Error 错误处理
**any error in a reactive sequence is a terminal event**，错误是终止事件，发生错误后，会停止序列，向下传播到订阅者和它的onError()方法中。<br/>
错误处理操作符(error-handling operator)可以处理错误，产生一个新的序列(fallback)替换原有(original)序列。<br/>
常见错误处理场景：
- onErrorReturn: 捕获(catch)异常并返回一个静态的默认值。
- onErrorResume: 捕获(catch)异常并执行一个fallback方法，经常配合使用的方法有 Mono.error、Flux.error、Mono.just、Flux.just。
- onErrorMap: 捕获(catch)包装(wrap)后重新抛出(re-throw)，相当于onErrorResume + Mono.error。
- doOnError: 捕获(catch)打印日志(log)后重新抛出(re-throw)。
- Catch, log an error-specific message, and re-throw.
- doFinally: 无论正常完成、取消、错误，最终都会执行doFinally，一般进行清理资源工作。

包装检查型异常(Checked Exception)：
- Mono.error, Flux.error
- Exceptions.propagate, Exceptions.unwrap


## Operators 操作符
### Mono

- **创建** just
```java
// 从一个值创建一个Mono
Mono.just("hello")
```
- **创建** fromCallable
```java
// 从一个Callable创建一个Mono
Mono.fromCallable(() -> "hello")
```
- **创建** fromRunnable
```java
// 从一个Runnable创建一个Mono
 Mono.fromRunnable(() -> System.out.println("hello"))
```
- **创建** defer
```java
// 延迟创建真正的Mono
Mono.defer(() -> Mono.just("hello"))
```
- **创建** empty
```java
// 马上完成的空Mono
Mono.empty()
```
- **转换** map
```java
// 同步转换元素值为新值
Mono.just(5).map(i -> i * i)
```
- **转换** flatMap
```java
// 异步转换元素值为新值
Mono.just(3).flatMap(i -> {
    if (i == 3) {
        return Mono.error(
            new RuntimeException("error")
        );
    } else {
        return Mono.just(i);
    }
})
```
- **转换** flatMapMany
```java
// Mono转换为Flux
Mono.just(5).flatMapMany(i ->
    Flux.fromArray(new Integer[]{i * 2, i * 3})
)
```
- **默认值** defaultIfEmpty
```java
// 没有数据时提供默认值
Mono.empty().defaultIfEmpty("default")
```
- **默认值** switchIfEmpty
```java
// 没有数据时提供默认值
Mono.empty().switchIfEmpty(Mono.defer(() ->
    Mono.just("hello"))
)
```
- **条件分支** filter
```java
// 过滤
Mono.just(5).filter(i -> i == 5)
```
- **条件分支** when
```java
// 聚合一组发布者数据，直到都成功或者出现错误，异步执行
Mono.when(
    Mono.defer(() -> Mono.just(5)),
    Mono.defer(() -> Mono.just(6 / 0))
)
```
- **条件分支** then
```java
// 完成当前Mono，并执行另一个Mono
Mono.just(5).then(Mono.just(6))
```
- **条件分支** thenMany
```java
// 完成当前Mono，并执行另一个Flux
Mono.just(5).thenMany(Flux.just(6))
```
- **上下文** subscriberContext
```java
// 创建一个上下文向上游传递，向下就近获取当前上下文
Mono.just(5).flatMap(s ->
    Mono.subscriberContext().map(ctx ->
        ctx.getOrDefault("key", "default") + s
    )
).subscriberContext(Context.of("key", "hello"))
```
- **异常** error
```java
// 创建一个MonoError向下游传递
Mono.error(new RuntimeException("error"))
```
- **异常** doOnError
```java
// 异常hook
Mono.defer(() -> Mono.just(6 / 0))
    .doOnError(e -> System.out.println(e.getMessage()))
```
- **异常** onErrorResume
```java
// 错误处理
Mono.defer(() -> Mono.just(6 / 0))
    .onErrorResume(e -> Mono.just(-1))
```
- **异常** doFinally
```java
// 最终处理，一般用于资源清理
Scheduler scheduler = Schedulers.newParallel("test");
Mono.defer(() -> Mono.just(6 / 0))
    .onErrorResume(e -> Mono.just(-1))
    .doFinally(s -> scheduler.dispose())
```

### Flux

- **创建** just
```java
// 从一组数据创建一个Flux
Flux.just("hello", "world")
```
- **创建** interval
```java
// 每1秒发出一个从0开始递增的整数
Flux.interval(Duration.ofSeconds(1))
```
- **创建** range
```java
// 创建一个从11到20的整数序列
Flux.range(11, 10)
```
- **创建** fromArray
```java
// 从一个数组创建一个Flux
Flux.fromArray(new Integer[]{1, 2, 3})
```
- **创建** fromIterable
```java
// 从一个迭代器创建一个Flux
Flux.fromIterable(Arrays.asList("hello", "world"))
```
- **创建** fromStream
```java
// 从Stream创建一个Flux
Flux.fromStream(
    IntStream.range(1, 5).mapToObj(i -> i)
)
```
- **创建** defer
```java
// 延迟创建真正的Flux
Flux.defer(() -> Flux.just(1, 2, 3))
```
- **创建** empty
```java
// 马上完成的空序列
Flux.empty()
```
- **创建** generate
```java
// 编程创建Flux，每次只能发出一个信号
Flux.generate(() -> 0, (s, emitter) -> {
    if (s++ > 5) {
        emitter.complete();
    } else {
        emitter.next(s * s);
    }
    return s;
})
```
- **创建** create
```java
// 编程创建Flux，每次可以发出多个信号
Flux.create(emitter -> {
    int i = 0;
    while (i++ < 5) {
        emitter.next(i);
    }
    emitter.complete();
})
```
- **转换** map

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/map.png?raw=true)

```java
// 同步转换元素值为新值
Flux.just(1, 2, 3).map(i -> i * i)
```
- **转换** flatMap
```java
// 异步转换元素值为新值
Flux.just(1, 2, 3).flatMap(i -> {
    if (i == 3) {
        return Mono.error(
            new RuntimeException("error")
        );
    } else {
        return Mono.just(i);
    }
})
```
- **转换** next
```java
// 第一个元素Mono
Flux.just(1, 2, 3).next()
```
- **转换** last
```java
// 最后一个元素Mono
Flux.just(1, 2, 3).last()
```
- **转换** collect

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/collect.png?raw=true)

```java
// 收集序列中所有元素Mono
Flux.just(1, 2, 3).collect(
    () -> new AtomicInteger(),
    (i, n) -> i.addAndGet(n)
)
```
- **转换** collectList

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/collectList.png?raw=true)

```java
// 收集序列中所有元素Mono<List>
Flux.just(1, 2, 3).collectList()
```
- **转换** collectMap
```java
// 收集序列中所有元素Mono<Map>
Flux.just(1, 2, 3).collectMap(i -> "key" + i)
```
- **转换** zipWith

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/zip.png?raw=true)

```java
// 将两个或多个序列合并为元组(turple)
Flux.just("A", "B", "C").zipWith(
    Flux.just(1, 2, 3)
)
```
- **默认值** defaultIfEmpty

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/defaultIfEmpty.png?raw=true)

```java
// 没有数据时提供默认值
Flux.empty().defaultIfEmpty("default")
```
- **默认值** switchIfEmpty
```java
// 没有数据时提供默认值
Flux.empty().switchIfEmpty(Flux.defer(() ->
    Flux.just("hello"))
)
```
- **条件分支** filter

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/filter.png?raw=true)

```java
// 过滤
Flux.just(1, 2, 3).filter(i -> i > 3)
```
- **条件分支** filterWhen
```java
// 动态过滤
Flux.just(1, 2, 3, 4, 5)
    .filterWhen(i -> Flux.just(10, 30, 50).any(j -> i == j / 10))
```
- **条件分支** merge

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/merge.png?raw=true)

```java
// 聚合一组发布者数据，直到都成功或者出现错误
// 异步执行，无序输出
Flux.merge(
    Flux.defer(() -> Flux.just(5)),
    Flux.defer(() -> Flux.just(6 / 0))
)
```
- **条件分支** mergeSequential
```java
// 聚合一组发布者数据，直到都成功或者出现错误
// 异步执行，顺序输出
Flux.mergeSequential(
    Flux.defer(() -> Flux.just(5)),
    Flux.defer(() -> Flux.just(6 / 0))
)
```
- **条件分支** concat

![flux concat](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/concat.png?raw=true)

```java
// 聚合一组发布者数据，直到都成功或者出现错误
// 同步执行，顺序输出
Flux.concat(
    Flux.defer(() -> Flux.just(5)),
    Flux.defer(() -> Flux.just(6 / 0))
)
```
- **条件分支** then

![flux merge](https://github.com/jonathanzhao/imeta-started-guides/blob/master/images/webflux/reactor/then.png?raw=true)

```java
// 完成当前Flux，并执行另一个Mono
Flux.just(1, 2, 3).then(Mono.just(6))
```
- **条件分支** thenMany
```java
// 完成当前Flux，并执行另一个Flux
Flux.just(1, 2, 3).thenMany(Flux.just(6))
```
- **上下文** subscriberContext
```java
// 创建一个上下文向上游传递，向下就近获取当前上下文
Flux.just(1, 2, 3).flatMap(s ->
    Mono.subscriberContext().map(ctx ->
        ctx.getOrDefault("key", "default") + s
    )
).subscriberContext(Context.of("key", "hello"))
```
- **异常** error
```java
// 创建一个MonoError向下游传递
Flux.error(new RuntimeException("error"))
```
- **异常** doOnError
```java
// 异常hook
Flux.defer(() -> Flux.just(6 / 0))
    .doOnError(e -> System.out.println(e.getMessage()))
```
- **异常** onErrorResume
```java
// 错误处理
Flux.defer(() -> Flux.just(6 / 0))
    .onErrorResume(e -> Flux.just(-1))
```
- **异常** doFinally
```java
// 最终处理，一般用于资源清理
Scheduler scheduler = Schedulers.newParallel("test");
Flux.defer(() -> Flux.just(6 / 0))
    .onErrorResume(e -> Flux.just(-1))
    .doFinally(s -> scheduler.dispose())
```
- **并行** parallel & runOn
```java
// 无论是否设置subscribeOn或者publishOn，对于同一个序列，总是在同一个线程上执行。
// 使用parallel和runOn后，同一个序列的操作将在不同线程上执行。
Flux.range(1, 10)
    // 默认CPU核心数量，可以指定个数
    .parallel()
    // 如果不设置runOn，parallel不生效
    .runOn(Schedulers.parallel())
```
- **竞争** first
```java
// 返回最快的竞争资源
Flux.first(
    Flux.defer(() -> {
        ThreadUtils.sleep(200);
        return Flux.just(1);
    }).subscribeOn(Schedulers.elastic()),
    Flux.defer(() -> {
        ThreadUtils.sleep(100);
        return Flux.just(2);
    }).subscribeOn(Schedulers.elastic())
)
```

## Hot vs Cold
**Nothing happens until you subscribe** 是针对 cold 类型发布者(publisher)来说的，即在没有订阅者(subscriber)订阅(subscribe)之前，什么都不会发生。<br/>
对于 hot 类型发布者，无论是否有订阅者订阅，都会发出(emit)数据，新加入的订阅者只能看到新发出的数据。<br/>
just是一个 hot 操作符，在装配时直接捕获值，在订阅时重播；使用defer可以将just转化成cold。
```java
// 装配时已经捕获值
Flux m = Flux.just(1 + delta.getAndIncrement(), 2 + delta.getAndIncrement(), 3 + delta.getAndIncrement());
// 第一个订阅者, replay
m.subscribe(i -> System.out.println(i));
// 第二个订阅者, replay
m.subscribe(i -> System.out.println(i));
// 结果：2 4 6    2 4 6
```
```java
AtomicInteger delta = new AtomicInteger(1);
// 将just转化为cold类型，装配时不再捕获值，只有在订阅时才开始
Flux m = Flux.defer(() -> Flux.just(1 + delta.getAndIncrement(), 2 + delta.getAndIncrement(), 3 + delta.getAndIncrement()));
// 第一个订阅者
m.subscribe(i -> System.out.println(i));
// 第二个订阅者，在delta原有基础上继续求值
m.subscribe(i -> System.out.println(i));
// 结果：2 4 6    5 7 9
```

## Best Practices 最佳实践
- 编码风格：链式操作(chaining)。
- 扁平化(flattened)优于嵌套(nested)，callback 的编码风格一般是嵌套，通过flatMap、then等操作符将嵌套扁平化。
- 不要将空元素加入序列中，如果有，通过filter操作符过滤掉。
- 通过switchIfEmpty或者defaultIfEmpty操作符提供默认值。
- 创建 Flux 的方法不能抛出异常，通过方法Mono.error()包装异常返回。
- 同步方法也包装成Rector风格，通过静态方法 Flux.just() 包装返回值。
- 后续操作仅关心上游的完成/异常信号，使用返回 Mono<Void> 的操作符。
- 分支流程一般使用操作符：filter、then、switchIfEmpty。
- 并行流程一般使用 Flux 操作符：concat、merge、mergeSequential，或者 Mono 操作符 when。
- Flux(序列) 转换成 Mono(结果)一般使用操作符：last、next、then、collet。
- Mono 转换成 Flux 一般使用操作符：flatMapMany、concatWith、mergeWith。

## Notice 注意事项
- subscribe: 在subscribe之前，一切都不会发生（针对cold场景，不适合just操作符），如果操作符没有执行，先确认是否执行了subscribe方法。
- just: just为hot操作符，在装配时已经捕获值，如果不想即时求值，使用defer方法包装just。
- decorator: reactor的操作符使用装饰者模式，返回值为原始序列和附加行为的新的实例，每次的实例都不同，所以推荐链式操作(chaining)。
- chaining: 如果没有使用链式操作，需要将每一段代码的返回值赋值给一个变量(类似字符串substring)，因为每个操作符都会返回一个新的序列，不会影响原始序列。
- then: 使用then的一般场景是上游进行了判断校验，请确认上游是否异常路径都进行了处理。
- filter: 使用filter过滤，下游序列中可能没有符合的数据，一般要和switchIfEmpty配合使用。
- null: 序列中不能有有空值，不要试图向序列中增加空对象，如果数组、集合中有空值，需要先过滤掉再进序列。
- context: subscriberContext方法与调用位置有关，上游操作符使用最接近它的context；上下文不可变(immutable)。
- error: 创建发布者的方法中，不能直接抛出异常，否则 onErrorResume 等异常处理方法无法捕获处理异常；一般通过defer包装，或者返回操作符error()的值。
- scheduler: 注意操作符publishOn的位置，一般使用subscribeOn；如果未指定scheduler，默认全都在调用subscribe方法的线程上执行。
- concurrence: 注意merge(并行、无序)、mergeSquential(并行、顺序)、concat(串行)的区别。
- parallel: parallel操作符执行需要和runOn配合使用，否则不生效。

## In Action 实战
常用的模式有：
- 完成-那么: .. then，后续操作不关心上游结果，只关心完成和错误信号
- 并行-完成-收集: merge .. collect，后续操作依赖并行结果
- 并行-完成-那么: when .. then，后续操作不关心并行结果，只关心完成和错误信号

1. Branch 分支
    ```shell
    # 分支任务
                 A |
    [name!=null] B | -> map
    ```
    ```java
    // 根据条件选择分支
    // merge .. collect
    Flux.merge(
        Flux.just("hello").map(s -> Tuples.of("key", s)),
        Flux.defer(() -> {
            if (name == null) {
                return Flux.empty();
            }
            return Flux.just(name).map(s -> Tuples.of("name", s));
        }))
        // 收集上游操作结果，其它的还有collect、collectList
        .collectMap(t -> t.getT1(), t -> t.getT2())
        .doOnNext(s -> System.out.println(s))
        // Nothing happens until you subscribe
        .subscribe();
    ```

2. ForkJoin 分支合并
    ```shell
    # ForkJoin任务
    A  ->  D |
    B |      | -> F -> true
    C | -> E |
    ```
    ```java
    CountDownLatch latch = new CountDownLatch(1);
    // merge 并行执行(与线程模型有关，单线程时效果为串行)，结果序列顺序不确定
    // mergeSequential 并行执行(与线程模型有关，单线程时效果为串行)，结果序列顺序确定
    // concat 串行执行，结果序列顺序确定
    // Mono.when 相当于 Flux.merge，仅需要上游完成和错误信号时，使用Mono.when。
    // when .. then, .. -> F
    Mono.when(
        // .. then, A -> D
        createJob("A", 2, 900).thenMany(createJob("D", 3, 600)),
        // when .. then, B & C -> E
        Mono.when(
            createJob("B", 3, 200),
            createJob("C", 2, 500)
        ).thenMany(createJob("E", 2, 100))
        // D & E -> F
    ).thenMany(createJob("F", 1, 500))
    // .. then, F -> true
    .then(Mono.just(true))
    .doFinally(s -> {
        // 释放资源
        latch.countDown();
    })
    // Nothing happens until you subscribe
    .subscribe();

    latch.await();
    ```
    ```java
    // createJob(String name, int count, int milli)
    return Flux.<String>create(sink -> {
        for (int i = 1; i <= count; i++) {
            try {
                Thread.sleep(milli);
            } catch (InterruptedException e) {
            }
            sink.next(name + i);
        }
        sink.complete();
        // 如果需要并行，这里需要设置线程模型，否则总在调用subscribe()方法的线程上执行。
    }).subscribeOn(Schedulers.elastic());
    ```

## 中间件
### Redis Lettuce
当使用Lettuce时，默认情况下是单线程处理（nioEventLoop ），在调用后，执行线程切换成该单线程，如果在该线程上还有进行其它运算/操作，可能会抛出异常：
```
org.springframework.dao.QueryTimeoutException:
Redis command timed out; 
nested exception is io.lettuce.core.RedisCommandTimeoutException: 
Command timed out after 2 second(s)
```

这时需要开始computation线程池模式：

```java
@Configuration
public class LettuceCustomizerConfig implements LettuceClientConfigurationBuilderCustomizer {
    @Value("${lettuce.thread-size}")
    private Integer threadPoolSize = 4;

    @Override
    public void customize(LettuceClientConfiguration.LettuceClientConfigurationBuilder clientConfigurationBuilder) {
        clientConfigurationBuilder
            // Use I/O thread，uses EventExecutorGroup configured through ClientResources for data/completion signals
            .clientOptions(ClientOptions.builder().publishOnScheduler(true).build())
            // Number of processors, Every thread represents an internal event loop where all computation tasks are run.
            .clientResources(ClientResources.builder().computationThreadPoolSize(threadPoolSize).build());
    }
}
```