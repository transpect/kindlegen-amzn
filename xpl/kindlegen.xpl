<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:pos="http://exproc.org/proposed/steps/os" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="kindlegen"
  type="tr:kindlegen" exclude-inline-prefixes="p pos letex">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>tr:kindlegen</h1>
    <p>A XProc Wrapper for Amazon KindleGen.</p>
    <h2>Usage</h2>
    <p>Pass EPUB file and the location of your kindlegen binary as parameters to this pipeline.</p>
    <pre>java -jar calabash.jar kindlegen.xpl kindlegen=/data/mypath/kindlegen epub=/data/mypath/myepub.epub</pre>
    <p>Note: KindleGen path can be passed as option. If the option is not set, the path is resolved against a XML catalog.</p>
    <h2>Output</h2>
    <p>The MOBI file is stored to the directory of the EPUB file.</p>
    <p>The XML result shipped on the result port is either a <code>c:file</code> or a <code>c:errors</code>, depending on whether KindleGen was executed successfully.</p>
    <pre>
      Success:
      &lt;c:file code="OK" name="C:/home/my-sample.mobi"/>
      
      Warnings:
      &lt;c:file code="warnings" name="C:/home/my-sample.mobi"/>
      
      Errors:
      &lt;c:error tr:rule-family="kindlegen"
        name="C:/home/my-sample.epub">MOBI/KF8 generation failed!&lt;/c:error></pre>
    <h2>Requirements</h2>
    <ul>
      <li><p>Path normalizing requires <a href="https://subversion.le-tex.de/common/xproc-util/file-uri/" target="_blank">tr:file-uri</a>.</p></li>
      <li><p>You have to download KindleGen from <a href="http://www.amazon.com/gp/feature.html?docId=1000765211" target="_blank">here</a> and store it to <i>some-directory</i>&#x2122;</p></li>
      <li><p>Paths are resolved with <a href="https://subversion.le-tex.de/common/letex-util/xslt-based-catalog-resolver/" target="_blank">XSLT-based catalog resolver</a>. You have to rewrite the URI <code>http://customers.le-tex.de/generic/book-conversion/infrastructure/kindlegen/i386/</code> with your local KindleGen install directory by using a XML catalog as it is shown in the example below:</p>
        <pre>
&lt;catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
  &lt;nextCatalog catalog="../store-debug/xmlcatalog/catalog.xml"/>
  &lt;nextCatalog catalog="../file-uri/xmlcatalog/catalog.xml"/>
  &lt;nextCatalog catalog="../xslt-based-catalog-resolver/xmlcatalog/catalog.xml"/>
  
  &lt;rewriteURI uriStartString="http://customers.le-tex.de/generic/book-conversion/xmlcatalog/catalog.xml" rewritePrefix="my-catalog.xml"/>
  &lt;rewriteURI uriStartString="http://customers.le-tex.de/generic/book-conversion/infrastructure/kindlegen/i386/" rewritePrefix="../<i>some-directory</i>/"/>
