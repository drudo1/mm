var globalDataCore = {
    __newGlobalData: function () {
        var obj = {
            __properties: {
                IsAdmin: false,
                ProtalMenuLoaded: false,
                ClientMenuLoaded: false,
                KeepAlive: false,
                FormControls: {},
                Messages: {},
                FieldPrefs: {},
                typingTimers: {}
            },
            /*Function returns void
            *Sets a typing timer
            */
            setTypingTimer: function (uid, timer) {
                if (!isNullOrEmpty(timer) && !isNullOrEmpty(uid)) {
                    this.__properties.typingTimers[uid] = timer;
                }
            },
            /*Function returns void
            *Clears a typing timer
            */
            clearTypingTimer: function (uid) {
                if (!isNullOrEmpty(uid) && this.__properties.typingTimers[uid] != undefined)
                    clearTimeout(this.__properties.typingTimers[uid]);
            },
            /*Function returns object
            *Returns a typing timer
            */
            getTypingTimer: function (uid) {
                var tt = null;

                if (!isNullOrEmpty(uid) && this.__properties.typingTimers[uid] != undefined)
                    tt = this.__properties.typingTimers[uid];

                return tt;
            },
            /*Function returns value
            *Loops through the Groups array and all controls to locate the value for the 
            *given element based on the id of the element.
            */
            GetFormObject: function (id) {
                ///<param name="id">The id for the given element being looked for</param>
                var val = null;
                for (groupKey in this.__properties.FormControls().Groups()) {
                    for (fieldKey in this.FormControls().Groups()[groupKey].controls) {
                        if (fieldKey === id) {
                            val = this.FormControls().Groups()[groupKey].controls[fieldKey];
                            break;
                        }
                    }
                    if (!isNullOrEmpty(val))
                        break;
                }
                return val;
            },
            /*Function accepts bool true/false
            *Sets the value of blIsAdmin.
            */
            setIsAdmin: function (blIsAdmin) {
                ///<param name="blIsAdmin">true/false - Is the current user an admin?</param>               
                this.__properties.IsAdmin = Bool(blIsAdmin);
            },
            /*Function returns bool true/false
            *Gets the value of IsAdmin and returns it.
            */
            getIsAdmin: function () {
                return this.__properties.IsAdmin;
            },
            /*Function accepts bool true/false
            *sets the value of PortalMenuLoaded
            */
            setProtalMenuLoaded: function (isLoaded) {
                ///<param name="isLoaded">true / false - Has the portal menu loaded?</param>
                this.__properties.ProtalMenuLoaded = Bool(isLoaded);
            },
            /*Function returns bool true/false
            *Returns the current state of PortalMenuLoaded
            */
            PortalMenuLoaded: function () {
                return this.__properties.ProtalMenuLoaded;
            },
            setKeepAlive: function (blKeepAlive) {
                this.__properties.KeepAlive = Bool(blKeepAlive);
            },
            KeepAlive: function () {
                return this.__properties.KeepAlive;
            },
            FormControls: function () {
                return this.__properties.FormControls;
            },
            setFormControls: function (formObject) {
                if (typeof formObject === 'object')
                    this.__properties.FormControls = formObject;
            },
            FieldPrefs: function () {
                return this.__properties.FieldPrefs;
            },
            setFieldPrefs: function (objFieldPrefs) {
                if (typeof objFieldPrefs === 'object')
                    this.__properties.FieldPrefs = objFieldPrefs;
            },
            ClientMenuLoaded: function () {
                return this.__properties.ClientMenuLoaded;
            },
            setClientMenuLoaded: function (blLoaded) {
                this.__properties.ClientMenuLoaded = Bool(blLoaded);
            },
            Messages: function () {
                return this.__properties.Messages;
            },
            setMessages: function (objMsg) {
                if (typeof objMsg === 'object')
                    this.__properties.Messages = objMsg;
            },

        }

        return obj;
    },
    /*Function returns object
    *Returns a new globalData object.
    */
    new: function () {
        var obj = this.__newGlobalData();
        return obj;
    }
}

