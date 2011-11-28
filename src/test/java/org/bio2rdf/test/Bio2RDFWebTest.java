package org.bio2rdf.test;
/**
 * 
 */


import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;
import org.queryall.query.Settings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Peter Ansell p_ansell@yahoo.com
 */
public class Bio2RDFWebTest extends AbstractQueryAllWebTest
{
    private static final Logger LOGGER = LoggerFactory.getLogger(Bio2RDFWebTest.class);

    /**
     * Tests that the /admin/profiles page was generated using the correct headers and that it wasn't interrupted
     */
    @Test
    public void testAdminProfiles()
    {
        this.getWebTester().gotoPage("/admin/profiles");
        
        this.getWebTester().assertTextPresent("Number of queries =");
        this.getWebTester().assertTextPresent("Number of providers =");
        this.getWebTester().assertTextPresent("Number of rdf normalisation rules =");
        this.getWebTester().assertTextPresent("Number of profiles =");
        
        this.getWebTester().assertTextPresent("The following list is authoritative across all of the currently enabled profiles");
        
        this.getWebTester().assertTextPresent("Included providers: (");
        
        this.getWebTester().assertTextPresent("Excluded providers: (");
        
        this.getWebTester().assertTextPresent("Included queries: (");
        
        this.getWebTester().assertTextPresent("Excluded queries: (");
        
        this.getWebTester().assertTextPresent("Included rdfrules: (");
        
        this.getWebTester().assertTextPresent("Excluded rdfrules: (");
        
        this.getWebTester().assertTextPresent("The next section details the profile by profile details, and does not necessarily match the actual effect if there is more than one profile enabled");
    }

    /**
     * Tests that the /admin/configuration/CURRENT/n3 interface is working correctly
     */
    @Test
    public void testCurrentApiVersionAdminConfigurationN3()
    {
        this.getWebTester().gotoPage("/admin/configuration/"+Settings.CONFIG_API_VERSION+"/n3");
        
    }
    
    /**
     * Tests that the /admin/configuration/CURRENT/rdfxml interface is working correctly
     */
    @Test
    public void testCurrentApiVersionAdminConfigurationRdfXml()
    {
        this.getWebTester().gotoPage("/admin/configuration/"+Settings.CONFIG_API_VERSION+"/rdfxml");
    }

    /**
     * Tests that the /admin/configuration/CURRENT/json interface is working correctly
     */
    @Test
    public void testCurrentApiVersionAdminConfigurationJson()
    {
        this.getWebTester().gotoPage("/admin/configuration/"+Settings.CONFIG_API_VERSION+"/json");
    }

    /**
     * Tests that the /admin/configuration/CURRENT/html interface is working correctly
     * 
     * WARNING: The Bio2RDF configuration HTML page is so large that HTMLUnit cannot deal with it.
     * 
     * DO NOT REMOVE the Ignore annotation below without reason, as it will fail after a few minutes with OutOfMemoryError
     */
    @Ignore
    @Test
    public void testCurrentApiVersionAdminConfigurationHtml()
    {
        this.getWebTester().gotoPage("/admin/configuration/"+Settings.CONFIG_API_VERSION+"/html");
    }

    /**
     * Tests that the /admin/stats page was generated using the correct headers and that it wasn't interrupted
     */
    @Test
    public void testAdminStats()
    {
        this.getWebTester().gotoPage("/admin/stats");
        
        this.getWebTester().assertTextPresent("Current date : ");
        
        this.getWebTester().assertTextPresent("Server Version : ");
        
        this.getWebTester().assertTextPresent("Now : ");
        
        this.getWebTester().assertTextPresent("Last error reset date: ");
        this.getWebTester().assertTextPresent("Server startup date: ");
        this.getWebTester().assertTextPresent("Reset period ");
        
        this.getWebTester().assertTextPresent("Client blacklist will reset in ");
        
    }

    /**
     * Tests that the /admin/namespaceproviders page was generated using the correct headers and that it wasn't interrupted
     */
    @Test
    public void testAdminNamespaceProviders()
    {
        this.getWebTester().gotoPage("/admin/namespaceproviders");
        
        this.getWebTester().assertTextPresent("Number of namespaces that are known = ");
        this.getWebTester().assertTextPresent("Number of namespaces that have providers = ");
        this.getWebTester().assertTextPresent("Number of query titles = ");
        this.getWebTester().assertTextPresent("Number of providers = ");
        this.getWebTester().assertTextPresent("Number of rdf normalisation rules = ");
        this.getWebTester().assertTextPresent("Number of rdf normalisation rule tests = ");
        this.getWebTester().assertTextPresent("Number of profiles = ");
        this.getWebTester().assertTextPresent("Number of namespace provider options = ");
        this.getWebTester().assertTextPresent("Number of query title provider options = ");
        this.getWebTester().assertTextPresent("Number of query title and namespace combinations = ");
        this.getWebTester().assertTextPresent("Number of query title and namespace combination provider options = ");
        
        this.getWebTester().assertTextPresent("Raw complete namespace Collection");
        
        this.getWebTester().assertTextPresent("Queries for this namespace (");
        this.getWebTester().assertTextPresent("Namespaces for this query (");
        
        // Verify that there are no providers without namespaces or namespaces without providers
        this.getWebTester().assertTextNotPresent("NO Providers known for this namespace");
        this.getWebTester().assertTextNotPresent("Namespaces found on providers without definitions:");
    }

    
    /**
     * Tests that the /admin/test/rules page did not indicate any test failures
     */
    @Test
    public void testAdminTestRules()
    {
        this.getWebTester().gotoPage("/admin/test/rules");
        
        this.getWebTester().assertTextNotPresent("Test Failure occured");
    }
    
    @Override
    protected String getBaseUrl()
    {
        return "http://localhost:9090/bio2rdf-test/";
    }

    @Override
    protected String getBeginAtPath()
    {
        return "/";
    }
    
}
