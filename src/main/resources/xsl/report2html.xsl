<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="r" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:r="http://www.example.org/documenttests">
	<xsl:output encoding="utf-8" indent="yes" method="xml"
		omit-xml-declaration="no"></xsl:output>
	<xsl:strip-space elements="*"></xsl:strip-space>
	<xsl:template match="r:error">
		<dt>
			<xsl:value-of select="@type" />
		</dt>
		<dd>
			<xsl:value-of select="@message" />
		</dd>
	</xsl:template>
	<xsl:template match="r:validation">
		<xsl:if test="count(r:error)&gt;0">
			<div class="popup">
				<h3>Validation errors:</h3>
				<dl>
					<xsl:apply-templates select="r:error" />
				</dl>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template name="openelement">
		<xsl:param name="indent" />
		<xsl:variable name="s"
			select="'                                         '" />
		<xsl:value-of
			select="concat(substring($s, 1, $indent), '&lt;', local-name(.))" />
		<xsl:for-each select="@*">
			<br />
			<xsl:value-of
				select="concat(substring($s, 1, $indent + 2), local-name(.), '=&quot;', ., '&quot;')" />
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="formatxml">
		<xsl:param name="indent">
			0
		</xsl:param>
		<xsl:variable name="s"
			select="'                                         '" />
		<xsl:variable name="i" select="number($indent)" />
		<xsl:for-each select="*|text()">
			<xsl:choose>
				<xsl:when test="count(*)">
					<xsl:call-template name="openelement">
						<xsl:with-param name="indent" select="$i" />
					</xsl:call-template>
					<xsl:value-of select="'>'" />
					<br />
					<xsl:call-template name="formatxml">
						<xsl:with-param name="indent" select="$i + 1" />
					</xsl:call-template>
					<xsl:value-of
						select="concat(substring($s, 1, $i), '&lt;/', local-name(.), '>')" />
					<br />
				</xsl:when>
				<xsl:when test="text()">
					<xsl:call-template name="openelement">
						<xsl:with-param name="indent" select="$i" />
					</xsl:call-template>
					<xsl:value-of select="'>'" />
					<xsl:value-of select="concat(text(), '&lt;', local-name(.), '/>')" />
					<br />
				</xsl:when>
				<xsl:when test="local-name(.)">
					<xsl:call-template name="openelement">
						<xsl:with-param name="indent" select="$i" />
					</xsl:call-template>
					<xsl:value-of select="'/>'" />
					<br />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(substring($s, 1, $i), .)" />
					<br />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="r:input|r:output">
		<div class="popup">
			<xsl:if test="r:fragment">
				<pre>
					<xsl:for-each select="r:fragment">
						<xsl:call-template name="formatxml" />
					</xsl:for-each>
				</pre>
			</xsl:if>
			<a>
				<xsl:attribute name="href">
				<xsl:value-of select="@path" />
			</xsl:attribute>
				<xsl:value-of select='local-name(.)' />
			</a>
			size:
			<xsl:value-of select="@size" />
			<xsl:if test="../r:commands">
				<span>
					<xsl:value-of
						select="concat(', duration: ', sum(../r:commands/@durationMs), ' ms ')" />
				</span>
				<xsl:if test="../r:commands/@stderr">
					<span>
						stderr
						<pre class="output">
							<xsl:value-of select="../r:commands/@stderr" />
						</pre>
					</span>
				</xsl:if>
				<xsl:if test="../r:commands/@stdout">
					<span>
						stdout
						<pre class="output">
							<xsl:value-of select="../r:commands/@stdout" />
						</pre>
					</span>
				</xsl:if>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="pdfpage">
		<xsl:param name="pageNumber" />
		<xsl:param name="outputs" />
		<tr>
			<th>
				<xsl:value-of select="concat('page ', $pageNumber)" />
			</th>
			<td></td>
			<xsl:for-each select="$outputs">
				<td>
					<xsl:if test="r:pdfinfo/r:page[position()=$pageNumber]">
						<xsl:value-of
							select="concat('width: ', r:pdfinfo/r:page[position()=$pageNumber]/@width, ' ')" />
						<br />
						<xsl:value-of
							select="concat('height: ', r:pdfinfo/r:page[position()=$pageNumber]/@height, ' ')" />
						<br />
						<a href="{r:pdfinfo/r:page[position()=$pageNumber]/@png}">
							<img class="thumb"
								src="{r:pdfinfo/r:page[position()=$pageNumber]/@pngthumb}" />
						</a>
					</xsl:if>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
	<xsl:template name="pdfpages">
		<xsl:param name="pageNumber" select="1" />
		<xsl:call-template name="pdfpage">
			<xsl:with-param name="pageNumber" select="$pageNumber" />
			<xsl:with-param name="outputs" select="r:target/r:output[@type='pdf']" />
		</xsl:call-template>
		<xsl:if test="count(r:target/r:output/r:pdfinfo[@pages > $pageNumber]) > 0">
			<xsl:call-template name="pdfpages">
				<xsl:with-param name="pageNumber" select="$pageNumber + 1" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="pdfmask">
		<xsl:variable name="name" select="@name" />
		<tr>
			<th>
				<xsl:value-of select="concat('mask ', $name)" />
			</th>
			<td></td>
			<xsl:for-each select="../../../../r:target/r:output[@type='pdf']">
				<td>
					<xsl:for-each select="r:pdfinfo/r:maskResult[@name=$name]">
						<xsl:value-of select="@result" />
						<br />
						<a href="{@png}">
							<img class="thumb" src="{@png}" style="width:100px" />
						</a>
					</xsl:for-each>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
	<xsl:template name="pdfmasks">
		<xsl:for-each select="r:target/r:output/r:pdfinfo/r:maskResult">
			<xsl:variable name="name" select="@name" />
			<xsl:variable name="masks" select="../../../../r:target/r:output/r:pdfinfo/r:maskResult[@name=$name]" />
			<xsl:if test="../../../@name=$masks[1]/../../../@name">
				<xsl:call-template name="pdfmask"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="r:testreport">
		<tr>
			<th class="testreport">
				<h1>
					<xsl:value-of select="@name" />
				</h1>
			</th>
		</tr>
		<tr>
			<th>
                <xsl:variable name="name" select="r:input[1]/@path"/>
				<xsl:value-of select="substring($name,string-length($name)-2)" />
			</th>
			<th>
				input
				<xsl:apply-templates select="r:input" />
			</th>
			<xsl:for-each select="r:target[r:output[@type!='pdf']]">
				<th>
					<xsl:value-of select="@name" />
					<xsl:apply-templates select="r:output[@type!='pdf']" />
				</th>
			</xsl:for-each>
		</tr>
		<tr>
			<th>valid ODF</th>
			<td class="{count(r:input/r:validation/r:error)=0}">
				<xsl:value-of select="count(r:input/r:validation/r:error)=0" />
				<xsl:apply-templates select="r:input/r:validation" />
			</td>
			<xsl:for-each select="r:target[r:output[@type!='pdf']]">
				<td class="{count(r:output[@type!='pdf']/r:validation/r:error)=0}">
					<xsl:value-of select="count(r:output[@type!='pdf']/r:validation/r:error)=0" />
					<xsl:apply-templates select="r:output[@type!='pdf']/r:validation" />
				</td>
			</xsl:for-each>
		</tr>
		<xsl:for-each select="r:input/r:file[r:xpath]">
			<xsl:variable name="path" select="@path" />
			<tr>
				<th>
					<xsl:value-of select="@path" />
				</th>
			</tr>
			<xsl:for-each select="r:xpath">
				<xsl:variable name="expr" select="@expr" />
				<tr>
					<th>
						<xsl:value-of select="@expr" />
					</th>
					<td class="{@result}">
						<xsl:value-of select="@result" />
					</td>
					<xsl:for-each select="../../../r:target[r:output[@type!='pdf']]">
						<td class="{r:output[@type!='pdf']/r:file[@path=$path]/r:xpath[@expr=$expr]/@result}">
							<xsl:value-of
								select="r:output[@type!='pdf']/r:file[@path=$path]/r:xpath[@expr=$expr]/@result" />
						</td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</xsl:for-each>
		<tr>
			<th>pdf</th>
			<th>
				input
				<xsl:apply-templates select="r:input" />
			</th>
			<xsl:for-each select="r:target[r:output[@type='pdf']]">
				<th>
					<xsl:value-of select="@name" />
					<xsl:apply-templates select="r:output[@type='pdf']" />
				</th>
			</xsl:for-each>
		</tr>
		<tr>
			<th>success</th>
			<td></td>
			<xsl:for-each select="r:target[r:output[@type='pdf']]">
				<td class="{count(r:output[@type='pdf']/r:validation/r:error)=0 and count(r:output[@type='pdf']/r:pdfinfo/r:maskResult[@result='false'])=0}">
					<xsl:value-of
						select="count(r:output[@type='pdf']/r:validation/r:error)=0 and count(r:output[@type='pdf']/r:pdfinfo/r:maskResult[@result='false'])=0" />
					<xsl:apply-templates select="r:output[@type='pdf']/r:validation" />
				</td>
			</xsl:for-each>
		</tr>
		<xsl:call-template name="pdfpages" />
		<xsl:call-template name="pdfmasks" />
	</xsl:template>
	<xsl:template match="/r:documenttestsreport">
		<html>
			<head>
				<title>ODF Automatic tests report</title>
				<style type="text/css">
					.false {background-color: #faa}
					.true {background-color: #afa}
					.popup, .output {
					display: none;
					}
					th:hover .popup,
					td:hover
					.popup, span:hover .output {
					display:
					block;
					position:
					absolute;
					background: white;
					border:
					1px solid black;
					}
					th {
					vertical-align: top;
					font-weight: normal;
					background-color:
					#cccccc;
					text-align:
					left; }
					img.thumb { border: 1px
					solid black; }
					th:nth-child(1) { text-align: right; }
				</style>
			</head>
			<body>
				<table>
					<xsl:apply-templates select="r:testreport" />
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