/*Object
*Stores the Global Data Elements
*/
var globalData = globalDataCore.new();

/*Returns string
*This is a the format of a new Guid id
*Depricated, use guid.empty instead.
*/
var newGuid = '00000000-0000-0000-0000-000000000000';

//Required States and what they are.
var reqStates = {
    /*Const Guid
    *Field is not required to save/submit
    */
    NotRequired: '00000000-0000-0000-0000-000000000000',
    /*Const Guid
    *Field can be saved but only to the pending table
    */
    ReqToSubmit: '99c36806-4d03-49fb-8e3d-923601520ccd',
    /*Const Guid
    *Field must be supplied before save is available.
    */
    ReqToSave: '1f169541-39dd-4c00-a014-abb9f6a84031'
};

//Global Variables used across all pages
//example: global.sessionID = getParameterByName('SessionID');
var Session =
    {
        objActiveSession: {},
        /*Assoc. Array
        *User Extended Rights.
        */
        __rights: {},
        checkRights: function (right) {
            var objRight = {};
            if (!isNullOrEmpty(right)) {
                var blRightFound = false;

                for (var tmpRight in this.__rights) {
                    if (tmpRight.toLowerCase() == right.toLowerCase()) {
                        objRight = this.__rights[tmpRight];
                        objRight[tmpRight] = true;
                        blRightFound = true;
                        break;
                    }
                }
            }

            if (!blRightFound) {
                objRight = {
                    grantToAdmin: false
                }
                objRight[right] = false;
            }
            return objRight;
        },
        hasRole: function () {
            var args = Array.prototype.slice.call(arguments, 0)
            var hasRole = false;
            for (rKey in this.objActiveSession.UserRoles) {
                for (aKey in args) {
                    if (this.objActiveSession.UserRoles[rKey].Role === args[aKey] || this.objActiveSession.UserRoles[rKey].RoleID === args[aKey]) {
                        hasRole = true;
                        break;
                    }
                }
                if (hasRole)
                    break;
            }
            return hasRole;
        },
        objSessionVariables: {
            Packages: {},

            SetVariable: function (key, value) {
                this[key] = value;
            },

            ClearPackage: function (pkgKey) {
                this.Packages[pkgKey] = {};
            },

            SetPackageVariable: function (pkgKey, key, value) {
                if (isNullOrEmpty(this.Packages[pkgKey]))
                    this.Packages[pkgKey] = {};
                this.Packages[pkgKey][key] = value;
            }
        },

        newPackageVar: function (name, value) {
            return { name: name, value: value };
        },

        ClearPackageVar: function (pkg, key) {
            Session.objSessionVariables.Packages[pkg][key] = null;
        },

        ClearPackageVars: function (pkg) {
            Session.objSessionVariables.ClearPackage(pkg);
        },

        ClearPackageVarsImmediate: function (pkg) {
            Session.ClearPackageVars(pkg);
            Session.UpdateSession();
        },

        SendPackageVar: function (pkg, key, value) {
            if ($.isArray(value))
                Session.objSessionVariables.SetPackageVariable(pkg, key, value.join(','));
            else
                Session.objSessionVariables.SetPackageVariable(pkg, key, value);
        },

        SendPackageVars: function (pkg, vars) {
            this.ClearPackageVars(pkg);
            if ($.isArray(vars)) {
                for (v in vars) {
                    var x = vars[v];
                    this.SendPackageVar(pkg, x['name'], x['value']);
                }
            }
            else if (typeof vars === 'object' && vars['name'] != undefined && vars['value'] != undefined)
                this.SendPackageVar(pkg, vars['name'], vars['value']);
            else {
                for (key in vars) {
                    this.SendPackageVar(pkg, key, vars[key]);
                }
            }
        },
        SendPackageVarsImmediate: function (pkg, vars) {
            this.SendPackageVars(pkg, vars);
            this.UpdateSession();
        },

        GetPackageVars: function (pkgName) {
            return this.objSessionVariables.Packages[pkgName];
        },

        GetPackageVar: function (pkgName, key) {
            var pkg = this.GetPackageVars(pkgName);
            if (isNullOrEmpty(pkg))
                return this.GetPackageVarFromDB(pkgName, key);
            else
                return pkg[key];
        },

        GetPackageVarFromDB: function (pkgName, key) {
            return data.run('GetPackageVar', { Package: pkgName, Key: key });
        },

        ClearPageVar: function (pageid, key) {
            this.ClearPackageVar("page:" + pageid, key);
        },

        ClearPageVars: function (pageid, blUpdateImmidiate) {
            ///<param name="pageid">uniqueidentifier - the page id</param>
            ///<param name="blUpdateImmidiate">bool - set to true to clear the var immediately.
            this.ClearPackageVars("page:" + pageid);

            if (Bool(blUpdateImmidiate))
                this.UpdateSession();
        },

        SendPageVar: function (pageid, key, value) {
            this.SendPackageVar("page:" + pageid.toLowerCase(), key, value);
        },

        SendCurrentPageVar: function (key, value) {
            this.SendPackageVar("page:" + pageSecurity.PageID, key, value);
        },

        SendPageVars: function (pageid, vars) {
            this.SendPackageVars("page:" + pageid, vars);
        },

        SendCurrentPageVars: function (vars) {
            this.SendPackageVars("page:" + pageSecurity.PageID, vars);
        },

        GetPageVars: function (pageid) {
            return this.GetPackageVars("page:" + pageid);
        },

        GetCurrentPageVars: function () {
            return this.GetPackageVars("page:" + pageSecurity.PageID);
        },

        GetPageVar: function (pageid, key) {
            return this.GetPageVars(pageid)[key];
        },

        GetCurrentPageVar: function (key) {
            return this.GetPageVars(pageSecurity.PageID)[key];
        },

        GetCurrentClient: function () {
            return this.GetPackageVar('currentClient', 'ClientID');
        },

        GetCurrentUser: function () {
            return this.objActiveSession.UserID;
        },

        Login: function (user, pass) {
            var objData = data.new();
            objData.Params.SetParams("Login", "username", user);
            objData.Params.SetParams("Login", "password", pass);
            this.objActiveSession = objData.call("Login", true).data;
        },

        LoadSession: function () {
            var objData = data.new();
            if (globalvars.GetSessionId != newGuid) {
                objData.Params.SetParams("GetActiveSessionInfoBySessionID", "PageID", pageSecurity.PageID);
                objData.Params.SetParams("GetActiveSessionInfoBySessionID", "SessionID", globalvars.GetSessionId());
                this.objActiveSession = objData.call("GetActiveSessionInfoBySessionID", true, false).data;
                if (isNullOrEmpty(this.objActiveSession.ErrorMessage)) {
                    this.loadUserRoles();

                    for (key in this.objActiveSession.SessionVariables) {
                        var variable = this.objActiveSession.SessionVariables[key];
                        if (isNullOrEmpty(variable.PackageKey))
                            this.objSessionVariables[variable.VarKey] = variable.Value;
                        else {
                            if (isNullOrEmpty(this.objSessionVariables.Packages[variable.PackageKey]))
                                this.objSessionVariables.Packages[variable.PackageKey] = {};
                            this.objSessionVariables.Packages[variable.PackageKey][variable.VarKey] = variable.Value;
                        }
                    }
                }
            }
        },

        UpdateSession: function () {
            var objData = data.new();
            if (globalvars.GetSessionId() != newGuid) {
                objData.Params.SetParams("UpdateSessionVariables", "SessionVariables", this.objSessionVariables);
                objData.Params.SetParams("UpdateSessionVariables", "SessionID", globalvars.GetSessionId());
                objData.call("UpdateSessionVariables").data;
            }
        },
        loadUserRoles: function () {
            var blExist = false;

            var tmpRoles = this.objActiveSession.UserRoles;
            for (var key in tmpRoles) {
                var objRole = tmpRoles[key];
                var sre = objRole.SecurityRoleExtensions;

                for (var ext in sre) {
                    var objExt = sre[ext];
                    this.__rights[objExt.Description] = { grantToAdmin: Bool(objExt.ApplyToAdmin) };
                }
            }
        }
    };
