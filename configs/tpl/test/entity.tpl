package <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>;

<#?(suppliers._size>0)#>
<#*(supplier:suppliers)?(owner!=this.owner){#>
import <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>.<#=name#>;
<#}#>
<#}#>
<#?(parent!=null && "BizObject" != parent.name){#>
import <#=NAME_SPACE#>.<#=parent.owner.moduleName#>.<#=parent.owner.name#>.<#=parent.name#>;
<#}#>
<#?(parent==null || parent.name == "BizObject"){#>
import org.imeta.context.biz.BizObject;
<#}#>