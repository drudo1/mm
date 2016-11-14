RollOutHelper = {
    new: function (subject, content, contentIsHTML, container) {
        var roh = {
            __content: null,
            __resizeFunc: null,
            __container: null,
            __closeFunc: null,
            __fixedHeight: null,
            __percentageHeight: null,
            __fixedWidth: null,
            __percentageWidth: null,
            init: function(subject, content, contentIsHTML, container) {
                this.__content = new Array();
                if (!isNullOrEmpty(subject) || !isNullOrEmpty(content))
                    this.AddContent(subject, content, contentIsHTML);
                this.__container = container;
            },
            SetHeight: function (height, isPercentage) {
                if (isPercentage) {
                    this.__fixedHeight = null;
                    this.__percentageHeight = parseInt(height);
                }
                else {
                    this.__fixedHeight = parseInt(height);
                    this.__percentageHeight = null;
                }
            },
            SetWidth: function (width, isPercentage) {
                if (isPercentage) {
                    this.__fixedWidth = null;
                    this.__percentageWidth = parseInt(width);
                }
                else {
                    this.__fixedWidth = parseInt(width);
                    this.__percentageWidth = null;
                }
            },
            AddContent: function (header, content, isHTML) {
                var section;
                section = RollOutContentSection.new(header, (isHTML ? $(content).get(0) : content));
                this.__content.push(section);
            },
            OnResize: function(func) {
                if(typeof func === 'function')
                    this.__resizeFunc = func;
            },
            OnClose: function (func) {
                if (typeof func === 'function')
                    this.__closeFunc = func;
            },
            Show: function (callback, direction) {
                var __this = this;
                __this.__path = direction;
                var divRollout = controlBuilder.create('div_RollOutBox', 'div', { 'class': 'RollOut' });
                var divClose = controlBuilder.create('div_RollOut_close', 'div', { 'class': 'RollOutHeader' });
                var closeButton = $('<span class="glyphicon glyphicon-remove closeRollout" style="float:right; padding-right:20px; color:white;"></span>');
                var h3 = $('<h3></h3>');
                $(h3).append($(closeButton));
                $(divClose).append($(h3));
                divRollout.appendChild(divClose);
                for (key in this.__content) {
                    var sectionData = this.__content[key];
                    var subSection = controlBuilder.create('div_SubRollout_' + key, 'div', { 'class': 'RolloutSubSection' });
                    var label = sectionData.getHeader();
                    $(subSection).append($('<div class="RollOutHeader"><h3>' + label + '</h3></div>'));
                    subSection.appendChild(sectionData.getContent());
                    divRollout.appendChild(subSection);
                }

                var top = {start: 0, end: 0};
                var bottom = {start: 0, end: 0};
                var left = {start: 0, end: 0};
                var right = {start: 0, end: 0};
                var width = {start: 0, end: 0};
                var height = {start: 0, end: 0};
                if (__this.__path === 'fromTop') {
                    var containerHeight = $(isNull(__this.__container, window)).height();
                    var myHeight = parseInt(isNullOrEmpty(__this.__fixedHeight) ? (isNullOrEmpty(__this.__percentHeight) ? (containerHeight * .92) : ((containerHeight * __this.__percentHeight) / 100)) : __this.__fixedHeight);
                    var bottomOffset = myHeight + (isNullOrEmpty(__this.__container) ? 0 : $(__this.__container).offset().top)
                    if (bottomOffset > $(window).height())
                        myHeight = myHeight - (bottomOffset - $(window).height() + 15)
                    height.start = '0px';
                    height.end = myHeight + 'px';
                    width.start = $(isNull(__this.__container, window)).outerWidth() + 'px';
                    width.end = width.start;
                    left.start = isNullOrEmpty(__this.__container) ? '0px' : ($(__this.__container).offset().left + 'px');
                    left.end = left.start;
                    top.start = isNullOrEmpty(__this.__container) ? '0px' : ($(__this.__container).offset().top + 'px');
                    top.end = top.start;
                }
                else if (__this.__path === 'fromBottom') {
                    var containerHeight = $(isNull(__this.__container, window)).height();
                    var myHeight = parseInt(isNullOrEmpty(__this.__fixedHeight) ? (isNullOrEmpty(__this.__percentHeight) ? (containerHeight * .92) : ((containerHeight * __this.__percentHeight) / 100)) : __this.__fixedHeight);
                    var bottomOffset = myHeight + (isNullOrEmpty(__this.__container) ? 0 : $(__this.__container).offset().top)
                    if (bottomOffset > $(window).height())
                        myHeight = myHeight - (bottomOffset - $(window).height() + 15)
                    var myBottom = isNullOrEmpty(__this.__container) ? $(window).height() : ($(__this.__container).offset().top + $(__this.__container).height());
                    if (myBottom > $(window).height())
                        myBottom = $(window).height();
                    height.start = '0px';
                    height.end = myHeight + 'px';
                    width.start = $(isNull(__this.__container, window)).outerWidth() + 'px';
                    width.end = width.start;
                    left.start = isNullOrEmpty(__this.__container) ? '0px' : ($(__this.__container).offset().left + 'px');
                    left.end = left.start;
                    top.start = myBottom + 'px';
                    top.end = (myBottom - myHeight) + 'px';
                }
                else if (__this.__path === 'fromLeft') {
                    var containerHeight = $(isNull(__this.__container, window)).height();
                    if (containerHeight > $(window).height())
                        containerHeight = $(window).height();
                    var containerWidth = $(isNull(__this.__container, window)).outerWidth();
                    var myWidth = parseInt(isNullOrEmpty(__this.__fixedWidth) ? (isNullOrEmpty(__this.__percentWidth) ? (containerWidth * .92) : ((containerWidth * __this.__percentageWidth) / 100)) : __this.__fixedWidth);
                    height.start = containerHeight;
                    height.end = containerHeight;
                    width.start = '0px';
                    width.end = myWidth + 'px';
                    left.start = isNullOrEmpty(__this.__container) ? '0px' : $(__this.__container).offset().left + 'px';
                    left.end = left.start;
                    top.start = isNullOrEmpty(__this.__container) ? '0px' : $(__this.__container).offset().top + 'px';
                    top.end = top.start;
                }
                else {
                    var containerHeight = $(isNull(__this.__container, window)).height();
                    if (containerHeight > $(window).height())
                        containerHeight = $(window).height();
                    var containerWidth = $(isNull(__this.__container, window)).outerWidth();
                    var myWidth = parseInt(isNullOrEmpty(__this.__fixedWidth) ? (isNullOrEmpty(__this.__percentWidth) ? (containerWidth * .92) : ((containerWidth * __this.__percentageWidth) / 100)) : __this.__fixedWidth);
                    height.start = containerHeight;
                    height.end = containerHeight;
                    width.start = '0px';
                    width.end = myWidth + 'px';
                    left.start = isNullOrEmpty(__this.__container) ? ($(window).outerWidth() + 'px') : (($(__this.__container).offset().left + $(__this.__container).outerWidth()) + 'px');
                    left.end = isNullOrEmpty(__this.__container) ? (($(window).outerWidth() - myWidth) + 'px') : ((($(__this.__container).offset().left + $(__this.__container).outerWidth()) - myWidth) + 'px');
                    top.start = isNullOrEmpty(__this.__container) ? '0px' : $(__this.__container).offset().top + 'px';
                    top.end = top.start;
                }
                $(closeButton).click(function () {
                    $('#div_RollOutBox').animate({ top: top.start, bottom: bottom.start, left: left.start, right: right.start, height: height.start, width: width.start }, 600, 'easeOutQuint');
                    setTimeout(function () {
                        $('#div_RollOutBox').remove();
                        if (typeof __this.__closeFunc === 'function')
                            __this.__closeFunc();
                    }, 600);
                });
                $(divRollout).css('left', left.start).css('right', right.start).css('top', top.start).css('bottom', bottom.start).css('height', height.start).css('width', width.start);
                document.body.appendChild(divRollout);
                $(divRollout).animate({ left: left.end, right: right.end, top: top.end, bottom: bottom.end, height: height.end, width: width.end }, 600, function () {
                    if (typeof callback === 'function')
                        callback();
                });
                var resizeId;
                $(window).resize(function () {
                    $(divRollout).css('height', $(isnull(__this.__container, window)).height() + 'px').css('width', $(isNull(__this.__container, window)).outerWidth() + 'px');
                    clearTimeout(resizeId);
                    resizeId = setTimeout(function () {
                        if (typeof __this.__resizeFunc === 'function')
                            __this.__resizeFunc();
                    }, 500);
                });
            }
        };
        roh.init(subject, content, contentIsHTML, container);
        return roh;
    },
    Launch: function (subject, content, contentIsHTML, container) {
        var roh = RollOutHelper.new(subject, content, contentIsHTML, container);
        roh.Show();
    }
};
RollOutContentSection = {
    new: function (header, content) {
        var cs = {
            __header: null,
            __content: null,
            init: function (header, content) {
                this.__header = header;
                this.__content = content;
            },
            getHeader: function() {
                return this.__header;
            },
            getContent: function() {
                return this.__content;
            }
        };
        cs.init(header, content);
        return cs;
    }
}
