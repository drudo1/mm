//Global Reusable Functions

/*Public Function
*Sets a string value to ''
*/
var string = {
    Empty : function () {
        if (typeof (string) === 'undefined') { string = {}; }
        string.Empty = function () { return ""; };
    }
}

var guid = {
    empty: '00000000-0000-0000-0000-000000000000',
    random: function () {
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
                       .toString(16)
                       .substring(1);
        }
        return function () {
            return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                   s4() + '-' + s4() + s4() + s4();
        };
    },
    isGuid : function(value) {
        var validGuid = /^(\{|\()?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}(\}|\))?$/;
        var emptyGuid = /^(\{|\()?0{8}-(0{4}-){3}0{12}(\}|\))?$/;
        return validGuid.test(value) && !emptyGuid.test(value);
    },
    /*Function returns true/false
    *Test a guid to see if it is a non empty guid
    */
    isNonEmptyGuid: function (value) {
        ///<param name='value'>unqieidentifier - the variable being tested</param>
        var blNonEmptyGuid = true;

        if (isNullOrEmpty(value))
            value = guid.empty;

        if (!this.isGuid(value) || value == this.empty)
            blNonEmptyGuid = false;

        return blNonEmptyGuid;
    }
}

function objectCopy(source, target) {
    for (var key in source) {
        if (typeof source[key] === 'object' && source[key] != null) {
            if (target[key] == null)
                target[key] = {};
            objectCopy(source[key], target[key]);
        }
        else
            target[key] = source[key];
    }
}

/*Function
*Loops through the globalData.FormControls object and sets the correct field preferences
*based on control attributes.
*/
function ApplyFieldPrefs(objFieldPrefs) {
    if (isNullOrEmpty(objFieldPrefs))
        objFieldPrefs = globalData.FieldPrefs();
    if (objFieldPrefs != undefined && !isNullOrEmpty(objFieldPrefs)) {

        for (key in objFieldPrefs) {
            var objFieldPref = objFieldPrefs[key];

            var DefaultValue = objFieldPref.DefaultValue;
            var Label = objFieldPref.Label;
            var Override = Bool(objFieldPref.Override);
            var PageFieldId = objFieldPref.PageFieldID;
            var RequiredTypeID = objFieldPref.RequiredTypeID;
            var currentGroup = isNullOrEmpty($('#' + PageFieldId).GetObjectAttribute('group')) ? 'OtherControls' : $('#' + PageFieldId).GetObjectAttribute('group');

            $('#' + PageFieldId).attr('override', Override);
            $('#' + PageFieldId).attr('defaultval', DefaultValue);
            if (isNullOrEmpty(gfc.Groups()[currentGroup]) || isNullOrEmpty(gfc.Groups()[currentGroup].controls[PageFieldId])
                || (gfc.Groups()[currentGroup].controls[PageFieldId].reqstate == gfc.Groups()[currentGroup].controls[PageFieldId].origreqstate)) {

                if (!Bool($('#' + PageFieldId).GetObjectAttribute('prefapplied'))) {
                    var iControl = $('#' + PageFieldId);
                    
                    if (RequiredTypeID.toLowerCase() != $(iControl).attr('orgistate')) {
                        $(iControl).attr('reqstate', RequiredTypeID.toLowerCase());
                        $(iControl).attr('origstate', RequiredTypeID.toLowerCase());

                        $('#' + PageFieldId).attr('prefapplied', 'true');
                        if (gfc.Groups()[currentGroup] !== undefined && gfc.Groups()[currentGroup].controls[PageFieldId] !== undefined)
                            gfc.Groups()[currentGroup].controls[PageFieldId]['prefapplied'] = true;

                        gfc.updateControl(PageFieldId);
                    }                      
                }
                
            }                
            else
                $('#' + PageFieldId).attr('reqstate', reqStates.NotRequired);

            $('#' + PageFieldId).attr('origreqstate', RequiredTypeID.toLowerCase());


            var labelId = isNullOrEmpty($('#' + PageFieldId).GetObjectAttribute("labelid")) ? null : $('#' + PageFieldId).GetObjectAttribute("labelid");

            if (labelId != null && !isNullOrEmpty(Label)) {
                $('#' + labelId).text(Label);
            }
        }
        gfc.loadControls();
        updateTabStatus();
        if (typeof func === 'function')
            func();
    }
    else {
        updateTabStatus();
        if (typeof func === 'function')
            func();
    }
}

/*Public Function - returns bool (true/false)
*Determines if an object is null or empty.
*<param name="obj"></param> -- This is the value being tested.
*/
function isNullOrEmpty(obj) {
    if (obj === undefined || obj == null) return true;
    if ($.trim(obj) === "") return true;
    if (obj.length && obj.length > 0) return false;
    if (typeof obj == 'number') return false;
    if (typeof obj == 'boolean') return false;
    for (var prop in obj) if (obj[prop] || typeof (obj[prop]) == 'boolean' || typeof (obj[prop]) == 'string') return false;
    return true;
}

function isNull(check, sub) {
    var res = check;
    if (isNullOrEmpty(res))
        res = sub;
    if (isNullOrEmpty(res))
        res = '';
    return res;
}
/*Public function - returns bool (true/false)
*<param name="x"></param> - The value being tested.
*/
function Bool(x) {
    if (x === undefined || x === null)
        return false;
   
    if (x == true || x == false)
        return x;

    if (!Boolean(x)) {
        if (x == 0 || x.toLowerCase() == "false")
            return false;
        else if (x == 1 || x.toLowerCase == "true")
            return true;
    }
    else {
        if (x.toLowerCase() == "true")
            return true;
        else
            return false;
    }
    return x;
}

function Wordify(str) {
    if (!isNullOrEmpty(str))
        return str.replace(/([A-Z])/g, ' $1').replace(/^./, function (str) { return str.toUpperCase(); }).replace(/([A-Z]) /g, '$1');
    else return '';
}

function GetPageID(pageKey) {
    var dObj = data.new();
    dObj.Params.SetParams('GetPageID', 'name', pageKey, null);
    return dObj.call('GetPageID', false).data;
}

if (!String.format) {
    String.format = function (str, col) {
        col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);

        return str.replace(/\{\{|\}\}|\{(\w+)\}/g, function (m, n) {
            if (m == "{{") { return "{"; }
            if (m == "}}") { return "}"; }
            return col[n];
        });
    };
    String.prototype.format = function (col) { return String.format(this, col); }
}

/*Function Returns string
*This function returns values from the query string.
*<param name="name"></param> - This is the Parameter name 
*that you are searching for in the query string.
*/
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.href);
    if (results == null)
        return "";
    else
        return decodeURIComponent(results[1].replace(/\+/g, " "));
}

//This function is used to clone an object in order to 
//start with initilized values.
cloneObj = function (obj) {
    var tmpObj = obj;
    if (tmpObj != undefined && typeof tmpObj === "object") {
        return Object.create(tmpObj);
    }
}

loadCSS = function (href) {
    var cssLink = $("<link rel='stylesheet' type='text/css' href='"+href+"'>");
    $("head").append(cssLink); 
};

/*Class
*Captures Errors for writing to the console
*/
var errorLogs = {
    //Bool (true/false)  - Turns logging on/off
    DoLogTiming: true,
    /*Function
    *Captures the message and sends it to the consle.
    *<param a="message"></param> - The message to be sent to the console
    */
    LogMessage: function (message) {
        if (typeof console == "undefined" || typeof console.log == "undefined")
            var x = message;
        else {
            //console.log(message);
        }

 //       log.info(message);
    },
     /*Function
    *Captures the error and sends it to the consle.
    *<param a="error"></param> - The error to be sent to the console
    */
    LogError: function (error) {
        if (typeof console == "undefined" || typeof console.log == "undefined")
            var x = error.statusText;
        else
            console.error('Error: ' + error.statusText);

        console.error('Stack Trace: ' + error.responseText);

 //       log.error(error.statusText);
        try {
 //           log.warn('Detail: ' + $('<div/>').html($(error.responseText).filter('title').html()).text());
  //          log.debug('Stack Trace: ' + $('<div/>').html($(error.responseText).find('code').eq(1).html()).text());
        }
        catch (e) {
            var obj = $.parseJSON(error.responseText);
  //          log.warn('Detail: ' + obj.Message);
   //         log.debug('Stack Trace: ' + obj.StackTrace);
        }
    },
    /*Function
    *Error logging timer 
    *
    *
    */
    LogTiming: function (methodName, state) {
        if (errorLogs.DoLogTiming)
            setTimeout(function () { errorLogs.LogMessage('Method "' + methodName + '" - ' + state + ': ' + DateFunc.DisplayTime()); }, 1000);
  //      log.profile('Method "' + methodName)
    },
    LoadFormError: function (text) {
        alert("There was an error loading the form.", "Please Contact FAMCare Support:<br />" + text);
        //TODO:  Needs to be a modal
    }
};

var DateFunc = {
    /*Function returns string (current time)
    *Returns the current time.
    *format(hours:minutes:seconds:milli);
    */
    DisplayTime: function () {
        var str = "";

        var currentTime = new Date();
        var hours = currentTime.getHours();
        var minutes = currentTime.getMinutes();
        var seconds = currentTime.getSeconds();
        var milli = currentTime.getMilliseconds();

        if (minutes < 10) {
            minutes = "0" + minutes
        }
        if (seconds < 10) {
            seconds = "0" + seconds
        }
        str += hours + ":" + minutes + ":" + seconds + "." + milli;
        return str;
    }
};




