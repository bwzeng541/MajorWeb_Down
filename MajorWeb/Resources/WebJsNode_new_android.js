;
if (typeof(window.__webjsNodePlug__) == "undefined") {
    window.__webjsNodePlug__ = (function() {;
        var updateTime = -1;
        var startPos;
        var touchHook = function(event) {
            var event = event || window.event;

            var oInp = document.body;

            switch (event.type) {
            case "touchstart":
                {
                    var touch = event.targetTouches[0]; //touches数组对象获得屏幕上所有的touch，取第一个touch
                    　　startPos = {
                        x: touch.pageX,
                        y: touch.pageY,
                        time: +new Date
                    }; //取第一个touch的坐标值
                }
                break;
            case "touchend":
                {　　
                    var duration = +new Date - startPos.time; //滑动的持续时间
                    var touch = event.pageY; //touches数组对象获得屏幕上所有的touch，取第一个touch
                    if (duration < 80 && Math.abs(touch - startPos.y) < 5) {
                        var ww = document.body.clientWidth / 2;
                        if (startPos.x < ww) {
                            window.webkit.messageHandlers.sendWebJsNodeLeftMessageInfo.postMessage('');
                        } else {
                            window.webkit.messageHandlers.sendWebJsNodeRightMessageInfo.postMessage('');
                        }
                    }
                    console.log("touchend %f", duration);
                }
                break;
            case "touchmove":
                console.log("touchmove");
                break;
            }
        };

        function hookBodyTouch() {
            document.addEventListener('touchstart', touchHook, false);
            document.addEventListener('touchmove', touchHook, false);
            document.addEventListener('touchend', touchHook, false);
        };

        function stopCheckList() {
            clearInterval(updateTime);
            updateTime = -1;
        }

        ;
        var updateList = function() {
            var ceshi = document.getElementById("ceshi_id");
            if (ceshi == null) {
                var head = document.getElementsByTagName('head')[0];
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.onreadystatechange = function() {
                    if (this.readyState == 'complete') {}
                }

                script.onload = function() {

}
                script.id = "ceshi_id";
                head.appendChild(script);

            }

            var realbb = window.location.href;
           var videoTitle   = document.title.replace(/[ /d]/g, '');//查找《》里面的数据，并删除数字;
            var startPos = videoTitle.indexOf('《');
            var endPos = videoTitle.indexOf('》');
            if (startPos != -1 && endPos != -1) {
                videoTitle = videoTitle.substring(startPos + 1, endPos);
            }
            var urlArray = new Array();
            var select = 0;
            if (realbb.indexOf('m.iqiyi.com') != -1) { //爱奇艺
                var list = document.getElementsByClassName('juji-list  clearfix');
                if (list.length == 0) {
                    list = document.getElementsByClassName('m-album-num clearfix item');
                }
                if (list.length == 0) {
                    list = document.getElementsByClassName('m-album-num clearfix');
                }
                if (list.length > 0) {
                    var i;
                    var jujilist;
                    for (i = 0; i < list.length; i++) {
                        jujilist = list[i].getElementsByTagName('a');
                    }

                    for (i = 0; i < jujilist.length; i++) {
                        var retValue = {
                            'url': 'http:' + jujilist[i].getAttribute('href'),
                            'title': jujilist[i].getAttribute('curpage-index')
                        };
                        urlArray.push(retValue);
                    }
                    if (urlArray.length > 0) {
                        var dic = {
                            'listArray': urlArray,
                            'ShowName': videoTitle,
                            'SelectIndex': select
                        };
                        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                    }
                } else {
                    var dic = {
                        'listArray': urlArray,
                        'ShowName': videoTitle,
                        'SelectIndex': select
                    };
                    window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                }
            }
             else if (realbb.indexOf('lemaotv.net') != -1) //乐猫
            {
		
                var list = document.getElementsByClassName('detail-video-select');
                if (list != null && list.length > 0) {
                    var vv = list[0].getElementsByTagName('li');
                    for (i = 0; i < vv.length; i++) {
                        var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                        var title = vv[i].getElementsByTagName('a')[0].innerText;
                        var retValue = {
                            'url': 'http://m.lemaotv.net/' + value,
                            'title': title
                        };
                        urlArray.push(retValue);
                        if (realbb.indexOf(value) != -1) {
                            select = i;
                        }
                    }
                    if (urlArray.length > 0) {
                        var dic = {
                            'listArray': urlArray,
                            'ShowName': videoTitle,
                            'SelectIndex': select
                        };
                        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                    } else {
                        var dic = {
                            'listArray': urlArray,
                            'ShowName': videoTitle,
                            'SelectIndex': select
                        };
                        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                    }
                }
            }  else {
                var dic = {
                    'listArray': urlArray,
                    'ShowName': videoTitle,
                    'SelectIndex': select
                };
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        };
        function startCheckList() {
            if (updateTime == -1) {
                updateTime = setInterval(updateList, 1000);
            }
        }

        ;
        function updateZySort() {
            
        }

        ;
        function clickfixUrl(url) {
            window.setTimeout(delayCilck, 1000 * 2);
        }

        ;
        function delayCilck() {
            var realbb = window.location.href;
            if (realbb.indexOf('youku.com') != -1 && realbb.indexOf('alipay_video') != -1) {
                var classArray = new Array();
                classArray.push('waist active');
                classArray.push('select active');
                for (i = 0; i < classArray.length; i++) {
                    var list = document.getElementsByClassName(classArray[i]);
                    if (list != null && list.length > 0) { //调用click 事件
                        list[0].parentNode.click();
                        break;
                    }
                }
            }
        }

        ;
        function gotoParseWeb() {
            //虎牙某个路径下的所有a标签
            var realbb = window.location.href;
            var retArray = new Array();
          
            return retArray;
        };
        function getWebNoInFoJs(responseText) {
            responseText = decodeURIComponent(responseText);
            var link = $(responseText);
            var vv = link.find('.channel-link');
            var length = vv.length;
            var retArray = new Array();
          
            return retArray;
        }

        ;
        function getWebChanneInFoJs(responseText) {
            responseText = decodeURIComponent(responseText);
            var link = $(responseText);
            var vv = link.find('.play-channel').children('span');
            var length = vv.length;
            var retArray = new Array();
           
            return retArray;
        }

        ;
        function addPicIntoWeb(text, n, b) {
           
        }

        ;
        function getWebLists(text) {
         

        }
        //删除广告扩展代码
        ;
        var AdBlockupdateTime = -1;

        ;
        function stopCheckAdBlock() {
            clearInterval(AdBlockupdateTime);
            AdBlockupdateTime = -1;
        }

        ;
        var updateAdBlock = function()  {
        	            var realbb = window.location.href;
            if (realbb.indexOf('5tdy.com') != -1) { //
                $('body>div').each(function(index, el) {
                    var name = el.className;
                    var id_name = el.id;
                    if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                        el.style.zoom = 0.001;
                        return false;
                    }
                });
                $('[style]').each(function(index, el) {
                    var isFind = false;
                    if (el.attributes.length > 0) {
                        var textValue = el.attributes[0].textContent;
                        if (textValue.length > 1) {
                            textValue = textValue.substring(1, textValue.length);
                            if (!isNaN(textValue)) {
                                isFind = true;
                            }
                        }
                    }

                    if (isFind) {
                        el.remove();
                        return false;
                    }
                });

                
            }
        	};
    function startCheckAdBlock() {
        if (AdBlockupdateTime == -1) {
            AdBlockupdateTime = setInterval(updateAdBlock, 0.25);
        }
    };

    return {
        startCheckAdBlock: startCheckAdBlock,
        stopCheckAdBlock: stopCheckAdBlock,
        getWebLists: getWebLists,
        addPicIntoWeb: addPicIntoWeb,
        getWebChanneInFoJs: getWebChanneInFoJs,
        getWebNoInFoJs: getWebNoInFoJs,
        gotoParseWeb: gotoParseWeb,
        stopCheckList: stopCheckList,
        startCheckList: startCheckList,
        updateZySort: updateZySort,
        clickfixUrl: clickfixUrl,
        hookBodyTouch: hookBodyTouch
    }
})();
};; !
function breakDebugger() {
    return;
    if (checkDebugger()) {
        breakDebugger();
    }
} ();

;
function checkDebugger() {
    const d = new Date();
    debugger;
    const dur = Date.now() - d;
    if (dur < 5) {
        return false;
    } else {
        return true;
    }
}