/*Global Object
*Contains any value/object/variable that needs to be saved
*for global consumption
*/
var globalvars = {
    reqmsg: '*',
    /*Function
    *This returns the current session id.
    */
    GetSessionId: function () {
        return isNullOrEmpty($('.hdn_SessionID').val()) ? newGuid : $('.hdn_SessionID').val();
    }
};

var Navigation = {
    NavigateByMenuItem: function (menuItemID, menuType) {
        var objData = data.new();
        objData.Params.SetParams("Get" + menuType + "MenuItemByID", "MenuItemID", menuItemID);
        var item = objData.call("Get" + menuType + "MenuItemByID", true).data;
        if (item != null) {
            var newWindow = false;
            Session.objSessionVariables.ClearPackage('page:' + item.PageID);
            for (key in item.Parameters) {
                var param = item.Parameters[key];
                if (param.ParameterName != 'NewWindow')
                    Session.objSessionVariables.SetPackageVariable("page:" + item.PageID, param.ParameterName, param.ParameterValue);
                else
                    newWindow = param.ParameterValue.toLowerCase() == 'true';
            }
            this.NavigateToUrl(HttpContext.BuildPath(item.PageLocation), newWindow);
        }
    },

    NavigateToPage: function (pageID) {
        var objData = data.new();
        objData.Params.SetParams("GetPageByID", "PageID", pageID);
        var navPage = objData.call("GetPageByID", true).data;
        if (navPage != null) {
            this.NavigateToUrl(HttpContext.BuildPath(navPage.PageLocation));
        }
    },

    NavigateToUrl: function (url, newWindow) {
        if (isNullOrEmpty(newWindow)) {
            newWindow = false;
        }
        if (window.location.href.toLowerCase() != url.toLowerCase()) {
            $('.blockUI').show();
            Session.UpdateSession();
            if (!newWindow)
                window.location.href = url;
            else
                window.open(url);
        }
    }
};