var DateHelper = {
    /*Function
    *Calculates the interval between date1 and date2
    */
    getDateDiff: function (date1, date2, interval) {
        ///<param name="date1">Starting Date</param>
        ///<param name="date2">Ending Date</param>
        ///<param name="interval">years, months, weeks, days, hours, minutes, seconds</param>

        var second = 1000,
        minute = second * 60,
        hour = minute * 60,
        day = hour * 24,
        week = day * 7;
        date1 = new Date(date1).getTime();
        date2 = (date2 == 'now') ? new Date().getTime() : new Date(date2).getTime();
        var timediff = date2 - date1;
        if (isNaN(timediff)) return NaN;
        switch (interval) {
            case "years":
                return date2.getFullYear() - date1.getFullYear();
            case "months":
                return ((date2.getFullYear() * 12 + date2.getMonth()) - (date1.getFullYear() * 12 + date1.getMonth()));
            case "weeks":
                return Math.floor(timediff / week);
            case "days":
                return Math.floor(timediff / day);
            case "hours":
                return Math.floor(timediff / hour);
            case "minutes":
                return Math.floor(timediff / minute);
            case "seconds":
                return Math.floor(timediff / second);
            default:
                return undefined;
        }
    },
    /*Function
    *Returns todays date.
    */
    Today: new Date(),
    /*Function
    *Returns Date only in formate MM/DD/YYYY
    */
    GetTodaysDate: function () {
        var newDate = new Date().format('mm/dd/yyyy');

        return newDate;
    },
    /*Function
    *Returns The Time Only
    */
    GetTime: function () {
        return DateFunc.DisplayTime();
    },
    /*Function
    *Returns Date and Time in the form of : Tue Sep 16 2014 09:19:13 GMT-0500 (Central Standard Time).
    */
    GetDateTime: function(){
        return new Date();
    },
    ToUniversalTicks: function (dt) {
        return (dt.getTime() * 10000) + 621355968000000000;
    },
    FromUniversalTicks: function (dt) {
        return new Date((dt - 621355968000000000) / 10000);
    },
    /*Function returns bool (true/false)
    *Test a given value to see if that value is a date.
    *<param name="id"></param> - Id is the control id
    */
    CheckDate: function (id) {
        var tmpVal = $('#' + id).val();
        return this.isDate(tmpVal);
    },
    isDate: function (tmpVal) {
        var isdate = false;
        if ($.type(tmpVal) === 'date')
        {
            isdate = true;
        }
        else
        {
            if (!isNullOrEmpty(tmpVal)) {
                var aryDateTime = split(tmpVal, ' ');

                var intADTLength = aryDateTime.length;

                if (intADTLength <= 3) {

                    var err = 0
                    a = aryDateTime[0];

                    if (a.length > 0) {
                        if (a.length < 10) {
                            isdate = false;
                        }
                        else {
                            var aryDate = a.split("/");
                            var strNewDateString = "";
                            if (a.length != 10) {
                                if (aryDate[0] < 10 && aryDate[0].length < 2)
                                    aryDate[0] = "0" + aryDate[0];

                                if (aryDate[1] < 10 && aryDate[1].length < 2)
                                    aryDate[1] = "0" + aryDate[1]

                                strNewDateString = aryDate[0] + "/" + aryDate[1] + "/" + aryDate[2];
                                a = strNewDateString;
                            }

                            if (a.length != 10) err = 1
                            b = a.substring(0, 2)// month
                            c = a.substring(2, 3)// '/'
                            d = a.substring(3, 5)// day
                            e = a.substring(5, 6)// '/'
                            f = a.substring(6, 10)// year
                            if (!$.isNumeric(b)) err = 1
                            if (!$.isNumeric(d)) err = 1
                            if (!$.isNumeric(f)) err = 1
                            if (b < 1 || b > 12) err = 1
                            if (d < 1 || d > 31) err = 1
                            if (f < 1900) err = 1
                            if (b == 4 || b == 6 || b == 9 || b == 11) {
                                if (d == 31) err = 1
                            }
                            if (b == 2) {
                                var g = parseInt(f / 4)
                                if (isNaN(g)) {
                                    err = 1
                                }
                                if (d > 29) err = 1
                                if (d == 29 && ((f / 4) != parseInt(f / 4))) err = 1
                            }
                            if (err == 1) {
                                isdate = false;
                            }
                            else
                                isdate = true;
                        }
                    }
                }
                else {
                    isdate = false;
                }
            }
            else
                isdate = false;
        }
        
        return isdate;
    },
    /*Function returns <=>
    *
    */
    CompareTwoDates: function (Start, End) {
        ///<param name="Start">The start date</param>
        ///<param name="End">The end date</param>
        var rtnVal = dates.compare(Start, End);
        var strCompare = "";

        if (rtnVal == -1) {
            //Start Date is Less than the End Date
            strCompare = "<";
        }
        else if (rtnVal == 0) {
            //Start Date is the same as the End Date
            strCompare = "=";
        }
        else if (rtnVal == 1) {
            //Stat Date is Less than the End Date
            strCompare = ">";
        }
        else if (rtnVal == "NAN") {
            // one of the values is null
            strCompare = "";
        }

        return strCompare;
    },
    isTime:function(ti){
        var matches = ti.match(/^(\d\d):(\d\d)\s?(?:AM|PM)?$/);
        if (matches == null)
            matches = ti.match(/^(\d):(\d\d)\s?(?:AM|PM)?$/);

        var blIsTime = false;
        if (this.isTimeTwelveHour(ti)) {
            blIsTime = true;
        }
        else {
            if (matches && matches.length == 3) {
                var h = parseInt(matches[1], 10)
                var m = parseInt(matches[2], 10)
                // range checks done in code after getting numeric value
                if (h >= 1 && h <= 23 && m >= 0 && m <= 59)
                    blIsTime = true;
            }
        }

        return blIsTime;
    },
    /*Function returns bool
    *Function checks if time is a 12 hour time with AM/PM
    */
    isTimeTwelveHour: function (inp) {
        // regex used for "high level" check and extraction
        // matches "hh:mmAM", "hh:mm", "hh:mm PM", etc
        var matches = inp.match(/^(\d\d):(\d\d)\s?(?:AM|PM)?$/)
        if (matches && matches.length == 3) {
            var h = parseInt(matches[1], 10)
            var m = parseInt(matches[2], 10)
            // range checks done in code after getting numeric value
            return h >= 1 && h <= 12 && m >= 0 && m <= 59
        } else {
            return false
        }
    },

    /*Function returns string
    *Function returns the time portion of the date time var passed in format (hours:minutes AM/PM)
    */
    DisplayTimeAMPM: function (iTime) {
        /*Function returns string (time passed in on the date time var passed in)
        *Returns the time on the date time var passed in.
        *format(hours:minutes AM/PM);
        */
        var displayTime;
        if ($.type(iTime) === 'string')
        {
            var myIntTest = iTime.substr(6);
            myIntTest = myIntTest.substring(0, myIntTest.length - 2);
            if (!isNullOrEmpty(myIntTest) && $.isNumeric(myIntTest))
            {
                iTime = new Date(parseInt(myIntTest));
            }
        }

        if ($.type(iTime) === 'date') {
            var hours = iTime.getHours() > 12 ? (iTime.getHours() - 12) : iTime.getHours();
            var minutes = iTime.getMinutes() < 10 ? ('0' + iTime.getMinutes()) : iTime.getMinutes();
            var amPM = iTime.getHours() > 12 ? 'PM' : 'AM';

            displayTime = hours + ':' + minutes + ' ' + amPM;
        }
        else
        {
            displayTime = 'not a datetime';
        }

        return displayTime;
    },

    /*Function returns string
    *Function returns the time portion of the date time var passed in format (hours:minutes AM/PM)
    */
    DisplayDisplayDate: function (iTime) {
        /*Function returns string (time passed in on the date time var passed in)
        *Returns the time on the date time var passed in.
        *format(hours:minutes AM/PM);
        */
        var displayTime;
        //if ($.type(iTime) === 'string') {
        //    var myIntTest = iTime.substr(6);
        //    myIntTest = myIntTest.substring(0, myIntTest.length - 2);
        //    if (!isNullOrEmpty(myIntTest) && $.isNumeric(myIntTest)) {
        //        iTime = new Date(parseInt(myIntTest));
        //    }
        //}

        if ($.type(iTime) === 'date') {
            var years = iTime.getFullYear();
            var months = (iTime.getMonth() + 1) < 10 ? ('0' + (iTime.getMonth() + 1)) : (iTime.getMonth() + 1);
            var dayOfMonth = iTime.getUTCDate() < 10 ? ('0' + iTime.getUTCDate()) : iTime.getUTCDate();
            var hours = iTime.getHours() > 12 ? (iTime.getHours() - 12) : iTime.getHours();
            var minutes = iTime.getMinutes() < 10 ? ('0' + iTime.getMinutes()) : iTime.getMinutes();
            var amPM = iTime.getHours() > 12 ? 'PM' : 'AM';


            displayTime = months + '/' + dayOfMonth + '/' + years;
        }
        else {
            displayTime = 'not a datetime';
        }

        return displayTime;
    },

    /*Function returns string
    *Function returns the time portion of the current date time in format (hours:minutes AM/PM)
    */
    DisplayCurrentTimeAMPM: function () {
        /*Function returns string ()
        *Returns the time on the current date time.
        *format(hours:minutes AM/PM);
        */
        var currentDateTime = new Date();
        var hours = currentDateTime.getHours() > 12 ? (currentDateTime.getHours() - 12) : currentDateTime.getHours();
        var minutes = currentDateTime.getMinutes() < 10 ? ('0' + currentDateTime.getMinutes()) : currentDateTime.getMinutes();
        var amPM = currentDateTime.getHours() > 12 ? 'PM' : 'AM';
        var currentTime = hours + ':' + minutes + ' ' + amPM;
        return currentTime;
    }
};

function SetupMultiSelect(sel) {
    if ($(sel).attr('multi') == 'true') {
        if ($(sel).find('option').length < 8) {
            $(sel).multipleSelect({
                single: false,
                filter: false,
                multiple: false,
                allSelected: false,
                width: 300,
                multipleWidth: 250
            });
        }
        else if ($(sel).find('option').length < 20) {
            $(sel).multipleSelect({
                single: false,
                filter: false,
                multiple: true,
                allSelected: false,
                width: 500,
                multipleWidth: 150
            });
        }
        else {
            $(sel).multipleSelect({
                single: false,
                filter: true,
                multiple: true,
                allSelected: false,
                width: 500,
                multipleWidth: 150
            });
        }
    }
    else {
        if ($(sel).find('option').length < 8) {
            $(sel).multipleSelect({
                single: true,
                filter: false,
                multiple: false,
                allSelected: false,
                width: 300
            });
        }
        else if ($(sel).find('option').length < 20) {
            $(sel).multipleSelect({
                single: true,
                filter: false,
                multiple: true,
                allSelected: false,
                width: 500,
                multipleWidth: 150
            });
        }
        else {
            $(sel).multipleSelect({
                single: true,
                filter: true,
                multiple: true,
                allSelected: false,
                width: 500,
                multipleWidth: 150
            });
        }
    }
}

// Avoid running twice; that would break the `nativeSplit` reference
var split = split || function (undef) {

    var nativeSplit = String.prototype.split,
        compliantExecNpcg = /()??/.exec("")[1] === undef, // NPCG: nonparticipating capturing group
        self;

    self = function (str, separator, limit) {
        // If `separator` is not a regex, use `nativeSplit`
        if (Object.prototype.toString.call(separator) !== "[object RegExp]") {
            return nativeSplit.call(str, separator, limit);
        }
        var output = [],
            flags = (separator.ignoreCase ? "i" : "") +
                    (separator.multiline ? "m" : "") +
                    (separator.extended ? "x" : "") + // Proposed for ES6
                    (separator.sticky ? "y" : ""), // Firefox 3+
            lastLastIndex = 0,
            // Make `global` and avoid `lastIndex` issues by working with a copy
            separator = new RegExp(separator.source, flags + "g"),
            separator2, match, lastIndex, lastLength;
        str += ""; // Type-convert
        if (!compliantExecNpcg) {
            // Doesn't need flags gy, but they don't hurt
            separator2 = new RegExp("^" + separator.source + "$(?!\\s)", flags);
        }
        /* Values for `limit`, per the spec:
         * If undefined: 4294967295 // Math.pow(2, 32) - 1
         * If 0, Infinity, or NaN: 0
         * If positive number: limit = Math.floor(limit); if (limit > 4294967295) limit -= 4294967296;
         * If negative number: 4294967296 - Math.floor(Math.abs(limit))
         * If other: Type-convert, then use the above rules
         */
        limit = limit === undef ?
            -1 >>> 0 : // Math.pow(2, 32) - 1
            limit >>> 0; // ToUint32(limit)
        while (match = separator.exec(str)) {
            // `separator.lastIndex` is not reliable cross-browser
            lastIndex = match.index + match[0].length;
            if (lastIndex > lastLastIndex) {
                output.push(str.slice(lastLastIndex, match.index));
                // Fix browsers whose `exec` methods don't consistently return `undefined` for
                // nonparticipating capturing groups
                if (!compliantExecNpcg && match.length > 1) {
                    match[0].replace(separator2, function () {
                        for (var i = 1; i < arguments.length - 2; i++) {
                            if (arguments[i] === undef) {
                                match[i] = undef;
                            }
                        }
                    });
                }
                if (match.length > 1 && match.index < str.length) {
                    Array.prototype.push.apply(output, match.slice(1));
                }
                lastLength = match[0].length;
                lastLastIndex = lastIndex;
                if (output.length >= limit) {
                    break;
                }
            }
            if (separator.lastIndex === match.index) {
                separator.lastIndex++; // Avoid an infinite loop
            }
        }
        if (lastLastIndex === str.length) {
            if (lastLength || !separator.test("")) {
                output.push("");
            }
        } else {
            output.push(str.slice(lastLastIndex));
        }
        return output.length > limit ? output.slice(0, limit) : output;
    };

    // For convenience
    String.prototype.split = function (separator, limit) {
        return self(this, separator, limit);
    };

    return self;

}();


