package org.bio2rdf.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.queryall.*;
import org.bio2rdf.servlets.queryparsers.*;
import org.bio2rdf.servlets.html.*;
import org.queryall.helpers.*;
import org.queryall.blacklist.*;

import org.openrdf.*;
import org.openrdf.model.*;
import org.openrdf.rio.*;
import org.openrdf.repository.*;
import org.openrdf.repository.sail.*;
import org.openrdf.sail.memory.*;


import org.apache.log4j.Logger;

/** 
 * 
 */

public class ConfigurationServlet extends HttpServlet 
{
    public static final Logger log = Logger.getLogger(ConfigurationServlet.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();

    
    @Override
    public void doGet(HttpServletRequest request,
                        HttpServletResponse response)
        throws ServletException, IOException 
    {
        // Settings.setServletContext(getServletConfig().getServletContext());
        
        log.debug("request.getRequestURI()="+request.getRequestURI());
        
        ConfigurationQueryOptions requestConfigurationQueryOptions = new ConfigurationQueryOptions(request.getRequestURI());
        
        PrintWriter out = response.getWriter();
        java.io.StringWriter stBuff = new java.io.StringWriter();
        
        String originalRequestedContentType = QueryallContentNegotiator.getResponseContentType(request.getHeader("Accept"), request.getHeader("User-Agent"));
        
        String requestedContentType = originalRequestedContentType;
        
        String explicitUrlContentType = "";

        if(requestConfigurationQueryOptions.isRefresh())
        {
            if(Settings.isManualRefreshAllowed())
            {
                if(Settings.configRefreshCheck(true))
                {
                    BlacklistController.doBlacklistExpiry();
                    
                    response.setStatus(HttpServletResponse.SC_OK);
                    log.info("manualrefresh.jsp: manual refresh succeeded requesterIpAddress="+request.getRemoteAddr());
                    out.write("Refresh succeeded.");
                }
                else
                {
                    response.setStatus(500);
                    log.error("manualrefresh.jsp: refresh failed for an unknown reason, as it was supposedly allowed in a previous check requesterIpAddress="+request.getRemoteAddr());
                    out.write("Refresh failed for an unknown reason");
                }
            }
            else
            {
                response.setStatus(401);
                log.error("manualrefresh.jsp: refresh not allowed right now requesterIpAddress="+request.getRemoteAddr()+ " Settings.MANUAL_CONFIGURATION_REFRESH_ALLOWED="+Settings.getStringPropertyFromConfig("enableManualConfigurationRefresh"));
                out.write("Refresh not allowed right now.");
            }
            
            out.flush();
            return;
        }
        
        if(requestConfigurationQueryOptions.containsExplicitFormat())
        {
            explicitUrlContentType = requestConfigurationQueryOptions.getExplicitFormat();
            // override whatever was requested with the urlrewrite variable
            requestedContentType = explicitUrlContentType;
        }
        
        String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 && request.getScheme().equals("http") ? "" : ":"+ request.getServerPort())+"/";
        
        String serverName = request.getServerName();
        
        String queryString = requestConfigurationQueryOptions.getParsedRequest();
        
        if(queryString == null)
        {
            queryString = "";
        }
        
        int apiVersion = requestConfigurationQueryOptions.getApiVersion();
        
        if(apiVersion > Settings.CONFIG_API_VERSION)
        {
            log.error("ConfigurationServlet: requested API version not supported by this server. apiVersion="+apiVersion+" Settings.CONFIG_API_VERSION="+Settings.CONFIG_API_VERSION);
            
            response.setContentType("text/plain");
            response.setStatus(400);
            out.write("Requested API version not supported by this server. Current supported version="+Settings.CONFIG_API_VERSION);
            out.flush();
            return;
        }
        
        Collection<String> debugStrings = new HashSet<String>();
        
        String writerFormatString = Utilities.findWriterFormat(requestedContentType, Settings.getStringPropertyFromConfig("preferredDisplayContentType"), "application/rdf+xml");
        
        RDFFormat writerFormat = null;
        
        if(!writerFormatString.equals("text/html"))
        {
            writerFormat = Rio.getWriterFormatForMIMEType(writerFormatString);
        }

        if(log.isDebugEnabled())
        {
            log.debug("ConfigurationServlet: requestedContentType="+requestedContentType+ " acceptHeader="+request.getHeader("Accept")+" userAgent="+request.getHeader("User-Agent"));
        }
        
        Settings.configRefreshCheck(false);
        
        response.setContentType(requestedContentType);
        response.setCharacterEncoding("UTF-8");
        
        boolean targetOnlyQueryString = false;
        
        final String queryStringURI = Settings.getDefaultHostAddress()+queryString;
        
        if(Utilities.isPlainNamespaceAndIdentifier(queryString))
        {
            targetOnlyQueryString = true;
        }
        
        
        Repository myRepository = new SailRepository(new MemoryStore());

        RepositoryConnection myRepositoryConnection = null;
        
        try
        {
            myRepository.initialize();
            
            ValueFactory f = myRepository.getValueFactory();
            
            if(requestConfigurationQueryOptions.containsAdminConfiguration())
            {
                Map<URI, Provider> allProviders = Settings.getAllProviders();
                
                for(URI nextProviderKey : allProviders.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextProviderKey.stringValue()))
                    {
                        try
                        {
                            if(!allProviders.get(nextProviderKey).toRdf(myRepository, nextProviderKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Provider was not placed correctly in the rdf store key="+nextProviderKey);
                                // out.write("<!-- "+Utilities.xmlEncodeString(allProviders.get(nextProviderKey).toString()).replace("--","- -")+" -->");
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Provider RDF with key: "+nextProviderKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                            // out.write("Problem generating Provider RDF with key: "+nextProviderKey+"<br />\n");
                            // out.write(Utilities.xmlEncodeString(allProviders.get(nextProviderKey).toString()));
                        }
                    }
                }
                
                Map<URI, QueryType> allQueries = Settings.getAllCustomQueries();
                
                for(URI nextQueryKey : allQueries.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextQueryKey.stringValue()))
                    {
                        try
                        {
                            if(!allQueries.get(nextQueryKey).toRdf(myRepository, nextQueryKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Custom Query was not placed correctly in the rdf store key="+nextQueryKey);
                                // out.write(Utilities.xmlEncodeString(allQueries.get(nextQueryKey).toString()));
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Query RDF with key: "+nextQueryKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                            // out.write("Problem generating Query RDF with key: "+nextQueryKey+"<br />\n");
                            // out.write(Utilities.xmlEncodeString(allQueries.get(nextQueryKey).toString()));
                        }
                    }
                }
                
                Map<URI, Template> allTemplates = Settings.getAllTemplates();
                
                for(URI nextTemplateKey : allTemplates.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextTemplateKey.stringValue()))
                    {
                        try
                        {
                            if(!allTemplates.get(nextTemplateKey).toRdf(myRepository, nextTemplateKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Template was not placed correctly in the rdf store key="+nextTemplateKey);
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Template RDF with key: "+nextTemplateKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                        }
                    }
                }
                
                Map<URI, NormalisationRule> allNormalisationRules = Settings.getAllNormalisationRules();
                
                for(URI nextNormalisationRuleKey : allNormalisationRules.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextNormalisationRuleKey.stringValue()))
                    {
                        try
                        {
                            if(!allNormalisationRules.get(nextNormalisationRuleKey).toRdf(myRepository, nextNormalisationRuleKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Rdf Normalisation Rule was not placed correctly in the rdf store key="+nextNormalisationRuleKey);
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Rdf Rule RDF with key: "+nextNormalisationRuleKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                            // out.write("Problem generating Rdf Rule RDF with key: "+nextNormalisationRuleKey+"<br />\n");
                            // out.write(Utilities.xmlEncodeString(allNormalisationRules.get(nextNormalisationRuleKey).toString()));
                        }
                    }
                }
                
                Map<URI, RuleTest> allRuleTests = Settings.getAllRuleTests();
                
                for(URI nextRuleTestKey : allRuleTests.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextRuleTestKey.stringValue()))
                    {
                        try
                        {
                            if(!allRuleTests.get(nextRuleTestKey).toRdf(myRepository, nextRuleTestKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Rule Test was not placed correctly in the rdf store key="+nextRuleTestKey);
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Rule Test RDF with key: "+nextRuleTestKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                        }
                    }
                }
                
                Map<URI, NamespaceEntry> allNamespaceEntries = Settings.getAllNamespaceEntries();
                
                for(URI nextNamespaceEntryKey : allNamespaceEntries.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextNamespaceEntryKey.stringValue()))
                    {
                        try
                        {
                            if(!allNamespaceEntries.get(nextNamespaceEntryKey).toRdf(myRepository, nextNamespaceEntryKey, apiVersion))
                            {
                                log.error("ConfigurationServlet: Namespace Entry was not placed correctly in the rdf store key="+nextNamespaceEntryKey);
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating RDF with namespace: "+nextNamespaceEntryKey);
                            log.error(ex.getMessage());
                        }
                    }
                }
                
                Map<URI, Profile> allProfiles = Settings.getAllProfiles();
                
                for(URI nextProfileKey : allProfiles.keySet())
                {
                    if(!targetOnlyQueryString || queryStringURI.equals(nextProfileKey.stringValue()))
                    {
                        try
                        {
                            // log.info("Debug-configuration: nextProfileKey="+nextProfileKey);
                            
                            if(!allProfiles.get(nextProfileKey).toRdf(myRepository, allProfiles.get(nextProfileKey).getKey(), apiVersion))
                            {
                                log.error("ConfigurationServlet: Profile was not placed correctly in the rdf store key="+nextProfileKey);
                                // out.write(Utilities.xmlEncodeString(allNormalisationRules.get(nextNormalisationRuleKey).toString()));
                            }
                        }
                        catch(Exception ex)
                        {
                            log.error("ConfigurationServlet: Problem generating Profile RDF with key: "+nextProfileKey+" type="+ex.getClass().getName());
                            log.error(ex.getMessage());
                            // out.write("Problem generating Rdf Rule RDF with key: "+nextNormalisationRuleKey+"<br />\n");
                            // out.write(Utilities.xmlEncodeString(allNormalisationRules.get(nextNormalisationRuleKey).toString()));
                        }
                    }
                }
            }
            else if(requestConfigurationQueryOptions.containsAdminBasicWebappConfiguration())
            {
                myRepositoryConnection = myRepository.getConnection();

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("userAgent"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("projectHomeUri"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("uriPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("hostName"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("uriSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("separator"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("rdfXmlUrlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("rdfXmlUrlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("n3UrlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("n3UrlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("htmlUrlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("htmlUrlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("queryplanUrlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("queryplanUrlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetUrlOpeningPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetUrlClosingPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetUrlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminUrlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminWebappConfigurationPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationRefreshPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationApiVersionOpeningPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationApiVersionClosingPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationApiVersionSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationHtmlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationHtmlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationRdfxmlPrefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationRdfxmlSuffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationN3Prefix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("adminConfigurationN3Suffix"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetOnlyShowForNsId"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("plainNamespaceAndIdentifierRegex"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("plainNamespaceRegex"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("tagPatternRegex"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("blankTitle"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("projectHomeUrl"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("projectName"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("applicationHelpUrl"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("blacklistContactEmailAddress"));
                
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("blacklistRedirectPage"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("autogenerateIncludeStubList"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("titleProperties"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("imageProperties"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("commentProperties"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("urlProperties"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("unknownQueryStaticAdditions"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("unknownQueryHttpResponseCode"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("unknownNamespaceStaticAdditions"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("unknownNamespaceHttpResponseCode"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("useAllEndpointsForEachProvider"));

                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetMaxValue"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("pageoffsetIndividualQueryLimit"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("preferredDisplayContentType"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("preferredDisplayLanguage"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("assumedRequestContentType"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("defaultAcceptHeader"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("useRequestCache"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("convertAlternateNamespacePrefixesToPreferred"));
                myRepositoryConnection.add(Settings.getStatementPropertiesFromConfig("useVirtuosoMaxRowsParameter"));
            }
            
            if(myRepositoryConnection != null)
            {
                myRepositoryConnection.close();
            }
            
            if(requestedContentType.equals("text/html"))
            {
                if(_DEBUG)
                {
                    log.debug("Atlas2Rdf.jsp: about to call html rendering method");
                }
                
                try
                {
                    HtmlPageRenderer.renderHtml(getServletContext(), myRepository, stBuff, debugStrings, queryString, Settings.getDefaultHostAddress() + queryString, realHostName, request.getContextPath(), -1);
                }
                catch(OpenRDFException ordfe)
                {
                    log.error("Atlas2Rdf.jsp: couldn't render HTML because of an RDF exception", ordfe);
                }
                catch(Exception ex)
                {
                    log.error("Atlas2Rdf.jsp: couldn't render HTML because of an unknown exception", ex);
                }
            }
            else
            {
                Utilities.toWriter(myRepository, stBuff, writerFormat);
            }
        
        }
        catch(OpenRDFException ordfe)
        {
            log.error("ConfigurationServlet: error", ordfe);
        }
        
        out.write(stBuff.toString());
        
        out.flush();
    }
}

