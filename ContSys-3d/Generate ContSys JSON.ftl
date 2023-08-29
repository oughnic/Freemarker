<#ftl output_format="JSON">
<#-- Print the metadata value for a catalogueItem filtered by namespace and key, escape double quotes and trim any whitespace -->
<#-- Input parameters                                                                                                         -->
<#--     catalogueItem - generic Mauro Catalogue Item with metadata                                                           -->
<#--     metaNamespace - Namespace of the metadata profile                                                                    -->
<#--     metaKey - The key identifying the parameter to retrieve                                                              -->

<#macro printMetadata catalogueItem, metaNamespace, metaKey >
<#list catalogueItem.metadata?filter(p -> p.key == metaKey && p.namespace == metaNamespace) as meta>${meta.value?trim?json_string
}</#list></#macro>

<#macro termSubsection1 class >
<#assign termClause >
<@printMetadata class,
"directives.org.iso",
"termClause" />
</#assign>
<#if termClause?split(".")?size gt 2 >
${(termClause?split("."))[
        1
    ]
}<#else>
0</#if>
</#macro>
<#macro relatedClasses dataClass>
<#if dataClass.dataElements??>
<#list dataClass.dataElements?filter(p -> p.dataType.domainType == "ReferenceType") as dataElement >
        {
    "source": "${dataClass.label?js_string}",
    "target": "${dataElement.dataType.referenceClass.label?json_string}",
    "value": 1,
    "label": "${dataElement.label?json_string}"
}<#sep>,
         </#sep>
</#list>
</#if>
</#macro>
<#macro getData>
{
    "nodes": [
<#list dataModel.dataClasses as class >
        {
            "id": "${class.label?js_string}",
            "kind": "class",
            "label": "<@printMetadata class, "directives.org.iso", "className" />",
            "detail": "<@printMetadata class, "directives.org.iso", "definition" />",
            "childLinks": [],
            "collapsed": <#if class.label == "health">false<#else>true</#if>,
            "group": <@termSubsection1 class />
        }<#sep>,</#sep>
</#list>
    ],
    "links": [
<#list dataModel.dataClasses as class >
    <#if class.dataElements?filter(p -> p.dataType.domainType == "ReferenceType")?size gt 0 >
     <@relatedClasses class /><#sep>,</#sep>
</#if>
</#list>
    ]
}
</#macro>
<@getData />