//End Global Variable declarations.

/*Core Load Functions
*These function dictate the order of loading operations
*on a given page.
*/
var loadEvents = {
    /*DataObject
    *Used to store data objects globally.
    */
    Data: {},
    /*Page Func Object
    *This object stores a pages particular function.
    */
    PageFuncs: {
        FormControlProperties: function () {
            //objFormHelper.Funcs.preloadForm();
            //createRequiredLabels();
        }
    },
    /*Object
    *PreInit fires first on a page.  Use this to preload variables and
    *anything else that doesn't require data.
    */
    PreInit: {},
    /*Object
    *This object loads events after the PreInit.
    */
    Init: {
        Global: function () { }
    },
    /*Object
    *This function follows a full page load.  Use this to
    *Load grids/drop downs and other data functions
    */
    DocReady: {
        EventFormats: function () { }
    },
    /*Object
    *This object fires prior to the ping functions.  Use this
    *obect to store functions that wrap up page loads.
    */
    WinLoad: {},

    AfterLoad: {}
};
//End Load Events


//This is used to generate all the required labels
function checkReqLables(id, containers) {
    ///<param name="id">This is the id for the element being checked</param>
    ///<param name="container">This is the optional container object to be searched</param>
    if (!isNullOrEmpty(id))
        createRequiredLabels(id, containers);
    else if (!isNullOrEmpty(containers)) {
        for (key in containers) {
            $(containers[key]).find('[reqstate]').each(function () {
                createRequiredLabels(this.id, containers);
            });
        }
    }
    else {
        $('[reqstate]').each(function () {
            createRequiredLabels(this.id);
        });
    }
    createContainerReqLabels(containers);
}

