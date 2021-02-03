<?xml version="1.0" encoding="UTF-8" ?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                version="2.0"
>

   <xsl:import href="../../iso19139/index-fields/index-subtemplate.xsl"/>

   <!-- conformity directory entries -->

    <xsl:template mode="index" match="gmd:DQ_DomainConsistency[count(ancestor::node()) =  1]">
    <xsl:variable name="date"
                  select="*/gmd:specification/*/gmd:date/*/gmd:date/gco:Date"/>
    <Field name="_title"
           string="{gmd:result/*/gmd:explanation/gco:CharacterString}{if ($date != '') then concat(' (', $date, ')') else ''}"
           store="true" index="true"/>

        <xsl:call-template name="subtemplate-common-fields"/>
    </xsl:template>

    <xsl:template mode="index" match="gmd:DQ_CompletenessCommission[count(ancestor::node()) =  1]">
    <xsl:variable name="date"
                  select="*/gmd:specification/*/gmd:date/*/gmd:date/gco:Date"/>
    <Field name="_title"
           string="{gmd:result/*/gmd:explanation/gco:CharacterString/text()}{if ($date != '') then concat(' (', $date, ')') else ''}"
           store="true" index="true"/>

        <xsl:call-template name="subtemplate-common-fields"/>
    </xsl:template>

    <!-- use constraints directory entries -->

    <!-- use constraints entries -->

    <xsl:template mode="index" match="gmd:MD_LegalConstraints[count(ancestor::node()) =  1][gmd:useConstraints]">
    <Field name="_title"
           string="{if ($title !='') then $title else concat('Use Constraint: ',//gmd:otherConstraints/gmx:Anchor)}"
           store="true" index="true"/>

        <xsl:call-template name="subtemplate-common-fields"/>
    </xsl:template>


    <!-- access constraints directory entries -->

     <xsl:template mode="index" match="gmd:MD_LegalConstraints[count(ancestor::node()) =  1][gmd:accessConstraints]">
    <Field name="_title"
           string="{if ($title !='') then $title else concat('Access Limitation: ',//gmd:otherConstraints/gmx:Anchor)}"
           store="true" index="true"/>

        <xsl:call-template name="subtemplate-common-fields"/>
    </xsl:template>


    <xsl:template name="subtemplate-common-fields">
        <Field name="any" string="{normalize-space(string(.))}" store="false" index="true"/>
        <Field name="_root" string="{name(.)}" store="true" index="true"/>
    </xsl:template>


</xsl:stylesheet>
