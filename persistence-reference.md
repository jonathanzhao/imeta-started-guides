# iMeta 持久化参考手册
iMeta Framework提供了基于关系数据库的增删改持久化功能，提供了常见主外键赋值等规则，提供了几种扩展机制，可以在默认处理过程中加入额外功能。
## 术语表

|术语|元数据|含义|
|---|---|---|
|主键|Property|Classifier中isKey为true的Property|
|外键|Property|Classifier中类型为复杂类型的Property|
|冗余字段|Property|Classifier中isRedundant为true的Property|
|隔离字段|Property|Classifier中isPartition为true的Property<br/>使用partitionName标识其隔离名称，用于从上下文中获取值<br/>查询时仅能查找到隔离范围内的数据|
|同步字段|Property|Classifier中isSyncKey为true的Property<br/>用于控制并发访问|
|唯一性字段|Property|Classifier中isUnique为true的Property<br/>用于保证值在指定范围内唯一不重复|
|联合唯一键|Property|唯一性字段，unionKey用于定义联合唯一键，将会使用所有联合键进行唯一性检查|

## 默认规则
- 主键、外键、冗余字段赋值
    > 赋值前数据

    ```json
    {
        "status": 1,
        "customer": 53754,
        "details": [
            {
                "goodsCate": 381,
                "goods": 2138,
                "sku": 31210,
                "qty": 503.59,
                "price": 1.69
            }
        ],
        "logistics": [
            {
                "shipTime": "2019-05-06 23:59:59",
                "site": "my8x4OsF",
                "actions": [
                    {
                        "action": "捡货",
                        "user": "李四"
                    },
                    {
                        "action": "签收",
                        "user": "张三"
                    }
                ]
            }
        ]
    }
    ```

    > 赋值后数据

    ```json
    {
        "status": 1,
        "customer": 53754,
        "vouchDate": "2019-05-09", // 扩展：单据基类Vouch赋值
        "code": "mall20190509133034", // 扩展：自动编号接口AutoCode赋值
        "createTime": "2019-05-09 13:30:34", // 扩展：审计接口Audit赋值
        "creator": "管理员", // 扩展：审计接口Audit赋值
        "id": 1215362508460288, // 主键赋值
        "details": [
            {
                "goodsCate": 381,
                "goods": 2138,
                "sku": 31210,
                "qty": 503.59,
                "price": 1.69,
                "id": 1215362508460289, // 主键赋值
                "order": 1215362508460288 // 外键赋值
            }
        ],
        "logistics": [
            {
                "shipTime": "2019-05-06 23:59:59",
                "site": "my8x4OsF",
                "id": 1215362508476672, // 主键赋值
                "order": 1215362508460288, // 外键赋值
                "actions": [
                    {
                        "action": "捡货",
                        "user": "李四",
                        "id": 1215362508476673, // 主键赋值
                        "logistics": 1215362508476672, // 外键赋值
                        "order": 1215362508460288 // 冗余字段赋值
                    },
                    {
                        "action": "签收",
                        "user": "张三",
                        "id": 1215362508525824, // 主键赋值
                        "logistics": 1215362508476672, // 外键赋值
                        "order": 1215362508460288 // 冗余字段赋值
                    }
                ]
            }
        ]
    }
    ```

- 隔离字段赋值

    从服务上下文(ServiceContext)中获取partitionName对应的值为其赋值。例如：买家需要根据租户进行隔离，当前租户在服务上下文中，值为1001。

    > 赋值前数据

    ```json
    {"code":"test01","name":"测试01"}
    ```

    > 赋值后数据

    ```json
    {"code":"test01","name":"测试01","tenant":1001}
    ```

- 默认值赋值

    默认值赋值在批量插入时有用，当一次性新增多个对象时，对象有值的字段可能多少不一致，需要先补齐有差异的字段，这些差异字段如果有默认值，则取默认值，否则为空。

    > 赋值前数据

    ```json
    {"code":"test01","name":"测试01"}
    ```

    > 赋值后数据

    ```json
    {"code":"test01","name":"测试01","type":1}
    ```

- 数据合法性校验

    通过元数据Property上的validate属性设置字段格式校验。
    |validate值|含义|
    |---|---|
    |phone|命名校验器 手机号|
    |tel|命名校验器 电话|
    |email|命名校验器 邮件|
    |正则表达式|自定义校验器|

    命名校验器可以外部注册。

    如果validate的值为^1\d{10}$，传入值为1360124，校验时将会抛出异常：XX的格式不合法

