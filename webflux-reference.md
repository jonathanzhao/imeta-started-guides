# iMeta 异步编程参考手册
## WebFlux简介
![Spring WebFlux & MVC](/images/webflux/diagram-boot-reactor.svg)

- 反应式 reactive
- 函数式 functional
- 非阻塞non-blocking
- 高并发 concurrency
- 背压 Backpressure

## MVC vs WebFlux 压测
> 压测数据

![Spring MVC vs WebFlux](/images/webflux/test/summary.png)

> 吞吐量

![Spring MVC vs WebFlux](/images/webflux/test/throughout.png)

> 响应时长

![Spring MVC vs WebFlux](/images/webflux/test/rt.png)

随着压力进一步增大，mvc-with-latency的测试出现了许多的请求fail而以失败告终； 而WebFlux-with-latency应对20000用户已然面不改色心不慌，吞吐量达到7228 req/sec，95%响应时长仅117ms。

## WebFlux 适用范围
- 中转调度，不做具体工作的
  - 网关
  - 任务分发
- No-Sql，提供了异步驱动的
  - Cassandra、MongoDB、Couchbase、Redis
- 不涉及关系数据库、JDBC、事务操作的
  - 如果涉及，将相关内容抽取到独立服务中，通过微服务框架调用。
- 不要涉及 ***ThreadLocal*** ，以下情况最好不用
  - Spring AOP 事务 涉及ThreadLocal
  - 应用程序中与当前登录用户相关的工具类，例如：AppContext等。
  - 写日志使用MDC传递变量

## 基础知识
使用WebFlux要求对Stream、Lambda熟练掌握，对reactor操作符熟练掌握。
### Java8 Stream
- Stream 不是集合元素，不是数据结构，不保存数据，不修改所封装的数据，像一个高级版本的 Iterator
- 无存储、函数式风格、惰性求值、无上界(数据源可以是无限的)、并行parallel
- 惰性
  - movies.stream().filter(m -> m.getRaking() >= 9.0).mapToDouble(Movie::getRaking).sorted().sum(); 中filter,map,sorted都是惰性操作，并不立即执行，collect为终止操作，会在此时对数据集进行一次循环，循环内执行所有的惰性操作