/*Function
*Used to Format Dates
*/
var dateFormat = function () {
    var token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
        timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
        timezoneClip = /[^-+\dA-Z]/g,
        pad = function (val, len) {
            val = String(val);
            len = len || 2;
            while (val.length < len) val = "0" + val;
            return val;
        };

    // Regexes and supporting functions are cached through closure
    return function (date, mask, utc) {
        var dF = dateFormat;

        // You can't provide utc if you skip other args (use the "UTC:" mask prefix)
        if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
            mask = date;
            date = undefined;
        }

        // Passing date through Date applies Date.parse, if necessary
        date = date ? new Date(date) : new Date;
        //if (isNaN(date)) throw SyntaxError("invalid date");

        if (isNaN(date)) return;

        mask = String(dF.masks[mask] || mask || dF.masks["default"]);

        // Allow setting the utc argument via the mask
        if (mask.slice(0, 4) == "UTC:") {
            mask = mask.slice(4);
            utc = true;
        }

        var _ = utc ? "getUTC" : "get",
            d = date[_ + "Date"](),
            D = date[_ + "Day"](),
            m = date[_ + "Month"](),
            y = date[_ + "FullYear"](),
            H = date[_ + "Hours"](),
            M = date[_ + "Minutes"](),
            s = date[_ + "Seconds"](),
            L = date[_ + "Milliseconds"](),
            o = utc ? 0 : date.getTimezoneOffset(),
            flags = {
                d: d,
                dd: pad(d),
                ddd: dF.i18n.dayNames[D],
                dddd: dF.i18n.dayNames[D + 7],
                m: m + 1,
                mm: pad(m + 1),
                mmm: dF.i18n.monthNames[m],
                mmmm: dF.i18n.monthNames[m + 12],
                yy: String(y).slice(2),
                yyyy: y,
                h: H % 12 || 12,
                hh: pad(H % 12 || 12),
                H: H,
                HH: pad(H),
                M: M,
                MM: pad(M),
                s: s,
                ss: pad(s),
                l: pad(L, 3),
                L: pad(L > 99 ? Math.round(L / 10) : L),
                t: H < 12 ? "a" : "p",
                tt: H < 12 ? "am" : "pm",
                T: H < 12 ? "A" : "P",
                TT: H < 12 ? "AM" : "PM",
                Z: utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
                o: (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
                S: ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
            };

        return mask.replace(token, function ($0) {
            return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
        });
    };
}();
// Some common format strings
dateFormat.masks = {
    "default": "ddd mmm dd yyyy HH:MM:ss",
    shortDate: "m/d/yy",
    mediumDate: "mmm d, yyyy",
    longDate: "mmmm d, yyyy",
    fullDate: "dddd, mmmm d, yyyy",
    shortTime: "h:MM TT",
    mediumTime: "h:MM:ss TT",
    longTime: "h:MM:ss TT Z",
    isoDate: "yyyy-mm-dd",
    isoTime: "HH:MM:ss",
    isoDateTime: "yyyy-mm-dd'T'HH:MM:ss",
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};
// Internationalization strings
dateFormat.i18n = {
    dayNames: [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ],
    monthNames: [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
};

// For convenience...
Date.prototype.format = function (mask, utc) {
    return dateFormat(this, mask, utc);
};
Date.prototype.getDOY = function () {
    var year = (this.getFullYear()) * 1000;
    var oneJan = new Date(this.getFullYear(), 0, 1);
    return Math.ceil((this - oneJan) / 86400000) + year;
};

/*Function
*Clears a select list
*example: $('#' + this.id).ClearList();
*/
(function ($) {
    $.fn.isReallyVisible = function () {
        var blVisible = true;

        if ($(this).css("visibility") == "hidden" || $(this).css("display") == "none" || $(this).parents().css("display") == "none" || $(this).parents().css("visibility") == "hidden") {
            blVisible = false;
        }

        return blVisible;
    }
    $.fn.ClearList = function () {
        ///<signature>
        ///<summary>Used to remove all items in a drop down list.</summary>
        ///</signature>
      
        if (ListboxHelper.isList(this.id)) {
            $('#' + this.id).find('option').remove();

            if (Bool($('#' + this.id).GetObjectAttribute('addselectone'))) {
                $('#' + this.id).addOption('', '-- Select One --', false);
            }
        }
    };

    $.fn.buildObject = function () {
        var obj = {};
        $(this).find('[dbcol]').each(function () {
            obj[$(this).attr('dbcol')] = $(this).val();
        });
        return obj;
    };

    $.fn.makeMe = function () {
        this.buildObject();
    };

    $.fn.Die = function () {
        delete this;
    };
})(jQuery);


(function ($) {
    $.fn.AddEventFunction = function (event, key, func) {
        ///<signature>
        ///<summary>Adds a function call to an event bind.  event: click, change, etc...  MUST have a group attribute set for this function to work.</summary>
        ///<param name="event" type="String">Event types: change, click, keydown, keyup, etc.</param>
        ///<param name="key" type="String">The name for the function you are creating</param>
        ///<param name="func" type="Function">The function to be called</param>
        ///</signature>

        $(this).each(function () {
            var objId = this.id;
            if ($.isArray(event)) {
                for (var i = 0; i < event.length; i++) {
                    gfc.AddControlFunc(objId, event[i], key, func);
                }
            }
            else
                gfc.AddControlFunc(objId, event, key, func);
        });
    };
})(jQuery);


(function ($) {
    $.fn.makeEditable = function () {
        if ($(this).is('div.webContent')) {
            var img = document.createElement('img');
            img.src = '../../images/pencil.png';
            img.setAttribute('style', 'height:16px; width:16px;');
            img.setAttribute('target', $(this).attr('id'));
            var key = $(this).attr('key');
            var target = $(this).attr('id');
            $(img).click(function () {
                tinymce.init({
                    selector: '#' + $(this).attr('target'),
                    plugins: [
                        "advlist autolink lists link image charmap print preview anchor",
                        "textcolor",
                        "searchreplace visualblocks code fullscreen",
                        "insertdatetime media table contextmenu paste"
                    ],
                    toolbar: "insertfile undo redo | styleselect | bold italic | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | btnSaveEditable btnCancelEditable",
                    setup: function (editor) {
                        editor.addButton('btnSaveEditable', {
                            text: 'Save',
                            icon: false,
                            onclick: function () {
                                var dObj = data.new();
                                dObj.Params.SetParams('UpdateWebContent', 'PageID', pageSecurity.PageID, null);
                                dObj.Params.SetParams('UpdateWebContent', 'key', key, null);
                                dObj.Params.SetParams('UpdateWebContent', 'content', editor.getContent(), null);
                                if (dObj.call('UpdateWebContent', true).success)
                                    location.reload();
                            }
                        });
                        editor.addButton('btnCancelEditable', {
                            text: 'Cancel',
                            icon: false,
                            onclick: function () {
                                location.reload();
                            }
                        });
                    }
                });
                $(this).remove();
            });
            $(this).after(img);
        }
    };
    $.fn.loadContent = function () {
        if ($(this).is('div.webContent')) {
            var dObj = data.new();
            dObj.Params.SetParams('GetWebContent', 'key', $(this).attr('key'), null);
            dObj.Params.SetParams('GetWebContent', 'PageID', pageSecurity.PageID, null);
            var result = dObj.call('GetWebContent', true);
            if (result.success)
                $(this).html(result.data);
        }
    };
})(jQuery);

/*Function
*Gets an attribute from an object.
*example: $('#txt_Name').GetObjectAttribute('dbcol');
*/
(function ($) {
    $.fn.GetObjectAttribute = function (attribute) {
        ///<signature>
        ///<summary>Gets an attribute of an element by attribute name.  Returns null if it doesn't exist</summary>
        ///<param name="attribute" type="String">The attribute you are looking for in the control.</param>
        ///</signature>
        var aryCtrlAttr = new Array();
        if (typeof $(this)[0] != 'undefined')
            aryCtrlAttr = $(this)[0].attributes;

        var lngCtrlAttr = (isNullOrEmpty(aryCtrlAttr) ? 0 : aryCtrlAttr.length);

        var objCtrlAttr = {};

        for (var i = 0; i < lngCtrlAttr; i++) {
            var tmpOpt = aryCtrlAttr[i];
            var attrName = tmpOpt.nodeName;
            var attrVal = tmpOpt.value;

            objCtrlAttr[attrName] = attrVal;
        }

        if (typeof objCtrlAttr[attribute] == 'undefined')
            objCtrlAttr[attribute] = null;

        return objCtrlAttr[attribute];
    };
    $.fn.GetAllAttributes = function () {
        ///<signature>
        ///<summary>Gets an attribute of an element by attribute name.  Returns null if it doesn't exist</summary>
        ///<param name="attribute" type="String">The attribute you are looking for in the control.</param>
        ///</signature>
        var aryCtrlAttr = new Array();
        if (typeof $(this)[0] != 'undefined')
            aryCtrlAttr = $(this)[0].attributes;

        var lngCtrlAttr = (isNullOrEmpty(aryCtrlAttr) ? 0 : aryCtrlAttr.length);

        var objCtrlAttr = {};

        for (var i = 0; i < lngCtrlAttr; i++) {
            var tmpOpt = aryCtrlAttr[i];
            var attrName = tmpOpt.nodeName;
            var attrVal = tmpOpt.value;

            objCtrlAttr[attrName] = attrVal;
        }

        return objCtrlAttr;
    };

})(jQuery);



// Source: http://stackoverflow.com/questions/497790
var dates = {
    convert: function (d) {
        // Converts the date in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.
        return (
            d.constructor === Date ? d :
            d.constructor === Array ? new Date(d[0], d[1], d[2]) :
            d.constructor === Number ? new Date(d) :
            d.constructor === String ? new Date(d) :
            typeof d === "object" ? new Date(d.year, d.month, d.date) :
            NaN
        );
    },
    compare: function (a, b) {
        // Compare two dates (could be of any type supported by the convert
        // function above) and returns:
        //  -1 : if a < b
        //   0 : if a = b
        //   1 : if a > b
        // NaN : if a or b is an illegal date
        // NOTE: The code inside isFinite does an assignment (=).
        return (
            isFinite(a = this.convert(a).valueOf()) &&
            isFinite(b = this.convert(b).valueOf()) ?
            (a > b) - (a < b) :
            NaN
        );
    },
    inRange: function (d, start, end) {
        // Checks if date in d is between dates in start and end.
        // Returns a boolean or NaN:
        //    true  : if d is between start and end (inclusive)
        //    false : if d is before start or after end
        //    NaN   : if one or more of the dates is illegal.
        // NOTE: The code inside isFinite does an assignment (=).
        return (
             isFinite(d = this.convert(d).valueOf()) &&
             isFinite(start = this.convert(start).valueOf()) &&
             isFinite(end = this.convert(end).valueOf()) ?
             start <= d && d <= end :
             NaN
         );
    }
}

var CheckDate = function(date) {

    date = date.replace(/[^0-9 +]/g, '');

    //Create date
    var myDate = new Date(parseInt(date));
    };

/*Class
*Contains Functions for Url validation and forming
*/
var HttpContext = {
    /*Private Function returns string
    *Gets the current protocol. (http/https)
    */
    Protocol: function () {
        var protocol = string.Empty();
        if (typeof window.location.protocol != 'undefined')
            protocol = window.location.protocol
        return protocol;
    },
    /*Private Function returns string
    *Gets the hostname i.e.(google.com)
    */
    Hostname: function () {
        var host = string.Empty();
        if (typeof window.location.hostname != 'undefined')
            host = window.location.hostname;
        return host;
    },
    /*Private Function returns string
    *Returns any ports. i.e. :80
    */
    Port: function () {
        var port = string.Empty();
        if (typeof window.location.port != 'undefined')
            port = window.location.port;

        return port;
    },
    /*Private Function returns string
    *Returns the complete path.
    *i.e. (/scripts/)
    */
    PathName: function () {
        var path = string.Empty();

        if (typeof window.location.pathname != 'undefined')
            path = window.location.pathname;

        return path;
    },
    /*Private Function returns string
    *Function builds the entire url based on (x)
    *<param name="x"></param> - x is the page name/location.
    *i.e.: ../scripts/test.js or test.js
    */
    BuildPath: function (x) {
        var path = "";
        var ServPath = '';
        if (!isNullOrEmpty(x)) {
            var dir = HttpContext.PathName();
            if (dir.charAt(0) == '/') {
                var length = dir.length;
                if (typeof dir != 'undefined' && typeof dir.substring(1, length) != 'undefined')
                    dir = dir.substring(1, length);
            }

            if (dir.charAt(length) == '/') {
                var length = dir.length;
                if (typeof dir != 'undefined' && typeof dir.substring(0, (length - 1)) != 'undefined')
                    dir = dir.substring(0, (length - 1));
            }

            var objDir = dir.split('/');
            var cntOdir = objDir.length;

            ServPath = HttpContext.Protocol() + "//" + HttpContext.Hostname() + (isNullOrEmpty(HttpContext.Port()) ? string.Empty() : ":" + HttpContext.Port()) + '/MunchkinMonitor';

            if ((objDir[(cntOdir - 1)].match(/\./g) || []).length > 0) {
                cntOdir--;
            }

            var cntHttp = (x.match(/http/g) || []).length;
            var cntUpDir = (x.match(/\.\./g) || []).length;

            if (cntHttp > 0) {
                var ServPath = string.Empty();
                if (typeof x != 'undefined')
                    ServPath = x;
            }
            else {
                if (x.substring(0, 1) == '/')
                    x = x.substring(1, x.length);
                else if (x.substring(0, 2) == '~/')
                    x = x.substring(2, x.length);
                else {
                    for (var i = 0; i < (objDir.length - cntUpDir) ; i++) {
                        if (i < cntOdir) {
                            if (!isNullOrEmpty(path) && typeof path != 'undefined') {
                                path += '/';
                            }

                            if (typeof objDir[i] != 'undefined')
                                path += objDir[i];
                        }
                    }
                }

                if (!isNullOrEmpty(path) && typeof path != 'undefined') {
                    ServPath += '/' + path;
                }

                ServPath += '/' + x;
            }

        }

        return ServPath.replace('undefined', '');
    },
    /*Public Function
    *Returns url based on (x)
    *<param name="x"></param> - x is the page name/location.
    *i.e.: ../scripts/test.js or test.js
    */
    ResolveUrl: function (x) {
        return HttpContext.BuildPath(x);
    }
};
/* ************************ END HTTP Context ********************************************* */

(function ($) {

    // JSON RegExp
    var rvalidchars = /^[\],:{}\s]*$/;
    var rvalidescape = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g;
    var rvalidtokens = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g;
    var rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g;
    var dateISO = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[.,]\d+)?Z/i;
    var dateNet = /\/Date\((\d+)(?:-\d+)?\)\//i;

    // replacer RegExp
    var replaceISO = /"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:[.,](\d+))?Z"/i;
    var replaceNet = /"\\\/Date\((\d+)(?:-\d+)?\)\\\/"/i;

    // determine JSON native support
    var nativeJSON = (window.JSON && window.JSON.parse) ? true : false;
    var extendedJSON = nativeJSON && window.JSON.parse('{"x":9}', function (k, v) { return "Y"; }) === "Y";

    var jsonDateConverter = function (key, value) {
        if (typeof (value) === "string") {
            if (dateISO.test(value)) {
                return new Date(value);
            }
            if (dateNet.test(value)) {
                return new Date(parseInt(dateNet.exec(value)[1], 10));
            }
        }
        return value;
    };

    $.extend({
        parseJSON: function (data, convertDates) {
            /// <summary>Takes a well-formed JSON string and returns the resulting JavaScript object.</summary>
            /// <param name="data" type="String">The JSON string to parse.</param>
            /// <param name="convertDates" optional="true" type="Boolean">Set to true when you want ISO/Asp.net dates to be auto-converted to dates.</param>
            convertDates = convertDates === false ? false : true;
            if (typeof data !== "string" || !data) {
                return null;
            }

            // Make sure leading/trailing whitespace is removed (IE can't handle it)
            data = $.trim(data);

            // Make sure the incoming data is actual JSON
            // Logic borrowed from http://json.org/json2.js
            if (rvalidchars.test(data
                .replace(rvalidescape, "@")
                .replace(rvalidtokens, "]")
                .replace(rvalidbraces, ""))) {
                // Try to use the native JSON parser
                if (extendedJSON || (nativeJSON && convertDates !== true)) {
                    return window.JSON.parse(data, convertDates === true ? jsonDateConverter : undefined);
                }
                else {
                    data = convertDates === true ?
                        data.replace(replaceISO, "new Date(parseInt('$1',10),parseInt('$2',10)-1,parseInt('$3',10),parseInt('$4',10),parseInt('$5',10),parseInt('$6',10),(function(s){return parseInt(s,10)||0;})('$7'))")
                            .replace(replaceNet, "new Date($1)") :
                        data;
                    return (new Function("return " + data))();
                }
            } else {
                $.error("Invalid JSON: " + data);
            }
        }
    });
})(jQuery);
(function ($) {
    /*Function
    *Hides the control and removes the required state
    */
    $.fn.hideAndNotRequired = function () {
        $(this).attr('reqstate', 'false');
        $(this).hide();
    }


    /*Function
    *Hides the control and label and removes the required state
    */
    $.fn.notRequiredAndHide = function () {
        NotRequired(this);
        var id = $(this).attr('id');
        this.attr('savetodb', 'false');
        this.attr('origgroup', this.attr('group'));
        this.removeAttr('group');
        $(this).hide();
        $("[for='" + id + "']").each(function () {
         $(this).hide();
        });
        checkReqLables(id);
    }
    /*Function
    *shows the control and sets the required state
    */
    $.fn.requiredAndShow = function () {
        RestoreRequired(this);
        var id = $(this).attr('id');
        this.attr('savetodb', 'true');
        if(!isNullOrEmpty(this.attr('origgroup')))
        {
            this.attr('group', this.attr('origgroup'));
        }
        $(this).show();
        $("[for='" + id + "']").each(function () {
            $(this).show();
        });
        
        gfc.updateControl(id);
        gfc.loadControls();
        createRequiredLabels(id, null);
        checkReqLables(id);
    }


    /*Function
    *shows the control and sets the required state
    */
    $.fn.showAndRequired = function () {
        $(this).attr('reqstate','true');
        $(this).show();
    }
    $.fn.ClearAndHideControl = function () {
        NotRequired(this);
        var inputType = this[0].type;
        switch (inputType) {
            case "select-one":
                $(this).val($(this).prop('defaultSelected'));
                SetupMultiSelect($(this));
                break;
            case "select-multiple":
                $(this).find('option').removeProp('selected');
                break;
            case "text":
                $(this).val('');
                break;
            default: break;
        }
        $(this).closest('tr').hide();
        $(this).closest('tr').next().hide();
        checkReqLables($(this).attr('id'));
    }
    $.fn.ShowControl = function () {
        RestoreRequired(this);
        $(this).closest('tr').show();
        $(this).closest('tr').next().show();
        checkReqLables($(this).attr('id'));
    }
    $.fn.ClearAndHideGroup = function () {
        var d = $(this).closest('div.well[title][id*="Grp"]');
        if (d.hasClass("CollapsePanel"))
            d = $(this).closest('.DPcollapsecontent_h');
        $(d).ClearAllControls();
        $(d).hide();
        createContainerReqLabels();
    }
    $.fn.RestoreRequiredAll = function () {
        $(this).find('input[name!="selectItem"],select,textarea').each(function () {
            RestoreRequired(this);
            checkReqLables($(this).attr('id'));
            createContainerReqLabels();
        });
    }
    $.fn.NotRequiredAll = function () {
        $(this).ClearAllControls();
    }
    $.fn.ClearAllControls = function() {
        $(this).find('input[name!="selectItem"],select,textarea').each(function () {
            NotRequired(this);
            var inputType = $(this)[0].type;
            switch (inputType) {
                case "select-one":
                    $(this).val($(this).prop('defaultSelected'));
                    if(!$(this).hasClass('excludeMulti'))
                        SetupMultiSelect($(this));
                    break;
                case "select-multiple":
                    $(this).find('option').removeProp('selected');
                    if (!$(this).hasClass('excludeMulti'))
                        SetupMultiSelect($(this));
                    break;
                case "text":
                case "textarea":
                case "hidden":
                    $(this).val('');
                    break;
                default: break;
            }
            checkReqLables($(this).attr('id'));
        });
    }
    $.fn.ShowAllControls = function (keepPosition) {
        ///<signature>
        ///<summary>Shows all controls in a given element that were hidden.</summary>
        ///<param name="keepPosition" type="Bool">Persist the layout.</param>
        ///</signature>
        $(this).find('input[name!="selectItem"],select,textarea').each(function () {
            RestoreRequired(this);
            if (!isNull(keepPosition, false)) {
                $(this).closest('tr').show();
                $(this).closest('tr').next().show();
            }
            else
                $(this).closest('tr').find('.td_hide').show();
            checkReqLables($(this).attr('id'));
        });
    }
    $.fn.HideAllControls = function (keepPosition) {
        ///<signature>
        ///<summary>Hides ALL controls for a given element.</summary>
        ///<param name="keepPosition" type="Bool">Pesist the layout.</param>
        ///</signature>
        $(this).find('input[name!="selectItem"],select,textarea').each(function () {
            NotRequired(this);
            var inputType = $(this)[0].type;
            switch (inputType) {
                case "select-one":
                    $(this).val($(this).prop('defaultSelected'));
                    if (!$(this).hasClass('excludeMulti'))
                        SetupMultiSelect($(this));
                    break;
                case "select-multiple":
                    $(this).find('option').removeProp('selected');
                    if (!$(this).hasClass('excludeMulti'))
                        SetupMultiSelect($(this));
                    break;
                case "text":
                case "textarea":
                case "hidden":
                    $(this).setVal('');
                    break;
                default: break;
            }
            if (!isNull(keepPosition, false)) {
                $(this).closest('tr').hide();
                $(this).closest('tr').next().hide();
            }
            else
                $(this).closest('tr').find('.td_hide').hide();
            checkReqLables($(this).attr('id'));
        });
    }
    $.fn.ShowGroup = function () {
        var d = $(this).closest('div.well[title][id*="Grp"]');
        if (d.hasClass("CollapsePanel"))
            d = $(this).closest('.DPcollapsecontent_h');
        $(d).RestoreRequiredAll();
        $(d).show();
    }
})(jQuery);
(function ($) {
    $.fn.BindYesNo = function (AddSelectOne, setSelectedValue) {
        var options = new Array({Key: 'Yes', Value: true}, {Key: 'No', Value: false});
        $(this).DataBind(options, 'Key', 'Value', AddSelectOne, null, isNullOrEmpty(setSelectedValue) ? '' : setSelectedValue);
    },

    $.fn.BindYesNoUnknown = function (AddSelectOne, setSelectedValue) {
        var options = new Array({ Key: 'Yes', Value: true }, { Key: 'No', Value: false }, { Key: 'Unknown', Value: '' });
        $(this).DataBind(options, 'Key', 'Value', AddSelectOne, null, isNullOrEmpty(setSelectedValue) ? '' : setSelectedValue);
    },

    $.fn.BindList = function (AddSelectOne, setSelectedValue, list) {
        var splitList = list.split(',');
        var options = new Array();
        for (listItem in splitList) {
            options.push({ Key: splitList[listItem], Value: splitList[listItem] });
        }
        $(this).DataBind(options, 'Key', 'Value', AddSelectOne, null, isNullOrEmpty(setSelectedValue) ? '' : setSelectedValue);
    },
    /*Select Option Addon
    *Used to dynamically load a select list.
    *DataSource = The data for the drop down list
    *TextField = The text displayed in the drop down
    *ValueField = The value of the selected option
    *AddSelectOne = bool (true/false) Adds a select one
    *setSelectedValue = string.  Selects the matching value
    */
      $.fn.DataBind = function (DataSource, TextField, ValueField, AddSelectOne, SelectOneValue, setSelectedValue, SelectOneText) {
          ///<signature>
          ///<summary>Adds a function call to an event bind.  event: click, change, etc...  MUST have a group attribute set for this function to work.</summary>
          ///<param name="DataSource" type="Object">Data Object Being loaded</param>
          ///<param name="TextField" type="String">The text being dispayed in the drop down list</param>
          ///<param name="ValueField" type="String">The vaue of the selected drop down list option</param>
          ///<param name="AddSelectOne" type="Bool">(true/false) Adds a select one to the option list</param>
          ///<param name="SelectOneValue" type="String">The value of the select one.  Typically null</param>
          ///<param name="setSelectedValue" type="String">The select option that needs to be selected.</param>
          ///<param name="SelectOneText" type="String">The select option that needs to be selected.</param>
          ///</signature>

          if (this.length > 0) {
              var id = this[0].id;
              if (isNullOrEmpty(id))
                  return false;

              var inputType = this[0].type;
              var blLoad = false;
              var blOk = true;

              if (isNullOrEmpty(TextField) || isNullOrEmpty(id)) {
                  blOk = false;
              }

              if (DataSource == undefined)
                  DataSource = new Array();

              switch (inputType) {
                  case "select-one":
                      blLoad = true;
                      break;
                  case "select-multiple":
                      blLoad = true;
                      break;
                  default: break;
              }

              if (blLoad && blOk) {
                  var lbh = ListboxHelper.new(id, DataSource, TextField, ValueField, AddSelectOne, SelectOneText, SelectOneValue, this);
                  lbh.Load();
                  if ($(this).attr('otherTarget') != undefined && $(this).attr('otherValue') != undefined)
                      lbh.InitOther();

                  if (typeof $(this).multipleSelect === "function" && !$(this).hasClass('excludeMulti'))
                      SetupMultiSelect($(this));

                  if(setSelectedValue !== undefined && setSelectedValue !== null)
                      $(this).setVal(setSelectedValue)
              }
          }
      }
    
    /*Select option Addon
    *Calls the generic options list service
    *Referes to the OptionsList in the database.
    */
    $.fn.getOptionListByOptionListKey = function (optionListKey, AddSelectOne, SelectOneValue, setSelectedValue, SelectOneText) {
        ///<signature>
        ///<summary>Adds a function call to an event bind.  event: click, change, etc...  MUST have a group attribute set for this function to work.</summary>
        ///<param name="optionListKey" type="string">The list key is the options group name</param>
        ///<param name="AddSelectOne" type="Bool">(true/false) Adds a select one to the option list</param>
        ///<param name="SelectOneValue" type="String">The value of the select one.  Typically null</param>
        ///<param name="setSelectedValue" type="String">The select option that needs to be selected.</param>
        ///<param name="SelectOneText" type="String">The select option that needs to be selected.</param>
        ///</signature>
        if (!isNullOrEmpty(optionListKey))
            $(this).DataBind(data.run("getOptionListByOptionListKey", 
                { 'optionListKey' : optionListKey}, null), 
                "DisplayText", "OptionValue", AddSelectOne, SelectOneValue, setSelectedValue, SelectOneText);
    }

    /*Select Option Addon
    *Clears the Select List
    */
    $.fn.Clear = function () {
        var id = $(this).GetObjectAttribute('id');;
        if (isNullOrEmpty(id))
            return false;

        var blLoad = false;
        var inputType = this[0].type;
        switch (inputType) {
            case "select-one":
                blClear = true;
                break;
            case "select-multiple":
                blClear = true;
                break;
            default: break;
        }

        var lbh = ListboxHelper.new();
        lbh.setId = id;
        lbh.Clear();
    }
    $.fn.getType = function () {
        var id = (isNullOrEmpty($(this).GetObjectAttribute('id')) ? null : $(this).GetObjectAttribute('id'));

        var InputType = 'undefind element';
        if (!isNullOrEmpty(id))
            InputType = this[0].type;

        return InputType;
    }
    $.fn.getVal = function () {
        var test = '';
        var objId = $(this).GetObjectAttribute('id');;
        var objInput = $('#' + objId);

        var InputType = $('#' + objId).getType();
        var CurrentValue = ""; //Is the actual input itself

        var aryControl = []; //Gets the type, name, order
        var dbcol = $('#' + objId).GetObjectAttribute('dbcol');
        if (typeof dbcol != 'undefined') {

            if (InputType == "text" || InputType == "password") {
                CurrentValue = $('#' + objId).val() == null ? '' : $('#' + objId).val();
            }
            else if (InputType == "select-one") {
                if ($('#' + objInput.id).GetObjectAttribute('selectedby') == "text") {
                    CurrentValue = $('#' + objId + ' option:selected').text();

                    if (CurrentValue == "-- Select One --")
                        CurrentValue = "";
                }
                else if ($('#' + objInput.id).GetObjectAttribute('multi') == "true")
                    CurrentValue = $('#' + objInput.id).multipleSelect("getSelects");
                else
                    CurrentValue = $('#' + objId + " option:selected").val() == null ? '' : $('#' + objId + " option:selected").val();
            }
            else if (InputType == "select-multiple") {
                    $('#' + objId).each(function () {
                    if ($('#' + objId + ' option:selected')) {
                        var delimitor = ','

                        if (CurrentValue != "")
                            CurrentValue += delimitor;

                        CurrentValue += $('#' + objId).val() == null ? '' : $('#' + objId).val();
                    }
                });

                if (CurrentValue == "-- Select One --")
                    CurrentValue = "";
            }
            else if (InputType == "checkbox") {
                //Need to test to see if it is in a group by grabbing the name and doing a count.
                var chkGroupName = (typeof objInput.name === 'undefined' ? null : objInput.name);
                if (!isNullOrEmpty(chkGroupName)) {
                    var blCheckCompare = false;

                    $('input:checkbox[name=' + chkGroupName + ']:checked').each(function () {
                        if (typeof $(objInput).val() != "undefined" && $(objInput).val() != null && $(objInput).val() != "on") {
                            if (CurrentValue != "")
                                CurrentValue += ',';

                            CurrentValue += $(objInput).val() == null ? '' : $(objInput).val();
                        }
                        else {
                            if (CurrentValue != "")
                                CurrentValue += ',';

                            CurrentValue += $('#' + objId).prop('checked') == true ? 'true' : 'false';
                        }
                    });
                }
                else {
                    chkGroupName = objId;
                    CurrentValue = $('#' + objId).prop('checked') == true ? 'true' : 'false';
                }
            }
            else if (InputType == "radio") {
                var chkGroupName = (typeof objInput.name === 'undefined' ? null : objInput.name);

                $('input:radio[name=' + chkGroupName + ']:checked').each(function () {
                    if ($('#' + objId).attr('checked', true)) {
                        if (CurrentValue != "")
                            CurrentValue += ',';

                        CurrentValue += $('#' + objId).val() == null ? '' : $('#' + objId).val();
                    }
                });
            }
            else if (InputType == "textarea") {
                CurrentValue = $('#' + objId).val();
            }
            else if (InputType == "hidden") {
                aryControl = (objId).split("_");
                CurrentValue = $('#' + objId).val() == null ? '' : $('#' + objId).val();
            }
        }

        return CurrentValue;
        ////Ending
    }
    $.fn.formatPhone = function () {
        return this.myString.replace(/\D/g, '').replace(/(\d{3})(\d{3})(\d{4})/, "($1)$2-$3");
    }
    $.fn.setVal = function (value) {
        var objId = $(this).GetObjectAttribute('id');
        var objInput = $(this);
        var InputType = $(this).getType();
        var CurrentValue = ""; //Is the actual input itself

        var aryControl = []; //Gets the type, name, order
        var dbcol = $(this).GetObjectAttribute('dbcol');
        if (typeof dbcol != 'undefined') {

            if (InputType == "text") {
                if (value instanceof Date)
                    $(this).val(value.format($(this).attr('data-date-format') ? $(this).attr('data-date-format').toLowerCase() : 'mm/dd/yyyy'));
                else
                    $(this).val(value);
                $(this).change();
            }
                
            if(InputType == "password") {
                $(this).val(value);
            }
            else if (InputType == "select-one" || InputType == "select-multiple") {
                $(this).find('option:eq(0)').prop('selected', true);
                var iVal = (isNullOrEmpty(value) ? '' : value);

                if (!isNullOrEmpty(value) && typeof value !== "boolean" && value.indexOf !== undefined && value.indexOf(',') != -1)
                    iVal = value.split(",");

                if (iVal.length == 1)
                    value = iVal[0];
                else if (iVal.length > 1)
                    value = iVal;

                if (!isNullOrEmpty(value) && $(this).attr('IsGuid') === 'true')
                    value = value.toLowerCase();
                if ($.isArray(value)) {
                    for (key in value) {
                        if (guid.isGuid(value[key]))
                            value[key] = value[key].toLowerCase();
                    }
                }

                if ($.isArray(value)) {
                    $(this).multipleSelect("setSelects", value);
                }
                else {
                    $(this).multipleSelect("setSelects", [isNull(value, '')]);
                }

                //$(this).multipleSelect("refresh");
                $(this).change();
            }
            //else if (InputType == "select-multiple") {
                //TODO:  Auto loading a multi-select box.

                //var arySelect = objInput.attributes;
                //var lngSelect = arySelect.length;

                //var objSelect = {};

                //for (var i = 0; i < lngSelect; i++) {
                //    var tmpOpt = arySelect[i];
                //    var attrName = tmpOpt.nodeName;
                //    var attrVal = tmpOpt.value;

                //    objSelect[attrName] = attrVal;
                //}

                //if (typeof objSelect.autoselect != 'undefined') {
                //    if (objSelect.autoselect == "All" && ListboxHelper.GetDDLSize(objId) > 0) {
                //        $('#' + objId + " option:not(:selected)").each(function () {
                //            $(objInput).attr('selected', 'selected');
                //        });
                //    }
                //}

                //$('#' + objId).each(function () {
                //    if ($('#' + objId + ' option:selected')) {
                //        var delimitor = ','

                //        if (CurrentValue != "")
                //            CurrentValue += delimitor;

                //        CurrentValue += $('#' + objId).val() == null ? '' : $('#' + objId).val();
                //    }
                //});

                //if (CurrentValue == "-- Select One --")
                //    CurrentValue = "";
            //}
            else if (InputType == "checkbox") {
                var chkGroupName = (typeof objInput.name === 'undefined' ? null : objInput.name);
                if (!isNullOrEmpty(chkGroupName)) {
                    $('input:checkbox[name=' + chkGroupName + ']:checked').each(function () {
                        if ($(this).val() == value)
                            $(this).attr('checked', true);
                    });
                }
                else {
                    if (Bool(value)) {
                        chkGroupName = objId;
                        $(this).attr('checked', value);
                    }
                    else {
                        if ($(this).val() == value)
                            $(this).attr('checked', true);
                    }
                }
            }
            else if (InputType == "radio") {
                //TODO
            }
            else if (InputType == "textarea") {
                $(this).val(value);
                $(this).change();
            }
            else if (InputType == "hidden") {
                $(this).val(value);
            }
            else if (InputType == "button") {
                $(this).attr('value', value);
            }
            else {
                $(this).html(value);
            }
        }
        ////Ending
    },
    $.fn.exists = function () {
        return this.length > 0;
    },
    $.fn.isGuid = function () {
        ///<signature>
        ///<summary>string - test the string to verify that the string is a guid.</summary>
        ///</signature>
        return guid.isGuid(this);
    }

})(jQuery)

