<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

    <!-- ================================================================= -->

        <!-- Template for converting Gemini 2.2 to Gemini 2.3 -->

    <!-- ================================================================= -->


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>



    <!-- ================================================================= -->

    <!-- Resource Constraints -->

    <!-- TODO Needs some tests to copy existing constraints into new encoding
        or these below as defaults -->


    <xsl:template match="gmd:resourceConstraints[descendant::gmd:accessConstraints]" priority="10">
        <xsl:copy copy-namespaces="no">
            <!--<xsl:apply-templates select="@*|node()"/>-->
            <xsl:message>=== Adding Access Constraints</xsl:message>
            <gmd:MD_LegalConstraints>
                <gmd:accessConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_RestrictionCode"
                        codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:accessConstraints>
                 <xsl:if test="not(./gmd:MD_LegalConstraints/gmd:accessConstraints)">
                    <xsl:message>=== Adding default access constraint</xsl:message>
                    <gmd:otherConstraints>
                        <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1e">no limitations</gmx:Anchor>
                    </gmd:otherConstraints>
                </xsl:if>
                <xsl:for-each select="./gmd:MD_LegalConstraints/gmd:otherConstraints">
                <xsl:choose>
                    <xsl:when test="./gco:CharacterString">
                    <xsl:variable name="otherConstraint" select="gco:CharacterString"/>
                    <xsl:message>=== Copying existing access constraint character string</xsl:message>
                    <gmd:otherConstraints>
                        <gco:CharacterString><xsl:value-of select="$otherConstraint"/></gco:CharacterString>
                    </gmd:otherConstraints>
                    </xsl:when>
                     <xsl:when test="./gmx:Anchor">
                    <xsl:variable name="otherConstrainttext" select="gmx:Anchor"/>
                    <xsl:variable name="otherConstrainthref" select="gmx:Anchor/@xlink:href"/>
                    <xsl:message>=== Copying existing access constraint anchor</xsl:message>
                    <gmd:otherConstraints>
                        <gmx:Anchor xlink:href="{$otherConstrainthref}"><xsl:value-of select="$otherConstrainttext"/></gmx:Anchor>
                    </gmd:otherConstraints>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            </gmd:MD_LegalConstraints>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:resourceConstraints[child::gmd:MD_Constraints]" priority="10">
        <xsl:copy copy-namespaces="no">
            <xsl:message>=== Adding Use Constraints</xsl:message>
            <!--<xsl:apply-templates select="@*|node()"/>-->
            <gmd:MD_LegalConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_RestrictionCode"
                        codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:useConstraints>
                <xsl:if test="not(./gmd:MD_Constraints/gmd:useLimitation)">
                        <xsl:message>=== Adding default use Limitation</xsl:message>
                        <gmd:otherConstraints>
                            <gmx:Anchor>no conditions apply</gmx:Anchor>
                        </gmd:otherConstraints>
                </xsl:if>
                <xsl:for-each select="./gmd:MD_Constraints/gmd:useLimitation">
                    <xsl:choose>
                            <xsl:when test="./gco:CharacterString">
                                <xsl:variable name="useLimitation" select="gco:CharacterString"/>
                                <xsl:message>=== Copying existing use Limitation character string</xsl:message>
                                <gmd:otherConstraints>
                                    <gco:CharacterString><xsl:value-of select="$useLimitation"/></gco:CharacterString>
                                    </gmd:otherConstraints>
                            </xsl:when>
                            <xsl:when test="./gmx:Anchor">
                                <xsl:variable name="useLimitationtext" select="gmx:Anchor"/>
                                <xsl:variable name="useLimitationhref" select="gmx:Anchor/@xlink:href"/>
                                <xsl:message>=== Copying existing use limitation anchor</xsl:message>
                                <gmd:otherConstraints>
                                    <gmx:Anchor xlink:href="{$useLimitationhref}"><xsl:value-of select="$useLimitationtext"/></gmx:Anchor>
                                </gmd:otherConstraints>
                            </xsl:when>
                        </xsl:choose>
                        </xsl:for-each>
            </gmd:MD_LegalConstraints>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" priority="1">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
            <xsl:namespace name="srv" select="'http://www.isotc211.org/2005/srv'"/>
            <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
            <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
            <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@xsi:schemaLocation" priority="10"/>

    <!--  Change standard to UK GEMINI  -->
    <xsl:template match="//gmd:metadataStandardName"  priority="10">
        <xsl:message>=== Updating Metadata Standard Name</xsl:message>
        <gmd:metadataStandardName>
            <gmx:Anchor xlink:href="http://vocab.nerc.ac.uk/collection/M25/current/GEMINI/">UK GEMINI</gmx:Anchor>
        </gmd:metadataStandardName>
    </xsl:template>

    <xsl:template match="//gmd:metadataStandardVersion"  priority="10">
        <xsl:message>=== Updating Metadata Standard Version</xsl:message>
        <gmd:metadataStandardVersion>
            <gco:CharacterString>2.3</gco:CharacterString>
        </gmd:metadataStandardVersion>

    </xsl:template>



    <!-- ================================================================= -->
    <!-- Insert character encoding as utf8 if it does not exist -->

    <xsl:template match="gmd:identificationInfo/*/gmd:characterSet" priority="10">
      <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(gmd:MD_CharacterSetCode/@codeListValue='utf8')">
        <xsl:message>==== Add missing encoding ====</xsl:message>
            <gmd:MD_CharacterSetCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_CharacterSetCode"
                                     codeListValue="utf8"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>==== Copying existing encoding ====</xsl:message>
          <xsl:apply-templates select="gmd:MD_CharacterSetCode"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <!-- Add default conformance snippet -->

    <xsl:template match="gmd:DQ_DataQuality" priority="10">
        <gmd:DQ_DataQuality>
        <xsl:apply-templates select="gmd:scope"/>
        <!-- <xsl:copy copy-namespaces="no"> -->
        <xsl:choose>
            <xsl:when test="not(gmd:report)">
            <xsl:message>=== Adding default conformance report for datasets, series and invocable spatial data services ===</xsl:message>
            <gmd:report>
                <gmd:DQ_DomainConsistency>
                    <gmd:result>
                        <gmd:DQ_ConformanceResult>
                            <gmd:specification>
                                <gmd:CI_Citation>
                                    <gmd:title>
                                        <gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2010/1089">Commission Regulation (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services</gmx:Anchor>
                                    </gmd:title>
                                    <gmd:date>
                                        <gmd:CI_Date>
                                            <gmd:date>
                                                <gco:Date>2010-12-08</gco:Date>
                                            </gmd:date>
                                            <gmd:dateType>
                                                <gmd:CI_DateTypeCode codeList='http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#CI_DateTypeCode' codeListValue='publication' />
                                            </gmd:dateType>
                                        </gmd:CI_Date>
                                    </gmd:date>
                                </gmd:CI_Citation>
                            </gmd:specification>
                            <!-- Explanation is a required element but can be empty -->
                            <gmd:explanation gco:nilReason="inapplicable"/>
                            <!-- Conformance has not been evaluated -->
                            <gmd:pass gco:nilReason="unknown" />
                        </gmd:DQ_ConformanceResult>
                    </gmd:result>
                </gmd:DQ_DomainConsistency>
            </gmd:report>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>=== Copying existing conformity report ===</xsl:message>
            <xsl:apply-templates select="gmd:report"/>
        </xsl:otherwise>
    </xsl:choose>

    <!-- </xsl:copy> -->
    <xsl:apply-templates select="gmd:lineage"/>
    </gmd:DQ_DataQuality>
    </xsl:template>


    <!-- ================================================================= -->
    <!-- fix service hierarchy level description if not present -->

    <xsl:template match="gmd:DQ_Scope" priority="10">
        <xsl:copy>
        <xsl:apply-templates select="gmd:level"/>
            <xsl:if test="not(gmd:levelDescription) and gmd:level/gmd:MD_ScopeCode[@codeListValue='service']">
                <xsl:message>=== Adding level description for service ===</xsl:message>
                <gmd:levelDescription>
                  <gmd:MD_ScopeDescription>
                     <gmd:other>
                        <gco:CharacterString xmlns:gco="http://www.isotc211.org/2005/gco">service</gco:CharacterString>
                     </gmd:other>
                  </gmd:MD_ScopeDescription>
               </gmd:levelDescription>
            </xsl:if>
            <xsl:if test="gmd:levelDescription and gmd:level/gmd:MD_ScopeCode[@codeListValue='service']">
                <xsl:message>=== Copying existing level description ===</xsl:message>
                <xsl:apply-templates select="gmd:levelDescription"/>
            </xsl:if>
            <xsl:if test="not(gmd:level/gmd:MD_ScopeCode[@codeListValue='service'])">
                <xsl:message>=== Not a service record ===</xsl:message>
            </xsl:if>
        </xsl:copy>
        </xsl:template>
    <!-- ================================================================= -->

    <!--  Remove geonet:* elements.  -->
    <xsl:template match="geonet:*" priority="10"/>

</xsl:stylesheet>
