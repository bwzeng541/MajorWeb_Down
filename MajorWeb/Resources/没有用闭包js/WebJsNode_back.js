
;var updateTime = -1;

;function stopCheckList()
{
    clearInterval(updateTime);
    updateTime = -1;
}

;function startCheckList()
{
    if(updateTime==-1){
        updateTime = setInterval('updateList()', 1000);
    }
}

;function updateList()
{
    var realbb  = window.location.href;
    var videoTitle   = document.title.replace(/[ /d]/g, '');//查找《》里面的数据，并删除数字;
    var startPos = videoTitle.indexOf('《');
    var endPos = videoTitle.indexOf('》');
    if(startPos!=-1&&endPos!=-1){
        videoTitle = videoTitle.substring(startPos+1,endPos);
    }
    var urlArray = new Array();
    var select = 0;
    if (realbb.indexOf('m.iqiyi.com')!=-1){//爱奇艺
        var list = document.getElementsByClassName('juji-list  clearfix');
        if (list.length==0){
            list = document.getElementsByClassName('m-album-num clearfix item');
        }
        if(list.length==0){
            list = document.getElementsByClassName('m-album-num clearfix');
        }
        if(list.length > 0){
            var i;
            var jujilist;
            for (i = 0; i < list.length; i++)
            {
                jujilist = list[i].getElementsByTagName('a');
            }
            
            for(i = 0;i <jujilist.length;i++ ){
                var retValue = {'url':'http:'+jujilist[i].getAttribute('href'),'title':jujilist[i].getAttribute('curpage-index')};
                urlArray.push(retValue);
            }
            if(urlArray.length > 0){
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        }
        else{
            var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
            window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
        }
    }
    else  if (realbb.indexOf('m.m4yy.com')!=-1)//没事影院
    {
        var list = document.getElementsByClassName('plau-ul-list');
        if (list !=null && list.length>0){
            var vv = list[0].getElementsByTagName('li');
            for (i = 0; i < vv.length; i++)
            {
                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                var title = vv[i].getElementsByTagName('a')[0].getAttribute('title');
                var retValue = {'url':'http://m.m4yy.com/'+value,'title':title};
                urlArray.push(retValue);
                if(realbb.indexOf(value)!=-1){
                    select = i;
                }
            }
            if(urlArray.length > 0){
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
            else{
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        }
        else{
            var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
            window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
        }
    }
    else if (realbb.indexOf('lemaotv.net')!=-1)//乐猫
    {
        var list = document.getElementsByClassName('detail-video-select');
        if (list !=null && list.length>0){
            var vv = list[0].getElementsByTagName('li');
            for (i = 0; i < vv.length; i++)
            {
                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                var title = vv[i].getElementsByTagName('a')[0].innerText;
                var retValue = {'url':'http://m.lemaotv.net/'+value,'title':title};
                urlArray.push(retValue);
                if(realbb.indexOf(value)!=-1){
                    select = i;
                }
            }
            if(urlArray.length > 0){
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
            else{
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        }
    }
    else if (realbb.indexOf('imeiju.cc')!=-1){
        var list = document.getElementsByClassName('playlistlink-1 list-15256 clearfix');
        if (list !=null && list.length>0){
            var vv = list[0].getElementsByTagName('li');
            for (i = 0; i < vv.length; i++)
            {
                var value = vv[i].getElementsByTagName('a')[0].getAttribute('href');
                var title = vv[i].getElementsByTagName('a')[0].innerText;
                var retValue = {'url':'http://imeiju.cc/'+value,'title':title};
                urlArray.push(retValue);
                if(realbb.indexOf(value)!=-1){
                    select = i;
                }
            }
            if(urlArray.length > 0){
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
            else{
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        }
        
    }
    else if (realbb.indexOf('zymk.cn')!=-1){
        var textNodes = document.evaluate('/html/body/section/div[2]/div[1]/h1', document, null, XPathResult.ANY_TYPE, null).iterateNext();
        videoTitle = document.title;
        if(textNodes){
            videoTitle  = textNodes.textContent;
        }
        
        var list = document.getElementsByClassName('chapterlist');
        if (list !=null && list.length>0){
            var vv = list[0].getElementsByTagName('li');
            for (i = 0; i < vv.length; i++)
            {
                var object = vv[i];
                var url = object.getElementsByTagName('a')[0].getAttribute('href');
                var title = object.getElementsByTagName('a')[0].getAttribute('title');
                if(url!=null && title!=null){
                    var retValue = {'url':realbb+url,'title':title};
                    urlArray.push(retValue);
                }
                if(realbb.indexOf(url)!=-1){
                    select = i;
                }
            }
            if(urlArray.length > 0){
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
            else{
                var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
                window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
            }
        }
    }
    else if (realbb.indexOf('xcmh.cc')!=-1){
        var listObject = $('#article-list');
        if(listObject.length>0){
            var t = $('h1');
            if(t.length>0){
                videoTitle = t[0].textContent;
            }
            var arr = listObject[0].children;
            $.each(arr,function(index,value){
                   var retValue = {'url':value.children[0].href,'title':value.children[0].textContent};
                   urlArray.push(retValue);
                   });
        }
        var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
    }
    else if (realbb.indexOf('manben.com')!=-1){
        var o = $('.detailTop>.content>.info>.title');
        if(o.length>0){
            videoTitle = o[0].textContent;
            o = $('li:has(a):has([href])');
            $.each(o,function(index,value){
                   var retValue = {'url':value.children[0].href,'title':value.children[0].textContent};
                   urlArray.push(retValue);
                   });
            urlArray = urlArray.reverse();
        }
        var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
    }
    else if(realbb.indexOf('pufei.net')!=-1){
        var o =  $('h1');
        if(o.length>0){
            videoTitle = o[0].textContent;
            o = $('.chapter-list>ul>li');
            $.each(o,function(index,value){
                   var retValue = {'url':value.children[0].href,'title':value.children[0].textContent};
                   urlArray.push(retValue);
                   });
            
        }
        var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
    }//[0].href
    else if(realbb.indexOf('manhua123.net')!=-1){
        var o =  $('h1');
        if(o.length>0){
            videoTitle = o[0].textContent;
            o =  $('.Drama.autoHeight >li>a');
            $.each(o,function(index,value){
                   var retValue = {'url':value.href,'title':value.textContent};
                   urlArray.push(retValue);
                   });
            urlArray = urlArray.reverse();
        }
        var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
    }
    else{
        var dic = {'listArray': urlArray,'ShowName':videoTitle,'SelectIndex':select};
        window.webkit.messageHandlers.sendWebJsNodeMessageInfo.postMessage(dic);
    }
}

;function updateZySort(){
    var realbb  = window.location.href;
    var result = document.evaluate('//*[@id=\'classTabs\']/div/div/ul[1]', document, null, XPathResult.ANY_TYPE, null);
    var nodes = result.iterateNext(); //枚举第一个元素
    var classArray = new Array();
    while (nodes){
        var vv = nodes.getElementsByTagName('li');
        for (i = 0; i < vv.length; i++)
        {
            var object = vv[i];
            var url = object.getElementsByTagName('a')[0].getAttribute('href');
            var title = object.getElementsByTagName('a')[0].getAttribute('title');
            if(url!=null && title!=null){
                var retValue = {'url':realbb+url,'title':title};
                classArray.push(retValue);
            }
        }
        break;
    }
    window.webkit.messageHandlers.sendWebJsNodeMessageZySort.postMessage(classArray);
}

;function clickfixUrl(url)
{
    window.setTimeout(delayCilck, 1000 * 2);
}

;function delayCilck(){
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

;function gotoParseWeb(){
    //虎牙某个路径下的所有a标签
    var realbb = window.location.href;
    var retArray = new Array();
    if (realbb.indexOf('huya.com') != -1){
        var result = document.evaluate('/html/body/div[2]/div/div/div[1]/div//a', document, null, XPathResult.ANY_TYPE, null);
        var nodes = result.iterateNext(); //枚举第一个元素
        while (nodes){
            // 对 nodes 执行操作;
            var url = nodes.href;
            var imgUrl = '';
            var img = nodes.getElementsByTagName('img');
            if(img!=null){
                imgUrl =  img[0].getAttribute('src');
            }
            if(imgUrl.length>2 ){
                var dic = {'imgUrl': 'http:'+imgUrl,'url':url ,'referer':realbb};
                retArray.push(dic);
            }
            nodes=result.iterateNext(); //枚举下一个元素
        }
    }
    //end
    return retArray;
}

;function getWebNoInFoJs(responseText){
    responseText = decodeURIComponent(responseText);
    var link = $(responseText);
    var vv =  link.find('.channel-link');
    var length = vv.length;
    var retArray = new Array();
    for (var i = 0; i < length; i++) {
        var url = vv[i].href;
        var pos = url.indexOf('/channel');
        if(pos!=-1){
            url = 'http://m.icantv.cn' + url.substr(pos);
            var dic = {'url': url,'name':vv[i].textContent};
            retArray.push(dic);
        }
    }
    return retArray;
}

;function getWebChanneInFoJs(responseText){
    responseText = decodeURIComponent(responseText);
    var link = $(responseText);
    var vv =  link.find('.play-channel').children('span');
    var length = vv.length;
    var retArray = new Array();
    for (var i = 0; i < length; i++) {//字符串替换
        var newPlay = 'sw_play(';
        newPlay+=i.toString();
        newPlay+=');';
        var newHtml = responseText.replace('sw_play(0);',newPlay);
        var dic = {'html': newHtml,'name':vv[i].textContent};
        retArray.push(dic);
    }
    return retArray;
}

;function addPicIntoWeb(text){
    $('body').append(text);
}

;function getWebLists(text)
{
    var realbb = window.location.href;
    var retArray = new Array();
    var imgSrc = '';
    if (realbb.indexOf('xcmh.cc')!=-1){
        var ll = $('option').length/2;
        for(var i =0;i<ll;i++){
            retArray.push(text+'?p='+(i+1).toString());
        }
        var b = $('.mh_comicpic');
        if(b.length>0){
            imgSrc = (b.children('img')[0]).src;
        }
    }
    else if(realbb.indexOf('pufei.net')!=-1){
        var  o=  $('.manga-page');
        var debugT = '';
        var total = 0;
        
        if(o.length>0){
            var j = o[0].textContent.replace(/(^\s*)|(\s*$)/g, '');
            var pos1 = j.lastIndexOf('/');
            var pos2 = j.lastIndexOf('P');
            debugT= j;
            if(pos1!=-1&&pos2!=-1&&pos2>pos1){
                total = parseInt(j.substring(pos1+1,pos2));
            }
            for(var i = 0;i<total;i++){
                retArray.push(text+'?af='+(i+1).toString());
            }
            var o1 = $('.manga-box>img');
            if(o1.length>0){
                imgSrc = o1[0].src;
            }
        }
    }//
    else if(realbb.indexOf('manhua123.net')!=-1){
        var o = $('tbody>tr>td>img');
        var o1 = $('#k_total');
        if(o.length>0){
            imgSrc = o[0].src;
        }
        if(o1.length>0){
            var n =  parseInt(o1[0].textContent);
            for(var i =0;i<n;i++){
                retArray.push(text+'?p='+(i+1).toString());
            }
        }
    }
    var bb = '<img id=\"manga\" src=\"';
    bb+=imgSrc;
    bb+='\"style=\"max-width: 100%;\">';
    var dic = {'retArray': retArray,'dom':bb};
    return dic;
}

//删除广告扩展代码
;var AdBlockupdateTime = -1;

;function stopCheckAdBlock()
{
    clearInterval(AdBlockupdateTime);
    AdBlockupdateTime = -1;
}

;function startCheckAdBlock()
{
    if(AdBlockupdateTime==-1){
        AdBlockupdateTime = setInterval('updateAdBlock()', 0.25);
    }
}

;function updateAdBlock()
{
    var realbb  = window.location.href;
    if (realbb.indexOf('5tdy.com')!=-1){//
        $('body>div').each(function(index, el) {
                           var name =  el.className;
                           var id_name =  el.id;
                           if (id_name.length>0 && name.length>0 && (name==id_name)){
                           el.style.zoom = 0.001;
                           return false;
                           }
                           });
        
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
}


;!function breakDebugger(){
    if(checkDebugger()){
        breakDebugger();
    }
}();

;function checkDebugger(){
    const d=new Date();
    debugger;
    const dur=Date.now()-d;
    if(dur<5){
        return false;
    }else{
        return true;
    }
}