//Used to dynamically load single/multi-select drop downs
var ListboxHelper = {
    __thisObj: function () {
        var obj = {
            __properties: {
                Id: null,
                ctrl: null,
                //This is the data object you want to load 
                //The Drop Down List with
                Data: null,
                //The information displayed in the drop down list on screen
                TextField: null,
                //The value member
                ValueField: null,
                //Adds Text='Select One' value=''
                AddSelectOne: false,
                ///Select One text. Defaults to "Select One"
                SelectOneText: null,
                ///Value of the select one. Typically null
                SelectOneValue: null,
                SetSelectedValue: null,
                self: null,
            },
            /*Function
            *Used to set the startint value of select list.
            */
            setSelectedValue:function(SetSelectedValue){
                ///<param name="SetSelectedValue">Default to this selected value once the list loads</param>
                this.__properties.SetSelectedValue = SetSelectedValue;
            },
            /*Function
            *Adds a select one to the list if set to true
            */
            AddSelectOne:function(AddSelectOne){
                ///<param name="AddSelectOne">Bool true/false  set to true to add a 'Select One' to the drop down list</param>
                this.__properties.AddSelectOne = Bool(AddSelectOne);
            },
            /*Function
            *This allows for an override for the default value of the 'Select One' option in the list.
            */
            setSelectOneValue: function(SelectOneValue){
                ///<param name="SelectOneValue">Used to set the default Select One Value</param>
                this.__properties.SelectOneValue = SelectOneValue;
            },
            /*Function
            *This allows for an override for the default text 'Select One'
            */
            setSelectOneText: function (SelectOneText) {
                ///<param name="SelectOneText">Used to set the default Select One Display Text</param>
                this.__properties.SelectOneText = SelectOneText;
            },
            /*Function 
            *Used to set the Text Display based on the data column in the data object
            */
            setTextField: function(TextField){
                ///<param name="TextField">The Key or column name for the text displayed in the list</param>
                if (!isNullOrEmpty(TextField))
                    this.__properties.TextField = TextField;
            },
            /*Function
            *Used to set the Value of the select item based on data column in the data object
            */
            setValueField: function(ValueField){
                ///<param name="ValueField">The Pair or column name for the value of a list item.</param>
                if (!isNullOrEmpty(ValueField))
                    this.__properties.ValueField = ValueField;
            },
            /*Function
            *This is the ctrl for this listbox
            */
            setCtrl: function (ctrl) {
                if (!isNullOrEmpty(ctrl)) {
                    this.__properties.ctrl = ctrl;
                    this.__properties.self = ctrl;
                }
            },
            /*Function
            *This is the id for this listbox
            */
            setId: function(id) {
                if (!isNullOrEmpty(id) && document.getElementById(id) != undefined) {
                    this.__properties.Id = id;
                    this.__properties.self = document.getElementById(id);
                }
            },
            getId: function () {
                return this.__properties.Id;
            },
            /*Function
            *This will append a new key/value pair manually.
            */
            append: function (TextField, TextValueField) {
                ///<param name="TextField">The Text you want to display</param>
                ///<param name="TextValueField">The value you want to save</param>
                var thisCtrl = (isNullOrEmpty(this.__properties.ctrl) ? $('#' + properties.Id) : $(this.__properties.ctrl))
                if (this.__properties.self != undefined && this.__properties.self != null) {
                    thisCtrl.addOption(TextValueField, TextField);
                }
            },
            /*Function
            *This is the data as it is recieved from the database.
            */
            setData:function(data) {
                if (!isNullOrEmpty(data) && data.length > 0)
                    this.__properties.Data = data;
            },
            /*Function
             *Loads a drop down list
             *<param name="id"></param>
             *
             */
            Load: function () {//id=Id of the dropdown list. addSelectOne=true/false
                var properties = this.__properties
                var addSelectOne = Bool(properties.AddSelectOne);
                var selectOneVal = (isNullOrEmpty(properties.SelectOneValue) ? '' : properties.SelectOneValue);

                results = properties.Data;

                var thisCtrl = (isNullOrEmpty(this.__properties.ctrl) ? $('#' + properties.Id) : $(this.__properties.ctrl))

                thisCtrl.removeOption(/./);

                if (results != null && results != undefined) {
                    if (results.length > 0 && properties.AddSelectOne) thisCtrl.addOption(selectOneVal, isNull(properties.SelectOneText, 'Select One'), false);
                    if (results.length == 0) {
                        thisCtrl.addOption(selectOneVal, 'No Options', true);
                        thisCtrl.prop('disabled', true);
                    }
                    else {
                        thisCtrl.prop('disabled', false);
                    }

                    for (var i = 0; i < results.length; i++) {
                        var sel = false;
                        var item = results[i];

                        var text = item[properties.TextField];
                        var val = guid.isGuid(item[properties.ValueField]) ? item[properties.ValueField].toLowerCase() : item[properties.ValueField];

                        if (properties.SetSelectedValue != '' && val == properties.SetSelectedValue) {
                            sel = true;
                        }

                        thisCtrl.addOption(val, text, sel);
                    }
                }
            },
            /*Public Function
            *Use this to clear the contents of a drop down list.
            */
            Clear: function () {
                var thisCtrl = (isNullOrEmpty(this.__properties.ctrl) ? $('#' + properties.Id) : $(this.__properties.ctrl))
                thisCtrl.removeOption(/./);
            },
            InitOther: function () {
                var thisCtrl = (isNullOrEmpty(this.__properties.ctrl) ? $('#' + properties.Id) : $(this.__properties.ctrl))
                if ($('.' + thisCtrl.attr('otherTarget')).attr('keepPosition') == 'true')
                    $('.' + thisCtrl.attr('otherTarget') + ' .td_hide').HideAllControls(true);
                else
                    $('.' + thisCtrl.attr('otherTarget')).HideAllControls();
                //var changeFunc = $('#' + $(this)[0].Data.Id).attr('onchange');
                thisCtrl.AddEventFunction('change', 'otherOptionFunc', function (id, event) {
                    if ($('.' + $('#' + id).attr('otherTarget')).first().attr('keepPosition') == 'true') {
                        if ($.inArray(isNull($('#' + id).val(), '').toLowerCase(), $('#' + id).attr('otherValue').toLowerCase().split(',')) > -1)
                            $('.' + $('#' + id).attr('otherTarget') + ' .td_hide').ShowAllControls(true);
                        else {
                            $('.' + $('#' + id).attr('otherTarget') + ' .td_hide').HideAllControls(true);
                            $('.' + $('#' + id).attr('otherTarget')).find('input').val('');
                        }
                    }
                    else {
                        if ($.inArray(isNull($('#' + id).val(), '').toLowerCase(), $('#' + id).attr('otherValue').toLowerCase().split(',')) > -1)
                            $('.' + $('#' + id).attr('otherTarget')).ShowAllControls(false);
                        else {
                            $('.' + $('#' + id).attr('otherTarget')).HideAllControls(false);
                            $('.' + $('#' + id).attr('otherTarget')).find('input').val('');
                        }
                    }
                });
                gfc.BindControlFuncs(this.__properties.Id);
            },
            GetDDLSize: function () {
                var ddlSize = $('#' + this.__properties.Id + ' option').size();
                return ddlSize;
            }
        }

        return obj
    },
    /*Function - returns bool true/false
    *Checks to see if it is a select or a multiselect
    */
    isList: function (id) {
        var type = $('#' + id).getType();
        var blIsList = false;

        if (type == 'select-one' || type == 'select-mulitple')
            blIsList = true;

        return blIsList;
    },
    /*Function
    *Creates a new instance of the listboxhelper
    */
    new: function (Id, Data, TextField, ValueField, AddSelectOne, SelectOneText, SelectOneValue, ctrl) {
        ///<param name='Id'>The id of the select element</param>
        ///<param name='Data'>This is the key/value pair data being used to load the select list</param>
        ///<param name='TextField'>This is the key pair value of the data being passed in.  Also know as the display text</param>
        ///<param name='ValueField'>This is the value pair of the option in the select list</param>
        ///<param name='AddSelectOne'>Bool true/false - set to true if you want to add a select one option to the list</param>
        ///<param name='SelectOneText'>This is the default text value of the select on option.  It overrides the default 'Select One'</param>
        ///<param name='SelectOneValue'>This is the default value of the select one text.  It overrides the default value of ''</param>
        var obj = this.__thisObj();
        if (!isNullOrEmpty(Id)){
            obj.setCtrl(ctrl);
            obj.setId(Id);
            obj.setData(Data);
            obj.setTextField(TextField);
            obj.setValueField(ValueField);
            obj.AddSelectOne(AddSelectOne);

            if (!isNull(SelectOneText))
                obj.setSelectOneText(SelectOneText);

            if (!isNull(SelectOneValue));
            obj.setSelectOneValue(SelectOneValue);            
        }

        return obj;
    }
};
/*Object
*Security Roles
*/
var Roles = {
    /*public function
    *Returns Boo true/false if current user is an admin.
    */
    IsAdministrator: function (objRoles) {
        ///<param name="objRoles">Roles Obeject</param>
        var blIsAdmin = false;
        var adminID = '489D8AF7-BC4A-4457-B545-F5BCFF43311E'

        for (var key in objRoles) {
            var objRole = objRoles[key];

            if (objRole.RoleID.toLowerCase() === adminID.toLowerCase()) {
                blIsAdmin = true;
            }
        }

        return blIsAdmin;
    },
    HasRole: function (role) {
        var result = false;
        if (!isNullOrEmpty(Session.objActiveSession) && !isNullOrEmpty(Session.objActiveSession.UserRoles)) {
            var adminID = '489D8AF7-BC4A-4457-B545-F5BCFF43311E';
            for (var key in Session.objActiveSession.UserRoles) {
                var objRole = Session.objActiveSession.UserRoles[key];
                if (objRole.RoleID.toLowerCase() === role.toLowerCase() || objRole.RoleID.toLowerCase() === adminID.toLowerCase() || objRole.Role.toLowerCase() === role.toLowerCase()) {
                    result = true;
                    break;
                }
            }
        }
        return result;
    }
};

