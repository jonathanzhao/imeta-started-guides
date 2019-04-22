# iMeta参考手册
## 介绍
iMeta是一个基于JAVA语言开发的模型驱动（MDD）开发框架，以元数据为基础，与微服务架构（Micro-Services）天然融合，配置文件为主要开发方式，适用于以关系数据库和No-Sql数据库为数据存储介质、以数据查询、持久化为主要操作方式、面向微服务的、部署在云（Cloud）中的应用程序。
## 特点
1. MDD：以用户模型（参考“OMG四层元模型架构”中M1层）为基础的开发框架，使用元数据描述用户模型，元数据结构借鉴OMG M2层静态元素结构，开发时以元数据为基础、以配置文件为主要开发方式。
2. Zero Coding：零JAVA代码，主要开发方式是书写配置文件，包括：用户模型、数据查询、导出导出等。
3. Micro-Services Inside：天然支持微服务，涉及远程服务、缓存服务、本地服务的查询统一查询配置，对开发人员透明，极大降低开发复杂度和成本。
4. Deep integration with Spring：iMeta与Spring深度集成，参考Spring Boot的实现方式，实现了自动配置，开发时引入jar包即可。
5. Extensible：iMeta框架采用分层架构，完全基于接口，底层使用接口定义系统脉络、体现系统整体结构；同时也提供了大量的默认实现，主要位于Spring集成层中，这些默认实现可以被替换、扩展。
## 使用前提
iMeta框架已经为Web、数据库、No-Sql、异步服务等提供了默认实现，为了更加高效开发，最好具备以下知识。
1. [必选]具有一定软件工程基础：对UML有一定了解，能够绘制UML类图，理解类间关系（继承、实现、关联、组合）的含义，这些是iMeta开发的原材料。
2. [可选]具有一定WEB开发基础：能够理解cookie、cors、http、ajax等常见概念。
3. [可选]具有一定No-SQL基础：当应用程序使用No-Sql数据库（例如：Redis）存储数据时，需要了解相关No-Sql一些常见操作。
4. [可选]具有一定异步编程知识：当应用程序为高性能异步应用时，需要了解Reactor、WebFlux、No-Sql异步驱动一些基本知识。
5. [可选]具有一定架构能力：能够合理拆分服务，实现高内聚低耦合的微服务架构。
## OMG四层元模型架构
![OMG四层元模型架构](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/m4.png "OMG M4")
- M0层 (实例对象层)
  是现实世界的具体事物/数据，代表一个个具体的实例对象。
- M1层（用户模型层）
  是对现实事物的抽象，包含类及其关系，图中M1层对一个影片管理系统建模，抽象出类Movie类，包含title属性，用于描述现实世界中的影片；<br/>
  目的是使用软件系统描述现实世界。
- M2层（UML层）
  是对用户模型的进一步抽象，是抽象的抽象，使用Class抽象描述Movie，使用Attribute(Property)抽象描述title，使用Instance抽象描述具体一个影片实例；<br/>
  目的是使用更高一级的抽象实现代码自动化处理；<br/>
  iMeta参考M2层（即UML层）的结构，抽象出元数据的结构；M1层（用户模型层）的元素就是领域元数据的数据；<br/>
  元数据是描述数据的数据。
- M3层 (MOF层)
  是对M2层进一步抽象，改层为递归层，即可以继续高度抽象。一般用于Case工具开发等场景；<br/>
  iMeta框架不涉及此层内容。
  
## iMeta与其它架构的关系
### iMeta vs ORM
|     | iMeta | ORM |
| --- | --- | --- |
| 设计 | 以服务为基础 | 以实体为基础 |
| 抽象层次 | M2元数据,对M1的抽象 | M1,对业务数据的抽象 |
| 设计 | 以服务为基础 | 以实体为基础 |
| 开发视角 | 基于抽象：用户模型、类图 | 基于具体实现：实体、数据库表 |
| 功能 | 关系数据库、No-SQL数据库、远程服务操作透明化 | 数据库操作透明化 |
| 数据源 | 关系数据库、No-SQL数据库、远程服务 | 关系数据库 |