- 操作流程
  - 为获取一个数据源(source）→ 数据转换→执行操作获取想要的结果，每次转换原有 Stream 对象不改变，返回一个新的 Stream 对象(可以有多次转换）
- 操作类型
  - 中间操作：map、flatMap、filter、limit、sorted、distinct …
  - 终止操作：reduce、collect、forEach、anyMatch、findAny、max、count …
- 短路(short-circuiting) ：anyMatch、findFirst、findAny、limit …
  - 对于中间操作，接收一个无限流，输出一个有限
  - 对于终止操作，接收一个无限流，能在有限时间计算出结果

### Java8 Lambda示例
- 每个城市所有人的名字
```java
people.stream().collect(groupingBy(Person::getCity, mapping(Person::getLastName, joining(","))));
```
- 每个城市平均身高
```java
people.stream().collect(groupingBy(Person::getCity, averagingInt(Person::getHeight)));
```
- 每个城市最高的人
```java
people.stream().collect(groupingBy(Person::getCity, maxBy(Comparator.comparingInt(Person::getHeight))));
```
- 无限流+短路
```java
(new Random()).ints(100, 200).flatMap(i -> IntStream.of(i, i * i)).limit(100).reduce(Integer::sum);
```
- 正则表达式
```java
Pattern.compile("\\s*(/|\\||,)\\s*").splitAsStream("D / A | B ,C").sorted().collect(Collectors.joining(","));
```
- 文本流读取
```java
InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("test.log");
new BufferedReader(new InputStreamReader(inputStream)).lines().filter(line -> line.startsWith("[INFO]")).forEach(System.out::println);
```

### IO 模型
![IO 模型](/images/webflux/io/io-model.png)

### Reactor模型
- 代表：Netty、eventlib  同步IO
- 事件驱动机制，Observer模式，好莱坞原则
- 过程
  1. 向事件分发器注册事件回调
  2. 事件发生
  3. 事件分发器调用之前注册的函数
  4. 在回调函数中读取数据，对数据进行后续处理
- 关键角色<br/>
  Reactor、Handle、Event Demultiplexer、Event handler
- 单线程模型<br/>
  ![单线程模型](/images/webflux/reactor/single-model.png)
- 多线程模型<br/>
  ![多线程模型](/images/webflux/reactor/multi-model.png)
- 主从多线程模型<br/>
  ![多线程模型](/images/webflux/reactor/m-s-model.png)
- Callback vs Reactor
  
  Callback
  ```java
  userService.getFavorites(userId, new Callback<List<String>>() { 
    public void onSuccess(List<String> list) { 
        if (list.isEmpty()) { 
        suggestionService.getSuggestions(new Callback<List<Favorite>>() {
            public void onSuccess(List<Favorite> list) { 
            UiUtils.submitOnUiThread(() -> { 
                list.stream()
                    .limit(5)
                    .forEach(uiList::show); 
                });
            }

            public void onError(Throwable error) { 
            UiUtils.errorPopup(error);
            }
        });
        } else {
        list.stream() 
            .limit(5)
            .forEach(favId -> favoriteService.getDetails(favId, 
                new Callback<Favorite>() {
                public void onSuccess(Favorite details) {
                    UiUtils.submitOnUiThread(() -> uiList.show(details));
                }

                public void onError(Throwable error) {
                    UiUtils.errorPopup(error);
                }
                }
            ));
        }
    }

    public void onError(Throwable error) {
        UiUtils.errorPopup(error);
    }
  });
  ```

  Reactor
  ```java
  userService.getFavorites(userId) 
        .flatMap(favoriteService::getDetails) 
        .switchIfEmpty(suggestionService.getSuggestions()) 
        .take(5) 
        .publishOn(UiUtils.uiThreadScheduler()) 
        .subscribe(uiList::show, UiUtils::errorPopup); 
  ```
- CompletableFuture vs Reactor
  
  CompletableFuture
  ```java
  CompletableFuture<List<String>> ids = ifhIds();
  CompletableFuture<List<String>> result = ids.thenComposeAsync(l -> { 
	Stream<CompletableFuture<String>> zip =
			l.stream().map(i -> { 
				CompletableFuture<String> nameTask = ifhName(i); 
				CompletableFuture<Integer> statTask = ifhStat(i); 

				return nameTask.thenCombineAsync(statTask, (name, stat) -> "Name " + name + " has stats " + stat); 
			});
	List<CompletableFuture<String>> combinationList = zip.collect(Collectors.toList()); 
	CompletableFuture<String>[] combinationArray = combinationList.toArray(new CompletableFuture[combinationList.size()]);

	CompletableFuture<Void> allDone = CompletableFuture.allOf(combinationArray); 
	return allDone.thenApply(v -> combinationList.stream()
			.map(CompletableFuture::join) 
			.collect(Collectors.toList()));
  });
  List<String> results = result.join(); 
  assertThat(results).contains(
		"Name NameJoe has stats 103",
		"Name NameBart has stats 104",
		"Name NameHenry has stats 105",
		"Name NameNicole has stats 106",
		"Name NameABSLAJNFOAJNFOANFANSF has stats 121");
  ```

  Reactor
  ```java
  Flux<String> ids = ifhrIds(); 
  Flux<String> combinations =
		ids.flatMap(id -> { 
			Mono<String> nameTask = ifhrName(id); 
			Mono<Integer> statTask = ifhrStat(id); 

			return nameTask.zipWith(statTask, 
					(name, stat) -> "Name " + name + " has stats " + stat);
		});
  Mono<List<String>> result = combinations.collectList(); 
  List<String> results = result.block(); 
  assertThat(results).containsExactly( 
		"Name NameJoe has stats 103",
		"Name NameBart has stats 104",
		"Name NameHenry has stats 105",
		"Name NameNicole has stats 106",
		"Name NameABSLAJNFOAJNFOANFANSF has stats 121"
  );
  ```

- 命令式到反应式
  - Composability and readability
  - Data as a flow manipulated with a rich vocabulary of operators
  - Nothing happens until you subscribe
  - Backpressure or the ability for the consumer to signal the producer that the rate of emission is too high
  - High level but high value abstraction that is concurrency-agnostic
- Core Features
  - Flux and Mono
    - 一个 Flux 对象代表一个包含 0..N 个元素的反应式序列
    - 一个 Mono 对象代表一个包含 零/一个（0..1）元素的结果
  - Flux, an Asynchronous Sequence of 0-N Items
  ![Flux](/images/webflux/reactor/flux.png)
  - Mono, an Asynchronous 0-1 Result
  ![Mono](/images/webflux/reactor/mono.png)
  - A Flux<T> is a standard Publisher<T> representing an asynchronous sequence of 0 to N emitted items, optionally terminated by either a completion signal or an error. these 3 types of signal translate to calls to a downstream Subscriber’s onNext, onComplete or onError methods.
  - A Mono<T> is a specialized Publisher<T> that emits at most one item and then optionally terminates with an onComplete signal or an onError signal.It offers only a subset of the operators that are available for a Flux.
- Backpressure mock
  ```java
  Flux.just(1, 2, 3, 4, 5)
        .subscribe(new BaseSubscriber<Integer>() {
            @Override
            protected void hookOnSubscribe(Subscription subscription) {
                request(1); // 通过 subscription 向上游传递 背压 请求
            }

            @Override
            protected void hookOnNext(Integer value) {
                System.out.println("onNext " + value);
                request(1); // 通过 subscription 向上游传递 背压 请求
            }
        });
  ```
- Schedulers
  - concurrency agnostic 不强制并发模型，可由开发人员决定
  - The current thread: Schedulers.immediate()
  - A single, reusable thread: Schedulers.single()
  - per-call dedicated thread: Schedulers.newSingle()
  - An elastic thread pool: Schedulers.elastic()
    - This is a good choice for I/O blocking work for instance.
  - a fixed pool of workers that is tuned for parallel work: Schedulers.parallel()
  - pre-existing ExecutorService: Schedulers.fromExecutorService(ExecutorService)
  - create new instances: using the newXXX methods. For example, Schedulers.newElastic(yourScheduleName)
- Threading
  - 获得Mono和Flux不需要在专属线程上执行，一般继续运行与前一个操作所在的线程上。如果没有特别指定，最上面的运算符（源）运行在调用subscribe()方法的线程上。
  - 两种指定scheduler/context的方法
    - publishOn 与调用位置有关，改变后续的操作符的执行所在线程
    - subscribeOn 与位置无关，影响到源头的线程执行环境
  - nothing happens until you subscribe()
  - 使用log()可以查看执行情况
  - 测试时，多个Flux同时执行时，才能清楚看到parallel、elastic的效果
  - 示例
  ```java
  Flux.interval(Duration.ofMillis(300)); // 默认 Schedulers.parallel()
  Flux.interval(Duration.ofMillis(300), Schedulers.newSingle("test"));
  Flux.interval(Duration.ofMillis(300)).log().publishOn(Schedulers.newSingle("test")).log()
  ```
- 异常处理
  - Static Fallback Value: onErrorReturn()
    - Catch and return a static default value
    - Flux.just(10).map(this::doSomethingDangerous).onErrorReturn("RECOVERED");
  - Fallback Method: onErrorResume()
    - Catch and execute an alternative path with a fallback method
    - Flux.just("key1", "key2").flatMap(k -> callExternalService(k)).onErrorResume(e -> getFromCache(k));
  - Dynamic Fallback Value: onErrorResume()
  - Catch and Rethrow: onErrorMap()、Flux.error()
    - onErrorMap(original -> new BusinessException("oops, SLA exceeded", original))
    - onErrorResume(original -> Flux.error(new BusinessException("oops, SLA exceeded", original)))
  - Log or React on the Side: doOnError()
  - Using Resources and the Finally Block: doFinally()
  - Wrap Checked Exceptions: Exceptions.propagate()、Exceptions.unwrap()

## WebFlux核心组件
![Spring MVC vs WebFlux](/images/webflux/spring-mvc-and-webflux-venn.png)
- ServerRequest
- ServerResponse
- HandlerFunction
- RouterFunction
- HandlerFilterFunction
- WebFilter
- RouterFunctions
- DataBuffer
- BodyBuilder

## 常用操作
- ServerRequest
  - path()、headers()、attributes()、cookies()、remoteAddress()、
  - bodyToMono()、pathVariable()、formData()
- ServerResponse
  - ok()、status()、temporaryRedirect()
- BodyBuilder
  - render()、contentType()、header()、body()、syncBody()
- DataBuffer
  - new DefaultDataBufferFactory().allocateBuffer()、asOutputStream()
- Exceptions
  - propagate()、unwrap()
- Reactor
  - map()、flatMap()、subscriberContext()、switchIfEmpty()、defaultIfEmpty()、doOnNext()、onErrorResume()、doFinally()
  - just()、fromArray()、empty()、error()、timeout()、defer()、any()、collect()、hasElements()、filter()、zipWith()、then()

## 注意事项
- WebFilter vs HandlerFilterFunction
  - WebFilter中onErrorResume()可以处理所有未处理的异常。
  - CorsWebFilter可以处理跨域请求问题。
  - HandlerFilterFunction(使用.filter()定义)中onErrorResume()仅能处理相应RouterFunction中产生的异常。
- 创建Flux/Mono时抛出的异常，无法使用onErrorResume()捕获，需要使用Flux/Mono.error()包装异常。
- 如果未进行switchIfEmpty()操作，response可能会没有内容。需要注意switchIfEmpty中内容使用Mono.defer()包装。
- defaultIfEmpty()操作中的值不能为空(null)。
- 使用subscriberContext()传递上下文内容，最好每个方法有ServiceContext等xxxContext参数，避免使用全局变量。
- map is for synchronous, non-blocking, 1-to-1 transformations; flatMap is for asynchronous (non-blocking) 1-to-N transformations, 在flatMap中进行的异步转换(CompletableFuture)，会先于后续操作符全部转换。

## FAQ
1. 在WebFlux应用中，是否可以使用MySql？
   
   这个问题需要分两个场景回答：

   场景一、在特定应用中，例如看板服务代码中可以使用MySql，可以避免Spring AOP事务使用ThreadLocal所带来的影响，具体做法是，所有数据库操作通过代理类（例如：JdbcProxy）访问，其第一步就是调用publishOn切换线程模型，使用自定义线城池，最大/最小/空闲线程数参照数据库连接池配置；在这个Proxy类中，除了数据库操作，不再涉及其它中间件（例如Redis）的操作，这样可以保证数据库操作总是在同一个线程上执行。

   场景二、在通用应用中，不容易写出一个通用框架来保证数据库操作不与Redis等代码混用，例如：保存后马上更新Redis缓存就是常见的这种混用操作。在这种情况下，建议采用微服务架构，将MySql数据库操作封装为使用独立服务。
   
   不管哪种场景，都涉及MqSql执行环境保护，场景一使用特定线程模型实现线程级隔离，场景二使用微服务进行进程级彻底隔离。

## 官方参考文献
- Spring Reference Documentation Index
  - https://spring.io/docs/reference  参考文献目录索引
  - https://spring.io/guides                操作指南目录索引
- Spring WebFlux & WebClient & WebSockets
  - https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html
- Spring Boot
  - https://docs.spring.io/spring-boot/docs/2.1.4.RELEASE/reference/htmlsingle/
- Spring Data Redis
  - https://docs.spring.io/spring-data/redis/docs/2.1.6.RELEASE/reference/html/
- Reactor 3 Reference Guide
  - https://projectreactor.io/docs/core/release/reference/index.html