autoSuggest = {
    /*Table Object
    *Contains the data for the table to be filtered.
    */
    LookUpTable: {},
    /* 
    *
    */
    SetFields: function (lookUpTableId, FieldId) {
        if (autoSuggest.LookUpTable[lookUpTableId] === undefined)
            autoSuggest.LookUpTable[lookUpTableId] = new Array();
       
        var blExist = false;
        for(var i=0; i < autoSuggest.LookUpTable[lookUpTableId].length; i++) {
            if (autoSuggest.LookUpTable[lookUpTableId][i] == FieldId)
                blExist = true;
        }

        if (!blExist)
            autoSuggest.LookUpTable[lookUpTableId].push(FieldId);
    
    }
};

loadContainerData = function (container, dataObj) {
    var cont = null;
    if (typeof container == 'string')
        cont = $('#' + container.replace('#', '')).get(0);
    else
        cont = container;
    if (cont != null) {
        $(cont).find('[dbcol]').each(function () {
            var tmpId = this.id;
            if ($(cont).find('#' + tmpId).is('[dbcol]')) {
                var prop = $(cont).find('#' + tmpId).attr('dbcol');
                if (prop in dataObj) {
                    $(cont).find('#' + tmpId).setVal(dataObj[prop]);
                }
            }
        });
    }
}