function createContainerReqLabels(containers) {
    if (isNullOrEmpty(containers))
        containers = { doc: document };
    for (cKey in containers) {
        var container = containers[cKey];
        $(container).find('.DPcollapsecontent_h').each(function () {
            if ($(this).find('.DPcollapsecontent').find('.required').length > 0) {
                var objLabel = document.createElement('div');
                objLabel.innerHTML = '*';
                $(objLabel).css('float', 'right');
                $(objLabel).css('color', 'red');
                $(objLabel).addClass('required');
                $($(this).find('.DPcollapsecontenthandle').find('div')[2]).html('').append(objLabel);
            }
            else
                $($(this).find('.DPcollapsecontenthandle').find('div')[2]).html('');
        });

        if (guid.isGuid(cKey)) {
            if ($(container).find('.required').length > 0) {
                if ($('a[href="#' + cKey + '"]').find('.required').length == 0) {
                    var objLabel = document.createElement('div');
                    objLabel.innerHTML = '*';
                    $(objLabel).css('float', 'right');
                    $(objLabel).css('color', 'red');
                    $(objLabel).addClass('required');
                    $('a[href="#' + cKey + '"]').append(objLabel);
                }
            }
            else {
                if ($('a[href="#' + cKey + '"]').parent().find('.required') != undefined)
                    $('a[href="#' + cKey + '"]').parent().find('.required').remove();
            }
        }
        else {
            $('.tab-pane').each(function () {
                if ($(this).find('.required').length > 0) {
                    if ($('a[href="#' + $(this).attr('id') + '"]').find('.required').length == 0) {
                        var objLabel = document.createElement('div');
                        objLabel.innerHTML = '*';
                        $(objLabel).css('float', 'right');
                        $(objLabel).css('color', 'red');
                        $(objLabel).addClass('required');
                        $('a[href="#' + $(this).attr('id') + '"]').append(objLabel);
                    }
                }
                else {
                    if ($('a[href="#' + $(this).attr('id') + '"]').parent().find('.required') != undefined)
                        $('a[href="#' + $(this).attr('id') + '"]').parent().find('.required').remove();
                }
            });
        }
    }
    updateTabStatus();
}

function updateTabStatus() {
    var gfc = globalData.FormControls();
    $('.tab-pane').each(function () {
        var tab = $(this);
        if ($(this).hasClass('statusCheck')) {
            var status = 'red';
            var countreq = 0;
            var countfilled = 0;
            $(this).find('[dbcol]').each(function () {
                if ($(this).attr('origval') === undefined || isNullOrEmpty($(this).attr('origval')) || $(this).attr('origval') == guid.empty) {
                    for (key in gfc.Groups()) {
                        if (gfc.Groups()[key].controls[$(this).attr('id')] != undefined) {
                            if (gfc.Groups()[key].controls[$(this).attr('id')].reqstate != reqStates.NotRequired)
                                countreq++;
                        }
                    }
                }
                else {
                    countfilled++;
                    if (status == 'red' && $(this).attr('type') != 'hidden')
                        status = 'yellow'
                }
            });
            if (countreq == 0 && countfilled > 0)
                status = 'green';

            $('a[href="#' + $(this).attr('id') + '"]').parent().removeClass('statusIndicator-red');
            $('a[href="#' + $(this).attr('id') + '"]').parent().removeClass('statusIndicator-yellow');
            $('a[href="#' + $(this).attr('id') + '"]').parent().removeClass('statusIndicator-green');
            $('a[href="#' + $(this).attr('id') + '"]').parent().addClass('statusIndicator-' + status);
            if (pageFuncs.AdmitClient !== 'undefined')
                pageFuncs.AdmitClient.CanAdmit();
        }
    });
}

function NotRequired(ctrl) {
    var currentGroup = isNullOrEmpty($(ctrl).GetObjectAttribute('group')) ? 'OtherControls' : $(ctrl).GetObjectAttribute('group');
    var tmpFormObj = undefined;
    var gfc = globalData.FormControls();

    if (gfc.Groups()[currentGroup] != undefined && gfc.Groups()[currentGroup].controls[$(ctrl).attr('id')] != undefined) {
        tmpFormObj = gfc.Groups()[currentGroup].controls[$(ctrl).attr('id')];
        if (tmpFormObj.reqstate != reqStates.NotRequired) {
            tmpFormObj.origreqstate = tmpFormObj.reqstate;
            $(ctrl).attr('origreqstate', tmpFormObj.reqstate);
            tmpFormObj.reqstate = reqStates.NotRequired;
            $(ctrl).attr('reqstate', reqStates.NotRequired);
        }
    }
}

