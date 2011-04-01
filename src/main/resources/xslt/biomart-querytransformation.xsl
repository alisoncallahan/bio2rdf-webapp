<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes"></xsl:output>
<xsl:template match="/">CONSTRUCT
{<xsl:for-each select="Query/Dataset">
	GRAPH <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text>
	{<xsl:for-each select="Filter">
		?resultObject <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text> ?<xsl:value-of select="@name"/> .
    </xsl:for-each>
    <xsl:for-each select="Attribute">
		?resultObject <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text> ?<xsl:value-of select="@name"/> .
    </xsl:for-each>}
</xsl:for-each>}
WHERE
{<xsl:for-each select="Query/Dataset">
	GRAPH <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text>
    {<xsl:for-each select="Filter">
		?resultObject <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text> ?<xsl:value-of select="@name"/> .
    	FILTER(STR(?<xsl:value-of select="@name"/>) = "<xsl:value-of select="@value"/>") .
    </xsl:for-each><xsl:for-each select="Attribute">
		?resultObject <xsl:text disable-output-escaping="yes" ><![CDATA[<]]></xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes" ><![CDATA[>]]></xsl:text> ?<xsl:value-of select="@name"/> .
    </xsl:for-each>}
</xsl:for-each>}
</xsl:template>
</xsl:stylesheet>