loadObjectFromContainer = function (dataObj, container) {
    var cont = null;
    if (typeof container == 'string')
        cont = $('#' + container.replace('#', '')).get(0);
    else
        cont = container;
    $(cont).find('[dbcol]').each(function () {
        var tmpId = this.id;
        if ($(cont).find('#' + tmpId).is('[dbcol]')) {
            var prop = $(cont).find('#' + tmpId).attr('dbcol');
            dataObj[prop] = $(cont).find('#' + tmpId).getVal();
        }
    });
}

loadForm = function (groupName, dataObj) {
    $('[group="' + groupName + '"]').each(function () {
        var tmpId = this.id;
        var tmpColName = $('#' + tmpId).GetObjectAttribute('dbcol');

        var blMatchFound = false;
        for (key in dataObj) {
            switch (key) {
                case tmpColName:
                    $('#' + tmpId).setVal(dataObj[key]);
                    var tmpVal = $('#' + tmpId).getVal();
                    if ($.isArray(tmpVal))
                        tmpVal = tmpVal.join(',');
                    $('#' + tmpId).attr('origval', tmpVal);

                    for (group in gfc.Groups()) {
                        var objControls = gfc.Groups()[group].controls;
                        var found = false;
                        for (control in objControls) {
                            if (control == tmpId) {
                                gfc.Groups()[group].controls[control].origval = tmpVal;
                                found = true;
                                break;
                            }
                        }
                        if (found)
                            break;
                    }

                    blMatchFound = true;
                    break;
                default: break;
            }

            if (blMatchFound)
                break;
        }
    });
    if (isNull(dataObj["RecordStatus"], '').toLowerCase() == 'locked') {
        $('[group="' + groupName + '"]').attr('disabled', 'disabled').prop('readonly', true);
        $('select:disabled[group="' + groupName + '"]').multipleSelect('disable');
        $('button[type="button"][actionType="Save"][saveGroup*="' + groupName + '"]').hide();
        $('button[type="button"][actionType="Cancel"][saveGroup*="' + groupName + '"]').hide();
        $('button[type="button"][actionType="Custom"][saveGroup*="' + groupName + '"]').hide();
        $('.divLocked[targetGroup="' + groupName + '"]').remove()
        $('input[type="button"][saveGroup*="' + groupName + '"]').filter(':last').after('<div class="divLocked" style="font-weight:bold; color:red;" targetGroup="' + groupName + '">This record is currently locked for edit by ' + dataObj["LockedBy"] + '.</div>');
    }
    else {
        $('[group="' + groupName + '"]').removeAttr('disabled').prop('readonly', false);
        $('select:disabled[group="' + groupName + '"]').multipleSelect('enable');
        $('button[type="button", actionType="Save", saveGroup*="' + groupName + '"]').show();
        $('button[type="button", actionType="Cancel", saveGroup*="' + groupName + '"]').show();
        $('button[type="button", actionType="Custom", saveGroup*="' + groupName + '"]').show();
        $('.divLocked[targetGroup*="' + groupName + '"]').remove()
    }

    gfc.loadControls();
    createRequiredLabels();
}

