
tableHelper = {
    __table: function () {
        var obj = {
            __disableColumnDetect: false,
            //This private function adds a control column
            __fnCreateControl: function (dataObj) {
                for (var key in dataObj) {
                    (dataObj[key])["control"] = "Control";
                }
            },
            __fnHeaderProperties: function () {
                var obj = {
                    //this is how you change the display name of the header.
                    DisplayName: null,
                    //this is a setting to hide a chosen column
                    HideColumn: false,
                    /*Private int
                    *This controls the display order of the columns
                    */
                    displayOrder: 0
                }
                return obj;
            },
            noResultsMessage: 'No Results',
            /*Function
             *Changes the order of columns
             */
            changeDisplayOrder: function (columnName, order) {
                ///<param name="columnName">Name of the column being ordered</param>
                ///<param name="order">Int - the order the column should be displayed in</param>

                var iOrder = (parseInt(order) < -1 ? 0 : parseInt(order));
                var collection = this.Properties.Header.Collection;

                if (typeof collection[columnName] === 'undefined') {
                    collection[columnName] = this.__fnHeaderProperties();
                    collection[columnName].displayOrder = iOrder;
                }
                else {
                    collection[columnName].displayOrder = iOrder;
                }
            },
            setDisplayOrder: function () {
                var array = Array.prototype.slice.call(arguments, 0);
                for (var idx in array) {
                    this.changeDisplayOrder(array[idx], idx);
                }
            },
            /*Function
            *Set to true if you want to freeze the header and prevent it from scrolling.
            */
            freezeHeader: function (freezeHeader, height) {
                ///<param name="freezeHeader">Bool true/false</param>
                ///<param name="height">Height of the table to freeze.  Leave null for default</param>
                var tmpHeight = parseInt(height);
                var headerProp = this.Properties.Header;
                if (tmpHeight > 0)
                    headerProp.__freezeHeaderHeight = tmpHeight;

                headerProp.__freezeHeader = Bool(freezeHeader);
            },
            setColumnWidth: function (colName, width, target) {
                if (typeof width === 'number')
                    width = width.toString();
                if (target != null)
                    $(target).find(String.format('#{0} [colname="{1}"]', this.Properties.Id, colName)).css('width', width.replace('px', '') + 'px');
                else
                    $(String.format('#{0} [colname="{1}"]', this.Properties.Id, colName)).css('width', width.replace('px', '') + 'px');
            },
            /*Function 
            * Checks for frozen header
            */
            hasFrozenHeader: function () {
                var headerProp = this.Properties.Header;
                return Bool(headerProp.__freezeHeader);
            },
            /*Function 
            * Gets the table height;
            */
            getFreezeHeaderHeight: function () {
                var headerProp = this.Properties.Header;
                return headerProp.__freezeHeaderHeight;
            },
            /*Function returns void
            *Bool. true / false.  Used to hide null values.  Displays as empty instead of null.
            */
            hideNullValues: function (hide) {
                ///<param name="hide">Bool true/false - Set this to true if you don't want to display null values.</param>
                this.Properties.__hideNullValues = Bool(hide);
            },
            /*Function
            *Returns bool.  Whether or not null values are visible.
            */
            nullValuesHidden: function () {
                return Bool(this.Properties.__hideNullValues);
            },
            /*Function
            *Hides / Shows the header row
            */
            hideHeader: function (hide) {
                ///<param name="hide">Bool true / false</param>
                this.Properties.Header.HideHeaderRow = Bool(hide);
            },
            /*Function
            *Sets the Id on the table and clears the cache
            */
            setId: function (tmpId, clearCache) {
                ///<param name="tmpId">This is the ID used for the table</param>
                ///<param name="clearCache">Bool true / false.  Set to true by default to clear the cache on each load.</param>

                var blClearCache = (isNullOrEmpty(clearCache) ? false : Bool(clearCache));

                if (!isNullOrEmpty(tmpId)) {
                    if (blClearCache && globalvars.IndexedTables != undefined && globalvars.IndexedTables[tmpId] != undefined)
                        delete globalvars.IndexedTables[tmpId];

                    this.Properties.Id = tmpId;
                }
            },
            /*Function
            *Sets the Id on the table and clears the cache
            */
            getId: function () {
                return this.Properties.Id;
            },
            SetData: function (dataObj) {
                var iProperties = this.Properties;
                iProperties.setData(dataObj);
                var iData = iProperties.getData();
                var iHeader = iProperties.Header;
                var iTableId = iProperties.Id;

                if (iData != undefined && !isNullOrEmpty(iData)) {

                    var objRow1 = iData[0];
                    var aryTmpHeadCollection = new Array();

                    for (var key in iHeader.Collection) {
                        aryTmpHeadCollection[key] = iHeader.Collection[key];
                    }

                    iHeader.Collection = {};

                    for (key in objRow1) {
                        if (key == '__type' && isNullOrEmpty(iTableId)) {
                            var tmpTableId = "dataTbl_" + objRow1[key];
                            var iTCount = 0;
                            while (document.getElementById(tmpTableId) != undefined) {
                                tmpTableId += iTCount
                            }

                            iTableId = tmpTableId;

                            if (typeof iHeader.Collection[key] === 'undefined') {
                                iHeader.Collection[key] = this.__fnHeaderProperties();
                                iHeader.Collection[key].displayOrder = -1;
                            }
                        }
                        else {
                            if (!this.__disableColumnDetect || aryTmpHeadCollection[key] !== undefined) {
                                if (typeof iHeader.Collection[key] === 'undefined') {
                                    iHeader.Collection[key] = this.__fnHeaderProperties();
                                    iHeader.Collection[key].displayOrder = -1;
                                }
                            }
                        }
                    }

                    if (this.Properties.TButtons > 0) {
                        iHeader.Collection["control"] = this.__fnHeaderProperties();;
                        iHeader.Collection["control"].DisplayName = "";
                        this.changeDisplayOrder("control", -1);

                        iData = this.__fnCreateControl(iData);
                    }

                    iHeader.displayOrder = new Array(); //Clear out the display order array.

                    for (key in aryTmpHeadCollection) {
                        iHeader.Collection[key].HideColumn = aryTmpHeadCollection[key].HideColumn;
                        iHeader.Collection[key].displayOrder = aryTmpHeadCollection[key].displayOrder; //update the display order array with current sorts
                        iHeader.Collection[key].DisplayName = aryTmpHeadCollection[key].DisplayName;
                        iHeader.Collection[key].showTime = aryTmpHeadCollection[key].showTime;
                    }

                    var tmpNonSorted = new Array();
                    var tmpSorted = new Array();

                    //Loop through headers and move those with keys into tmpSorted
                    //move those without keys into tmpNonSorted.
                    for (key in iHeader.Collection) {
                        if (iHeader.Collection[key].displayOrder < 0)
                            tmpNonSorted.push(key); //store keys with a -1 sort order
                        else {
                            tmpSorted[iHeader.Collection[key].displayOrder] = key; //store keys with 0 > sort order
                        }
                    }

                    tmpSorted = tmpSorted.filter(function (e) { return e }); //clean array and compress to remove "", null, and undefined
                    tmpSorted = tmpSorted.concat(tmpNonSorted); //push the non sorted array to the bottom of the sorted array

                    //Update the Headers to have their appropriate sort orders
                    for (var i = 0; i < tmpSorted.length; i++) {
                        iHeader.Collection[tmpSorted[i]].displayOrder = i;
                    }

                    iHeader.displayOrder = tmpSorted;
                    iProperties.TResults = (isNullOrEmpty(iData) ? 0 : iData.length);
                }
                else {
                    //---------------------------------------------------------
                        var tmpNonSorted = new Array();
                        var tmpSorted = new Array();

                        //Loop through headers and move those with keys into tmpSorted
                        //move those without keys into tmpNonSorted.
                        for (key in iHeader.Collection) {
                            if (iHeader.Collection[key].displayOrder < 0)
                                tmpNonSorted.push(key); //store keys with a -1 sort order
                            else {
                                tmpSorted[iHeader.Collection[key].displayOrder] = key; //store keys with 0 > sort order
                            }
                        }

                        tmpSorted = tmpSorted.filter(function (e) { return e }); //clean array and compress to remove "", null, and undefined
                        tmpSorted = tmpSorted.concat(tmpNonSorted); //push the non sorted array to the bottom of the sorted array

                        //Update the Headers to have their appropriate sort orders
                        for (var i = 0; i < tmpSorted.length; i++) {
                            iHeader.Collection[tmpSorted[i]].displayOrder = i;
                        }

                        iHeader.displayOrder = tmpSorted;
                        iProperties.TResults = 0;
                    //---------------------------------------------------------
                }
            },
            SetDataObjectFromIndex: function (indexName) {
                var tmpDO = null;

                tmpDO = new Array();
                var i = 0;

                for (var key in globalvars.IndexedTables[indexName]) {
                    tmpDO[i] = globalvars.IndexedTables[indexName][key].objRow;
                    i++;
                }

                this.SetData(tmpDO);
            },
            /*Function
            *Adds buttons to the table helper.
            */
            AddButtons: function (buttonName, columnName, onClickFunction, type, caption, rules) {
                ///<param name="buttonName">This is the title attribute on the button. use buttonTypes object.</param>
                ///<param name="columnName">This points the button to the data object being used as the key.</param>
                ///<param name="onClickFunction">The function to call on click.</param>
                ///<param name="type">User:  standard for a normal button or use the last piece of the glypicon name</param>
                ///<param name="caption">The caption that appears on hover</param>
                if (!isNullOrEmpty(buttonName)) {
                    var tmpObjButton = this.Properties.__fnButtonProperties();
                    tmpObjButton.ButtonName = buttonName;
                    tmpObjButton.ColumnName = (isNullOrEmpty(columnName) ? null : columnName);
                    if (!isNullOrEmpty(onClickFunction) || typeof onClickFunction === 'function')
                        tmpObjButton.OnClickFunction = onClickFunction;
                    else
                        tmpObjButton.OnClickFunction = null;

                    if (!isNullOrEmpty(type))
                        tmpObjButton.type = type;

                    if (!isNullOrEmpty(caption))
                        tmpObjButton.ButtonCaption = caption;

                    if (!isNullOrEmpty(rules))
                        tmpObjButton.ButtonRules = rules;

                    this.Properties.Buttons[buttonName] = tmpObjButton;

                    if (!isNullOrEmpty(columnName) && !isNullOrEmpty(onClickFunction))
                        this.Properties.Buttons[buttonName].On = true;

                    this.Properties.TButtons++;
                }
            },
            //------------------ Header functions -----------------------------------------
            /*Function
            *Takes a list of column names and hides them.
            */
            hideColumns: function () {
                var cols = Array.prototype.slice.call(arguments, 0);
                for (key in cols) {
                    this.hideColumn(cols[key], true);
                }
            },
            hideColumn: function (columnName, hide) {
                ///<param name="columnName">Name of the column to hide/reveal</param>
                ///<param name="hide">Bool true/false</param>
                var iHeaderCollection = this.Properties.Header.Collection;

                if (typeof iHeaderCollection[columnName] === "undefined") {
                    iHeaderCollection[columnName] = this.__fnHeaderProperties();
                    iHeaderCollection[columnName].HideColumn = Bool(hide);
                    iHeaderCollection[columnName].displayOrder = -1;
                }
                else {
                    iHeaderCollection[columnName].HideColumn = Bool(hide);
                    if (iHeaderCollection[columnName].displayOrder < 0)
                        iHeaderCollection[columnName].displayOrder = -1;
                }
            },
            renameColumnHeader: function (columnName, displayName) {
                ///<param name="columnName">Name of the column to hide/reveal</param>
                ///<param name="displayName">The column name</param>
                var iHeaderCollection = this.Properties.Header.Collection;

                if (typeof iHeaderCollection[columnName] === "undefined" && !isNullOrEmpty(displayName)) {
                    iHeaderCollection[columnName] = this.__fnHeaderProperties();
                    iHeaderCollection[columnName].DisplayName = displayName;
                }
            },
            changeHeaderDisplayName: function (columnName, displayName) {
                ///<param name="columnName">Name of the column being modified</param><
                ///<param name="displayName">The display name for the column</param>

                var iCollection = this.Properties.Header.Collection;
                if (iCollection[columnName] === undefined) {
                    iCollection[columnName] = this.__fnHeaderProperties();
                }

                iCollection[columnName].DisplayName = displayName;
            },
            showTimeInColumn: function (columnName, showTime) {
                ///<param name="columnName">Name of the column being modified</param><
                ///<param name="showTime">Boolean indicating whether to display time</param>

                var iCollection = this.Properties.Header.Collection;
                if (iCollection[columnName] === undefined) {
                    iCollection[columnName] = this.__fnHeaderProperties();
                }

                iCollection[columnName].showTime = showTime;
            },
            preLoadHeaders: function (Headers) {
                for (var i = 0; i < Headers.length; i++) {
                    var headerObj = Headers[i];

                    this.hideColumn(headerObj.dataColumn, headerObj.hideColumn);
                    this.changeHeaderDisplayName(headerObj.dataColumn, headerObj.displayName);
                    this.showTimeInColumn(headerObj.dataColumn, headerObj.showTime);


                    if (headerObj.sortOrder != null)
                        this.changeDisplayOrder(headerObj.dataColumn, headerObj.sortOrder);
                }
            },
            preLoadHeaders2: function (detectOtherColumns) {
                detectOtherColumns = isNull(detectOtherColumns, true);
                var headers = Array.prototype.slice.call(arguments, 1);
                for (var i = 0; i < headers.length; i++) {
                    var headerObj = headers[i];
                    if ($.isArray(headerObj)) {
                        preLoadHeaders(headerObj);
                        break;
                    }
                    else {
                        if ($.type(headerObj) === 'string')
                            headerObj = {
                                dataColumn: headerObj,
                                displayName: null,
                                hideColumn: false,
                                sortOrder: i
                            };
                        if (headerObj.displayName === undefined)
                            headerObj.displayName = null;
                        if (headerObj.hideColumn === undefined)
                            headerObj.hideColumn = false;
                        if (headerObj.showTime === undefined)
                            headerObj.showTime = false;
                        headerObj.sortOrder = i;

                        this.hideColumn(headerObj.dataColumn, headerObj.hideColumn);
                        this.changeHeaderDisplayName(headerObj.dataColumn, headerObj.displayName);
                        this.showTimeInColumn(headerObj.dataColumn, headerObj.showTime);


                        if (headerObj.sortOrder != null)
                            this.changeDisplayOrder(headerObj.dataColumn, headerObj.sortOrder);

                        if (!detectOtherColumns)
                            this.disableColumnDetect();
                    }
                }
            },
            disableColumnDetect: function () {
                this.__disableColumnDetect = true;
            },
            __preLoadHeaders: function () {
                var obj = {
                    aryHeaders: new Array(),
                    __headerObj : function() {
                        var obj={
                            dataColumn: null,
                            displayName: null,
                            hideColumn: false,
                            sortOrder: null
                        }
                        return obj;
                    },
                    addHeader: function (dataColumn, displayName, hideColumn, sortOrder) {
                        var iAry = this.aryHeaders;                        

                        if (!isNullOrEmpty(dataColumn)) {
                            var iHObj = this.__headerObj();
                            iHObj.dataColumn = dataColumn;

                            if (isNullOrEmpty(displayName)) {
                                iHObj.displayName = null;
                            }
                            else {
                                iHObj.displayName = dataColumn
                            }

                            iHObj.hideColumn = Bool(hideColumn);

                            if (!isNullOrEmpty(sortOrder)) {
                                iHObj.sortOrder = parseInt(sortOrder);
                            }
                            else
                                iHObj.sortOrder = -1;

                            iAry[iAry.length] = iHObj;
                        }
                    }
                }

                return obj;
            },
            //------------------ END Header functions --------------------------------------

            onRowClick: function (columnName, onClickFunction) {
                this.Properties.RowEvent.On = true;
                this.Properties.RowEvent.ColumnName = columnName;
                this.Properties.RowEvent.OnClickFunction = onClickFunction;
            },
            setRowExpand: function (expandRowOnClick, getContentFunction, columnName) {
                this.Properties.ExpandRowOnClick = expandRowOnClick;
                if (expandRowOnClick === true) {
                    this.Properties.ExpandRowContentFunc = getContentFunction;
                    this.Properties.ExpandRowColumnName = columnName;
                }
            },
            initializeTable: function (id, hideHeader, freezeHeader, altStyles, highlightOnHover) {
                ///<param name="id">This is the table elements id.</param>
                ///<param name="hideHeader">Bool true/false : Will hide(true) or reveal (false) the table header</param>
                ///<param name="freezeHeader">Bool true/false : Will lock the header at the top (true) enabling a scroll effect or not (false)</param>
                ///<param name="altStyles">Bool true/false : Turns alternating row styles on (true) or off (false)</param>
                ///<param name="highlightOnHover">Bool true/false : Adds a highlight on hover effect (true) or not (false)</param>
                if (!isNullOrEmpty(this.Properties)) {
                    this.Properties.Id = id;
                    this.Properties.Header.HideHeaderRow = Bool(hideHeader);
                    if (Bool(freezeHeader))
                        this.freezeHeader(true, 300);
                    this.Properties.UseAltStyles = Bool(altStyles);
                    this.Properties.HighlightRowOnHover = Bool(highlightOnHover);
                }
            },
            getTSearchResults: function () {
                return this.Properties.TSearchResults;
            },
            /*Public function
              *Used to set the filter fields
              */
            SetFilter: function (controlId, columnName, blUnique) {
                ///<param name="controlId">Id of the control used in filtering</param>
                ///<param name="columnName">Database Column being filtered against</param>
                ///<param name="blUnique">Specifies that this filtered field must be unique</param>
                var iFilter = this.Properties.Filter.objFilter;

                if ($('#' + controlId) === undefined || isNullOrEmpty(columnName))
                    return false;
                else {
                    var tmpVal = $('#' + controlId).getVal();
                    var maxLength = tmpVal.length;
                    for (var key in iFilter) {
                        if (key != columnName && iFilter[key].Value.length > maxLength) {
                            maxLength = iFilter[key].Value.length
                        }
                    }

                    if (maxLength >= 3) {
                        iFilter[columnName] = {};
                        iFilter[columnName].Value = tmpVal;
                        iFilter[columnName].Unique = Bool(blUnique);
                        this.Properties.Filter.FilterOn = true;
                    }
                    else {
                        if (iFilter !== undefined && iFilter[columnName] != undefined)
                            delete iFilter[columnName];
                    }
                }
            },
            /*Function 
            * Turns alternating row styles on or off
            */
            UseAltStyles: function (blAltStyles) {
                ///<param name="blAltStyles">Bool true / false</param>
                this.Properties.UseAltStyles = Bool(blAltStyles);
            },
            /*Function 
            * Turns row hover on / off
            */
            HighlightRowOnHover: function (blHighlight) {
                ///<param name="blHighlight">Bool true / false</param>
                this.Properties.HighlightRowOnHover = Bool(blHighlight);
            },
            /*Function 
            * Turns Indexing on if a key is provided.
            */
            setIndexingKey: function (key) {
                ///<param name="key">Primary key used for filtering</param>
                if (!isNullOrEmpty(key)) {
                    this.Properties.Indexing.Set(key);
                }
            },
            Properties: {
                __hideNullValues: false,
                __Data: null,
                setData: function (objData) {
                    ///<param name="objData">The data being set</param>
                    this.__Data = objData;
                },
                getData: function () {
                    return this.__Data;
                },
                /*Variable - depricated
                *Use setId instead to set the table Id.
                */
                Id: null,
                AddFilterBox: false,
                FilterBoxMin: null,
                FilterBoxLabel: null,
                //Total Number of columns in the table
                TColumns: 0,
                //Total Number of Rows in the table
                TRows: 0,
                //The Total Results for the table
                TResults: 0,
                //The Total Number of Event Buttons Added
                TButtons: 0,
                //The Total Results returned in the search
                TSearchResults: 0,
                //true/false : If you want to alternate row style colors
                UseAltStyles: false,
                //true/false : If you want to add row hover styles
                HighlightRowOnHover: false,
                //true/false : If you want to expand row on click
                ExpandRowOnClick: false,
                //function to get expanded row content
                ExpandRowContentFunc: null,
                //data to send to content function
                ExpandRowColumnName: null,
                //true/false : If you want to add cell hover style
                HighlightCellOnHover: false,
                //Add indexing for auto updating tables
                Indexing: {
                    Set: function (iName) {
                        ///<param name="iName">Data Column Name</param>
                        if (isNullOrEmpty(iName))
                            this.On = false
                        else {
                            this.IndexName = iName;
                            this.On = true;
                        }

                    },
                    /*Bool true/false
                    *used if you want to cache your results.
                    */
                    __cacheResults: false,
                    cacheResults: function (cache) {
                        this.__cacheResults = Bool(cache);
                    },
                    On: false,
                    /*Index name refers to the data column name
                    *DO NOT CALL Directly.  Use Indexing.On
                    */
                    IndexName: null,
                    /*Value refers to the unique identifer need for indexing
                    *DO NOT CALL Directly.  Use Indexing.On
                    */
                    IndexValue: null
                },                
                Header: {
                    //this hides the entire header row.
                    HideHeaderRow: false,
                    //this holds the entire header collection in an associative array for later retrieval.
                    Collection: new Array(),
                    //Clears out the Header Collection
                    newCollection: function () {
                        this.Collection = new Array();
                        this.displayOrder = new Array();
                    },
                    displayOrder: new Array(),
                    GetDisplayOrderArray: function () {
                        return this.displayOrder;
                    },
                    __freezeHeader: false,
                    __freezeHeaderHeight: null,
                },
                /*Filter Object
                *Add Filter Column ames and their Values
                */
                Filter: {
                    /*Private Bool
                    *Internal Bool value for turning filtering on or off
                    */
                    FilterOn: false,
                    /*Private Object
                    *Stores filter information
                    */
                    objFilter: {}
                },
                //These are the style defaults for the entire table.
                Styles: {
                    Header: {
                        //The style for the entire header row.
                        Row: "rowHeader",
                        //The style for the headers per cell.
                        Cell: "cellHeader"
                    },

                    Cell: {
                        //Default Data Cell style
                        Default: "cell",
                        //Alternating Data Cell Style.  UseAltStyles must be true
                        AltStyle: "altCell",
                        //Data Cell(s) highlight individually. HighlightCellOnHover must be true
                        ClickStyle: "cellHighlight",
                        //Alternating Data Cell Style.  UseAltStyles must be true and HighlightCellOnHover must be true
                        AltClickStyle: "altCellHighlight"
                    },

                    Row: {
                        //Default Row Style
                        Default: "dataRow",
                        //Alternating Data Row Style.  UseAltStyles must be true
                        AltStyle: "altDataRow",
                        //Row(s) highlight.  HighlightRowOnHover must be true
                        ClickStyle: "dataRowHighlight",
                        //Row(s) highlight.  HighlightRowOnHover must be true and UseAltStyles must be true
                        AltClickStyle: "altDataRowHighlight"
                    },

                    Table: {
                        //Default table style
                        Default: "dataTable"
                    }
                },

                //The Button Object sets the default for All buttons
                __fnButtonProperties: function () {
                    var Button = {
                        //Denotes the data column name used for event processing
                        ColumnName: null,
                        //Denotes the data column value used for event processing
                        value: null,
                        //Is the unique button id
                        id: null,
                        //Add an exising function. i.e. (SomeFunc(this, params))
                        OnClickFunction: null,
                        //This is the button name.  Default value is Function
                        ButtonName: "Function",
                        type: 'standard',
                        caption: null,
                        rules: null
                    }

                    return Button;
                },
                /*Object 
                /*The Buttons Object contains ALL Buttons added
                *for that particular table being created.
                */
                Buttons: {},
                RowEvent:
                {
                    On: false,
                    ColumnName: "",
                    OnClickFunction: ""
                },
                __fnGetTableIndex: function () {
                    /* Private Object
                    * This is used to index rows for data for easy updates
                    */
                    var TableIndexObj = {
                        objRows: {
                            /*Bool (true/false)
                            *Verifies that the data row still exist in the database.
                            *true : Row Renders in table
                            *false : Row is hidden in the table
                            */
                            RowExist: true,
                            /*Guid
                            *This MUST have a unique key from the database in order to sync up the
                            *key with the row.  Will make updating the data object faster.
                            */
                            RowId: null,
                            /*Private int
                            *The row number itself.
                            */
                            RowNum: 0,
                            /*bool (true/false)
                            *Denotes if there are any changes in the row
                            */
                            hasChanges: false,
                            /*Object
                            *This stores key value pairs for each rows data cell
                            */
                            objRow: {}
                        },
                        /*Private object
                        *Contains all data from the Data Object rearranged into Rows
                        *with additional properties used in indexing.
                        */
                        IndexedTables: {},
                        /*Private Function
                        *Adds a Row to the Rows Object
                        */
                        InsertRow: function (tableId, guidKey, pvtRows) {
                            ///<param name="tableId">Must be the tableId</param>
                            ///<param name="guidKey">A primary key to test values</param>
                            ///<param name="pvtObj">clonedObj from TableIndexObj.pvtObj</param>
                            if (isNullOrEmpty(tableId) || isNullOrEmpty(guidKey) || guidKey == newGuid)
                                return false;

                            this.IndexedTables[tableId] = {
                                guidKey: objRows,
                                RowNum: Object.size(this.IndexedTables[tableId])
                            };
                        }
                    };

                    return TableIndexObj;
                }
            },
            /*Function returns void
            *Inserts a new blank column into the table
            */
            insertNewColumn: function (colName, afterColumn) {
                var irowCount = 0;
                var self = this;

                $('#' + this.getId()).find('[colname="' + afterColumn + '"]').each(function () {
                    var iLoc = this.id.split('_');
                    var cCol = parseInt(iLoc[2].split('')[3]) + 1;
                    var cRow = parseInt(iLoc[2].split('')[1]);
                    var cellId = self.getId() + '_r' + cRow + '_c' + cCol;

                    if (irowCount == 0) {
                        var ith = controlBuilder.create(cellId, 'th', { "colname": colName, "class": "cellHeader" });
                        $(ith).html(colName);
                        $(ith).insertAfter($(this));

                    }
                    else {
                        var itd = controlBuilder.create(cellId, 'td', { "colname": colName, "class": "cell" });
                        $(itd).insertAfter($(this));
                    }

                    irowCount++;
                });
            },
            ParseData: function () {
                var iTableId = this.Properties.Id;
                var iData = this.Properties.getData();
                var iCollection = this.Properties.Header.Collection;
                var iTIndex = this.Properties.__fnGetTableIndex();

                if (!isNullOrEmpty(iTableId)) {
                    var pvtTableIndexing = {};
                    var tableId = iTableId;

                    if (this.Properties.Indexing.On) {
                        var iIndexedTables = this.Properties.Indexing

                        if (globalvars.IndexedTables !== undefined && globalvars.IndexedTables[tableId] !== undefined
                            && !isNullOrEmpty(globalvars.IndexedTables[tableId])) {

                            iTIndex.IndexedTables = {};

                            if (!this.Properties.Indexing.__cacheResults)
                                iTIndex.IndexedTables[tableId] = {};
                            else
                                iTIndex.IndexedTables[tableId] = globalvars.IndexedTables[tableId];
                        }
                        else {
                            iTIndex.IndexedTables = {};
                            iTIndex.IndexedTables[tableId] = {};
                        }
                    }
                    else if (globalvars.IndexedTables !== undefined && !isNullOrEmpty(globalvars.IndexedTables) &&
                        !isNullOrEmpty(globalvars.IndexedTables[tableId])) {
                        globalvars.IndexedTables[tableId] = null;
                    }

                    var iIndexName = this.Properties.Indexing.IndexName;
                    var iTableIndexing = iTIndex.IndexedTables[tableId];

                    if (iData != null) {
                        var iRowCount = 1;
                        for (var dataRow in iData) {
                            var tmpRowObj = iData[dataRow];

                            if (tmpRowObj[iIndexName] != undefined && iTableIndexing[(tmpRowObj[iIndexName])] === undefined)
                                iTableIndexing[(tmpRowObj[iIndexName])] = this.Properties.__fnGetTableIndex().objRows;

                            var iRow = iTableIndexing[(tmpRowObj[iIndexName])];
                            iRow.RowId = tableId + "_r" + iRowCount;
                            iRow.RowNum = iRowCount;
                            iRow.RowExist = true;
                            iRow.objRow = tmpRowObj;

                            iRowCount++;
                        }

                        if (globalvars.IndexedTables === undefined)
                            globalvars.IndexedTables = {};

                        globalvars.IndexedTables[tableId] = iTableIndexing;
                        if (iCollection["__type"] != undefined)
                            iCollection["__type"].HideColumn = true;
                    }
                }
            },
            /*Function
            *Used to Call/Assign Table specific styles
            */
            TableStyles: function () {
                return this.Properties.Styles.Table;
            },
            /*Function
            *Used to turn the filterbox feature on / off
            */
            AddFilterBox: function (blAdd) {
                ///<param name="blAdd">true / false if you want to add a filter box</param>
                this.Properties.AddFilterBox = Bool(blAdd);
            },
            /*Public Function
            *Adds a row event
            */
            addRowEvent: function (columnName, onClickFunction) {
                ///<param name="columnName">Data column name that stores the PK value</param>
                ///<param name="onClikcFunction">The onClickFunction being called.</param>
                if (!isNullOrEmpty(columnName) && !isNullOrEmpty(onClickFunction)) {
                    var rowEvents = this.Properties.RowEvent;
                    rowEvents.On = true;
                    rowEvents.ColumnName = columnName;
                    rowEvents.OnClickFunction = onClickFunction;
                }
            },
            Create: function (containerID) {
                ///<param name="containerID">This is the id for the container where the table will be rendered. Leave null if you want the table object returned instead</param>
                this.ParseData();
                var iProperties = this.Properties;
                var iTableId = iProperties.Id;
                var iStyles = iProperties.Styles;
                var iHeaders = iProperties.Header;

                var tmpRowDetails = null;
                if (globalvars.IndexedTables != undefined) {
                    tmpRowDetails = globalvars.IndexedTables[iTableId];
                }
                else {
                    tmpRowDetails = this.Properties.getData();
                }

                var hasData = false;
                for (var key in tmpRowDetails) {
                    hasData = true;
                }

                if (!hasData)
                    tmpRowDetails = null;

                if (tmpRowDetails != null) {
                    var dataObj = tmpRowDetails;

                    this.TResults = Object.size(dataObj);
                    this.TSearchResults = 0;

                    var strHtmlTable = '';
                    var objContainer = null;
                    var objTable = null;

                    if (dataObj != undefined && !isNullOrEmpty(dataObj) && !isNullOrEmpty(iTableId)) {
                        objContainer = document.createElement('div');
                        objTable = document.createElement("table");
                        objContainer.appendChild(objTable);
                        objTable.id = iTableId;

                        objTable.className = iStyles.Table.Default;

                        var objTbo = document.createElement('tbody');

                        var strHeader = '';
                        var iRowCount = 0;

                        //Start Building The Headers --------------------------------------------------------------------------------------------------------------------------
                        var iColumn = 0;
                        var objTableHead = document.createElement("thead");

                        var objHeadRow = document.createElement("tr");
                        objHeadRow.id = iTableId + "_r" + iRowCount;

                        objHeadRow.className = iStyles.Header.Row;

                        var blHideColumn = false;


                        //var tmpHeaderCollection = cloneObj(iHeaders.Collection);


                        var headerDisplayOrder = iProperties.Header.GetDisplayOrderArray();

                        for (var i = 0; i < headerDisplayOrder.length; i++) {
                            var key = headerDisplayOrder[i];

                            if (iHeaders.Collection[key] != undefined)
                                blHideColumn = (iHeaders.Collection[key].HideColumn ? true : false);
                            else
                                blHideColumn = this.__disableColumnDetect;

                            var tmpDisplayName = '';
                            var strDisplayName = '';

                            if (typeof iHeaders.Collection[key] != 'undefined') {
                                if (iHeaders.Collection[key].DisplayName !== null)
                                    tmpDisplayName = iHeaders.Collection[key].DisplayName;
                                else
                                    tmpDisplayName = key.replace(/([A-Z])/g, ' $1').replace(/^./, function (str) { return str.toUpperCase(); }).replace(/([A-Z]) /g, '$1')

                                strDisplayName = tmpDisplayName;
                            }

                            var tmpId = iTableId + '_r' + iRowCount + 'c' + iColumn;

                            if (!blHideColumn) {
                                var objTH = document.createElement("th");
                                objTH.id = tmpId;
                                objTH.setAttribute('colname', key);
                                objTH.className = iStyles.Header.Cell;
                                objTH.appendChild(document.createTextNode(strDisplayName));
                                objHeadRow.appendChild(objTH);

                                iColumn++;
                            }
                        }
                        //if (iProperties.Buttons.length > 0) {
                        //    var objTH = document.createElement("th");
                        //    objTH.setAttribute('colname', 'tableButtonsHeader');
                        //    objTH.className = iStyles.Header.Cell;
                        //    objHeadRow.appendChild(objTH);
                        //}

                        if (!this.Properties.Header.HideHeaderRow) {
                            objTableHead.appendChild(objHeadRow);
                            objTable.appendChild(objTableHead);

                            iRowCount++;
                            strHeader = '';
                        }
                        //End Building The Headers --------------------------------------------------------------------------------------------------------------------------

                        var curStyle = null;
                        for (rdKey in tmpRowDetails) {
                            if (globalvars.IndexedTables[iTableId][rdKey].RowExist) {

                                iColumn = 0;
                                var tmpRowObj = tmpRowDetails[rdKey].objRow;

                                if (iProperties.HighlightRowOnHover)
                                    iProperties.HighlightCellOnHover = false;

                                if (isNullOrEmpty(curStyle)) {
                                    if (iProperties.HighlightRowOnHover)
                                        curStyle = iStyles.Row.ClickStyle;
                                    else
                                        curStyle = iStyles.Row.Default;
                                }
                                else {
                                    if (iProperties.UseAltStyles && !iProperties.HighlightRowOnHover) {
                                        curStyle = (curStyle == iStyles.Row.Default ? iStyles.Row.AltStyle : iStyles.Row.Default);
                                    }
                                    else if (iProperties.UseAltStyles && iProperties.HighlightRowOnHover) {
                                        curStyle = (curStyle == iStyles.Row.ClickStyle ? iStyles.Row.AltClickStyle : iStyles.Row.ClickStyle);
                                    }
                                }

                                var objDatarow = document.createElement("tr");
                                objDatarow.id = tmpRowDetails[rdKey].RowId;
                                objDatarow.className = curStyle;

                                var blFound = true;
                                var blUnique = false;

                                if (this.Properties.Filter.FilterOn) {
                                    for (key in tmpRowObj) {
                                        var blFound = true;
                                        for (filterKey in this.Properties.Filter.objFilter) {
                                            if (tmpRowObj[filterKey] != undefined) {
                                                if (iProperties.Filter.objFilter[filterKey].Unique) {
                                                    if (tmpRowObj[filterKey].toLowerCase() == iProperties.Filter.objFilter[filterKey].Value.toLowerCase())
                                                        blUnique = true;
                                                    else {
                                                        if (tmpRowObj[filterKey].toLowerCase().indexOf(iProperties.Filter.objFilter[filterKey].Value.toLowerCase()) == -1) {
                                                            blFound = false;
                                                        }
                                                        else {
                                                            blfound = true;
                                                        }
                                                    }
                                                }
                                                else if (tmpRowObj[filterKey].toLowerCase().indexOf(iProperties.Filter.objFilter[filterKey].Value.toLowerCase()) == -1) {
                                                    blFound = false
                                                }
                                            }
                                        }
                                    }
                                }

                                if (blUnique)
                                    blFound = blUnique;

                                var aryRowObject = new Array();

                                for (dataCell in tmpRowObj) {
                                    if (iHeaders.Collection[dataCell] !== undefined) {
                                        //Cell Begins
                                        var objCell = document.createElement("td");
                                        objCell.id = iTableId + "_r" + tmpRowDetails[rdKey].RowNum + "_c" + iColumn;
                                        objCell.setAttribute('colname', dataCell);

                                        var curCellStyle = "";
                                        if (isNullOrEmpty(curCellStyle)) {
                                            if (iProperties.HighlightCellOnHover)
                                                curCellStyle = iStyles.Cell.ClickStyle;
                                            else
                                                curCellStyle = iStyles.Cell.Default;
                                        }
                                        else {
                                            if (iProperties.UseAltStyles && !iProperties.HighlightCellOnHover) {
                                                curCellStyle = (curCellStyle == iStyles.Cell.Default ? iStyles.Cell.AltStyle : tableHelper.Styles.Cell.Default);
                                            }
                                            else if (iProperties.UseAltStyles && iProperties.HighlightCellOnHover) {
                                                curCellStyle = (curCellStyle == iStyles.Cell.ClickStyle ? iStyles.Cell.AltClickStyle : tableHelper.Styles.Cell.ClickStyle);
                                            }
                                        }

                                        objCell.className = curCellStyle;
                                        blHideColumn = (iHeaders.Collection[dataCell].HideColumn ? true : false);

                                        if (!blHideColumn) {
                                            if (dataCell.toLowerCase() == "control") {
                                                var blAddButtons = false;

                                                if (iProperties.TButtons > 0) {
                                                    for (var button in iProperties.Buttons) {
                                                        var include = true;
                                                        for(key in iProperties.Buttons[button].ButtonRules) {
                                                            if (tmpRowObj[key].toString() != iProperties.Buttons[button].ButtonRules[key].toString()) {
                                                                include = false;
                                                                break;
                                                            }
                                                        }
                                                        if (include) {
                                                            var btnObj = null;
                                                            btnObj = document.createElement("button");
                                                            btnObj.type = "button";
                                                            btnObj.id = iTableId + "_" + button + "_r" + tmpRowDetails[rdKey].RowNum + "_c" + iColumn;
                                                            btnObj.setAttribute("datacolumn", iProperties.Buttons[button].ColumnName);
                                                            btnObj.setAttribute("datavalue", tmpRowObj[iProperties.Buttons[button].ColumnName]);
                                                            btnObj.setAttribute("title", isNullOrEmpty(iProperties.Buttons[button].ButtonCaption) ? iProperties.Buttons[button].ButtonName : iProperties.Buttons[button].ButtonCaption);
                                                            switch (iProperties.Buttons[button].type) {
                                                                case 'standard':
                                                                    $(btnObj).html(isNullOrEmpty(iProperties.Buttons[button].ButtonCaption) ? iProperties.Buttons[button].ButtonName : iProperties.Buttons[button].ButtonCaption);
                                                                    break;
                                                                default:
                                                                    btnObj.value = '';
                                                                    $(btnObj).html('<span class="glyphicon glyphicon-' + iProperties.Buttons[button].type + '" />');
                                                                    //                                                                btnObj.clas = 'width: 0px !important; height: 0px !important; border-style: solid !important; border-width: 0 25px 25px 25px !important; border-color-right: transparent !important; border-color-left: transparent !important; border-color-top: transparent !important;';
                                                                    //$(btnObj).css('width', '0px !important');
                                                                    //$(btnObj).css('height', '0px !important');
                                                                    //$(btnObj).css('border-style', 'solid !important');
                                                                    //$(btnObj).css('border-width', '0 25px 25px 25px !important');
                                                                    //$(btnObj).css('border-color-right', 'transparent !important');
                                                                    //$(btnObj).css('border-color-left', 'transparent !important');
                                                                    //$(btnObj).css('border-color-top', 'transparent !important');
                                                                    //$(btnObj).css('-webkit-transform', 'rotate(360deg) !important');
                                                                    break;
                                                            }

                                                            if (typeof this.Properties.Buttons[button].OnClickFunction === 'function') {
                                                                var __this = this;
                                                                $(btnObj).click(__this.Properties.Buttons[button].OnClickFunction);
                                                            }
                                                            else if (!isNullOrEmpty(this.Properties.Buttons[button].OnClickFunction)) {
                                                                btnObj.setAttribute("onclick", this.Properties.Buttons[button].OnClickFunction);
                                                            }

                                                            objCell.appendChild(btnObj);

                                                        }
                                                        blAddButtons = true;
                                                    }

                                                    if (blAddButtons) {
                                                        aryRowObject[iHeaders.Collection[dataCell].displayOrder] = objCell;
                                                        $(objCell).css('text-align', 'right');
                                                    }
                                                }
                                            }
                                            else {
                                                var value = tmpRowDetails[rdKey].objRow[dataCell];

                                                if (value instanceof Date) {
                                                    var showTime = isNullOrEmpty(iHeaders.Collection[dataCell].showTime) ? false : iHeaders.Collection[dataCell].showTime;
                                                    if (showTime)
                                                        value = value.format('mm/dd/yyyy  h:MM TT');
                                                    else
                                                        value = value.format('mm/dd/yyyy');
                                                }

                                                if (this.nullValuesHidden()) {
                                                    var tmpVal = (isNullOrEmpty(value) ? '' : value);

                                                    objCell.appendChild(document.createTextNode(tmpVal));
                                                }
                                                else
                                                    objCell.appendChild(document.createTextNode(value));

                                                aryRowObject[iHeaders.Collection[dataCell].displayOrder] = objCell;
                                                iColumn++;
                                            }
                                        }
                                        else {
                                            aryRowObject[iHeaders.Collection[dataCell].displayOrder] = null;
                                        }
                                        //Cell ENDs
                                    }
                                }
                                if (this.Properties.ExpandRowOnClick == true) {
                                    this.Properties.RowEvent.On = true;
                                    iProperties.RowEvent.ColumnName = this.Properties.ExpandRowColumnName;
                                    var __this = this;
                                    this.Properties.RowEvent.OnClickFunction = function () {
                                        var objExpandRow = null;
                                        var objExpandCell = null;
                                        var rowID = $('tr[datavalue="' + $(this).GetObjectAttribute("datavalue") + '"]').attr('id') + '_expand';
                                        if ($('#' + rowID).length > 0) {
                                            objExpandRow = $('#' + rowID)[0];
                                            objExpandCell = $('#' + rowID).find('td')[0];
                                        }
                                        else {
                                            objExpandRow = document.createElement('tr');
                                            objExpandRow.id = rowID;
                                            objExpandRow.className = 'rowExpand';
                                            objExpandCell = document.createElement('td');
                                            objExpandCell.id = rowID + '_cellexpand';
                                            //objExpandCell.className = curCellStyle;
                                            objExpandCell.setAttribute('colspan', (iColumn + (iProperties.TButtons > 0 ? 1 : 0)));
                                            objExpandRow.appendChild(objExpandCell);
                                            objExpandRow.style.display = 'none';
                                            $(objExpandCell).append(__this.Properties.ExpandRowContentFunc($(this).GetObjectAttribute("datavalue")))
                                            $('tr[datavalue="' + $(this).GetObjectAttribute("datavalue") + '"]').after($(objExpandRow));
                                        }
                                        if ($(objExpandRow).is(':visible')) {
                                            //alert('visible, so hide');
                                            $(objExpandRow).hide();
                                        }
                                        else {
                                            //alert('not visible, so show');
                                            $('.rowExpand').hide();
                                            $(objExpandCell).html('');
                                            $(objExpandCell).append(__this.Properties.ExpandRowContentFunc($(this).GetObjectAttribute("datavalue")))
                                            $(objExpandRow).slideDown();
                                        }
                                    };
                                }
                                if (this.Properties.RowEvent.On == true) {
                                    objDatarow.setAttribute("datacolumn", iProperties.RowEvent.ColumnName);
                                    objDatarow.setAttribute("datavalue", tmpRowObj[iProperties.RowEvent.ColumnName]);
                                    if (typeof this.Properties.RowEvent.OnClickFunction === 'function') {
                                        var __this = this;
                                        $(objDatarow).click(__this.Properties.RowEvent.OnClickFunction);
                                    }
                                    else
                                        objDatarow.setAttribute("onclick", this.Properties.RowEvent.OnClickFunction);
                                }

                                if (blFound) {
                                    iProperties.TSearchResults += 1;

                                    for (var i = 0; i < aryRowObject.length; i++) {
                                        if (aryRowObject[i] != null)
                                            objDatarow.appendChild(aryRowObject[i]);
                                    }

                                    objTbo.appendChild(objDatarow);
                                    iRowCount++;
                                }

                                globalvars.IndexedTables[iTableId][rdKey].RowExist = false;
                            }
                        }
                        objTable.appendChild(objTbo);
                        if (this.Properties.AddFilterBox) {
                            if (isNullOrEmpty(iProperties.FilterBoxMin))
                                $(objTable).filterTable({ label: isNullOrEmpty(iProperties.FilterBoxLabel) ? 'Search:' : iProperties.FilberBoxLabel, minRows: 8 });
                            else
                                $(objTable).filterTable({ label: isNullOrEmpty(iProperties.FilterBoxLabel) ? 'Search:' : iProperties.FilberBoxLabel, minRows: iProperties.FilterBoxMin });
                        }
                    }

                    $(objContainer).find('button, input[type="button"], input[type="submit"]').addClass('btn').addClass('btn-primary').addClass('btn-large').css('margin-left', '5px');

                    if (isNullOrEmpty(containerID))
                        return objContainer;
                    else {
                        document.getElementById(containerID).innerHTML = '';

                        if (objContainer != null)
                            document.getElementById(containerID).appendChild(objContainer);
                    }

                    if (this.hasFrozenHeader()) {
                        var height = 500;
                        if (this.getFreezeHeaderHeight() != null) {
                            height = this.getFreezeHeaderHeight();
                        }
                        $('#' + iTableId).parent().addClass('fixed-table');
                        $('<style type="text/css"></style>').html('.fixed-table .header-fixed { ' +
                        '        position: absolute;' +
                        '    top: 0px;' +
                        '    z-index: 935; /* 10 less than .navbar-fixed to prevent any overlap */' +
                        '    border-bottom: 2px solid #d5d5d5;' +
                        '    -webkit-border-radius: 0;' +
                        '    -moz-border-radius: 0;' +
                        '    border-radius: 0;' +
                        '}' +
                        '.fixed-table{' +
                        '    display:block;' +
                        '    position:relative;' +
                        '}' +
                        '.fixed-table .table-content{' +
                        '    display:block;' +
                        '    position: relative;' +
                        '    height: ' + height + 'px; /*FIX THE HEIGHT YOU NEED*/' +
                        '    overflow-y: auto;' +
                        '}' +
                        '.fixed-table .header-copy{' +
                        '    position:absolute;' +
                        '    top:0;' +
                        '    left:0;' +
                        '}').appendTo("head");
                        $('#' + iTableId).wrap('<div class="table-content" style="width:100%"></div>');
                        $('#' + iTableId).fixedHeader((this.Properties.AddFilterBox && tmpRowDetails.length > (isNullOrEmpty(iProperties.FilterBoxMin) ? 8 : iProperties.FilterBoxMin))  ? 40 : 0);
                    }
                }
                else {
                    //Here is where we would want to render the columns.
                    //The bigger issue is that setdata is clearing out the column headers resulting
                    //in no data.
                    this.TResults = 0;
                    this.TSearchResults = 0;

                    var strHtmlTable = '';
                    var objContainer = null;
                    var objTable = null;

                    if (document.getElementById('tblHelper_Container_' + isNull(containerID, iTableId)) != null)
                        controlBuilder.remove('tblHelper_Container_' + isNull(containerID, iTableId));

                    objContainer = document.createElement('div');
                    objContainer.id = 'tblHelper_Container_' + isNull(containerID, iTableId);

                    objTable = document.createElement("table");
                    objTable.id = iTableId;

                    objTable.className = iStyles.Table.Default;

                    var objTbo = document.createElement('tbody');

                    var strHeader = '';
                    var iRowCount = 0;

                    //Start Building The Headers --------------------------------------------------------------------------------------------------------------------------
                    var iColumn = 0;
                    var objTableHead = document.createElement("thead");

                    var objHeadRow = document.createElement("tr");
                    objHeadRow.id = iTableId + "_r" + iRowCount;

                    objHeadRow.className = iStyles.Header.Row;

                    var blHideColumn = false;

                    var headerDisplayOrder = iProperties.Header.GetDisplayOrderArray();

                    for (var i = 0; i < headerDisplayOrder.length; i++) {
                        var key = headerDisplayOrder[i];

                        if (iHeaders.Collection[key] != undefined)
                            blHideColumn = (iHeaders.Collection[key].HideColumn ? true : false);

                        var tmpDisplayName = '';
                        var strDisplayName = '';

                        if (typeof iHeaders.Collection[key] != 'undefined') {
                            if (iHeaders.Collection[key].DisplayName !== null)
                                tmpDisplayName = iHeaders.Collection[key].DisplayName;
                            else
                                tmpDisplayName = key.replace(/([A-Z])/g, ' $1').replace(/^./, function (str) { return str.toUpperCase(); }).replace(/([A-Z]) /g, '$1')

                            strDisplayName = tmpDisplayName;
                        }

                        var tmpId = iTableId + '_r' + iRowCount + 'c' + iColumn;

                        if (!blHideColumn) {
                            var objTH = document.createElement("th");
                            objTH.id = tmpId;
                            objTH.setAttribute('colname', key);
                            objTH.className = iStyles.Header.Cell;
                            objTH.appendChild(document.createTextNode(strDisplayName));
                            objHeadRow.appendChild(objTH);

                            iColumn++;
                        }
                    }

                    if (!this.Properties.Header.HideHeaderRow) {
                        objTableHead.appendChild(objHeadRow);
                        objTable.appendChild(objTableHead);

                        iRowCount++;
                        strHeader = '';
                    }
                    //End Building The Headers --------------------------------------------------------------------------------------------------------------------------
              
                    var iNoResults = document.createElement('div');
                    iNoResults.id = 'div_TH_NoResults';
                    iNoResults.innerHTML = this.noResultsMessage;
                    objContainer.innerHTML = '';

                    objContainer.appendChild(objTable);
                    $(objContainer).find('#div_TH_NoResults').remove();
                    objContainer.appendChild(iNoResults);

                    $(objContainer).find('input[type="button"], input[type="submit"]').addClass('btn').addClass('btn-primary').addClass('btn-large').css('margin-left', '5px');

                    if (!isNullOrEmpty(containerID)) {
                        $('#' + containerID).html('');
                        document.getElementById(containerID).appendChild(objContainer);
                    }
                    else
                        return objContainer;
                }
            },
        }

        return obj;
    },
    /*Function
    *Easily create a new table programatically.
    */
    newTableBuilder: function (id, tableAttributeOptions) {
        ///<param name='id'>The id of the table if any</param>
        ///<param name='tableAttributeOptions'>Any attributes you want to add to your table.</param>
        var obj = {
            __properties: {
                id: null,
                rowDetails: new Array(),
                tableAttributeOptions: {},
                tableBodyOptions: {},
                spacerRowDefaults: {
                    options: {
                        'style':'height:10px;'
                    },
                    insertSpacerRow: true
                },
                spacerColumnDefaults: {
                    options: {
                        'style': 'width:10px;display:block;' //The block forces a spacer width
                    },
                    insertSpacerColumn:true
                }
            },
            /*Function
            *Overrides the current spacer column options
            */
            setSpacerColumnOptions: function (options, blClearCurrentOptions) {
                ///<param name='options'>This is an options object used for setting attributes for the spacer columns/(td tags)</param>
                ///<param name='blClearCurrentOptions'>Bool true/false - set to true if you want the current default values removed.  Set to false to append/overwrite.</param>
                
                if (Bool(blClearCurrentOptions))
                    this.__properties.spacerColumnDefaults.options = {};
                
                for (var opt in options) {
                    this.__properties.spacerColumnDefaults.options[opt] = options[opt];
                }
            },
            /*Internal Function
            *Retrieves the insertSpacerColumn value
            */
            __fnInsertSpacerColumn:function(){
                return Bool(this.__properties.spacerColumnDefaults.insertSpacerColumn);
            },
            /*Function
            *Automatically inserts a spacer column if set to true.  
            *Default: true
            */
            setInsertSpacerColumnOn: function (blOn) {
                this.__properties.spacerColumnDefaults.insertSpacerColumn = Bool(blOn);
            },
            /*Function
            *Overrides the current spacer column options
            */
            setSpacerRowOptions: function (options, blClearCurrentOptions) {
                ///<param name='options'>This is an options object used for setting attributes for the spacer rows/(td tags)</param>
                ///<param name='blClearCurrentOptions'>Bool true/false - set to true if you want the current default values removed.  Set to false to append/overwrite.</param>
                if (Bool(blClearCurrentOptions))
                    this.__properties.spacerRowDefaults.options = null;

                for (var opt in options) {
                    if (this.__properties.spacerRowDefaults.options === null)
                        this.__properties.spacerRowDefaults.options = {};

                    this.__properties.spacerRowDefaults.options[opt] = options[opt];
                }
            },
            /*Internal Function
            *Retrieves the insertSpacerRow value
            */
            __fnInsertSpacerRow:function(){
                return Bool(this.__properties.spacerRowDefaults.insertSpacerRow);
            },
            /*Function
            *Automatically inserts a spacer row if set to true.  
            *Default: true
            */
            setInsertSpacerRowOn:function(blOn){
                this.__properties.spacerRowDefaults.insertSpacerRow = Bool(blOn);
            },
            /*Function
            *Sets the id for the table.
            */
            getId: function () {
                return this.__properties.id;
            },
            /*Function
            *Sets the id for the table.
            */
            setId:function(id) {
                this.__properties.id = id;
            },
            /*Function
            *Gets the set ID of the Table
            */
            getId:function(){
                return this.__properties.id;
            },
            /*Functions
            *Gets the current table attribute options
            */
            getTableAttributeOptions:function(){
                return this.__properties.tableAttributeOptions;
            },
            /*Function
            *Sets the tables attributes
            */
            setTableAttributeOptions: function (options) {
                this.__properties.tableAttributeOptions = {};
                for (var key in options) {
                    this.__properties.tableAttributeOptions[key] = options[key];
                }
            },
            /*Function
            *Allows you to set attributes on the tbody tag
            */
            setTableBodyAttributeOptions: function (options) {
                for (var key in options) {
                    this.__properties.tableBodyOptions[key] = options[key];
                }                
            },
            /*Function
            *Gets the options for the tbody tag
            */
            getTableBodyAttributesOptions:function(){
                return this.__properties.tableBodyOptions;
            },
            /*Function
            *Returns the actual table object
            */
            Render: function () {
                var self = this;
                var iTable = controlBuilder.create(this.getId(), 'table', this.getTableAttributeOptions());
                var iTableBody = controlBuilder.create(this.getId() + '_tbody', 'tbody', '');

                for (var row in this.__properties.rowDetails) {
                    iTableBody.appendChild(this.__properties.rowDetails[row]);
                }

                iTable.appendChild(iTableBody);

                return iTable;
            },
            /*Function
            *
            *example:  var tc = tableHelper.newTableBuilder();
            *tc.newRow([tc.newColumn({ 'style': 'vertical-align:top' }, lblSearchFirstName, true), newColumn({'style':'vertical-align:top'}, txtSearchFirstName, true)]);
            */
            newHeaderRow: function (options, columnDetails, renderAsObject) {
                ///<param name='options'>This is the attribute options being added to the table row</param>
                ///<param name='columnDetails'>This will be an array of newTableBuilder.newColumn()</param>
                ///<param name='renderAsObject'>Bool true/false are you appending html (false) or an object (true)?</param>
                var iRow = controlBuilder.create(null, 'tr', options);
                var self = this;
                var blRowInserted = false;

                for (var i = 0; i < columnDetails.length; i++) {
                    if (Bool(renderAsObject)) {
                        if (typeof iRow.appendChild === 'function') {
                            iRow.appendChild(columnDetails[i]);
                        }
                        else {
                            //alert('error');
                        }
                    }
                    else {
                        $(iRow).html(columnDetails[i]);
                    }


                    if (self.__fnInsertSpacerColumn()) {
                        var iTdSpacer = controlBuilder.create(null, 'th', self.__properties.spacerColumnDefaults.options);
                        iRow.appendChild(iTdSpacer);
                    }

                    blRowInserted = true;
                }

                if (blRowInserted) {
                    this.__properties.rowDetails[this.__properties.rowDetails.length] = iRow;

                    if (self.__fnInsertSpacerRow() && this.__properties.rowDetails.length > 0) {
                        var iTrSpacer = controlBuilder.create(null, 'tr', {});
                        var iTdSpacer = controlBuilder.create(null, 'th', self.__properties.spacerRowDefaults.options);
                        iTrSpacer.appendChild(iTdSpacer);
                        this.__properties.rowDetails[this.__properties.rowDetails.length] = iTrSpacer;
                    }
                }
            },
            /*Function
            *
            *example:  var tc = tableHelper.newTableBuilder();
            *tc.newRow([tc.newColumn({ 'style': 'vertical-align:top' }, lblSearchFirstName, true), newColumn({'style':'vertical-align:top'}, txtSearchFirstName, true)]);
            */
            newRow: function (options, columnDetails, renderAsObject) {
                ///<param name='options'>This is the attribute options being added to the table row</param>
                ///<param name='columnDetails'>This will be an array of newTableBuilder.newColumn()</param>
                ///<param name='renderAsObject'>Bool true/false are you appending html (false) or an object (true)?</param>
                var iRow = controlBuilder.create(null, 'tr', options);
                var self = this;
                var blRowInserted = false;

                for (var i = 0; i < columnDetails.length; i++) {
                    if (Bool(renderAsObject))
                        iRow.appendChild(columnDetails[i]);
                    else
                        $(iRow).html(columnDetails[i]);


                    if (self.__fnInsertSpacerColumn()) {
                        var iTdSpacer = controlBuilder.create(null, 'td', self.__properties.spacerColumnDefaults.options);
                        iRow.appendChild(iTdSpacer);
                    }

                    blRowInserted = true;
                }

                if (blRowInserted) {
                    this.__properties.rowDetails[this.__properties.rowDetails.length] = iRow;

                    if (self.__fnInsertSpacerRow() && this.__properties.rowDetails.length > 0) {
                        var iTrSpacer = controlBuilder.create(null, 'tr', {});
                        var iTdSpacer = controlBuilder.create(null, 'td', self.__properties.spacerRowDefaults.options);
                        iTrSpacer.appendChild(iTdSpacer);
                        this.__properties.rowDetails[this.__properties.rowDetails.length] = iTrSpacer;
                    }
                }
            },
            /*Function
            *Creates a new table header tag
            */
            newTableHeader: function (options, details, renderAsObject) {
                ///<param name='options'>This is the attribute options being added to the table row</param>
                ///<param name='details'>This will be the items needed to be contained within the table data.</param>
                ///<param name='renderAsObject'>Bool true/false are you appending html (false) or an object (true)?</param>

                var iColumn = controlBuilder.create('', 'th', options);

                if (Bool(renderAsObject))
                    $(iColumn).append(details);
                else
                    $(iColumn).html(details);

                return iColumn;
            },
            /*Function
            *Creates a new td and returns as either html or as an object.
            */
            newColumn: function (options, details, renderAsObject) {
                ///<param name='options'>This is the attribute options being added to the table row</param>
                ///<param name='details'>This will be the items needed to be contained within the table data.</param>
                ///<param name='renderAsObject'>Bool true/false are you appending html (false) or an object (true)?</param>

                var iColumn = controlBuilder.create('', 'td', options);

                if (Bool(renderAsObject))
                    $(iColumn).append(details);
                else
                    $(iColumn).html(details);

                return iColumn;
            }
        }

        obj.setId(id);
        obj.setTableAttributeOptions(tableAttributeOptions);

        return obj;
    },
    /*Function
    *Returns the value of a particular cell in the table helper 
    *Requires the table to have been rendered.
    */
    getColumnValueByRowID: function (rowName, colName, tablename) {
        ///<param name="rowName">The row id for the row containing the cell you are trying to get the value of</param>
        ///<param name="colName">This is the colName for the column.</param>
        ///<param name="tablename">This is the name of the table helper table</param>
        var colCount = 0;
        var cellName = "";
        var rVal = null;

        if (!isNullOrEmpty(tablename) && document.getElementById(tablename) !== null) {
            rVal = $('#' + tablename).find('[id="' + rowName + '"]').find('[colname="' + colName + '"]').html();
        }
        else {

            if (document.getElementById(rowName) != null && !isNullOrEmpty(colName)) {
                cellName = rowName + "_c" + colCount;
                while (document.getElementById(cellName) != null) {
                    var tmpObj = $('#' + cellName);
                    var tmpDbCol = $('#' + cellName).attr('colname');

                    if (tmpDbCol == colName) {
                        rVal = $('#' + cellName).html();
                        break;
                    }

                    colCount++;
                    cellName = rowName + "_c" + colCount;

                    if (colCount >= 10)
                        break;
                }
            }
        }

        return rVal;
    },
    /*Function returns object
    *Returns a new table helper object
    */
    __newTableV2 :function(){
        var obj = {
            __properties: {
                id: null,
                tableOptions: {},
                dataSource: {
                    raw: new Array(),
                    list: new Array([]),
                    headers: {},
                    headerSort: new Array(),
                    sortedHeaders: new Array(),
                    lastModified: null,
                    hideNullValues: false,
                    hideHeaderRow: false,
                    customControls: {}
                },
                filter: {
                    label: 'Search',
                    minrows: 8,
                    FilterOn: false
                },
                rowClickOn:false,
                key: null,
                type: null,
                containerId: null,
                disbleColumnDetect: false,
                noResultMessage: 'No Results',
                //true/false : If you want to alternate row style colors
                UseAltStyles: false,
                //true/false : If you want to add row hover styles
                HighlightRowOnHover: false,
                //true/false : If you want to add cell hover style
                HighlightCellOnHover: false,
                //These are the style defaults for the entire table.
                Styles: {
                    Header: {
                        //The style for the entire header row.
                        Row: "rowHeader",
                        //The style for the headers per cell.
                        Cell: "cellHeader"
                    },
                    Cell: {
                        //Default Data Cell style
                        Default: "cell",
                        //Alternating Data Cell Style.  UseAltStyles must be true
                        AltStyle: "altCell",
                        //Data Cell(s) highlight individually. HighlightCellOnHover must be true
                        ClickStyle: "cellHighlight",
                        //Alternating Data Cell Style.  UseAltStyles must be true and HighlightCellOnHover must be true
                        AltClickStyle: "altCellHighlight"
                    },

                    Row: {
                        //Default Row Style
                        Default: "dataRow",
                        //Alternating Data Row Style.  UseAltStyles must be true
                        AltStyle: "altDataRow",
                        //Row(s) highlight.  HighlightRowOnHover must be true
                        ClickStyle: "dataRowHighlight",
                        //Row(s) highlight.  HighlightRowOnHover must be true and UseAltStyles must be true
                        AltClickStyle: "altDataRowHighlight"
                    },
                    Table: {
                        //Default table style
                        Default: "dataTable"
                    }
                },
                ExpandRowOnClick: null,
                ExpandRowContentFunc: null,
                ExpandRowColumnName: null
            },
            /*Funciont return void
            *
            */
            setExpandedRow: function(columnName, ContentFunc){
                if (!isNullOrEmpty(columnName) && typeof ContentFunc === 'function') {
                    this.setExpandRowColumnName(columnName);
                    this.ExpandRowOnClick(true);
                    this.ExpandRowContentFunc(ContentFunc);
                }
            },
            /*Function returns void 
            *Sets the column key for the row Expansion
            */
            setExpandRowColumnName: function (colname) {
                ///<param name='colname'>The column key that will trigger the change event</param>
                if (!isNullOrEmpty(colname)) {
                    this.__properties.ExpandRowColumnName = colname;
                }
            },
            /*Function returns string
            *Gets the expand/collapse key
            */
            getExpandRowColumnName: function () {
                return this.__properties.ExpandRowColumnName;
            },
            /*Function returns void
            *Sets the function for the Row Expand/Collapse
            */
            ExpandRowContentFunc: function (Func) {
                ///<param name="Func">The function to call for expand/collapse</param>
                if (typeof Func == 'function')
                    this.__properties.ExpandRowContentFunc = Func;
            },
            /*Function returns void
            *Toggles the rows expand/collapse feature.
            */
            ExpandRowOnClick: function (blOn) {
                ///<param name="blOn">Bool true/false</param>
                this.__properties.ExpandRowOnClick = Bool(blOn);
            },
            /*Function returns bool
            *Returns the current state for the expand/collapse row function.
            */
            isExpandRowOnClickOn: function () {
                return Bool(this.__properties.ExpandRowOnClick);
            },
            /*Function returns void
            *Turns on cell highlights and turns off row hightlights.
            */
            HighlightCellOnHover: function (blOn) {
                this.__properties.HighlightCellOnHover = Bool(blOn);
                this.__properties.HighlightRowOnHover = Bool(false);
            },
            /*Function returns void
            *Turns on Row Hightlights and turns off cell highlights.
            */
            HighlightRowOnHover: function (blOn) {
                this.__properties.HighlightRowOnHover = Bool(blOn);
                this.__properties.HighlightCellOnHover = Bool(false);
            },
            /*Function returns void
            *Turns on Alternat Row styles
            */
            useAltStyles: function (blOn) {
                ///<param name="blOn">Bool true/false - turn altStyles on/off</param>
                this.__properties.UseAltStyles = Bool(blOn);
            },
            /*Function returns bool
            *Returns true/false based on the current state of alter Row Styles
            */
            altStylesOn: function () {
                return Bool(this.__properties.UseAltStyles);
            },
            /*Function returns bool
            *Returns the rowClickOn status
            */
            onRowClick :function(){
                return this.__properties.rowClickOn;
            },
            /*Function returns object
            *Returns the custom control object for the column name specified
            */
            getCustomControlByColname: function (colname) {
                ///<param name="colname">The name of the column currently being rendered.</param>
                var iCustControls = this.__properties.dataSource.customControls;
                var obj = null;

                if (iCustControls[colname] !== undefined)
                    obj = iCustControls[colname];

                return obj;
            },
            /*Function returns void
            *Adds a Custom Control to a column.
            *MUST be run after render
            */
            addCustomControl:function(colname, afterColumn, customFunction, headerData){
                ///<param name="colname">The column name is required and represent a new column to add the function control to.</param>
                ///<param name="afterColumn">The column to insert the new controls column</param>
                ///<param name="customFunction">The custom function represents the control creation needing to be run for each row</param>
                ///<param name="headerData">This is the newHeaderData object.</param>
                var custFunc = {};
                custFunc[colname] = {
                    custFunction: customFunction
                }

                if (this.__properties.dataSource.headers[colname] !== undefined && !isNullOrEmpty(headerData))
                    this.__properties.dataSource.headers[colname] = headerData;

                if (!isNullOrEmpty(colname) && !isNullOrEmpty(afterColumn)) {
                    if (!isNullOrEmpty(headerData))
                        this.insertNewColumn(colname, afterColumn);

                    $('#' + this.getTableId()).find('[colname="' + colname + '"]').each(function () {
                        var cellId = this.id;

                        if (!$('#' + cellId).hasClass('cellHeader')) {
                            custFunc[colname]["custFunction"](this);
                        }
                    });
                }
            },
            newCustControl: function () {
                var obj = {
                    element: null,
                    rules: null,
                    id: null,
                    custFunction: null
                };

                return obj;
            },
            /*Function returns void
            *Adds buttons to the table helper
            */
            AddButtons: function (buttonName, columnName, key, onClickFunction, type, caption, rules) {
                ///<param name="buttonName">This is the title attribute on the button. use buttonTypes object.</param>
                ///<param name="columnName">This is the new column being created.</param>
                ///<param name="key">This points the button to the data object being used as the key.</param>
                ///<param name="onClickFunction">The function to call on click.</param>
                ///<param name="type">User:  standard for a normal button or use buttonTypes</param>
                ///<param name="caption">The caption that appears on hover</param>
                ///<param name="rules">An object of data columns that must contain a value</param>
                var self = this;
                if (this.__properties.dataSource.list[0].length > 0) {
                    var iList = this.__properties.dataSource.list;
                    var iRowOne = this.__properties.dataSource.list[0]; //need to get a row so we can determine column locations
                    var iTotalCells = iRowOne.length - 1;
                    var iCustomControls = this.__properties.dataSource.customControls;

                    var iHeaderDetail = null;

                    if (iCustomControls[columnName] === undefined) {
                        iCustomControls[columnName] = {};

                        iHeaderDetail = this.newHeaderDataObject(columnName, false, iTotalCells + 1, true, 100);
                    }

                    var iAfter = iRowOne[iRowOne.length - 1].colname;

                    var elementType = "button";
                    var blStandard = true;

                    if (type == 'standard')
                        elementType = "button"
                    else if (type !== undefined) {
                        elementType = type;
                        blStandard = false;
                    }

                    //need to run a loop to create a button in every cell for the column
                    var custFunc = function (element) {
                        var tdElement = element;
                        if (!$(tdElement).hasClass('cellHeader')) {
                            var iParentRow = $(tdElement).attr('parentrow');
                            var iCell = $(tdElement).attr('cell');

                            var btnId = 'btn_' + $(tdElement).attr('colname') + "_" + iParentRow;

                            if (iCustomControls[columnName][btnId] === undefined)
                                iCustomControls[columnName][btnId] = self.newCustControl();

                            var iButton = null;

                            if (blStandard)
                                iButton = controlBuilder.create(btnId, "input", { type: 'button', 'caption': caption, value: buttonName, parentrow: iParentRow, "key": key });
                            else
                                iButton = controlBuilder.createGlyphButton(btnId, 'button', elementType, { 'caption': caption, value: buttonName, parentrow: iParentRow, "key" : key });

                            iCustomControls[columnName][btnId].id = btnId;
                            iCustomControls[columnName][btnId].element = iButton;
                            iCustomControls[columnName][btnId].custFunction = onClickFunction;
                            iCustomControls[columnName][btnId].rules = rules;

                            $(tdElement).append(iButton);

                            $(iButton).on('click', function () {
                                var element = this;
                                onClickFunction(this);
                                return false;
                            });

                            if (typeof rules == "object") {
                                for (key in rules) {
                                    var keyVal = self.getDataValueByRowAndColname(iParentRow, key);

                                    if (keyVal.toString() != rules[key].toString()) {
                                        $(iButton).hide();
                                    }
                                    else
                                        $(iButton).show();
                                }
                            }
                        }
                    };

                    this.addCustomControl(columnName, iAfter, custFunc, iHeaderDetail);
                }
            },            
            /*Function returns object
            *Returns a new header data object
            */
            newHeaderDataObject: function (displayName, hideColumn, defaultColumn, customColumn, colWidth) {
                ///<param name="displayName">Sets the display name for the column</param>
                ///<param name="hideColumn">Bool true/false - hide the column or not</param>
                ///<param name="defaultColumn">The default sort order of the column</param>
                ///<param name="customColumn">Bool true/false - determines if this is a custom column or one added from the web service</param>
                ///<param name="colWidth">The width of the column</param>
                var obj = this.__newHeaderData(displayName, hideColumn, defaultColumn, customColumn, colWidth);
                return obj;
            },
            /*Function returns void
            *Set the hideHeaderRow value
            */
            setHideHeaderRow:function(blHideHeaderRow)
            {
                ///<param name="blHideHeaderRow">Bool true/false - set to true to hide the header row</param>
                this.__properties.dataSource.hideHeaderRow = Bool(blHideHeaderRow);
            },
            /*Function returns bool
            *Returns the value of the hideHeaderRow
            */
            hideHeaderRow:function(){
                return Bool(this.__properties.dataSource.hideHeaderRow);
            },
            /*Function returns bool
            *Returns the current state of Hide Null Values
            */
            hideNullDataValues:function(){
                return Bool(this.__properties.dataSource.hideNullValues);
            }, 
            /*Function returns void
            *Controls whether or not you see a null or an empty value when the webservice returns null as a value
            */
            setHideNullValues:function(blHide){
                ///<param name="blHide">Bool true/false - set to true if you don't want null to appear in empty values</param>
                this.__properties.dataSource.hideNullValues = Bool(blHide);
            },
            /*Function returns void
            *Sets the noResultMessage
            */
            updateNoResultMessage: function(msg){
                ///<param name='msg'>The message you want to display when there are no results</param>
               this.__properties.noResultMessage = msg;               
            },
            /*Function returns string
            *Returns the current no result message
            */
            getNoResultMessage: function () {
                return this.__properties.noResultMessage;
            },
            /*Function returns void
            *Auto sets hide columns to true on data columns that were not added to the 
            *hide columns option.
            */
            disableColumnDetection: function (blEnabled) {
                ///<param name='blEnabled'>Bool true/false - true if disableColumnDetection is on</param>
                this.__properties.disbleColumnDetect = Bool(blEnabled);
            },
            /*Function returns bool
            *Returns the current status of disableColumnDetect
            */
            ColumnDetectDisabled: function () {
                return Bool(this.__properties.disbleColumnDetect);
            },
            /*Function returns void
            *Updates the Filter label
            */
            changeFilterLabel: function (label) {
                if (!isNullOrEmpty(label)) {
                    this.__properties.filter.label = label
                }
            },
            /*Function returns string
            *Gets the filter label
            */
            getFilterLabel: function () {
                return this.__properties.filter.label;
            },
            /*Function returns int
            *Returns the minium required search rows
            */
            getFilterMinRows: function () {
                return this.__properties.filter.minrows;
            },
            /*Function returns void
            *Sets the minimum required rows for the filter to be visible.
            */
            setMinRows: function (rows) {
                if (parseInt(rows)) {
                    this.__properties.filter.minrows = rows;
                }
            },
            /*Function
            *Turns the filter search on/off
            */
            setFilter: function (blFilterOn) {
                ///<param name="blFilterOn">Bool true / false - Turn on the filter search box</param>
                this.__properties.filter.FilterOn = Bool(blFilterOn);
            },
            /*Function returns bool
            *Returns the filter status
            */
            FilterIsOn: function () {
                return Bool(this.__properties.filter.FilterOn);
            },
            /*Function returns void
            *Set the it for the object being used to hold the table.
            */
            setContainerId: function (id) {
                ///<param name="id">The id of the containing element</param>
                if (!isNullOrEmpty(id))
                    this.__properties.containerId = id;
            },
            /*Function returns void
            *Set the attribute options for the table.
            */
            setTableOptions: function (options) {
                ///<param name="options">Object that contains a list of attributes and values to add to the table at creation time</param>
                if (typeof options === 'object')
                    this.__properties.tableOptions = options;
            },
            /*Function returns object
            *Returns the tables current option properties.
            */
            getTableOptions: function () {
                return this.__properties.tableOptions;
            },
            /*Function returns void
            *Sets the sort order of the table.
            */
            setSortOrder: function () {
                ///<param name="order">A comma delimited list of parameters.  ie: 'Col1', 'Col2', 'Col3', ...</param>
                var lstHeader = this.__properties.dataSource.headers;
                
                var cols = Array.prototype.slice.call(arguments, 0);

                for (var i = 0; i < cols.length; i++) {
                    if (lstHeader[i] === undefined)
                        lstHeader[i] = this.__newHeaderData(cols[i], false, i, false, null);
                    else
                        lstHeader[i].currentColumn = i;
                }
            },
            /*Function retutns void
            *Internal function that gets __type from the webservice call
            */
            __setTableType: function (type) {
                ///<param name="type">This is the __type from the webservice</param>
                if (!isNullOrEmpty(type)) {
                    this.__properties.type = type;
                }
            },
            /*Function returns void
            *Sets the tables primary key
            */
            setKey: function (key) {
                ///<param name="key">The primary key of the table.</param>
                if (!isNullOrEmpty(key))
                    this.__properties.key = key;
            },
            /*Function returns uniqueidentifier
            *Returns the tables primary key
            */
            getKey: function () {
                return this.__properties.key;
            },
            /*Function returns void
            *Sets the id of the table being created
            */
            setTableId: function (id) {
                ///<param name="id">The id for the created table</param>
                if (!isNullOrEmpty(id)) {
                    this.__properties.id = id;
                }
            },
            /*Function returns string
            *Returns the id for the given table.
            */
            getTableId: function () {
                return this.__properties.id;
            },
            /*Function returns object
            *Returns a new header data object
            */
            __newHeaderData: function (displayName, hideColumn, defaultColumn, customColumn, colWidth) {
                ///<param name="displayName">Sets the display name for the column</param>
                ///<param name="hideColumn">Bool true/false - hide the column or not</param>
                ///<param name="defaultColumn">The default sort order of the column</param>
                ///<param name="customColumn">Bool true/false - determines if this is a custom column or one added from the web service</param>
                ///<param name="colWidth">The width of the column</param>

                var obj = {
                    displayName: null,
                    hideColumn: false,
                    defaultColumn: null,
                    currentColumn: null,
                    customColumn: false,
                    width: null,
                    headerObject: null,
                    showTime: false
                }

                obj.displayName = displayName;
                obj.defaultColumn = defaultColumn;
                obj.customColumn = Bool(customColumn);
                if (!isNullOrEmpty(colWidth))
                    obj.width = parseInt(colWidth);

                return obj;
            },
            /*Function returns object
            *Returns a new cell data object
            */
            __newCellData: function (colname, colvalue) {
                ///<param name="colname">The name of the column being added</param>
                ///<param name="colvalue">The value of the column being added</param>

                var obj = {
                    colname: null,
                    colvalue: null,
                    colDisplayName: null
                }

                if (!isNullOrEmpty(colname))
                    obj.colname = colname;

                if (!isNullOrEmpty(colvalue))
                    obj.colvalue = colvalue;

                return obj;
            },
            /*Function returns void
            *set the data source to the list array coming from webservice
            */
            setDataSource: function (dataSource) {
                ///<param name="dataSource">List Array from the Webservice</param>
                if (!isNullOrEmpty(dataSource) && Object.prototype.toString.call(dataSource) === '[object Array]') {
                    this.__properties.dataSource.raw = dataSource;

                    var lm = this.__properties.dataSource.lastModified;
                    if (isNullOrEmpty(lm))
                        this.__properties.dataSource.lastModified = DateHelper.GetDateTime();
                    else {
                        this.render();
                    }
                }
            },
            /*function returns element
            *Returns the td element for the given column
            */
            getHeaderObjectByHeaderID: function (colname) {
                ///<param name="colname">The column name being called.</param>
                var element = null;
                if (!isNullOrEmpty(colname) && this.__properties.dataSource.headers[colname] !== undefined) {
                    element = this.__properties.dataSource.headers[colname].headerObj;
                }

                return element;
            },
            /*Function returns void
            *Converts a list of columns to a local date format
            */
            shortDate:function(){
                var cols = Array.prototype.slice.call(arguments, 0);
                for (key in cols)
                {
                    this.toShortDate(cols[key]);
                }
            },
            /*Function returns void
            *Converts a column to a local date format
            */
            toShortDate: function (colname) {
                ///<param name="colname">The name of the column needing to be converted to local date format.</param>
                var iHeaders = this.__properties.dataSource.headers;
                if(iHeaders[colname] !== undefined)
                {


                    if (!isNullOrEmpty(colname) && !isNullOrEmpty(this.getHeaderObjectByHeaderID(colname))) {
                        $('[colname="' + colname + '"]').each(function () {
                            if (!$(this).hasClass('cellHeader') && !isNullOrEmpty($(this).html()))
                                $(this).html(new Date($(this).html()).format('mm/dd/yyyy'));
                        });
                    }
                }
            },
            /*Function returns void
            *Converts a list of columns to a local date time format
            */
            shortDateTime: function () {
                var cols = Array.prototype.slice.call(arguments, 0);
                for (key in cols) {
                    this.toShortDateTime(cols[key]);
                }
            },
            /*Function returns void
            *Converts a column to a local date time format
            */
            toShortDateTime: function (colname) {
                ///<param name="colname">The name of the column needing to be converted to local date format.</param>
                var iHeaders = this.__properties.dataSource.headers;
                if (iHeaders[colname] !== undefined)
                {


                    if (!isNullOrEmpty(colname) && !isNullOrEmpty(this.getHeaderObjectByHeaderID(colname))) {
                        $('[colname="' + colname + '"]').each(function () {
                            if (!$(this).hasClass('cellHeader') && !isNullOrEmpty($(this).html()))
                                $(this).html(new Date($(this).html()).format('mm/dd/yyyy hh:MM TT'));
                        });
                    }
                }
            },
            /*Function returns void
            *Converts a list of columns to a local time format
            */
            shortTime: function () {
                var cols = Array.prototype.slice.call(arguments, 0);
                for (key in cols) {
                    this.toShortTime(cols[key]);
                }
            },
            /*Function returns void
            *Converts a column to a local time format
            */
            toShortTime: function (colname) {
                ///<param name="colname">The name of the column needing to be converted to local date format.</param>
                var iHeaders = this.__properties.dataSource.headers;
                if (iHeaders[colname] !== undefined)
                {


                    if (!isNullOrEmpty(colname) && !isNullOrEmpty(this.getHeaderObjectByHeaderID(colname))) {
                        $('[colname="' + colname + '"]').each(function () {
                            if (!$(this).hasClass('cellHeader') && !isNullOrEmpty($(this).html()))
                                $(this).html(new Date($(this).html()).format('hh:MM TT'));
                        });
                    }
                }
            },

            /*Function
            *Takes a list of column names and hides them.
            */
            hideColumns: function () {
                var cols = Array.prototype.slice.call(arguments, 0);
                for (key in cols) {
                    //this.hideColumn(cols[key], true);
                    this.hideColumnByColName(cols[key]);
                }
            },
            /*Function returns void
            *Hides a particular column from display
            */
            hideColumnByColName: function (colname) {
                ///<param name="colname">The name of the column needing to be hidden.</param>
                var iHeaders = this.__properties.dataSource.headers;

                if (iHeaders[colname] === undefined) {
                    iHeaders[colname] = this.__newHeaderData();
                    iHeaders[colname].displayName = colname;
                    iHeaders[colname].hideColumn = true;
                    iHeaders[colname].defaultColumn = colname;
                    iHeaders[colname].currentColumn = null;
                    iHeaders[colname].customColumn = false;
                    iHeaders[colname].width = null;
                    iHeaders[colname].headerObject = null;
                    iHeaders[colname].headerObj = null;
                }
                else {
                    if (!isNullOrEmpty(colname) && !isNullOrEmpty(this.getHeaderObjectByHeaderID(colname))) {
                        $('[colname="' + colname + '"]').each(function () {
                            $(this).attr('style', 'display:none');
                            iHeaders[colname].hideColumn = true;
                        });
                    }
                }
            },
            /*Function returns void
            *Sets the column width of a particular column
            */
            setColumnWidthByHeaderId: function (colname, colWidth, blPixel) {
                ///<param name="colname">The data column name</param>
                ///<param name="width">The width of the column</param>
                ///<param name="blPixel">bool true/false set to true if the width is in pixels, false if its in percentage</param>
                var iheaders = this.__properties.dataSource.headers;
                var renderType = (Bool(blPixel) ? 'px' : '%');


                if (iheaders[colname] === undefined)
                    iheaders[colname] = this.__newHeaderData(colname, false, colname, false, colWidth + renderType);
                else
                    iheaders[colname].width = colWidth + renderType;

            },
            /*Function returns list array
            *Returns the raw data for the given object
            */
            getRawData: function () {
                return this.__properties.dataSource.raw;
            },
            /*Function returns list array
            *Returns the data matrix for the formated Raw Data
            */
            getDataList: function () {
                return this.__properties.dataSource.list;
            },
            /*Function returns int
            *It returns the total rows returned in the raw data.
            */
            getDataValueByRowAndColname: function (row, colname) {
                var iDataList = this.__properties.dataSource.list;
                var value = null;

                if (!isNullOrEmpty(row) && !isNullOrEmpty(colname) && parseInt(row) >= 0) {

                    var objRow = iDataList[row];

                    for (var i = 0; i < objRow.length; i++) {
                        var objCell = objRow[i];

                        if (objCell["colname"] == colname) {
                            value = objCell["colvalue"];
                            break;
                        }
                    }
                }

                return value;
            },
            /*Function returns in
            *Returns the total Rows returned from the raw data.
            */
            getTotalRows: function () {
                var iDS = this.__properties.dataSource.raw;
                var iCount = 0;

                for (var key in iDS) {
                    iCount++;
                }

                return iCount;
            },
            /*Function returns int
            *Returns the total columns from the raw data.
            */
            getTotalColumns: function () {
                var tColumns = 0;
                tColumns = this.__properties.dataSource.list[0].length;

                return tColumns;
            },
            /*Function returns void
            *Manually adds the filter
            */
            setFilter: function () {
                var self= this;

                if (this.FilterIsOn) {
                    $('#' + self.getTableId()).filterTable(
                        {
                            label: isNullOrEmpty(this.getFilterLabel()) ? 'Search:' : this.getFilterLabel(),
                            minRows: this.getFilterMinRows()
                        })
                }
            },
            /*Function returns void
            *Binds the raw data into the display matrix data and creates the headers object.
            */
            Bind: function () {
                var dsList = this.__properties.dataSource.list;
                var dataSource = this.getRawData();

                //Need to include the custom fields some where

                if (dsList.length > 0) {
                    //begin reformating the data source into the row/cell matrix
                    for (var i = 0; i < dataSource.length; i++) {
                        //grab the datasource first row object
                        var objRow = dataSource[i];
                        var colCount = 0;

                        for (var key in objRow) {
                            //loop through each key in the data source row object key/value pairs
                            var cVal = objRow[key];

                            if (key != '__type') {//the __type is always returned from the data source.  We will store this value once.
                                if (dsList[i] === undefined)//checking the list matrix to see if the current row is undefined and adding a new array if it is
                                    dsList[i] = new Array();

                                dsList[i][colCount] = this.__newCellData(key, cVal); //Matix for cell [row][cell]=cellObject.  ie: [0][1]={colname:'col1', value:'val'}

                                if (this.__properties.dataSource.headers[key] === undefined) //Makes sure we have a header for this data column
                                    this.__properties.dataSource.headers[key] = this.__newHeaderData(key, this.ColumnDetectDisabled(), colCount, false, null);
                               
                                colCount++;
                            }
                            else {
                                if (isNullOrEmpty(this.__properties.type))
                                    this.__properties.type = cVal;
                            }
                        }
                    }
                }

                var test;
            },
            /*Function
            *Freeze's the current tables headers at the top.
            */
            freezeHeaderRow: function () {
                if (true) {
                    var iMasterHead = $('#master_' + this.getTableId() + ' [masterheader="true"]');
                    //var iMasterHead = $('#master_' + this.getTableId());
                    var ith = $('#' + this.getTableId() + ' tr:nth-child(1)').html();
                    iMasterHead.html("<td><table style='padding:0px;border-spacing:0px;'>" + ith + "</table></td>");
                    $('#' + this.getTableId() + ' tr:nth-child(1)').attr('style', 'visibility:collapse;');
                }
            },
            /*Function returns void
            *Formats the date/datetime values in a table.
            */
            showTimeInColumn: function(columnName, showTime){
                ///<param name="columnName">Name of the column being modified</param>
                ///<param name="showTime">Bool true/false - indicates whether to display time or not</param>
                var iHeaders = this.__properties.dataSource.headers;
                if (iHeaders[columnName] === undefined) {
                    iHeaders[columnName] = this.newHeaderDataObject(null, false, 0, false, 100);
                    iHeaders[columnName].showTime = Bool(shotTime);
                }
                else {
                    iHeaders[columnName].showTime = Bool(shotTime);
                }
            }, 
            /*Function returns void
            *Binds the row to the click event.  Add after table renders
            */
            setRowClick: function (onClickFunction) {
                if (typeof onClickFunction === 'function' && this.getTotalRows() > 0)
                {
                    this.__properties.rowClickOn = true;
                    $('#' + this.getTableId() + " [row]").on('click', function () {
                        onClickFunction(this);
                    });
                }
            },
            /*Function
            *
            */
            setRowExpand: function (expandRowOnClick, getContentFunction, columnName) {//Pete
                this.__properties.ExpandRowOnClick = expandRowOnClick;
                if (expandRowOnClick === true) {
                    this.Properties.ExpandRowContentFunc = getContentFunction;
                    this.Properties.ExpandRowColumnName = columnName;
                }
            },
            /*Function returns void
            *Used to update a headers display infomration.
            */
            renameHeaders:function(objHeaders){
                ///<param name="objHeaders">An object of headers.  ie { headerColName : "New Header" }</param>

                if (typeof objHeaders === 'object')
                {
                    for (var colname in objHeaders) {
                        $('[colname="' + colname + '"]').each(function () {
                            if ($(this).hasClass('cellHeader')) {
                                $(this).html(objHeaders[colname]);
                            }
                        });                        
                    }
                }
            },
            /*Function returns element
            *Returns the table element
            */
            render: function () {
                var self = this;
                var curStyle = '';
                var tbMasterGen = tableHelper.newTableBuilder('master_' + this.getTableId(), { style: 'padding:0px; border-spacing:0px;' });
                tbMasterGen.setInsertSpacerColumnOn(false);
                tbMasterGen.setInsertSpacerRowOn(false);
                var iHeaderRowClass = self.__properties.Styles.Header.Row;
                tbMasterGen.newRow({ "masterheader": true, 'class': iHeaderRowClass }, [tbMasterGen.newColumn({}, '', true)], true);


                var tblOptions = this.__properties.tableOptions;
                if (tblOptions['class'] === undefined)
                    tblOptions['class'] = this.__properties.Styles.Table.Default;

                var tbGen = tableHelper.newTableBuilder(this.getTableId(), this.getTableOptions());
                tbGen.setInsertSpacerRowOn(false);

                var iHeaders = this.__properties.dataSource.headers;

                var aryHeaders = new Array();
                //Need to create the table headers
                for (var colname in iHeaders) {
                    var options = '';
                    var iCurCol = null;

                    iCurCol = isNull(iHeaders[colname].currentColumn, iHeaders[colname].defaultColumn);
                    var iHeaderCellClass = self.__properties.Styles.Header.Cell;

                    if (!isNullOrEmpty(iHeaders[colname].width)) {

                        iHeaders[colname].headerObj = tbGen.newTableHeader(
                            {
                                colname: colname,
                                style: 'width:' + iHeaders[colname].width + ';',
                                "class": iHeaderCellClass
                            }, iHeaders[colname].displayName, false);

                        if (!Bool(iHeaders[colname].hideColumn)) {
                            aryHeaders[iCurCol] = iHeaders[colname].headerObj;
                        }
                    }
                    else {
                        if (!Bool(iHeaders[colname].hideColumn)) {
                            iHeaders[colname].headerObj = tbGen.newTableHeader({
                                colname: colname,
                                "class": iHeaderCellClass
                            }, iHeaders[colname].displayName, false);
                            aryHeaders[iCurCol] = iHeaders[colname].headerObj;
                        }
                    }
                }

                //Headers created but are we rendering them?
                if (!this.hideHeaderRow()) {
                    tbGen.newHeaderRow({ "class": iHeaderRowClass }, aryHeaders, true);
                }

                //Render the data cells
                var lstData = this.__properties.dataSource.list;
                if (this.getTotalRows() > 0) {
                    for (var row = 0; row < lstData.length; row++) {
                        var col = lstData[row];
                        var aryRow = new Array();

                        for (var cell = 0; cell < col.length; cell++) {                            
                            var objCell = col[cell];
                            var iCurCol = isNull(iHeaders[objCell.colname].currentColumn, iHeaders[objCell.colname].defaultColumn);

                            if (!Bool(iHeaders[objCell.colname].hideColumn)) {
                                var colValue = null;

                                if (this.hideNullDataValues())
                                    colValue = isNull(objCell.colvalue, '');
                                else
                                    colValue = objCell.colvalue;
                                                                
                                //if (colValue != null && DateHelper.isDate(objCell.colvalue)) {
                                //    if (Bool(objCell.showTime)) {
                                //        colValue = colValue.format('mm/dd/yyyy hh:MM TT');
                                //    }
                                //    else {
                                //        colValue = colValue.format('mm/dd/yyyy');
                                //    }
                                //}

                                aryRow[iCurCol] = tbGen.newColumn(
                                    {
                                        colname: objCell.colname,
                                        "cell": iCurCol,
                                        parentrow: row,
                                        datavalue: objCell.colvalue
                                    }, colValue, true);
                            }
                        }

                        if (Bool(this.__properties.UseAltStyles) && !Bool(this.__properties.HighlightRowOnHover)) {
                            if (curStyle == this.__properties.Styles.Row.Default)
                                curStyle = this.__properties.Styles.Row.AltStyle;
                            else
                                curStyle = this.__properties.Styles.Row.Default;
                        }
                        else if (Bool(this.__properties.UseAltStyles) && Bool(this.__properties.HighlightRowOnHover)) {
                            if (curStyle == this.__properties.Styles.Row.ClickStyle)
                                curStyle = this.__properties.Styles.Row.AltClickStyle;
                            else
                                curStyle = this.__properties.Styles.Row.ClickStyle;
                        }
                        else if (!Bool(this.__properties.UseAltStyles) && Bool(this.__properties.HighlightRowOnHover)) {
                            curStyle = this.__properties.Styles.Row.ClickStyle;
                        }
                        else {
                            curStyle = this.__properties.Styles.Row.Default;
                        }
                            

                        tbGen.newRow(
                            {
                                "row": row,
                                "class": curStyle
                            }, aryRow, true); //adds the new row to the table

                        var newRow = tbGen.__properties.rowDetails[tbGen.__properties.rowDetails.length - 1];

                        
                        if (this.isExpandRowOnClickOn()) {
                            var iExpandRowId = this.getTableId() + "_expand_" + row;
                            tbGen.newRow({ id: iExpandRowId, style: "visibility:collapse", 'state': 'collapse', 'parentrow': row, 'keycol': this.getExpandRowColumnName()}, [tbGen.newColumn({
                                'colspan' : iCurCol
                            }, 'No Results', false)], true);

                            var custFunc = this.__properties.ExpandRowContentFunc;

                            $(newRow).on('click', function () {                                
                                var tableid = $(this).closest('table').attr('id');
                                var rowToControl = $('#' + tableid + "_expand_" + $(this).attr('row'));

                                var istate = $(rowToControl).attr('state');

                                if (istate == 'collapse') {
                                    $(rowToControl).css('visibility', 'visible');
                                    $(rowToControl).attr('state', 'visible');
                                }
                                else if (istate == 'visible') {
                                    $(rowToControl).css('visibility', 'collapse');
                                    $(rowToControl).attr('state', 'collapse');
                                }

                                if (typeof custFunc === 'function')
                                    custFunc(rowToControl);
                            });
                        }
                    }
                }
                else {
                    var aryRow = new Array();
                    aryRow[0] = tbGen.newColumn({}, 'No Results Found', true);
                    tbGen.newRow({ "row": row }, aryRow, true);
                }

                var iTable = tbGen.Render();
                var idiv = controlBuilder.create('divMaster_' + this.getTableId(), 'div', {});
                $(idiv).append(iTable);
                tbMasterGen.newRow({ "container": true }, [tbMasterGen.newColumn({}, idiv, true)]);
                var iContainerTable = tbMasterGen.Render();

                if (!isNullOrEmpty(this.__properties.containerId))
                {
                    $('#' + this.__properties.containerId).html('');
                    $('#' + this.__properties.containerId).append(iContainerTable);

                    if (this.FilterIsOn) {
                        $(iTable).filterTable(
                            {
                                label: isNullOrEmpty(this.getFilterLabel()) ? 'Search:' : this.getFilterLabel(),
                                minRows: this.getFilterMinRows()
                            });

                        var ifilterHead = $('#master_' + this.getTableId());
                        $('#master_' + this.getTableId()).find('.filter-table').prependTo(ifilterHead);
                    }
                }

                return iContainerTable
            },
            /*Function returns void
            *Inserts a new blank column into the table
            */
            insertNewColumn: function (colName, afterColumn) {
                var irowCount = 0;
                var self = this;
                var iDisplayName = null;

                if (this.__properties.dataSource.headers[colName] !== undefined)
                    iDisplayName = (isNullOrEmpty(this.__properties.dataSource.headers[colName].displayName) ? colName : this.__properties.dataSource.headers[colName].displayName);
                else
                    iDisplayName = colName;


                $('#' + this.getTableId()).find('[colname="' + afterColumn + '"]').each(function () {
                    var cCol = null;
                    if ($(this).attr('cell') === undefined)
                        cCol = 0;
                    else
                        cCol = parseInt($(this).attr('cell')) + 1;

                    var cRow = null;
                    if ($(this).attr('parentrow') === undefined)
                        cRow = 0;
                    else
                        cRow = parseInt($(this).attr('parentrow'));

                    if (irowCount == 0) {
                        var ith = controlBuilder.create('', 'th', { "colname": colName, "class": "cellHeader" });
                        $(ith).html(iDisplayName);
                        $(ith).insertAfter($(this));
                        self.__properties.dataSource.headers[colName] = self.newHeaderDataObject(colName, false, cCol, true, null);
                    }
                    else {
                        var itd = controlBuilder.create('', 'td', { "colname": colName, "class": "cell", "parentrow": cRow, "cell": cCol + "_" + colName });
                        $(itd).insertAfter($(this));
                    }

                    irowCount++;
                });
            },
        }

        return obj;
    },
    /*Function
    *For version 2 table helper only.
    */
    getCellValue: function (columnName, tableName, rowId) {
        ///<param name="columnName">The colname containing the information you are looking for.</param>
        ///<param name="tableName"></param>
        ///<param name="rowId"></param>
        var val = null;

        if (document.getElementById(tableName) != null) {
            val = $('#' + tableName).find('[row="' + rowId + '"]').find('[colname="' + columnName + '"]').attr('datavalue').toLowerCase();
        }
        
        return val;
    },
    newTable:function(){
        var obj = this.__newTableV2();
        return obj;
    },
    new: function () {
        return this.__table();
    }
};

