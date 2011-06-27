<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bio2rdf="http://bio2rdf.org/bio2rdf#" xmlns:iucr="http://bio2rdf.org/iucr#" xmlns:idf="http://bio2rdf.org/idf#" xmlns:cif="http://bio2rdf.org/idf#">

    	<xsl:variable name="title" select="//scalar[@dictRef=&quot;iucr:publ_section_title&quot;]"/>

    	<xsl:variable name="id" select="//@id"/>
    	<xsl:variable name="lsid" select="concat('crystaleye:',$id)"/>
    	<xsl:variable name="uri" select="concat('http://bio2rdf.org/',$lsid)"/>

<xsl:element name="iucr:Annotation">	
	<xsl:attribute name="rdf:about"><xsl:value-of select="$uri"/></xsl:attribute>    		

	<dc:title><xsl:value-of select="$title"/></dc:title>
	<dc:identifier>crystaleye:<xsl:value-of select="$id"/></dc:identifier>
	<rdfs:label><xsl:value-of select="$title"/> [<xsl:value-of select="$lsid"/>]</rdfs:label>

	<xsl:element name="bio2rdf:lsid">	
		<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('urn:lsid:bio2rdf.org:',$lsid)"/></xsl:attribute>    		
	</xsl:element>	
	<xsl:element name="bio2rdf:html">	
		<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/html/',$lsid)"/></xsl:attribute>    		
	</xsl:element>	

    <xsl:for-each select="/cml/scalar/@dictRef">	
	<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		<xsl:value-of select="../."/>
	<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;
	</xsl:text>
    </xsl:for-each>

    <xsl:for-each select="//@convention">	
	<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		<xsl:value-of select="../."/>
	<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;
	</xsl:text>
    </xsl:for-each>

    	<xsl:for-each select="/cml/molecule/atomArray/atom">	
		<xsl:element name="iucr:xAtom">	
			<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid)"/>-<xsl:value-of select="@id"/></xsl:attribute>    
		</xsl:element>	
	</xsl:for-each>

    	<xsl:for-each select="/cml/molecule/bondArray/bond">	
		<xsl:element name="iucr:xBond">	
			<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid)"/>-<xsl:value-of select="@id"/></xsl:attribute>    
		</xsl:element>	
	</xsl:for-each>
</xsl:element>	

<xsl:for-each select="/cml/molecule/atomArray/atom">	
	<xsl:element name="iucr:Atom">	
		<xsl:attribute name="rdf:about"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid)"/>-<xsl:value-of select="@id"/></xsl:attribute>    

		<xsl:element name="iucr:z3"><xsl:value-of select="@z3"/></xsl:element>			
		<xsl:element name="iucr:y3"><xsl:value-of select="@y3"/></xsl:element>			
		<xsl:element name="iucr:x3"><xsl:value-of select="@x3"/></xsl:element>			
		<xsl:element name="iucr:zFract"><xsl:value-of select="@zFract"/></xsl:element>			
		<xsl:element name="iucr:yFract"><xsl:value-of select="@yFract"/></xsl:element>			
		<xsl:element name="iucr:xFract"><xsl:value-of select="@xFract"/></xsl:element>			
		<xsl:element name="iucr:elementType">			
			<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/atom:',@elementType)"/></xsl:attribute>    
		</xsl:element>
		<xsl:element name="iucr:x2"><xsl:value-of select="@x2"/></xsl:element>			
		<xsl:element name="iucr:y2"><xsl:value-of select="@y2"/></xsl:element>			
		<xsl:for-each select="./scalar/@dictRef">	
			<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
				<xsl:value-of select="../."/>
			<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="translate(.,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		</xsl:for-each>

	</xsl:element>	
</xsl:for-each>

<xsl:for-each select="/cml/molecule/bondArray/bond">	
	<xsl:element name="iucr:Bond">	
		<xsl:attribute name="rdf:about"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid)"/>-<xsl:value-of select="@id"/></xsl:attribute>    

		<xsl:element name="iucr:atomRefs2"><xsl:value-of select="@atomRefs2"/></xsl:element>			
		<xsl:element name="iucr:userCyclic"><xsl:value-of select="@userCyclic"/></xsl:element>			
		<xsl:element name="iucr:order"><xsl:value-of select="@order"/></xsl:element>			
		<xsl:element name="iucr:elementTypes2"><xsl:value-of select="./length/@elementTypes2"/></xsl:element>			
		<xsl:element name="iucr:bondLength"><xsl:value-of select="./length"/></xsl:element>			

		<xsl:element name="iucr:xAtom">			
			<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid,'-',substring-before(@atomRefs2,' '))"/></xsl:attribute>    
		</xsl:element>
		<xsl:element name="iucr:xAtom">			
			<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',$lsid,'-',substring-after(@atomRefs2,' '))"/></xsl:attribute>    
		</xsl:element>

	</xsl:element>	
</xsl:for-each>

    </rdf:RDF>
</xsl:template>
</xsl:stylesheet>