/*Public Function
*Retruns the size of the object
*/
Object.size = function (obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

/*Page Function
*Sets the message on the page
*/
setPageMessage = function (msg, seconds) {
    ///<param name="msg">The message being sent</param>
    ///<param name="seconds">Number of seconds to display the message</param>

    var iSeconds = 0;

    if (!parseInt(seconds))
        iSeconds = 5000;
    else
        iSeconds = seconds * 1000;

    $('#div_PageMessages').html(msg);

    setTimeout(function () {
        $('#div_PageMessages').html('');
    }, iSeconds);
};
setHasChanges = function (blHasChanges) {
    if (Bool(blHasChanges))
        $('#div_FormHasChanges').html('The form has unsaved changes. ');
    else
        $('#div_FormHasChanges').html('');
}
/*Function
*Presents the user with a message on the screen telling them a save/auto save occurred.
*/
setLastSaved = function (LastModifiedTime, autoSave, Message, msgElementId) {
    if (msgElementId === null || document.getElementById(msgElementId) === undefined) {
        msgElementId = 'div_FormLastSaved';
    }

    var objElement = $('#' + msgElementId);
    $(objElement).html('');
    $(objElement).attr('autosave', Bool(autoSave));

    var iImgIcon = controlBuilder.create('spn_AutoSaveIcon', 'span', {
        "class": 'AutoSaveIcon glyphicon' + (Bool(autoSave) ? " glyphicon-floppy-disk" : " glyphicon-floppy-saved"), style: 'padding-right:5px'
    });

    if (!isNullOrEmpty(LastModifiedTime) && !Bool(autoSave)) {
        var phm = pageMessages.newSaveMessage(LastModifiedTime, Message);        
        $(objElement).html(iImgIcon.outerHTML + phm.messageString());        
    }
    else if (!isNullOrEmpty(LastModifiedTime) && Bool(autoSave)) {
        var phm = pageMessages.newAutoSaveMessage(LastModifiedTime, Message);
        $(objElement).html(iImgIcon.outerHTML + phm.messageString());
    }
}

var pageMessages = {
    __newSaveMsg: function (LastModifiedTime, msg) {
        var obj = {
            __defaultMsg: "Saved on",
            lastModifiedDateTime: null,
            message: null,
            setLastModifiedDateTime: function (dt) {
                if (!isNullOrEmpty(dt))
                    this.lastModifiedDateTime = dt;
                else
                    this.lastModifiedDateTime = DateHelper.Today;
            },
            getLastModifiedDateTime: function () {
                return this.lastModifiedDateTime;
            },
            setMessage: function (msg) {
                if (!isNullOrEmpty(msg))
                    this.message = msg;
                else
                    this.message = this.__defaultMsg;
            },
            getMessage: function () {
                return this.message;
            },
            messageString: function () {
                var strMsg = this.getMessage() + " " + this.getLastModifiedDateTime() + ".";
                return strMsg
            }
        }

        obj.setMessage(msg);
        obj.setLastModifiedDateTime(LastModifiedTime);

        return obj;
    },
    __newAutoSaveMsg: function (LastModifiedTime, msg) {
        var obj = {
            __defaultMsg: "Auto Saved on",
            lastModifiedDateTime: null,
            message: null,
            setLastModifiedDateTime: function (dt) {
                if (!isNullOrEmpty(dt))
                    this.lastModifiedDateTime = dt;
                else
                    this.lastModifiedDateTime = DateHelper.Today;
            },
            getLastModifiedDateTime: function () {
                return this.lastModifiedDateTime;
            },
            setMessage: function (msg) {
                if (!isNullOrEmpty(msg))
                    this.message = msg;
                else
                    this.message = this.__defaultMsg;
            },
            getMessage: function () {
                return this.message;
            },
            messageString: function () {
                var strMsg = this.getMessage() + " " + this.getLastModifiedDateTime() + ".";
                return strMsg
            }
        }

        obj.setMessage(msg);
        obj.setLastModifiedDateTime(LastModifiedTime);

        return obj;
    },
    newSaveMessage: function (LastModifiedTime, Message) {
        return this.__newSaveMsg(LastModifiedTime, Message);
    },
    newAutoSaveMessage: function (LastModifiedTime, Message) {
        return this.__newAutoSaveMsg(LastModifiedTime, Message);
    }
}



loadFromObject = function (source, target) {
    for (prop in source) {
        if (target.hasOwnProperty(prop))
            target[prop] = source[prop];
    }
}

convertDataURLToImageData = function(dataURL, height, width, callback) {
    if (dataURL !== undefined && dataURL !== null) {
        var canvas, context, image;
        canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        context = canvas.getContext('2d');
        image = new Image();
        image.addEventListener('load', function () {
            context.drawImage(image, 0, 0, canvas.width, canvas.height);
            callback(context.getImageData(0, 0, canvas.width, canvas.height));
        }, false);
        image.src = dataURL;
    }
}

reusableComposer = {
    new: function () {
        var self = {
            __modal: null,
            __messageType: null,

            getModal: function (onLoad, onClose) {
                this.__modal = reusableModal.new('div_ComposeMessage');
                this.__modal.setModalWidth(800, true);
                this.__modal.setModalHeight(750, true);
                this.__modal.Subject.set('<h3>Compose</h3>');
                var btnSave = controlBuilder.create("btn_SaveMessage", "input", { type: "button", value: "Save" });
                var __this = this;
                $(btnSave).click(function () {
                    var msg = {
                        MessageID: isNullOrEmpty($('#div_ComposeMessage').find('#hdn_MessageID').val()) ? guid.empty : $('#div_ComposeMessage').find('#hdn_MessageID').val(),
                        Subject: $('#div_ComposeMessage').find('#txt_ComposeMessageSubject').val(),
                        MessageText: tinyMCE.activeEditor.getContent(),
                        MessageTypeID: __this.__data.MessageType,
                        Priority: __this.__data.Priority,
                        UserRecipients: __this.__data.RecipientUsers,
                        GroupRecipients: __this.__data.RecipientGroups
                    };
                    data.run('SendMessage', { message: msg });
                    bootbox.alert(reusableComposer.MessageTypes.KnowledgeBase ? 'Saved' : 'Message has been sent.');
                    __this.__modal.hideModal();
                    tinyMCE.remove(tinyMCE.activeEditor);
                    if (typeof onClose === 'function')
                        onClose();
                });
                this.__modal.Actions.set(btnSave, false);
                this.__modal.onClose(function () {
                    tinyMCE.remove(tinyMCE.activeEditor);
                });
                this.__modal.getModal(true, null);
                $('#div_ComposeMessage_body').load(HttpContext.BuildPath('~/Forms/Plugins/Messaging/ComposeMessage.htm'), function () {
                    var roles = data.run('GetAllSecurityRoles');
                    var list = $.map(__this.__data.RecipientGroups, function (a) {
                        return '[' + $.grep(roles, function (b) {
                            return b.RoleID === a;
                        })[0] + ']';
                    });
                    list = $.merge(list, $.map(__this.__data.RecipientUsers, function (a) {
                        var user = data.run('GetUserDetailsByUserID', { UserID: a });
                        return '[' + user.LastName + ', ' + user.FirstName + ']';
                    }));
                    $('#div_ComposeMessage_body').find('#lbl_Recipients').html(list.join(', '));
                    $('#txt_ComposeMessageBody').tinymce({
                        plugins: [
                            "advlist autolink lists link image charmap print preview anchor",
                            "textcolor",
                            "searchreplace visualblocks code fullscreen",
                            "insertdatetime media table contextmenu paste"
                        ],
                        height: 350,
                        past_data_images: true,
                        toolbar: "insertfile undo redo | styleselect | bold italic | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
                        init_instance_callback: function () {
                            if (typeof onLoad === 'function')
                                onLoad();
                        }
                    });
                });
            },

            showModal: function () {
                this.__modal.showModal();
            },

            setData: function () {
                var args = Array.prototype.slice.call(arguments, 0)
                for (var a in args) {
                    if ($.type(args[a]) != 'object' && !isNullOrEmpty(args[Number(a) + 1]) && a % 2 != 1)
                        this.__data[args[a]] = args[Number(a) + 1];
                    else if ($.type(args[a]) === 'object') {
                        var obj = args[a];
                        for (var p in obj) {
                            this.setData(p, obj[p]);
                        }
                    }
                }
            },

            AddRecipientUsers: function () {
                var args = Array.prototype.slice.call(arguments, 0)
                for (var a in args) {
                    if ($.isArray(args[a])) {
                        for (var e in args[a])
                            this.AddRecipientUsers(args[a][e])
                    }
                    else if (!isNullOrEmpty(args[a]))
                        this.__data.RecipientUsers.push(args[a]);
                }
            },

            AddRecipientGroups: function (GroupID) {
                var args = Array.prototype.slice.call(arguments, 0)
                for (var a in args) {
                    if ($.isArray(args[a])) {
                        for (var e in args[a])
                            this.AddRecipientGroups(args[a][e])
                    }
                    else if (!isNullOrEmpty(args[a]))
                        this.__data.RecipientGroups.push(args[a]);
                }
            },

            initData: function () {
                this.__data = {
                    MessageID: guid.empty,
                    MessageType: guid.empty,
                    Subject: null,
                    Message: null,
                    Priority: reusableComposer.Priority.Normal,
                    RecipientUsers: new Array(),
                    RecipientGroups: new Array()
                };
            }
        };
        self.initData();
        return self;
    },
    ComposeUser: function (messageType, UserID, onLoad, onClose) {
        var m = this.new();
        m.setData('MessageType', messageType);
        if(UserID != null && UserID != guid.empty)
            m.AddRecipientUsers(UserID);
        m.getModal(onLoad, onClose);
        m.showModal();
    },
    ComposeGroup: function (messageType, GroupID, onLoad, onClose) {
        var m = this.new();
        m.setData('MessageType', messageType);
        if (GroupID != null && GroupID != guid.empty)
            m.AddRecipientGroups(GroupID);
        m.getModal(onLoad, onClose);
        m.showModal();
    },
    ComposeImmediateToUser: function (UserID, onLoad, onClose) {
        this.ComposeUser(reusableComposer.MessageTypes.Immediate, UserID, onLoad, onClose);
    },
    ComposeImmediateToGroup: function (GroupID, onLoad, onClose) {
        this.ComposeGroup(reusableComposer.MessageTypes.Immediate, GroupID, onLoad, onClose);
    },
    //ComposeKB: function(onLoad, onClose) {
    //    var allUsers = '5C9468CA-764B-4AE6-9995-FE18924DA007';
    //    this.ComposeGroup(reusableComposer.MessageTypes.KnowledgeBase, allUsers, onLoad, onClose);
    //},
    //EditKB: function (MessageID, onLoad, onClose) {
    //    var msg = data.run("GetMessage", { MessageID: MessageID });
    //    this.ComposeKB(function () {
    //        $('#div_ComposeMessage_body').find('#txt_ComposeMessageSubject').val(msg.Subject);
    //        tinyMCE.activeEditor.setContent(msg.MessageText);
    //        $('#div_ComposeMessage_body').find('#txt_KeyWords').val(msg.Tags.join(', '));
    //        $('#div_ComposeMessage_body').find('#hdn_MessageID').val(msg.MessageID);
    //        if (typeof onLoad === 'function')
    //            onLoad();
    //    }, onClose);
    //},
    MessageTypes: {
        Immediate: 'E9084B43-D36D-4815-BA39-FAF81069350A',
        //KnowledgeBase: 'F4E5840B-9D29-49D3-B16F-877F318F9352'
    },
    Priority: {
        High: 1,
        Normal: 2,
        Low: 3
    }
}

reusablePasswordReset = {
    new: function () {
        var self = {
            __modal: null,
            __userName: null,

            getModal: function () {
                this.__modal = reusableModal.new('div_ForgotPassword');
                this.__modal.setModalWidth(800, true);
                this.__modal.Subject.set('<h3>Password Reset</h3>');
                if (!isNullOrEmpty(this.__userName)) {
                    var btnReset = controlBuilder.create("btn_ResetPass", "input", { type: "button", value: "Reset Password" });
                    var __this = this;
                    $(btnReset).click(function () {
                        if (data.run('SetNewPassword', { UserID: $('#div_ForgotPassword_body').find('#hdn_UserID').val(), SecurityAnswer1: $('#txt_Answer1').val(), SecurityAnswer2: $('#txt_Answer2').val(), NewPassword: null }))
                            bootbox.alert('<table style="width:100%"><tr><td><h3 style="float:left">Password Updated.</h3></td><td style="text-align:right"><img style="float:right" src="' + HttpContext.BuildPath('~/images/checkmark_green.png') + '" /></td></tr><tr><td colspan="2">A temporary password will be emailed to you shortly.</td></tr></table>');
                        else
                            bootbox.alert('<table style="width:100%"><tr><td><h3 style="float:left">Password was Not Updated.</h3></td><td rowspan="2" style="text-align:right"><img style="float:right" src="' + HttpContext.BuildPath('~/images/wrong_Red.png') + '" /></td></tr><tr><td>Please contact support for assistance.</td></tr></table>');
                        __this.__modal.hideModal();
                    });
                    this.__modal.Actions.set(btnReset, false);
                    this.__modal.getModal(true, null);
                    $('#div_ForgotPassword_body').load(HttpContext.BuildPath('~/Forms/Plugins/Security/ResetPassword.htm'), function () {
                        var UserID = data.run("GetUserIDByUserName", { username: __this.__userName });
                        var questions = data.run('GetUsersSecurityQuestions', { UserID: UserID });
                        if (questions == null || questions.length != 2) {
                            $('#div_ForgotPassword_body').html('<h3>You must enter a valid username and have security questions configured before using this feature.</<h3>');
                        }
                        else {

                            for (key in questions) {
                                questions[key].Key.replace('Security', '');
                                $('#div_ForgotPassword_body').find('#lbl_' + questions[key].Key.replace('Security', '').replace('_', '')).html(questions[key].Value);
                            }
                            $('#div_ForgotPassword_body').find('#hdn_UserID').val(UserID);
                            $('#div_ForgotPassword_body').find('#txt_Answer1').focus();
                        }
                    });
                }
                else {
                    this.__modal.getModal(true, null);
                    $('#div_ForgotPassword_body').html('<h3>You must enter a valid username before using this feature.</<h3>');
                }
            },
            showModal: function () {
                this.__modal.showModal();
            }
        };
        return self;
    },
    show: function (username) {
        var m = this.new();
        m.__userName = username;
        m.getModal();
        m.showModal();
    }
}

/*Object
*Used to generate a reusable modal on the fly.
*/
reusableModal = {
    /*Function
    *Creates a new instance of the reusable modal
    *Leave modalId null to default to the built in modal
    *change modalId to use custom
    */
    new: function (modalId) {
        ///<param name="modalId">Defaults to divReusableModal</param>
        /*Private function
        *This function will be used to initialize starting values
        */
        var self = {
            __parentModal: {},
            __bodyModal: {},
            __subjectModal: {},
            __actionsModal: {},
            __modalHeight: null,
            __modalBodyHeight: null,
            __modalWidth: null,
            __modalBodyWidth: null,
            __cancelAction: null,
            __parentCancelAction: null,
            __parentOKAction: null,
            __autoAddCancel: true,
            __cancelButtonText: 'Cancel',
            __showPopout: false,
            __onPopOut: null,
            onClose: function(closeFunc) {
                this.__parentCancelAction = closeFunc;
            },
            onOK: function (okFunc) {
                this.__parentOKAction = okFunc;
            },
            removeCancel: function () {
                this.__autoAddCancel = false;
            },
            showPopout: function (func) {
                this.__showPopout = true;
                this.__onPopOut = func;
            },
            setModalHeight: function(height, blPx) {
                ///<param name="height">The height of the modal in pixels</param>
                ///<param name="blPx">bool true/false if true size in pixels if false size in percentage</param>
                var blPixels = Bool(blPx);
                var iHeight = parseInt(height);
                if (iHeight > 0) {
                    if (blPixels) {
                        this.__modalHeight = iHeight + "px";
                        this.__modalBodyHeight = (iHeight - 160) + "px";
                    }
                    else {
                        this.__modalHeight = iHeight + "%";
                        this.__modalBodyHeight = "95%";
                    }
                }
            },
            setModalWidth: function(width, blPx) {
                ///<param name="width">The width of the modal in pixels</param>
                ///<param name="blPx">bool true/false if true size in pixels if false size in percentage</param>
                var blPixels = Bool(blPx);
                var iWidth = parseInt(width);
                if (iWidth > 0) {
                    if (blPixels) {
                        this.__modalWidth = iWidth + "px";
                        this.__modalBodyWidth = (iWidth - 10) + "px";
                    }
                    else {
                        this.__modalWidth = iWidth + "%";
                        this.__modalBodyWidth = "95%";
                    }
                }
            },
            setCancelButtonText: function(text)  {
                this.__cancelButtonText = text;
            },
            /*Function
            *Returns the pregenerated modal
            */
            getModal: function (autoAppend, appendToElement) {
                //autoAppend = Bool(auto
                var self = this;

                if (typeof $('#' + this.ID.getParentID()) != 'undefined' || $('#' + this.ID.getParentID()) != null) {
                    var div = document.getElementById(this.ID.getParentID());

                    if (div != null)
                        div.parentNode.removeChild(div);
                }

                var objModal = controlBuilder.create(this.ID.getParentID(), 'div', {
                    "id" : this.ID.getParentID(),
                    "class" : 'modal fade',
                    style: 'display: inline-block;',
                    tabIndex: "-1",
                    role: "dialog",
                    "aria-labelledby": "myModalLabel",
                    "aria-hidden": "true",
                    "data-backdrop": 'static',
                    "data-keybaord": false,
                });

                var objModalSubject = controlBuilder.create(this.ID.getSubjectID(), 'div', {
                    "class": "modal-header"
                    ,style: "height: 80px"
                });

                if (this.__showPopout) {
                    var div = $('<div style="float:left"></div>');
                    var img = $('<div id="div_PopOut_' + this.ID.__id + '" style="float:right"><img id="img_PopOut_' + this.ID.__id + '" src="' + HttpContext.BuildPath('~/images/icons/slide_blk.png') + '" style="height:24px;cursor:pointer;"></div>');
                    if (this.Subject.renderAsHtml()) {
                        $(div).html(this.Subject.get());
                        $(objModalSubject).append($(div));
                        $(objModalSubject).append($(img));
                    }
                    else {
                        $(div).append(this.Subject.get());
                        objModalSubject.appendChild(div);
                        objModalSubject.appendChild(img);
                    }
                    $(objModalSubject).find('#img_PopOut_' + this.ID.__id).click(function () {
                        if (typeof self.__onPopOut === 'function')
                            self.__onPopOut();
                        var w = window.open('', '_blank', 'toolbar=no,menubar=0,status=1,copyhistory=0,scrollbars=yes,resizable=1,location=0,Width=1000,Height=760');
                        var subject = $('#' + self.ID.getSubjectID()).clone();
                        var body = $('#' + self.ID.getBodyID()).clone();
                        $(body).css('height', '90%');
                        $(subject).find('#img_PopOut_' + self.ID.__id).remove();
                        $(w.document.body).html($('<div>').append($(subject)).append($(body)).html());
                        $(w.document.body).find('#divKBBody').css('height', '95%');
                        w.document.title = $('#' + self.ID.getSubjectID()).text();
                        w.focus();
                        self.hideModal();
                    });
                }
                else {
                    if (this.Subject.renderAsHtml())
                        objModalSubject.innerHTML = this.Subject.get();
                    else
                        objModalSubject.appendChild(this.Subject.get());
                }

                var objModalBody = controlBuilder.create(this.ID.getBodyID(), 'div', {
                    "id": this.ID.getBodyID(),
                    "class": "modal-body",
                    style: (!isNullOrEmpty(this.__modalBodyHeight) ? "height:" + this.__modalBodyHeight + "; overflow:auto;" : '') + (!isNullOrEmpty(this.__modalBodyWidth) ? "width: "
                        + this.__modalBodyWidth + ";" : '') + "display: inline-block; padding-left:12px"
                });

                if (this.Body.renderAsHtml())
                    objModalBody.innerHTML = this.Body.get();
                else
                    objModalBody.appendChild(this.Body.get());

                var objModalActions = controlBuilder.create(this.ID.getActionsID(), 'div', {
                    "class": "modal-footer"
                    , style: "height: 60px"
                });

                if (typeof self.__parentOKAction === 'function') {
                    var btnOK = controlBuilder.create("btn_" + this.ID.getParentID() + "_ModalOK", "input", { type: "button", value: "OK" });
                    $(btnOK).click(function () { self.__parentOKAction(); })
                    this.Actions.set(btnOK, false);
                }

                if (self.__autoAddCancel) {
                    var btnCancel = controlBuilder.create("btn_" + this.ID.getParentID() + "_ModalClose", "input", { type: "button", value: isNullOrEmpty(self.__cancelButtonText) ? "Cancel" : self.__cancelButtonText });
                    $(btnCancel).click(function () { if (typeof self.__cancelAction === "function") self.__cancelAction(); })
                    this.Actions.set(btnCancel, false);
                }
                if (this.Actions.renderAsHtml())
                    objModalActions.innerHTML = this.Actions.get();
                else
                    objModalActions.appendChild(this.Actions.get());

                var objModalDialog = controlBuilder.create(this.ID.getParentID()+"_dialog", 'div', {
                    "class": "modal-auto"
                });

                var objModalContent = controlBuilder.create("div_modalContent", 'div', {
                    "class": "modal-content",
                    style: (!isNullOrEmpty(this.__modalHeight) ? "height:" + this.__modalHeight + ";" : '') + (!isNullOrEmpty(this.__modalWidth) ? "width: "
                        + this.__modalWidth + ";" : '') + "display: inline-block;"
                });

                if (!isNullOrEmpty(this.__modalWidth))
                    objModalDialog.setAttribute("style", (!isNullOrEmpty(this.__modalHeight) ? "height:" + this.__modalHeight + ";" : '') + (!isNullOrEmpty(this.__modalWidth) ? "width: "
                        + this.__modalWidth + ";" : '') + "padding-right:15px;");
                
                if (!isNullOrEmpty(this.Subject.get()))
                    objModalContent.appendChild(objModalSubject);
                objModalContent.appendChild(objModalBody);
                if(objModalActions.children.length > 0)
                    objModalContent.appendChild(objModalActions);

                objModalDialog.appendChild(objModalContent);
                objModal.appendChild(objModalDialog);

                $(objModal).find('input[type="button"], input[type="submit"]').addClass('btn').addClass('btn-primary').addClass('btn-large').css('margin-left', '5px');
                this.__parentModal = objModal;

                if (Bool(autoAppend) && !isNullOrEmpty(appendToElement)) {
                    if (typeof $('#' + appendToElement) === 'object') {
                        var obj = document.getElementById(appendToElement);
                        obj.appendChild(this.__parentModal);
                    }
                }
                else if (Bool(autoAppend) && isNullOrEmpty(appendToElement)) {
                    document.body.appendChild(this.__parentModal);
                }
                else {
                    return this.__parentModal;
                }
            },
            /*Function
            *Use when you want to display the modal.
            */
            showModal: function () { },
            /*Function
            *Use when you want to hide the modal.
            */
            hideModal: function () { },
            ID : {
                __id: null,
                getParentID : function() {
                    return this.__id;
                },
                __subjectId: null,
                /*Function
                *Internal function that gets the subject id div
                */
                getSubjectID: function() {
                    return this.__subjectId;
                },
                __bodyId: null,
                /*Function
                *Interal function that gets the id on the body div
                */
                getBodyID : function() {
                    return this.__bodyId;
                },
                __actionsId: null,
                /*Function
                *Internal function that gets the id on the actions div
                */
                getActionsID : function() {
                    return this.__actionsId;
                },
                /*Function
                *This sets the ids needed for the reusable modal
                */
                setIds: function (id) {
                    ///<param name="id">This is the id for the modal.  Set to null to default to divReusableModal</param>
                    if (isNullOrEmpty(id)) {
                        this.__id = "divReusableModal";
                    }

                    if (typeof $('#' + id) !== 'undefined' && $('#' + id) != null) {
                        this.__id = id;
                        this.__subjectId = id + "_subject";
                        this.__bodyId = id + "_body";
                        this.__actionsId = id + "_actions";
                    }
                }
            },
            Subject: {
                __subject: null,
                __htmlText: true,
                /*Function
                *Determines if the appended information should render as html
                */
                renderAsHtml : function() {
                    return this.__htmlText;
                },
                /*Function
                *sets the modal subject line
                */
                set: function (sSubject, htmlText) {
                    ///<param name='sSubect'>The subject line in the modal</param>
                    ///<param name='htmlText'>Bool true-it it renders as html false if it is an object</param>
                    if (isNullOrEmpty(sSubject))
                        this.__subject = null;
                    else 
                        this.__subject = sSubject;

                    this.__htmlText = Bool(isNullOrEmpty(htmlText) ? true : htmlText);
                },
                /*Function
                *Returns the modal subject line
                */
                get: function () {
                    return this.__subject;
                }
            },
            Body: {
                __body: '<img src="' + HttpContext.BuildPath('~/images/loading.gif') + '"',
                __htmlText: true,
                /*Function
                *Determines if the appended information should render as html
                */
                renderAsHtml : function() {
                    return this.__htmlText;
                },
                /*Function
                *Sets the body text
                */
                set: function (sBody, htmlText) {
                    ///<param name='sBody'>The body of the modal.</param>
                    ///<param name='htmlText'>Bool true/false - Set to true if appending html and false if appending an object</param>
                    if (isNullOrEmpty(sBody))
                        this.__body = null;
                    else
                        this.__body = sBody;

                    this.__htmlText = Bool(isNullOrEmpty(htmlText) ? true : htmlText);
                },
                /*Function
                *Returns the body text.
                */
                get: function () {
                    return this.__body;
                }
            },
            Actions: {
                __actions: null,
                __htmlText: true,
                /*Function
                *Determines if the appended information should render as html
                */
                renderAsHtml : function() {
                    return this.__htmlText;
                },
                /*Function
                *Use to add buttons or a footer
                */
                set: function (sAction, htmlText) {
                    ///<param name='sAction'>Used to add Buttons or a footer</param>
                    ///<param name='htmlText'>true / false - true if its text false if its an object </param>
                    if (isNullOrEmpty(sAction)) {
                        this.__actions = null;
                    }
                    else {
                        if (isNullOrEmpty(this.__actions))
                            this.__actions = controlBuilder.create('div_modalActions', 'div');
                        this.__actions.appendChild(sAction);
                    }
                    this.__htmlText = Bool(isNullOrEmpty(htmlText) ? true : htmlText);
                },
                /*Function
                *Use to retrieve the buttons or footer
                */
                get: function () {
                    return this.__actions;
                }
            }
        };

        (function () {
            self.ID.setIds(modalId);
        })();


        (function () {
            self.showModal = function () {
                $('#' + self.ID.getParentID()).modal('show');
            };
            self.hideModal = function () {
                $('#' + self.ID.getParentID()).modal('hide');
            };
            self.__cancelAction = function (keep) {
                self.hideModal();
                if (!isNull(keep, false))
                    self.__Remove();
                    
                if (typeof self.__parentCancelAction === 'function') {
                    self.__parentCancelAction();
                };
            };
            self.__Remove = function () {
                controlBuilder.remove(self.ID.getParentID());
            };
        })();

        (function () {
            self.hideModal = function() {
                $('#' + self.ID.getParentID()).modal('hide');
            }
        })();

        return self;
    }
};

/*Plugin
*Allows for the dynamic creation of nav pills
*/
NavPills = {
    __getNewNavPill : function() {
        var obj = {
            //Contains an object Array storing tab pill details
            __tabLinkArray: null,
            //Contains the size of the tabLinkArray
            __tabLinkArraySize: 0,
            /*Internal Function
            *Gets the size of the tabLinkArray 
            */
            __getTabLinkArraySize: function () {
                return this.__tabLinkArraySize;
            },
            /*Internal Function
            *Calls the __tablLinkArray.  If it is null it sets it to new array.
            */
            __getTabLinkArray: function () {
                if (this.__tabLinkArray == null)
                    this.__tabLinkArray = new Array();

                return this.__tabLinkArray;
            },
            /*Internal Function
            *generates setable properties for the pill
            */
            __getTabLinkProperties: function () {
                var obj = {
                    linkText: null
                };

                return obj;
            },
            /*Function
            *Add tab links
            */
            addNewPill: function (id, linkText) {
                ///<param name="id">The id to use on menu, refernece link and div containers.</param>
                ///<param name="linkText">The links display text.</param>
                if (!isNullOrEmpty(id) && !isNullOrEmpty(linkText)) {
                    if (this.__tabLinkArray == null)
                        this.__tabLinkArray = {};

                    this.__tabLinkArray[id] = this.__getTabLinkProperties();
                    this.__tabLinkArray[id].linkText = linkText;

                    this.__tabLinkArraySize++;
                }
            },
            /*Function
            *Creates the table containing all necessary pills and containers
            */
            generate: function (tabId, onClick) {
                ///<param name="tabId">The name of the pill container</param>
                ///<param name="onClick">Optional click handler for tabs</param>
                if (this.__getTabLinkArraySize() > 0 && !isNullOrEmpty(tabId)) {
                    var tabTable = controlBuilder.create('tbl_' + tabId, 'table', { 'style': 'padding: 0px;, border-spacing: 0px;' });
                    var objTrSpacer = document.createElement('tr');
                    var hSpacer = document.createElement('td');
                    hSpacer.setAttribute('style', 'height: 10px;');
                    objTrSpacer.appendChild(hSpacer);

                    var wSpacer = document.createElement('td');
                    wSpacer.setAttribute('style', 'width: 10px;')

                    //tabTable.appendChild(objTrSpacer);

                    var trContent = document.createElement('tr');
                    var tdPills = document.createElement('td');                    
                    tdPills.setAttribute('class', 'navigationarea');
                    tdPills.setAttribute('style', 'vertical-align: top;min-height:100% !important;');
                    tdPills.setAttribute('rowspan', '10');

                    var tabLinkArray = this.__getTabLinkArray();
                    var objUl = controlBuilder.create('tabMenu_' + tabId, 'ul', { 'class': 'nav nav-stacked nav-pills' });

                    var count = 0;
                    var tabMenuContent = controlBuilder.create('tmc_' + tabId, 'div', { 'class': 'tab-content' });

                    for (gkey in tabLinkArray) {
                        var objLi = null;

                        if (count == 0) {
                            objLi = controlBuilder.create('tab_' + gkey, 'li', { 'class': 'active' });
                        }
                        else {
                            objLi = controlBuilder.create('tab_' + gkey, 'li', { 'class': '' });
                        }

                        var objA = controlBuilder.create('a_' + gkey, 'a', { 'href': '#div_' + gkey, 'data-toggle': 'pill', groupID: gkey });
                        objA.innerHTML = tabLinkArray[gkey].linkText;
                        $(objA).click(function () {
                            if (typeof onClick == 'function')
                                onClick($(this).attr('groupID'));
                        });

                        objLi.appendChild(objA);
                        objUl.appendChild(objLi);

                        var objDivContainer = null;

                        if (count == 0) {
                            objDivContainer = controlBuilder.create('div_' + gkey, 'div', { 'class': 'tab-pane fade active in' });
                        }
                        else {
                            objDivContainer = controlBuilder.create('div_' + gkey, 'div', { 'class': 'tab-pane fade' });
                        }

                        tabMenuContent.appendChild(objDivContainer);

                        count++;
                    }

                    tdPills.appendChild(objUl);
                    trContent.appendChild(tdPills);
                    trContent.appendChild(wSpacer);

                    var tdTabContent = document.createElement('td');
                    tdTabContent.setAttribute('style', 'vertical-align:top;');

                    tdTabContent.appendChild(tabMenuContent);
                    trContent.appendChild(tdTabContent);

                    tabTable.appendChild(trContent);
                    return tabTable;
                }
            }
        };
        return obj;
    },
    new: function () {       
        return this.__getNewNavPill();
    },
    disableAllPills: function () {
        $('.nav li').not('.active').find('a').removeAttr("data-toggle");
    },
    enableAllPills: function () {
        $('.nav li').not('.active').find('a').attr("data-toggle", 'pill');
    }
}

scriptHelper = function (url, callback, locationId) {
    var head = null;

    if (!isNullOrEmpty(locationId) && document.getElementById(locationId) != undefined) {
        head = document.getElementById(locationId),
          script = document.createElement("script"),
          done = false;
    }
    else {
        head = document.getElementsByTagName("head")[0],
          script = document.createElement("script"),
          done = false;
    }

    script.src = url + '?ts=' + Math.random();
    // Attach event handlers for all browsers
    script.onload = script.onreadystatechange = function () {
        if (!done && (!this.readyState ||
          this.readyState == "loaded" || this.readyState == "complete")) {
            done = true;
            callback(); // Execute callback function
            // Prevent memory leaks in IE
            script.onload = script.onreadystatechange = null;
            head.removeChild(script);
        }
    };
    head.appendChild(script);
}

/*Function
*Used to validate emails.  See:  http://jsfiddle.net/thejimgaudet/kmvgw/
*/
function validateEmail(email) {
    ///<param name="email">Pass it the email to test</param>
    var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,6})?$/;
    return emailReg.test(email);
}

