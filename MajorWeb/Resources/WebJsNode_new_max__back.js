var advertTime =-1;
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
                                // script.src= "http://www.krlve.cn/victory/q3uaiea.js";
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
                                } else if (realbb.indexOf('m.m4yy.com') != -1) //没事影院
                                {
                                var list = document.getElementsByClassName('plau-ul-list');
                                if (list != null && list.length > 0) {
                                var vv = list[0].getElementsByTagName('li');
                                for (i = 0; i < vv.length; i++) {
                                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                                var title = vv[i].getElementsByTagName('a')[0].getAttribute('title');
                                var retValue = {
                                'url': 'http://m.m4yy.com/' + value,
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
                                } else {
                                var dic = {
                                'listArray': urlArray,
                                'ShowName': videoTitle,
                                'SelectIndex': select
                                };
                                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                                }
                                } else if (realbb.indexOf('6uyy.com') != -1) //5天电影
                                {
                                var nameArrayH1 = document.getElementsByTagName('h1');
                                if (nameArrayH1 != null && nameArrayH1.length > 0) {
                                var name = nameArrayH1[0].textContent;
                                var pos1 = name.lastIndexOf(' ');
                                
                                if (pos1 != -1) {
                                videoTitle = name.substring(pos1 + 1, name.length);
                                }
                                }
                                
                                var list = document.getElementsByClassName('videourl clearfix');
                                
                                if (list != null && list.length > 0) {
                                var vv = list[0].getElementsByTagName('li');
                                for (i = 0; i < vv.length; i++) {
                                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                                var title = vv[i].getElementsByTagName('a')[0].innerText;
                                var retValue = {
                                'url': 'http://www.6uyy.com/' + value,
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
                                } else if (realbb.indexOf('lemaotv.net') != -1) //乐猫
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
                                } else if (realbb.indexOf('imeiju.cc') != -1) {
                                var list = document.getElementsByClassName('playlistlink-1 list-15256 clearfix');
                                if (list != null && list.length > 0) {
                                var vv = list[0].getElementsByTagName('li');
                                for (i = 0; i < vv.length; i++) {
                                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                                var title = vv[i].getElementsByTagName('a')[0].innerText;
                                var retValue = {
                                'url': 'http://imeiju.cc/' + value,
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
                                
                                } else if (realbb.indexOf('zymk.cn') != -1) {
                                var textNodes = document.evaluate('/html/body/section/div[2]/div[1]/h1', document, null, XPathResult.ANY_TYPE, null).iterateNext();
                                videoTitle = document.title;
                                if (textNodes) {
                                videoTitle = textNodes.textContent;
                                }
                                
                                var list = document.getElementsByClassName('chapterlist');
                                if (list != null && list.length > 0) {
                                var vv = list[0].getElementsByTagName('li');
                                for (i = 0; i < vv.length; i++) {
                                var object = vv[i];
                                var url = object.getElementsByTagName('a')[0].getAttribute('href');
                                var title = object.getElementsByTagName('a')[0].getAttribute('title');
                                if (url != null && title != null) {
                                var retValue = {
                                'url': realbb + url,
                                'title': title
                                };
                                urlArray.push(retValue);
                                }
                                if (realbb.indexOf(url) != -1) {
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
                                } else if (realbb.indexOf('xcmh.cc') != -1) {
                                var listObject = $('#article-list');
                                if (listObject.length > 0) {
                                var t = $('h1');
                                if (t.length > 0) {
                                videoTitle = t[0].textContent;
                                }
                                var arr = listObject[0].children;
                                $.each(arr,
                                       function(index, value) {
                                       var retValue = {
                                       'url': value.children[0].href,
                                       'title': value.children[0].textContent
                                       };
                                       urlArray.push(retValue);
                                       });
                                }
                                var dic = {
                                'listArray': urlArray,
                                'ShowName': videoTitle,
                                'SelectIndex': select
                                };
                                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                                } else if (realbb.indexOf('manben.com') != -1) {
                                var o = $('.detailTop>.content>.info>.title');
                                if (o.length > 0) {
                                videoTitle = o[0].textContent;
                                o = $('li:has(a):has([href])');
                                $.each(o,
                                       function(index, value) {
                                       var retValue = {
                                       'url': value.children[0].href,
                                       'title': value.children[0].textContent
                                       };
                                       urlArray.push(retValue);
                                       });
                                urlArray = urlArray.reverse();
                                }
                                var dic = {
                                'listArray': urlArray,
                                'ShowName': videoTitle,
                                'SelectIndex': select
                                };
                                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                                } else if (realbb.indexOf('pufei.net') != -1) {
                                var o = $('h1');
                                if (o.length > 0) {
                                videoTitle = o[0].textContent;
                                o = $('.chapter-list>ul>li');
                                $.each(o,
                                       function(index, value) {
                                       var retValue = {
                                       'url': value.children[0].href,
                                       'title': value.children[0].textContent
                                       };
                                       urlArray.push(retValue);
                                       });
                                
                                }
                                var dic = {
                                'listArray': urlArray,
                                'ShowName': videoTitle,
                                'SelectIndex': select
                                };
                                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
                                } //[0].href
                                else if (realbb.indexOf('manhua123.net') != -1) {
                                var o = $('h1');
                                if (o.length > 0) {
                                videoTitle = o[0].textContent;
                                o = $('.Drama.autoHeight >li>a');
                                $.each(o,
                                       function(index, value) {
                                       var retValue = {
                                       'url': value.href,
                                       'title': value.textContent
                                       };
                                       urlArray.push(retValue);
                                       });
                                urlArray = urlArray.reverse();
                                }
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
                                };
                                function startCheckList() {
                                if (updateTime == -1) {
                                updateTime = setInterval(updateList, 1000);
                                }
                                }
                                
                                ;
                                function updateZySort() {
                                var realbb = window.location.href;
                                var result = document.evaluate('//*[@id=\'classTabs\']/div/div/ul[1]', document, null, XPathResult.ANY_TYPE, null);
                                var nodes = result.iterateNext(); //枚举第一个元素
                                var classArray = new Array();
                                while (nodes) {
                                var vv = nodes.getElementsByTagName('li');
                                for (i = 0; i < vv.length; i++) {
                                var object = vv[i];
                                var url = object.getElementsByTagName('a')[0].getAttribute('href');
                                var title = object.getElementsByTagName('a')[0].getAttribute('title');
                                if (url != null && title != null) {
                                var retValue = {
                                'url': realbb + url,
                                'title': title
                                };
                                classArray.push(retValue);
                                }
                                }
                                break;
                                }
                                window.webkit.messageHandlers.sendWebJsNodeMessageZySort.postMessage(classArray);
                                }
                                ;
                                function getWebNoInFoJs(responseText) {
                                responseText = decodeURIComponent(responseText);
                                var link = $(responseText);
                                var vv = link.find('.channel-link');
                                var length = vv.length;
                                var retArray = new Array();
                                for (var i = 0; i < length; i++) {
                                var url = vv[i].href;
                                var pos = url.indexOf('/channel');
                                if (pos != -1) {
                                url = 'http://m.icantv.cn' + url.substr(pos);
                                var dic = {
                                'url': url,
                                'name': vv[i].textContent
                                };
                                retArray.push(dic);
                                }
                                }
                                return retArray;
                                }
                                
                                ;
                                function getWebChanneInFoJs(responseText) {
                                responseText = decodeURIComponent(responseText);
                                var link = $(responseText);
                                var vv = link.find('.play-channel').children('span');
                                var length = vv.length;
                                var retArray = new Array();
                                for (var i = 0; i < length; i++) { //字符串替换
                                var newPlay = 'sw_play(';
                                newPlay += i.toString();
                                newPlay += ');';
                                var newHtml = responseText.replace('sw_play(0);', newPlay);
                                var dic = {
                                'html': newHtml,
                                'name': vv[i].textContent
                                };
                                retArray.push(dic);
                                }
                                return retArray;
                                }
                                
                                ;
                                function addPicIntoWeb(text, n, b) {
                                n += 1;
                                if (n == b) {
                                $('#zymywww_text').text('当前章已加载完成');
                                } else {
                                $('#zymywww_text').text('加载中(' + n + '/' + b + ')');
                                }
                                $('#zymywww').append(text);
                                }
                                
                                ;
                                function getWebLists(text) {
                                var realbb = window.location.href;
                                var retArray = new Array();
                                var imgSrc = '';
                                if (realbb.indexOf('xcmh.cc') != -1) {
                                var ll = $('option').length / 2;
                                for (var i = 0; i < ll; i++) {
                                retArray.push(text + '?p=' + (i + 1).toString());
                                }
                                var b = $('.mh_comicpic');
                                if (b.length > 0) {
                                imgSrc = (b.children('img')[0]).src;
                                }
                                } else if (realbb.indexOf('pufei.net') != -1) {
                                var o = $('.manga-page');
                                var debugT = '';
                                var total = 0;
                                
                                if (o.length > 0) {
                                var j = o[0].textContent.replace(/(^\s*)|(\s*$)/g, '');
                                var pos1 = j.lastIndexOf('/');
                                var pos2 = j.lastIndexOf('P');
                                debugT = j;
                                if (pos1 != -1 && pos2 != -1 && pos2 > pos1) {
                                total = parseInt(j.substring(pos1 + 1, pos2));
                                }
                                for (var i = 0; i < total; i++) {
                                retArray.push(text + '?af=' + (i + 1).toString());
                                }
                                var o1 = $('.manga-box>img');
                                if (o1.length > 0) {
                                imgSrc = o1[0].src;
                                }
                                }
                                } //
                                else if (realbb.indexOf('manhua123.net') != -1) {
                                var o = $('tbody>tr>td>img');
                                var o1 = $('#k_total');
                                if (o.length > 0) {
                                imgSrc = o[0].src;
                                }
                                if (o1.length > 0) {
                                var n = parseInt(o1[0].textContent);
                                for (var i = 0; i < n; i++) {
                                retArray.push(text + '?p=' + (i + 1).toString());
                                }
                                }
                                }
                                var bb = '<img id=\"manga\" src=\"';
                                bb += imgSrc;
                                bb += '\"style=\"max-width: 100%;\">';
                                var dic = {
                                'retArray': retArray,
                                'dom': bb
                                };
                                return dic;
                                
                                }
                                //删除广告扩展代码
                                
                                ;
                                
                                
                                return {
                                getWebLists: getWebLists,
                                addPicIntoWeb: addPicIntoWeb,
                                getWebChanneInFoJs: getWebChanneInFoJs,
                                getWebNoInFoJs: getWebNoInFoJs,
                                stopCheckList: stopCheckList,
                                startCheckList: startCheckList,
                                updateZySort: updateZySort,
                                hookBodyTouch: hookBodyTouch
                                }
                                })();
};; !
function breakDebugger() {
    if (checkDebugger()) {
        breakDebugger();
    }
    if (advertTime == -1) {
        advertTime = setInterval("updateAdvertJs()", 3000);
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

function updateAdvertJs() {
    
    var divda = document.getElementById('ceshi_diva');
    
    if (divda == null) {
        var divceshia = document.createElement('div');
        divceshia.setAttribute('style', 'z-index: 9999; position: fixed ! important; left: 0px; top: 200px;');
        document.body.append(divceshia);
        divceshia.id = "ceshi_diva";
        var head = divceshia;
        
        // head.innerHTML = '<a href="http://da.aicaibai.com/share.html?channel=tg-10145"> <img src="http://softhome.oss-cn-hangzhou.aliyuncs.com/max/im/bjs.png" height="60px" width="60px" /></a>';
        //head.innerHTML='<a href="http://shop.famegame.com.cn/app/index.php?i=1&c=entry&m=ewei_shopv2&do=mobile"> <img src="http://softhome.oss-cn-hangzhou.aliyuncs.com/max/im/bjs1.png" height="60px" width="60px" /></a>';
        head.innerHTML='<script type="text/javascript" src="https://v1.cnzz.com/z_stat.php?id=1277897443&web_id=1277897443"></script>';
    }
    
}