function RestoreRequired(ctrl) {
    var currentGroup = isNullOrEmpty($(ctrl).GetObjectAttribute('group')) ? 'OtherControls' : $(ctrl).GetObjectAttribute('group');
    var tmpFormObj = undefined;
    var gfc = globalData.FormControls();

    if (gfc.Groups()[currentGroup] != undefined && gfc.Groups()[currentGroup].controls[$(ctrl).attr('id')] != undefined) {
        tmpFormObj = gfc.Groups()[currentGroup].controls[$(ctrl).attr('id')];
        if (tmpFormObj.reqstate == reqStates.NotRequired && !isNullOrEmpty(tmpFormObj.origreqstate)) {
            tmpFormObj.reqstate = tmpFormObj.origreqstate;
            $(ctrl).attr('reqstate', tmpFormObj.origreqstate);
        }
    }
}
/*Function
*This function is responsible for update the required lables in a page
*/
function createRequiredLabels(id, containers) {
    ///<param name="id">This is the id for the element being checked</param>
    ///<param name="container">This is the optional container to search</param>
    if (isNullOrEmpty(containers))
        containers = { doc: document };
    for (cKey in containers) {
        var container = containers[cKey];
        var ctrl = $(container).find('#' + id);
        if (!isNullOrEmpty(ctrl)) {
            var currentGroup = isNullOrEmpty($(ctrl).GetObjectAttribute('group')) ? 'OtherControls' : $(ctrl).GetObjectAttribute('group');
            var tmpFormObj = null;
            var gfc = globalData.FormControls();

            if (gfc.Groups()[currentGroup] != undefined && gfc.Groups()[currentGroup].controls[id] != undefined)
                tmpFormObj = gfc.Groups()[currentGroup].controls[id];

            if (!isNullOrEmpty(tmpFormObj)) {
                var baseID = id.split('_').length > 1 ? id.split('_')[1] : id;
                var additional = (id.split('_')[2] === undefined ? '' : id.split('_')[2]);
                var tmpId = 'req_' + baseID + (additional == 'additional' ? "_" + additional : '');

                var objLabel = null;
                if (typeof container.getElementById == 'function')
                    objLabel = container.getElementById(tmpId);
                else
                    objLabel = $(container).find('#' + tmpId).get(0);
                if (tmpFormObj.reqstate != reqStates.NotRequired) {
                    if (objLabel === null) {
                        objLabel = document.createElement('div');
                        objLabel.id = tmpId;
                        objLabel.innerHTML = tmpFormObj.reqmsg;
                        objLabel.attributes['for'] = id;
                        $(objLabel).css('float', 'right');
                        var pn = container.getElementById(id).parentNode;

                        if (id.split('_')[0] == 'dt') {
                            $(pn).css('float', 'left')
                            pn = pn.parentNode;
                        }

                        pn.appendChild(objLabel, $(ctrl).nextSibling);
                    }

                    if (isNullOrEmpty(tmpFormObj.cval) || ($(container).find('#' + id).attr('IsGuid') == 'true' && tmpFormObj.cval === guid.empty)) {
                        if (!$(objLabel).hasClass('required')) {
                            $(objLabel).html(isNullOrEmpty($(ctrl).GetObjectAttribute('reqmsg')) ? globalvars.reqmsg : $(ctrl).GetObjectAttribute('reqmsg'));
                            $(objLabel).addClass('required');
                        }
                    }
                    else {
                        if ($(objLabel).hasClass('required') || !isNullOrEmpty($(objLabel).html())) {
                            $(objLabel).html('');
                            $(objLabel).removeClass('required');
                        }
                    }

                    $(objLabel).attr('for', id);
                }
                else {
                    if (!isNullOrEmpty(objLabel)) {
                        if ($(objLabel).hasClass('required') || !isNullOrEmpty($(container).find('#' + tmpId).html())) {
                            $(objLabel).html('');
                            $(objLabel).removeClass('required');
                        }
                    }
                }
                break;
            }
        }
    }
}

