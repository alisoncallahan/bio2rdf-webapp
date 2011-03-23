package org.bio2rdf.servlets;

import de.fuberlin.wiwiss.pubby.negotiation.ContentTypeNegotiator;
import de.fuberlin.wiwiss.pubby.negotiation.MediaRangeSpec;

import org.apache.log4j.Logger;

import org.queryall.helpers.*;


public class QueryallContentNegotiator
{
    public static final Logger log = Logger.getLogger(QueryallContentNegotiator.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    @SuppressWarnings("unused")
    public static final boolean _INFO = log.isInfoEnabled();
    
    private static ContentTypeNegotiator contentNegotiator = null;
    
    public static ContentTypeNegotiator getContentNegotiator()
    {
        if(contentNegotiator != null)
            return contentNegotiator;
        
        contentNegotiator = new ContentTypeNegotiator();
        
        if(Settings.getSettings().getStringPropertyFromConfig("preferredDisplayContentType", Constants.TEXT_HTML).equals(Constants.APPLICATION_RDF_XML))
        {
            contentNegotiator.addVariant("application/rdf+xml;q=0.99");
            // Avoid putting application/xml into this mix, as it prevents common browsers from ever seeing text/html
            //.addAliasMediaType("application/xml;q=0.4")
            //    .addAliasMediaType("text/xml;q=0.4");
        }
        else
        {
            contentNegotiator.addVariant("application/rdf+xml;q=0.95");
            // Avoid putting application/xml into this mix, as it prevents common browsers from ever seeing text/html
            //.addAliasMediaType("application/xml;q=0.4")
            //    .addAliasMediaType("text/xml;q=0.4");
        }
        
        if(Settings.getSettings().getStringPropertyFromConfig("preferredDisplayContentType", Constants.TEXT_HTML).equals(Constants.TEXT_RDF_N3))
        {
            contentNegotiator.addVariant("text/rdf+n3;q=0.99")
            .addAliasMediaType("text/n3;q=0.5")
            .addAliasMediaType("application/rdf+n3;q=0.5")
            .addAliasMediaType("application/n3;q=0.5");
        }
        else
        {
            contentNegotiator.addVariant("text/rdf+n3;q=0.90")
            .addAliasMediaType("text/n3;q=0.5")
            .addAliasMediaType("application/rdf+n3;q=0.5")
            .addAliasMediaType("application/n3;q=0.5");
        }
        
        if(Settings.getSettings().getStringPropertyFromConfig("preferredDisplayContentType", Constants.TEXT_HTML).equals(Constants.TEXT_TURTLE))
        {
            // See http://www.w3.org/TeamSubmission/turtle/ for reasoning here
            contentNegotiator.addVariant("text/turtle;q=0.99")
            .addAliasMediaType("application/turtle;q=0.8")
            .addAliasMediaType("application/x-turtle;q=0.5");
        }
        else
        {
            // See http://www.w3.org/TeamSubmission/turtle/ for reasoning here
            contentNegotiator.addVariant("text/turtle;q=0.90")
            .addAliasMediaType("application/turtle;q=0.8")
            .addAliasMediaType("application/x-turtle;q=0.5");
        }
        
        if(Settings.getSettings().getStringPropertyFromConfig("preferredDisplayContentType", Constants.TEXT_HTML).equals(Constants.TEXT_HTML))
        {
            contentNegotiator.addVariant("text/html;q=0.99")
            .addAliasMediaType("application/html;q=0.8")
            .addAliasMediaType("application/xhtml+xml;q=0.8");
        }
        else
        {
            contentNegotiator.addVariant("text/html;q=0.45")
            .addAliasMediaType("application/html;q=0.3")
            .addAliasMediaType("application/xhtml+xml;q=0.3");
        }
        
        
        contentNegotiator.addVariant("text/plain;q=0.2");

        return QueryallContentNegotiator.contentNegotiator;
    }
    
    public static String getResponseContentType(String acceptHeader, String userAgent)
    {
        if(_DEBUG)
        {
            log.debug("QueryallContentNegotiator: acceptHeader="+acceptHeader+" userAgent="+userAgent);
        }
        
        ContentTypeNegotiator negotiator = QueryallContentNegotiator.getContentNegotiator();
        MediaRangeSpec bestMatch = negotiator.getBestMatch(acceptHeader, userAgent);
        
        if (bestMatch == null)
        {
            if(_TRACE)
            {
                log.trace("QueryallContentNegotiator: bestMatch not found, returning Settings:preferredDisplayContentType instead");
            }
            
            return Settings.getSettings().getStringPropertyFromConfig("preferredDisplayContentType", Constants.APPLICATION_RDF_XML);
        }
        
        return bestMatch.getMediaType();
    }
}
