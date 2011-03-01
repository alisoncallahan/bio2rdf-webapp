<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bio2rdf="http://bio2rdf.org/bio2rdf#" xmlns:gopubmed="http://bio2rdf.org/gopubmed#" xmlns:bibtex="http://bio2rdf.org/bibtex#" xmlns:ygg="http://bio2rdf.org/ygg#">

    	<xsl:variable name="title" select="//ygg:ResulSet[@signature]"/>
      
    	<xsl:variable name="lsid" select="concat('gopubmed:',//QueryString)"/>
    	<xsl:variable name="uri" select="concat('http://bio2rdf.org/',$lsid)"/>          
    	<xsl:variable name="maj" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    	<xsl:variable name="min" select="'abcdefghijklmnopqrstuvwxyz'"/>

<xsl:element name="bibtex:Article">	
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
	<xsl:element name="bio2rdf:url">	
		<xsl:value-of select="concat('http://bio2rdf.org/html/',$lsid)"/>    		
	</xsl:element>	
	
	<xsl:for-each select="//Document">
	 	<xsl:element name="bio2rdf:xArticle">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="concat('http://bio2rdf.org/pubmed:',substring-after(@id,'?'))"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:for-each>

	<xsl:for-each select="//Attr[@name='ISSN']">
	 	<xsl:element name="gopubmed:xISSN">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="concat('http://bio2rdf.org/issn:',.)"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:for-each>

	<xsl:for-each select="//DocAnnotations[@type='PubMedMeshAnnotation']/Annotation">
	 	<xsl:element name="bio2rdf:xMeSH">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="concat('http://bio2rdf.org/mesh:id-', substring-after(@term,'#'))"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:for-each>

	<xsl:for-each select="//DocAnnotations[@type='wiki']/Annotation">
	 	<xsl:element name="bio2rdf:xDBPedia">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="concat('http://bio2rdf.org/dbpedia:', substring-after(@term,'#'))"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:for-each>

	<xsl:for-each select="//TextAnnotations[@type='OntologyAttributeAnnotation']/Annotation">
		<xsl:choose>
			<xsl:when test="substring-before(@term,'#') = 'http://biotec.tu-dresden.de/mesh'">
			 	<xsl:element name="gopubmed:xOntology">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/mesh:id-', substring-after(@term,'#'))"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:when test="substring-before(@term,'#') = 'http://www.geneontology.org/go'">
			 	<xsl:element name="bio2rdf:xGO">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/go:', substring-after(@term,'#'))"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:for-each>

</xsl:element>	

</rdf:RDF>
</xsl:template>
</xsl:stylesheet>