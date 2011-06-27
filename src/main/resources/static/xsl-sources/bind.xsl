<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<xsl:variable name="title" select="/BIND-Interaction/BIND-Interaction_descr/BIND-descr/BIND-descr_simple-descr"/>
		<xsl:variable name="titleA" select="/BIND-Interaction/BIND-Interaction_a/BIND-object/BIND-object_short-label"/>
		<xsl:variable name="titleB" select="/BIND-Interaction/BIND-Interaction_b/BIND-object/BIND-object_short-label"/>
		<xsl:variable name="year" select="/BIND-Interaction/BIND-Interaction_date/Date/Date_std/Date-std/Date-std_year"/>
		<xsl:variable name="month" select="/BIND-Interaction/BIND-Interaction_date/Date/Date_std/Date-std/Date-std_month"/>
		<xsl:variable name="day" select="/BIND-Interaction/BIND-Interaction_date/Date/Date_std/Date-std/Date-std_day"/>
		<xsl:variable name="bmid" select="concat('bind:',/BIND-Interaction/BIND-Interaction_iid/Interaction-id)"/>
		<xsl:variable name="bmidA" select="concat($bmid,'A')"/>
		<xsl:variable name="bmidB" select="concat($bmid,'B')"/>
		<xsl:variable name="uri" select="concat('http://bio2rdf.org/',$bmid)"/>
		<xsl:variable name="uriA" select="concat('http://bio2rdf.org/',$bmidA)"/>
		<xsl:variable name="uriB" select="concat('http://bio2rdf.org/',$bmidB)"/>
		<xsl:variable name="giA" select="concat('http://bio2rdf.org/gi:',BIND-Interaction/BIND-Interaction_a/BIND-object/BIND-object_id/BIND-object-type-id/BIND-object-type-id_protein/BIND-id/BIND-id_gi/Geninfo-id)"/>
		<xsl:variable name="giB" select="concat('http://bio2rdf.org/gi:',BIND-Interaction/BIND-Interaction_b/BIND-object/BIND-object_id/BIND-object-type-id/BIND-object-type-id_protein/BIND-id/BIND-id_gi/Geninfo-id)"/>
		<xsl:variable name="commentA" select="/BIND-Interaction/BIND-Interaction_a/BIND-object/BIND-object_descr"/>
		<xsl:variable name="commentB" select="/BIND-Interaction/BIND-Interaction_b/BIND-object/BIND-object_descr"/>
		<xsl:variable name="maj" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ/#: '"/>
		<xsl:variable name="min" select="'abcdefghijklmnopqrstuvwxyz---_'"/>

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://bio2rdf.org/ns/bind:Interaction&gt; .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://bio2rdf.org/ns/bind:InteractingElement&gt; .
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://bio2rdf.org/ns/bind:InteractingElement&gt; .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/title&gt; "<xsl:value-of select="$title"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/identifier&gt; "<xsl:value-of select="$bmid"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://purl.org/dc/elements/1.1/created&gt; "<xsl:value-of select="concat($year,'-',$month,'-',$day)"/>" .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#label&gt; "<xsl:value-of select="concat($title, ' [', $bmid, ']')"/>" .

		<xsl:for-each select="/BIND-Interaction/BIND-Interaction_source/BIND-pub-set/BIND-pub-set_pubs/BIND-pub-object/BIND-pub-object_pub/Pub/Pub_medline/Medline-entry/Medline-entry_cit/Cit-art/Cit-art_ids/ArticleIdSet">
			<xsl:variable name="pmid" select="concat('http://bio2rdf.org/pubmed:', ./ArticleId/ArticleId_pubmed/PubMedId)"/>
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/ns/bind:xPubmed&gt; &lt;<xsl:value-of select="$pmid"/>&gt; .
		</xsl:for-each>

