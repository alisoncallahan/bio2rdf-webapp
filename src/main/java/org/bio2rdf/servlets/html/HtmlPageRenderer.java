package org.queryall.servlets.html;

import org.queryall.servlets.GeneralServlet;
import org.queryall.queryutils.*;
import org.queryall.helpers.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.Collection;
import java.util.List;
import java.util.HashSet;

import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.OpenRDFException;
import org.openrdf.model.Statement;
import org.openrdf.model.Value;
import org.openrdf.model.URI;
import info.aduna.xml.XMLUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletContext;

import org.apache.velocity.context.Context;

import org.apache.log4j.Logger;

/**
 * A servlet for serving the HTML page describing a resource.
 * Invokes a Velocity template.
 * 
 * Originally created for Pubby by...
 * @author Richard Cyganiak (richard@cyganiak.de)
 * Ported to Sesame for Bio2RDF by...
 * @author Peter Ansell (p_ansell@yahoo.com)
 * @version $Id: HtmlPageRenderer.java 944 2011-02-08 10:23:08Z p_ansell $
 */

public class HtmlPageRenderer
{
    private static final Logger log = Logger.getLogger(HtmlPageRenderer.class.getName());
    private static final boolean _TRACE = log.isTraceEnabled();
    private static final boolean _DEBUG = log.isDebugEnabled();
    private static final boolean _INFO = log.isInfoEnabled();
    
    public static void renderHtml(ServletContext servletContext, Repository nextRepository, java.io.Writer nextWriter, Collection<String> debugStrings, String queryString, String resolvedUri, String realHostName, String contextPath, int pageoffset) throws OpenRDFException
    {
        renderHtml(servletContext, nextRepository, nextWriter, null, debugStrings, queryString, resolvedUri, realHostName, contextPath, pageoffset);
    }
    
