[#ftl]
[#macro formatDuration durationInNs]
  [@compress single_line=true]
    [#assign days         = (durationInNs / (1000 * 1000 * 1000 * 60 * 60 * 24))?floor]
    [#assign hours        = (durationInNs / (1000 * 1000 * 1000 * 60 * 60))?floor % 24]
    [#assign minutes      = (durationInNs / (1000 * 1000 * 1000 * 60))?floor % 60]
    [#assign seconds      = (durationInNs / (1000 * 1000 * 1000))?floor % 60]
    [#assign milliseconds = (durationInNs / (1000 * 1000)) % 1000]
    [#assign microseconds = (durationInNs / (1000)) % 1000]
    ${days}d ${hours}h ${minutes}m ${seconds}s ${milliseconds}.${microseconds}ms
  [/@compress]
[/#macro]
[#macro formatBytes bytes]
  [@compress single_line=true]
    [#if     bytes > (1024 * 1024 * 1024 * 1024 * 1024)]${(bytes / (1024 * 1024 * 1024 * 1024 * 1024))?string("#,##0.00")}PB
    [#elseif bytes > (1024 * 1024 * 1024 * 1024)]${(bytes / (1024 * 1024 * 1024 * 1024))?string("#,##0.00")}TB
    [#elseif bytes > (1024 * 1024 * 1024)]${(bytes / (1024 * 1024 * 1024))?string("#,##0.00")}GB
    [#elseif bytes > (1024 * 1024)]${(bytes / (1024 * 1024))?string("#,##0.00")}MB
    [#elseif bytes > 1024]${(bytes / 1024)?string("#,##0.00")}kB
    [#else]${bytes?string("#,##0")}B
    [/#if]
  [/@compress]
[/#macro]
[#macro stateToHtmlColour state]
  [@compress single_line=true]
    [#if     state="Never run"]  black
    [#elseif state="Running"]    black
    [#elseif state="Successful"] green
    [#elseif state="Stopping"]   orange
    [#elseif state="Stopped"]    orange
    [#elseif state="Failed"]     red
    [#else]                      black
    [/#if]
  [/@compress]
[/#macro]
<!DOCTYPE HTML>
<html>
<head>
  <title>Bulk Filesystem Import Status</title>
  <link rel="stylesheet" href="${url.context}/css/main.css" type="text/css"/>
  <script src="http://yui.yahooapis.com/3.8.0/build/simpleyui/simpleyui-min.js"></script>
  <script src="${url.context}/scripts/bulkfilesystemimport/smoothie.js"></script>
  <script src="${url.context}/scripts/bulkfilesystemimport/spin.min.js"></script>
  <script src="${url.context}/scripts/bulkfilesystemimport/statusui.js"></script>
</head>
<body onload="onLoad('${url.serviceContext}', document.getElementById('filesPerSecondChart'), document.getElementById('bytesPerSecondChart'));">
  <table>
    <tr>
      <td><img src="${url.context}/images/logo/AlfrescoLogo32.png" alt="Alfresco" /></td>
      <td><nobr><strong>Bulk Filesystem Import Tool v1.3.5-SNAPSHOT (Community maintained)</strong></nobr></td>
    </tr>
    <tr><td><td>Alfresco ${server.edition} v${server.version}
  </table>
  <blockquote>
    <p>
[#if importStatus.inProgress()]
      <div id="currentStatus" style="display:inline-block;height:50px;color:red;font-weight:bold;font-size:16pt">In progress <span id="inProgressDuration"></span></div> <div id="spinner" style="display:inline-block;vertical-align:middle;width:50px;height:50px;margin:0px 20px 0px 20px"></div>
      <br/>
      <button id="stopImportButton" type="button" onclick="stopImport('${url.serviceContext}/bulk/import/filesystem/stop.json');">Stop import</button>
      <a id="initiateAnotherImport" style="display:none" href="${url.serviceContext}/bulk/import/filesystem">Initiate another import</a>
[#else]
      <div id="currentStatus" style="display:inline-block;height:50px;color:green;font-weight:bold;font-size:16pt">Idle</div> <div id="spinner" style="display:inline-block;vertical-align:middle;width:50px;height:50px;margin:0px 20px 0px 20px"></div>
      <br/>
      <button id="stopImportButton" style="display:none" type="button" onclick="stopImport('${url.serviceContext}/bulk/import/filesystem/stop');">Stop import</button>
      <a id="initiateAnotherImport" href="${url.serviceContext}/bulk/import/filesystem">Initiate another import</a>
[/#if]
    </p>
    <p>
      <div id="graphsHidden" style="display:none"><a onClick="toggleDivs(document.getElementById('graphsHidden'), document.getElementById('graphsShown'));"><img style="vertical-align:middle" src="${url.context}/images/icons/arrow_closed.gif"/><span style="vertical-align:middle">Graphs</span></a></div>
    </p>
    <div id="graphsShown" style="display:block"><a onClick="toggleDivs(document.getElementById('graphsShown'), document.getElementById('graphsHidden'));"><img style="vertical-align:middle" src="${url.context}/images/icons/arrow_open.gif"/><span style="vertical-align:middle">Graphs</span></a>
    <p>
      <strong>Files Per Second</strong>
    </p>
    <p>
      <table border="0" cellspacing="10" cellpadding="0">
        <tr>
          <td align="left" valign="top" width="75%">
            <canvas id="filesPerSecondChart" width="1000" height="200"></canvas>
          </td>
          <td align="left" valign="top" width="25%">
            <span style="color:red;font-weight:bold">Red = files scanned</span><br/>
            <span style="color:green;font-weight:bold">Green = files read</span><br/>
            <span style="color:blue;font-weight:bold">Blue = nodes created</span><br/>
          </td>
        </tr>
      </table>
    </p>
    <p>
      <strong>Bytes Per Second</strong>
    </p>
    <p>
      <table border="0" cellspacing="10" cellpadding="0">
        <tr>
          <td align="left" valign="top" width="75%">
            <canvas id="bytesPerSecondChart" width="1000" height="200"></canvas>
          </td>
          <td align="left" valign="top" width="25%">
            <span style="color:green;font-weight:bold">Green = bytes read</span><br/>
            <span style="color:blue;font-weight:bold">Blue = bytes written</span><br/>
            <span id="testMessage"></span><br/>
          </td>
        </tr>
      </table>
    </p>
    </div>
    <p>
      <div id="detailsHidden" style="display:block"><a onClick="toggleDivs(document.getElementById('detailsHidden'), document.getElementById('detailsShown'));"><img style="vertical-align:middle" src="${url.context}/images/icons/arrow_closed.gif"/><span style="vertical-align:middle">Details</span></a></div>
    </p>
    <div id="detailsShown" style="display:none"><a onClick="toggleDivs(document.getElementById('detailsShown'), document.getElementById('detailsHidden'));"><img style="vertical-align:middle" src="${url.context}/images/icons/arrow_open.gif"/><span style="vertical-align:middle">Details</span></a>
    <p>
    Refreshes every 5 seconds.
    </p>
    <p>
    <table border="1" cellspacing="0" cellpadding="1" width="80%">
      <tr>
        <td colspan="2"><strong>General Statistics</strong></td>
      </tr>
      <tr>
        <td width="25%">Status:</td>
        <td width="75%" id="detailsStatus" style="color:[@stateToHtmlColour importStatus.processingState/]">${importStatus.processingState}</td>
      </tr>
      <tr>
        <td>Source Directory:</td>
        <td>
[#if importStatus.sourceDirectory??]
          ${importStatus.sourceDirectory}
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>Target Space:</td>
        <td>
[#if importStatus.targetSpace??]
          ${importStatus.targetSpace}
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>Import Type:</td>
        <td>
[#if importStatus.importType??]
          ${importStatus.importType}
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>Batch Weight:</td>
        <td>${importStatus.batchWeight}</td>
      </tr>
      <tr>
        <td>Active Threads:</td>
        <td><span id="detailsActiveThreads">${importStatus.numberOfActiveThreads}</span> (of <span id="detailsTotalThreads">${importStatus.totalNumberOfThreads}</span> total)</td>
      </tr>
      <tr>
        <td>Start Date:</td>
        <td>
[#if importStatus.startDate??]
          ${importStatus.startDate?datetime?iso_utc}
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>End Date:</td>
        <td id="detailsEndDate">
[#if importStatus.endDate??]
          ${importStatus.endDate?datetime?iso_utc}</td>
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>Duration:</td>
        <td id="detailsDuration">
[#if importStatus.durationInNs??]
          [@formatDuration importStatus.durationInNs /]
[#else]
          n/a
[/#if]
        </td>
      </tr>
      <tr>
        <td>Number of Completed Batches:</td>
        <td id="detailsCompletedBatches">${importStatus.numberOfBatchesCompleted}</td>
      </tr>
      <tr>
        <td colspan="2"><strong>Source (read) Statistics</strong></td>
      </tr>
      <tr>
        <td>Last file or folder processed:</td>
        <td id="detailsCurrentFileOrFolder">${importStatus.currentFileBeingProcessed!"n/a"}</td>
      </tr>
      <tr>
        <td>Scanned:</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="1">
            <tr>
              <td>Folders</td>
              <td>Files</td>
              <td>Unreadable</td>
            </tr>
            <tr>
              <td id="detailsFoldersScanned">${importStatus.numberOfFoldersScanned}</td>
              <td id="detailsFilesScanned">${importStatus.numberOfFilesScanned}</td>
              <td id="detailsUnreadableEntries">${importStatus.numberOfUnreadableEntries}</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>Read:</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="1">
            <tr>
              <td>Content</td>
              <td>Metadata</td>
              <td>Content Versions</td>
              <td>Metadata Versions</td>
            </tr>
            <tr>
              <td><span id="detailsContentFilesRead">${importStatus.numberOfContentFilesRead}</span> (<span id="detailsContentBytesRead">[@formatBytes importStatus.numberOfContentBytesRead/]</span>)</td>
              <td><span id="detailsMetadataFilesRead">${importStatus.numberOfMetadataFilesRead}</span> (<span id="detailsMetadataBytesRead">[@formatBytes importStatus.numberOfMetadataBytesRead/]</span>)</td>
              <td><span id="detailsContentVersionFilesRead">${importStatus.numberOfContentVersionFilesRead}</span> (<span id="detailsContentVersionBytesRead">[@formatBytes importStatus.numberOfContentVersionBytesRead/]</span>)</td>
              <td><span id="detailsMetadataVersionFilesRead">${importStatus.numberOfMetadataVersionFilesRead}</span> (<span id="detailsMetadataVersionBytesRead">[@formatBytes importStatus.numberOfMetadataVersionBytesRead/]</span>)</td>
            </tr>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>Throughput:</td>
        <td>
[#if importStatus.durationInNs?? && importStatus.durationInNs > 0]
  [#assign totalFilesRead = importStatus.numberOfContentFilesRead +
                            importStatus.numberOfMetadataFilesRead +
                            importStatus.numberOfContentVersionFilesRead +
                            importStatus.numberOfMetadataVersionFilesRead]
  [#assign totalDataRead = importStatus.numberOfContentBytesRead +
                           importStatus.numberOfMetadataBytesRead +
                           importStatus.numberOfContentVersionBytesRead +
                           importStatus.numberOfMetadataVersionBytesRead]
          <span id="detailsEntriesScannedPerSecond">${((importStatus.numberOfFilesScanned + importStatus.numberOfFoldersScanned) / (importStatus.durationInNs / (1000 * 1000 * 1000)))} entries scanned / sec</span><br/>
          <span id="detailsFilesReadPerSecond">${(totalFilesRead  / (importStatus.durationInNs / (1000 * 1000 * 1000)))} files read / sec</span><br/>
          <span id="detailsDataReadPerSecond">[@formatBytes (totalDataRead / (importStatus.durationInNs / (1000 * 1000 * 1000))) /] / sec</span>
[#else]
          <span id="detailsEntriesScannedPerSecond">n/a</span><br/>
          <span id="detailsFilesReadPerSecond"></span><br/>
          <span id="detailsDataReadPerSecond"></span>
[/#if]
        </td>
      </tr>
      <tr>
        <td colspan="2"><strong>Target (write) Statistics</strong></td>
      </tr>
      <tr>
        <td>Space Nodes:</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="1">
            <tr>
              <td># Created</td>
              <td># Replaced</td>
              <td># Skipped</td>
              <td># Properties</td>
            </tr>
            <tr>
              <td id="detailsSpaceNodesCreated">${importStatus.numberOfSpaceNodesCreated}</td>
              <td id="detailsSpaceNodesReplaced">${importStatus.numberOfSpaceNodesReplaced}</td>
              <td id="detailsSpaceNodesSkipped">${importStatus.numberOfSpaceNodesSkipped}</td>
              <td id="detailsSpacePropertiesWritten">${importStatus.numberOfSpacePropertiesWritten}</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>Content Nodes:</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="1">
            <tr>
              <td># Created</td>
              <td># Replaced</td>
              <td># Skipped</td>
              <td>Data Written</td>
              <td># Properties</td>
            </tr>
            <tr>
              <td id="detailsContentNodesCreated">${importStatus.numberOfContentNodesCreated}</td>
              <td id="detailsContentNodesReplaced">${importStatus.numberOfContentNodesReplaced}</td>
              <td id="detailsContentNodesSkipped">${importStatus.numberOfContentNodesSkipped}</td>
              <td id="detailsContentBytesWritten">[@formatBytes importStatus.numberOfContentBytesWritten/]</td>
              <td id="detailsContentPropertiesWritten">${importStatus.numberOfContentPropertiesWritten}</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>Content Versions:</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="1">
            <tr>
              <td># Created</td>
              <td>Data Written</td>
              <td># Properties</td>
            </tr>
            </tr>
              <td id="detailsContentVersionsCreated">${importStatus.numberOfContentVersionsCreated}</td>
              <td id="detailsContentVersionBytesWritten">[@formatBytes importStatus.numberOfContentVersionBytesWritten/]</td>
              <td id="detailsContentVersionPropertiesWritten">${importStatus.numberOfContentVersionPropertiesWritten}</td>
            </tr>
          </table>
        </td>
      <tr>
      <tr>
        <td>Throughput:</td>
        <td>
[#if importStatus.durationInNs?? && importStatus.durationInNs > 0]
  [#assign totalNodesWritten = importStatus.numberOfSpaceNodesCreated +
                               importStatus.numberOfSpaceNodesReplaced +
                               importStatus.numberOfContentNodesCreated +
                               importStatus.numberOfContentNodesReplaced +
                               importStatus.numberOfContentVersionsCreated]    [#-- We count versions as a node --]
  [#assign totalDataWritten = importStatus.numberOfContentBytesWritten +
                              importStatus.numberOfContentVersionBytesWritten]
          <span id="detailsNodesWrittenPerSecond">${(totalNodesWritten  / (importStatus.durationInNs / (1000 * 1000 * 1000)))?string("#0")} nodes / sec</span><br/>
          <span id="detailsDataWrittenPerSecond">[@formatBytes (totalDataWritten / (importStatus.durationInNs / (1000 * 1000 * 1000))) /] / sec</span>
[#else]
          <span id="detailsNodesWrittenPerSecond">n/a</span><br/>
          <span id="detailsDataWrittenPerSecond"></span>
[/#if]
        </td>
      </tr>
    </table>
    <div id="detailsErrorInformation" style="display:none">
      <p><strong>Error Information From Last Run</strong></p>
      <table border="1" cellspacing="0" cellpadding="1" width="80%">
        <tr>
          <td>File that failed:</td>
          <td id="detailsFileThatFailed">${importStatus.currentFileBeingProcessed!"n/a"}</td>
        </tr>
        <tr>
          <td style="vertical-align:top">Exception:</td>
          <td><pre id="detailsLastException">${importStatus.lastExceptionAsString!"n/a"}</pre></td>
        </tr>
      </table>
    </div>
    </p>
  </blockquote>
</body>
</html>