- 唯一性校验

    当一个Property的isUnique设置为true时，在新增/修改时，如果其值在范围内除了自身已经存在，则会抛出异常：XX已经存在。
    
    唯一性校验时，会综合考虑隔离性(isPartition)、联合唯一键(unionKey)。

- 删除引用校验

    删除时校验该对象是否被其它对象所使用。例如：删除买家时，检查是否有订单使用了该买家。

## CRUD

> 统一持久化接口

```java
public interface PersistenceService extends Service, MetaCollectionAware, MetadataRegistryAware, PersistenceBeanAware {
    <T extends BizObject> int insert(T obj, ServiceContext serviceContext) throws BusinessException, ServiceException;

    <T extends BizObject> int update(T obj, ServiceContext serviceContext) throws BusinessException, ServiceException;

    <T extends BizObject> int delete(T obj, ServiceContext serviceContext) throws BusinessException, ServiceException;

    <T extends BizObject> int batchInsert(List<T> objs, ServiceContext serviceContext) throws BusinessException, ServiceException;
}
```

> 默认实现

```java
public class DefaultPersistenceService implements PersistenceService, UnifiedQueryEngineAware, KeyIteratorRepositoryAware, PersistenceInterceptorAware, EventPublisherAware, ServiceListenerCollectionAware<PersistenceServiceListener> {
    // default implements ...
}
```

## 扩展机制
### 拦截器

> 拦截器接口

```java
public interface PersistenceInterceptor extends InterceptorBean {

    boolean preHandle(PersistentEvent persistentEvent, List<PersistenceServiceListener> listeners) throws BusinessException, ServiceException;

    void postHandle(PersistentEvent persistentEvent, List<PersistenceServiceListener> listeners) throws BusinessException;
}
```

> 默认实现

```java
public class DefaultPersistenceInterceptor implements PersistenceInterceptor, UnifiedQueryEngineAware, KeyIteratorRepositoryAware {
    // default implements ...
}
```

### 自定义规则
### 事件机制

> 事件名称

|事件名称|时机|
|---|---|
|START|开始持久化|
|DATA_READY|数据层级结构已经构建|
|BEFORE_PK_FK|主键、外键、冗余字段赋值前|
|BEFORE_FORMAT_CHECK|数据校验前|
|BEFORE_UNIQUE_CHECK|唯一性校验前|
|BEFORE_BUILD_SQL|构造SQL结构前，SQL不局限于数据库SQL|
|BEFORE_EXECUTE_SQL|执行SQL结构前，SQL不局限于数据库SQL|
|AFTER_EXECUTE_SQL|执行SQL结构后，SQL不局限于数据库SQL|

> 事件监听接口

```java
public interface PersistenceServiceListener extends ServiceListener<PersistentEvent> {
    boolean supports(Entity entity, EntityStatus entityStatus);
}
```

> 持久化事件结构

```java
public class PersistentEvent implements Event {
    protected Entity entity;
    protected BizObject obj;
    protected EntityStatus entityStatus;
    protected ServiceContext serviceContext;
    protected SqlStruct sqlStruct;
    protected Object result;
    protected String eventName;
    // ...
}
```

> 实现示例

```java
public class AuditInsertPersistenceServiceListener implements PersistenceServiceListener, MetadataRegistryAware {
    Type audit;

    @Override
    public void setMetaBean(MetaBean metaBean) {
        if (metaBean instanceof MetadataRegistry) {
            setMetadataRegistry((MetadataRegistry) metaBean);
        }
    }

    @Override
    public void setMetadataRegistry(MetadataRegistry metadataRegistry) {
        audit = metadataRegistry.type("base.itf.Audit");
    }

    @Override
    public boolean supports(Entity entity, EntityStatus entityStatus) {
        return entityStatus == EntityStatus.Insert && entity.is(audit);
    }

    @Override
    public void onServiceEvent(PersistentEvent event) throws ServiceException {
        if (event.getEventName().equals("DATA_READY")) {
            BizObject obj = event.getObj();
            ServiceContext context = event.getServiceContext();
            obj.set("createTime", new Date());
            obj.set("creator", context.getParam("CURRENT_USER_NAME"));
        }
    }
}
```

### 消息机制
可以通过RabbitMQ等消息队列中间件实现消息发布接口。

> 消息发布接口

```java
public interface AsyncEventPublisher<E extends Event> extends MetaBean {
    void publishEvent(E event);
}
```

## 缓存
通过消息扩展机制(AsyncEventPublisher)，监听持久化完成时发出的消息，将数据缓存。<br/>
通过异步消息完成该任务是因为是否缓存成功事务都需要提交完成。<br/>
数据可以被缓存到不同的存储中，例如：同时存储到redis和elasticSearch中。