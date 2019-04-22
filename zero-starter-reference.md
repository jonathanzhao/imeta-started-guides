# iMeta零JAVA代码参考手册
## 用户模型
> 电子商城用户模型示例<br/>
- 包
![电子商城包](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-package.png "Mall Design Model")
- 类图
![电子商城类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall.png "Mall Design Model")
- 统计分析
![电子商城统计分析类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-stat.png "Mall Statistic Model")

## 用户模型与元数据的映射
|用户模型|元数据模型|示例|
|---|---|---|
| 包 | Component | order,goods |
| 包间依赖 | Component.dependencies | |
| 基本类型 | DataType | Integer,DateTime,String |
| 枚举类型 | Enumeration | OrderStatus |
| 实体 | Entity | Order,OderDetail,Goods |
| 接口 | Interface | Code,Autditable |
| 组合关系 | Association | Order -> OrderDetail |
| 关联关系 | Association | OrderDetail -> Goods |
| 继承关系 | Generalization| Goods -> Archive |
|实现关系|Realization| OrderBase -> Auditable |
|属性|Property|code,details,createTime|
|方法|Operation||
|方法参数|Parameter||

## 配置模型数据（元数据）

## 配置查询方案

## 配置导入导出模版

## 运行
- 下载JAVA包
```git
git clone https://github.com/jonathanzhao/imeta-boot-starter-service.git
```
- 重命名jar包
```bash
mv imeta-boot-starter-service-2.1.0-SNAPSHOT.jar mall-boot-starter-service-2.1.0-SNAPSHOT.jar
```
- 执行
```bash
java -jar -Dfile.encoding=utf-8 -Dport=8581 -Dstatic.path=file:/data/release/mall/configs 
-Ddb.host=数据库服务器地址 -Ddb.port=数据库端口号 -Ddb.username=数据库用户名 -Ddb.pwd=数据库密码 
-Ddb.database=数据库名称 -Dredis.pwd=Redis密码 -Dredis.db=Redis数据库编号 -Dauth.enabled=true 
-Dcors.enabled=true -Dapi.skip.check=true -Dauth.session.id=mallsessionid -Dapi.header.key=X-MALL-TOKEN 
service/mall-boot-starter-service-2.1.0-SNAPSHOT.jar > mall.service.log &
```
