package org.queryall.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.queryall.*;
import org.queryall.queryutils.*;
import org.queryall.helpers.*;
import org.queryall.blacklist.*;

import org.apache.log4j.Logger;

import org.openrdf.model.URI;

/** 
 * 
 */

public class ServerStatsServlet extends HttpServlet 
{
    public static final Logger log = Logger.getLogger(ServerStatsServlet.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();

    
    @Override
    public void doGet(HttpServletRequest request,
                        HttpServletResponse response)
        throws ServletException, IOException 
    {
        // Settings.setServletContext(getServletConfig().getServletContext());
        
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");
        
        String subversionId = "$Id: errorstats.jsp 910 2010-12-03 22:07:48Z p_ansell $";
        
        String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 ? "" : ":"+ request.getServerPort())+"/";
        
        BlacklistController.doBlacklistExpiry();
        BlacklistController.clearStatisticsUploadList();
        
        Date currentDate = new Date();
        
            // SimpleDateFormat ISO8601UTC = 
            //  new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss,SSS'Z'");
            // SimpleDateFormat ISO8601UTC = 
            //   new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");	  
            // ISO8601UTC.setTimeZone(TimeZone.getTimeZone("UTC"));
            String now = Utilities.ISO8601UTC().format(currentDate);
        
        
        long differenceMilliseconds = currentDate.getTime() - BlacklistController.lastExpiryDate.getTime();
        
        out.write("Current date : "+currentDate.toString()+"<br />\n");
        out.write("Server Version : "+Settings.VERSION+"<br />\n");
        out.write("Now : "+now+"<br />\n");
        out.write("Last error reset date: "+BlacklistController.lastExpiryDate.toString()+"<br />\n");
        out.write("Server startup date: "+BlacklistController.lastServerStartupDate.toString()+"<br />\n");
        out.write("Reset period "+Settings.getLongPropertyFromConfig("blacklistResetPeriodMilliseconds")+"<br />\n");
        out.write("Client blacklist will reset in "+((Settings.getLongPropertyFromConfig("blacklistResetPeriodMilliseconds")-differenceMilliseconds)/1000)+" seconds.<br /><br />\n");
        
        if(BlacklistController.allHttpErrorResponseCodesByServer != null)
        {
            if(BlacklistController.allHttpErrorResponseCodesByServer.size() > 0)
            {
                out.write("All HTTP response error codes by endpoint since last server restart:<br /><br />\n");
                
                for(String nextKey : BlacklistController.allHttpErrorResponseCodesByServer.keySet())
                {
                    out.write("Endpoint="+nextKey+"<br />\n");
                    
                    Hashtable<Integer, Integer> errorCodeList = BlacklistController.allHttpErrorResponseCodesByServer.get(nextKey);
                    
                    out.write("<ul>\n");
                    
                    for(int nextErrorCode : errorCodeList.keySet())
                    {
                        out.write("<li>"+nextErrorCode + " : " + errorCodeList.get(nextErrorCode)+"</li>\n");
                    }
                    
                    out.write("</ul>\n");
                }
            }
        }
        
        if(BlacklistController.allServerQueryTotals != null)
        {
            if(BlacklistController.allServerQueryTotals.size() > 0)
            {
                out.write("Total queries by endpoint since last server restart:<br />\n");
                
                out.write("<ul>\n");
                
                for(String nextKey : BlacklistController.allServerQueryTotals.keySet())
                {
                    out.write("<li>Endpoint=" + nextKey + " : " + BlacklistController.allServerQueryTotals.get(nextKey)+"</li>\n");
                }
                
                out.write("</ul>\n");
            }
        }
        
        for(String nextKey : BlacklistController.accumulatedBlacklistStatistics.keySet())
        {
            out.write(BlacklistController.accumulatedBlacklistStatistics.get(nextKey).toString()+"<br />\n");
            out.write(BlacklistController.accumulatedBlacklistStatistics.get(nextKey).errorMessageSummaryToString()+"<br />\n");
        }
        
        Collection<Long> overallQueryTimes = new HashSet<Long>();
        Collection<Long> userSpecificQueryTimes = new HashSet<Long>();
        long overallQueryTime = 0;
        int overallQueryNumbers = 0;
        
        
        
        for(String nextKey : BlacklistController.currentQueryDebugInformation.keySet())
        {
            out.write("<br />Queries by : "+nextKey+"<br />\n");
            
            Collection<QueryDebug> nextSetOfQueries = BlacklistController.currentQueryDebugInformation.get(nextKey);
            
            Collection<Long> nextQueryTimes = new HashSet<Long>();
            long nextTotalQueryTime = 0;
            int nextTotalQueryNumbers = nextSetOfQueries.size();
            
            for(QueryDebug nextQueryDebug : nextSetOfQueries)
            {
                nextTotalQueryTime += nextQueryDebug.totalTimeMilliseconds;
                
                overallQueryTimes.add(nextQueryDebug.totalTimeMilliseconds);
                nextQueryTimes.add(nextQueryDebug.totalTimeMilliseconds);
                
                if(_DEBUG)
                {
                    out.write(nextQueryDebug.toString()+"<br />\n");
                }
            }
            
            out.write("Total number of queries = " + nextTotalQueryNumbers+"<br />\n");
            out.write("Total query time = " + nextTotalQueryTime+"<br />\n");
            out.write("Average query length = " + nextTotalQueryTime/nextTotalQueryNumbers+"<br />\n");
            out.write("Standard deviation = " + Utilities.getStandardDeviationFromLongs(nextQueryTimes)+" <br />\n");
            
            userSpecificQueryTimes.add(nextTotalQueryTime);
            overallQueryTime += nextTotalQueryTime;
            overallQueryNumbers += nextTotalQueryNumbers;
        }
        
        if(overallQueryNumbers > 0)
        {
            out.write("<br />Overall Total number of queries = " + overallQueryNumbers+"<br />\n");
            out.write("Overall Total query time = " + overallQueryTime+"<br />\n");
            out.write("Overall Average query length = " + overallQueryTime/overallQueryNumbers+"<br />\n");
            out.write("Overall Standard deviation = " + Utilities.getStandardDeviationFromLongs(overallQueryTimes)+" <br />\n");
            out.write("Overall requestor level Standard deviation = " + Utilities.getStandardDeviationFromLongs(userSpecificQueryTimes)+" <br />\n");
        }
    
  }
  
}

