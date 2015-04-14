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

package org.alfresco.extension.bulkfilesystemimport.importfilters;

import java.util.ArrayList;
import java.util.List;

import org.alfresco.extension.bulkfilesystemimport.ImportableItem;
import org.alfresco.extension.bulkfilesystemimport.ImportFilter;

/**
 * This class provides an <code>ImportFilter</code> that only returns true if all of the configured <code>ImportFilter</code>s return true.
 *
 * @author Peter Monks (pmonks@alfresco.com)
 */
public class AndImportFilter
    implements ImportFilter
{
    private final List<ImportFilter> filters;
    
    public AndImportFilter(final ImportFilter left, final ImportFilter right)
    {
        // PRECONDITIONS
        assert left  != null : "left must not be null.";
        assert right != null : "right must not be null.";
        
        // Body
        this.filters = new ArrayList<ImportFilter>(2);
        
        filters.add(left);
        filters.add(right);
    }
    
    public AndImportFilter(final List<ImportFilter> filters)
    {
        // PRECONDITIONS
        assert filters        != null : "filters must not be null.";
        assert filters.size() >= 2    : "filters must contain at least 2 items.";
        
        // Body
        this.filters = filters;
    }
    

    /**
     * @see org.alfresco.extension.bulkfilesystemimport.ImportFilter#shouldFilter(org.alfresco.extension.bulkfilesystemimport.ImportableItem)
     */
    public boolean shouldFilter(final ImportableItem importableItem)
    {
        boolean result = true;
        
        for (final ImportFilter sourceFilter : filters)
        {
            if (!sourceFilter.shouldFilter(importableItem))
            {
                result = false;
                break;
            }
        }

        return(result);
    }

}