面向关系数据库（例如：Mysql）开发时，ORM框架（例如：Mybatis、Hibernate）提供了基础的数据库操作能力，还提供了一定的缓存能力。随着云（Cloud）的日益普及、微服务架构日益流行，存粹的ORM框架已经很难解决关系数据库和No-Sql数据库综合使用的应用场景。
iMeta提供面向服务的ORM能力，自动适配集成来自不同数据源的数据，iMeta的关系数据库的操作部分仍然可以使用传统ORM能力。
### iMeta & Micro-Services
微服务架构在容器环境中，可以轻松弹性扩容，已经成为云（Cloud）部署环境的首选框架。
iMeta框架天然支持微服务架构，统一查询服务自动识别分拆查询服务，聚合查询来自No-Sql数据库、关系数据库、远程服务不同数据源的数据，整个过程对开发人员是透明的，极大降低开发复杂度和成本。
### iMeta & Spring
Spring框架已经成为JAVA开发标配，Spring Boot的出现更是极大降低了JAVA Web开发的复杂度。
iMeta参考Spring Boot的实现方式，实现了自动配置，开发时引入jar包即可。
### iMeta & Spring WebFlux
利用微服务框架可以很容易实现应用程序水平扩展，但通过WebFlux反应式框架实现纵向并发能力提升越来越流行，通过较少的资源提供更大的并发能力是一种趋势，尤其是在面向No-Sql数据库的应用中。
iMeta提供了集成WebFlux的能力，可以方便的开发涉及任务调度、网关、No-Sql数据库的应用程序。
## 元数据加载流程
![元数据加载流程](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/metadata-load.png "MD LOAD")
元数据加载主要分为两个阶段：元数据定义阶段、元数据阶段，通过实现不同接口，可以进行功能扩展。
元数据定义是元数据的原材料，经过加工可以转换成元数据。

## 核心概念
### 用户模型 UserModel
> 电子商城用户模型示例<br/>
- 包
![电子商城包](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-package.png "Mall Design Model")
- 类图
![电子商城类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall.png "Mall Design Model")
- 统计分析
![电子商城统计分析类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-stat.png "Mall Statistic Model")

用户模型中的静态类图可以认为是iMeta所需的原材料，基于此原材料生成元数据。<br/>
用户模型通常包含以下几个UML元素：包、类、属性、关系。关系主要描述类间关系，有继承、实现、关联、组合。<br/>
iMeta结合数据仓库模型，能够提供极为灵活的统计查询，一般情况下，无需一行JAVA代码。

### 元数据定义 MetadataDefinition
![元数据定义](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/md-definition.png "MetadataDefinition")

### 元数据 Metadata
![元数据](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/md.png "Metadata")

### 域 Domain
域是对应用所属领域的抽象，域用于隔离不同的应用，域的隔离策略有：不隔离、单实例不同库、服务隔离，域的隔离级别（IsolationLevel）目前有三种：远程服务、缓存服务、本地服务，通过隔离策略决定域的隔离级别。<br/>
iMeta中域在组件（Component）上声明，组件为最小的部署单元。
> 域隔离级别

| 隔离策略 | 相同域 | 不同域 |
| --- | --- | --- |
| 不隔离 | 本地服务/缓存服务 | 本地服务/缓存服务 |
| 单实例 | 本地服务（跨库）/缓存服务 | 本地服务（跨库）/缓存服务 |
| 服务隔离 | 本地服务/缓存服务 | 远程服务 |

### 用户模型与元数据的映射
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

### 查询方案
![查询方案](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-schema.png "QuerySchema")

![查询条件](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-condition.png "QueryCondition")

查询方案为统一查询引擎对外开发的唯一数据结构，所有的查询配置都要遵守查询方案的定义。
## 应用模式
所有操作视角都统一到模型层，大多数应用模式仅依赖配置文件即可完成所有开发任务。
### 统一查询引擎
iMeta提供了统一查询引擎，将远程服务、缓存服务、本地服务的数据查询统一，实现细节对开发人员透明，所有操作视角都统一到模型层面，实现基于微服务的模型驱动开发；一般情况下，无需一行JAVA代码。
> 详细内容 [查询引擎参考手册](query-reference.md)

### 统一持久化
iMeta提供了统一持久化机制，包括单实体持久化、组合实体持久化、批量新增，并提供了主外键设置、唯一性校验、数据合法性校验、默认值设置等默认规则；一般情况下，无需一行JAVA代码。
> 详细内容 [持久化参考手册](persistence-reference.md)

### 统一DTS
iMeta提供了统一的数据转换服务，主要包括数据导出导出到Excel、csv文件；一般情况下，无需一行JAVA代码。
> 详细内容 [DTS参考手册](dts-reference.md)

### 代码生成和数据渲染
iMeta提供了一套模版解析引擎，提供支持设计态根据元数据生成代码和支持运行时渲染数据两种功能。
> 详细内容 [模版参考手册](template-reference.md)

### 零JAVA代码
iMeta提供了一个简洁快速的imeta-boot-starter-service模块，仅仅通过配置文件，即可完成应用程序开发，一般情况下，无需一行JAVA代码。
> 详细内容 [零JAVA代码参考手册](zero-starter-reference.md)

### 集成WebFlux
iMeta可以快速集成Spring WebFlux反应式编程框架，一般用于任务调度、路由分发、No-Sql数据库数据存储。
> 详细内容 [WebFlux参考手册](starter-webflux-reference.md)
