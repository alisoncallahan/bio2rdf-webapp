<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bio2rdf="http://bio2rdf.org/bio2rdf#" xmlns:pubchem="http://bio2rdf.org/pubchem#" xmlns:cid="http://bio2rdf.org/cid#" xmlns:pccompound="http://bio2rdf.org/pccompound#" xmlns="http://www.ncbi.nlm.nih.gov">

    	<xsl:variable name="title" select="//:PC-Substance_synonyms_E[last()]"/>
      
    	<xsl:variable name="lsid" select="concat('cid:',//:PC-CompoundType_id_cid)"/>
    	<xsl:variable name="uri" select="concat('http://bio2rdf.org/',$lsid)"/>          
    	<xsl:variable name="maj" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    	<xsl:variable name="min" select="'abcdefghijklmnopqrstuvwxyz'"/>

<xsl:element name="pubchem:Compound">	
	<xsl:attribute name="rdf:about"><xsl:value-of select="$uri"/></xsl:attribute>    		

	<xsl:element name="dc:title">
		<xsl:value-of select="$title"/>
	</xsl:element>	
	<xsl:element name="dc:identifier">
		<xsl:value-of select="$lsid"/>
	</xsl:element>	
	<xsl:element name="rdfs:label">
		<xsl:value-of select="$title"/> [<xsl:value-of select="$lsid"/>]
	</xsl:element>	
	<xsl:element name="bio2rdf:lsid">	
		<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('urn:lsid:bio2rdf.org:',$lsid)"/></xsl:attribute>    		
	</xsl:element>	
	<xsl:element name="bio2rdf:html">	
		<xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/html/',$lsid)"/></xsl:attribute>    		
	</xsl:element>	
	<xsl:element name="bio2rdf:url">	
		<xsl:value-of select="concat('http://bio2rdf.org/html/',$lsid)"/>    		
	</xsl:element>	
	<xsl:element name="bio2rdf:urlImage">	
		<xsl:value-of select="concat('http://bio2rdf.org/image/',$lsid)"/>    		
	</xsl:element>	

	<xsl:for-each select="//:PC-Substance_synonyms_E">	
		<xsl:element name="bio2rdf:synonym">	
			<xsl:value-of select="."/>   		
		</xsl:element>	
	</xsl:for-each>
	<xsl:for-each select="/:PC-Substance/:PC-Substance_source/:PC-Source/:PC-Source_db/:PC-DBTracking">	
		<xsl:element name="pubchem:source">	
			<xsl:attribute name="rdf:resource"><xsl:value-of select="translate(concat('http://bio2rdf.org/',./:PC-DBTracking_name,':',./:PC-DBTracking_source-id/:Object-id/:Object-id_str),$maj,$min)"/></xsl:attribute>    		
		</xsl:element>	
	</xsl:for-each>
	<xsl:for-each select="//:PC-Substance_comment_E">	
		<xsl:element name="pubchem:comment">	
			<xsl:value-of select="."/>    		
		</xsl:element>	
	</xsl:for-each>
	<xsl:for-each select="//:PC-XRefData_protein-gi">	
		<xsl:element name="bio2rdf:xGI">	
			<xsl:attribute name="rdf:resource"><xsl:value-of select="translate(concat('http://bio2rdf.org/gi:',.),$maj,$min)"/></xsl:attribute>    		
		</xsl:element>	
	</xsl:for-each>

	<xsl:for-each select="//:PC-InfoData/:PC-InfoData_urn/:PC-Urn/:PC-Urn_label">	
	    	<xsl:variable name="label" select="translate(concat('cid:',.),' ','_')"/>

		<xsl:for-each select="./../../../:PC-InfoData_value/:PC-InfoData_value_sval">
			<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="translate($label,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
				<xsl:value-of select="."/>
			<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="translate($label,'[]%/','')"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		</xsl:for-each>
	</xsl:for-each>
</xsl:element>	

</rdf:RDF>
</xsl:template>
</xsl:stylesheet>