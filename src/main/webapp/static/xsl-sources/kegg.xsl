<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bio2rdf="http://bio2rdf.org/bio2rdf#" xmlns:kegg="http://bio2rdf.org/kegg#">

    <xsl:for-each select="pathway">	
		<xsl:element name="kegg:Pathway">	
	    		<xsl:attribute name="rdf:about">
	    			<xsl:value-of select="concat('http://bio2rdf.org/',@name)"/>
	    		</xsl:attribute>    		
	    		<xsl:element name="bio2rdf:url">
	    			<xsl:value-of select="@link"/>
	    		</xsl:element>    		
	    		<xsl:element name="bio2rdf:urlImage">
	    			<xsl:value-of select="@image"/>
	    		</xsl:element>    		
 			<xsl:element name="rdfs:label">
    				<xsl:value-of select="concat(@title,' [',@name,']')"/>
     			</xsl:element>    		
 			<xsl:element name="dc:title">
    				<xsl:value-of select="@title"/>
     			</xsl:element>    		
 			<xsl:element name="dc:identifier">
    				<xsl:value-of select="@name"/>
     			</xsl:element>    		
   		</xsl:element>
    </xsl:for-each>


    <xsl:for-each select="pathway">	
		<xsl:element name="kegg:Pathway">	
	    		<xsl:attribute name="rdf:about">
	    			<xsl:value-of select="concat('http://bio2rdf.org/',@name)"/>
	    		</xsl:attribute>    		
			<xsl:for-each select="reaction">	
				<xsl:element name="kegg:xReaction">	
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/',@name)"/>
					</xsl:attribute>    		
				</xsl:element>
			</xsl:for-each>
			<xsl:for-each select="relation">	
				<xsl:element name="kegg:xRelation">	
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/',../@name,'-',@entry1,'-',@entry2)"/>
					</xsl:attribute>    		
				</xsl:element>
			</xsl:for-each>
		
   		</xsl:element>
    </xsl:for-each>


    <xsl:for-each select="pathway/entry">	
		<xsl:element name="kegg:Entry">	
	    		<xsl:attribute name="rdf:about">
	    			<xsl:value-of select="concat('http://bio2rdf.org/',../@name,'-',@id)"/>
	    		</xsl:attribute>    		
	    		<xsl:element name="bio2rdf:subType">
	    			<xsl:value-of select="@type"/>
	    		</xsl:element>    		
			<xsl:if test="graphics/@x != ''"> 
				<xsl:element name="kegg:x">
					<xsl:value-of select="graphics/@x"/>
				</xsl:element>    		
				<xsl:element name="kegg:y">
					<xsl:value-of select="graphics/@y"/>
				</xsl:element>    		
				<xsl:element name="kegg:width">
					<xsl:value-of select="graphics/@width"/>
				</xsl:element>    		
				<xsl:element name="kegg:height">
					<xsl:value-of select="graphics/@height"/>
				</xsl:element>    		
				<xsl:element name="kegg:subType">
					<xsl:value-of select="graphics/@type"/>
				</xsl:element>    		
			</xsl:if> 
 			<xsl:element name="kegg:xObject">
    				<xsl:attribute name="rdf:resource">
    					<xsl:value-of select="concat('http://bio2rdf.org/',@name)"/>
    				</xsl:attribute> 
     			</xsl:element>    		
   		</xsl:element>
    </xsl:for-each>

    <xsl:for-each select="pathway/entry[@type='gene']">	
		<xsl:if test="@reaction != ''"> 
			<xsl:element name="kegg:Composite">	
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="concat('http://bio2rdf.org/kegg:composite-',substring-after(@link,'?'))"/>
				</xsl:attribute>    		
				<xsl:element name="dc:title">
					<xsl:value-of select="graphics/@name"/>
				</xsl:element>    		
				<xsl:element name="rdfs:label">
					<xsl:value-of select="concat(graphics/@name,' [',@name,']')"/>
				</xsl:element>    		
				<xsl:element name="bio2rdf:url">
					<xsl:value-of select="@link"/>
				</xsl:element>    		
				<xsl:element name="kegg:xReaction">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/',@reaction)"/>
					</xsl:attribute> 
				</xsl:element>    		
				<xsl:element name="rdfs:seeAlso">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://bio2rdf.org/kegg-genes:',translate(substring-after(@link,'?'),'+',','))"/>
					</xsl:attribute> 
				</xsl:element>    		
			</xsl:element>
		</xsl:if>
    </xsl:for-each>


    <xsl:for-each select="pathway/relation">	
		<xsl:element name="kegg:Relation">	
	    		<xsl:attribute name="rdf:about">
	    			<xsl:value-of select="concat('http://bio2rdf.org/',../@name,'-',@entry1,'-',@entry2)"/>
	    		</xsl:attribute>    		
	    		<xsl:element name="bio2rdf:subType">
	    			<xsl:value-of select="@type"/>
	    		</xsl:element>    		

    			<xsl:element name="kegg:xEntry1">
    				<xsl:attribute name="rdf:resource">
    					<xsl:value-of select="concat('http://bio2rdf.org/',../@name,'-',@entry1)"/>
    				</xsl:attribute> 
     			</xsl:element>    		
   			<xsl:element name="kegg:xEntry2">
    				<xsl:attribute name="rdf:resource">
    					<xsl:value-of select="concat('http://bio2rdf.org/',../@name,'-',@entry2)"/>
    				</xsl:attribute> 
     			</xsl:element>    		
    			<xsl:for-each select="subtype">
    				<xsl:element name="kegg:subtype">
    					<xsl:value-of select="@name"/>
     				</xsl:element>    		
    				<xsl:element name="kegg:value">
    					<xsl:value-of select="@value"/>
     				</xsl:element>    		
		    	</xsl:for-each>
   		</xsl:element>
    </xsl:for-each>

</rdf:RDF>
</xsl:template>
</xsl:stylesheet>