    public static void renderHtml(ServletContext servletContext, Repository nextRepository, java.io.Writer nextWriter, RdfFetchController fetchController, Collection<String> debugStrings, String queryString, String resolvedUri, String realHostName, String contextPath, int pageoffset) throws OpenRDFException
    {
        boolean nextpagelinkuseful = false;
        boolean previouspagelinkuseful = false;
        int previouspageoffset = pageoffset - 1;
        // String discoLink = "http://www4.wiwiss.fu-berlin.de/rdf_browser/?browse_uri=" + Utilities.percentEncode(resolvedUri);
        // String tabulatorLink = "http://dig.csail.mit.edu/2005/ajar/ajaw/tab.html?uri=" + Utilities.percentEncode(resolvedUri);
        // String openLinkLink = "http://demo.openlinksw.com/rdfbrowser/?uri=" + Utilities.percentEncode(resolvedUri);
        
        if(fetchController != null)
        {
            for(RdfFetcherQueryRunnable nextResult : fetchController.getResults())
            {
                debugStrings.add("<!-- "+Utilities.xmlEncodeString(nextResult.resultDebugString).replace("--","- -") + "-->");
            }
        }
        
        if(contextPath == null || contextPath.equals("/"))
        {
            contextPath = "";
        }
        else if(contextPath.startsWith("/") && contextPath.length() > 1 )
        {
            // take off the first slash and add one to the end for our purposes
            contextPath = contextPath.substring(1)+"/";
        }
        
        if(Settings.getBooleanPropertyFromConfig("useHardcodedRequestContext"))
        {
            contextPath = Settings.getStringPropertyFromConfig("hardcodedRequestContext");
        }
        
        if(Settings.getBooleanPropertyFromConfig("useHardcodedRequestHostname"))
        {
            realHostName = Settings.getStringPropertyFromConfig("hardcodedRequestHostname");
        }
        
        if(_TRACE)
        {
            log.trace("HtmlPageRenderer.renderHtml: about to create VelocityHelper class");
        }
        
        
        
        VelocityHelper template = new VelocityHelper(servletContext);
        
        
        if(_TRACE)
        {
            log.trace("HtmlPageRenderer.renderHtml: finished creating VelocityHelper class");
        }
        
        Context context = template.getVelocityContext();
        
        context.put("debug_level_info", GeneralServlet._INFO);
        context.put("debug_level_debug", GeneralServlet._DEBUG);
        context.put("debug_level_trace", GeneralServlet._TRACE);
        
        
        context.put("project_name", Settings.getStringPropertyFromConfig("projectName"));
        context.put("project_base_url", Settings.getStringPropertyFromConfig("projectHomeUrl"));
        context.put("project_html_url_prefix", Settings.getStringPropertyFromConfig("htmlUrlPrefix"));
        context.put("project_html_url_suffix", Settings.getStringPropertyFromConfig("htmlUrlSuffix"));
        context.put("project_link", Settings.getStringPropertyFromConfig("projectHomeUrl"));
        context.put("application_name", Settings.getStringPropertyFromConfig("userAgent")+ "/"+Settings.VERSION);
        context.put("application_help", Settings.getStringPropertyFromConfig("applicationHelpUrl"));
        context.put("uri", resolvedUri);
        
        boolean is_plainnsid = false;
        
        if(queryString != null)
        {
            context.put("query_string", queryString);
            
            if(Utilities.isPlainNamespaceAndIdentifier(queryString))
            {
                is_plainnsid = true;
                
                List<String> namespaceAndIdentifier = Utilities.getNamespaceAndIdentifier(queryString);
                
                if(namespaceAndIdentifier.size() == 2)
                {
                    context.put("namespace", namespaceAndIdentifier.get(0));
                    context.put("identifier", namespaceAndIdentifier.get(1));
                }
                else
                {
                    log.warn("Namespace and identifier did not have exactly two components: namesapceAndIdentifier.size()="+namespaceAndIdentifier.size());
                }
            }
        }
        
        context.put("is_plainnsid", is_plainnsid);
        context.put("real_hostname", realHostName);
        context.put("context_path", contextPath);
        context.put("server_base", realHostName+contextPath);
        context.put("rdfxml_link", realHostName+contextPath+Settings.getStringPropertyFromConfig("rdfXmlUrlPrefix")+queryString+Settings.getStringPropertyFromConfig("rdfXmlUrlSuffix"));
        context.put("rdfn3_link", realHostName+contextPath+Settings.getStringPropertyFromConfig("n3UrlPrefix")+queryString+Settings.getStringPropertyFromConfig("n3UrlSuffix"));
        context.put("html_link", realHostName+contextPath+Settings.getStringPropertyFromConfig("htmlUrlPrefix")+queryString+Settings.getStringPropertyFromConfig("htmlUrlSuffix"));
        // context.put("disco_link", discoLink);
        // context.put("tabulator_link", tabulatorLink);
        // context.put("openlink_link", openLinkLink);
        Collection<String> endpointsList = new HashSet<String>();
        
        if(fetchController != null)
        {
            for(QueryBundle nextQueryBundle : fetchController.getQueryBundles())
            {
                if(!endpointsList.contains(nextQueryBundle.queryEndpoint))
                {
                    endpointsList.add(nextQueryBundle.queryEndpoint);
                }
            }
        }
        
        context.put("provider_endpoints", endpointsList);
        
        if(fetchController != null)
            context.put("query_bundles", fetchController.getQueryBundles());
        
        //Collection<Value> titles = new HashSet<Value>();
        //Collection<Value> comments = new HashSet<Value>();
        //Collection<Value> images = new HashSet<Value>();
        Collection<Value> titles = Utilities.getValuesFromRepositoryByPredicateUris(nextRepository, Settings.getURICollectionPropertiesFromConfig("titleProperties"));
        Collection<Value> comments = Utilities.getValuesFromRepositoryByPredicateUris(nextRepository, Settings.getURICollectionPropertiesFromConfig("commentProperties"));
        Collection<Value> images = Utilities.getValuesFromRepositoryByPredicateUris(nextRepository, Settings.getURICollectionPropertiesFromConfig("imageProperties"));
        
        String chosenTitle = "";
        
        while(chosenTitle.trim().equals("") && titles.size() > 0)
        {
            chosenTitle = Utilities.getUTF8StringValueFromSesameValue(Utilities.chooseRandomItemFromCollection(titles));
            
            if(chosenTitle.trim().equals(""))
            {
                titles.remove(chosenTitle);
            }
        }
        
        if(chosenTitle.trim().equals(""))
        {
            context.put("title", Settings.getStringPropertyFromConfig("blankTitle"));
        }
        else
        {
            context.put("title", chosenTitle);
        }
        
        context.put("titles", titles);
        context.put("comments", comments);
        context.put("images", images);
        
        // For each URI in Settings.IMAGE_QUERY_TYPES
        // Make sure the URI is a valid QueryType
        // If there are any matches, replace the input_NN's with the namespace and identifier known here and then show a link to the image in HTML
        //Collection<Provider> providersForThisNamespace = Settings.getProvidersForQueryTypeForNamespaceUris(String customService, Collection<Collection<String>> namespaceUris, NamespaceEntry.)
        
        List<Statement> allStatements = Utilities.getAllStatementsFromRepository(nextRepository);
        
        // TODO: go through the statements and check an internal label cache to see if there is an existing label available 
        // and if not schedule a thread to retrieve a label for the item so that for other uses it can be shown
        
        log.info("HtmlPageRenderer: allStatements.size()="+allStatements.size());
        
        // TODO: what should be shown if there are no RDF statements? A 404 error doesn't seem appropriate because the query might be quite legitimate and no triples is the valid response
        
        context.put("statements", allStatements);
        
        context.put("xmlutil", new info.aduna.xml.XMLUtil());
        context.put("bio2rdfutil", new org.queryall.helpers.Utilities());
        
        // our only way of guessing if other pages are available without doing an explicit count
        if(allStatements.size() >= Settings.getIntPropertyFromConfig("pageoffsetIndividualQueryLimit"))
        {
            nextpagelinkuseful = true;
        }
        
        if(pageoffset > 1)
        {
            previouspagelinkuseful = true;
        }
        else if(pageoffset < 1)
        {
            // pageoffset less than one does not need a nextpagelinkuseful as it is useful as a marker to avoid this function
            pageoffset = 1;
            previouspageoffset = 1;
            
            previouspagelinkuseful = false;
            nextpagelinkuseful = false;
        }
        
        // To prevent infinite or extended requests, we have a maximum value that we can go up to
        if(pageoffset > Settings.getIntPropertyFromConfig("pageoffsetMaxValue"))
        {
            // setup the pageoffset value so it artificially points to the limit so that non-conforming robots that don't follow robots.txt don't accidentally run into issues when people play around with links to very high page offsets
            previouspageoffset = Settings.getIntPropertyFromConfig("pageoffsetMaxValue");
            nextpagelinkuseful = false;
        }
        
        // If configured to only show pageoffset for plain nsid's as opposed to the other queries then decide here whether to show it
        if(Settings.getBooleanPropertyFromConfig("pageoffsetOnlyShowForNsId") && !is_plainnsid)
        {
            nextpagelinkuseful = false;
        }
        
        if(nextpagelinkuseful)
        {
            context.put("nextpagelink", realHostName
                +contextPath
                +Settings.getStringPropertyFromConfig("htmlUrlPrefix")
                +Settings.getStringPropertyFromConfig("pageoffsetUrlOpeningPrefix")
                +(pageoffset+1)
                +Settings.getStringPropertyFromConfig("pageoffsetUrlClosingPrefix")
                +queryString
                +Settings.getStringPropertyFromConfig("pageoffsetUrlSuffix")
                +Settings.getStringPropertyFromConfig("htmlUrlSuffix"));
            context.put("nextpagelabel", (pageoffset+1));
        }
        
        if(previouspagelinkuseful)
        {
            context.put("previouspagelink", realHostName
                +contextPath
                +Settings.getStringPropertyFromConfig("htmlUrlPrefix")
                +Settings.getStringPropertyFromConfig("pageoffsetUrlOpeningPrefix")
                +(previouspageoffset)
                +Settings.getStringPropertyFromConfig("pageoffsetUrlClosingPrefix")
                +queryString
                +Settings.getStringPropertyFromConfig("pageoffsetUrlSuffix")
                +Settings.getStringPropertyFromConfig("htmlUrlSuffix"));
            context.put("previouspagelabel", previouspageoffset);
        }
        
        context.put("debugStrings", debugStrings);
        
        context.put("xmlEncoded_testString", "<test&amp;\"\'&>");
        
        //http://velocity.apache.org/engine/devel/webapps.html
        // Any user-entered text that contains special HTML or XML entities (such as <, >, or &) needs to be escaped before included in the web page. This is required, both to ensure the text is visible, and also to prevent dangerous cross-site scripting . Unlike, for example, JSTL (the Java Standard Tag Language found in Java Server Pages), Velocity does not escape references by default.
        //
        // However, Velocity provides the ability to specify a ReferenceInsertionEventHandler which will alter the value of a reference before it is inserted into the page. Specifically, you can configure the EscapeHtmlReference handler into your velocity.properties file to escape all references (optionally) matching a regular expression. The following example will escape HTML entities in any reference that starts with "msg" (e.g. $msgText).
        //
        // eventhandler.referenceinsertion.class = org.apache.velocity.app.event.implement.EscapeHtmlReference
        // eventhandler.escape.html.match = /msg.*/
        //
        // Note that other kinds of escaping are sometimes required. For example, in style sheets the @ character needs to be escaped, and in Javascript strings the single apostrophe ' needs to be escaped.
        
        if(_TRACE)
        {
            log.trace("HtmlPageRenderer.renderHtml: about to render XHTML to nextWriter="+nextWriter);
        }
        
        try
        {
            if(fetchController != null && !fetchController.queryKnown())
            {
                template.renderXHTML("error.vm", nextWriter);
            }
            else
            {
                template.renderXHTML("page.vm", nextWriter);
            }
        }
        catch(Exception ex)
        {
            log.fatal("HtmlPageRenderer.renderHtml: caught exception while rendering XHTML",ex);
        }
        
        if(_TRACE)
        {
            log.trace("HtmlPageRenderer.renderHtml: finished rendering XHTML");
        }
    }
}
