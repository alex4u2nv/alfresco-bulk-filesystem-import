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

package org.alfresco.extension.bulkfilesystemimport;

import java.io.File;


/**
 * This interface defines a directory analyser. This is the process by which
 * the contents of a source directory are grouped together into a list of
 * <code>ImportableItem</code>s. 
 * 
 * Please note that this interface is not intended to have more than one implementation
 * (<code>DirectoryAnalyserImpl</code>) - it exists solely for dependency injection purposes.
 *
 * @author Peter Monks (pmonks@alfresco.com)
 */
public interface DirectoryAnalyser
{
    /**
     * Regex string for version labels.
     */
    public final static String VERSION_LABEL_REGEX  = "([\\d]+)(\\.([\\d]+))?"; // Group 0 = version label, Group 1 = major version #, group 3 (if not null) = minor version #

    /**
     * Regex string for version labels within filenames.
     */
    public final static String VERSION_SUFFIX_REGEX = "\\.v(" + VERSION_LABEL_REGEX + ")\\z"; // Note: group numbers are one greater than shown above
    
    /**
     * Analyses the given directory.
     * 
     * @param directory The directory to analyse (note: <u>must</u> be a directory) <i>(must not be null)</i>.
     * @return An <code>AnalysedDirectory</code> object <i>(will not be null)</i>.
     * @throws InterruptedException If the thread executing the method is interrupted.
     */
    public AnalysedDirectory analyseDirectory(final File directory) throws InterruptedException;
}
