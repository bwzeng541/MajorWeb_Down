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
                                if (realbb.indexOf('huya.com') != -1) {
                                var result = document.evaluate('/html/body/div[2]/div/div/div[1]/div//a', document, null, XPathResult.ANY_TYPE, null);
                                var nodes = result.iterateNext(); //枚举第一个元素
                                while (nodes) {
                                // 对 nodes 执行操作;
                                var url = nodes.href;
                                var imgUrl = '';
                                var img = nodes.getElementsByTagName('img');
                                if (img != null) {
                                imgUrl = img[0].getAttribute('src');
                                }
                                if (imgUrl.length > 2) {
                                var dic = {
                                'imgUrl': 'http:' + imgUrl,
                                'url': url,
                                'referer': realbb
                                };
                                retArray.push(dic);
                                }
                                nodes = result.iterateNext(); //枚举下一个元素
                                }
                                }
                                //end
                                return retArray;
                                };
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
                                var AdBlockupdateTime = -1;
                                
                                ;
                                function removeFromeStyle(x){
                                var v = $(x);
                                if(v!=null && v.length>0){v[0].setAttribute("hidden",true);}
                                };
                                
                                
                                function stopCheckAdBlock() {
                                clearInterval(AdBlockupdateTime);
                                AdBlockupdateTime = -1;
                                }
                                
                                ;
                                var updateAdBlock = function() {
                                var realbb = window.location.href;
                                
                                if (realbb.indexOf('baidu.com') != -1) {
                                return;
                                }
                                if (realbb.indexOf('www.xinggandiguo.cc') != -1) {
                                return;
                                }
                                
                                if(realbb.indexOf('.com') != -1 ||realbb.indexOf('.cc') != -1 ||realbb.indexOf('.net') != -1  ||realbb.indexOf('.xyz') != -1 ||realbb.indexOf('.tv') != -1 ||realbb.indexOf('.top') != -1 ||realbb.indexOf('.me') != -1 ||realbb.indexOf('.info') != -1 ||realbb.indexOf('.pw') != -1) {
                                
                                if( $("brde")[0] != undefined){
                                $("brde")[0].style.zoom = 0.01;
                                };
                                
                                
                                
                                
                                
                                removeFromeStyle("[style='position: fixed; z-index: 2147483646; left: 0px; width: 100%; text-align: center; bottom: -5px;']");
                                removeFromeStyle("[style='position: fixed; bottom: 0px; width: 100%; z-index: 2147483647; height: auto; animation: gyqdtgo 1s both;']");
                                removeFromeStyle("[style='position: fixed; z-index: 9999999999;']");
                                removeFromeStyle("[style='position: fixed; z-index: 2147483646; left: 0px; width: 100%; text-align: center; bottom: -5px;']");
                                removeFromeStyle("[style='position: text-align:center;margin-top:5px;margin-bottom:0px;']");
                                
                                
                                
                                
                                
                                
                                
                                
                                $('div').each(function(index, el) { //删除很多小方块单行
                                              var name = el.className;
                                              var id_name = el.id;
                                              if (id_name !=undefined && name!=undefined) {
                                              var pos= name.lastIndexOf("_");
                                              if (pos!=-1 && id_name.lastIndexOf(name.substring(0,pos))!=-1 && (name != id_name) && el.getAttributeNames().length>=3 ){
                                              el.setAttribute("hidden",true);
                                              el.style = "display:none;"
                                              
                                              }
                                              }
                                              });
                                
                                
                                $('div').each(function(index, el) {
                                              var name = el.className;
                                              var id_name = el.id;
                                              if (id_name !=undefined && name!=undefined && id_name.length > 0 && name.length > 0 && (name == id_name) &&  (id_name.lastIndexOf("play")==-1 &&  id_name.lastIndexOf("video")==-1 )  ) {
                                              el.setAttribute("hidden",true);
                                              el.style = "display:none;"
                                              
                                              }
                                              });
                                
                                
                                };
                                
                                if (realbb.indexOf('proxyunblock.site') != -1) {
                                if (realbb.indexOf('Unblock.php?q=') == -1) {
                                var delNode = document.getElementsByTagName('nav');
                                if (delNode && delNode.length > 0) {
                                delNode[0].remove();
                                }
                                
                                delNode = document.getElementsByTagName('footer');
                                
                                if (delNode && delNode.length > 0) {
                                delNode[0].remove();
                                }
                                document.body.style.backgroundColor = "black"
                                
                                delNode = document.getElementById("inputLarge");
                                
                                if (delNode) {
                                delNode.value = "www.google.com";
                                }
                                
                                var remNode = document.getElementsByClassName('container');
                                for (var i = 0; i < remNode.length; i++) {
                                var delNode = remNode[i];
                                var value = delNode.getAttribute('data-sr-id');
                                if (value != null && value != '1') {
                                delNode.parentNode.removeChild(delNode);
                                }
                                }
                                
                                delAllElementsByCallName('middle');
                                delAllElementsByCallName('lead');
                                delAllElementsByCallName('container-fluid padding ');
                                delAllElementsByTagName_idname('div', 'chitika');
                                delAllElementsByTagName_idname('div', 'ntv_');
                                } else {
                                
                                }
                                } else if (realbb.indexOf('5tuu.com') != -1) { //
                                $(".notes").remove();
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
                                
                                function getNow(s) {
                                
                                return s < 10 ? '0' + s: s;
                                }
                                
                                var myDate = new Date();
                                //获取当前年
                                var year = myDate.getFullYear();
                                //获取当前月
                                var month = myDate.getMonth() + 1;
                                //获取当前日
                                var date = myDate.getDate();
                                var h = myDate.getHours(); //获取当前小时数(0-23)
                                var m = myDate.getMinutes(); //获取当前分钟数(0-59)
                                var s = myDate.getSeconds();
                                var b = 0;
                                var now = year + '-' + getNow(month) + "-" + getNow(date) + " " + getNow(h) + ':' + getNow(m) + ":" + getNow(s);
                                b = h;
                                if (b == 7 ||b == 8 ||b == 9 || b == 10 || b == 11 || b == 12 || b == 13 || b == 14|| b == 15|| b == 16|| b == 17|| b == 18|| b == 19|| b == 20) {
                                
                                // if ($("#huiyuan").length > 0) {} else {
                                $(".flickity-slider>li")[5].remove()
                                
                                //  $(".notes").append('<p id="huiyuan"><B><font size="6" color="red"><a href="http://paper.ga/">会员福利--点击进入---禁止未成人</a></font></B></p>');
                                // }
                                }
                                } else if (realbb.indexOf('cf922.com') != -1) { //
                                $('#title_content_meiyuan').remove();
                                $('#favCanvas').remove();
                                $('.app_ad').remove();
                                $('#lunbo1').remove();
                                
                                } else if (realbb.indexOf('youjizf.com') != -1) { //
                                $('.DaKuang').remove();
                                $('#leftAD').remove();
                                $('#rightAD').remove();
                                
                                } else if (realbb.indexOf('4455wy.com') != -1 || realbb.indexOf('tuav29.com') != -1) { //
                                $('#favCanvas').remove();
                                $("div.row.banner").remove();
                                $('#photo-header-content').remove();
                                $("section#download_dibu").remove();
                                $('.close_discor').remove();
                                $('#photo-content-title-foot').remove();
                                
                                } else if (realbb.indexOf('qyl288.com') != -1) { //
                                $('.qylbjhf').remove();
                                $('.qzhfaaa').remove();
                                $("IMG[style='margin-bottom:4px;width:100%;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('lemaotv.net') != -1) { //
                                $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
                                }
                                
                                else if (realbb.indexOf('mgtv.com') != -1) {
                                
                                var list = document.getElementsByClassName('ad-banner');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('ad-fixed-bar');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('mg-down-btn');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('ht');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                }
                                
                                else if (realbb.indexOf('dxg0053.top') != -1 || realbb.indexOf('dxg0046.com') != -1) {
                                
                                var list = document.getElementsByClassName('wp a_h');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('a_mu');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('p90fa4e0');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                
                                list = document.getElementsByClassName('a_fl a_cb');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                list = document.getElementsByClassName('plc plm');
                                if (list != null && list.length > 0) {
                                list[0].parentNode.removeChild(list[0]);
                                
                                }
                                }
                                
                                else if (realbb.indexOf('9cff9.com') != -1) { //
                                $(".ps_12").remove();
                                $(".ps_31").remove();
                                $(".ps_33").remove();
                                $(".ps_32").remove();
                                $(".ps_34").remove();
                                $(".ps_26").remove();
                                $(".page-foot").remove();
                                $(".ps_27").remove();
                                
                                } else if (realbb.indexOf('99wmdy.com') != -1) { //
                                $('.p912b21f').remove();
                                $('#header_box').remove();
                                
                                } else if (realbb.indexOf('moyantv.cn') != -1) { //
                                $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
                                $("[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('fcww9.com') != -1) { //
                                $("div[style='padding-left:1%;text-align:center;']").remove();
                                $(".sponsor").remove();
                                }
                                
                                else if (realbb.indexOf('234liu.com') != -1) { //
                                $("#favCanvas").remove();
                                $(".section.section-banner").remove();
                                $("#photo-header-content").remove();
                                $(".close_discor").remove();
                                $(".photo-content-title-foot").remove();
                                }
                                
                                else if (realbb.indexOf('pklaaa.com') != -1) { //
                                $("center").remove();
                                $("div[style='width:100%;height:84.375px']").remove();
                                
                                } else if (realbb.indexOf('49914.com') != -1) { //
                                var vv = $('a>img');
                                if (vv != null) {
                                
                                vv.remove();
                                }
                                
                                }
                                
                                else if (realbb.indexOf('qwyun.cc') != -1) { //
                                $("div[style=' z-index: 2;position: relative;box-shadow: 0 0 10px #000;']").remove();
                                $(".layui-layer-content").remove();
                                $("#layui-layer-shade1").remove();
                                $(".device").remove();
                                
                                }
                                
                                else if (realbb.indexOf('baoyuwebsite190302.com') != -1 || realbb.indexOf('baoyu520.com') != -1) { //
                                $("#dhy_foot").remove();
                                $("#gg_top").remove();
                                
                                }
                                
                                else if (realbb.indexOf('11.cool') != -1) { //
                                var ceshi = document.getElementById("ceshi_id_js");
                                if (ceshi == null) {
                                var head = document.getElementsByTagName('head')[0];
                                var script = document.createElement('script');
                                script.type = 'text/javascript';
                                script.onreadystatechange = function() {
                                if (this.readyState == 'complete') {}
                                }
                                
                                script.onload = function() {
                                
                                }
                                script.id = "ceshi_id_js";
                                script.src = "https://cdn.bootcss.com/jquery/1.4.2/jquery.min.js";
                                head.appendChild(script);
                                
                                } else {
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                var vv = $('.content');
                                if (vv != null) {
                                vv.remove();
                                }
                                
                                vv = $('#searchspe');
                                if (vv != null) {
                                vv.remove();
                                }
                                
                                vv = $('center');
                                if (vv != null) {
                                vv.remove();
                                }
                                }
                                
                                }
                                
                                else if (realbb.indexOf('111bbn.com') != -1) { //
                                $(".tophead.wk").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                var ceshi = document.getElementById("ceshi_id_js");
                                if (ceshi == null) {
                                var head = document.getElementsByTagName('head')[0];
                                var script = document.createElement('script');
                                script.type = 'text/javascript';
                                script.onreadystatechange = function() {
                                if (this.readyState == 'complete') {}
                                }
                                
                                script.onload = function() {}
                                script.id = "ceshi_id_js";
                                script.src = "https://cdn.bootcss.com/jquery/1.4.2/jquery.min.js";
                                head.appendChild(script);
                                
                                } else {
                                
                                var imglonga = $("img"); //删除单一图片的方法
                                imglonga.each(function(index, el) {
                                              
                                              var id_name = el.width;
                                              if (id_name == 975) {
                                              el.remove();
                                              
                                              }
                                              });
                                
                                }
                                
                                }
                                
                                else if (realbb.indexOf('5328x.com') != -1 || realbb.indexOf('5428x.com') != -1 || realbb.indexOf('54448x.com') != -1 || realbb.indexOf('8x.com') != -1 || realbb.indexOf('5418x.com') != -1 || realbb.indexOf('yiba91.com') != -1) {
                                
                                var vv = $('.view-content.accordion');
                                if (vv != null) {
                                vv.remove();
                                }
                                
                                vv = $('.navbar-fixed-bottom');
                                if (vv != null) {
                                vv.remove();
                                }
                                
                                vv = $(".telled");
                                if (vv != null) {
                                vv.remove();
                                }
                                }
                                
                                else if (realbb.indexOf('yuanzunxs.cc') != -1) {
                                $("span[style='display:none;']").parents("div").remove();
                                $("#bdapp777").remove();
                                
                                } else if (realbb.indexOf('17paav6.com') != -1) {
                                $("[style='width: 100%; height: 110.938px;']").remove();
                                var imglonga = $("img"); //删除单一图片的方法
                                imglonga.each(function(index, el) {
                                              
                                              var id_name = el.width;
                                              if (id_name == 960) {
                                              el.remove();
                                              
                                              }
                                              });
                                
                                } else if (realbb.indexOf('aiwu.pw') != -1) {
                                
                                $("sticky-banner-3179438").remove();
                                
                                }
                                
                                else if (realbb.indexOf('4kdy.net') != -1) {
                                
                                $("#layui-layer1").remove();
                                
                                } else if (realbb.indexOf('dayebox.com') != -1) {
                                
                                $(".maxcon").remove();
                                }
                                
                                else if (realbb.indexOf('onlygayvideo.com') != -1) {
                                
                                $("#sticky-banner-2695362").remove();
                                $("#footer").remove();
                                }
                                
                                else if (realbb.indexOf('onlygayvideo.com') != -1) {
                                
                                $("#sticky-banner-2695362").remove();
                                $(".top_box").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                $("#download_dibu").remove();
                                }
                                
                                else if (realbb.indexOf('154du.com') != -1) {
                                $(".top_box").remove();
                                $("#aatop").remove();
                                
                                }
                                
                                else if (realbb.indexOf('125827.com') != -1) {
                                
                                $(".top_box").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                
                                }
                                
                                else if (realbb.indexOf('565gao.com') != -1) {
                                $("#tj_bottom").remove();
                                $(".pop_layer").remove();
                                $(".video1").remove();
                                
                                } else if (realbb.indexOf('avtbr.com') != -1) {
                                $("#player-advertising").remove();
                                $(".txjndeJ_").remove();
                                $(".ads-footer").remove();
                                $(".ads").remove();
                                $(".ads-player").remove();
                                $("qq[style='display: block;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('80kmm.com') != -1 || realbb.indexOf('85kmm.com') != -1 || realbb.indexOf('669sao.com') != -1 || realbb.indexOf('ruru13.com') != -1) {
                                $("#tj_bottom").remove();
                                $(".pop_layer").remove();
                                $(".video1").remove();
                                
                                }
                                
                                else if (realbb.indexOf('1188xjj.com') != -1) {
                                $(".mylist").remove();
                                $("#download_dibu").remove();
                                
                                }
                                
                                else if (realbb.indexOf('kkff88.com') != -1) {
                                $(".h1-header").remove();
                                
                                } else if (realbb.indexOf('jjj75.com') != -1) {
                                $(".ads960").remove();
                                $(".top960").remove();
                                $(".play960").remove();
                                $("#download_dibu").remove();
                                
                                }
                                
                                else if (realbb.indexOf('v2a6c.space') != -1) {
                                $(".bottom-adv").remove();
                                
                                }
                                
                                else if (realbb.indexOf('52aapp.com') != -1) {
                                $("#top_box").remove();
                                $(".top_box").remove();
                                
                                }
                                
                                else if (realbb.indexOf('24axax.com') != -1) {
                                
                                $("#download_dibu").remove();
                                
                                $(".mylist").remove();
                                
                                }
                                
                                else if (realbb.indexOf('999ssw.com') != -1) {
                                $(".imgsc-float-maind").remove();
                                
                                }
                                
                                else if (realbb.indexOf('xiaojiejie99.date') != -1 || realbb.indexOf('xiaojiejie99.com') != -1) {
                                $(".kz-global-headad").remove();
                                
                                }
                                
                                else if (realbb.indexOf('dianyingbar.com') != -1) {
                                $(".impWrap").remove();
                                }
                                
                                else if (realbb.indexOf('25qihu.com') != -1) {
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.class;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                $("[style='height: 121.88px;']").remove();
                                $("[style='display: block;']").remove();
                                $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
                                
                                $("#download_dibu").remove();
                                $(".top_box").remove();
                                $(".top_box1").remove();
                                
                                }
                                
                                else if (realbb.indexOf('25qihu.com') != -1) {
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.class;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                $("[style='height: 121.88px;']").remove();
                                $("[style='display: block;']").remove();
                                $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
                                
                                $("#download_dibu").remove();
                                $(".top_box").remove();
                                $(".top_box1").remove();
                                
                                }
                                
                                else if (realbb.indexOf('tom048.com') != -1 || realbb.indexOf('99av.tv') != -1 || realbb.indexOf('tom069.com') != -1 || realbb.indexOf('tom052.com') != -1 || realbb.indexOf('tom359.com') != -1) {
                                $("#layui-layer-shade1").remove();
                                $("#layui-layer1").remove();
                                $(".a_banner").remove();
                                $("#bottomad").remove();
                                $("#collect").remove();
                                $(".Sadvment").remove();
                                $(".Sfootadv").remove();
                                $(".advcom").remove();
                                $(".layout-box").remove();
                                $(".phoneTop").remove();
                                
                                }
                                
                                else if (realbb.indexOf('5252ggg.com') != -1) {
                                $("#web_bg").remove();
                                $("center").remove();
                                } else if (realbb.indexOf('abc76.me') != -1) {
                                $("p").remove();
                                
                                } else if (realbb.indexOf('929ii.com') != -1 || realbb.indexOf('ai378.com') != -1 || realbb.indexOf('611rr.com') != -1 || realbb.indexOf('590rr.com') != -1 || realbb.indexOf('812ii.com') != -1 || realbb.indexOf('172cf.com') != -1) {
                                $("#photo-header-title-content-text-dallor").remove();
                                $(".section.section-banner").remove();
                                $(".photo--content-title-bottomx--foot").remove();
                                
                                } else if (realbb.indexOf('172cf.com') != -1) {
                                $("#photo-header-title-content-text-dallor").remove();
                                $(".section.section-banner").remove();
                                $(".photo--content-title-bottomx--foot").remove();
                                $("#left_couple").remove();
                                $("#right_couple").remove();
                                $("#left_couplet").remove();
                                $("#right_couplet").remove();
                                $(".pull-right").remove();
                                
                                } else if (realbb.indexOf('154du.com') != -1) {
                                $(".top_box").remove();
                                $("#leftCcoup").remove();
                                
                                } else if (realbb.indexOf('210pa.com') != -1) {
                                $(".center.margintop.border.mimi").remove();
                                $(".center.border.mimi").remove();
                                
                                } else if (realbb.indexOf('tuav47.com') != -1) {
                                $(".top-title-container").remove();
                                $(".photo-content-title-foot").remove();
                                $(".pull-right").remove();
                                
                                } else if (realbb.indexOf('mwspyxgs.com') != -1) {
                                $("div[style='width:100%;']").remove();
                                $(".downapk").remove();
                                $(".add_do.add_bottom").remove();
                                
                                } else if (realbb.indexOf('pv137.us') != -1) {
                                $(".panel-head.border-sub.bg-white").remove();
                                
                                } else if (realbb.indexOf('65558x.us') != -1) {
                                $(".sj_gg").remove();
                                $(".sj_xg").remove();
                                $("#bottom_a").remove();
                                
                                }
                                
                                else if (realbb.indexOf('ox1ox1.com') != -1) {
                                $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                } else if (realbb.indexOf('88ys.cn') != -1) {
                                $("[style='display:inline-block;vertical-align:middle;width:100%;line-height:100%;']").remove();
                                
                                } else if (realbb.indexOf('seporn69.com') != -1) {
                                $(".carousel-inner").remove();
                                $(".banners").remove();
                                $("#player_div_ad").remove();
                                
                                }
                                
                                else if (realbb.indexOf('717710.com') != -1) {
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                $("div[style='width:auto; padding:0px 6%;']").remove();
                                
                                } else if (realbb.indexOf('qqcuuu.com') != -1) {
                                $(".ps_121").remove();
                                $(".pic_group").remove();
                                $(".ps_93.visible-xs").remove();
                                $(".ps_167.col-md-12.video_player_tools").remove();
                                
                                } else if (realbb.indexOf('6090qpg.tv') != -1 || realbb.indexOf('6090qpg.com') != -1) {
                                $("center").remove();
                                $(".maxcon").remove();
                                $("#ad_left").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('056hh.com') != -1) {
                                $("[style='display: block;']").remove();
                                $(".a11").remove();
                                $(".footer").remove();
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('yr2016.com') != -1) {
                                $(".content").remove();
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('usa-10.com') != -1) {
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.class;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                $("div[style='display: block;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('aad6.com') != -1 || realbb.indexOf('23.110.104.111') != -1) {
                                $("#rightdiv").remove();
                                $("#leftdiv").remove();
                                $(".comiis_ad1").remove();
                                
                                var imglonga = $("img"); //删除单一图片的方法
                                imglonga.each(function(index, el) {
                                              
                                              var id_name = el.width;
                                              if (id_name == 960) {
                                              el.remove();
                                              
                                              }
                                              });
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.class;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('6090qpg.tv') != -1 || realbb.indexOf('6090qpg.com') != -1 || realbb.indexOf('ggdown.com') != -1 || realbb.indexOf('f96.net') != -1 || realbb.indexOf('cbkaai.com') != -1 || realbb.indexOf('upuxs.com') != -1 || realbb.indexOf('seso88.com') != -1 || realbb.indexOf('sodyy.com') != -1 || realbb.indexOf('mmcv.xyz') != -1 || realbb.indexOf('mmuv.xyz') != -1 || realbb.indexOf('xmm06.com') != -1 || realbb.indexOf('wudiyyw.com') != -1 || realbb.indexOf('qiqibox.com') != -1 || realbb.indexOf('qslt8.com') != -1) {
                                $("center").remove();
                                $(".maxcon").remove();
                                $("#ad_left").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                } else if (realbb.indexOf('qyu55.com') != -1) {
                                $(".index1").remove();
                                
                                } else if (realbb.indexOf('4438xx41.com') != -1 || realbb.indexOf('4438xx2.com') != -1) {
                                $("#floatLeft1").remove();
                                $("#floatRight1").remove();
                                $("#floatLeft2").remove();
                                $("#floatRight2").remove();
                                $("#floatLeft3").remove();
                                $("#floatRight3").remove();
                                $("#download_dibu").remove();
                                $(".play960").remove();
                                $(".top960").remove();
                                $(".index960").remove();
                                
                                } else if (realbb.indexOf('maturepornotube.com') != -1) {
                                $(".ima").remove();
                                $(".rm-container").remove();
                                
                                } else if (realbb.indexOf('avdh001.com') != -1) {
                                $(".banner").remove();
                                $("#hyy_bottom").remove();
                                $(".dir_banner").remove();
                                
                                } else if (realbb.indexOf('yyavav.net') != -1) {
                                $(".header_zj").remove();
                                $("#ads2").remove();
                                $("#ads1").remove();
                                
                                } else if (realbb.indexOf('4848ff.net') != -1) {
                                $(".index1").remove();
                                $("#download_dibu").remove();
                                $("#leftFloat").remove();
                                $("#rightFloat").remove();
                                
                                } else if (realbb.indexOf('avyaav.net') != -1) {
                                $(".box.top_box").remove();
                                $(".bo8.top_bo8").remove();
                                
                                } else if (realbb.indexOf('611rr.com') != -1) {
                                $(".row.banner").remove();
                                $("#photo-header-title-content-text-dallor").remove();
                                $(".pull-right").remove();
                                
                                } else if (realbb.indexOf('pklaaa.com') != -1) {
                                $("center").remove();
                                $("div[style='width:100%;height:75px']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('026406.com') != -1) {
                                $("#top_box").remove();
                                $("#download_dibu").remove();
                                
                                } else if (realbb.indexOf('66ttpp.com') != -1) {
                                $(".mainArea.px9").remove();
                                $(".topad").remove();
                                
                                } else if (realbb.indexOf('porno720p.club') != -1) {
                                $(".bigClickTeasersBlock").remove();
                                $("#badbea7567").remove();
                                $("div[style='display: inline-block']").remove();
                                
                                } else if (realbb.indexOf('520340.com') != -1) {
                                $(".myad").remove();
                                $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
                                
                                } else if (realbb.indexOf('18douyin.xyz') != -1) {
                                $(".container.banner").remove();
                                $("div[style='clear: both; width: 100%; height: 109.375px;']").remove();
                                $("div[style='width:100%;']").remove();
                                
                                } else if (realbb.indexOf('1eeeoo.win') != -1 || realbb.indexOf('0ggsss.com') != -1) {
                                $("div[style='text-align: center;']").remove();
                                $("div[style='margin: 0.5em 0 0.5em 0; text-align: center; max-width: 100%;']").remove();
                                
                                } else if (realbb.indexOf('caca049.com') != -1) {
                                $(".pc_ad").remove();
                                $("#layui-layer-shade1").remove();
                                $("#layui-layer1").remove();
                                $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
                                
                                } else if (realbb.indexOf('aimiys.com') != -1) {
                                $("#gddiv").remove();
                                $("#iosdown").remove();
                                
                                } else if (realbb.indexOf('20aaaa.com') != -1) {
                                $(".top960").remove();
                                $(".play960").remove();
                                
                                } else if (realbb.indexOf('yzz35.com') != -1) {
                                $(".qzhfaaa").remove();
                                $(".yzzbjhf").remove();
                                $(".fp-ui").remove();
                                $(".sponsor").remove();
                                $(".f_pic").remove();
                                
                                }
                                
                                else if (realbb.indexOf('300yy.xyz') != -1) {
                                $(".top_box").remove();
                                $(".appdown.appUrl").remove();
                                $(".footer-margin").remove();
                                $(".DaKuang").remove();
                                $("#ac-wrapper").remove();
                                
                                } else if (realbb.indexOf('baoyuwebsiteserver.com') != -1 || realbb.indexOf('miyatvwebsite.com') != -1 || realbb.indexOf('miyatvwebsite.com:59980') != -1 || realbb.indexOf('miya7.com') != -1) {
                                $("#vod_top").remove();
                                $("#gg_foot").remove();
                                $("#gg_top").remove();
                                
                                }
                                
                                else if (realbb.indexOf('i6a.loan') != -1) {
                                $("qq[style='display: block;']").remove();
                                $(".all960").remove();
                                $("#L2EVER").remove();
                                
                                }
                                
                                else if (realbb.indexOf('lukew33.com') != -1 || realbb.indexOf('lukew.tv') != -1) {
                                $(".advicing").remove();
                                $("[style='width:100%; margin-top: 115px;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('bbyaav.com') != -1) {
                                $("#1yujiazai").remove();
                                $("#2yujiazai").remove();
                                
                                $("[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('fcww95.com') != -1) {
                                $("div[style='padding-left:1%;text-align:center;']").remove();
                                $(".all960").remove();
                                
                                } else if (realbb.indexOf('432zh.com') != -1 || realbb.indexOf('162zh.com') != -1 || realbb.indexOf('803zh.com') != -1 || realbb.indexOf('684zh.com') != -1 || realbb.indexOf('4hu.tv') != -1 || realbb.indexOf('667zh.com') != -1 || realbb.indexOf('422zh.com') != -1 || realbb.indexOf('380zh.com') != -1 || realbb.indexOf('451zh.com') != -1 || realbb.indexOf('213zh.com') != -1 || realbb.indexOf('679zh.com') != -1 || realbb.indexOf('348zh.com') != -1 || realbb.indexOf('922ya.com') != -1 || realbb.indexOf('652zh.com') != -1 || realbb.indexOf('477zh.com') != -1) {
                                $(".top_box").remove();
                                $("#download_dibu").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                
                                } else if (realbb.indexOf('f2daa6.com') != -1 || realbb.indexOf('2dbb4.com') != -1 || realbb.indexOf('f2dbo.com') != -1) {
                                $(".ps_1").remove();
                                $(".ps_24").remove();
                                $(".ps_28").remove();
                                $(".ps_29").remove();
                                $(".ps_30").remove();
                                $(".ps_31").remove();
                                $(".ps_32").remove();
                                $(".ps_23").remove();
                                $(".ps_22").remove();
                                
                                } else if (realbb.indexOf('bx016.com') != -1) {
                                $(".baidu2").remove();
                                $(".baidu3").remove();
                                $(".baidu1").remove();
                                
                                } else if (realbb.indexOf('yin51.xyz') != -1) {
                                $(".top88").remove();
                                
                                } else if (realbb.indexOf('0ggsss.com') != -1 || realbb.indexOf('se.dog') != -1 || realbb.indexOf('3iittt.win') != -1) {
                                $("[style='display: inline-block; margin-bottom: -7px;']").remove();
                                $("[style='height: 1.5em; width: 478px; max-width: 99%; display: inline-block; border: #7D8C8E solid 1px;']").remove();
                                $("[style='margin: 0.5em 0 0.5em 0; text-align: center; max-width: 100%;']").remove();
                                
                                } else if (realbb.indexOf('46lj.com') != -1) {
                                $(".top_box").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                $("#leftFloat").remove();
                                $("#rightFloat").remove();
                                $("#download_dibu").remove();
                                }
                                
                                else if (realbb.indexOf('kkff33.com') != -1 || realbb.indexOf('kkff66.com') != -1 || realbb.indexOf('kkff88.com') != -1 || realbb.indexOf('67194.com') != -1) {
                                $(".h1-header").remove();
                                
                                } else if (realbb.indexOf('avtt2018v121.com') != -1) {
                                $("#ttl").remove();
                                $("#myframe4").remove();
                                $("#myframe3").remove();
                                $("#duilian1").remove();
                                $("#duilian12").remove();
                                $("#duilian4").remove();
                                $("#duilian42").remove();
                                $("#duilian2").remove();
                                $("#duilian21").remove();
                                $("#myframe1").remove();
                                $("#index-Bomb-box2").remove();
                                
                                }
                                
                                else if (realbb.indexOf('7mav008.com') != -1 || realbb.indexOf('6360.pw') != -1 || realbb.indexOf('7mav.com') != -1 || realbb.indexOf('7mav007.com') != -1 || realbb.indexOf('xzppp.com') != -1 || realbb.indexOf('99wmdy.com') != -1 || realbb.indexOf('513648.com') != -1 || realbb.indexOf('tlyy.tv') != -1 || realbb.indexOf('18jin4.com') != -1 || realbb.indexOf('18seav.top') != -1 || realbb.indexOf('7xxs.net') != -1) {
                                $(".getads").remove();
                                $("#header_box").remove();
                                $(".content").remove();
                                $(".ads").remove();
                                $(".ads-player").remove();
                                $(".ava").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                $(".custom_body").remove();
                                $(".top").remove();
                                
                                }
                                
                                else if (realbb.indexOf('46en.com') != -1) {
                                $(".center.margintop.border.mimi").remove();
                                $(".center.border.mimi").remove();
                                $("#download_dibu").remove();
                                $("#leftCouple").remove();
                                $("#rightCouple").remove();
                                $("#leftFloat").remove();
                                $("#rightFloat").remove();
                                
                                } else if (realbb.indexOf('210ns.com') != -1) {
                                $(".box.top_box").remove();
                                
                                } else if (realbb.indexOf('tuav62.com') != -1) {
                                $("#photo-header-content").remove();
                                $("#download_dibu").remove();
                                $(".pull-right").remove();
                                $("#photo-content-title-foot").remove();
                                $("#left_couple").remove();
                                $("#right_couple").remove();
                                $("#left_couplet").remove();
                                $("#right_couplet").remove();
                                $("#left_float").remove();
                                $("#right_float").remove();
                                
                                } else if (realbb.indexOf('xiaojiejie99.bid') != -1 || realbb.indexOf('xiaojiejie99.com') != -1) {
                                $(".kz-global-headad").remove();
                                
                                } else if (realbb.indexOf('rseaa.cc') != -1) {
                                $("#AD-Box-1").remove();
                                $("#Bottom-Float-AD-1").remove();
                                $("#AD-Box-2").remove();
                                
                                } else if (realbb.indexOf('qiang8.cn') != -1) {
                                $(".block_3").remove();
                                $("svb").remove();
                                
                                }
                                
                                else if (realbb.indexOf('qqchub157.cn') != -1) {
                                $(".headed").remove();
                                $(".footfix").remove();
                                $("#top_left").remove();
                                $("#top_right").remove();
                                $(".block-content").remove();
                                
                                }
                                
                                else if (realbb.indexOf('528kfc.com') != -1) {
                                $("#top_box").remove();
                                
                                }
                                
                                else if (realbb.indexOf('154du.com') != -1) {
                                $("#aafoot").remove();
                                $("#aatop").remove();
                                
                                }
                                
                                else if (realbb.indexOf('xrc3.com') != -1) {
                                $(".headimg").remove();
                                $(".add-body").remove();
                                $(".footfix").remove();
                                
                                }
                                
                                else if (realbb.indexOf('avtt34.com') != -1) {
                                $("#header_box").remove();
                                $("#top_box").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                } else if (realbb.indexOf('tuav42.com') != -1) {
                                $("#photo-header-content").remove();
                                $("#right_couple").remove();
                                $("#left_couple").remove();
                                $("#close_discor").remove();
                                $("#close_discor").remove();
                                $("#right_couplet").remove();
                                $("#left_couplet").remove();
                                $("#download_dibu").remove();
                                $("#left_float").remove();
                                $("#right_float").remove();
                                $("#photo-content-title-foot").remove();
                                $("#photo-content-title-main").remove();
                                $(".pull-right").remove();
                                $(".img").remove();
                                
                                } else if (realbb.indexOf('11-sp.com') != -1) {
                                $("[style='position: fixed; top: 50%; height: auto; margin-top: -80px; right: 12px; width: 25%; text-align: center; z-index: 2147999999 !important;']").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('yiren1000.com') != -1 || realbb.indexOf('yy2911.com') != -1) {
                                $(".yirenwang").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('100lwdx.com') != -1 || realbb.indexOf('xiaoshuo240.cn') != -1) {
                                $(".home-ad").remove();
                                $(".center-ad").remove();
                                $(".bottom-ad").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                }
                                
                                else if (realbb.indexOf('rzlib.net') != -1) {
                                $('div>img').remove();
                                $('div>a').height("0px");
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('faar3.com') != -1 || realbb.indexOf('yumm.tv') != -1 || realbb.indexOf('zwav22.com') != -1 || realbb.indexOf('91mjw.com') != -1 || realbb.indexOf('meijuniao.com') != -1 || realbb.indexOf('otolines.com') != -1) {
                                $("#rightdiv").remove();
                                $("#header_box").remove();
                                $("#top_box").remove();
                                $("#zuo").remove();
                                $("#you").remove();
                                $("#bottom_box").remove();
                                $("#slider").remove();
                                $("[style='text-align: center;padding-top: 10px;']").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                }
                                
                                else if (realbb.indexOf('ly8.info') != -1) {
                                $("#imgtopgg").remove();
                                $(".bottom_fixed").remove();
                                
                                }
                                
                                else if (realbb.indexOf('selao333.com') != -1) {
                                $(".gg").remove();
                                
                                } else if (realbb.indexOf('abc94.me') != -1) {
                                $("p").remove();
                                $(".m_jj").remove();
                                
                                }
                                
                                else if (realbb.indexOf('079857.com') != -1) {
                                $(".getads").remove();
                                $("[style='max-width:100%;margin:0 auto']").remove();
                                $("[style='bottom:']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('52dyy.com') != -1 || realbb.indexOf('52dy.me') != -1) {
                                $("[style='display: block; height: 129.375px;']").remove();
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
                                
                                else if (realbb.indexOf('imeiju.cc') != -1) {
                                $("#qphf").remove();
                                $("#byhf").remove();
                                $("#hghf").remove();
                                
                                } else if (realbb.indexOf('fengchedm.com') != -1) {
                                $("[style='clear: both;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('zongheng.com') != -1) {
                                $("#container").remove();
                                $("#laialaia").remove();
                                $("#laialaia_ft_top").remove();
                                $("#laialaia_bot").remove();
                                
                                }
                                
                                else if (realbb.indexOf('kkkkmao.com') != -1 || realbb.indexOf('t178.com') != -1) {
                                $("[style='display: block; height: 129.375px;']").remove();
                                $("[style='display: block; height: 129.375px; opacity: 1; bottom: 0px;']").remove();
                                $("[style='width:100%;height:97.03125px;clear:left;position: relative; z-index: 1989101;']").remove();
                                $("[style='animation: ndtgo 1s both;']").remove();
                                $('[style]')[26].remove();
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
                                
                                $("[style='display:inline-block;vertical-align:middle;width:100%;line-height:100%;']").remove();
                                $("[style='animation: mymove_success 15s 1s infinite;']").remove();
                                
                                }
                                
                                else if (realbb.indexOf('9bbg.com') != -1) {
                                
                                var vv = $("[style='animation: mymove_success 15s 1s infinite;']");
                                if (vv != null) vv.remove();
                                
                                $('a[style]').each(function(index, el) {
                                                   var isFind = false;
                                                   
                                                   if (el.attributes.length > 1) {
                                                   var textValue = el.attributes[1].textContent;
                                                   if (textValue.indexOf('display: block; ') != -1) {
                                                   isFind = true;
                                                   }
                                                   }
                                                   
                                                   if (isFind) {
                                                   el.remove();
                                                   
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('97kp.me') != -1 || realbb.indexOf('97kpw.me') != -1 || realbb.indexOf('97kpw.com') != -1 || realbb.indexOf('97kpb.com') != -1 || realbb.indexOf('wuqimh.com') != -1) {
                                
                                $('body>div').each(function(index, el) { //删除很多小方块单行
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                $('div[style]').each(function(index, el) {
                                                     var isFind = false;
                                                     debugger;
                                                     if (el.attributes.length > 1) {
                                                     var textValue = el.attributes[1].textContent;
                                                     if (textValue.indexOf('display: block; ') != -1) {
                                                     isFind = true;
                                                     }
                                                     }
                                                     
                                                     if (isFind) {
                                                     el.remove();
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
                                
                                $("[style='margin: 0px; padding: 0px; width: 300px; height: 250px;']").remove();
                                $("[style='position: fixed; bottom: 2px; right: 0px; width: 300px; height: 270px; overflow: hidden; z-index: 2147483647;']").remove();
                                $("#adModal").remove();
                                
                                }
                                
                                else if (realbb.indexOf('mp4pa.com') != -1) {
                                
                                $('body>div').each(function(index, el) { //删除很多小方块单行
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                $('div[style]').each(function(index, el) {
                                                     var isFind = false;
                                                     debugger;
                                                     if (el.attributes.length > 1) {
                                                     var textValue = el.attributes[1].textContent;
                                                     if (textValue.indexOf('display: block; ') != -1) {
                                                     isFind = true;
                                                     }
                                                     }
                                                     
                                                     if (isFind) {
                                                     el.remove();
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
                                
                                $("[style='margin-left: 0px; margin-bottom: 0px;']").remove();
                                $("brde")[0].style.zoom = 0.01;
                                $("ifeam")[0].style.zoom = 0.01;
                                }
                                
                                else if (realbb.indexOf('zxdy777.com') != -1) {
                                $("[style='display:block;width:100%;height:60px;']").remove();
                                $(".wzghBox").remove();
                                $(".imgBox").remove();
                                $(".qqunBox").remove();
                                $(".hbptBox").remove();
                                $("#mySwipe").remove();
                                
                                } else if (realbb.indexOf('20aaaa.com') != -1 || realbb.indexOf('cbkaam.com') != -1 || realbb.indexOf('leiguang.tv') != -1 || realbb.indexOf('bobo123.me') != -1) {
                                $("center").remove();
                                $(".custom_body").remove();
                                $("#apDivd").remove();
                                $(".top").remove();
                                $(".uii").remove();
                                $(".wrap.mt20").remove();
                                $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
                                $("div[style='margin-top:2px;height:100px;width:100%;background:#fff;padding-right:10px;']").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('20aaaa.com') != -1 || realbb.indexOf('cbkaam.com') != -1 || realbb.indexOf('leiguang.tv') != -1 || realbb.indexOf('bobo123.me') != -1) {
                                $("center").remove();
                                $(".custom_body").remove();
                                $("#apDivd").remove();
                                $(".top").remove();
                                $(".wrap.mt20").remove();
                                $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('qinian.cc') != -1 || realbb.indexOf('idm.cc') != -1) {
                                
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                
                                }
                                
                                else if (realbb.indexOf('46lj.com') != -1 || realbb.indexOf('26uuu.com') != -1 || realbb.indexOf('sex5.com') != -1) {
                                
                                $("#favCanvas").remove();
                                $(".top_box").remove();
                                $("#leftFloat").remove();
                                $("#rightFloat").remove();
                                $("#rightCouple").remove();
                                $("#leftCouple").remove();
                                
                                }
                                
                                else if (realbb.indexOf('fjisu.com') != -1 || realbb.indexOf('yse123.com') != -1) {
                                $('body>div').each(function(index, el) {
                                                   var name = el.className;
                                                   var id_name = el.id;
                                                   if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                                                   el.remove();
                                                   return false;
                                                   }
                                                   });
                                $("[style='display: block; margin: 0px; padding: 0px; width: 100%; height: 97.03125px;']").remove();
                                $("[style='left: 0px; bottom: 0px; overflow: hidden; z-index: 92147483647; width: 100%; position: fixed !important; height: 129px;']").remove();
                                
                                }
                                
                                //         var n = $('body>div');
                                //    var b = $('#ceshi');
                                //    var l = n.length;
                                //        if(l>=0 && b.length==0){
                                //          n[l-2].insertAdjacentHTML('beforeBegin',"<div id = 'ceshi'><a href='http://www.baidu.com' ><img src='http://softhome.oss-cn-hangzhou.aliyuncs.com/max/qq.png' style='max-width: 100%;'></img></a></div>");
                                //        }
                                //            var b =  $("iframe").contents().find("body");
                                //           var n = $("iframe").contents().find("#ceshi");
                                //            if(n.length==0){
                                //                $("iframe").contents().find("body").append("<div id = 'ceshi'><a href='http://www.baidu.com' ><img src='http://softhome.oss-cn-hangzhou.aliyuncs.com/max/qq.png' style='max-width: 100%;'></img></a></div>");}
                                //        }
                                };
                                function startCheckAdBlock() {
                                if (AdBlockupdateTime == -1) {
                                AdBlockupdateTime = setInterval(updateAdBlock, 0.25);
                                }
                                };
                                
                                function delAllElementsByCallName(name) {
                                var remNode = document.getElementsByClassName(name);
                                for (var i = 0; i < remNode.length; i++) {
                                var delNode = remNode[i];
                                delNode.parentNode.removeChild(delNode);
                                
                                }
                                }
                                
                                function delAllElementsByTagName_idname(name, idName) {
                                var remNode = document.getElementsByTagName(name);
                                for (var i = 0; i < remNode.length; i++) {
                                var delNode = remNode[i];
                                var idValue = delNode.getAttribute('id');
                                if (idValue != null && idValue.indexOf(idName) != -1) {
                                delNode.parentNode.removeChild(delNode);
                                }
                                }
                                }
                                
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
    
};


function changeTxUrlVid(x){
    var ret = x;
    if (x.indexOf(".html?vid=")!=-1){
        ret = x.replace(".html?vid=","/") + ".html";
    }
    return ret;
}
;

function webUrlAndBody(){
    var v1 = document.location.href;
    if (v1.indexOf("m.v.qq.com")!=-1){//qq需要替换
        var qq = "m.v.qq.com";
        v1 = changeTxUrlVid(v1.replace(qq,"v.qq.com"));
    }
    var v2 = document.documentElement.innerHTML;
    var ret =new Array(v1,v2);
    return ret;
}
