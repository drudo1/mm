/*Data Object
*Generic class object used for accessing the webservice.
*/
var data = {
    __newLayer: function () {
        var layer = {
            /*Public Global Data Object
            *Used to store data returned from the webservice
            *and stored for global access.
            */
            global: {},
            /*Function returns results object
            *Checks for any active/upcoming maintenance schedules
            *and stored in the global data object.
            */
            func: {
                checkForActiveMaintenance: function () {
                    errorLogs.LogTiming('checkForActiveMaintenance(Datalayer.js)', 'Starting');
                    var result = null;

                    $.ajax({
                        type: "POST",
                        url: HttpContext.BuildPath("~/DataServices.asmx") + "/checkForActiveMaintenance",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: false,
                        success: function (response) {
                            if (!isNullOrEmpty(response.d))
                                result = response.d;
                        },
                        error: function (msg) {
                            errorLogs.LogError(msg);
                        }
                    });
                    errorLogs.LogTiming('checkForActiveMaintenance(Datalayer.js)', 'Ending');

                    return result;
                },
                /*Function returns Login object
                *Validates User Login/Password
                *<param name="username"></param> - UserName
                *<param name="password"></param> - Users password
                */
                Login: function (username, password) {
                    errorLogs.LogTiming('Login(Datalayer.js)', 'Starting');
                    var result = null;

                    $.ajax({
                        type: "POST",
                        url: HttpContext.BuildPath("~/DataServices.asmx") + "/Login",
                        data: "{username: '" + username + "', password: '" + password + "'}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: false,
                        success: function (response) {
                            if (!isNullOrEmpty(response.d))
                                result = response.d;
                        },
                        error: function (msg) {
                            errorLogs.LogError(msg);
                        }
                    });
                    errorLogs.LogTiming('Login(Datalayer.js)', 'Ending');

                    return result;
                }
            },
            /*public Object
            *Contains functions for setting parameters for the
            *webservice calls.
            */
            Params: {
                /*Private Assoc. Array Object
                *(DO NOT CALL DIRECTLY) Use SetParams function
                *Stores a List of any parameters To be sent to
                *The webservice
                */
                Parameters: new Array(),
                /*Public Function 
                *Use this function to add parameters needed for the webservice
                */
                SetParams: function (serviceName, paramName, paramValue, objName) {
                    ///<param name="serviceName">The web service being called</param>
                    ///<param name="paramName">The parameter being added</param>
                    ///<param name="paramValue">The value of the parameter</param>
                    ///<param name="objName">The actual variable/class name used in the webservice</param>
                    for (svc in this.Parameters) {
                        if (svc != serviceName)
                            delete this.Parameters[svc];
                    }
                    if (isNullOrEmpty(this.Parameters[serviceName])) {
                        this.Parameters[serviceName] = {};
                    }
                    if (!isNullOrEmpty(objName)) {
                        var objTmp = {};
                        if (!isNullOrEmpty(this.Parameters[serviceName][objName])) {
                            objTmp = this.Parameters[serviceName][objName];
                        }
                        if (!isNullOrEmpty(paramName)) {
                            objTmp[paramName] = paramValue;
                            this.Parameters[serviceName][objName] = objTmp;
                        }
                    }
                    else {
                        this.Parameters[serviceName][paramName] = paramValue;
                    }
                },
                AddParamsOfObject: function (serviceName, obj, objName) {
                    for (param in obj) {
                        this.SetParams(serviceName, param, obj[param], objName);
                    }
                },

                ClearParams: function (serviceName) {
                    delete this.Parameters[serviceName];
                },

                ClearAllParams: function () {
                    for (svc in this.Params.Parameters) {
                        delete this.Parameters[svc];
                    }
                }
            },
            /*Private Function. (DO NOT CALL DIRECTLY)
            *Returns the results of the webservice call.
            *Use data.call instead of this function
            *<params name="funcName"></params> Webservice Name being called.
            */
            funcGeneric: function (funcName, async) {
                errorLogs.LogTiming(funcName + '(Datalayer.js)', 'Starting');
                var result = {
                    success: false,
                    error: null,
                    data: null
                };

                if (typeof this.Params.Parameters[funcName] === 'undefined')
                    this.Params.Parameters[funcName] = new Array();

                if (this.Params.Parameters[funcName].length == 0) {
                    $.ajax({
                        type: "POST",
                        url: HttpContext.BuildPath("~/Services/DataServices.asmx") + "/" + funcName,
                        contentType: "application/json; charset=utf-8",
                        async: isNull(async, false),
                        success: function (response) {
                            if (!isNullOrEmpty(response.d) || $.isArray(response.d)) {
                                result.success = true;
                                result.data = response.d;
                            }
                        },
                        error: function (msg) {
                            errorLogs.LogError(msg);
                            result.success = false;
                            result.error = msg;
                        }
                    });
                }
                else {
                    var Params = {};
                    for (var key in this.Params.Parameters[funcName]) {
                        Params[key] = this.Params.Parameters[funcName][key];
                    }
                    $.ajax({
                        type: "POST",
                        url: HttpContext.BuildPath("~/Services/DataServices.asmx") + "/" + funcName,
                        data: JSON.stringify(Params),
                        contentType: "application/json; charset=utf-8",
                        async: isNull(async, false),
                        success: function (response) {
                            if (!isNullOrEmpty(response.d) || $.isArray(response.d)) {
                                result.success = true;
                                result.data = response.d;
                            }
                        },
                        error: function (msg) {
                            errorLogs.LogError(msg);
                            result.success = false;
                            result.error = msg;
                        }
                    });
                }
                errorLogs.LogTiming(funcName + '(Datalayer.js)', 'Ending');

                return result;
            },
            /*Public Function retruns webservice results
            *Used to contact the webservice
            *Use SetParams to add parameters for the webservice
            *if alwaysRefresh is true the data object is always refreshed per data call.
            *if false, then the data is written once and accessed many times.
            *<param name="funcName">Webservice being called<param>
            *<param name="alwaysRefresh">bool (true/false)</param>
            */
            call: function (funcName, alwaysRefresh, async) {
                ///<param name="funcName">Name of the webservice being called</param>
                ///<param name="alwaysRefresh">Set to true if you don't want to cache your results</param>

                var result = '';

                if (isNullOrEmpty(this.global[funcName]) || isNullOrEmpty(this.global[funcName].data) || Bool(alwaysRefresh))
                    this.global[funcName] = this.funcGeneric(funcName, async);

                result = this.global[funcName];
                return result;
            },
            saveGroup: function (groupName, paramName, serviceName, autoSave) {
                var result = {
                    success: false,
                    errorMessage: null,
                    data: null
                };

                if (isNullOrEmpty(autoSave))
                    autoSave = false;

                var objS = objSave.new();
                var tmpObj = objS.GenerateSaveObject(groupName, null, serviceName, globalData.FormControls().Groups()[groupName], false);

                if (objS.isValid) {
                    this.Params.SetParams(serviceName, paramName, tmpObj, null);
                    this.Params.SetParams(serviceName, "completed", Bool(objS.reqMet), null);
                    this.Params.SetParams(serviceName, "PageID", pageSecurity.PageID, null);
                    this.Params.SetParams(serviceName, "AutoSave", autoSave, null);
                    //dataLayer.Params.SetParams(serviceName, "sessionID", globalvars.GetSessionId(), null);

                    result = this.call(serviceName, true);
                    if (!Bool(autoSave))
                        setLastSaved(DateHelper.GetDateTime(), Bool(autoSave), null, null);
                }
                else {
                    if (!Bool(autoSave))
                        result.errorMessage = 'Not all required fields were provided.';
                }
                if (!result.success) {
                    if (!isNullOrEmpty(result.errorMessage))
                        bootbox.alert(result.errorMessage);
                    else if (!isNullOrEmpty(result.error.responseText))
                        bootbox.alert(result.error.responseText);
                    else
                        bootbox.alert('Unknown Error');
                }
                return result;
            },
            /*Function
            *Returns a key value pair object for use in drop down selections
            */
            getList: function (procName) {
                ///<param name="procName">This is the name of the stored procdure to call.</param>
                var params = Array.prototype.slice.call(arguments, 1)
                var sendParams = new Array();
                this.Params.ClearParams("GetList");
                this.Params.SetParams("GetList", "procName", procName, null);
                if (params.length > 0) {
                    if ($.isArray(params[0])) {
                        sendParams = params[0];
                    }
                    else {
                        sendParams = params;
                    }
                }
                this.Params.SetParams("GetList", "Params", sendParams, null);
                return this.call("GetList", true).data;
            }
        }
        return layer;
    },
    /*Function
    *This returns the data from the webservice call based on parameters
    */
    run: function (procname, paramList, func, async, filtered) {
        ///<param name="procname">The Data service name </param>
        ///<param name="paramList">This is an object list of parameters</param>
        ///<param name="func">This is an optional callback function</param>
        ///<param name="async">bool true/false</param>
        ///<param name="filtered">Pass in an object template.  Used to reogranize/filter data results</param>
        var dObj = data.new();
        if (!isNullOrEmpty(paramList)) {
            for (paramKey in paramList) {
                dObj.Params.SetParams(procname, paramKey, paramList[paramKey], null);
            }
        }
        var result = dObj.call(procname, true, async).data;

        if (!isNullOrEmpty(filtered) && typeof filtered === 'object') {
            var aryOrderData = new Array();
            for (var i = 0; i < result.length; i++) {
                var iObj = result[i];

                var newObj = function (filter, data) {
                    for (var key in data) {
                        filtered[key] = data[key];
                    }

                    return filtered;
                }

                aryOrderData.push(newObj(filtered, iObj));
            }

            result = aryOrderData;
        }

        if (typeof func === 'function')
            func(result);
        return result;
    },
    getList: function () {
        data.new().getList.apply(this, arguments);
    },
    /*Functon returns list
    *Sets a custom key/value pair based on the list data.
    */
    buildCustomKeyValueList: function (aryData, textString, valueField) {
        ///<param name='aryData'>list array - the list being passed in</param>
        ///<param name='textString'>The string you want to add.  Place the object property names you want to use inside the string. i.e.: "{dbcol1}, {dbcol2}"</param>
        ///<param name='valueField'>The object property being used as the value</param>
        if (aryData != null && !isNullOrEmpty(textString) && !isNullOrEmpty(valueField)) {
            var newObj = new Array();

            for (var i = 0; i < aryData.length; i++) {
                var tmpString = String.format(textString, aryData[i]);
                var tmpValue = aryData[i][valueField];

                newObj.push({ Text: tmpString, Value: tmpValue });
            }

            return newObj;
        }
    },
    new: function () {
        var obj = this.__newLayer();
        obj.getListglobal = {};
        obj.Params.Parameters = new Array();

        return obj;
    }
};

