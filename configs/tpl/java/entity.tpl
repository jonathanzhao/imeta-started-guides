package <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>;

<#?(dependencies!=null && dependencies._size>0){#>
<#*(depComp:dependencies)?(name!="base.entity"){#>
import <#=NAME_SPACE#>.<#=moduleName#>.<#=name#>.*;
<#}#>

<#}#>
<#?(parent==null || parent.name == "BizObject"){#>
import org.imeta.context.biz.BizObject;

<#}#>
/**
 * <#=title#>实体
 *
 * @author <#=AUTHOR#>
 * @version <#=VERSION#>
 * @createTime <#=CURRENT_DATE#>
 */
public class <#@GenericNameBuilder#><#?{#><#:(parent!=null){#> extends <#@GenericInheritNameBuilder,this,parent#><#}#><#:{#> extends BizObject<#}#><#}#><#?(suppliers._size>0)#> implements <#*(supplier:suppliers){#> <#@GenericInheritNameBuilder,_super,this#><#?(IS_LAST!=true)#>,<#}#><#}#><#}#> {
	// 实体全称
	public static final String ENTITY_NAME = "<#=owner.moduleName#>.<#=owner.name#>.<#=name#>";

    /**
     * 获取实体全称
     *
     * @return 实体全称
     */
    @Override
    public String getEntityName() {
        return ENTITY_NAME;
    }

<#?(keyProperty!=null && keyProperty.name != "id"){#>
    /**
     * 获取主键名称
     *
     * @return 主键名称
     */
    @Override
    public String getKeyName() {
        return "<#=keyProperty.name#>";
    }

	/**
	 * 获取<#=keyProperty.title#>
	 *
	 * @return <#=keyProperty.title#>
	 */
	public <#/javatype(keyProperty)#> getId() {
		return get("<#=keyProperty.name#>");
	}

	/**
	 * 设置<#=keyProperty.title#>
	 *
	 * @param <#=keyProperty.name#> <#=keyProperty.title#>
	 */
	public void setId(<#/javatype(keyProperty)#> <#=keyProperty.name#>) {
		set("<#=keyProperty.name#>", <#=keyProperty.name#>);
	}

	/**
	 * 获取<#=keyProperty.title#>
	 *
	 * @return <#=keyProperty.title#>
	 */
	public <#/javatype(keyProperty)#> get<#/capital(keyProperty.name)#>() {
		return get("<#=keyProperty.name#>");
	}

	/**
	 * 设置<#=keyProperty.title#>
	 *
	 * @param <#=keyProperty.name#> <#=keyProperty.title#>
	 */
	public void set<#/capital(keyProperty.name)#>(<#/javatype(keyProperty)#> <#=keyProperty.name#>) {
		set("<#=keyProperty.name#>", <#=keyProperty.name#>);
	}

<#}#>
<#*(property:properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isKey!=true && isDerived!=true && isDependencyProperty!=true){#>
<#?{#>
<#:(type.m1Type == "Enum"){#>
    /**
     * 获取<#=title#>
     *
     * @return <#=title#>
     */
	public <#/javatype(this)#> get<#/capital(name)#>() {
		Object v = get("<#=name#>");
		return <#/javatype(this)#>.find(v);
	}

    /**
     * 设置<#=title#>
     *
     * @param <#=name#> <#=title#>
     */
	public void set<#/capital(name)#>(<#/javatype(this)#> <#=name#>) {
		if (<#=name#> != null) {
			set("<#=name#>", <#=name#>.getValue());
		} else {
			set("<#=name#>", null);
		}
	}

<#}#>
<#:{#>
    /**
     * 获取<#=title#>
     *
     * @return <#=title#>
     */
	public <#/javatype(this)#> get<#/capital(name)#>() {
	    <#?(type.m1Type in "Short,Byte,Boolean"){#>
	    return get<#=type.m1Type#>("<#=name#>");
	    <#}#>
        <#?(type.m1Type ~in "Short,Byte,Boolean"){#>
		return get("<#=name#>");
        <#}#>
	}

    /**
     * 设置<#=title#>
     *
     * @param <#=name#> <#=title#>
     */
	public void set<#/capital(name)#>(<#/javatype(this)#> <#=name#>) {
		set("<#=name#>", <#=name#>);
	}

<#}#>
<#}#>
<#}#>
<#*(property:properties)?(isAggregationProperty==true && isAggrChildRole==true){#>
<#?{#>
<#:(aggregation.isChildRoleCollection==false){#>
    /**
     * 获取<#=type.title#>
     *
     * @return <#=type.title#>
     */
	public <#=type.name#> <#=name#>() {
		return getBizObject("<#=name#>", <#=type.name#>.class);
	}

    /**
     * 设置<#=type.title#>
     *
     * @param <#=name#> <#=type.title#>
     */
	public void set<#/capital(name)#>(<#=type.name#> <#=name#>) {
		setBizObject("<#=name#>", <#=name#>);
	}

<#}#>
<#:{#>
    /**
     * 获取<#=type.title#>集合
     *
     * @return <#=type.title#>集合
     */
	public java.util.List<<#=type.name#>> <#=name#>() {
		return getBizObjects("<#=name#>", <#=type.name#>.class);
	}

    /**
     * 设置<#=type.title#>集合
     *
     * @param <#=name#> <#=type.title#>集合
     */
	public void set<#/capital(name)#>(java.util.List<<#=type.name#>> <#=name#>) {
		setBizObjects("<#=name#>", <#=name#>);
	}

<#}#>
<#}#>
<#}#>
}
