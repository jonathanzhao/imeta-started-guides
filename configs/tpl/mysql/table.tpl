<#*(component:components){#>
####################
--	<#=title#>
####################
<#*(entity:classes)?(tableName!=null && isView!=true){#>
-- ----------------------------
-- Table structure for <#=tableName#>
-- ----------------------------
DROP TABLE IF EXISTS `<#=tableName#>`;
CREATE TABLE `<#=tableName#>` (
<#*(property:properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && (isDependencyProperty!=true) && (modeType!="None")){#>
	<#@TableColumnBuilder#><#?(isSyncKey==true){#> NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP<#}#>,
<#}#>
<#*(property:properties){#>
<#?(unionKey!=null){#>
	<#@TableIndexBuilder#>,
<#}#>
<#?(unionKey==null && isAggrParentRole==true && isKey!=true){#>
	<#@TableIndexBuilder#>,
<#}#>
<#}#>
	<#@TableIndexBuilder,keyProperty#>

) ENGINE=InnoDB CHARSET=utf8;
<#}#>
<#}#>