/*Data Object
*
*/
var objSave = {
    new: function () {
        __saveObj = {
            /*Returns Results Object
                *Stores results from the save routine
                */
            results: null,
            errorMessage: null,
            /*Bool (true/false)
            *Means object can be saved.
            */
            isValid: false,
            /*Bool (true/false)
            *Means all requirements were met for a full submission.
            */
            reqMet: true,

            Initialize: function () {
                this.results = null;
                this.errorMessage = null;
                this.isValid = false;
                this.reqMet = false;
            },
            /*Form Object
            *Wraps the form object up for saving.
            */
            GenerateSaveObject: function (groupId, saveObj) {
                ///<param name="groupId">Group name of the controls being sent to the save routine</param>
                ///<param name="saveObj">Can send over an overloaded form Object with additional parameters</param>

                //Notes:  Need to check reqtoSave/reqtoSubmit - determines if the save can be published or not
                errorLogs.LogTiming("GenerateSaveObject", "Starting");
                var formObject = {};  //Stores the current group elements
                var SaveObject = {};  //This is the collection of all items need to save wrapped in a single object.

                this.Initialize();

                if (globalData.FormControls() != undefined && globalData.FormControls().Groups() != undefined &&
                    globalData.FormControls().Groups()[groupId] != undefined) {

                    formObject = globalData.FormControls().Groups()[groupId].controls;
                    this.reqMet = true;
                    for (var key in formObject) {
                        if (Bool(formObject[key].savetodb)) {
                            if (!isNullOrEmpty(formObject[key].dbcol)) {
                                if ($('#' + key).attr('type') === 'hidden')
                                    SaveObject[formObject[key].dbcol] = $('#' + key).val();
                                else {
                                    var val = isNull(formObject[key].cval, $('#' + key).val());
                                    if (isNullOrEmpty(val) && $('#' + key).attr('IsGuid') === 'true')
                                        val = guid.empty;
                                    SaveObject[formObject[key].dbcol] = val;
                                }
                                this.isValid = true;

                                if (formObject[key].reqstate == reqStates.ReqToSave &&
                                    (isNullOrEmpty(formObject[key].cval) || formObject[key].cval == guid.empty))
                                    this.reqMet = false;
                                else if (formObject[key].reqstate == reqStates.ReqToSubmit &&
                                    isNullOrEmpty(formObject[key].cval)) {
                                    this.isValid = false;
                                    break;
                                }
                            }
                        }
                    }
                    if (!this.isValid) {
                        this.errorMessage = errorLogs.LogTiming("GenerateSaveObject", "Submit requirements not met.");
                        SaveObject = {};
                        return SaveObject;
                    }
                    else {
                        return SaveObject;
                    }
                }
                else {
                    this.errorMessage = errorLogs.LogTiming("GenerateSaveObject", "Form object not loaded.");
                    return SaveObject;
                }
            },
            /*Function
            *Creates a save group object that test whether or not a save can occur.
            */
            Save: function (groupId, saveObjectName, ReturnResults, ServiceName, saveObj) {
                ///<param name="groupId">Group name of the controls being sent to the save routine</param>
                ///<param name="saveObjectName">null if saving as individual units or the name of the webservice object being sent</param>
                ///<param name="ReturnResults">Bool (true/false) - Whether or not to return any results</param>
                ///<param name="ServiceName">Name of the webservice</param>
                ///<param name="saveObj">Can send over an overloaded form Object with additional parameters</param>

                //Notes:  Need to check reqtoSave/reqtoSubmit - determines if the save can be published or not

                var objSave = {};
                var tmpSaveObj = null;

                if (saveObj != undefined && saveObj != null)
                    tmpSaveObj = saveObj;
                else
                    globalData.FormControls().Groups()[groupId];


                var blReqMet = true; //This is flipped true if ALL requirements have been met
                var blReqToSubmit = false; //If this is true, then the save routine is aborted
                var blFoundItemsToSave = false;
                for (var key in tmpSaveObj) {
                    if (Bool(tmpSaveObj[key].savetodb)) {
                        objSave[tmpSaveObj[key].dbcol] = tmpSaveObj[key].cval;
                        blFoundItemsToSave = true;
                    }
                }

                var tmpData = data.new();
                tmpData.Params.Parameters = new Array();

                var blSaved = false;

                for (var key in tmpSaveObj) {
                    if (isNullOrEmpty(tmpSaveObj[key].dbcol)) {
                        blReqToSubmit = true;
                    }
                    else {

                        if (tmpSaveObj[key].reqstate == reqStates.ReqToSave &&
                            isNullOrEmpty(tmpSaveObj[key].cval))
                            blReqMet = false;
                        else if (tmpSaveObj[key].reqstate == reqStates.ReqToSubmit &&
                            isNullOrEmpty(tmpSaveObj[key].cval))
                            blReqToSubmit = true;
                    }
                }

                if (!blReqToSubmit && blFoundItemsToSave) {
                    objSave["complete"] = blReqMet;

                    if (!isNullOrEmpty(saveObjectName)) {
                        tmpData.Params.SetParams(ServiceName, null, objSave, saveObjectName);
                    }
                    else {
                        for (var key in objSave) {
                            tmpData.Params.SetParams(ServiceName, key, objSave[key], null);
                        }
                    }

                    if (Bool(ReturnResults)) {
                        this.results = tmpData.call(ServiceName, true).data;
                        blSaved = true;
                    }
                    else {
                        tmpData.call(ServiceName, true).data;
                        blSaved = true;
                    }
                }
                else
                    this.errorMessage = "Submit requirements not met.";

                tmpData = null;

                if (Bool(ReturnResults))
                    return this.results;
                else
                    return blSaved;
            }
        }
        return __saveObj
    }
}



