# iMeta Framework Reference
iMeta是一个基于JAVA语言开发的模型驱动（MDD）开发框架，以元数据为基础，与微服务架构（Micro-Services）天然融合，配置文件为主要开发方式，适用于以关系数据库和No-Sql数据库为数据存储介质、以数据查询、持久化为主要操作方式、面向微服务的、部署在云（Cloud）中的应用程序。
## Features
1. MDD：以用户模型（参考“OMG四层元模型架构”中M1层）为基础的开发框架，使用元数据描述用户模型，元数据结构借鉴OMG M2层静态元素结构，开发时以元数据为基础、以配置文件为主要开发方式。
2. Zero Coding：零JAVA代码，主要开发方式是书写配置文件，包括：用户模型、数据查询、导出导出等。
3. Micro-Services Inside：天然支持微服务，涉及远程服务、缓存服务、本地服务的查询统一查询配置，对开发人员透明，极大降低开发复杂度和成本。
4. Deep integration with Spring：iMeta与Spring深度集成，参考Spring Boot的实现方式，实现了自动配置，开发时引入jar包即可。
5. Extensible：iMeta框架采用分层架构，完全基于接口，底层使用接口定义系统脉络、体现系统整体结构；同时也提供了大量的默认实现，主要位于Spring集成层中，这些默认实现可以被替换、扩展。

## Documentation
> 参考手册
- [概述 & 设计思想](imeta-reference.md)
- [统一查询引擎](query-reference.md)
- [统一持久化](persistence-reference.md)
- [模版 & 代码生成](template-reference.md)
- [数据转换](dts-reference.md)

> 快速上手
- [商城示例模型](mall-model.md)
- [零JAVA代码创建Spring Boot应用程序](zero-starter-reference.md)