&lt;/catalog>
        </pre>
      </li>
    </ul>
    <h2>Known Issues</h2>
    <ul>
      <li><p>Consider to use <code>cx:depends-on</code> if your input EPUB file is dynamically generated by another XProc pipeline.</p></li>  
      <li><p>Running kindlegen on 64 bit Linux operating systems requires ia32-libs to be installed.</p></li>
    </ul>
    
  </p:documentation>
  
  <p:output port="result" primary="true"/>
  <p:output port="report" primary="false">
    <p:pipe port="result" step="transform-output"/>
  </p:output>
  
  <p:option name="kindlegen" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Option "kindlegen"</h3>
      <p>Path to kindlegen Binary</p>
    </p:documentation>
  </p:option>
  <p:option name="epub" required="true">
    <p:documentation>
      <h3>Option "epub"</h3>
      <p>Path to EPUB file</p>
    </p:documentation>
  </p:option>
  <p:option name="lang" select="'en'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Option "lang"</h3>
      <p>To display messages in selected language. List of possible codes</p>
      <ul>
        <li>en: Englisch</li>
        <li>de: Deutsch</li>
        <li>fr: Französisch</li>
        <li>it: Italienisch</li>
        <li>es: Spanisch</li>
        <li>zh: Chinesisch</li>
        <li>ja: Japanisch</li>
        <li>pt: Portugiesisch</li>
        <li>ru: Russian</li>
      </ul>
    </p:documentation>
  </p:option>
  
  <p:option name="ignore-warnings" select="'no'"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <tr:simple-progress-msg name="start-msg" file="kindlegen-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">KindleGen started.</c:message>
          <c:message xml:lang="de">KindleGen gestartet.</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>
  
  <!-- get OS type -->
  <pos:info name="info"/>
  
  <!--  *
        * KindleGen path can be either passed as option or if empty, resolved against a XML catalog.
        * -->
  <tr:file-uri name="kindlegen-path">
    <p:with-option name="filename"
      select="if(string-length($kindlegen) gt 0) then $kindlegen
      else if (matches(/c:result/@os-name, 'windows', 'i')) 
        then 'http://this.transpect.io/infrastructure/kindlegen/i386/kindlegen.exe'
        else 'http://this.transpect.io/infrastructure/kindlegen/i386/kindlegen'"/>
    <p:input port="catalog">
      <p:document href="http://customers.le-tex.de/generic/book-conversion/xmlcatalog/catalog.xml"/>
    </p:input>
    <p:input port="resolver">
      <p:document href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
    </p:input>
  </tr:file-uri>
  
  <p:sink/>
  
  <tr:file-uri name="epub-path">
    <p:with-option name="filename" select="$epub"/>
  </tr:file-uri>
  
  <!--  *
        * execute KindleGen
        * -->
  <p:exec name="kindlegen-execute" result-is-xml="false" wrap-error-lines="true" wrap-result-lines="true">
    <p:input port="source">
      <p:empty/>
    </p:input>
    <p:with-option name="command" select="/c:result/@os-path">
      <p:pipe port="result" step="kindlegen-path"/>
    </p:with-option>
    <p:with-option name="args" select="concat('-verbose ', /c:result/@os-path, ' -locale ', ($lang, 'en')[normalize-space()][1])"/>
  </p:exec>
  
  <!--  *
        * if anything goes wrong, the following steps 
        * provide you with valuable debug information
        * -->
  
  <tr:store-debug pipeline-step="kindlegen/exec-errout" extension="xml">
    <p:input port="source">
      <p:pipe port="errors" step="kindlegen-execute"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <tr:store-debug pipeline-step="kindlegen/exec-stdout" extension="xml">
    <p:input port="source">
      <p:pipe port="result" step="kindlegen-execute"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <tr:store-debug pipeline-step="kindlegen/exit-status" extension="xml">
    <p:input port="source">
      <p:pipe port="exit-status" step="kindlegen-execute"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:wrap-sequence wrapper-prefix="cx" wrapper="document" wrapper-namespace="http://xmlcalabash.com/ns/extensions">
    <p:input port="source">
      <p:pipe port="result" step="kindlegen-execute"/>
      <p:pipe port="errors" step="kindlegen-execute"/>
    </p:input>
  </p:wrap-sequence>
  
  <p:xslt name="transform-output">
    <p:with-param name="ignore-warnings" select="$ignore-warnings"/>
    <p:input port="stylesheet">
      <p:document href="../xsl/kindlegen.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <p:choose>
    
    <!--  *
          * KindleGen exit codes 
          *
          * 0: finished succesfully   => MOBI is generated
          * 1: finished with warnings => MOBI is generated
          * 2: aborted with errors    => cancelled
          *
          * -->
    <p:when test="/c:result = ('0', '1')">
      <p:xpath-context>
        <p:pipe port="exit-status" step="kindlegen-execute"/>
      </p:xpath-context>
      
      <!-- attach file name -->
      <p:add-attribute attribute-name="name" match="/c:file">
        <p:with-option name="attribute-value" select="replace(/c:result/@os-path, '^(.+\.)epub$', '$1mobi')">
          <p:pipe port="result" step="epub-path"/>
        </p:with-option>
        <p:input port="source">
          <p:inline><c:file tr:rule-family="kindlegen"/></p:inline>
        </p:input>
      </p:add-attribute>
      
      <!-- attach exit code -->
      <p:add-attribute attribute-name="code" match="/c:file">
        <p:with-option name="attribute-value" select="if(/c:result = 0) then 'OK'
          else 'warnings'">
          <p:pipe port="exit-status" step="kindlegen-execute"/>
        </p:with-option>
      </p:add-attribute>
      
    </p:when>
    
    <!--  *
          * other exit codes
          * -->
    <p:otherwise>
      
      <p:add-attribute attribute-name="name" match="/c:errors">
        <p:with-option name="attribute-value" select="/c:result/@os-path">
          <p:pipe port="result" step="epub-path"/>
        </p:with-option>
        <p:input port="source">
          <p:inline><c:errors tr:rule-family="kindlegen"><c:error code="kindlegen-error" srcpath="BC_orphans">MOBI/KF8 generation failed!</c:error></c:errors></p:inline>
        </p:input>
      </p:add-attribute>
            
    </p:otherwise>
    
  </p:choose>
  
  <tr:simple-progress-msg name="success-msg" file="kindlegen-success.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">KindleGen finished.</c:message>
          <c:message xml:lang="de">KindleGen abgeschlossen.</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
</p:declare-step>