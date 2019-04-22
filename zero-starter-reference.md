# iMeta零JAVA代码参考手册
## 用户模型
> 电子商城用户模型示例<br/>
- 包
![电子商城包](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-package.png "Mall Design Model")
- 类图
![电子商城类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall.png "Mall Design Model")
- 统计分析
![电子商城统计分析类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-stat.png "Mall Statistic Model")

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