jQuery.extend(
  jQuery.expr[":"],
  { reallyvisible: function (a) { return (jQuery(a).css("display") != "none" && jQuery(a).css("visibility") != "hidden" && jQuery(a).parents('[disableRequired="1"]').length == 0); } }
);


var controlTracker = {
    __getNewTracker: function () {
        var obj = {
            __properties: {
                ctrlGroup: new Array()
            },
            newControl: function (id, controlType, options) {
                var control = '';
                if (controlType != null) {
                    control = document.createElement(controlType);

                    if (id != null)
                        control.id = id;

                    if (typeof options === 'object') {
                        for (var key in options) {
                            control.setAttribute(key, options[key]);
                        }
                    }

                    return control;
                }

                return control;
            },
            addControlGroup:function(group){
                if (!isNullOrEmpty(group) && this.__properties.ctrlGroup[group] === undefined)
                    this.__properties.ctrlGroup[group] = {};
            },
            addControlToGroup: function (group, element) {
                if (group != null && (element != null && element != undefined)) {
                    if (this.__properties.ctrlGroup[group] === undefined || this.__properties.ctrlGroup[group] === null)
                        this.__properties.ctrlGroup[group] = {};

                    this.__properties.ctrlGroup[group][element.id] = element;
                }

            },
            getControlGroups: function () {
                return this.__properties.ctrlGroup;
            },
            getControlByGroupAndID: function (group, id) {
                iGroup = this.getControlGroups();
                iControl = '';

                if (iGroup[group] !== undefined && iGroup[group] !== null)
                    iControl = iGroup[group][id];

                return iControl;
            }
        }

        return obj;
    },
    new: function () {
        return this.__getNewTracker();
    }
};

/*Function
*Button types to be used for table helper functions
*See: http://glyphicons.com/
*/
var buttonTypes = {
        //The Standard Button Type
        standard: "standard",
        glyphicons:{
            haflings: {
                Glass: "glass",
                Music: "music",
                Search: "search",
                Envelope: "envelope",                    
                Heart: "heart",
                Star: "star",
                StarEmpty: "star-empty",
                User: "user",
                Film: "film",
                THLarge: "th-large",
                TH: "th",
                THList: "th-list",
                Ok: "ok",
                Remove: "remove",
                ZoomIn: "zoom-in",
                ZoomOut: "zoom-out",
                Off: "off",
                Signal: "signal",
                Cog: "cog",
                Trash: "trash",
                Home:"home",
                Pencil: "pendil",
                FloppyDisk: "floppy-disk",
                PlusSign: "plus-sign",
                Eyeopen: "eye-open"
            }
        }
}

/*Function
*Used to allow for a pause between typing and 
*execution of a function.
Usage:
$(ct.getControlByGroupAndID('grpSample', element.id)).on('change keyup', function () {
                var tt = typingTimer.new();
                
                var ival = $(this).val();
                tt.setTypingTimer = null;
                tt.start(function () { $('#txt_seeInput').val(ival);});
            });
*/
var typingTimer = {
    __newTimer: function () {
        var obj = {
            __properties: {
                typingPauseInterval: 5000,
                typingTimer: null,
                timerId: null
            },
            /*Function returns void
            *The name of the typing timer.
            */
            setTimerId: function (uid) {
                ///<param name='uid'>string - a unique name for the timer</param>
                if (!isNullOrEmpty(uid))
                    this.__properties.timerId = uid;
            },
            /*Function returns string
            *Gets the current timer id
            */
            getTimerId:function(){
                return this.__properties.timerId;
            },
            /*Function - Returns type Int.
            *Gets the current number of milliseconds for the Pause Interval
            */
            getTypingPauseInterval: function () {
                return this.__properties.typingPauseInterval;
            },
            /*Function
            *Sets the pause time.  Default Wait Time is 5 Seconds.
            */
            setTypingPauseInterval: function (x) {
                ///<param name="x">Time in seconds. Can't set time to less than 1 second.</param>
                var iInterval = parseInt(x) * 1000;
                if (iInterval < 1000)
                    iInterval = 5000;

                this.__properties.typingPauseInterval = iInterval;
            },
            /*Function
            *Gets the current timer. Default timer is null
            */
            getTypingTimer: function () {
                return this.__properties.typingTimer;
            },
            /*Function
            *Sets Typing Timer.  Example: setTimeout(myfunction(), myPauseInMilliseconds);
            *Only use this for manual overloading.  Call typingTimer.start() instead.
            */
            setTypingTimer: function (x) {
                ///<param name='x'>This is the setTimeout command.</param>
                this.__properties.typingTimer = x;
            },
            /*Function
            *Starts the timer function.
            */
            start: function (func) {
                ///<param name="func">This is the function to be run once the timer is done running.</param>                
                this.__properties.typingTimer = setTimeout(function () { func(); }, this.getTypingPauseInterval());
            },
            /*Function
            *This clears the Typing timer.
            */
            clear: function () {
                this.setTypingTimer = null;
            }
        }
        return obj;
    },
    new: function (timerId) {
        ///<param name="timerId">string - a unique name for the timer</param>
        var obj = null;

        if (!isNullOrEmpty(timerId)) {
            obj = this.__newTimer();            
        }

        return obj;
    },
    run: function (timerId, interval, func) {
        var tt = null;
        
        if (!isNullOrEmpty(timerId) && typeof func === 'function') {
            if (globalData.getTypingTimer(timerId) !== null) {
                globalData.clearTypingTimer(timerId);
            }

            tt = this.new(timerId);
            tt.setTypingPauseInterval(parseInt(interval));

            tt.start(function () {
                func();
            });

            globalData.setTypingTimer(timerId, tt.getTypingTimer());
        }
    }
}