&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/ns/bind:interactionPart&gt; &lt;<xsl:value-of select="$uriA"/>&gt; .
&lt;<xsl:value-of select="$uri"/>&gt; &lt;http://bio2rdf.org/ns/bind:interactionPart&gt; &lt;<xsl:value-of select="$uriB"/>&gt; .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://purl.org/dc/elements/1.1/title&gt; "<xsl:value-of select="$titleA"/>" .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://purl.org/dc/elements/1.1/identifier&gt; "<xsl:value-of select="$bmidA"/>" .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#label&gt; "<xsl:value-of select="concat($titleA, ' [', $bmidA, ']')"/>" .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://bio2rdf.org/ns/bind:xGI&gt; &lt;<xsl:value-of select="$giA"/>&gt; .
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#comment&gt; "<xsl:value-of select="$commentA"/>" .
		<xsl:for-each select="/BIND-Interaction/BIND-Interaction_descr/BIND-descr/BIND-descr_cond/BIND-condition-set/BIND-condition-set_conditions/BIND-condition/BIND-condition_exp-form-a/BIND-experimental-form/BIND-experimental-form_object/BIND-object/BIND-object_extref/BIND-other-db">
			<xsl:variable name="dbA" select="translate(./BIND-other-db_dbname,$maj,$min)"/>
			<xsl:variable name="idAint" select="./BIND-other-db_intp"/>
			<xsl:variable name="idAstr" select="./BIND-other-db_strp"/>
			<xsl:choose>
                                <xsl:when test="$idAint = '0'">
					<xsl:variable name="uriAxRef" select="concat('http://bio2rdf.org/',$dbA,':',$idAstr)"/>
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://bio2rdf.org/ns/bind:xRef&gt; &lt;<xsl:value-of select="$uriAxRef"/>&gt; .
                                </xsl:when>
                                <xsl:otherwise>
					<xsl:variable name="uriAxRef" select="concat('http://bio2rdf.org/',$dbA,':',$idAint)"/>
&lt;<xsl:value-of select="$uriA"/>&gt; &lt;http://bio2rdf.org/ns/bind:xRef&gt; &lt;<xsl:value-of select="$uriAxRef"/>&gt; .
                                </xsl:otherwise>
                        </xsl:choose>
		</xsl:for-each>

&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://purl.org/dc/elements/1.1/title&gt; "<xsl:value-of select="$titleB"/>" .
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://purl.org/dc/elements/1.1/identifier&gt; "<xsl:value-of select="$bmidB"/>" .
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#label&gt; "<xsl:value-of select="concat($titleB, ' [', $bmidB, ']')"/>" .
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://bio2rdf.org/ns/bind:xGI&gt; &lt;<xsl:value-of select="$giB"/>&gt; .
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://www.w3.org/2000/01/rdf-schema#comment&gt; "<xsl:value-of select="$commentB"/>" .
		<xsl:for-each select="/BIND-Interaction/BIND-Interaction_descr/BIND-descr/BIND-descr_cond/BIND-condition-set/BIND-condition-set_conditions/BIND-condition/BIND-condition_exp-form-b/BIND-experimental-form/BIND-experimental-form_object/BIND-object/BIND-object_extref/BIND-other-db">
			<xsl:variable name="dbB" select="translate(./BIND-other-db_dbname,$maj,$min)"/>
			<xsl:variable name="idBint" select="./BIND-other-db_intp"/>
			<xsl:variable name="idBstr" select="./BIND-other-db_strp"/>
			<xsl:choose>
                                <xsl:when test="$idBint = '0'">
					<xsl:variable name="uriBxRef" select="concat('http://bio2rdf.org/',$dbB,':',$idBstr)"/>
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://bio2rdf.org/ns/bind:xRef&gt; &lt;<xsl:value-of select="$uriBxRef"/>&gt; .
                                </xsl:when>
                                <xsl:otherwise>
					<xsl:variable name="uriBxRef" select="concat('http://bio2rdf.org/',$dbB,':',$idBint)"/>
&lt;<xsl:value-of select="$uriB"/>&gt; &lt;http://bio2rdf.org/ns/bind:xRef&gt; &lt;<xsl:value-of select="$uriBxRef"/>&gt; .
                                </xsl:otherwise>
                        </xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
