package org.bio2rdf.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.bio2rdf.servlets.html.*;
import org.queryall.queryutils.*;
import org.queryall.statistics.*;
import org.queryall.helpers.*;
import org.queryall.impl.*;


import org.openrdf.*;
import org.openrdf.rio.*;
import org.openrdf.repository.*;
import org.openrdf.repository.sail.*;
import org.openrdf.sail.memory.*;

import org.apache.log4j.Logger;

/** 
 * 
 */

public class QueryAllSchemaServlet extends HttpServlet 
{
    /**
	 * 
	 */
	private static final long serialVersionUID = -4486511923930733168L;
	public static final Logger log = Logger.getLogger(QueryAllSchemaServlet.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();

    
  @Override
  public void doGet(HttpServletRequest request,
                    HttpServletResponse response)
      throws ServletException, IOException 
  {
	    Settings localSettings = Settings.getSettings();

	    // localSettings.setServletContext(getServletConfig().getServletContext());
        
        // DefaultQueryOptions requestQueryOptions = new DefaultQueryOptions(request.getRequestURI());
        
        PrintWriter out = response.getWriter();

        // String propertiesSubversionId = localSettings.SUBVERSION_INFO;
        
        String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 && request.getScheme().equals("http") ? "" : ":"+ request.getServerPort())+"/";
        
        String originalRequestedContentType = QueryallContentNegotiator.getResponseContentType(request.getHeader("Accept"), request.getHeader("User-Agent"));
        
        String requestedContentType = originalRequestedContentType;

        String queryString = (String)request.getAttribute("org.queryall.RuleTesterServlet.queryString");
        
        if(queryString == null)
        {
            queryString = "";
        }
        
        String locale = request.getLocale().toString();
        
        String characterEncoding = request.getCharacterEncoding();
        
        if(_INFO)
        {
            log.info("QueryAllSchemaServlet: locale="+locale+" characterEncoding="+characterEncoding);
        }
        
        String versionParameter = (String)request.getAttribute("org.queryall.RuleTesterServlet.apiVersion");
        
		int apiVersion = Settings.CONFIG_API_VERSION;
        
        if(versionParameter != null && !versionParameter.equals("") && !Constants.CURRENT.equals(versionParameter))
        {
            try
            {
                apiVersion = Integer.parseInt(versionParameter);
            }
            catch(NumberFormatException nfe)
            {
                log.error("QueryAllSchemaServlet: apiVersion not recognised versionParameter="+versionParameter);
            }
        }
        
        if(apiVersion > Settings.CONFIG_API_VERSION)
        {
            log.error("QueryAllSchemaServlet: requested API version not supported by this server. apiVersion="+apiVersion+" Settings.CONFIG_API_VERSION="+Settings.CONFIG_API_VERSION);
            
            response.setContentType("text/plain");
            response.setStatus(400);
            out.write("Requested API version not supported by this server. Current supported version="+Settings.CONFIG_API_VERSION);
            return;
        }
        
        Collection<String> debugStrings = new HashSet<String>();
        
        String explicitUrlContentType = (String)request.getAttribute("org.queryall.QueryAllSchemaServlet.chosenContentType");
        
        if(explicitUrlContentType != null && !explicitUrlContentType.equals(""))
        {
            if(log.isInfoEnabled())
            {
                log.info("QueryAllSchemaServlet: explicitUrlContentType="+explicitUrlContentType);
            }
            
            // override whatever was requested with the urlrewrite variable
            requestedContentType = explicitUrlContentType;
        }
        
        // even if they request a random format, we need to make sure that Rio has a writer compatible with it, otherwise we revert to one of the defaults as a failsafe mechanism
        RDFFormat writerFormat = Rio.getWriterFormatForMIMEType(requestedContentType);
        
        if(writerFormat == null)
        {
            writerFormat = Rio.getWriterFormatForMIMEType(localSettings.getStringPropertyFromConfig("preferredDisplayContentType", Constants.APPLICATION_RDF_XML));
            
            if(writerFormat == null)
            {
                writerFormat = RDFFormat.RDFXML;
                
                if(!requestedContentType.equals(Constants.TEXT_HTML))
                {
                    requestedContentType = Constants.APPLICATION_RDF_XML;
                    
                    log.error("QueryAllSchemaServlet: content negotiation failed to find a suitable content type for results. Defaulting to hard coded RDF/XML writer. Please set localSettings.getStringPropertyFromConfig(\"preferredDisplayContentType\") to a MIME type which is understood by the RDF package being used by the servlet to ensure this message doesn't appear.");
                }
            }
            else if(!requestedContentType.equals(Constants.TEXT_HTML))
            {
                requestedContentType = localSettings.getStringPropertyFromConfig("preferredDisplayContentType", Constants.APPLICATION_RDF_XML);
                
                log.error("QueryAllSchemaServlet: content negotiation failed to find a suitable content type for results. Defaulting to localSettings.getStringPropertyFromConfig(\"preferredDisplayContentType\")="+localSettings.getStringPropertyFromConfig("preferredDisplayContentType", ""));
            }
        }
        
        if(log.isInfoEnabled())
        {
            log.info("QueryAllSchemaServlet: requestedContentType="+requestedContentType+ " acceptHeader="+request.getHeader("Accept")+" userAgent="+request.getHeader("User-Agent"));
        }
        
        if(!originalRequestedContentType.equals(requestedContentType))
        {
            log.warn("QueryAllSchemaServlet: originalRequestedContentType was overwritten originalRequestedContentType="+originalRequestedContentType+" requestedContentType="+requestedContentType);
        }
        
        localSettings.configRefreshCheck(false);
        
        response.setContentType(requestedContentType);
        response.setCharacterEncoding("UTF-8");
        
        // if(requestedContentType.equals("application/rdf+xml"))
        // {
            // out.write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
        // }
        // else if(requestedContentType.equals("text/html"))
        // {
            // out.write("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n");
        // }
        
        // Start sending output before we fetch the rdf so the client doesn't decide to timeout or re-request
        // version = RdfUtils.xmlEncodeString(version).replace("--","- -");
        // 
        // if(requestedContentType.equals("application/rdf+xml") || requestedContentType.equals("text/html"))
        // {
            // // always print the version number out for debugging
            // out.write("<!-- bio2rdf sourceforge package version ("+ version +") -->\n");
            // 
            // if(log.isInfoEnabled())
            // {
                // subversionId = RdfUtils.xmlEncodeString(subversionId).replace("--","- -");
                // out.write("<!-- bio2rdf sourceforge subversion copy Id ("+ subversionId +") -->\n");
                // propertiesSubversionId = RdfUtils.xmlEncodeString(propertiesSubversionId).replace("--","- -");
                // out.write("<!-- bio2rdf sourceforge properties file subversion copy Id ("+ propertiesSubversionId +") -->\n");
            // }
        // }
        // else if(requestedContentType.equals("text/rdf+n3"))
        // {
            // always print the version number out for debugging
            // out.write("# bio2rdf sourceforge package version ("+ version.replace("\n","").replace("\r","") +")\n");
            
            // if(log.isInfoEnabled())
            // {
                // out.write("# bio2rdf sourceforge subversion copy Id ("+ subversionId.replace("\n","").replace("\r","") +")\n");
                // 
                // out.write("# bio2rdf sourceforge properties file subversion copy Id ("+ propertiesSubversionId.replace("\n","").replace("\r","") +")\n");
            // }
        // }
        
        try
        {
            Repository myRepository = new SailRepository(new MemoryStore());
            myRepository.initialize();
            
            try
            {
                if(!ProviderImpl.schemaToRdf(myRepository, ProviderImpl.providerNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: Provider schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating Provider schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!ProjectImpl.schemaToRdf(myRepository, ProjectImpl.projectNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: Project schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating Project schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!QueryTypeImpl.schemaToRdf(myRepository, QueryTypeImpl.queryNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: QueryType schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating QueryType schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                // if(!NormalisationRule.schemaToRdf(myRepository, NormalisationRule.rdfruleNamespace, apiVersion))
                // {
                    // log.error("QueryAllSchemaServlet: NormalisationRule schema was not placed correctly in the rdf store");
                // }
                if(!RegexNormalisationRule.schemaToRdf(myRepository, NormalisationRuleImpl.rdfruleNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: RegexNormalisationRule schema was not placed correctly in the rdf store");
                }
                if(!SparqlNormalisationRule.schemaToRdf(myRepository, NormalisationRuleImpl.rdfruleNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: SparqlNormalisationRule schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating RegexNormalisationRule schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!RuleTestImpl.schemaToRdf(myRepository, RuleTestImpl.getRuletestNamespace(), apiVersion))
                {
                    log.error("QueryAllSchemaServlet: RuleTest schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating RuleTest schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!NamespaceEntryImpl.schemaToRdf(myRepository, NamespaceEntryImpl.namespaceNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: NamespaceEntry schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating NamespaceEntry schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!ProfileImpl.schemaToRdf(myRepository, ProfileImpl.profileNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: Profile schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating Profile schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!StatisticsEntry.schemaToRdf(myRepository, StatisticsEntry.statisticsNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: Statistics schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating Statistics schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!ProvenanceRecord.schemaToRdf(myRepository, ProvenanceRecord.provenanceNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: Provenance schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating Provenance schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            try
            {
                if(!QueryBundle.schemaToRdf(myRepository, QueryBundle.queryBundleNamespace, apiVersion))
                {
                    log.error("QueryAllSchemaServlet: QueryBundle schema was not placed correctly in the rdf store");
                }
            }
            catch(Exception ex)
            {
                log.error("QueryAllSchemaServlet: Problem generating QueryBundle schema RDF with type="+ex.getClass().getName());
                log.error(ex.getMessage());
            }
            
            // RepositoryConnection myRepositoryConnection = myRepository.getConnection();
            
            java.io.StringWriter stBuff = new java.io.StringWriter();
            
            if(requestedContentType.equals(Constants.TEXT_HTML))
            {
                // if(myRepositoryConnection != null)
                    // myRepositoryConnection.close();
                
                if(_DEBUG)
                {
                    log.debug("QueryAllSchemaServlet: about to call html rendering method");
                }
                
                try
                {
                    HtmlPageRenderer.renderHtml(
                        getServletContext(), myRepository, stBuff, debugStrings, 
                        localSettings.getOntologyTermUriPrefix() + queryString, 
                        localSettings.getOntologyTermUriPrefix() + queryString, 
                        realHostName, request.getContextPath(), -1);
                }
                catch(OpenRDFException ordfe)
                {
                    log.error("QueryAllSchemaServlet: couldn't render HTML because of an RDF exception", ordfe);
                }
                catch(Exception ex)
                {
                    log.error("QueryAllSchemaServlet: couldn't render HTML because of an unknown exception", ex);
                }
            }
            else
            {
                RdfUtils.toWriter(myRepository, stBuff, writerFormat);
            }
            
            String actualRdfString = stBuff.toString();
            
            if(_TRACE)
            {
                log.trace("QueryAllSchemaServlet: actualRdfString="+actualRdfString);
            }
            
            if(requestedContentType.equals(Constants.APPLICATION_RDF_XML))
            {
                out.write(actualRdfString);
                //out.write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
                // 
                // for(String nextDebugString : debugStrings)
                // {
                    // out.write(nextDebugString+"\n");
                // }
                // HACK: can't find a way to get sesame to print out the rdf without the xml PI
                //out.write(actualRdfString.replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", ""));
            }
            else if(requestedContentType.equals(Constants.TEXT_RDF_N3))
            {
                // for(String nextDebugString : debugStrings)
                // {
                    // out.write(nextDebugString+"\n");
                // }
                // 
                out.write(actualRdfString);
            }
            else
            {
                // log.error("entering UTF-8 conversion section");
                
                // try{
                    // byte[] bytes = new byte[actualRdfString.length()];
                    // for (int i = 0; i < actualRdfString.length(); i++) 
                    // {
                        // bytes[i] = (byte) actualRdfString.charAt(i);
                    // }
                    // 
                    // actualRdfString = new String(bytes, "UTF-8");
                // }
                // catch(java.io.UnsupportedEncodingException)
                // {
                    // log.error("QueryAllSchemaServlet: unsupported encoding exception for UTF-8");
                // }
                
                out.write(actualRdfString);
            }
    
            out.flush();
            
    
            
            // if(_DEBUG)
            // {
                // log.debug("QueryAllSchemaServlet: finished returning information to client requesterIpAddress="+requesterIpAddress+" queryString="+queryString + " pageOffset="+pageOffset+" totalTime="+nextTotalTime);
            // }    
        }
        catch(OpenRDFException ordfe)
        {
            if(out!= null)
            {
                out.flush();
            }
            
            log.fatal("QueryAllSchemaServlet.doGet: caught RDF exception", ordfe);
            throw new RuntimeException("QueryAllSchemaServlet.doGet failed due to an RDF exception. See log for details");
        }
        // catch(InterruptedException iex)
        // {
            // log.error("QueryAllSchemaServlet.doGet: caught interrupted exception", iex);
    // 
            // if(out!= null)
            // {
                // out.flush();
            // }
            // 
            // throw new RuntimeException("QueryAllSchemaServlet.doGet failed due to an exception. See log for details");
        // }
        catch(RuntimeException rex)
        {
            if(out!= null)
            {
                out.flush();
            }
            
            log.error("QueryAllSchemaServlet.doGet: caught runtime exception", rex);
        }
    }
}

