<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<xsl:variable name="title" select="//PubmedArticle/MedlineCitation/Article/ArticleTitle"/>
		<xsl:variable name="bmid" select="concat('pubmed:',//PubmedArticle/MedlineCitation/PMID)"/>
		<xsl:variable name="uri" select="concat('http://bio2rdf.org/',$bmid)"/>
		<xsl:variable name="maj" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ/#: '"/>
		<xsl:variable name="min" select="'abcdefghijklmnopqrstuvwxyz---_'"/>

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://bio2rdf.org/pubmed_resource:Article&gt; .

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/title&gt; "<xsl:value-of select="$title"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/identifier&gt; "<xsl:value-of select="$bmid"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/created&gt; "<xsl:value-of select="concat(//MedlineCitation/DateCreated/Year,'-',//MedlineCitation/DateCreated/Month,'-',//MedlineCitation/DateCreated/Day)"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/issued&gt; "<xsl:value-of select="concat(//MedlineCitation/DateCompleted/Year,'-',//MedlineCitation/DateCompleted/Month,'-',//MedlineCitation/DateCompleted/Day)"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/modified&gt; "<xsl:value-of select="concat(//MedlineCitation/DateRevised/Year,'-',//MedlineCitation/DateRevised/Month,'-',//MedlineCitation/DateRevised/Day)"/>" .

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#comment&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Abstract/AbstractText"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#label&gt; "<xsl:value-of select="concat($title, ' [', $bmid, ']')"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:url&gt; "<xsl:value-of select="concat('http://bio2rdf.org/html/',$bmid)"/>" .

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xJournal&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/journal:',translate(//PubmedArticle/MedlineCitation/Article/Journal/Title,'/#: ','---_'))"/>&gt; .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#volume&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Volume"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#number&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Issue"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#year&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#month&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#day&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate/Day"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/net/nknouf/ns/bibtex#pages&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Pagination/MedlinePgn"/>" .
	
		<xsl:choose>
			<xsl:when test="//PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType='doi'] != ''">
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xDOI&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/doi:',//PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType='doi'])"/>&gt; .
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="//PubmedArticle/MedlineCitation/Article/AuthorList/Author">
			<xsl:variable name="person" select="concat(translate(./LastName,' ','_'),',',translate(./Initials,' ','_'))"/>
			<xsl:variable name="personURI" select="concat('http://bio2rdf.org/foaf:', $person)"/>
	
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/creator&gt; &lt;<xsl:value-of select="$personURI"/>&gt; .
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://xmlns.com/foaf/0.1/Person&gt; .
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#label&gt; "[<xsl:value-of select="$person"/>]" . 

			<xsl:choose>
				<xsl:when test="./ForeName != ''">
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/name&gt; "<xsl:value-of select="concat(./ForeName,' ',./LastName)"/>" .
				</xsl:when>
				<xsl:when test="./FirstName != ''">
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/name&gt; "<xsl:value-of select="concat(./FirstName,' ',./LastName)"/>" .
				</xsl:when>
				<xsl:otherwise>
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/name&gt; "<xsl:value-of select="concat(./Initials,' ',./LastName)"/>" .
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="./ForeName != ''">
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/givenname&gt; "<xsl:value-of select="./ForeName"/>" .
				</xsl:when>
				<xsl:when test="./FirstName != ''">
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/givenname&gt; "<xsl:value-of select="./FirstName"/>" .
				</xsl:when>
				<xsl:otherwise>
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/givenname&gt; "<xsl:value-of select="./Initials"/>" .
				</xsl:otherwise>
			</xsl:choose>

&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://xmlns.com/foaf/0.1/family_name&gt; "<xsl:value-of select="./LastName"/>" .
&lt;<xsl:value-of select="$personURI"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:Group&gt; "<xsl:value-of select="//PubmedArticle/MedlineCitation/Article/Affiliation"/>" .
		</xsl:for-each>
		<xsl:for-each select="//PubmedArticle/MedlineCitation/MeshHeadingList/MeshHeading">
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xMeSH&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/mesh:',translate(./DescriptorName,' ','_'))"/>&gt; .
		</xsl:for-each>
		<xsl:for-each select="//PubmedArticle/MedlineCitation/ChemicalList/Chemical">
			<xsl:choose>
				<xsl:when test="./RegistryNumber = '0'">
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xChemical&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/pchem:',translate(./NameOfSubstance,' ','_'))"/>&gt; .
				</xsl:when>
				<xsl:otherwise>
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xChemical&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/pchem:',translate(./RegistryNumber,' ','_'))"/>&gt; .
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="//PubmedArticle/MedlineCitation/Article/DataBankList/DataBank">
			<xsl:for-each select="./AccessionNumberList/AccessionNumber">
				<xsl:choose>
					<xsl:when test="./../../DataBankName = 'GENBANK'">
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xGenBank&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/genbank:',.)"/>&gt; .
					</xsl:when>
					<xsl:when test="./../../DataBankName = 'OMIM'">
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xOMIM&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/omim:',.)"/>&gt; .
						</xsl:when>
					<xsl:otherwise>
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/bio2rdf_resource:xRef&gt; &lt;<xsl:value-of select="concat('http://bio2rdf.org/',translate(./../../DataBankName,$maj,$min),':',.)"/>&gt; .
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

