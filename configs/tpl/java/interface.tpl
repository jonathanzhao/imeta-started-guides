package <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>;

<#?(dependencies!=null && dependencies._size>0){#>
<#*(depComp:dependencies){#>
import <#=NAME_SPACE#>.<#=moduleName#>.<#=name#>.*;
<#}#>

<#}#>
/**
 * <#=title#>接口
 * 
 * @author <#=AUTHOR#>
 * @version <#=VERSION#>
 * @createTime <#=CURRENT_DATE#>
 */
public interface <#@GenericNameBuilder#><#?(parents._size>0)#> extends <#*(parent:parents){#> <#@GenericInheritNameBuilder,_super,this#><#?(IS_LAST!=true)#>,<#}#><#}#><#}#> {
<#*(property:properties)?(isDerived!=true){#>
	/**
	 * 获取<#=title#>
	 * 
	 * @return <#=title#>
	 */
	<#/javatype(this)#> get<#/capital(name)#>();

	/**
	 * 设置<#=title#>
	 * 
	 * @param <#=name#> <#=title#>
	 */
	void set<#/capital(name)#>(<#/javatype(this)#> <#=name#>);

<#}#>
}
