<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<rdf:RDF 
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"

        xmlns:bio2rdf="http://bio2rdf.org/ns/bio2rdf:"
        xmlns:geneid="http://bio2rdf.org/ns/geneid:"
        xmlns:pubchem="http://bio2rdf.org/ns/pubchem:"		
        xmlns="http://bio2rdf.org/ns/geneid:"
>

        <xsl:variable name="database" select='//Gene-ref_desc'/>
      
        <xsl:variable name="lsid" select="concat('geneid:',//Gene-track_geneid)"/>
        <xsl:variable name="uri" select="concat('http://bio2rdf.org/',$lsid)"/>          

        <xsl:variable name="maj" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ/#: '"/>
        <xsl:variable name="min" select="'abcdefghijklmnopqrstuvwxyz---_'"/>

<xsl:element name="pubchem:Substance" >
        <xsl:attribute name="rdf:about"><xsl:value-of select="$uri"/></xsl:attribute>    

        <xsl:element name="dc:title" >
                <xsl:value-of select="$title"/>
        </xsl:element>
        <xsl:element name="dc:identifier" >
                <xsl:value-of select="$lsid"/>
        </xsl:element>
        <xsl:element name="rdfs:comment" >
                <xsl:value-of select="//Entrezgene_summary"/>
        </xsl:element>
        <xsl:element name="rdfs:label" >
                <xsl:value-of select="$title"/> [<xsl:value-of select="$lsid"/>]
        </xsl:element>
        <xsl:element name="bio2rdf:url" >
                <xsl:value-of select="concat('http://bio2rdf.org/html/',$lsid)"/>
        </xsl:element>

        <xsl:for-each select="//Gene-track_create-date/Date/Date_std/Date-std/Date-std_year">
                <xsl:element name="dc:created" ><xsl:value-of select="concat(., '-', ../Date-std_month, '-', ../Date-std_day)"/></xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//Gene-track_update-date/Date/Date_std/Date-std/Date-std_year">
                <xsl:element name="dc:modified" ><xsl:value-of select="concat(., '-', ../Date-std_month, '-', ../Date-std_day)"/></xsl:element>
        </xsl:for-each>

        <xsl:for-each select="//Gene-track_discontinue-date/Date/Date_std/Date-std/Date-std_year">
                <xsl:element name="bio2rdf:replaced" ><xsl:value-of select="concat(., '-', ../Date-std_month, '-', ../Date-std_day)"/></xsl:element>
                <xsl:element name="dc:isReplacedBy" >
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/geneid:',//Gene-track_current-id/Dbtag[2]/Dbtag_tag/Object-id/Object-id_id)"/></xsl:attribute> 
                </xsl:element>
                <xsl:element name="rdfs:seeAlso" >
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/geneid:',//Gene-track_current-id/Dbtag[2]/Dbtag_tag/Object-id/Object-id_id)"/></xsl:attribute> 
                </xsl:element>
        </xsl:for-each>

        <xsl:for-each select="//Gene-ref_syn_E">
                <xsl:element name="bio2rdf:synonym" ><xsl:value-of select="."/></xsl:element>
        </xsl:for-each>

        <xsl:element name="bio2rdf:symbol" ><xsl:value-of select="//Gene-ref_locus."/></xsl:element>
        <xsl:element name="bio2rdf:subType" ><xsl:value-of select="//Entrezgene_type/@value"/></xsl:element>
        <xsl:element name="geneid:location" ><xsl:value-of select="//Gene-ref_maploc"/></xsl:element>
        <xsl:element name="geneid:chromosome" ><xsl:value-of select="/Entrezgene/Entrezgene_source/BioSource/BioSource_subtype/SubSource/SubSource_name"/></xsl:element>
        <xsl:element name="geneid:fromInterval" ><xsl:value-of select="/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_seqs/Seq-loc/Seq-loc_int/Seq-interval/Seq-interval_from"/></xsl:element>
        <xsl:element name="geneid:toInterval" ><xsl:value-of select="/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_seqs/Seq-loc/Seq-loc_int/Seq-interval/Seq-interval_to"/></xsl:element>

        <xsl:for-each select="//Seq-id_gi">
                <xsl:element name="bio2rdf:xGI" >
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/gi:',.)"/></xsl:attribute> 
                </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//PubMedId">
                <xsl:element name="bio2rdf:xPubMed" >
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/pubmed:',.)"/></xsl:attribute> 
                </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//Gene-commentary_type">
                <xsl:choose>
                        <xsl:when test=". = '1' or . = '3'">
                                <xsl:if test="../Gene-commentary_accession != ''">
                                        <xsl:element name="bio2rdf:xGenBank" >
                                                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/genbank:',../Gene-commentary_accession)"/></xsl:attribute> 
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if test="../Gene-commentary_version != '0'">
                                        <xsl:element name="bio2rdf:xGenBank" >
                                                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/genbank:',../Gene-commentary_accession,'.',../Gene-commentary_version)"/></xsl:attribute> 
                                        </xsl:element>
                                </xsl:if>
                        </xsl:when>
                        <xsl:when test=". = '8'">
                                <xsl:if test="../Gene-commentary_accession != ''">
                                        <xsl:element name="bio2rdf:xProteinID" >
                                                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/proteinid:',../Gene-commentary_accession)"/></xsl:attribute> 
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if test="../Gene-commentary_version != '0'">
                                        <xsl:element name="bio2rdf:xProteinID" >
                                                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/proteinid:',../Gene-commentary_accession,'.',../Gene-commentary_version)"/></xsl:attribute> 
                                        </xsl:element>
                                </xsl:if>
                        </xsl:when>
                        <xsl:when test=". = '16'">
                                <xsl:element name="bio2rdf:xEC" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/ec:',../Gene-commentary_text)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="//Object-id_id">
                <xsl:choose>
                        <xsl:when test="../../../Dbtag_db = 'GO'">
                                <xsl:element name="bio2rdf:xGO" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',translate(../../../Dbtag_db,$maj,$min),':',concat(substring('0000000',1,7-string-length(.)),.))"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'MIM'">
                                <xsl:element name="bio2rdf:xOMIM" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/omim:',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'taxon'">
                                <xsl:element name="bio2rdf:xTaxon" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/taxon:',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:element name="bio2rdf:xRef" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',translate(../../../Dbtag_db,$maj,$min),':',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="//Object-id_str">
                <xsl:choose>
                        <xsl:when test="../../../Dbtag_db = 'UniProtKB/TrEMBL'">
                                <xsl:element name="bio2rdf:xPath" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/uniprot:',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'UniProtKB/Swiss-Prot'">
                                <xsl:element name="bio2rdf:xPath" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/uniprot:',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'GDB'">
                                <xsl:element name="bio2rdf:xGDB" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/gdb:',translate(.,':',''))"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'KEGG'">
                                <xsl:element name="bio2rdf:xKeggGene" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/kegg:',translate(.,':',''))"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="../../../Dbtag_db = 'KEGG pathway'">
                                <xsl:element name="bio2rdf:xPath" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/path:ko',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:when test="starts-with(../../../Dbtag_db, 'KIAA')">
                                <xsl:element name="bio2rdf:xKIAA" >
                                        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/kiaa:',.)"/></xsl:attribute> 
                                </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:if test="../../../Dbtag_db != ''">
                                        <xsl:element name="bio2rdf:xRef" >
                                                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat('http://bio2rdf.org/',translate(../../../Dbtag_db,$maj,$min),':',.)"/></xsl:attribute> 
                                        </xsl:element>
                                </xsl:if>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:for-each>
</xsl:element>

</rdf:RDF>
</xsl:template>
</xsl:stylesheet>
