/*
 * Copyright (C) 2007-2013 Peter Monks.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * This file is part of an unsupported extension to Alfresco.
 * 
 */

package org.alfresco.extension.bulkfilesystemimport.webscripts;

import java.io.File;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Date;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.springframework.extensions.webscripts.Cache;
import org.springframework.extensions.webscripts.DeclarativeWebScript;
import org.springframework.extensions.webscripts.Status;
import org.springframework.extensions.webscripts.WebScriptRequest;
import org.springframework.extensions.webscripts.WebScriptException;

import org.alfresco.repo.model.Repository;
import org.alfresco.service.ServiceRegistry;
import org.alfresco.service.cmr.model.FileNotFoundException;
import org.alfresco.service.cmr.repository.NodeRef;

import org.alfresco.extension.bulkfilesystemimport.BulkFilesystemImporter;


/**
 * Web Script class that invokes a BulkFilesystemImporter implementation.
 *
 * @author Peter Monks (peter.monks@alfresco.com)
 */
public class BulkFilesystemImportWebScript
    extends DeclarativeWebScript
{
    private final static Log log = LogFactory.getLog(BulkFilesystemImportWebScript.class);
    
    
    // Other Web Script URIs
    private final static String WEB_SCRIPT_URI_BULK_FILESYSTEM_IMPORT_STATUS = "/bulk/import/filesystem/status";
    
    // Web Script parameters
    private final static String PARAMETER_TARGET_NODEREF         = "targetNodeRef";
    private final static String PARAMETER_TARGET_PATH            = "targetPath";
    private final static String PARAMETER_SOURCE_DIRECTORY       = "sourceDirectory";
    private final static String PARAMETER_REPLACE_EXISTING       = "replaceExisting";
    private final static String PARAMETER_VALUE_REPLACE_EXISTING = "replaceExisting";
    
    //
    private final static String COMPANY_HOME_NAME = "Company Home";
    private final static String COMPANY_HOME_PATH = "/" + COMPANY_HOME_NAME;
    
    // Attributes
    private final ServiceRegistry        serviceRegistry;
    private final Repository             repository;
    private final BulkFilesystemImporter importer;
    
    
    public BulkFilesystemImportWebScript(final ServiceRegistry        serviceRegistry,
                                         final Repository             repository,
                                         final BulkFilesystemImporter importer)
    {
        // PRECONDITIONS
        assert serviceRegistry != null : "serviceRegistry must not be null.";
        assert repository      != null : "repository must not be null."; 
        assert importer        != null : "importer must not be null.";
        
        //BODY
        this.serviceRegistry = serviceRegistry;
        this.repository      = repository;
        this.importer        = importer;
    }
    
    
    
    

    /**
     * @see org.springframework.extensions.webscripts.DeclarativeWebScript#executeImpl(org.springframework.extensions.webscripts.WebScriptRequest, org.springframework.extensions.webscripts.Status, org.springframework.extensions.webscripts.Cache)
     */
    @Override
    protected Map<String, Object> executeImpl(final WebScriptRequest request, final Status status, final Cache cache)
    {
        Map<String, Object> result = null;
        String targetNodeRefStr    = null;
        String targetPath          = null;
        String sourceDirectoryStr  = null;
        String replaceExistingStr  = null;
        
        cache.setNeverCache(true);
        
        try
        {
            if (!importer.getStatus().inProgress())
            {
                NodeRef targetNodeRef   = null;
                File    sourceDirectory = null;
                boolean replaceExisting  = false;
                
                // Retrieve, validate and convert parameters
                targetNodeRefStr   = request.getParameter(PARAMETER_TARGET_NODEREF);
                targetPath         = request.getParameter(PARAMETER_TARGET_PATH);
                sourceDirectoryStr = request.getParameter(PARAMETER_SOURCE_DIRECTORY);
                replaceExistingStr = request.getParameter(PARAMETER_REPLACE_EXISTING);
                
                if (targetNodeRefStr == null || targetNodeRefStr.trim().length() == 0)
                {
                    if (targetPath == null || targetPath.trim().length() == 0)
                    {
                        throw new RuntimeException("Error: neither parameter '" + PARAMETER_TARGET_NODEREF +
                                                   "' nor parameter '" + PARAMETER_TARGET_PATH +
                                                   "' was provided, but at least one is required.");
                    }
                    
                    targetNodeRef = convertPathToNodeRef(targetPath.trim());
                }
                else
                {
                    targetNodeRef = new NodeRef(targetNodeRefStr.trim());
                }
                
                if (sourceDirectoryStr == null || sourceDirectoryStr.trim().length() == 0)
                {
                    throw new RuntimeException("Error: mandatory parameter '" + PARAMETER_SOURCE_DIRECTORY + "' was not provided.");
                }
                
                sourceDirectory = new File(sourceDirectoryStr.trim());
                
                if (replaceExistingStr != null && replaceExistingStr.trim().length() > 0)
                {
                    replaceExisting = PARAMETER_VALUE_REPLACE_EXISTING.equals(replaceExistingStr);
                }
                
                // Initiate the import
                importer.bulkImport(targetNodeRef, sourceDirectory, replaceExisting);
            }
        }
        catch (final WebScriptException wse)
        {
            throw wse;
        }
        catch (final FileNotFoundException fnfe)
        {
            throw new WebScriptException(404, "The path " + targetPath + " does not exist.", fnfe);
        }
        catch (final Throwable t)
        {
            throw new WebScriptException(500, buildTextMessage(t), t);
        }
        
        // If successful, redirect to the status Web Script
        status.setCode(Status.STATUS_MOVED_TEMPORARILY);
        status.setRedirect(true);
        status.setLocation(request.getServiceContextPath() + WEB_SCRIPT_URI_BULK_FILESYSTEM_IMPORT_STATUS);
        
        return(result);
    }


    private NodeRef convertPathToNodeRef(final String targetPath)
        throws FileNotFoundException
    {
        NodeRef result          = null;
        NodeRef companyHome     = repository.getCompanyHome();
        String  cleanTargetPath = targetPath.replaceAll("/+", "/");
        
        if (cleanTargetPath.startsWith(COMPANY_HOME_PATH))
        {
            cleanTargetPath = cleanTargetPath.substring(COMPANY_HOME_PATH.length());
        }
        
        if (cleanTargetPath.startsWith("/"))
        {
            cleanTargetPath = cleanTargetPath.substring(1);
        }
        
        if (cleanTargetPath.endsWith("/"))
        {
            cleanTargetPath = cleanTargetPath.substring(0, cleanTargetPath.length() - 1);
        }
        
        if (cleanTargetPath.length() == 0)
        {
            result = companyHome;
        }
        else
        {
            result = serviceRegistry.getFileFolderService().resolveNamePath(companyHome, Arrays.asList(cleanTargetPath.split("/"))).getNodeRef();
        }
        
        return(result);
    }
    
    
    private String buildTextMessage(final Throwable t)
    {
        StringBuffer result        = new StringBuffer();
        String       timeOfFailure = (new Date()).toString();
        String       hostName      = null;
        String       ipAddress     = null;

        try
        {
            hostName  = InetAddress.getLocalHost().getHostName();
            ipAddress = InetAddress.getLocalHost().getHostAddress();
        }
        catch (UnknownHostException uhe)
        {
            hostName  = "unknown";
            ipAddress = "unknown";
        }

        result.append("\nTime of failure:             " + timeOfFailure);
        result.append("\nHost where failure occurred: " + hostName + " (" + ipAddress + ")");
        
        if (t != null)
        {
            result.append("\nRoot exception:");
            result.append(renderExceptionStackAsText(t));
        }
        else
        {
            result.append("\nNo exception was provided.");
        }

        return(result.toString());
    }
    
    
    private String renderExceptionStackAsText(final Throwable t)
    {
        StringBuffer result = new StringBuffer();

        if (t != null)
        {
            String    message = t.getMessage();
            Throwable cause   = t.getCause();

            if (cause != null)
            {
                result.append(renderExceptionStackAsText(cause));
                result.append("\nWrapped by:");
            }

            if (message == null)
            {
                message = "";
            }

            result.append("\n");
            result.append(t.getClass().getName());
            result.append(": ");
            result.append(message);
            result.append("\n");
            result.append(renderStackTraceElements(t.getStackTrace()));
        }

        return(result.toString());
    }
    
    private String renderStackTraceElements(final StackTraceElement[] elements)
    {
        StringBuffer result = new StringBuffer();

        if (elements != null)
        {
            for (int i = 0; i < elements.length; i++)
            {
                result.append("\tat " + elements[i].toString() + "\n");
            }
        }

        return(result.toString());
    }
    
}
