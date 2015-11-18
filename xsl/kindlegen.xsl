<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:param name="ignore-warnings" select="'no'"/>
  <xsl:param name="severity-regex" select="'^(Fehler|Error|Warning|Warnung)(\(.+\):)?([A-Z]\d+):\s?'"/>
  <xsl:param name="svrl-srcpath" select="'BC_orphans'"/>
  
  <xsl:template match="/cx:document">
    <svrl:schematron-output transpect:rule-family="kindlegen" transpect:step-name="kindlegen">
      <xsl:apply-templates/>
    </svrl:schematron-output>
  </xsl:template>
  
  <xsl:template match="c:result">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!--  *
        * stdout = c:result[1]
        * stderr = c:result[2]
        * -->
  
  <xsl:template match="c:result[1]/c:line[not(child::node()) or not(matches(., $severity-regex))]"/>
  
  <xsl:template match="c:result[1]/c:line[matches(., $severity-regex)]">
    <xsl:variable name="severity-txt" select="lower-case(replace(., concat($severity-regex, '.+$'), '$1'))" as="xs:string"/>
    <xsl:variable name="severity" select="if(matches($severity-txt, 'fehler|error')) then 'error' 
      else 'warning'" as="xs:string"/>
    <xsl:variable name="error-code" select="replace(., concat($severity-regex, '(.+)$'), '$3')" as="xs:string"/>
    <xsl:variable name="error-msg" select="replace(., concat($severity-regex, '(.+)$'), '$4')" as="xs:string"/>
    <xsl:variable name="svrl-srcpath" select="$svrl-srcpath" as="xs:string"/>
    <xsl:if test="not($ignore-warnings eq 'yes' and $severity eq 'warning')">
      <svrl:failed-assert test="{$svrl-srcpath}" 
        id="{$error-code}" 
        role="{$severity}" location="{$svrl-srcpath}">
        <svrl:text>
          <s:span class="srcpath">
            <xsl:value-of select="$svrl-srcpath"/>
          </s:span>
          <s:span class="kindlegen">
            <xsl:value-of select="$error-msg"/>
          </s:span>
        </svrl:text>
      </svrl:failed-assert>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:result[2]/c:line">
    <svrl:failed-assert test="{$svrl-srcpath}" 
      id="{normalize-space(replace(., '.+\p{L}{20}', ''))}" 
      role="{'error'}" location="{$svrl-srcpath}">
      <svrl:text>
        <s:span class="srcpath">
          <xsl:value-of select="$svrl-srcpath"/>
        </s:span>
        <s:span class="kindlegen">
          <xsl:value-of select="."/>
        </s:span>
      </svrl:text>
    </svrl:failed-assert>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>